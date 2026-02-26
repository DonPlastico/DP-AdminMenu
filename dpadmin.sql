-- =======================================================
-- DP-ADMINMENU | BASE DE DATOS PRINCIPAL (FULL)
-- =======================================================

-- 1. TABLA DE REPORTES
CREATE TABLE IF NOT EXISTS `dp_reports` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `citizenid` varchar(50) DEFAULT NULL COMMENT 'CitizenID del jugador que reporta',
  `steam_name` varchar(50) DEFAULT NULL COMMENT 'Nombre de Steam/FiveM del jugador',
  `sender_name` varchar(50) DEFAULT NULL COMMENT 'Nombre IC del jugador',
  `title` varchar(255) DEFAULT NULL COMMENT 'Asunto del reporte',
  `description` text DEFAULT NULL COMMENT 'Descripción detallada',
  `type` varchar(50) DEFAULT 'player' COMMENT 'Tipo: player o support',
  `status` varchar(50) DEFAULT 'open' COMMENT 'Estado: open, assigned, closed',
  `assigned_to` varchar(50) DEFAULT NULL COMMENT 'Nombre del Admin que tomó el reporte',
  `created_at` timestamp NULL DEFAULT current_timestamp() COMMENT 'Fecha de creación',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

INSERT INTO `dp_reports` (`citizenid`, `steam_name`, `sender_name`, `title`, `description`, `type`, `status`, `assigned_to`) VALUES
( 'VRC22222', 'El_Troll_67676767', 'Benito Camela', 'Ayuda me he quedado pillado', 'Estaba intentando hacer el truco de la bicicleta para saltar al aeropuerto y me he quedado bugeado dentro de una pared en los Santos Customs.\nNo puedo moverme ni usar /fix.\nNecesito que me saquéis o me hagáis TP.\nFoto de mi desgracia:\nhttps://i.ibb.co/676LwWkW/image.png', 'support', 'open', 'DonMaderos' ),
( 'VRC33333', 'Maria_Gamer_mannanster8881472', 'Lucía Fernanda', 'Toxicidad extrema en Hospital', 'Reporto al ID 104 y al ID 105.\nHan entrado al hospital gritando insultos racistas y machistas a todos los que estábamos en la sala de espera. No han roleado nada, solo han entrado a molestar.\nCuando les he dicho que pararan por OOC, me han dicho "llora más".\nAdjunto capturas del chat:\nhttps://i.ibb.co/yFnFvzMC/image.png', 'player', 'open', 'DonMaderos' ),
( 'VRC44444', 'timondiaboliquesnow', 'Paco Porras', 'Desaparición de piezas de tunning', 'Hola staff.\nAyer le puse el motor nivel 4 y los frenos de competición a mi Jester RR. Me gasté $45.000.\nHoy al sacar el coche, siento que corre menos. He ido al taller y me sale que tengo el motor de serie otra vez. No me parece justo perder el dinero por un bug del reinicio.', 'support', 'assigned', 'Poseidon_Admin' ),
( 'VRC55555', 'DarkSasuke', 'Shadow Moon', 'MG (MetaGaming) descarado', 'El sujeto ID 12 me ha llamado por mi nombre real de Steam "Sasuke" dentro del juego, cuando mi personaje lleva máscara y nunca le he dicho mi nombre.', 'player', 'open', NULL),
( 'VRC66666', 'lA_VAneSItA_MandoIN', 'Vanessa Romero', 'Bug visual ropa EMS', 'Cuando me pongo el uniforme de doctora, los brazos se me vuelven invisibles y el torso atraviesa el chaleco.\nHe probado a cambiarme de ropa y volver a ponérmelo pero sigue igual. Creo que es un problema del pack de ropa EUP nuevo.', 'support', 'open', NULL ),
( 'VRC77777', 'mercurynet_PATAPERRA_007', 'Agente Smith', 'Duda código penal', 'Perdón por molestar. Tengo a un detenido que ha intentado robar un coche de policía pero no lo ha conseguido abrir.', 'support', 'closed', 'DonMaderos' ),
( 'VRC88888', 'Gangster_Real', 'Lamar Davis', 'POWERGAMING en tiroteo', 'Estábamos en un tiroteo contra los Ballas en Grove Street.\nEl ID 55 ha recibido 4 tiros de AK-47 (se ve la sangre) y en vez de caerse o rolear heridas, ha salido corriendo saltando vallas como si fuera Spiderman y se ha metido en su casa para desconectarse (Combat Log).\nEs imposible que alguien corra así con 4 balazos en el pecho.', 'player', 'open', NULL ),
( 'VRC99999', 'Danny-B0ii', 'Ricardo Milos', 'Mapeado de la mansión invisible', 'He comprado la mansión de Vinewood Hills número 4 hace una semana.\nHoy al entrar, el suelo del garaje no tiene colisión y mis coches se caen al vacío infinito. He perdido un Adder y un T20 por esto.\nPor favor arreglad el mapa o devolvedme los coches al garaje público.', 'support', 'open', NULL ),
( 'VRC00001', 'ImmortalR-A-T', 'Roberto Carlos', 'Reporte Falso / Venganza', 'El usuario ID 90 me ha reportado antes por RDM, pero él no ha contado que me robó primero.', 'player', 'assigned', 'Admin_Ana' ),
( 'VRC00002', 'Hacker_Hunter', 'Neo Anderson', 'Posible Cheto (Aimbot)', 'Quiero que especteéis al ID 200.\nEstá dando todas las balas en la cabeza a una distancia imposible con una pistola de combate. Ha matado a 5 policías en 10 segundos.\nNo tengo pruebas definitivas, pero su comportamiento es muy sospechoso, mira a través de las paredes.\nUn saludo.', 'player', 'open', 'DonMaderos' );

