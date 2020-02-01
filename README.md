# ft_server

### Usage :

Dans le repo :

    docker build -t [nom-image] .
    docker run -p 443:443 [nom-image]
    
Urls disponibles (navigateur, le certificat ssl n'est pas reconnu, le navigateur renverra une erreur de connexion non privée, poursuivre la navigation quand même) :
- localhost/index.html
- localhost/wordpress
- localhost/wordpress/wp-config
- localhost/phpMyAdmin

Pour pouvoir utiliser shell dans le container :
    
    docker exec -it [pid ou nom du container] /bin/bash

Pour faire des tests de fonctionnement basiques : 

    cd /root/tests/
    bash test.sh
    
- localhost/test.html (la configuration basique fonctionne)
- localhost/info.php (la configuration php fonctionne)
- localhost/todo_list.php (la configuration php/sql fonctionne)

# tutoriel

### Docker-machine mac 42

Docker utilise une techno native Linux donc on devra le faire tourner sur machine virtuelle. Pour pas se prendre la tête :

- installer VirtualBox depuis le Managed Software Center (dispo sur les macs de l'école)
- installer Docker toujours depuis le Managed Software Center
- run ce script : https://github.com/Millon15/php_piscine/blob/master/docker_init.sh

Pour faire tourner le serveur on le branche sur un ou plusieurs ports (80, 443). Le serveur écoute le port X du container. Mais le port X du container n'est pas forcément le port X de notre machine (sur laquelle tourne notre navigateur), ça va poser problème pour se connecter au serveur. Il faudra 'mapper' les ports : c'est à dire les faire correspondre.

Au moment de lancer un container, on pourra utiliser l'option '-p' pour que le port X du container corresponde au port X de la machine sur laquelle le container tourne.

Puisqu'on fait tourner notre container sur docker-machine, une machine virtuelle, la commande de mapping de port de docker ne mappera pas le port du container à celui de notre mac, mais à celui de la machine virtuelle. Meme chose pour la VM, il faudra mapper son port au notre.

Donc : port:mac <-> port:vm <-> port:container.

Apres avoir run le script sans erreur, pour map le port de la vm au notre (443 est le numero de port pour ma config, on peut en mettre un autre) :

    docker-machine stop default
    vboxmanage modifyvm default --natpf1 "localhost,tcp,,443,,443"
    docker-machine start default

### Docker :

Une image Docker contient tout ce qu'on décide d’installer (Java, une base de donnée, un script qu'on va lancer, etc…) pour un container, mais est dans un état inerte. Les images sont créées à partir de fichiers de configuration, nommés “Dockerfile”, qui décrivent exactement ce qui doit être installé sur le système. Un conteneur est l’exécution d’une image : il possède la copie du système de fichiers de l’image, ainsi que la capacité de lancer des processus. Dans ce conteneur, on va pouvoir interagir avec les applications installées dans l’image, exécuter des scripts, faire tourner un serveur, etc.

Une fois le Dockerfile remplit avec ce qu'on veut, on peut build l'image (comme compiler) puis run un container à partir de cette image (executer). Dans le dossier du Dockerfile :

    docker build -t [nom-qu-on-veut-donner-a-l-image] .

    docker run [nom-qu-on-a-donner-a-l-image]

      
**Dockerfile line:1 :** `FROM debian:buster-slim`

L'instruction FROM permet de spécifier une image existante sur laquelle on veut se baser. Parfait pour nous, on va démarrer depuis une image qui contient l'OS Debian Buster.

Si on build puis run avec cette seule instruction, on obtient un container dans lequel est installé Debian Buster. L'option -i de la commande run nous permet de lancer un container en mode interactif : on a accès au terminal du container. Si on lance la commande ls dans ce terminal, on peut voir que les fichiers présents sont seulement ceux livrés avec l'installation de Debian.

Dans l'idéal, on veut obtenir un container dans lequel le serveur est déjà prêt et ne nécéssite aucune configuration manuelle une fois lancé.

Pour configurer le serveur, il faudra installer les paquets dont nous aurons besoin (php pour phpMyAdmin par exemple), et y copier les fichiers et dossiers que nous utiliserons (un fichier de configuration nginx par exemple).

Pour executer une commande pendant la création de l'image, et donc avant le lancement du container, on utilise l'instruction RUN du Dockerfile, qui pourra executer une commande Shell. On peut lui spécifier directement les commandes ou bien lui demander d'executer un script qui lui contiendrai toutes nos commandes et opérations (copier des fichiers par exemple).

Ici, on utilisera l'instruction RUN uniquement pour installer les paquets.

**Dockerfile line:3-12 :** `RUN apt-get -y update && apt-get -y install mariadb-server \ 
			wget \
			php \
			php-cli \
	 		php-cgi \
			php-mbstring \
			php-fpm \
			php-mysql \
			nginx \
			libnss3-tools`
            
Pour choisir comment construire son Dockerfile : https://docs.docker.com/develop/develop-images/dockerfile_best-practices/
    
Maintenant si on build/run puis ls, on peut voir que les fichiers présent sont ceux livrés par Debian et ceux installés par les libs (paquets).

**src/container_entrypoint.sh line:3-12 :** `COPY srcs ./root/`

Tout le contenu du dossier 'srcs' tel quel sera copié dans le dossier 'root' du container. Le container possèdera donc, entres autres, dans son dossier 'root' nos fichiers de configurations, et nos dossiers d'installation de wordpress et phpMyAdmin.

**Dockerfile line:16 :** `WORKDIR /root/`

L'instruction WORKDIR permet de spécifier dans quel dossier se placer au lancement du container, si un ENTRYPOINT ou CMD (https://docs.docker.com/engine/reference/builder/#entrypoint) est spécifié, les commandes lancées le seront depuis ce dossier. Si la commande est un script à executer, il est nécéssaire de lancer le script dans le repertoire ou se trouve le script.

**Dockerfile line:16 :** `ENTRYPOINT ["bash", "container_entrypoint.sh"]`

L'instruction ENTRYPOINT permet (explication très grossière) de préciser une commande à executer au lancement du container.
On va lancer le script 'container_entrypoint.sh' qui contient les opérations qui finalisent la config du serveur.

**Notes :**

Le script 'container_entrypoint.sh' lance la commande `service nginx start`. Cette commande démarre le serveur nginx.

Si on executait ce script via l'instruction RUN du Dockerfile, pendant la construction de l'image, au lancement du container le serveur ne serait pas du tout démarré, et donc ne fonctionnerai pas. Une image ne peut contenir de processus. Elle ne contiendra que des données 'statiques', comme des fichiers, des instructions de déplacement de dossier, installer des fichers (des paquets), etc.

Toutes les instructions relatives a des processus devront être lancées une fois le container démarré, sois manuellement dans le container, sois via une instruction ENTRYPOINT ou CMD par exemple.

### LEMP Stack

En gros une LEMP stack, c'est le combo linux/nginx/php/mysql pour faire tourner un serveur. On a besoin de ces quatres outils (en plus de wordpress et phpmyadmin). On peut commencer par suivre ce tuto pour faire une installation basique et vérifier que tout marche : https://www.digitalocean.com/community/tutorials/how-to-install-linux-nginx-mariadb-php-lemp-stack-on-debian-10


**srcs/container_entrypoint.sh line:3-6 :** (on peut skip la partie creation user sql du tuto pour le moment)

`mkdir /var/www/localhost`

On crée le dossier dans lequel le serveur ira chercher les pages web (src/localhost_index_on line:5)

`cp localhost_index_on /etc/nginx/sites-available/localhost`

On copie le fichier de config custom dans le repertoire nginx (le fichier devra juste s'appeler localhost)

`ln -s /etc/nginx/sites-available/localhost /etc/nginx/sites-enabled/`

On link le fichier de conf de sites-available avec celui de sites-enabled

**srcs/tests/test.sh line:3-5:**

`cp info.php /var/www/localhost/info.php`

On copie nos fichiers tests, un html basique pour voir que le serveur redirige bien sur les bonnes url, un php pour voir si la config php fonctionne (todo_list.php servira plus tard), on les place dans le dossier dans lequel le serveur ira chercher les pages web.

**srcs/container_entrypoint.sh line:27-30 :** `service nginx start`

On démarre le serveur.

`/etc/init.d/php7.3-fpm start`

On execute le script d'initialisation de php-fpm (c'est pas dans le tuto, on vérifie qu'on l'a dans le container : ls /etc/init.d/, si on l'as pas on a pas installé les bons paquets ou une erreur est survenue.)

**srcs/localhost_index_on line:30 :** `fastcgi_pass unix:/var/run/php/php7.3-fpm.sock;`

Vérifier sur cette ligne que la version de php est la bonne (sinon le processing php fonctionnera pas).


Puis on peut tenter de voir si l'on peut accéder à nos deux urls : localhost/test.html et localhost/info.php

Si le html return une 404, relancer en mappant les ports (80 si la configuration est celle du tuto, 443 si la configuration est la même que la mienne c'est à dire utilisant ssl) :

    docker run -p 80:80 -ti [nom-qu-on-a-donner-a-l-image]

Pour vérifier qu'on peut effectivement accéder à notre base de données depuis d'autres services (ce qu'on va devoir faire pour wordpress et phpmyadmin), on va créer une base de donnée, et insérer des valeures random à l'intérieur, puis les récupérer depuis un script php :

**srcs/tests/test.sh line:9-18:**

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

**srcs/tests/todo_list.php :**

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

On décompresse et déplace le dossier 'wordpress' dans le dossier de sources.

    tar -xzvf latest-fr_FR.tar.gz

Dans le container, on devra placer ce dossier 'wordpress' dans le dossier ou le serveur va choper les pages web, donc on ajoute une instruction au script 'install.sh'.

**src/container_entrypoint.sh line:8 :** `cp -r wordpress /var/www/localhost/wordpress`
    
Puis on peut re build l'image et lancer le container.
    
**src/container_entrypoint.sh line:13-18 :**

`echo "CREATE DATABASE wordpress;" | mysql -u root`

On crée une bdd wordpress, un user dédié avec son mot de passe comme pour le test todo_list.

On peut ensuite aller à localhost/wordpress qui normalement amène à l'install menu de wordpress. On nous demandera le nom de la db, le nom de l'user sql, le password, le nom du serveur etc : 'wordpress', 'wordpress', 'password', 'localhost', etc.

Wordpress va soit créer, soit nous demander de créer (et copier le contenu dedans) le fichier 'wp-config.php'. Il devra se trouver dans le dossier 'wordpress/'. Si on est pas redirigé automatiquement, on peut maintenant aller à :

- localhost/wordpress : la page d'acceuil de notre site wordpress
- localhost/wordpress/wp-admin : le tableau de bord de notre site wordpress

Wordpress est maintenant installé grâce au fichier wp-config. Mais si on sort du container, ce fichier est perdu et il faudra refaire l'installation de wordpress à chaque fois qu'on relance un container. Il faut donc copier le fichier wp-config obtenu (copier/coller par exemple) et le placer dans le dossier wordpress du repo pour que Wordpress soit toujours installé après un rebuild/rerun.

Par contre la structure de bdd créee par et pour Wordpress dans la base 'wordpress' sera perdue. La solution est de faire un fichier de sauvegarde de l'état de la bdd et l'importer à chaque rerun. La base sera donc recréee et réimportée à chaque rerun (cela prends plus ou moins de temps en fonction du poids de la base) ce qui permettra de conserver l'installation complète. Pour ça on va utiliser phpMyAdmin.

### phpMyAdmin

(Hors container)

On télécharge phpMyadmin (on va également récupérer une archive compressée depuis le site officiel) :

    wget https://files.phpmyadmin.net/phpMyAdmin/4.9.0.1/phpMyAdmin-4.9.0.1-all-languages.tar.gz

On peut la décompresser, renommer le dossier pour que le nom soit plus court (juste phpMyAdmin) et le placer dans les sources.

**src/container_entrypoint.sh line:10 :** `cp -r phpMyAdmin /var/www/localhost/phpMyAdmin`

On peut rebuild et run.

On peut aller à 'localhost/phpMyAdmin' pour accéder à l'écran de connexion PMA, il suffit de se connecter avec l'user mysql wordpress : 'wordpress', 'password'.

On peut visualiser nos bases de données dans l'onglet base de donnée. On peut visualiser toutes les tables de la bdd wordpress ainsi que leur contenu.
Si on poste un commentaire sur wordpress, on pourra aussi le voir sur phpMyAdmin.

On va pouvoir récupérer le fichier de sauvegarde de l'état de la base de donnée wordpress. Il suffit de cliquer sur l'onglet 'Exporter', et récupérer le fichier 'wordpress.sql' (le navigateur le télécharge).

On peut maintenant placer ce fichier dans nos sources puis ajouter une instruction au run script pour importer la base.

**src/container_entrypoint.sh line:19 :** `mysql wordpress -u root < wordpress.sql`

### SSL

https://youtu.be/NXyE3mayrtg

https://youtu.be/_UpuZ0Y3k-c

https://lehollandaisvolant.net/?d=2019/01/07/22/57/47-localhost-et-https

https://letsencrypt.org/fr/docs/certificates-for-localhost/

https://r.je/guide-lets-encrypt-certificate-for-local-development

Si on a des 'erreurs' de type connexion non privée en utilisant ssl, c'est ok. On n'est pas censés utiliser ssl pour du local, le but du sujet n'est pas de réussir à faire accepter notre certificat self-signed ou local au navigateur.

### Autres

Pour afficher les logs du serveur en temps réel :

        tail -f /var/log/nginx/access.log /var/log/nginx/error.log 

### Sources

https://github.com/matteoolefloch/ft_server

https://www.digitalocean.com/community/tutorials/how-to-install-linux-nginx-mariadb-php-lemp-stack-on-debian-10

https://howto.wared.fr/installation-wordpress-ubuntu-nginx/

https://www.itzgeek.com/how-tos/linux/debian/how-to-install-phpmyadmin-with-nginx-on-debian-10.html
