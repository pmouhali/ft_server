# ft_server

### Usage :

Dans le repo :

    docker build -t [nom-image] .
    docker run -p 80:80 -ti [nom-image]
    
Dans le container une fois lancé :

    bash run.sh
    
Urls disponibles (navigateur) :
- localhost/wordpress
- localhost/wordpress/wp-config
- localhost/phpMyAdmin

Pour faire des tests de fonctionnement basiques :

    cd tests/
    bash test.sh
    
- localhost/test.html (la configuration basique fonctionne)
- localhost/info.php (la configuration php fonctionne)
- localhost/todo_list.php (la configuration php/sql fonctionne)

# tutoriel

### Docker :

Une image Docker contient tout ce qu'on décide d’installer (Java, une base de donnée, un script qu'on va lancer, etc…) pour un container, mais est dans un état inerte. Les images sont créées à partir de fichiers de configuration, nommés “Dockerfile”, qui décrivent exactement ce qui doit être installé sur le système. Un conteneur est l’exécution d’une image : il possède la copie du système de fichiers de l’image, ainsi que la capacité de lancer des processus. Dans ce conteneur, on va pouvoir interagir avec les applications installées dans l’image, exécuter des scripts, faire tourner un serveur, etc.

Une fois le Dockerfile remplit avec ce qu'on veut, on peut build l'image (comme compiler) puis run un container à partir de cette image (executer). Dans le dossier du Dockerfile :

    docker build -t [nom-qu-on-veut-donner-a-l-image] .

    docker run -ti [nom-qu-on-a-donner-a-l-image]

      
**Dockerfile line:1 :** 
    `FROM debian:buster-slim`

L'instruction FROM permet de spécifier une image existante sur laquelle on veut se baser. Parfait pour nous, on va démarrer depuis une image qui contient l'OS Debian Buster.

Si on build puis run avec cette seule instruction, on obtient un container dans lequel est installé Debian Buster. L'option -i de la commande run nous permet d'être en mode interactif, on a accès à un terminal. Si on lance la commande ls dans ce terminal, on peut voir que les fichiers présents sont seulement ceux livrés avec l'installation de Debian.

Pour installer des paquets et configurer le serveur avec les autres services, on va avoir besoin d'un script pour lancer plein de commandes à notre place et de fichiers de configuration. Pour que le container ai accès aux fichiers dont on a besoin, on va les copier de notre dossier src/ au container. On va avoir besoin de l'instruction COPY du Dockerfile.

**Dockerfile line:3-7 :**
    `COPY src/install.sh ./`
    
Maintenant si on build/run puis ls, on peut voir que les fichier copiés sont présents en plus de ceux livrés par Debian.
On peut donc lancer le script sans problème.

**src/install.sh line:2-9 :** `apt-get -y install nginx`

Le script installe d'abord tout les paquets dont on aura besoin. Maintenant, on a les fichier Debian, ceux de tout les paquets installés (exactement comme si ils avaient été installés sur notre machine), et nos fichiers de config et scripts.

### LEMP Stack

En gros une LEMP stack, c'est le combo linux/nginx/php/mysql pour faire tourner un serveur. On a besoin de ces quatres outils (en plus de wordpress et phpmyadmin). On peut commencer par suivre ce tuto pour faire une installation basique et vérifier que tout marche : https://www.digitalocean.com/community/tutorials/how-to-install-linux-nginx-mariadb-php-lemp-stack-on-debian-10

Le script install.sh est lancé à la création de l'image et non du container, il contient toutes les opérations 'statiques'.

**src/install.sh line:16-24 :** (on peut skip la partie creation user sql du tuto pour le moment)

`mkdir /var/www/localhost`

On crée le dossier dans lequel le serveur ira chercher les pages web (src/localhost.conf line:5)

`cp localhost.conf /etc/nginx/sites-available/localhost`

