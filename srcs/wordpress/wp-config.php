<?php
/**
 * La configuration de base de votre installation WordPress.
 *
 * Ce fichier contient les réglages de configuration suivants : réglages MySQL,
 * préfixe de table, clés secrètes, langue utilisée, et ABSPATH.
 * Vous pouvez en savoir plus à leur sujet en allant sur
 * {@link http://codex.wordpress.org/fr:Modifier_wp-config.php Modifier
 * wp-config.php}. C’est votre hébergeur qui doit vous donner vos
 * codes MySQL.
 *
 * Ce fichier est utilisé par le script de création de wp-config.php pendant
 * le processus d’installation. Vous n’avez pas à utiliser le site web, vous
 * pouvez simplement renommer ce fichier en "wp-config.php" et remplir les
 * valeurs.
 *
 * @package WordPress
 */

// ** Réglages MySQL - Votre hébergeur doit vous fournir ces informations. ** //
/** Nom de la base de données de WordPress. */
define( 'DB_NAME', 'wordpress' );

/** Utilisateur de la base de données MySQL. */
define( 'DB_USER', 'wordpress' );

/** Mot de passe de la base de données MySQL. */
define( 'DB_PASSWORD', 'password' );

/** Adresse de l’hébergement MySQL. */
define( 'DB_HOST', 'localhost' );

/** Jeu de caractères à utiliser par la base de données lors de la création des tables. */
define( 'DB_CHARSET', 'utf8mb4' );

/** Type de collation de la base de données.
 * N’y touchez que si vous savez ce que vous faites.
 */
define('DB_COLLATE', '');

/**#@+
 * Clés uniques d’authentification et salage.
 *
 * Remplacez les valeurs par défaut par des phrases uniques !
 * Vous pouvez générer des phrases aléatoires en utilisant
 * {@link https://api.wordpress.org/secret-key/1.1/salt/ le service de clefs secrètes de WordPress.org}.
 * Vous pouvez modifier ces phrases à n’importe quel moment, afin d’invalider tous les cookies existants.
 * Cela forcera également tous les utilisateurs à se reconnecter.
 *
 * @since 2.6.0
 */
define( 'AUTH_KEY',         '/Yexv~Y/~[LXh@nXD77a0(D~]+TG.-~(BIQLwM.*zY7L3>`Uc7@T&)k({5IyVrpP' );
						define( 'SECURE_AUTH_KEY',  'eT?Hnl[}<c-(v ap#b,$i]YVf xJhqvD#?AR8;WZ@K{1n~$ R4WfHIde+17PT8n+' );
										define( 'LOGGED_IN_KEY',    '/X:Y{(<BZMc)##q^MH,x=}!m]wNs(V1Geg]FBXrSaqdO.V3)VWIis:[S)?2P@s{L' );
						define( 'NONCE_KEY',        'dabq6Cf<U%#w~I.?%:g/%&/Z]fI~3@D}ayi1di/LQ+y`LvD4w}p:=(3yAx t/z7q' );
										define( 'AUTH_SALT',        ' `}tTPh3k~]eqtF3<@{$()GINmY]DDqy9NmoS;duT,cLU^/WZJuXIGa]$aih9p&9' );
										define( 'SECURE_AUTH_SALT', 'ZG[m3v~{Q-q~.Bn1fT.a(fa1 ;1:re1q3&k%^fLsZ;}VxTMO~EST{+g3=ED[FQkI' );
														define( 'LOGGED_IN_SALT',   '144{aCUi~Y;lcZLF2S2s-kkl+.Zl$nZuOwB(/WBMQ%K;=QwJs]d)H/weWr5/#%qk' );
														define( 'NONCE_SALT',       'G~yGs@x1x:vVF|6rgg6-E:qWmnpWijy|a+IY6<u7xT}7eS_Nm|-x0Seugo*y(`j6' );
																		/**#@-*/

																		/**
																		 * Préfixe de base de données pour les tables de WordPress.
																		 *
																		 * Vous pouvez installer plusieurs WordPress sur une seule base de données
																		 * si vous leur donnez chacune un préfixe unique.
																		 * N’utilisez que des chiffres, des lettres non-accentuées, et des caractères soulignés !
																		 */
																		$table_prefix = 'wp_';

																		/**
																		 * Pour les développeurs : le mode déboguage de WordPress.
																		 *
																		 * En passant la valeur suivante à "true", vous activez l’affichage des
																		 * notifications d’erreurs pendant vos essais.
																		 * Il est fortemment recommandé que les développeurs d’extensions et
																		 * de thèmes se servent de WP_DEBUG dans leur environnement de
																		 * développement.
																		 *
																		 * Pour plus d’information sur les autres constantes qui peuvent être utilisées
																		 * pour le déboguage, rendez-vous sur le Codex.
																		 *
																		 * @link https://codex.wordpress.org/Debugging_in_WordPress
																		 */
																		define('WP_DEBUG', false);

																		/* C’est tout, ne touchez pas à ce qui suit ! Bonne publication. */

																		/** Chemin absolu vers le dossier de WordPress. */
																		if ( !defined('ABSPATH') )
																				define('ABSPATH', dirname(__FILE__) . '/');

																		/** Réglage des variables de WordPress et de ses fichiers inclus. */
																		require_once(ABSPATH . 'wp-settings.php');

