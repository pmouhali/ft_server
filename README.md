# ft_server

### Docker :

Une image Docker contient tout ce qu'on décide d’installer (Java, une base de donnée, un script qu'on va lancer, etc…) pour un container, mais est dans un état inerte. Les images sont créées à partir de fichiers de configuration, nommés “Dockerfile”, qui décrivent exactement ce qui doit être installé sur le système. Un conteneur est l’exécution d’une image : il possède la copie du système de fichiers de l’image, ainsi que la capacité de lancer des processus. Dans ce conteneur, on va pouvoir interagir avec les applications installées dans l’image, exécuter des scripts, faire tourner un serveur, etc.

Une fois le Dockerfile remplit avec ce qu'on veut, on peut build l'image (comme compiler) puis run un container à partir de cette image (executer). Dans le dossier du Dockerfile :

    docker build -t [nom-qu-on-veut-donner-a-l-image] .

    docker run -ti [nom-qu-on-a-donner-a-l-image]

      
Dockerfile line:1 : 
    `FROM debian:buster`

L'instruction FROM permet de spécifier une image existante sur laquelle on veut se baser. Parfait pour nous, on va démarrer depuis une image qui contient l'OS Debian Buster.

Si on build puis run avec cette seule instruction, on obtient un container dans lequel est installé Debian Buster. L'option -i de la commande run nous permet d'être en mode interactif, on a accès à un terminal. Si on lance la commande ls dans ce terminal, on peut voir que les fichiers présents sont seulement ceux livrés avec l'installation de Debian.

Pour installer des paquets et configurer le serveur avec les autres services, on va avoir besoin d'un script pour lancer plein de commandes à notre place et de fichiers de configuration. Pour que le container ai accès aux fichiers dont on a besoin, on va les copier de notre dossier src/ au container. On va avoir besoin de l'instruction COPY du Dockerfile.

Dockerfile line:3-7 :
    `COPY src/install.sh ./`
    
Maintenant si on build/run puis ls, on peut voir que les fichier copiés sont présents en plus de ceux livrés par Debian.
On peut donc lancer le script sans problème.

src/start.sh line:2-9 : `apt-get -y install nginx`

Le script installe d'abord tout les paquets dont on aura besoin. Maintenant, on a les fichier Debian, ceux de tout les paquets installés (exactement comme si ils avaient été installés sur notre machine), et nos fichiers de config et scripts.

### LEMP Stack

En gros une LEMP stack, c'est le combo linux/nginx/php/mysql pour faire tourner un serveur. On a besoin de ces quatres outils (en plus de wordpress et phpmyadmin). On peut commencer par suivre ce tuto pour faire une installation basique et vérifier que tout marche : https://www.digitalocean.com/community/tutorials/how-to-install-linux-nginx-mariadb-php-lemp-stack-on-debian-10

src/install.sh line:16-24 : 
`mkdir /var/www/localhost`

On crée le dossier dans lequel le serveur ira chercher les pages web (src/localhost.conf line:5)

`cp localhost.conf /etc/nginx/sites-available/localhost`

On copie le fichier de config custom dans le repertoire nginx (le fichier devra juste s'appeler localhost)

`ln -s /etc/nginx/sites-available/localhost /etc/nginx/sites-enabled/`

On link le fichier de conf de sites-available avec celui de sites-enabled

`cp test.html /var/www/localhost/test.html`

`cp info.php /var/www/localhost/info.php`

On copie nos deux fichiers tests, un html basique pour voir que le serveur redirige bien sur les bonnes url, un php pour voir si la config php fonctionne, on les place dans le dossier dans lequel le serveur ira chercher les pages web.

`/etc/init.d/php7.3-fpm start`

On execute le script d'initialisation de php-fpm (c'est pas dans le tuto, on vérifie qu'on l'a dans le container : ls /etc/init.d/, si on l'as pas on a pas installé les bons paquets ou une erreur est survenue.)

src/localhost.conf line:16 : `fastcgi_pass unix:/var/run/php/php7.3-fpm.sock;`

On vérifie que la version de php est la bonne (sinon le processing php fonctionnera pas).


Puis on peut tenter de voir si l'on peut accéder à nos deux urls : localhost/test.html et localhost/info.php

Si le html return une 404, relancer en mappant les ports :

docker run -p 80:80 -ti [image]

Si le php return une 404 :

restart le script php7.3-fpm (dans la ligne de commande du container).