On copie le fichier de config custom dans le repertoire nginx (le fichier devra juste s'appeler localhost)

`ln -s /etc/nginx/sites-available/localhost /etc/nginx/sites-enabled/`

On link le fichier de conf de sites-available avec celui de sites-enabled

**src/tests/test.sh line:3-5:**

`cp info.php /var/www/localhost/info.php`

On copie nos fichiers tests, un html basique pour voir que le serveur redirige bien sur les bonnes url, un php pour voir si la config php fonctionne (todo_list.php servira plus tard), on les place dans le dossier dans lequel le serveur ira chercher les pages web.

Le script run.sh est lancé manuellement dans le container, il contient toutes les opérations qui concernent des processus.

**src/run.sh :**
`service nginx start`

On démarre le serveur.

`/etc/init.d/php7.3-fpm start`

On execute le script d'initialisation de php-fpm (c'est pas dans le tuto, on vérifie qu'on l'a dans le container : ls /etc/init.d/, si on l'as pas on a pas installé les bons paquets ou une erreur est survenue.)

**src/localhost.conf line:16 :** `fastcgi_pass unix:/var/run/php/php7.3-fpm.sock;`

On vérifie que la version de php est la bonne (sinon le processing php fonctionnera pas).


Puis on peut tenter de voir si l'on peut accéder à nos deux urls : localhost/test.html et localhost/info.php

Si le html return une 404, relancer en mappant les ports :

    docker run -p 80:80 -ti [nom-qu-on-a-donner-a-l-image]

Pour vérifier qu'on peut effectivement accéder à notre base de données depuis d'autres services (ce qu'on va devoir faire pour wordpress et phpmyadmin), on va créer une base de donnée, et insérer des valeures random à l'intérieures, puis les récupérer depuis un script php :

**src/tests/test.sh line:9-18:**

`echo "CREATE DATABASE testdb;" | mysql -u root`

On peut rentrer ces querys manuellement dans la console sql ou via un pipe avec echo (ce qui permet de les executer via un script).

`echo "CREATE USER 'test'@'localhost';" | mysql -u root`

`echo "SET password FOR 'test'@'localhost' = password('password');" | mysql -u root`

`echo "GRANT ALL ON testdb.* TO 'test'@'localhost' IDENTIFIED BY 'password' WITH GRANT OPTION;" | mysql -u root`

On crée un nouvel user mysql, différent de l'user root (nous) avec lequel on lance les commandes. On lui assigne un mot de passe. On lui donne tout les droits sur la base de donnée 'testdb'. Pourquoi ne pas utiliser root et pourquoi donner tout les droits ?

Les services tels que wordpress et phpMyAdmin ont besoin de se connecter à une base de donnée pour fonctionner. Il sera nécéssaire de pouvoir leur fournir le nom de la base de donnée, un user sql avec lequel se connecter à mysql, qui aura lui même accès à cette base (et donc des droits dessus), et le mot de passe de cet user sql.
Le script de test php 'todo_list' utilise le même principe, il récupère l'user et son mot de passe pour puiser des infos dans la bdd.

Si on décide d'utiliser 'root' et de lui assigner un mot de passe, lorsqu'on voudra executer d'autres commandes, on ne pourra plus le faire sans renseigner notre mot de passe (on verra des erreurs de ce genre) :

    ERROR 1045 (28000): Access denied for user 'root'@'localhost' (using password: NO)
    
Il est donc plus simple d'utiliser un user dédié. (Et c'est fortement recommandé pour des raisons de sécurité.)

**src/tests/todo_list.php :**

`$user = "test";`
On modifie le script du tuto pour qu'il fonctionne avec notre setup. Dans le script testdb.sh on a appelé l'user 'test'@'localhost'.

`$password = "password";`
Le mot de passe qu'on à défini est bien password.

`$database = "testdb";`
Notre base s'appelle testdb.

On peut maintenant aller vérifier que la page web affiche les infos de la db sur localhost/todo_list.php.

### Wordpress

(Hors container)

On commence par télécharger Wordpress (on va récupérer une archive compressée depuis le site officiel) :

    wget http://fr.wordpress.org/latest-fr_FR.tar.gz

On décompresse et déplace le dossier 'wordpress' dans le dossier où le serveur va choper les pages web :

    tar -xzvf latest-fr_FR.tar.gz
    mv wordpress/ /var/www/localhost/
    
Puis on peut re build l'image et lancer le container.
    
**src/run.sh line:4-8 :**

`echo "CREATE DATABASE wordpress;" | mysql -u root`

On crée une bdd wordpress, un user dédié avec son mot de passe comme pour le test todo_list.

On peut ensuite aller à localhost/wordpress qui normalement amène à l'install menu de wordpress. On nous demandera le nom de la db, le nom de l'user sql, le password, le nom du serveur etc : 'wordpress', 'wordpress', 'password', 'localhost', etc.

Wordpress va soit créer, soit nous demander de créer (et copier le contenu dedans) le fichier 'wp-config.php'. Il devra se trouver dans le dossier 'wordpress/'. Si on est pas redirigé automatiquement, on peut maintenant aller à :

- localhost/wordpress : la page d'acceuil de notre site wordpress
- localhost/wp-admin : le tableau de bord de notre site wordpress

Wordpress est maintenant installé grâce au fichier wp-config. Mais si on sort du container, ce fichier et perdu et il faudra refaire l'installation de wordpress à chaque fois qu'on relance un container. Il faut donc copier le fichier wp-config obtenu (copier/coller par exemple) et le placer dans le dossier wordpress du repo pour que wordpress soit toujours installé après un rebuild/rerun.
