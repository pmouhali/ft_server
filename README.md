# ft_server

forked this awesome repo from : https://github.com/matteoolefloch/ft_server

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
    `COPY src/start.sh ./`
    
Maintenant si on build/run puis ls, on peut voir que les fichier copiés sont présents en plus de ceux livrés par Debian.
On peut donc lancer le script sans problème.

src/start.sh line:2-9 : `apt-get -y install nginx`

Le script installe d'abord tout les paquets dont on aura besoin. Maintenant, on a les fichier Debian, ceux de tout les paquets installés (exactement comme si ils avaient été installés sur notre machine), et nos fichiers de config et scripts.