-- =======================================================
-- 2. TABLA DE BANEOS (VERSIÓN COMPATIBLE SQL ANTIGUO)
-- =======================================================

-- 1. CREAR TABLA 'bans' (SI NO EXISTE, SE CREA YA CON TODAS LAS COLUMNAS)
CREATE TABLE IF NOT EXISTS `bans` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(50) DEFAULT NULL,
  `license` varchar(50) DEFAULT NULL,
  `discord` varchar(50) DEFAULT NULL,
  `ip` varchar(50) DEFAULT NULL,
  `reason` text DEFAULT NULL,
  `expire` int(11) DEFAULT NULL,
  `bannedby` varchar(50) DEFAULT 'Sistema',
  `status` varchar(50) DEFAULT 'active',          
  `created_at` timestamp NULL DEFAULT current_timestamp(), 
  PRIMARY KEY (`id`),
  KEY `license` (`license`),
  KEY `discord` (`discord`),
  KEY `ip` (`ip`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 2. INTENTAR AÑADIR COLUMNAS (POR SI LA TABLA YA EXISTÍA DE ANTES)
-- NOTA: Si esto da error "#1060 Duplicate column", IGNÓRALO, es que ya las tienes.
-- Simplemente hemos quitado el "IF NOT EXISTS" que te daba problemas.

SET @dbname = DATABASE();
SET @tablename = "bans";
SET @columnname = "status";
SET @preparedStatement = (SELECT IF(
  (
    SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
    WHERE
      (table_name = @tablename)
      AND (table_schema = @dbname)
      AND (column_name = @columnname)
  ) > 0,
  "SELECT 1",
  "ALTER TABLE bans ADD status varchar(50) DEFAULT 'active';"
));
PREPARE alterIfNotExists FROM @preparedStatement;
EXECUTE alterIfNotExists;
DEALLOCATE PREPARE alterIfNotExists;

SET @columnname = "created_at";
SET @preparedStatement = (SELECT IF(
  (
    SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
    WHERE
      (table_name = @tablename)
      AND (table_schema = @dbname)
      AND (column_name = @columnname)
  ) > 0,
  "SELECT 1",
  "ALTER TABLE bans ADD created_at timestamp NULL DEFAULT current_timestamp();"
));
PREPARE alterIfNotExists FROM @preparedStatement;
EXECUTE alterIfNotExists;
DEALLOCATE PREPARE alterIfNotExists;


-- 3. INSERTAR DATOS DE EJEMPLO
INSERT INTO `bans` (`name`, `license`, `discord`, `ip`, `reason`, `bannedby`, `expire`, `status`) VALUES
('Troll_Maximo', 
 'license:1a2b3c4d5e6f7g8h9i0j1k2l3m4n5o6p', 'discord:48291058291023', 'ip:192.168.0.15',
 'Uso de Mod Menu en zona segura', 'DonMaderos', 0, 'active'),
('Juan_Hacker', 
 'license:9z8y7x6w5v4u3t2s1r0q9p8o7n6m5l4k', 'discord:99988877766655', 'ip:203.0.113.45',
 'Aimbot detectado por Anticheat', 'DonMaderos', 0, 'active'),
('Pepito_Grief', 
 'license:5f4e3d2c1b0a9f8e7d6c5b4a3f2e1d0c', 'discord:11223344556677', 'ip:10.0.0.99',
 'Insultos OOC graves a administración', 'Admin_Luis', 1798750000, 'active'),
('Maria_FailRP', 
 'license:a1b2c3d4e5f6g7h8i9j0k1l2m3n4o5p6', 'discord:55667788990011', 'ip:172.16.254.1',
 'Combat Log reiterado en rol policial', 'Admin_Ana', 1792000000, 'active'),
('Test_Revocado', 
 'license:0p9o8i7u6y5t4r3e2w1q0p9o8i7u6y5t', 'discord:12312312312312', 'ip:8.8.8.8',
 'Baneo por error (Ya revocado)', 'DonMaderos', 0, 'revoked'),
('Marco_MarinateTTV', 
 'license:2b3c4d5e6f7g8h9i0j1k2l3m4n5o6p7q', 'discord:1122334455667788', 'ip:192.168.1.101',
 'Volar con la escoba del barrendero por encima de comisaría gritando hechizos (Noclip)', 'Hagrid_Staff', 0, 'active'),
('Aquaman_De_Barrio', 
 'license:3c4d5e6f7g8h9i0j1k2l3m4n5o6p7q8r', 'discord:9988776655443322', 'ip:10.0.0.55',
 'Rolear ser un pez fuera del agua en medio de la autopista durante 2 horas', 'Poseidon_Admin', 1798750000, 'active'),
('ManzanaKing', 
 'license:4d5e6f7g8h9i0j1k2l3m4n5o6p7q8r9s', 'discord:5544332211009988', 'ip:172.16.0.23',
 'Spawnear 50 Teslas en el hospital para "regalarlos" (Mass Spawn / Crash Server)', 'Admin_Ana', 0, 'active'),
('Diarrea-Liquida', 
 'license:5e6f7g8h9i0j1k2l3m4n5o6p7q8r9s0t', 'discord:6677889900112233', 'ip:192.168.100.12',
 'Poner "Despacito" versión saturada en zona segura con un altavoz invisible', 'Admin_Luis', 1789000000, 'active'),
('Marqilauro', 
 'license:6f7g8h9i0j1k2l3m4n5o6p7q8r9s0t1u', 'discord:1234123412341234', 'ip:80.50.20.10',
 'Esquivar balas de la policía haciendo el limbo (Godmode descarado)', 'DonMaderos', 0, 'active'),
('Senor_Patata', 
 'license:7g8h9i0j1k2l3m4n5o6p7q8r9s0t1u2v', 'discord:4321432143214321', 'ip:200.100.50.25',
 'Insultar a la administración usando código morse con el claxon', 'DonMaderos', 1893456000, 'active'),
('Invisibiliman', 
 'license:8h9i0j1k2l3m4n5o6p7q8r9s0t1u2v3w', 'discord:9876543210987654', 'ip:127.0.0.1',
 'Atropellar a toda la plaza siendo invisible y escribiendo "FANTASMA" en el chat', 'Hagrid_Staff', 0, 'active'),
('Dr_Strange_Bug', 
 'license:9i0j1k2l3m4n5o6p7q8r9s0t1u2v3w4x', 'discord:1111222233334444', 'ip:1.1.1.1',
 'Teletransportar patrullas de policía al Monte Chiliad sin motivo aparente', 'Hagrid_Staff', 0, 'active'),
('Naruto_Runner', 
 'license:0j1k2l3m4n5o6p7q8r9s0t1u2v3w4x5y', 'discord:5555666677778888', 'ip:8.8.4.4',
 'Hacer Powergaming corriendo hacia el Area 51 esquivando misiles con animaciones de anime', 'Hagrid_Staff', 1787000000, 'revoked'),
('Vaca_Burra', 
 'license:1k2l3m4n5o6p7q8r9s0t1u2v3w4x5y6z', 'discord:9999000011112222', 'ip:192.168.0.254',
 'Usar skin de animal para conducir camiones y atropellar EMS', 'Admin_Ana', 0, 'active'),
('Zombie_Vegano', 
 'license:2l3m4n5o6p7q8r9s0t1u2v3w4x5y6z7a', 'discord:3333444455556666', 'ip:10.10.10.10',
 'Morder a la gente roleando ser zombie pero robando solo sus plantas de marihuana (MetaGaming)', 'Admin_Luis', 1795000000, 'active'),
('GomaDePoion', 
 'license:3m4n5o6p7q8r9s0t1u2v3w4x5y6z7a8b', 'discord:7777888899990000', 'ip:172.20.10.5',
 'Usar speedhack para repartir pizzas en 2 segundos (literalmente)', 'AntiCheat_System', 0, 'active'),
('Admin_Impostor', 
 'license:4n5o6p7q8r9s0t1u2v3w4x5y6z7a8b9c', 'discord:1212121212121212', 'ip:90.80.70.60',
 'Hacerse pasar por dueño del servidor y intentar "banear" a un Admin real', 'Admin_Ana', 0, 'active'),
('Terminator_LowCost', 
 'license:5o6p7q8r9s0t1u2v3w4x5y6z7a8b9c0d', 'discord:2323232323232323', 'ip:192.168.8.1',
 'Entrar a comisaría desnudo diciendo "Necesito tu ropa, tus botas y tu motocicleta"', 'Admin_Luis', 1790000000, 'active'),
('Baneado_Por_Feo', 
 'license:6p7q8r9s0t1u2v3w4x5y6z7a8b9c0d1e', 'discord:3434343434343434', 'ip:203.0.113.1',
 'Baneo de prueba revocable (El usuario se quejó de que su PJ era demasiado guapo)', 'Admin_Luis', 0, 'active');

-- =======================================================
-- 3. TABLA DE CHAT DE ADMINISTRACIÓN
-- =======================================================

-- 1. CREAR TABLA 'dp_admin_chat'
DROP TABLE IF EXISTS `dp_admin_chat`;
CREATE TABLE `dp_admin_chat` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `sender_name` varchar(50) DEFAULT NULL,
  `license` varchar(255) DEFAULT NULL,
  `message` text DEFAULT NULL,
  `image_url` text DEFAULT NULL COMMENT 'JSON Array de imagenes',
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 2. DATOS DE EJEMPLO PARA CHAT DE ADMINISTRACIÓN
INSERT INTO `dp_admin_chat` (`sender_name`, `license`, `message`, `image_url`, `created_at`) VALUES
('Admin_Luis', 'license:2b3c4d5e6f7g8h9i0j1k2l3m4n5o6p7q', 'Don, tenemos un problema grave con el garaje de Sandy Shores. Los coches spawnean uno encima de otro y explotan.', NULL, '2025-10-05 16:30:00'),
('DonMaderos', 'license:1a2b3c4d5e6f7g8h9i0j1k2l3m4n5o6p', 'Voy. Seguramente sea el radio de spawn que se ha desconfigurado con el último reinicio. Dadme 5 minutos.', NULL, '2025-10-05 16:35:00'),
('Admin_Ana', 'license:3c4d5e6f7g8h9i0j1k2l3m4n5o6p7q8r', 'Mientras miras eso... el ID 494 está haciendo VDM masivo en la central con un camión de basura.', NULL, '2025-10-05 16:55:00'),
('Hagrid_Staff', 'license:4d5e6f7g8h9i0j1k2l3m4n5o6p7q8r9s', 'Lo estoy specteando yo. Confirmado. Se ha llevado a 3 EMS por delante. ¿Le meto perma directa o le aviso?', NULL, '2025-10-05 16:57:00'),
('DonMaderos', 'license:1a2b3c4d5e6f7g8h9i0j1k2l3m4n5o6p', 'Perma. No quiero gente así en el servidor. El garaje ya está parcheado, probad a sacar coches ahora.', NULL, '2025-10-05 17:05:00'),
('Admin_Luis', 'license:2b3c4d5e6f7g8h9i0j1k2l3m4n5o6p7q', 'Probado. Funciona fino. Gracias jefe.', NULL, '2025-10-05 17:07:00'),
('Poseidon_Admin', 'license:5e6f7g8h9i0j1k2l3m4n5o6p7q8r9s0t', 'Don, hemos estado hablando los del staff alto. La economía de la meta está muy rota. Los usuarios farmearon demasiado el fin de semana.', NULL, '2025-10-12 10:00:00'),
('DonMaderos', 'license:1a2b3c4d5e6f7g8h9i0j1k2l3m4n5o6p', 'Lo sé. Estoy reescribiendo el script de "qb-drugs" desde cero. Quiero meter un sistema de pureza, que si no lo cocinan bien, la droga valga menos.', NULL, '2025-10-12 10:05:00'),
('Poseidon_Admin', 'license:5e6f7g8h9i0j1k2l3m4n5o6p7q8r9s0t', 'Uff, eso suena increíble para el rol. ¿Cuándo crees que estará?', NULL, '2025-10-12 10:07:00'),
('DonMaderos', 'license:1a2b3c4d5e6f7g8h9i0j1k2l3m4n5o6p', 'Soy yo solo picando código y además tengo que arreglar el menú de admin viejo que crashea. Dadme una semana. Prioridad ahora mismo: optimización.', NULL, '2025-10-12 10:10:00'),
('Poseidon_Admin', 'license:5e6f7g8h9i0j1k2l3m4n5o6p7q8r9s0t', '¡Feliz Halloween equipo! El mapa del garaje central con las calabazas ha quedado brutal Don, dale las gracias de nuestra parte a Patri.', NULL, '2025-10-31 23:58:00'),
('DonMaderos', 'license:1a2b3c4d5e6f7g8h9i0j1k2l3m4n5o6p', 'Acabo de subir al repo el nuevo panel de administración. Necesito feedback urgente.', NULL, '2025-11-05 15:00:00'),
('Admin_Ana', 'license:3c4d5e6f7g8h9i0j1k2l3m4n5o6p7q8r', '¡Madre mía! El modo oscuro es precioso. Adiós a quedarme ciega por las noches.', NULL, '2025-11-05 15:02:00'),
('Hagrid_Staff', 'license:4d5e6f7g8h9i0j1k2l3m4n5o6p7q8r9s', 'Oye, el botón de "Noclip" va super fluido, mucho mejor que el txAdmin. Pero veo un fallo: en la lista de jugadores, si el nombre es muy largo, se sale del cuadro.', NULL, '2025-11-05 15:05:00'),
('DonMaderos', 'license:1a2b3c4d5e6f7g8h9i0j1k2l3m4n5o6p', 'Anotado. Le meteré un "text-overflow: ellipsis" al CSS ahora mismo. ¿Qué tal veis la pestaña de reportes?', NULL, '2025-11-05 15:08:00'),
('Admin_Luis', 'license:2b3c4d5e6f7g8h9i0j1k2l3m4n5o6p7q', 'Los reportes van bien, pero estaría bien poder asignárnoslos para que no vayamos dos admins al mismo aviso.', NULL, '2025-11-05 15:10:00'),
('DonMaderos', 'license:1a2b3c4d5e6f7g8h9i0j1k2l3m4n5o6p', 'Hecho. Mañana tendréis un botón de "ASIGNARME" que cambia el estado en la base de datos.', NULL, '2025-11-05 15:15:00'),
('Admin_Ana', 'license:3c4d5e6f7g8h9i0j1k2l3m4n5o6p7q8r', 'Genial. Así evitamos pisarnos el trabajo. Gracias Don.', NULL, '2025-11-05 15:17:00'),
('DonMaderos', 'license:1a2b3c4d5e6f7g8h9i0j1k2l3m4n5o6p', 'Chicos, necesito que me probéis otra cosa. El servidor está yendo muy lento últimamente y quiero ver si el nuevo script de optimización ayuda.', NULL, '2025-11-15 18:00:00'),
('Poseidon_Admin', 'license:5e6f7g8h9i0j1k2l3m4n5o6p7q8r9s0t', 'Chicos, el server va a pedales. Hay 120 personas conectadas y el resmon se ha disparado.', NULL, '2025-11-15 18:01:00'),
('DonMaderos', 'license:1a2b3c4d5e6f7g8h9i0j1k2l3m4n5o6p', 'Estoy mirando el profiler. Es el script de las matrículas personalizadas, está haciendo demasiadas consultas SQL por segundo. Voy a fixearlo ahora mismo, y a otimizarlo.', NULL, '2025-11-15 18:03:00'),
('Admin_Ana', 'license:3c4d5e6f7g8h9i0j1k2l3m4n5o6p7q8r', 'Mientras tanto, ojo con el ID 12. Me han llegado 4 reportes de que es inmortal. Le he vaciado un cargador y no baja la vida.', NULL, '2025-11-15 18:10:00'),
('DonMaderos', 'license:1a2b3c4d5e6f7g8h9i0j1k2l3m4n5o6p', 'Script de matrículas parcheado. El lag debería bajar ya. Ana, pásame la licencia del ID 12 por privado, voy a checkear si está inyectando algo o es lag.', NULL, '2025-11-15 18:15:00'),
('Admin_Ana', 'license:3c4d5e6f7g8h9i0j1k2l3m4n5o6p7q8r', 'Enviada. Dice por OOC que se le ha bugeado el chaleco, pero no me fío.', NULL, '2025-11-15 18:17:00'),
('DonMaderos', 'license:1a2b3c4d5e6f7g8h9i0j1k2l3m4n5o6p', 'Es mod menu. Los logs dicen que se ha curado 5000 de vida en 1 segundo. Ban más que merecido. Encargate tu Ana porfas...', NULL, '2025-11-15 18:25:00'),
('Hagrid_Staff', 'license:4d5e6f7g8h9i0j1k2l3m4n5o6p7q8r9s', 'Jefe, una pregunta tonta... ¿Podríamos tener emojis en este chat? A veces quiero mandar un "ok" rápido o una manita y me siento como en los años 90 escribiendo texto plano xD', NULL, '2025-12-01 09:00:00'),
('DonMaderos', 'license:1a2b3c4d5e6f7g8h9i0j1k2l3m4n5o6p', 'Jajaja, no es mala idea. Estaba pensando en mejorar el chat de admins. Estoy mirando librerías de JS para meter un picker de emojis integrado.', NULL, '2025-12-01 10:00:00'),
('Admin_Luis', 'license:2b3c4d5e6f7g8h9i0j1k2l3m4n5o6p7q', 'Y ya que estás... ¿sería posible mandar fotos? A veces para enseñarte un bug tengo que subirla a imgur y pasarte el link, es un rollo.', NULL, '2025-12-01 11:00:00'),
('DonMaderos', 'license:1a2b3c4d5e6f7g8h9i0j1k2l3m4n5o6p', 'Eso es más complejo por el tema de Base64 en la base de datos, peta si la cadena es muy larga. Pero puedo intentar hacer un puente con un Webhook de Discord. Lo investigo esta noche.', NULL, '2025-12-01 11:10:00'),
('Poseidon_Admin', 'license:5e6f7g8h9i0j1k2l3m4n5o6p7q8r9s0t', 'Buenos días equipo. ¿Cómo se presenta el viernes?', NULL, '2025-12-05 16:00:00'),
('DonMaderos', 'license:1a2b3c4d5e6f7g8h9i0j1k2l3m4n5o6p', 'Tranquilo. Estoy terminando el módulo de emojis y fotos en el chat. Luego me pondré con el resto de los apartados del script.', NULL, '2025-12-05 16:30:00'),
('Admin_Luis', 'license:2b3c4d5e6f7g8h9i0j1k2l3m4n5o6p7q', 'Perfecto Don. Avísanos cuando esté listo para probarlo.', NULL, '2025-12-05 16:45:00'),
('Hagrid_Staff', 'license:4d5e6f7g8h9i0j1k2l3m4n5o6p7q8r9s', '¡Gracias Don! Eres un crack.', NULL, '2025-12-05 17:00:00'),
('Poseidon_Admin', 'license:5e6f7g8h9i0j1k2l3m4n5o6p7q8r9s0t', '¿Alguna novedad con el chat Don?', NULL, '2025-12-08 11:00:00'),
('DonMaderos', 'license:1a2b3c4d5e6f7g8h9i0j1k2l3m4n5o6p', 'Sí, ya lo tengo casi listo. Esta tarde subo una preview para que lo probéis, haber que tal... como vas tu Ana con los pesados de los reportes y bugs?', NULL, '2025-12-08 11:15:00'),
('Admin_Ana', 'license:3c4d5e6f7g8h9i0j1k2l3m4n5o6p7q8r', 'Tranquila de momento. He atendido un par de dudas de whitelist y poco más.', NULL, '2025-12-08 12:00:00'),
('DonMaderos', 'license:1a2b3c4d5e6f7g8h9i0j1k2l3m4n5o6p', 'Chicos, acabo de subir la actualización del chat. Probad a darle al icono de la carita que sale abajo. ¡Ya tenemos emojis nativos!', NULL, '2025-12-08 14:00:00'),
('Hagrid_Staff', 'license:4d5e6f7g8h9i0j1k2l3m4n5o6p7q8r9s', '¡Funciona perfecto! Me acabo de tirar 10 minutos mirando los emojis de perros y gatos jajajaja.', NULL, '2025-12-08 14:15:00'),
('Admin_Luis', 'license:2b3c4d5e6f7g8h9i0j1k2l3m4n5o6p7q', 'P^robando su funcionamiento. Muy guay el set de emojis que has puesto. Gracias Don! 🥹😥🧙🏻‍♂️😙😘😚😏😮😝😯', NULL, '2025-12-08 14:30:00'),
('DonMaderos', 'license:1a2b3c4d5e6f7g8h9i0j1k2l3m4n5o6p', 'Genial. Ahora probad a mandar una imagen pegándola directamente (Ctrl+V) en el chat. Debería subirse sola a un canal de Discord y aparecer aquí.', NULL, '2025-12-10 18:00:00'),
('Hagrid_Staff', 'license:4d5e6f7g8h9i0j1k2l3m4n5o6p7q8r9s', '', '["https://i.ibb.co/bgh3PDbw/image.png"]', '2025-12-10 18:15:00'),
('Hagrid_Staff', 'license:4d5e6f7g8h9i0j1k2l3m4n5o6p7q8r9s', 'También probado. Acabo de mandar una captura de pantalla del resmon. Va de lujo.', NULL, '2025-12-10 18:30:00'),
('DonMaderos', 'license:1a2b3c4d5e6f7g8h9i0j1k2l3m4n5o6p', 'Perfecto. Me alegro que os guste el nuevo chat. Ahora me pondré con el resto de los apartados del script.', NULL, '2025-12-10 18:45:00'),
('Admin_Luis', 'license:2b3c4d5e6f7g8h9i0j1k2l3m4n5o6p7q', '🔥 Va finísimo Don! Se ve super profesional todo.', NULL, '2025-12-10 18:50:00'),
('Hagrid_Staff', 'license:4d5e6f7g8h9i0j1k2l3m4n5o6p7q8r9s', '😂😂😂 Me encanta. Eres un crack. Por cierto, ¿has mirado lo de las fotos?', NULL, '2025-12-12 21:00:00'),
('DonMaderos', 'license:1a2b3c4d5e6f7g8h9i0j1k2l3m4n5o6p', 'Sí, ya lo eh dicho, pero habian fallos... Ahora probad a pegar una imagen del portapapeles (Ctrl+V) de nuevo por favor. Debería ir mejor ahora con la funcion de que si le dais clic, se ve en pantalla completa...', NULL, '2025-12-12 21:15:00'),
('Admin_Ana', 'license:3c4d5e6f7g8h9i0j1k2l3m4n5o6p7q8r', 'A mi me deja ver la foto que subio Hagrid_Staff hace dos dias, y es la leche el que se haga grande con la X para cerrarlo. Genial Don, eres un puñetero crack ahhaha 🥰💞💘.', NULL, '2025-12-12 21:30:00'),
('Poseidon_Admin', 'license:5e6f7g8h9i0j1k2l3m4n5o6p7q8r9s0t', '', '["https://i.ibb.co/tPhxbBGf/image.png"]', '2025-12-12 21:40:00'),
('Poseidon_Admin', 'license:5e6f7g8h9i0j1k2l3m4n5o6p7q8r9s0t', 'Lol, funciona perfecto. Acabo de mandar una captura de un coche mal aparcado en comisaría. NO ME LO PUEDO CREEEEEEEER QUE WAPO TAH ETA MONDA!', NULL, '2025-12-12 21:45:00'),
('Poseidon_Admin', 'license:5e6f7g8h9i0j1k2l3m4n5o6p7q8r9s0t', 'Como mieldas a aparcado ese ahi de esa manera teniendo los pibotes esos?', NULL, '2025-12-12 21:47:00'),
('Hagrid_Staff', 'license:4d5e6f7g8h9i0j1k2l3m4n5o6p7q8r9s', 'Jajaja, me parto. Esto va a revolucionar la administración. Gracias Don!', NULL, '2025-12-12 21:50:00'),
('Admin_Luis', 'license:2b3c4d5e6f7g8h9i0j1k2l3m4n5o6p7q', '', '["https://i.ibb.co/zVtPbG64/image.png"]', '2025-12-28 12:00:00'),
('Admin_Luis', 'license:2b3c4d5e6f7g8h9i0j1k2l3m4n5o6p7q', 'Probado también lo de pegar imágenes. Te has superado esta vez. DEBO DE ADMITIRLO, cuando haces cosas que nadie tiene ni P**A idea de como hacerlo hahahahahahhaha. PD: me encanta el mapeado tanto de la comisaria como los 2 parques de delante, fomenta MUCHISIMO el rol por esta zona y me parece una GRAN LOCURA PAPITOOO!', NULL, '2025-12-28 12:20:00'),
('DonMaderos', 'license:1a2b3c4d5e6f7g8h9i0j1k2l3m4n5o6p', 'Genial. Pues ya estaría el módulo de chat terminado al 100%. Ahora me voy a poner con el resto del script, que me queda MUCHO en mi cabecita loca... que me está dando guerra la cámara acrobatica y resto de funciones que tengo pensadas me sobre cargan el resmon y me estoy tilteando que fipais...', NULL, '2025-12-28 12:30:00'),
('DonMaderos', 'license:1a2b3c4d5e6f7g8h9i0j1k2l3m4n5o6p', 'Os aviso cuando tenga algo más listo para testear. Admin_Luis esos mapeados son la putisima P***A son 3 mapeados separados que de por sí no eran compatibles y tube que modificarlos YO (que no tengo ni p***a idea de modelar mapeados ni modelar nada en general... Eh roto muchas colisiones, luces, el mapa dejaba de funciona sin tocar nada, el server se sobre cargaba) hasta que lo logré despues de 3/4 dias solo centrao en esos mapeados, solo por el capricho de que me encantaban los 3 y me negaba a que fueran incompatibles por que son en la misma zona...', NULL, '2025-12-28 12:32:00'),
('Hagrid_Staff', 'license:4d5e6f7g8h9i0j1k2l3m4n5o6p7q8r9s', 'Eres un crack Don. De verdad, gracias por todo el curro que te estás pegando.', NULL, '2025-12-28 12:34:00'),
('Admin_Luis', 'license:2b3c4d5e6f7g8h9i0j1k2l3m4n5o6p7q', 'Dale duro jefe. Nosotros nos encargamos de los tickets mientras programas. 💪', NULL, '2025-12-28 12:35:00'),
('Admin_Ana', 'license:3c4d5e6f7g8h9i0j1k2l3m4n5o6p7q8r', 'Gracias por el currazo Don. Este menú es una pasada, con lo "poco" que llevas. Si quierers mas ideas dinoslo que nosotros con tal de dar por culo y hacerte trabajar, lo que sea ahhahha 💘💞🥰 (ILUSM)', NULL, '2025-12-28 12:38:00'),
('DonMaderos', 'license:1a2b3c4d5e6f7g8h9i0j1k2l3m4n5o6p', 'Gracias por el apoyo moral pedazo de maricon@s. Sois los peores admins que he tenido nunca. SUS APRESIO ❤️ (ILUSMTOO)', NULL, '2025-12-28 12:40:00'),
('DonMaderos', 'license:1a2b3c4d5e6f7g8h9i0j1k2l3m4n5o6p', 'Buenas gente. Acabo de subir el Hotfix del chat 2.0. Ahora podéis mezclar texto con imágenes, subir hasta 5 de golpe y borrar la preview si os equivocáis.', NULL, '2026-01-05 18:00:57'),
('Poseidon_Admin', 'license:5e6f7g8h9i0j1k2l3m4n5o6p7q8r9s0t', '¡Por fin! El otro día intenté pasar 3 fotos de un reporte y tuve que spamear el chat linea a linea.', NULL, '2026-01-05 18:05:20'),
('Admin_Luis', 'license:2b3c4d5e6f7g8h9i0j1k2l3m4n5o6p7q', 'Yo estoy liado con un CK en la mafia, luego lo miro. Por cierto el ID 20 lleva 3 warnings por "funny driving", echadle un ojo.', NULL, '2026-01-05 18:10:45'),
('Hagrid_Staff', 'license:4d5e6f7g8h9i0j1k2l3m4n5o6p7q8r9s', 'Voy yo. Funny driving es mi especialidad xD. ¿El chat nuevo soporta gifs?', NULL, '2026-01-05 18:12:10'),
('DonMaderos', 'license:1a2b3c4d5e6f7g8h9i0j1k2l3m4n5o6p', 'Sí, soporta todo lo que soporte el webhook de Discord. Pero no abuséis de los gifs que os conozco...', NULL, '2026-01-05 18:15:30'),
('DonMaderos', 'license:1a2b3c4d5e6f7g8h9i0j1k2l3m4n5o6p', '¿Alguien ha probado el multi-upload ya? Necesito confirmar que no peta la DB si mandáis 5 fotos juntas.', NULL, '2026-01-06 10:00:00'),
('Admin_Ana', 'license:3c4d5e6f7g8h9i0j1k2l3m4n5o6p7q8r', 'Voy yo Don. Justo tengo un CALVO con un coche tuneado, perfecto para probarlo.', NULL, '2026-01-06 10:15:00'),
('Admin_Ana', 'license:3c4d5e6f7g8h9i0j1k2l3m4n5o6p7q8r', 'Mira esto Don, se sube al techo, luego sale corriendo por la carretera y luego atraviesa el edificio:', '["https://i.ibb.co/4ZSLfP7Z/image.png", "https://i.ibb.co/d0cMLWXB/image.png", "https://i.ibb.co/6k929Xn/image.png"]', '2026-01-06 10:20:00'),
('DonMaderos', 'license:1a2b3c4d5e6f7g8h9i0j1k2l3m4n5o6p', 'Perfecto Ana. Veo las 3 fotos y el texto arriba perfectamente alineado. ¿La preview te dejó borrarlas antes de enviar?', NULL, '2026-01-06 10:22:15'),
('Admin_Ana', 'license:3c4d5e6f7g8h9i0j1k2l3m4n5o6p7q8r', 'Sip, metí una cuarta sin querer que no era, le di a la X roja y se quitó suave. 10/10 el sistema.', NULL, '2026-01-06 10:23:40'),
('Poseidon_Admin', 'license:5e6f7g8h9i0j1k2l3m4n5o6p7q8r9s0t', 'Oye, habéis visto al EMS nuevo? Rolea genial, deberíamos darle puntos de rol.', NULL, '2026-01-06 10:25:00'),
('Admin_Luis', 'license:2b3c4d5e6f7g8h9i0j1k2l3m4n5o6p7q', 'Visto. Ayer me reanimó y me tiró 15 minutos de /me. Un crack.', NULL, '2026-01-07 09:00:00'),
('DonMaderos', 'license:1a2b3c4d5e6f7g8h9i0j1k2l3m4n5o6p', 'Anotado para la reunión semanal. Bueno, doy el módulo de chat por FINALIZADO. Me vuelvo a la cueva a programar el sistema de robos. No me etiquetéis a no ser que se queme el server.', NULL, '2026-01-07 09:10:00');

-- =======================================================
-- 4. TABLA DE LOGS DE ADMINISTRACIÓN
-- =======================================================

CREATE TABLE IF NOT EXISTS `dp_logs` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `admin_name` varchar(255) DEFAULT 'Sistema',
  `admin_identifier` varchar(50) DEFAULT NULL,
  `action` varchar(50) DEFAULT NULL COMMENT 'Ej: BAN, KICK, SPAWN_CAR',
  `details` text DEFAULT NULL COMMENT 'Descripción de lo que hizo',
  `date` timestamp NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- =======================================================
-- 5. TABLA DE ESTADÍSTICAS DE ADMINISTRACIÓN
-- =======================================================

CREATE TABLE IF NOT EXISTS `dp_stats` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `player_count` int(11) DEFAULT 0,
  `admin_count` int(11) DEFAULT 0,
  `report_count` int(11) DEFAULT 0,
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

INSERT INTO `dp_stats` (`player_count`, `admin_count`, `report_count`, `created_at`) VALUES 
(12, 1, 0, DATE_SUB(NOW(), INTERVAL 29 DAY)),
(25, 2, 1, DATE_SUB(NOW(), INTERVAL 25 DAY)),
(40, 4, 5, DATE_SUB(NOW(), INTERVAL 21 DAY)),
(18, 1, 0, DATE_SUB(NOW(), INTERVAL 18 DAY)),
(55, 5, 12, DATE_SUB(NOW(), INTERVAL 14 DAY)),
(30, 3, 2, DATE_SUB(NOW(), INTERVAL 7 DAY)),
(45, 4, 6, DATE_SUB(NOW(), INTERVAL 6 DAY)),
(62, 6, 15, DATE_SUB(NOW(), INTERVAL 4 DAY)),
(20, 2, 0, DATE_SUB(NOW(), INTERVAL 2 DAY));

-- =======================================================
-- 6. TABLA DE POSICIONAMIENTOS DEL MENÚ
-- =======================================================

CREATE TABLE IF NOT EXISTS `dp_preferences` (
  `citizenid` varchar(50) NOT NULL,
  `menu_top` varchar(20) DEFAULT '12.5%',
  `menu_left` varchar(20) DEFAULT '62.5%',
  PRIMARY KEY (`citizenid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

ALTER TABLE `dp_preferences` 
ADD COLUMN `menu_scale` INT DEFAULT 90 AFTER `menu_left`;
