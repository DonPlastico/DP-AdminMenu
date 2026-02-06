// ==========================================================================
// 1. CONFIGURACIÓN Y VARIABLES GLOBALES (ESTADO)
// ==========================================================================

// Debug y Logs
let isDebugActive = false;

// FUNCIÓN DE SEGURIDAD 
function escapeHtml(text) {
    if (!text) return "";
    return text
        .replace(/&/g, "&amp;")
        .replace(/</g, "&lt;")
        .replace(/>/g, "&gt;")
        .replace(/"/g, "&quot;")
        .replace(/'/g, "&#039;");
}

function log(msg) {
    if (isDebugActive) console.log(`^4[DP-ADMIN JAVASCRIPT]^7 ${msg}`);
}

// Estado Global de la Aplicación
let allPlayers = [];
let allBans = [];
let allChatMessages = [];
let minMessageId = 0;
let pendingAttachments = [];
const MAX_ATTACHMENTS = 5;
let chatIsLoading = false;
let extendBanId = null;
let extendOriginalExpire = 0;
let allJobs = [];
let allGangs = [];
let allVehicles = [];
let currentReportType = 'support';
let isDragging = false;
let dragOffsetX = 0;
let dragOffsetY = 0;
let isEditMode = false;

// Estados de Botones (Toggle) - AQUÍ GUARDAMOS SI LA HERRAMIENTA ESTÁ ACTIVA
const actionStates = {
    noclip: false,
    godmode: false,
    invisible: false,
    entity_info: false
};

// Configuración Externa
const discordWebhook = "https://discord.com/api/webhooks/1459417838530855074/LNstohvnbz6UpxPCvk8UMDCMKp7MUJAzDfRIBhgmbO7NTuewvaji2dOMSkfUt3yA8eLP";
// const discordWebhook = "Meter_Tu_Webhook_Aquí";

// Formateo de Fechas (Español)
const dateOptions = {
    day: '2-digit', month: '2-digit', year: 'numeric',
    hour: '2-digit', minute: '2-digit', second: '2-digit'
};

// Variables Temporales UI
let selectedWeather = 'EXTRASUNNY';
let announceTimeout = null;

// Variable para saber en qué estado estamos
let cursorModeActive = false;

// ==========================================================================
// 2. BASE DE DATOS ESTÁTICA (COLORES GTA V)
// ==========================================================================
const gtaPaintData = {
    // 1. CLÁSICOS
    classic: [
        { id: 0, name: "Negro" }, { id: 147, name: "Negro Carbón" }, { id: 1, name: "Grafito" }, { id: 11, name: "Negro Antracita" },
        { id: 2, name: "Acero Negro" }, { id: 3, name: "Plata Oscura" }, { id: 4, name: "Plata" }, { id: 5, name: "Azul Plata" },
        { id: 6, name: "Gris Acero" }, { id: 7, name: "Plata Sombra" }, { id: 8, name: "Plata Piedra" }, { id: 9, name: "Plata Medianoche" },
        { id: 10, name: "Gun Metal" }, { id: 111, name: "Blanco Hielo" }, { id: 112, name: "Blanco Nieve" }, { id: 121, name: "Blanco Hueso" },
        { id: 122, name: "Blanco Crema" }, { id: 131, name: "Blanco Algodón" }, { id: 132, name: "Blanco Alabastro" }, { id: 134, name: "Blanco Puro" },
        { id: 27, name: "Rojo" }, { id: 28, name: "Rojo Torino" }, { id: 29, name: "Rojo Fórmula" }, { id: 30, name: "Rojo Fuego" },
        { id: 31, name: "Rojo Elegante" }, { id: 32, name: "Rojo Granate" }, { id: 33, name: "Rojo Desierto" }, { id: 34, name: "Rojo Cabernet" },
        { id: 35, name: "Rojo Caramelo" }, { id: 43, name: "Rojo Brillante" }, { id: 44, name: "Rojo Brillante Fuerte" }, { id: 46, name: "Rojo Desgastado" },
        { id: 150, name: "Rojo Lava" }, { id: 135, name: "Rosa Fuerte" }, { id: 136, name: "Rosa Salmón" }, { id: 137, name: "Rosa Pfister" },
        { id: 142, name: "Violeta Oscuro" }, { id: 145, name: "Violeta" }, { id: 148, name: "Violeta Brillante" }, { id: 149, name: "Violeta Medianoche" },
        { id: 61, name: "Azul Galaxia" }, { id: 62, name: "Azul Oscuro" }, { id: 63, name: "Azul Sajonia" }, { id: 64, name: "Azul" },
        { id: 65, name: "Azul Marino" }, { id: 66, name: "Azul Puerto" }, { id: 67, name: "Azul Diamante" }, { id: 68, name: "Azul Surf" },
        { id: 69, name: "Azul Náutico" }, { id: 70, name: "Azul Brillante" }, { id: 73, name: "Azul Ultra" }, { id: 74, name: "Azul Fuerte" },
        { id: 87, name: "Azul Claro" }, { id: 49, name: "Verde Oscuro" }, { id: 50, name: "Verde Racing" }, { id: 51, name: "Verde Mar" },
        { id: 52, name: "Verde Oliva" }, { id: 53, name: "Verde Brillante" }, { id: 54, name: "Verde Gasolina" }, { id: 55, name: "Verde Lima" },
        { id: 92, name: "Lima" }, { id: 125, name: "Verde Securicar" }, { id: 128, name: "Verde" }, { id: 133, name: "Verde Ejército" },
        { id: 151, name: "Verde Bosque" }, { id: 152, name: "Verde Oliva Oscuro" }, { id: 155, name: "Verde Follaje" }, { id: 88, name: "Amarillo Taxi" },
        { id: 89, name: "Amarillo Carreras" }, { id: 91, name: "Amarillo Pájaro" }, { id: 126, name: "Amarillo Flojo" }, { id: 36, name: "Naranja Amanecer" },
        { id: 38, name: "Naranja" }, { id: 41, name: "Naranja Mate" }, { id: 130, name: "Naranja Brillante" }, { id: 138, name: "Naranja Fuerte" },
        { id: 90, name: "Bronce" }, { id: 94, name: "Marrón Metalizado" }, { id: 95, name: "Café Expresso" }, { id: 96, name: "Chocolate" },
        { id: 97, name: "Terracota" }, { id: 98, name: "Marrón Claro" }, { id: 99, name: "Beige Paja" }, { id: 100, name: "Marrón Musgo" },
        { id: 101, name: "Marrón Biston" }, { id: 102, name: "Madera Haya" }, { id: 103, name: "Madera Oscura" }, { id: 104, name: "Naranja Choco" },
        { id: 105, name: "Arena Playa" }, { id: 106, name: "Arena Blanca" }, { id: 107, name: "Crema" }, { id: 108, name: "Marrón" },
        { id: 109, name: "Marrón Medio" }, { id: 110, name: "Marrón Claro" }
    ],
    // 2. METALIZADOS
    metallic: [
        { id: 0, name: "Negro Metalizado" }, { id: 147, name: "Negro Carbón" }, { id: 1, name: "Grafito" }, { id: 11, name: "Negro Antracita" },
        { id: 2, name: "Acero Negro" }, { id: 3, name: "Plata Oscura" }, { id: 4, name: "Plata" }, { id: 5, name: "Azul Plata" },
        { id: 6, name: "Gris Acero" }, { id: 7, name: "Plata Sombra" }, { id: 8, name: "Plata Piedra" }, { id: 9, name: "Plata Medianoche" },
        { id: 10, name: "Gun Metal" }, { id: 111, name: "Blanco Hielo" }, { id: 112, name: "Blanco Nieve" }, { id: 131, name: "Blanco Algodón" },
        { id: 132, name: "Blanco Alabastro" }, { id: 27, name: "Rojo Fuego" }, { id: 28, name: "Rojo Torino" }, { id: 29, name: "Rojo Fórmula" },
        { id: 30, name: "Rojo Granate" }, { id: 31, name: "Rojo Elegante" }, { id: 32, name: "Rojo Vino" }, { id: 33, name: "Rojo Desierto" },
        { id: 34, name: "Rojo Cabernet" }, { id: 35, name: "Rojo Caramelo" }, { id: 43, name: "Rojo Sangre" }, { id: 44, name: "Rojo Brillante" },
        { id: 45, name: "Rojo Granate Oscuro" }, { id: 150, name: "Rojo Lava" }, { id: 135, name: "Rosa Fuerte" }, { id: 136, name: "Rosa Salmón" },
        { id: 137, name: "Rosa Pfister" }, { id: 71, name: "Púrpura Medianoche" }, { id: 142, name: "Violeta Oscuro" }, { id: 145, name: "Violeta" },
        { id: 146, name: "Azul Oscuro V." }, { id: 61, name: "Azul Galaxia" }, { id: 62, name: "Azul Oscuro" }, { id: 63, name: "Azul Sajonia" },
        { id: 64, name: "Azul" }, { id: 65, name: "Azul Marino" }, { id: 66, name: "Azul Puerto" }, { id: 67, name: "Azul Diamante" },
        { id: 68, name: "Azul Surf" }, { id: 69, name: "Azul Náutico" }, { id: 70, name: "Azul Brillante" }, { id: 72, name: "Azul Spinnaker" },
        { id: 73, name: "Azul Ultra" }, { id: 87, name: "Azul Claro" }, { id: 49, name: "Verde Oscuro" }, { id: 50, name: "Verde Racing" },
        { id: 51, name: "Verde Mar" }, { id: 52, name: "Verde Oliva" }, { id: 53, name: "Verde Brillante" }, { id: 54, name: "Verde Gasolina" },
        { id: 92, name: "Verde Lima" }, { id: 125, name: "Verde Securicar" }, { id: 151, name: "Verde Bosque" }, { id: 88, name: "Amarillo Taxi" },
        { id: 89, name: "Amarillo Carreras" }, { id: 91, name: "Amarillo Pájaro" }, { id: 126, name: "Amarillo Suave" }, { id: 36, name: "Naranja Amanecer" },
        { id: 38, name: "Naranja" }, { id: 130, name: "Naranja Brillante" }, { id: 138, name: "Naranja Fuerte" }, { id: 90, name: "Bronce" },
        { id: 94, name: "Marrón Metalizado" }, { id: 95, name: "Café Expresso" }, { id: 96, name: "Chocolate" }, { id: 97, name: "Terracota" },
        { id: 98, name: "Marrón Claro" }, { id: 99, name: "Beige Paja" }, { id: 100, name: "Marrón Musgo" }, { id: 101, name: "Marrón Biston" },
        { id: 102, name: "Madera Haya" }, { id: 103, name: "Madera Oscura" }, { id: 104, name: "Naranja Choco" }, { id: 105, name: "Arena Playa" },
        { id: 106, name: "Arena Blanca" }, { id: 107, name: "Crema" }
    ],
    // 3. MATE
    matte: [
        { id: 12, name: "Negro Mate" }, { id: 13, name: "Gris Mate" }, { id: 14, name: "Gris Claro Mate" },
        { id: 131, name: "Blanco Mate" }, { id: 134, name: "Blanco Puro Mate" },
        { id: 39, name: "Rojo Mate" }, { id: 40, name: "Rojo Oscuro Mate" },
        { id: 41, name: "Naranja Mate" }, { id: 42, name: "Amarillo Mate" },
        { id: 82, name: "Azul Oscuro Mate" }, { id: 83, name: "Azul Mate" }, { id: 84, name: "Azul Medianoche Mate" },
        { id: 92, name: "Verde Lima Mate" }, { id: 128, name: "Verde Mate" }, { id: 151, name: "Verde Bosque Mate" },
        { id: 152, name: "Verde Oliva Mate" }, { id: 155, name: "Verde Follaje Mate" },
        { id: 148, name: "Violeta Mate" }, { id: 149, name: "Violeta Oscuro Mate" },
        { id: 153, name: "Marrón Desierto" }, { id: 154, name: "Arena Desierto" }
    ],
    // 4. METALES
    metals: [
        { id: 120, name: "Cromo" }, { id: 117, name: "Acero Cepillado" },
        { id: 118, name: "Acero Negro Cepillado" }, { id: 119, name: "Aluminio Cepillado" },
        { id: 158, name: "Oro Puro" }, { id: 159, name: "Oro Cepillado" }, { id: 37, name: "Oro Clásico" },
        { id: 160, name: "Azul Epsilon" }
    ],
    // 5. CAMALEÓN
    chameleon: [
        { id: 161, name: "Anodizado Rojo" }, { id: 162, name: "Anodizado Vino" }, { id: 163, name: "Anodizado Morado" }, { id: 164, name: "Anodizado Azul" },
        { id: 165, name: "Anodizado Verde" }, { id: 166, name: "Anodizado Lima" }, { id: 167, name: "Anodizado Cobre" }, { id: 168, name: "Anodizado Bronce" },
        { id: 169, name: "Anodizado Champán" }, { id: 170, name: "Anodizado Oro" }, { id: 171, name: "Verde/Azul Flip" }, { id: 172, name: "Verde/Rojo Flip" },
        { id: 173, name: "Verde/Marrón Flip" }, { id: 174, name: "Verde/Turquesa Flip" }, { id: 175, name: "Verde/Morado Flip" }, { id: 176, name: "Teal/Morado Flip" },
        { id: 177, name: "Aberración Cromática" }, { id: 178, name: "Día y Noche" }, { id: 179, name: "Verde/Azul Cromo" }, { id: 180, name: "Verde/Amarillo Cromo" },
        { id: 181, name: "Naranja/Azul Cromo" }, { id: 182, name: "Naranja/Verde Cromo" }, { id: 183, name: "Morado/Amarillo Cromo" }, { id: 184, name: "Rojo/Amarillo Cromo" },
        { id: 185, name: "Arcoiris" }, { id: 186, name: "Arcoiris Pastel" }, { id: 187, name: "Siete prismas" }, { id: 188, name: "Kamen Rider" }, { id: 189, name: "Navidad" },
        { id: 190, name: "Místico" }, { id: 191, name: "Holográfico Blanco" }, { id: 192, name: "Holográfico Azul" }, { id: 193, name: "Holográfico Rosa" },
        { id: 194, name: "Holográfico Verde" }, { id: 195, name: "Holográfico Morado" }, { id: 196, name: "Prismático Oro" }, { id: 197, name: "Prismático Plata" },
        { id: 198, name: "Prismático Negro" }, { id: 199, name: "Prismático Rojo" }, { id: 200, name: "Prismático Azul" },
        { id: 201, name: "Aceite Derramado" }, { id: 202, name: "Plástico" }, { id: 203, name: "Temperatura" }, { id: 204, name: "Ciberpunk" }, { id: 205, name: "Synthwave" },
        { id: 206, name: "Cuatro Estaciones" }, { id: 207, name: "Matorral" }, { id: 208, name: "Verde Sprunk" }, { id: 209, name: "Rojo eCola" }, { id: 210, name: "Rosa Chicle" },
        { id: 211, name: "Atardecer Vice City" }, { id: 212, name: "Nebulosa" }, { id: 213, name: "Galaxia" }, { id: 214, name: "Espacio Profundo" }, { id: 215, name: "Ópalo" },
        { id: 216, name: "Tiza Blanca" }, { id: 217, name: "Tiza Gris" }, { id: 218, name: "Tiza Negra" }, { id: 219, name: "Tiza Roja" }, { id: 220, name: "Tiza Azul" },
        { id: 221, name: "Tiza Amarilla" }, { id: 222, name: "Tiza Verde" }
    ],
    // 6. DESGASTADO (WORN)
    worn: [
        { id: 21, name: "Negro Desgastado" }, { id: 22, name: "Grafito Desgastado" }, { id: 23, name: "Gris Plata Desgastado" },
        { id: 24, name: "Plata Desgastado" }, { id: 25, name: "Azul Plata Desgastado" }, { id: 26, name: "Sombra Plata Desgastado" },
        { id: 46, name: "Rojo Desgastado" }, { id: 47, name: "Rojo Dorado Desgastado" }, { id: 48, name: "Rojo Oscuro Desgastado" },
        { id: 56, name: "Verde Oscuro Desgastado" }, { id: 57, name: "Verde Desgastado" }, { id: 58, name: "Verde Mar Desgastado" },
        { id: 59, name: "Verde Militar Desgastado" }, { id: 75, name: "Azul Oscuro Desgastado" }, { id: 76, name: "Azul Desgastado" },
        { id: 77, name: "Azul Claro Desgastado" }, { id: 113, name: "Blanco Miel (Taxi)" }, { id: 114, name: "Marrón Desgastado" },
        { id: 123, name: "Naranja Desgastado" }, { id: 124, name: "Naranja Claro Desgastado" }, { id: 129, name: "Blanco Desgastado" }
    ],
    // 7. UTILIDAD
    util: [
        { id: 15, name: "Negro Utilidad" }, { id: 16, name: "Negro Poli Utilidad" }, { id: 17, name: "Plata Oscura Utilidad" },
        { id: 18, name: "Plata Utilidad" }, { id: 19, name: "Gun Metal Utilidad" }, { id: 20, name: "Sombra Utilidad" },
        { id: 43, name: "Rojo Utilidad" }, { id: 44, name: "Rojo Brillante Utilidad" }, { id: 45, name: "Rojo Granate Utilidad" },
        { id: 111, name: "Blanco Utilidad" }, { id: 112, name: "Blanco Hielo Utilidad" }
    ]
};

// ==========================================================================
// 2.1. COORDENADAS CON LOCALIZACIONES DE LOS MAPEADOS DE DP-SCRIPTS
// ==========================================================================
const gotoLocations = {
    "MAPEOS Y OTROS": [
        { name: "Ayuntamiento", coords: { x: -545.49, y: -206.71, z: 38.16 }, icon: "mdi:town-hall" },
        { name: "Plaza Legion", coords: { x: 202.75, y: -940.58, z: 29.79 }, icon: "mdi:fountain" },
        { name: "Gimnasio (Gym)", coords: { x: -1261.11, y: -348.45, z: 36.83 }, icon: "mdi:weight-lifter" },
        { name: "Hotel Wiwang", coords: { x: -827.64, y: -700.06, z: 28.06 }, icon: "mdi:office-building" },
        { name: "Mina", coords: { x: 2910.8, y: 2780.22, z: 40.49 }, icon: "mdi:pickaxe" },
        { name: "Iglesia Rockford", coords: { x: -766.33, y: -24.46, z: 41.08 }, icon: "mdi:church" },
        { name: "Casino MLO", coords: { x: 923.85, y: 47.14, z: 81.11 }, icon: "mdi:casino" },
        { name: "Tienda 24/7", coords: { x: 1965.54, y: 3739.63, z: 32.32 }, icon: "mdi:shop" },
        { name: "Tienda Ropa", coords: { x: 1685.81, y: 4820.45, z: 41.99 }, icon: "mdi:tshirt-crew" },
        { name: "Fleeca", coords: { x: -1213.19, y: -329.75, z: 37.78 }, icon: "mdi:bank-transfer" },
        { name: "Banco Paleto", coords: { x: -112.52, y: 6467.73, z: 31.63 }, icon: "mdi:bank-check" },
        { name: "Banco Central", coords: { x: 230.41, y: 214.39, z: 105.55 }, icon: "mdi:bank-check" },
        { name: "Monte Chiliad (Cima)", coords: { x: 481.53, y: 5531.77, z: 784.2 }, icon: "mdi:image-filter-hdr" },
        { name: "Observatorio", coords: { x: -431.15, y: 1122.95, z: 325.85 }, icon: "mdi:telescope" },
        { name: "Zancudo", coords: { x: -1600.301, y: 2806.731, z: 18.796 }, icon: "mdi:tank" },
        { name: "Cárcel (Bolingbroke)", coords: { x: 1846.54, y: 2585.83, z: 45.67 }, icon: "mdi:gavel" }
    ],
    "LOCALES Y OCIO": [
        { name: "Bolera", coords: { x: 759.1, y: -778.01, z: 26.45 }, icon: "mdi:bowling" },
        { name: "Cat Café", coords: { x: -581.0, y: -1071.81, z: 22.33 }, icon: "mdi:coffee" },
        { name: "Vanilla Unicorn", coords: { x: 127.34, y: -1308.18, z: 29.19 }, icon: "mdi:gender-female" },
        { name: "Hookies", coords: { x: -2193.55, y: 4290.18, z: 49.17 }, icon: "mdi:glass-mug-variant" },
        { name: "Caza (Hunt)", coords: { x: -680.14, y: 5833.56, z: 17.33 }, icon: "mdi:target" },
        { name: "DYNASTY 8 REAL ESTATES", coords: { x: -698.65, y: 271.07, z: 83.11 }, icon: "mdi:home-circle-outline" },
        { name: "Sandy Pawn", coords: { x: 911.13, y: 3644.32, z: 32.68 }, icon: "mdi:scale-balance" },
        { name: "Café Cute V2", coords: { x: -281.81, y: -64.12, z: 49.53 }, icon: "mdi:muffin" },
        { name: "Pet Shop", coords: { x: 230.69, y: -22.4, z: 74.99 }, icon: "mdi:dog" },
        { name: "Pacific Bluffs", coords: { x: -3020.92, y: 84.22, z: 11.68 }, icon: "mdi:pool" },
        { name: "Paleto 3 Shops", coords: { x: -20.51, y: 6490.53, z: 31.5 }, icon: "mdi:store" },
        { name: "Concesionario PDM", coords: { x: -1039.86, y: -1352.17, z: 5.55 }, icon: "mdi:car-estate" },
        { name: "Burger Shot", coords: { x: -1198.08, y: -883.68, z: 13.63 }, icon: "mdi:hamburger" },
        { name: "Pearls Resort", coords: { x: -1742.47, y: -1117.32, z: 13.03 }, icon: "mdi:island" },
        { name: "Arcade 1", coords: { x: 128.46, y: -207.21, z: 54.57 }, icon: "mdi:controller-classic" },
        { name: "Arcade 2", coords: { x: 618.39, y: 2746.11, z: 42.01 }, icon: "mdi:controller-classic" },
        { name: "Arcade 3", coords: { x: -3166.03, y: 1060.43, z: 20.85 }, icon: "mdi:controller-classic" },
        { name: "Arcade 4", coords: { x: -1204.69, y: -780.7, z: 17.33 }, icon: "mdi:controller-classic" },
        { name: "Arcadius Business Centre", coords: { x: -141.1987, y: -620.913, z: 168.8205 }, icon: "mdi:office-building" },
        { name: "Maze Bank Building", coords: { x: -75.8466, y: -826.9893, z: 243.3859 }, icon: "mdi:bank" },
        { name: "Lom Bank", coords: { x: -1579.756, y: -565.0661, z: 108.523 }, icon: "mdi:bank" },
        { name: "Maze Bank West", coords: { x: -1392.667, y: -480.4736, z: 72.04217 }, icon: "mdi:bank" },
        { name: "Nightclub", coords: { x: -1604.664, y: -3012.583, z: -78.0 }, icon: "mdi:music-box-outline" },
        { name: "OFICINA RICA 1", coords: { x: -1021.86, y: -427.74, z: 68.95 }, icon: "mdi:briefcase-check" },
        { name: "OFICINA RICA 2", coords: { x: 383.41, y: -59.87, z: 108.45 }, icon: "mdi:briefcase-check" },
        { name: "OFICINA RICA 3", coords: { x: -1004.23, y: -761.2, z: 66.99 }, icon: "mdi:briefcase-check" },
        { name: "OFICINA RICA 4", coords: { x: -587.87, y: -716.84, z: 118.1 }, icon: "mdi:briefcase-check" }
    ],
    "SERVICIOS (PD/EMS/MEC)": [
        { name: "Paleto PD", coords: { x: -427.23, y: 6023.62, z: 31.49 }, icon: "mdi:police-badge" },
        { name: "Pillbox Medical", coords: { x: 298.52, y: -584.33, z: 43.26 }, icon: "mdi:hospital-building" },
        { name: "BENNY'S ORIGINAL MOTORWORKS", coords: { x: -205.73, y: -1309.03, z: 31.29 }, icon: "mdi:wrench" },
        { name: "HAYES AUTOS (Gabz)", coords: { x: -1430.76, y: -442.14, z: 35.7 }, icon: "mdi:car-cog" },
        { name: "EAST CUSTOMS (Rfc)", coords: { x: 869.93, y: -2112.58, z: 30.51 }, icon: "mdi:car-wrench" },
        { name: "6 STR PERFORMANCE (Tuners)", coords: { x: 169.51, y: -3029.7, z: 6.0 }, icon: "mdi:wrench" },
        { name: "DASHOUND (Bus Station)", coords: { x: 425.1, y: -644.3, z: 28.5 }, icon: "mdi:bus" },
        { name: "SAN ANDREAS COURTS (Juez)", coords: { x: -545.49, y: -206.71, z: 38.16 }, icon: "mdi:gavel" },
        { name: "WEAZEL NEWS", coords: { x: -598.6, y: -929.9, z: 23.8 }, icon: "mdi:television-classic" },
        { name: "POST OP (Camioneros)", coords: { x: -413.5, y: -2795.3, z: 6.0 }, icon: "mdi:truck-delivery" },
        { name: "ATOMIC TOWING (Remolque)", coords: { x: 485.4, y: -1314.9, z: 29.2 }, icon: "mdi:truck-pickup" },
        { name: "LS SANITATION (Basureros)", coords: { x: -622.3, y: -1640.4, z: 25.9 }, icon: "mdi:trash-can" },
        { name: "MARLOWE VINEYARDS (Viñedo)", coords: { x: -1883.0, y: 2107.0, z: 140.0 }, icon: "mdi:fruit-grapes" },
        { name: "HORNY'S BURGERS (Hotdog)", coords: { x: 121.7, y: -1039.6, z: 29.2 }, icon: "mdi:food-hot-dog" },
        { name: "DOWNTOWN CAB CO. (Taxi)", coords: { x: 895.1, y: -179.2, z: 74.7 }, icon: "mdi:taxi" },
        { name: "PREMIUM DELUXE MOTORSPORT", coords: { x: -44.5, y: -1094.2, z: 26.4 }, icon: "mdi:car-multiple" },
        { name: "Oficina 1", coords: { x: -467.4, y: -68.3, z: 45.9 }, icon: "mdi:briefcase-account" }
    ],
    "ROBOS Y BANCOS": [
        { name: "Cerrajería", coords: { x: 170.14, y: -1799.38, z: 29.32 }, icon: "mdi:key-chain" },
        { name: "Pacific Bank", coords: { x: 230.41, y: 214.39, z: 105.55 }, icon: "mdi:bank" },
        { name: "The Vault", coords: { x: 231.52, y: -1095.24, z: 29.29 }, icon: "mdi:safe" },
        { name: "Farmacia 1", coords: { x: -509.3, y: 278.68, z: 83.32 }, icon: "mdi:pill" },
        { name: "Farmacia 2", coords: { x: 114.67, y: -5.19, z: 67.84 }, icon: "mdi:pill" },
        { name: "Tienda (Store)", coords: { x: -501.35, y: 277.88, z: 83.32 }, icon: "mdi:cart" }
    ],
    "BARRIOS E ILEGAL": [
        { name: "Ballas (Grove St.)", coords: { x: 107.19, y: -1942.33, z: 20.8 }, icon: "mdi:skull-outline" },
        { name: "THE FAMILIES (Forum Dr.)", coords: { x: -144.17, y: -1586.26, z: 31.78 }, icon: "mdi:account-group" },
        { name: "VAGOS (Rancho)", coords: { x: 347.41, y: -2011.6, z: 22.39 }, icon: "mdi:emoticon-angry" },
        { name: "MARABUNTA GRANDE (El Burro)", coords: { x: 1215.14, y: -1641.52, z: 48.64 }, icon: "mdi:knife-military" },
        { name: "AZTECAS (North Rancho)", coords: { x: 508.06, y: -1536.6, z: 29.27 }, icon: "mdi:knife" },
        { name: "CARTEL DE MADRAZO (La Fuente)", coords: { x: 1395.25, y: 1141.7, z: 114.33 }, icon: "mdi:fencing" },
        { name: "MERRYWEATHER (Elysian Is)", coords: { x: 488.39, y: -3326.69, z: 6.07 }, icon: "mdi:shield-airplane" },
        { name: "WEI CHENG TRIAD (Little Seoul)", coords: { x: -744.52, y: -908.43, z: 19.46 }, icon: "mdi:fire-circle" },
        { name: "O'NEIL BROTHERS (Farm)", coords: { x: 2434.93, y: 4964.84, z: 42.35 }, icon: "mdi:fire" },
        { name: "T.P. INDUSTRIES (Sandy)", coords: { x: 1982.72, y: 3816.03, z: 32.18 }, icon: "mdi:biohazard" },
        { name: "THE LOST MC (Casino HQ)", coords: { x: 978.88, y: -103.11, z: 74.85 }, icon: "mdi:motorbike" },
        { name: "ANGELS OF DEATH (Up-n-Atom)", coords: { x: -16.48, y: 6314.54, z: 31.33 }, icon: "mdi:vlc" },
        { name: "KKANGPAE (Korean Mob)", coords: { x: -589.65, y: -884.21, z: 25.56 }, icon: "mdi:skull-scan" },
        { name: "ARMENIAN POWER (La Puerta)", coords: { x: -446.7, y: -1684.34, z: 19.03 }, icon: "mdi:wallet-membership" },
        { name: "MIDNIGHT CLUB (Tunnels)", coords: { x: 928.98, y: -193.39, z: 73.01 }, icon: "mdi:engine-outline" },
        { name: "ALTRUISTAS (Montaña)", coords: { x: -1170.81, y: 4925.33, z: 224.28 }, icon: "mdi:eye-outline" },
        { name: "THE PROFESSIONALS", coords: { x: -841.9, y: -1367.6, z: 5.15 }, icon: "mdi:laptop" },
        { name: "CAMPAMENTO HIPPIE", coords: { x: 2471.9, y: 3772.64, z: 41.24 }, icon: "mdi:peace" },
        { name: "CALI ESTATE (Mafia)", coords: { x: 803.45, y: 1274.91, z: 360.32 }, icon: "mdi:account-tie-hat" },
        { name: "THE LOST MC (Russ 68 Cus)", coords: { x: 28.01, y: 2778.36, z: 58.19 }, icon: "mdi:motorbike" },
        { name: "Cocaine lockup", coords: { x: 1093.6, y: -3196.6, z: -38.99 }, icon: "mdi:pill" },
        { name: "Counterfeit cash factory", coords: { x: 1121.89, y: -3195.33, z: -40.4 }, icon: "mdi:cash-multiple" },
        { name: "Document forgery", coords: { x: 1165.0, y: -3196.6, z: -39.01 }, icon: "mdi:file-document-edit" },
        { name: "Meth lab 1", coords: { x: 1009.5, y: -3196.6, z: -38.99 }, icon: "mdi:flask-outline" },
        { name: "Meth lab 2", coords: { x: 981.99, y: -143.0, z: -50.0 }, icon: "mdi:flask-outline" },
        { name: "Meth Lab (Pequeño)", coords: { x: 483.42, y: -2625.07, z: -50.0 }, icon: "mdi:flask-outline" },
        { name: "Weed farm", coords: { x: 1051.49, y: -3196.53, z: -39.14 }, icon: "mdi:leaf" },
        { name: "BikerClubhouse1", coords: { x: 1107.04, y: -3157.39, z: -37.51 }, icon: "mdi:motorcycle" },
        { name: "PCPROS HACKERS", coords: { x: 570.97, y: -420.07, z: -70.0 }, icon: "mdi:laptop" },
        { name: "Tuner ilegal (Carreras)", coords: { x: 1077.27, y: -2274.87, z: -50.0 }, icon: "mdi:flag-checkered" },
    ],
    "MISIONES Y OTROS": [
        { name: "Bunker", coords: { x: 174.3, y: 1245.75, z: 223.3 }, icon: "mdi:shield-home" },
        { name: "Vangelico", coords: { x: -762.44, y: -601.51, z: 30.28 }, icon: "mdi:diamond-stone" },
        { name: "Hide Island", coords: { x: -3534.34, y: 6291.64, z: 37.96 }, icon: "mdi:palm-tree" },
        { name: "Cayo Perico", coords: { x: 7374.51, y: 7338.58, z: 42.29 }, icon: "mdi:island" },
        { name: "XLabs 1", coords: { x: 1086.89, y: -307.25, z: 64.29 }, icon: "mdi:flask" },
        { name: "XLabs 2", coords: { x: -505.22, y: -1438.36, z: 14.11 }, icon: "mdi:flask" },
        { name: "Document forgery 1", coords: { x: 1165.0, y: -3196.6, z: -39.01 }, icon: "mdi:file-certificate" },
        { name: "Document forgery 2", coords: { x: 565.88, y: -2688.76, z: -50.0 }, icon: "mdi:file-certificate" },
        { name: "Vehicle warehouse", coords: { x: 994.59, y: -3002.59, z: -39.64 }, icon: "mdi:warehouse" },
        { name: "Bunker 2", coords: { x: 892.63, y: -3245.86, z: -98.26 }, icon: "mdi:shield-alert" },
        { name: "Yacht 1", coords: { x: -1363.72, y: 6734.1, z: 2.44 }, icon: "mdi:sail-boat" },
        { name: "Yacht 2", coords: { x: -2041.54, y: -1032.34, z: 11.98 }, icon: "mdi:sail-boat" },
        { name: "Porta Aviones 1", coords: { x: 3089.28, y: -4727.51, z: 15.26 }, icon: "mdi:ferry" },
        { name: "Porta Aviones 2", coords: { x: -3208.03, y: 3954.54, z: 14.0 }, icon: "mdi:ferry" },
        { name: "Angar", coords: { x: -1256.76, y: -3003.44, z: -48.49 }, icon: "mdi:airplane-landing" },
        { name: "DiamondArcadeBasement", coords: { x: 2710.0, y: -360.78, z: -56.0 }, icon: "mdi:controller" },
        { name: "Submarine", coords: { x: 1560.0, y: 400.0, z: -50.0 }, icon: "mdi:waves" },
        { name: "Laboratorio", coords: { x: -1916.11, y: 3749.71, z: -100.0 }, icon: "mdi:flask-empty-plus-outline" },
        { name: "Cargero", coords: { x: -344.43, y: -4062.83, z: 17.0 }, icon: "mdi:ship-wheel" },
        { name: "AgentsFactory", coords: { x: 752.31, y: -997.24, z: -47.0 }, icon: "mdi:factory" },
        { name: "Mini Oficina 1", coords: { x: 2149.71, y: 4787.76, z: -47.0 }, icon: "mdi:desk" },
        { name: "Mini Oficina 2", coords: { x: -1160.49, y: -1538.93, z: -50.0 }, icon: "mdi:desk" },
        { name: "MoneyCarwash", coords: { x: 26.07, y: -1398.97, z: -75.0 }, icon: "mdi:car-wash" }
    ],
    "PROPIEDADES Y MANSIONES": [
        { name: "Diamond Penthouse", coords: { x: 976.63, y: 70.29, z: 115.16 }, icon: "mdi:star-face" },
        { name: "Tuner Garage", coords: { x: -1357.9, y: 168.52, z: -98.78 }, icon: "mdi:garage-variant" },
        { name: "Garaje Subterráneo", coords: { x: -1071.43, y: -77.03, z: -93.52 }, icon: "mdi:garage" },
        { name: "Estudio musical", coords: { x: -1000.72, y: -70.55, z: -98.1 }, icon: "mdi:microphone-variant" },
        { name: "Garaje/Angar", coords: { x: 800.13, y: -3001.42, z: -65.14 }, icon: "mdi:warehouse" },
        { name: "Criminal Enterprise Warehouse", coords: { x: 849.1, y: -3000.2, z: -45.97 }, icon: "mdi:domain" },
        { name: "Garaje Custom", coords: { x: 1220.13, y: -2277.84, z: -50.0 }, icon: "mdi:tools" },
        { name: "Garaje 2", coords: { x: 519.24, y: -2618.78, z: -50.0 }, icon: "mdi:garage-open" },
        { name: "Galería de fotos", coords: { x: 1202.4, y: -3251.25, z: -50.0 }, icon: "mdi:camera-outline" },
        { name: "MANSIÓN 1", coords: { x: 543.85, y: 712.75, z: 201.0 }, icon: "mdi:home-modern" },
        { name: "MANSIÓN 2", coords: { x: -1630.43, y: 470.85, z: 128.0 }, icon: "mdi:home-modern" },
        { name: "MANSIÓN 3", coords: { x: -2601.71, y: 1874.82, z: 166.0 }, icon: "mdi:home-modern" },
        { name: "Casa Michael", coords: { x: -802.31, y: 175.05, z: 72.84 }, icon: "mdi:home-account" },
        { name: "Casa Tía Franklin", coords: { x: -9.96, y: -1438.54, z: 31.1 }, icon: "mdi:home-heart" },
        { name: "Mansión Franklin", coords: { x: 13.99, y: 526.0, z: 174.63 }, icon: "mdi:home-modern" },
        { name: "Apartamento Floyd", coords: { x: -1150.7, y: -1520.71, z: 10.63 }, icon: "mdi:home-floor-1" },
        { name: "Remolque Trevor", coords: { x: 1985.48, y: 3828.76, z: 32.5 }, icon: "mdi:home-variant" }
    ]
};

// ==========================================================================
// 3. INICIALIZACIÓN DEL DOM (ARRANQUE)
// ==========================================================================

document.addEventListener('DOMContentLoaded', () => {
    log("DOM Listo. Arrancando interfaz DP-Admin...");

    // Cacheo de Elementos Globales
    const mainAdminPanel = document.getElementById('admin-menu');
    const tabs = document.querySelectorAll('.tab');
    const pages = document.querySelectorAll('.page');

    // Referencias específicas
    const chatListContainer = document.getElementById('chat-messages-list');
    const chatInput = document.getElementById('chat-input-text');

    const annModal = document.getElementById('announce-modal');
    const annValueInput = document.getElementById('announce-value');
    const annUnitInput = document.getElementById('announce-unit');
    const annUnitTrigger = document.getElementById('announce-unit-trigger');
    const annUnitWrapper = document.getElementById('announce-unit-wrapper');

    // ==========================================================================
    // 4. NUI MESSAGE HANDLER (COMUNICACIÓN LUA -> JS)
    // ==========================================================================

    window.addEventListener('message', (event) => {
        const data = event.data;

        // --- ABRIR MENÚ ---
        if (data.type === 'open') {
            mainAdminPanel.style.display = 'flex';

            if (data.menuPosition) {
                mainAdminPanel.style.top = data.menuPosition.top;
                mainAdminPanel.style.left = data.menuPosition.left;

                // FIX BUG 1: Aplicar la escala guardada inmediatamente al abrir
                currentScale = data.menuPosition.scale || 100;

                // Actualizamos los inputs del modal para que coincidan con la BD
                if (document.getElementById('scale-slider')) {
                    document.getElementById('scale-slider').value = currentScale;
                    document.getElementById('scale-number').value = currentScale;
                }

                mainAdminPanel.style.transformOrigin = 'top left'; // Importante mantener el origen
                mainAdminPanel.style.transform = `scale(${currentScale / 100})`;
                mainAdminPanel.style.margin = '0';
            }

            mainAdminPanel.style.opacity = '1.0';
            cursorModeActive = false;

            document.body.classList.add('menu-open');
            isDebugActive = data.debugMode;

            // 1. ACTUALIZAMOS LAS VARIABLES GLOBALES
            allPlayers = data.players || [];
            allBans = data.bans || [];
            allJobs = data.jobs || [];
            allGangs = data.gangs || [];

            // 2. RENDERIZAMOS USANDO ESAS VARIABLES O DATA DIRECTO
            renderPlayerList(allPlayers);
            renderReports(data.reports || []);
            renderBans(allBans);
            renderChat(data.chat || []);
            renderJobList(allJobs);
            renderGangList(allGangs);

            // Si la página activa es "status", recargamos los datos al abrir
            const activePage = document.querySelector('.page.active');
            if (activePage && activePage.id === 'status') {
                loadStatusPage();
            }

            if (data.weatherState) {
                const w = data.weatherState;
                const chkTime = document.getElementById('chk-freeze-time');
                const chkWeather = document.getElementById('chk-freeze-weather');
                const chkBlackout = document.getElementById('chk-blackout');
                const chkWind = document.getElementById('chk-wind');
                const chkWaves = document.getElementById('chk-waves');

                if (chkTime) chkTime.checked = w.freezeTime;
                if (chkWeather) chkWeather.checked = w.freezeWeather;
                if (chkBlackout) chkBlackout.checked = w.blackout;
                if (chkWind) chkWind.checked = w.wind;
                if (chkWaves) chkWaves.checked = w.waves;

                const slider = document.getElementById('weather-time-slider');
                const display = document.getElementById('weather-time-display');
                if (slider && display) {
                    slider.value = w.timeHour;
                    display.innerText = w.timeHour + ":00";
                }

                document.querySelectorAll('.weather-option').forEach(opt => {
                    opt.classList.remove('active');
                    if (opt.getAttribute('data-weather') === w.currentWeather) {
                        opt.classList.add('active');
                        selectedWeather = w.currentWeather;
                    }
                });
            }

            // --- CERRAR MENÚ ---
        } else if (data.type === 'close') {
            document.body.classList.remove('menu-open');
            mainAdminPanel.style.display = 'none';

            // Limpiezas existentes
            hideAllLicenses();
            closeWeatherModal();
            closeAnnounceModal();

            if (typeof closeJobManageModal === "function") closeJobManageModal();
            if (typeof closeJobRankModal === "function") closeJobRankModal();
            if (typeof closeGangManageModal === "function") closeGangManageModal();
            if (typeof closeGangRankModal === "function") closeGangRankModal();
            if (typeof closeGiveVehicleModal === "function") closeGiveVehicleModal();
            if (typeof closeGiveItemModal === "function") closeGiveItemModal();
        } else if (data.type === 'updateReports') {
            if (data.reports) renderReports(data.reports);

        } else if (data.type === 'openReportMenu') {
            // 1. Ocultar menú de admin si estaba abierto (por si acaso)
            mainAdminPanel.style.display = 'none';

            // 2. Mostrar menú de reportes
            const reportMenu = document.getElementById('report-menu');
            reportMenu.style.display = 'flex';

            // 3. Resetear campos
            document.getElementById('report-title').value = '';
            document.getElementById('report-desc').value = '';
            selectReportType('support'); // Resetear selección a soporte

        } else if (data.type === 'newChatMessage') {
            allChatMessages.push(data.message);
            renderChat([data.message], false);

        } else if (data.type === "toggleSpeedUI") {
            const speedDiv = document.getElementById('speed-ui');
            speedDiv.style.display = data.show ? "block" : "none";
            if (data.show) document.getElementById('speed-number').innerText = data.value.toFixed(2);

        } else if (data.type === "updateSpeed") {
            document.getElementById('speed-number').innerText = data.value.toFixed(2);

        } else if (data.type === "toggleJumpUI") {
            const jumpDiv = document.getElementById('jump-ui');
            jumpDiv.style.display = data.show ? "block" : "none";
            if (data.show) document.getElementById('jump-number').innerText = data.value.toFixed(1);

        } else if (data.type === "updateJump") {
            document.getElementById('jump-number').innerText = data.value.toFixed(1);

        } else if (data.type === "toggleTagsUI") {
            document.getElementById('tags-ui').style.display = data.show ? "block" : "none";

        } else if (data.type === "showAnnouncement") {
            const bar = document.getElementById('global-announce-bar');
            const marquee = document.getElementById('announce-marquee');
            const content = document.querySelector('.announce-content');

            // REFERENCIAS A LOS SONIDOS
            const soundIn = document.getElementById('audio-announce-in');
            const soundOut = document.getElementById('audio-announce-out');

            // AJUSTAR VOLUMEN (Opcional, 0.1 a 1.0)
            soundIn.volume = 0.4;
            soundOut.volume = 0.3;

            marquee.innerText = data.message;
            marquee.style.animation = 'none';
            bar.classList.remove('hide-announce');

            // --- SONIDO DE ENTRADA (ALERTA) ---
            soundIn.currentTime = 0; // Reinicia el audio por si sonó hace poco
            soundIn.play();

            // APLICAMOS CLASE DE ENTRADA
            bar.classList.add('show-announce');
            bar.style.display = 'flex';

            // Cálculos de tamaño (Igual que antes)
            const anchoBarra = content.offsetWidth;
            const anchoTexto = marquee.offsetWidth;
            const recorridoTotal = anchoBarra + anchoTexto;
            const pixelesPorSegundo = 200;
            const tiempoDeUnaVuelta = recorridoTotal / pixelesPorSegundo;

            marquee.style.setProperty('--distancia-recorrido', `-${recorridoTotal}px`);

            setTimeout(() => {
                marquee.style.animation = `marquee-scroll ${tiempoDeUnaVuelta}s linear infinite`;
            }, 10);

            if (announceTimeout) clearTimeout(announceTimeout);

            announceTimeout = setTimeout(() => {

                // --- SONIDO DE SALIDA (WHOOSH/VIENTO) ---
                soundOut.currentTime = 0;
                soundOut.play();

                // Animación de salida (Rebote hacia arriba)
                bar.classList.remove('show-announce');
                bar.classList.add('hide-announce');

                // Esperamos a que termine la animación visual (750ms)
                setTimeout(() => {
                    if (bar.classList.contains('hide-announce')) {
                        bar.style.display = 'none';
                        marquee.style.animation = 'none';
                        bar.classList.remove('hide-announce');
                    }
                }, 750);

            }, data.duration);

        } else if (data.type === "updateGameTime") {
            const h = data.hours.toString().padStart(2, '0');
            const m = data.minutes.toString().padStart(2, '0');
            const clockEl = document.getElementById('live-clock-text');
            if (clockEl) clockEl.innerText = `${h}:${m}`;

            const weatherEl = document.getElementById('live-weather-text');
            if (weatherEl && data.weather) {
                const weatherNames = {
                    'EXTRASUNNY': 'Extra Soleado', 'CLEAR': 'Despejado', 'NEUTRAL': 'Neutral',
                    'SMOG': 'Smog', 'FOGGY': 'Niebla', 'OVERCAST': 'Nublado', 'CLOUDS': 'Nubes',
                    'CLEARING': 'Aclarándose', 'RAIN': 'Lluvia', 'THUNDER': 'Tormenta',
                    'SNOW': 'Nieve', 'BLIZZARD': 'Ventisca', 'SNOWLIGHT': 'Nieve Ligera',
                    'XMAS': 'Navidad', 'HALLOWEEN': 'Halloween FX'
                };
                weatherEl.innerText = weatherNames[data.weather] || data.weather;
            }

            // --- HUD DE ENTIDADES (DEV TOOL) ---
        } else if (data.type === "toggleEntityUI") {
            const hud = document.getElementById('entity-info-hud');
            // Si data.show es true, mostramos block. Si no, none.
            hud.style.display = data.show ? "block" : "none";

            // Si activamos el HUD, cerramos el menú grande para que no estorbe
            if (data.show) {
                fetch(`https://${GetParentResourceName()}/closeMenu`, { method: 'POST', body: '{}' });
            }

        } else if (data.type === "updateEntityInfo") {
            const d = data.data;
            const setText = (id, val) => { const el = document.getElementById(id); if (el) el.textContent = val; };

            setText('ei-hash', d.hash);
            setText('ei-name', d.name);
            setText('ei-id', d.id);
            setText('ei-netid', d.netId);
            setText('ei-owner', d.owner);
            setText('ei-coords', d.coords);
            setText('ei-dist', d.distance + 'm');
            setText('ei-rot', d.heading);
            setText('ei-speed', d.speed + ' km/h');
            setText('ei-health', d.health);
            setText('ei-maxhealth', d.maxHealth);
            setText('ei-armour', d.armour);
            setText('ei-rel-hash', d.relGroup);

        } else if (data.type === 'updateAllLists') {
            allPlayers = data.players || [];
            allJobs = data.jobs || [];
            allGangs = data.gangs || [];

            renderPlayerList(allPlayers);
            renderJobList(allJobs, true);
            renderGangList(allGangs, true);

        } else if (data.type === 'updateVehicles') {
            allVehicles = data.vehicles || [];
            renderVehicleList(allVehicles);
            vehiclesLoaded = true;

        } else if (data.type === 'updateItems') {
            allItems = data.items || [];
            renderItemList(allItems);
            itemsDataLoaded = true;
        } else if (data.type === 'forceStatusRefresh') {
            // Esto recarga los datos si el servidor avisa de un cambio
            const activePage = document.querySelector('.page.active'); // O como detectes tu página activa
            // Si estamos viendo la página de status, recargamos
            if (activePage && activePage.id === 'status') {
                // NOTA: loadStatusPage volverá a poner el número real del servidor
                loadStatusPage();
            }
        } else if (data.type === "toggleNoClipUI") {
            // MOSTRAR / OCULTAR HUD DE NOCLIP
            const ui = document.getElementById('noclip-ui');
            if (ui) {
                ui.style.display = data.show ? "block" : "none";
                // Si lo activamos, ponemos la velocidad inicial
                if (data.show && data.value) {
                    document.getElementById('noclip-number').innerText = data.value.toFixed(1);
                }
            }

        } else if (data.type === "updateNoClipSpeed") {
            // ACTUALIZAR SOLO EL NÚMERO
            const num = document.getElementById('noclip-number');
            if (num) num.innerText = data.value.toFixed(1);
        }
    });

    // ==========================================================================
    // 5. NAVEGACIÓN Y TECLADO
    // ==========================================================================

    tabs.forEach(tab => {
        tab.addEventListener('click', () => {
            tabs.forEach(t => t.classList.remove('active'));
            pages.forEach(p => p.style.display = 'none'); // Oculta todas las páginas

            tab.classList.add('active');

            // Aquí obtenemos el ID de la página (ej: 'home', 'status', 'bans')
            const targetId = tab.getAttribute('data-tab');

            const pageEl = document.getElementById(targetId);
            if (pageEl) pageEl.style.display = 'block'; // Muestra la página

            // === LÓGICA ESPECÍFICA POR PÁGINA ===
            if (targetId === 'chat') scrollToBottomChat();

            // ---> AQUI AÑADIMOS LA MAGIA DEL STATUS <---
            if (targetId === 'status') loadStatusPage();
            // -------------------------------------------

            hideAllLicenses();
        });
    });

    if (document.querySelector('[data-tab="home"]')) document.querySelector('[data-tab="home"]').click();

    // 1. Bloquear Tab
    document.addEventListener('keydown', (e) => { if (e.key === 'Tab') e.preventDefault(); });

    // 2. Gestionar ESCAPE (Cierre de menús y herramientas)
    document.addEventListener('keyup', (e) => {
        if (e.key === 'Escape') {

            // PASO 1: Soltar cualquier Input (Buscador) que tenga el foco
            // Esto arregla el bug si estabas escribiendo
            if (document.activeElement && (document.activeElement.tagName === 'INPUT' || document.activeElement.tagName === 'TEXTAREA')) {
                document.activeElement.blur();
                return;
            }

            // PASO 2: Función auxiliar para comprobar visibilidad real de un modal
            const isVisible = (id) => {
                const el = document.getElementById(id);
                if (!el) return false;

                // Comprobamos el estilo inline
                if (el.style.display === 'none') return false;

                // Comprobamos el estilo real computado (CSS)
                // Esto detecta si está oculto por hoja de estilos aunque no tenga inline
                const style = window.getComputedStyle(el);
                if (style.display === 'none' || style.visibility === 'hidden' || style.opacity === '0') return false;

                return true;
            };

            // --- A. PRIORIDAD: CERRAR MODALES SECUNDARIOS ---
            // Si alguno de estos está abierto, lo cerramos y PARAMOS (return)

            if (isVisible('confirm-modal')) { closeConfirmation(); return; }
            if (isVisible('extend-modal')) { closeExtendModal(); return; }
            if (isVisible('image-modal')) { closeImageModal(); return; }
            if (isVisible('weather-modal')) { closeWeatherModal(); return; }
            if (isVisible('announce-modal')) { closeAnnounceModal(); return; }
            if (isVisible('refuel-modal')) { closeRefuelModal(); return; }
            if (isVisible('performance-modal')) { closePerformanceModal(); return; }
            if (isVisible('paint-modal')) { closePaintModal(); return; }
            if (isVisible('picker-modal')) { closeColorPickerModal(); return; }
            if (isVisible('livery-modal')) { closeLiveryModal(); return; }
            if (isVisible('report-menu')) { closeReportMenu(); return; }
            if (isVisible('job-rank-modal')) { closeJobRankModal(); return; }
            if (isVisible('job-manage-modal')) { closeJobManageModal(); return; }
            if (isVisible('gang-rank-modal')) { closeGangRankModal(); return; }
            if (isVisible('gang-manage-modal')) { closeGangManageModal(); return; }
            if (isVisible('give-vehicle-modal')) { closeGiveVehicleModal(); return; }
            if (isVisible('give-item-modal')) { closeGiveItemModal(); return; }
            if (isVisible('job-grades-modal')) { closeJobGradesModal(); return; }
            if (isVisible('gang-grades-modal')) { closeGangGradesModal(); return; }
            if (isVisible('goto-modal')) { closeGotoModal(); return; }

            // --- B. CERRAR HUD DE ENTIDADES (DEV TOOL) ---
            if (document.getElementById('entity-info-hud') && document.getElementById('entity-info-hud').style.display !== 'none') {
                toggleAction('entity_info');
                return;
            }

            // --- C. CERRAR MENÚ PRINCIPAL ---
            // Si llegamos aquí, es que no había nada secundario abierto. Cerramos el gordo.
            fetch(`https://${GetParentResourceName()}/closeMenu`, { method: 'POST', body: '{}' });
        }
    });

    function hideAllLicenses() {
        document.querySelectorAll('.blur-content.revealed').forEach(el => el.classList.remove('revealed'));
    }
    document.addEventListener('click', (e) => {
        if (e.target.classList.contains('blur-content')) e.target.classList.add('revealed');
        else hideAllLicenses();
    });

    // ==========================================================================
    // 6. MÓDULO: JUGADORES
    // ==========================================================================
    const playerListContainer = document.querySelector('#home .scroll-list');

    function renderPlayerList(list) {
        playerListContainer.innerHTML = '';
        if (!list || list.length === 0) {
            playerListContainer.innerHTML = '<div style="padding:15px; color:#888;">No hay nadie conectado :(</div>';
            return;
        }
        list.forEach(player => {
            const card = document.createElement('div');
            card.className = 'player-card';
            card.innerHTML = `<span class="id-badge">${player.id}</span> ${player.name}`;
            playerListContainer.appendChild(card);
        });
    }

    document.querySelector('#home .search-bar input').addEventListener('input', (e) => {
        const text = e.target.value.toLowerCase();
        const filtered = allPlayers.filter(p => p.name.toLowerCase().includes(text) || p.id.toString().includes(text));
        renderPlayerList(filtered);
    });

    document.querySelector('#home .clear-btn').addEventListener('click', () => {
        document.querySelector('#home .search-bar input').value = '';
        renderPlayerList(allPlayers);
    });

    // ==========================================================================
    // 7. MÓDULO: REPORTES
    // ==========================================================================
    window.selectReportType = (type) => {
        currentReportType = type;

        // Actualizar visualmente los botones
        document.querySelectorAll('.radio-btn').forEach(btn => btn.classList.remove('active'));
        const activeBtn = document.querySelector(`.radio-btn[data-type="${type}"]`);
        if (activeBtn) activeBtn.classList.add('active');
    };

    window.closeReportMenu = () => {
        // Ocultamos solo el div de reportes
        document.getElementById('report-menu').style.display = 'none';

        // NO TOCAMOS EL BODY NI EL ADMIN MENU
        // Así si abres luego el admin, todo funciona.

        fetch(`https://${GetParentResourceName()}/closeReport`, { method: 'POST', body: '{}' });
    };

    document.getElementById('btn-send-report').addEventListener('click', () => {
        const title = document.getElementById('report-title').value;
        const desc = document.getElementById('report-desc').value;
        if (!title || !desc) return;
        fetch(`https://${GetParentResourceName()}/submitReport`, {
            method: 'POST', headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ title: title, description: desc, type: currentReportType })
        });
        window.closeReportMenu();
    });

    // --- FUNCIÓN MEJORADA: Detecta imágenes y respeta formato ---
    function formatReportDescription(text) {
        if (!text) return "";

        // 1. PRIMERO: Limpiamos el texto de código malicioso.
        // Si alguien puso <button>, ahora será &lt;button&gt; (texto visible, no funcional)
        let safeText = escapeHtml(text);

        // 2. Regex para detectar URLs de imágenes
        // (Nota: detectará URLs incluso si tienen caracteres escapados como &amp;)
        const imageRegex = /(https?:\/\/\S+\.(?:png|jpg|jpeg|gif|webp)(\?\S*)?)/gi;

        // 3. Reemplazamos SOLO las URLs detectadas por nuestras imágenes
        return safeText.replace(imageRegex, function (url) {
            // IMPORTANTE: 'url' aquí ya es segura porque pasó por escapeHtml
            return `<img src="${url}" 
                     class="report-inline-img" 
                     onclick="openImageModal('${url}')" 
                     title="Click para ampliar">`;
        });
    }

    function renderReports(list) {
        const container = document.querySelector('.report-list');
        container.innerHTML = '';

        if (!list || list.length === 0) {
            container.innerHTML = '<div style="padding:20px; text-align:center; color:#666;">Relax, no hay reportes pendientes.</div>';
            return;
        }

        list.forEach(rep => {
            // SEGURIDAD: Limpiamos los nombres y títulos también
            const steamName = escapeHtml(rep.steam_name || "Anonimo");
            const charName = escapeHtml(rep.sender_name || "Anonimo");
            const titleSafe = escapeHtml(rep.title || "Sin Asunto");

            let statusBadge = rep.status === 'open'
                ? '<span class="badge unassigned">LIBRE</span>'
                : `<span class="badge assigned">LLEVA: ${escapeHtml(rep.assigned_to)}</span>`;

            let assignBtn = rep.status === 'open'
                ? `<button class="btn-assign" data-id="${rep.id}" data-player="${steamName}">ME LO QUEDO</button>`
                : `<button disabled style="opacity:0.5; cursor:not-allowed;">OCUPADO</button>`;

            const card = document.createElement('div');
            card.className = 'report-card';

            // Inyectamos los datos YA LIMPIOS
            card.innerHTML = `
            <div class="rc-header">
                <span class="rc-title">${steamName} (${charName})</span>
                <div class="rc-badges">${statusBadge}<span class="badge type">${rep.type}</span></div>
            </div>
            <div class="rc-body">
                <div class="rc-subject">${titleSafe}</div>
                
                <div class="rc-desc">${formatReportDescription(rep.description)}</div>
                
            </div>
            <div class="rc-footer">
                ${assignBtn}
                <button>INFORMACIÓN DEL JUGADOR</button>
                <button class="btn-danger btn-delete" data-id="${rep.id}">CERRAR/BORRAR</button>
            </div>
        `;
            container.appendChild(card);
        });

        addReportListeners();
    }

    function addReportListeners() {
        document.querySelectorAll('.btn-assign').forEach(btn => {
            btn.addEventListener('click', function () {
                const id = this.getAttribute('data-id');
                const name = this.getAttribute('data-player');
                showConfirmationModal(`¿Te encargas tú del reporte <b>#${id}</b> de ${name}?`, () => {
                    fetch(`https://${GetParentResourceName()}/assignReport`, { method: 'POST', body: JSON.stringify({ reportId: id }) });
                });
            });
        });
        document.querySelectorAll('.btn-delete').forEach(btn => {
            btn.addEventListener('click', function () {
                const id = this.getAttribute('data-id');
                showConfirmationModal(`¿Cerrar y borrar el reporte <b>#${id}</b>?`, () => {
                    fetch(`https://${GetParentResourceName()}/deleteReport`, { method: 'POST', body: JSON.stringify({ reportId: id }) });
                });
            });
        });
    }

    // ==========================================================================
    // 8. MÓDULO: BANEOS
    // ==========================================================================
    const banListBody = document.getElementById('ban-list-body');

    function renderBans(list) {
        if (!banListBody) return;
        banListBody.innerHTML = '';
        if (!list || list.length === 0) {
            banListBody.innerHTML = '<tr><td colspan="7" style="text-align:center; padding:20px;">Nadie baneado (de momento...)</td></tr>';
            return;
        }
        list.forEach(ban => {
            let expireText = (ban.expire === 0 || ban.expire === '0')
                ? '<span class="ban-perm">PERMANENTE</span>'
                : `<span class="ban-temp">${new Date(ban.expire * 1000).toLocaleString('es-ES', dateOptions)}</span>`;

            const tr = document.createElement('tr');
            tr.innerHTML = `
                <td class="ban-id">#${ban.id}</td>
                <td>${ban.name || '???'}</td>
                <td><span class="ban-license blur-content" title="Click para ver">${ban.license}</span></td>
                <td class="ban-reason">${ban.reason}</td>
                <td>${ban.banned_by}</td>
                <td>${expireText}</td>
                <td>
                    <div class="action-buttons">
                        <button class="btn-mini btn-revoke" onclick="revokeBan(${ban.id}, '${ban.name}')" title="Perdonar"><span class="iconify" data-icon="mdi:lock-open-check"></span></button>
                        <button class="btn-mini btn-extend" onclick="openExtendModal(${ban.id}, ${ban.expire})" title="Editar Tiempo"><span class="iconify" data-icon="mdi:clock-edit-outline"></span></button>
                    </div>
                </td>
            `;
            banListBody.appendChild(tr);
        });
    }

    document.getElementById('ban-search').addEventListener('input', (e) => {
        const text = e.target.value.toLowerCase();
        const filtered = allBans.filter(ban => {
            let dateStr = (ban.expire === 0 || ban.expire === '0') ? "permanente" : new Date(ban.expire * 1000).toLocaleString().toLowerCase();
            return (ban.name.toLowerCase().includes(text) || ban.reason.toLowerCase().includes(text) || ban.banned_by.toLowerCase().includes(text) || dateStr.includes(text));
        });
        renderBans(filtered);
    });

    document.getElementById('btn-clear-bans').addEventListener('click', () => {
        document.getElementById('ban-search').value = '';
        renderBans(allBans);
    });

    window.revokeBan = (id, name) => {
        showConfirmationModal(`¿Vas a desbanear a <b>${name}</b>?`, () => {
            fetch(`https://${GetParentResourceName()}/revokeBan`, { method: 'POST', body: JSON.stringify({ banId: id }) });
        });
    };

    // ==========================================================================
    // 9. MÓDULO: CHAT Y EMOJIS (ACTUALIZADO: MULTI-IMAGEN + PREVIEW)
    // ==========================================================================

    // RENDERIZADO DE MENSAJES (Ahora soporta Arrays de imágenes)
    function renderChat(list, prepend = false) {
        if (!list || list.length === 0) {
            if (!prepend && chatListContainer.innerHTML === '') chatListContainer.innerHTML = '<div style="text-align:center; padding:20px; opacity:0.5;">Silencio absoluto...</div>';
            return;
        }

        let shouldAutoScroll = false;
        if (!prepend) {
            if (list.length > 1) {
                shouldAutoScroll = true;
                chatListContainer.innerHTML = '';
                if (list[0].id) minMessageId = list[0].id;
            } else {
                shouldAutoScroll = isUserAtBottom();
            }
        } else {
            if (list[0].id < minMessageId) minMessageId = list[0].id;
        }

        let previousHeight = chatListContainer.scrollHeight;
        const fragment = document.createDocumentFragment();

        list.forEach(msg => {
            const row = document.createElement('div');
            row.className = 'chat-row';

            // Fecha (FORMATO COMPLETO: DD-MM-YYYY, HH:mm:ss)
            let dateText = "Ahora";
            if (msg.created_at) {
                let d = new Date(msg.created_at);
                // Compatibilidad con timestamp unix o string ISO
                if (isNaN(d.getTime())) d = new Date(parseInt(msg.created_at) * 1000);

                // Sacamos los datos y añadimos ceros (0) a la izquierda si hace falta
                const day = String(d.getDate()).padStart(2, '0');
                const month = String(d.getMonth() + 1).padStart(2, '0');
                const year = d.getFullYear();

                const hours = String(d.getHours()).padStart(2, '0');
                const minutes = String(d.getMinutes()).padStart(2, '0');
                const seconds = String(d.getSeconds()).padStart(2, '0');

                // Aquí montamos el string final
                dateText = `${day}-${month}-${year}, ${hours}:${minutes}:${seconds}`;
            }

            // CONTENIDO DEL MENSAJE (Soporta Texto y Array de Imágenes)
            let contentHtml = '';

            // 1. Texto normal
            if (msg.message && msg.message.trim() !== "") {
                contentHtml += `<div class="chat-text-content">${msg.message}</div>`;
            }

            // 2. Imágenes (Nueva lógica: Array en msg.images o JSON string)
            let images = [];

            // Intentar parsear si viene como string JSON desde la DB
            if (typeof msg.image_url === 'string' && (msg.image_url.startsWith('[') || msg.image_url.startsWith('{'))) {
                try { images = JSON.parse(msg.image_url); } catch (e) { }
            } else if (Array.isArray(msg.images)) {
                images = msg.images;
            } else if (msg.image_url) {
                // Compatibilidad antigua (una sola url string)
                images = [msg.image_url];
            }

            // Si hay imágenes, las pintamos en rejilla
            if (images && images.length > 0) {
                contentHtml += `<div class="chat-images-grid" style="display:flex; gap:5px; flex-wrap:wrap; margin-top:5px;">`;
                images.forEach(imgUrl => {
                    contentHtml += `<img src="${imgUrl}" class="chat-image" style="max-width:150px; border-radius:4px; cursor:pointer;" onclick="openImageModal('${imgUrl}')">`;
                });
                contentHtml += `</div>`;
            }

            // Si es sistema antiguo (detectar http en texto) - Fallback
            if (images.length === 0 && msg.message && msg.message.includes('http') && (msg.message.match(/\.(jpg|jpeg|png|gif)/))) {
                contentHtml = `<img src="${msg.message}" class="chat-image" style="max-width:200px;">`;
            }

            row.innerHTML = `
                <div class="chat-author-box">
                    <div class="chat-author">${msg.sender_name}</div>
                    <div class="chat-date">${dateText}</div>
                </div>
                <div class="chat-body">${contentHtml}</div>
            `;
            fragment.appendChild(row);
        });

        if (prepend) {
            chatListContainer.insertBefore(fragment, chatListContainer.firstChild);
            chatListContainer.scrollTop = chatListContainer.scrollHeight - previousHeight;
        } else {
            chatListContainer.appendChild(fragment);
            if (shouldAutoScroll) setTimeout(scrollToBottomChat, 50);
        }
    }

    // Funciones de Scroll
    function isUserAtBottom() {
        if (!chatListContainer) return false;
        return (chatListContainer.scrollHeight - chatListContainer.scrollTop - chatListContainer.clientHeight) < 100;
    }

    window.scrollToBottomChat = () => { if (chatListContainer) chatListContainer.scrollTop = chatListContainer.scrollHeight; };

    // Infinite Scroll
    chatListContainer.addEventListener('scroll', () => {
        if (chatListContainer.scrollTop === 0 && !chatIsLoading && minMessageId > 1) {
            chatIsLoading = true;
            fetch(`https://${GetParentResourceName()}/getMoreChatMessages`, {
                method: 'POST', headers: { 'Content-Type': 'application/json' }, body: JSON.stringify({ oldestId: minMessageId })
            }).then(r => r.json()).then(msgs => { if (msgs && msgs.length > 0) renderChat(msgs, true); chatIsLoading = false; });
        }
    });

    // 1. Detectar PEGADO (Paste) -> Muestra preview
    chatInput.addEventListener('paste', (e) => {
        const items = (e.clipboardData || e.originalEvent.clipboardData).items;
        let hasImage = false;
        for (let item of items) {
            if (item.type.indexOf('image') === 0) {
                e.preventDefault(); // IMPORTANTE: Evita pegar el binario
                const blob = item.getAsFile();
                addAttachment(blob); // Función global definida abajo
                hasImage = true;
            }
        }
    });

    // 2. Detectar ENTER -> Enviar
    chatInput.addEventListener('keydown', (e) => {
        if (e.key === 'Enter') {
            e.preventDefault(); // Evita salto de línea
            handleChatSend();   // Función global definida abajo
        }
    });

    // 3. Detectar CLICK -> Enviar
    const btnSend = document.getElementById('btn-chat-send');
    if (btnSend) {
        // Quitamos listeners viejos clonando el botón (truco rápido) o asumiendo que es carga nueva
        btnSend.onclick = handleChatSend;
    }

    // --- EMOJI PICKER ---
    const emojiData = [
        { id: "cat-recent", navIcon: "svg-spinners:clock", title: "Recientes", icons: ["😂", "😍", "😭", "👍", "🔥", "❤️", "🤣"] },
        { id: "cat-faces", navIcon: "line-md:emoji-smile", title: "Caras", icons: ["😀", "😁", "😂", "🤣", "😃", "😄", "😅", "😆", "😉", "😊", "😋", "😎", "😍", "😘", "🥰", "😗", "😙", "😚", "🙂", "🤗", "🤩", "🤔", "🤨", "😐", "😑", "😶", "🙄", "😏", "😣", "😥", "😮", "🤐", "😯", "😪", "😫", "😴", "😌", "😛", "😜", "😝", "🤤", "😒", "😓", "😔", "😕", "🙃", "🤑", "😲", "☹️", "🙁", "😖", "😞", "😟", "😤", "😢", "😭", "😦", "😧", "😨", "😩", "🤯", "😬", "😰", "😱", "🥵", "🥶", "😳", "🤪", "😵", "😡", "😠", "🤬", "😷", "🤒", "🤕", "🤢", "🤮", "🤧", "😇", "🥳", "🥺", "🤠", "🤡", "🤥", "🤫", "🤭", "🧐", "🤓", "😈", "👿", "👹", "👺", "💀", "👻", "👽", "🤖", "💩"] },
        { id: "cat-hands", navIcon: "f7:hand-raised-fill", title: "Manos", icons: ["👋", "🤚", "🖐", "✋", "🖖", "👌", "🤏", "✌️", "🤞", "🤟", "🤘", "🤙", "👈", "👉", "👆", "🖕", "👇", "☝️", "👍", "👎", "✊", "👊", "🤛", "🤜", "👏", "🙌", "👐", "🤲", "🤝", "🙏", "✍️", "💅", "🤳", "💪"] }
    ];

    function initEmojiPicker() {
        const list = document.getElementById('emoji-list');
        const nav = document.getElementById('emoji-nav');
        list.innerHTML = ''; nav.innerHTML = '';
        emojiData.forEach(cat => {
            const btn = document.createElement('div');
            btn.className = 'emoji-nav-item';
            btn.innerHTML = `<span class="iconify" data-icon="${cat.navIcon}"></span>`;
            btn.addEventListener('click', () => document.getElementById(cat.id).scrollIntoView({ behavior: 'smooth' }));
            nav.appendChild(btn);
            const sec = document.createElement('div');
            sec.id = cat.id;
            sec.innerHTML = `<div class="emoji-cat-title">${cat.title}</div><div class="emoji-cat-grid"></div>`;
            const grid = sec.querySelector('.emoji-cat-grid');
            cat.icons.forEach(icon => {
                const sp = document.createElement('span');
                sp.className = 'emoji-item';
                sp.textContent = icon;
                sp.addEventListener('click', () => { chatInput.value += icon; chatInput.focus(); });
                grid.appendChild(sp);
            });
            list.appendChild(sec);
        });
    }
    initEmojiPicker();

    document.getElementById('btn-emoji-toggle').addEventListener('click', (e) => { e.stopPropagation(); document.getElementById('emoji-picker-menu').classList.toggle('open'); });
    window.addEventListener('click', (e) => {
        const p = document.getElementById('emoji-picker-menu');
        const b = document.getElementById('btn-emoji-toggle');
        if (p.classList.contains('open') && !p.contains(e.target) && !b.contains(e.target)) p.classList.remove('open');
    });

    // ==========================================================================
    // 10. ACCIONES Y BOTONES (TRIGGERS / TOGGLES)
    // ==========================================================================

    window.triggerAction = (actionName) => {
        const confirmationActions = {
            'delete_all_veh': "⚠️ PELIGRO: Vas a borrar TODOS los vehículos del servidor. ¿Seguro?",
            'delete_all_peds': "⚠️ PELIGRO: Vas a borrar TODOS los NPCs del mapa. ¿Seguro?",
            'delete_all_objects': "⚠️ PELIGRO: Vas a borrar TODOS los objetos del mapa. ¿Seguro?"
        };

        if (confirmationActions[actionName]) {
            showConfirmationModal(confirmationActions[actionName], () => {
                fetch(`https://${GetParentResourceName()}/triggerAction`, {
                    method: 'POST', headers: { 'Content-Type': 'application/json' }, body: JSON.stringify({ action: actionName })
                });
            });
            return;
        }

        fetch(`https://${GetParentResourceName()}/triggerAction`, {
            method: 'POST', headers: { 'Content-Type': 'application/json' }, body: JSON.stringify({ action: actionName })
        });
    };

    window.toggleAction = (actionName) => {
        const btn = document.getElementById(`btn-${actionName}`);

        // Invertimos el estado guardado
        actionStates[actionName] = !actionStates[actionName];

        // Actualizamos visualmente el botón
        if (btn) btn.classList.toggle('btn-toggled', actionStates[actionName]);

        if (actionName === 'superspeed') isSpeedEnabled = actionStates[actionName];

        // Enviamos al Lua
        fetch(`https://${GetParentResourceName()}/toggleAction`, {
            method: 'POST', headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ action: actionName, state: actionStates[actionName] })
        });
    };

    // --- MÓDULO: HERRAMIENTAS DEV (COPIAR COORDENADAS Y ENTITY) ---
    window.copyCoords = (format) => {
        fetch(`https://${GetParentResourceName()}/getCoords`, { method: 'POST', headers: { 'Content-Type': 'application/json' }, body: JSON.stringify({ format: format }) })
            .then(resp => resp.json())
            .then(data => {
                if (data.coords) copyToClipboard(data.coords);
            });
    };

    window.copyEntityData = () => {
        const dataToCopy = {
            Model: document.getElementById('ei-hash').textContent,
            Name: document.getElementById('ei-name').textContent,
            ID: document.getElementById('ei-id').textContent,
            NetID: document.getElementById('ei-netid').textContent,
            Owner: document.getElementById('ei-owner').textContent,
            Coords: document.getElementById('ei-coords').textContent,
            Heading: document.getElementById('ei-rot').textContent
        };
        copyToClipboard(JSON.stringify(dataToCopy, null, 2));
    };

    function copyToClipboard(text) {
        const el = document.createElement('textarea'); el.value = text; document.body.appendChild(el); el.select(); document.execCommand('copy'); document.body.removeChild(el);
    }

    // ==========================================================================
    // 11. MODALES: UTILIDADES (IMAGEN, CONFIRM, BAN, ANUNCIO)
    // ==========================================================================

    // Imagen Modal
    const imageModal = document.getElementById('image-modal');
    const fullImage = document.getElementById('full-image');
    window.openImageModal = (src) => { imageModal.style.display = "flex"; fullImage.src = src; };
    window.closeImageModal = () => {
        if (!imageModal || imageModal.style.display === "none") return;
        imageModal.classList.add('closing'); fullImage.classList.add('closing');
        setTimeout(() => { imageModal.style.display = "none"; fullImage.src = ""; imageModal.classList.remove('closing'); fullImage.classList.remove('closing'); }, 450);
    };
    document.querySelector('.close-modal-btn').addEventListener('click', closeImageModal);
    imageModal.addEventListener('click', (e) => { if (e.target === imageModal) closeImageModal(); });

    // Confirmación Modal
    let onConfirm = null;
    window.showConfirmationModal = (msg, callback) => {
        document.getElementById('modal-message').innerHTML = msg; onConfirm = callback;
        document.getElementById('confirm-modal').style.display = 'flex';
    };
    window.closeConfirmation = () => { document.getElementById('confirm-modal').style.display = 'none'; onConfirm = null; };
    document.getElementById('btn-confirm-action').addEventListener('click', () => { if (onConfirm) onConfirm(); closeConfirmation(); });

    // Extender Ban Modal
    const extModal = document.getElementById('extend-modal');
    const extPerm = document.getElementById('ext-perm-check');
    const extVal = document.getElementById('ext-add-value');
    const extUnit = document.getElementById('ext-add-unit');
    const extDateDisp = document.getElementById('ext-new-date');

    window.openExtendModal = (id, expire) => {
        extendBanId = id; extendOriginalExpire = parseInt(expire);
        if (extendOriginalExpire === 0) { document.getElementById('ext-current-date').innerHTML = '<span style="color:#ff4444">PERMANENTE</span>'; extPerm.checked = true; }
        else { document.getElementById('ext-current-date').textContent = new Date(extendOriginalExpire * 1000).toLocaleString('es-ES', dateOptions); extPerm.checked = false; }
        extVal.value = ''; recalcNewDate(); extModal.style.display = 'flex';
    };
    window.closeExtendModal = () => { extModal.style.display = 'none'; extendBanId = null; };

    function recalcNewDate() {
        if (extPerm.checked) { extDateDisp.innerHTML = '<span style="color:#ff4444; font-weight:bold;">PERMANENTE</span>'; extVal.disabled = true; extUnit.disabled = true; return; }
        extVal.disabled = false; extUnit.disabled = false;
        let base = (extendOriginalExpire === 0 || extendOriginalExpire < Date.now() / 1000) ? Math.floor(Date.now() / 1000) : extendOriginalExpire;
        const add = (parseInt(extVal.value) || 0) * parseInt(extUnit.value);
        extDateDisp.textContent = new Date((base + add) * 1000).toLocaleString('es-ES', dateOptions);
    }
    extVal.addEventListener('input', recalcNewDate); extUnit.addEventListener('change', recalcNewDate); extPerm.addEventListener('change', recalcNewDate);

    document.getElementById('btn-save-extend').addEventListener('click', () => {
        if (!extendBanId) return;
        let finalExpire = 0;
        if (!extPerm.checked) {
            let base = (extendOriginalExpire === 0 || extendOriginalExpire < Date.now() / 1000) ? Math.floor(Date.now() / 1000) : extendOriginalExpire;
            finalExpire = base + ((parseInt(extVal.value) || 0) * parseInt(extUnit.value));
        }
        fetch(`https://${GetParentResourceName()}/extendBan`, { method: 'POST', headers: { 'Content-Type': 'application/json' }, body: JSON.stringify({ banId: extendBanId, newExpire: finalExpire }) });
        closeExtendModal();
    });

    // Custom Select Logic (Generic)
    const customWrap = document.querySelector('.custom-select-wrapper');
    const customTrig = document.getElementById('custom-trigger');
    if (customTrig) {
        customTrig.addEventListener('click', () => { if (!extPerm.checked) customWrap.classList.toggle('open'); });
        document.querySelectorAll('.custom-option').forEach(opt => {
            opt.addEventListener('click', function () {
                document.querySelectorAll('.custom-option').forEach(o => o.classList.remove('selected'));
                this.classList.add('selected');
                customTrig.querySelector('span').textContent = this.textContent;
                extUnit.value = this.getAttribute('data-value');
                customWrap.classList.remove('open');
                recalcNewDate();
            });
        });
        window.addEventListener('click', (e) => { if (!customWrap.contains(e.target)) customWrap.classList.remove('open'); });
    }

    // Anuncio Global Modal
    window.openAnnounceModal = () => {
        document.getElementById('announce-text').value = ""; annValueInput.value = "10";
        annUnitInput.value = "1000"; annUnitTrigger.querySelector('span').textContent = "Segundos";
        annModal.style.display = 'flex';
    };

    window.closeAnnounceModal = () => { annModal.style.display = 'none'; };

    if (annUnitTrigger) {
        annUnitTrigger.addEventListener('click', (e) => { e.stopPropagation(); annUnitWrapper.classList.toggle('open'); });
        annUnitWrapper.querySelectorAll('.custom-option').forEach(opt => {
            opt.addEventListener('click', function () {
                annUnitWrapper.querySelector('.selected')?.classList.remove('selected'); this.classList.add('selected');
                annUnitTrigger.querySelector('span').textContent = this.textContent;
                annUnitInput.value = this.getAttribute('data-value'); annUnitWrapper.classList.remove('open');
            });
        });
        window.addEventListener('click', (e) => { if (!annUnitWrapper.contains(e.target)) annUnitWrapper.classList.remove('open'); });
    }

    document.getElementById('btn-send-announce').addEventListener('click', () => {
        let text = document.getElementById('announce-text').value;
        let val = parseInt(annValueInput.value); let multiplier = parseInt(annUnitInput.value);
        if (!text) return;
        text = text.replace(/(\r\n|\n|\r)/gm, "    🛑    ");
        if (isNaN(val) || val < 1) val = 1;
        let totalDuration = val * multiplier;
        if (totalDuration > 300000) totalDuration = 300000; else if (totalDuration < 1000) totalDuration = 1000;
        fetch(`https://${GetParentResourceName()}/sendAnnouncement`, { method: 'POST', headers: { 'Content-Type': 'application/json' }, body: JSON.stringify({ message: text, duration: totalDuration }) });
        closeAnnounceModal();
    });

    // ==========================================================================
    // 12. MODAL: CLIMA Y TIEMPO (CORREGIDO)
    // ==========================================================================
    const weatherModal = document.getElementById('weather-modal');
    const weatherTimeSlider = document.getElementById('weather-time-slider');
    const weatherTimeDisplay = document.getElementById('weather-time-display');

    window.openWeatherModal = () => { if (weatherModal) weatherModal.style.display = 'flex'; };
    window.closeWeatherModal = () => { if (weatherModal) weatherModal.style.display = 'none'; };

    if (weatherTimeSlider && weatherTimeDisplay) {
        weatherTimeSlider.addEventListener('input', (e) => {
            const val = e.target.value.padStart(2, '0');
            weatherTimeDisplay.innerText = `${val}:00`;
        });
    }

    const weatherOpts = document.querySelectorAll('.weather-option');
    weatherOpts.forEach(opt => {
        opt.addEventListener('click', () => {
            weatherOpts.forEach(o => o.classList.remove('active'));
            opt.classList.add('active');
            selectedWeather = opt.getAttribute('data-weather');
        });
    });

    const btnApplyWeather = document.getElementById('btn-apply-weather');
    if (btnApplyWeather) {
        btnApplyWeather.addEventListener('click', () => {
            const extras = {
                freezeTime: document.getElementById('chk-freeze-time').checked,
                freezeWeather: document.getElementById('chk-freeze-weather').checked,
                blackout: document.getElementById('chk-blackout').checked,
                wind: document.getElementById('chk-wind').checked,
                waves: document.getElementById('chk-waves').checked
            };
            fetch(`https://${GetParentResourceName()}/updateWeather`, {
                method: 'POST', headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ weather: selectedWeather, hour: parseInt(weatherTimeSlider.value), extras: extras })
            });
            closeWeatherModal();
        });
    }

    // ==========================================================================
    // 13. MODALES: VEHÍCULOS (REFUEL, TUNING, LIVERY)
    // ==========================================================================

    // Refuel
    const refuelModal = document.getElementById('refuel-modal');
    const refuelInput = document.getElementById('refuel-amount');
    window.openRefuelModal = () => { refuelInput.value = ""; refuelModal.style.display = 'flex'; setTimeout(() => refuelInput.focus(), 100); };
    window.closeRefuelModal = () => { refuelModal.style.display = 'none'; };
    function doRefuel() {
        let amount = parseInt(refuelInput.value);
        if (isNaN(amount) || amount < 0) amount = 0; if (amount > 100) amount = 100;
        fetch(`https://${GetParentResourceName()}/triggerAction`, { method: 'POST', headers: { 'Content-Type': 'application/json' }, body: JSON.stringify({ action: 'refuel_vehicle', value: amount }) });
        closeRefuelModal();
    }
    document.getElementById('btn-confirm-refuel').addEventListener('click', doRefuel);
    refuelInput.addEventListener('keyup', (e) => { if (e.key === 'Enter') doRefuel(); });

    // Tuning (Performance)
    const perfModal = document.getElementById('performance-modal');
    function setupTuningSelect(wrapperId, triggerId, inputId, onChangeCallback) {
        const wrapper = document.getElementById(wrapperId); const trigger = document.getElementById(triggerId); const input = document.getElementById(inputId);
        if (!trigger || !wrapper) return;
        trigger.addEventListener('click', (e) => {
            e.stopPropagation(); document.querySelectorAll('.custom-select-wrapper.open').forEach(w => { if (w !== wrapper) w.classList.remove('open'); });
            wrapper.classList.toggle('open');
        });
        wrapper.querySelectorAll('.custom-option').forEach(opt => {
            opt.addEventListener('click', function (e) {
                e.stopPropagation(); wrapper.querySelectorAll('.custom-option').forEach(o => o.classList.remove('selected'));
                this.classList.add('selected'); trigger.querySelector('span').textContent = this.textContent;
                const newVal = this.getAttribute('data-value'); input.value = newVal; wrapper.classList.remove('open');
                if (typeof onChangeCallback === 'function') onChangeCallback(newVal);
            });
        });
    }

    setupTuningSelect('wrap-engine', 'trig-engine', 'val-engine');
    setupTuningSelect('wrap-brakes', 'trig-brakes', 'val-brakes');
    setupTuningSelect('wrap-transmission', 'trig-transmission', 'val-transmission');
    setupTuningSelect('wrap-suspension', 'trig-suspension', 'val-suspension');
    setupTuningSelect('wrap-armor', 'trig-armor', 'val-armor');
    setupTuningSelect('wrap-turbo', 'trig-turbo', 'val-turbo');

    window.addEventListener('click', (e) => { document.querySelectorAll('#performance-modal .custom-select-wrapper.open').forEach(w => { if (!w.contains(e.target)) w.classList.remove('open'); }); });

    function resetTuningToDefault(wrapperId, triggerId, inputId) {
        const wrapper = document.getElementById(wrapperId); const trigger = document.getElementById(triggerId); const input = document.getElementById(inputId);
        if (!wrapper) return;
        wrapper.querySelectorAll('.custom-option').forEach(o => o.classList.remove('selected'));
        const defaultOpt = wrapper.querySelector('[data-value="-1"]'); if (defaultOpt) defaultOpt.classList.add('selected');
        trigger.querySelector('span').textContent = "-- NO TOCAR --"; input.value = "-1";
    }

    window.openPerformanceModal = () => {
        resetTuningToDefault('wrap-engine', 'trig-engine', 'val-engine'); resetTuningToDefault('wrap-brakes', 'trig-brakes', 'val-brakes');
        resetTuningToDefault('wrap-transmission', 'trig-transmission', 'val-transmission'); resetTuningToDefault('wrap-suspension', 'trig-suspension', 'val-suspension');
        resetTuningToDefault('wrap-armor', 'trig-armor', 'val-armor'); resetTuningToDefault('wrap-turbo', 'trig-turbo', 'val-turbo');
        perfModal.style.display = 'flex';
    };
    window.closePerformanceModal = () => { perfModal.style.display = 'none'; };

    const btnPerf = document.getElementById('btn-confirm-performance');
    if (btnPerf) {
        btnPerf.addEventListener('click', () => {
            const mods = {
                engine: document.getElementById('val-engine').value, brakes: document.getElementById('val-brakes').value,
                transmission: document.getElementById('val-transmission').value, suspension: document.getElementById('val-suspension').value,
                armor: document.getElementById('val-armor').value, turbo: document.getElementById('val-turbo').value
            };
            fetch(`https://${GetParentResourceName()}/applyPerformance`, { method: 'POST', headers: { 'Content-Type': 'application/json' }, body: JSON.stringify({ mods: mods }) });
            closePerformanceModal();
        });
    }

    const btnMaxPreset = document.getElementById('btn-max-preset');
    if (btnMaxPreset) {
        btnMaxPreset.addEventListener('click', () => {
            const setMaxValue = (wrapperId, targetValue) => {
                const wrapper = document.getElementById(wrapperId); if (!wrapper) return;
                const input = wrapper.querySelector('input[type="hidden"]'); const triggerText = wrapper.querySelector('.custom-select-trigger span');
                if (input) input.value = targetValue;
                wrapper.querySelectorAll('.custom-option').forEach(opt => {
                    opt.classList.remove('selected');
                    if (opt.getAttribute('data-value') === targetValue) { opt.classList.add('selected'); if (triggerText) triggerText.textContent = opt.textContent; }
                });
            };
            setMaxValue('wrap-engine', 'max'); setMaxValue('wrap-brakes', 'max'); setMaxValue('wrap-transmission', 'max');
            setMaxValue('wrap-suspension', 'max'); setMaxValue('wrap-armor', 'max'); setMaxValue('wrap-turbo', 'on');
        });
    }

    // Livery Modal
    const liveryModal = document.getElementById('livery-modal');
    const liveryOptsContainer = document.getElementById('opts-livery');
    const liveryTriggerText = document.querySelector('#trig-livery span');
    const liveryInput = document.getElementById('val-livery');

    window.openLiveryModal = () => {
        liveryTriggerText.textContent = "Cargando..."; liveryInput.value = "-1";
        fetch(`https://${GetParentResourceName()}/getVehicleLiveries`, { method: 'POST', headers: { 'Content-Type': 'application/json' }, body: JSON.stringify({}) })
            .then(resp => resp.json()).then(liveries => {
                liveryOptsContainer.innerHTML = '';
                let html = `<span class="custom-option selected" data-value="-1">-- SIN CALCOMANÍA --</span>`;
                if (liveries.length === 0) html += `<span class="custom-option" data-value="-1" style="color: #aaa;">(No hay diseños disponibles)</span>`;
                else liveries.forEach(livery => { html += `<span class="custom-option" data-value="${livery.id}">${livery.name}</span>`; });
                liveryOptsContainer.innerHTML = html; liveryTriggerText.textContent = "-- SIN CALCOMANÍA --";
                const oldTrigger = document.getElementById('trig-livery'); const newTrigger = oldTrigger.cloneNode(true);
                oldTrigger.parentNode.replaceChild(newTrigger, oldTrigger);
                setupTuningSelect('wrap-livery', 'trig-livery', 'val-livery');
                liveryModal.style.display = 'flex';
            });
    };
    window.closeLiveryModal = () => { liveryModal.style.display = 'none'; };
    const btnLivery = document.getElementById('btn-apply-livery');
    if (btnLivery) {
        btnLivery.addEventListener('click', () => {
            const val = document.getElementById('val-livery').value;
            fetch(`https://${GetParentResourceName()}/setVehicleLivery`, { method: 'POST', headers: { 'Content-Type': 'application/json' }, body: JSON.stringify({ liveryIndex: parseInt(val) }) });
            closeLiveryModal();
        });
    }
    window.addEventListener('click', (e) => {
        if (liveryModal.style.display === 'flex') { const wrap = document.getElementById('wrap-livery'); if (wrap && wrap.classList.contains('open') && !wrap.contains(e.target)) wrap.classList.remove('open'); }
    });

    // ==========================================================================
    // 14. SISTEMA DE PINTURA (CORE)
    // ==========================================================================
    const paintModal = document.getElementById('paint-modal');

    function hexToRgb(hex) {
        hex = hex.replace(/^#/, ''); const bigint = parseInt(hex, 16);
        return [(bigint >> 16) & 255, (bigint >> 8) & 255, bigint & 255];
    }

    function updatePaintUI(target, category) {
        const pickerBtn = document.getElementById(`btn-col-${target}`);
        const listWrapper = document.getElementById(`wrap-${target}-list`);
        const listTrigger = document.getElementById(`trig-${target}-list`);
        const listContainer = document.getElementById(`opts-${target}-list`);
        const valInput = document.getElementById(`val-${target}-id`);

        if (category === 'normal') {
            pickerBtn.style.display = 'flex'; listWrapper.style.display = 'none';
        } else {
            pickerBtn.style.display = 'none'; listWrapper.style.display = 'block';
            const colors = gtaPaintData[category] || [];
            listContainer.innerHTML = '';
            if (colors.length > 0) { listTrigger.querySelector('span').textContent = colors[0].name; valInput.value = colors[0].id; }
            colors.forEach(col => {
                const opt = document.createElement('span'); opt.className = 'custom-option'; opt.setAttribute('data-value', col.id); opt.textContent = col.name;
                listContainer.appendChild(opt);
            });
            setupTuningSelect(`wrap-${target}-list`, `trig-${target}-list`, `val-${target}-id`);
        }
    }

    setupTuningSelect('wrap-primary-type', 'trig-primary-type', 'val-primary-type', (val) => updatePaintUI('primary', val));
    setupTuningSelect('wrap-secondary-type', 'trig-secondary-type', 'val-secondary-type', (val) => updatePaintUI('secondary', val));
    setupTuningSelect('wrap-xenon', 'trig-xenon', 'val-xenon');

    const pearlContainer = document.getElementById('opts-pearl');
    if (pearlContainer) {
        pearlContainer.innerHTML = ''; let html = `<span class="custom-option selected" data-value="0">Sin Nacarado (Negro)</span>`;
        [...gtaPaintData.metallic, ...gtaPaintData.classic].forEach(col => { if (col.id !== 0) html += `<span class="custom-option" data-value="${col.id}">${col.name}</span>`; });
        pearlContainer.innerHTML = html;
        setupTuningSelect('wrap-pearl', 'trig-pearl', 'val-pearl');
    }

    window.openPaintModal = () => {
        const currentPrimary = document.getElementById('val-primary-type').value;
        const currentSecondary = document.getElementById('val-secondary-type').value;
        updatePaintUI('primary', currentPrimary); updatePaintUI('secondary', currentSecondary);
        paintModal.style.display = 'flex';
    };
    window.closePaintModal = () => { paintModal.style.display = 'none'; };

    const btnPaint = document.getElementById('btn-apply-paint');
    if (btnPaint) {
        const newBtn = btnPaint.cloneNode(true); btnPaint.parentNode.replaceChild(newBtn, btnPaint);
        newBtn.addEventListener('click', () => {
            const data = {
                primary: { type: document.getElementById('val-primary-type').value, rgb: hexToRgb(document.getElementById('val-col-primary').value), id: parseInt(document.getElementById('val-primary-id').value) },
                secondary: { type: document.getElementById('val-secondary-type').value, rgb: hexToRgb(document.getElementById('val-col-secondary').value), id: parseInt(document.getElementById('val-secondary-id').value) },
                pearlescent: parseInt(document.getElementById('val-pearl').value),
                neon: hexToRgb(document.getElementById('val-col-neon').value), wheels: hexToRgb(document.getElementById('val-col-wheels').value),
                smoke: hexToRgb(document.getElementById('val-col-smoke').value), xenon: document.getElementById('val-xenon').value
            };
            fetch(`https://${GetParentResourceName()}/applyPaint`, { method: 'POST', headers: { 'Content-Type': 'application/json' }, body: JSON.stringify({ paint: data }) });
            closePaintModal();
        });
    }

    // ==========================================================================
    // 15. SISTEMA DE COLOR PICKER (IRO.JS)
    // ==========================================================================
    let colorPickerInstance = null;
    let activeColorTarget = null;

    function initColorPicker() {
        if (colorPickerInstance) return;
        colorPickerInstance = new iro.ColorPicker("#iro-color-picker", {
            width: 260, color: "#ffffff", borderWidth: 1, borderColor: "#444",
            layout: [{ component: iro.ui.Box, options: {} }, { component: iro.ui.Slider, options: { sliderType: 'hue', marginTop: 15 } }]
        });
        colorPickerInstance.on('color:change', function (color) {
            document.getElementById('in-hex').value = color.hexString.substring(1).toUpperCase();
            document.getElementById('in-r').value = color.rgb.r; document.getElementById('in-g').value = color.rgb.g; document.getElementById('in-b').value = color.rgb.b;
        });
        setupInputListeners();
        const presets = document.querySelectorAll('.dp-swatch');
        presets.forEach(swatch => {
            swatch.addEventListener('click', function () { colorPickerInstance.color.hexString = this.getAttribute('data-hex'); });
        });
    }

    function setupInputListeners() {
        document.getElementById('in-hex').addEventListener('input', function () { if (this.value.length >= 3) colorPickerInstance.color.hexString = "#" + this.value; });
        ['r', 'g', 'b'].forEach(c => {
            document.getElementById(`in-${c}`).addEventListener('input', () => {
                const r = document.getElementById('in-r').value, g = document.getElementById('in-g').value, b = document.getElementById('in-b').value;
                colorPickerInstance.color.rgb = { r: r, g: g, b: b };
            });
        });
    }

    window.switchColorMode = (mode) => {
        document.querySelectorAll('.tab-btn').forEach(btn => btn.classList.remove('active')); event.target.classList.add('active');
        document.querySelectorAll('.color-panel').forEach(p => p.classList.remove('active')); document.getElementById(`panel-${mode}`).classList.add('active');
    };

    window.openColorPicker = (target) => {
        activeColorTarget = target; initColorPicker();
        const currentColor = document.getElementById(`val-col-${target}`).value;
        colorPickerInstance.color.hexString = currentColor;
        document.getElementById('picker-modal').style.display = 'flex';
    };
    window.closeColorPickerModal = () => { document.getElementById('picker-modal').style.display = 'none'; activeColorTarget = null; };

    const btnSaveColor = document.getElementById('btn-save-color');
    const newSaveBtn = btnSaveColor.cloneNode(true); btnSaveColor.parentNode.replaceChild(newSaveBtn, btnSaveColor);
    newSaveBtn.addEventListener('click', () => {
        if (activeColorTarget) {
            const selectedColor = colorPickerInstance.color.hexString;
            document.getElementById(`val-col-${activeColorTarget}`).value = selectedColor;
            document.getElementById(`sample-${activeColorTarget}`).style.backgroundColor = selectedColor;
        }
        closeColorPickerModal();
    });

    // ==========================================================================
    // 16. BOTÓN ALEATORIZAR (CHAOS MODE)
    // ==========================================================================
    const btnRandomPaint = document.getElementById('btn-random-paint');
    if (btnRandomPaint) {
        btnRandomPaint.addEventListener('click', () => {
            const getRandomHex = () => '#' + Math.floor(Math.random() * 16777215).toString(16).padStart(6, '0').toUpperCase();
            const getRandomItem = (arr) => arr[Math.floor(Math.random() * arr.length)];

            const randomizePaintSection = (target) => {
                const types = ['normal', 'classic', 'metallic', 'matte', 'metals', 'chameleon', 'worn', 'util'];
                const randomType = getRandomItem(types);
                const typeWrapper = document.getElementById(`wrap-${target}-type`);
                const typeInput = document.getElementById(`val-${target}-type`);
                const typeTrigger = document.getElementById(`trig-${target}-type`);

                typeInput.value = randomType;
                const typeOption = typeWrapper.querySelector(`.custom-option[data-value="${randomType}"]`);
                if (typeOption) typeTrigger.querySelector('span').textContent = typeOption.textContent;

                if (randomType === 'normal') {
                    const randomColor = getRandomHex();
                    document.getElementById(`val-col-${target}`).value = randomColor;
                    document.getElementById(`sample-${target}`).style.backgroundColor = randomColor;
                } else {
                    const list = gtaPaintData[randomType];
                    if (list && list.length > 0) {
                        const randomPaint = getRandomItem(list);
                        document.getElementById(`val-${target}-id`).value = randomPaint.id;
                        document.getElementById(`trig-${target}-list`).querySelector('span').textContent = randomPaint.name;
                    }
                }
                updatePaintUI(target, randomType);
            };

            randomizePaintSection('primary');
            randomizePaintSection('secondary');

            const allPearls = [...gtaPaintData.metallic, ...gtaPaintData.classic];
            const randomPearl = getRandomItem(allPearls);
            document.getElementById('val-pearl').value = randomPearl.id;
            document.getElementById('trig-pearl').querySelector('span').textContent = randomPearl.name;

            ['wheels', 'neon', 'smoke'].forEach(t => {
                const color = getRandomHex();
                document.getElementById(`val-col-${t}`).value = color;
                document.getElementById(`sample-${t}`).style.backgroundColor = color;
            });

            const randomXenon = Math.floor(Math.random() * 13);
            document.getElementById('val-xenon').value = randomXenon;
            const xenonWrapper = document.getElementById('wrap-xenon');
            const xenonOpt = xenonWrapper.querySelector(`.custom-option[data-value="${randomXenon}"]`);
            if (xenonOpt) document.getElementById('trig-xenon').querySelector('span').textContent = xenonOpt.textContent;
        });
    }

    // ==========================================================================
    // 17. MÓDULO: TRABAJOS (JOBS) - PRO EDITION
    // ==========================================================================
    const jobListContainer = document.getElementById('job-list-container');
    const totalJobsCounter = document.getElementById('total-jobs');

    // Variables temporales
    let selectedJobPlayerId = null;
    let selectedJobName = null;

    // Renderizado Inteligente de Trabajos
    // keepState = true significa "No me cierres los desplegables"
    function renderJobList(list, keepState = false) {
        if (!jobListContainer) return;

        // 1. MEMORIA: Guardamos qué trabajos están abiertos antes de borrar nada
        let openJobs = new Set();
        if (keepState) {
            const currentOpenCards = jobListContainer.querySelectorAll('.accordion-card.expanded');
            currentOpenCards.forEach(card => {
                // Buscamos el ID técnico (ej: 'police') dentro del badge
                const idBadge = card.querySelector('.id-badge');
                if (idBadge) openJobs.add(idBadge.innerText);
            });
        }

        // 2. LIMPIEZA Y ORDEN
        jobListContainer.innerHTML = '';
        if (totalJobsCounter) totalJobsCounter.innerText = list ? list.length : 0;

        if (!list || list.length === 0) {
            jobListContainer.innerHTML = '<div style="padding:15px; color:#888; text-align:center;">No se encontraron trabajos.</div>';
            return;
        }

        // Ordenar alfabéticamente A-Z
        list.sort((a, b) => a.label.localeCompare(b.label));

        // 3. RENDERIZADO
        list.forEach(job => {
            const card = document.createElement('div');
            // Si este trabajo estaba en nuestra memoria de "abiertos", le añadimos la clase 'expanded' directamente
            const isExpanded = keepState && openJobs.has(job.name);
            card.className = isExpanded ? 'accordion-card expanded' : 'accordion-card';

            const playerCount = job.players ? job.players.length : 0;
            const countClass = playerCount > 0 ? 'online-count-badge active' : 'online-count-badge';
            const countText = playerCount > 0 ? `${playerCount} conectados` : '0 conectados';

            // HTML (Idéntico al anterior)
            let html = `
                <div class="accordion-header" onclick="toggleJobAccordion(this)">
                    <span class="id-badge" style="text-transform:none; width:115px; text-align:center; background:#18075A;">${job.name}</span> 
                    <span style="font-weight:bold; color:var(--text-main); margin-left:10px;">${job.label}</span>
                    <span class="${countClass}">${countText}</span>
                    <span class="iconify accordion-icon" data-icon="mdi:chevron-down"></span>
                </div>
                <div class="accordion-content">
            `;

            if (playerCount === 0) {
                html += `<div style="padding:20px; font-size:12px; color:#666; text-align:center; font-style:italic;">
                            <span class="iconify" data-icon="mdi:sleep" style="font-size:20px; vertical-align:middle;"></span> 
                            Nadie trabajando aquí ahora mismo.
                         </div>`;
            } else {
                job.players.forEach(p => {
                    const dutyClass = p.onduty ? 'jp-duty on' : 'jp-duty off';
                    const dutyIcon = p.onduty ? 'mdi:clock-check-outline' : 'mdi:clock-remove-outline';
                    const dutyText = p.onduty ? 'EN SERVICIO' : 'FUERA SERVICIO';
                    const dutyTooltip = p.onduty ? 'Click para sacar de servicio' : 'Click para poner en servicio';

                    html += `
                        <div class="job-player-row">
                            <div class="jp-info">
                                <span class="jp-id-badge">${p.source}</span>
                                <div class="jp-names">
                                    <div class="jp-char-name">${p.charName}</div>
                                    <div class="jp-steam-name">(${p.name})</div>
                                </div>
                                <div class="jp-meta">
                                    <div class="jp-grade">
                                        <span class="iconify" data-icon="mdi:police-badge-outline"></span>
                                        ${p.gradeLabel} <span class="jp-grade-num">${p.gradeLevel}</span>
                                    </div>
                                    <div class="${dutyClass}" onclick="toggleDutyPlayer(${p.source})" title="${dutyTooltip}">
                                        <span class="iconify" data-icon="${dutyIcon}"></span> ${dutyText}
                                    </div>
                                </div>
                            </div>
                            <div class="icon-actions">
                                <div class="icon-btn" onclick="" data-tooltip="Detalles del Jugador">
                                    <span class="iconify" data-icon="mdi:account-details"></span>
                                </div>
                                <div class="icon-btn warn" onclick="openJobRankModal('${p.source}', '${p.name}', '${job.name}')" data-tooltip="Cambiar Rango">
                                    <span class="iconify" data-icon="mdi:arrow-up-bold-hexagon-outline"></span>
                                </div>
                                <div class="icon-btn danger" onclick="openJobManageModal('${p.source}', '${p.name}')" data-tooltip="Despedir / Cambiar Trabajo">
                                    <span class="iconify" data-icon="mdi:briefcase-remove-outline"></span>
                                </div>
                            </div>
                        </div>
                    `;
                });
            }

            html += `</div>`;
            card.innerHTML = html;
            jobListContainer.appendChild(card);
        });
    }

    // Funciones Auxiliares Nuevas
    window.toggleDutyPlayer = (id) => {
        // Llamada correcta al endpoint específico toggleDuty
        fetch(`https://${GetParentResourceName()}/toggleDuty`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ targetId: id })
        });
    };

    window.teleportToPlayer = (id) => {
        log("TP a: " + id);
    };

    window.revivePlayer = (id) => {
        // Reutilizamos lógica de revive pero pasando ID
        log("Revivir a: " + id);
    };

    // ==========================================================================
    // 18. MÓDULO: BANDAS (GANGS)
    // ==========================================================================
    const gangListContainer = document.getElementById('gang-list-container');
    const totalGangsCounter = document.getElementById('total-gangs'); // Asegúrate de tener este ID en HTML si usas contador

    // Variables temporales para Gangs
    let selectedGangPlayerId = null;
    let selectedGangName = null;

    // 1. RENDERIZADO INTELIGENTE DE BANDAS
    function renderGangList(list, keepState = false) {
        if (!gangListContainer) return;

        // Memoria de acordeones abiertos
        let openGangs = new Set();
        if (keepState) {
            const currentOpen = gangListContainer.querySelectorAll('.accordion-card.expanded');
            currentOpen.forEach(card => {
                const idBadge = card.querySelector('.id-badge');
                if (idBadge) openGangs.add(idBadge.innerText);
            });
        }

        gangListContainer.innerHTML = '';
        if (totalGangsCounter) totalGangsCounter.innerText = list ? list.length : 0;

        if (!list || list.length === 0) {
            gangListContainer.innerHTML = '<div style="padding:15px; color:#888; text-align:center;">No se encontraron bandas activas.</div>';
            return;
        }

        list.sort((a, b) => a.label.localeCompare(b.label));

        list.forEach(gang => {
            const card = document.createElement('div');
            const isExpanded = keepState && openGangs.has(gang.name);
            card.className = isExpanded ? 'accordion-card expanded' : 'accordion-card';

            const playerCount = gang.players ? gang.players.length : 0;
            const countClass = playerCount > 0 ? 'online-count-badge active' : 'online-count-badge';
            const countText = playerCount > 0 ? `${playerCount} conectados` : '0 conectados';

            // Cabecera
            let html = `
                <div class="accordion-header" onclick="toggleJobAccordion(this)">
                    <span class="id-badge" style="text-transform:none; width:115px; text-align:center; background:#5a1a1a;">${gang.name}</span> 
                    <span style="font-weight:bold; color:var(--text-main); margin-left:10px;">${gang.label}</span>
                    <span class="${countClass}">${countText}</span>
                    <span class="iconify accordion-icon" data-icon="mdi:chevron-down"></span>
                </div>
                <div class="accordion-content">
            `;

            // Contenido
            if (playerCount === 0) {
                html += `<div style="padding:20px; font-size:12px; color:#666; text-align:center; font-style:italic;">
                            <span class="iconify" data-icon="mdi:sleep" style="font-size:20px; vertical-align:middle;"></span> 
                            Nadie de esta banda conectado.
                         </div>`;
            } else {
                gang.players.forEach(p => {
                    // Reutilizamos clase .job-player-row para mantener el estilo visual exacto
                    html += `
                        <div class="job-player-row">
                            <div class="jp-info">
                                <span class="jp-id-badge">${p.source}</span>
                                <div class="jp-names">
                                    <div class="jp-char-name">${p.charName}</div>
                                    <div class="jp-steam-name">(${p.name})</div>
                                </div>
                                
                                <div class="jp-meta">
                                    <div class="jp-grade" style="background:rgba(255, 50, 50, 0.1); border-color:rgba(255,50,50,0.2);">
                                        <span class="iconify" data-icon="mdi:skull-crossbones-outline"></span>
                                        ${p.gradeLabel} 
                                        <span class="jp-grade-num" style="color:#ff6b6b;">${p.gradeLevel}</span>
                                    </div>
                                    </div>
                            </div>

                            <div class="icon-actions">
                                <div class="icon-btn" onclick="" data-tooltip="Detalles del Jugador">
                                    <span class="iconify" data-icon="mdi:account-details"></span>
                                </div>
                                <div class="icon-btn warn" onclick="openGangRankModal('${p.source}', '${p.name}', '${gang.name}')" data-tooltip="Cambiar Rango">
                                    <span class="iconify" data-icon="mdi:arrow-up-bold-hexagon-outline"></span>
                                </div>
                                <div class="icon-btn danger" onclick="openGangManageModal('${p.source}', '${p.name}')" data-tooltip="Expulsar / Cambiar Banda">
                                    <span class="iconify" data-icon="mdi:account-cancel-outline"></span>
                                </div>
                            </div>
                        </div>
                    `;
                });
            }

            html += `</div>`;
            card.innerHTML = html;
            gangListContainer.appendChild(card);
        });
    }

    // 2. LÓGICA MODAL GESTIONAR BANDA (SELECTS)
    const gmModal = document.getElementById('gang-manage-modal');
    const gmName = document.getElementById('gm-player-name');

    const wrapGmGang = document.getElementById('wrap-gm-gang');
    const trigGmGang = document.getElementById('trig-gm-gang');
    const optsGmGang = document.getElementById('opts-gm-gang');
    const valGmGang = document.getElementById('val-gm-gang');

    const wrapGmGrade = document.getElementById('wrap-gm-grade');
    const trigGmGrade = document.getElementById('trig-gm-grade');
    const optsGmGrade = document.getElementById('opts-gm-grade');
    const valGmGrade = document.getElementById('val-gm-grade');

    window.openGangManageModal = (playerId, playerName) => {
        selectedGangPlayerId = playerId;
        if (gmName) gmName.innerText = playerName;

        if (valGmGang) valGmGang.value = "";
        if (trigGmGang) trigGmGang.querySelector('span').innerText = "Seleccionar Banda...";

        if (valGmGrade) valGmGrade.value = "0";
        if (trigGmGrade) trigGmGrade.querySelector('span').innerText = "Primero elige una banda...";
        if (wrapGmGrade) wrapGmGrade.classList.add('disabled');

        populateGangOptions();
        if (gmModal) gmModal.style.display = 'flex';
    };

    window.closeGangManageModal = () => {
        if (gmModal) gmModal.style.display = 'none';
        if (wrapGmGang) wrapGmGang.classList.remove('open');
        if (wrapGmGrade) wrapGmGrade.classList.remove('open');
    };

    function populateGangOptions() {
        if (!optsGmGang) return;
        optsGmGang.innerHTML = '';
        const sortedGangs = [...allGangs].sort((a, b) => a.label.localeCompare(b.label));

        sortedGangs.forEach(g => {
            const option = document.createElement('span');
            option.className = 'custom-option';
            option.innerText = g.label;
            option.addEventListener('click', () => {
                if (valGmGang) valGmGang.value = g.name;
                if (trigGmGang) trigGmGang.querySelector('span').innerText = g.label;
                if (wrapGmGang) wrapGmGang.classList.remove('open');
                populateGangGradeOptions(g);
            });
            optsGmGang.appendChild(option);
        });
    }

    function populateGangGradeOptions(gangData) {
        if (!optsGmGrade) return;
        optsGmGrade.innerHTML = '';
        if (wrapGmGrade) wrapGmGrade.classList.remove('disabled');
        if (valGmGrade) valGmGrade.value = "0";

        let gradesArray = [];
        if (gangData.grades) {
            for (const [level, data] of Object.entries(gangData.grades)) {
                gradesArray.push({ level: parseInt(level), name: data.name });
            }
        }
        gradesArray.sort((a, b) => a.level - b.level);

        if (trigGmGrade) trigGmGrade.querySelector('span').innerText = gradesArray.length > 0 ? `${gradesArray[0].name} (0)` : "Sin rangos";

        gradesArray.forEach(grade => {
            const option = document.createElement('span');
            option.className = 'custom-option';
            option.innerText = `${grade.name} (${grade.level})`;
            option.addEventListener('click', () => {
                if (valGmGrade) valGmGrade.value = grade.level;
                if (trigGmGrade) trigGmGrade.querySelector('span').innerText = option.innerText;
                if (wrapGmGrade) wrapGmGrade.classList.remove('open');
            });
            optsGmGrade.appendChild(option);
        });
    }

    // Listeners Selects Gangs
    if (trigGmGang) {
        trigGmGang.addEventListener('click', (e) => {
            if (wrapGmGang) wrapGmGang.classList.toggle('open');
            if (wrapGmGrade) wrapGmGrade.classList.remove('open');
            e.stopPropagation();
        });
    }
    if (trigGmGrade) {
        trigGmGrade.addEventListener('click', (e) => {
            if (wrapGmGrade && !wrapGmGrade.classList.contains('disabled')) wrapGmGrade.classList.toggle('open');
            if (wrapGmGang) wrapGmGang.classList.remove('open');
            e.stopPropagation();
        });
    }

    // Botones Acción
    const btnSetGang = document.getElementById('btn-set-gang');
    if (btnSetGang) {
        btnSetGang.addEventListener('click', () => {
            const newGang = valGmGang ? valGmGang.value : null;
            const newGrade = valGmGrade ? valGmGrade.value : 0;
            if (!newGang) return;

            fetch(`https://${GetParentResourceName()}/setGang`, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ targetId: selectedGangPlayerId, gang: newGang, grade: newGrade })
            });
            closeGangManageModal();
        });
    }

    const btnFireGang = document.getElementById('btn-fire-gang');
    if (btnFireGang) {
        btnFireGang.addEventListener('click', () => {
            showConfirmationModal(`¿Expulsar a <b>${gmName ? gmName.innerText : 'Jugador'}</b> de su banda?`, () => {
                fetch(`https://${GetParentResourceName()}/setGang`, {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify({ targetId: selectedGangPlayerId, gang: "none", grade: 0 })
                });
            });
            closeGangManageModal();
        });
    }

    // 3. LÓGICA MODAL RANGO BANDA (SIMPLE)
    const grModal = document.getElementById('gang-rank-modal');
    const grName = document.getElementById('gr-player-name');
    const grInput = document.getElementById('gr-grade-input');
    const grPreview = document.getElementById('gr-grade-preview');

    window.openGangRankModal = (playerId, playerName, gangName) => {
        selectedGangPlayerId = playerId;
        selectedGangName = gangName;
        if (grName) grName.innerText = playerName;
        if (grInput) {
            grInput.value = "";
            setTimeout(() => grInput.focus(), 100);
        }
        if (grPreview) {
            grPreview.innerText = "Escribe un número...";
            grPreview.style.color = "#888";
        }
        if (grModal) grModal.style.display = 'flex';
    };

    window.closeGangRankModal = () => { if (grModal) grModal.style.display = 'none'; };

    if (grInput) {
        grInput.addEventListener('input', (e) => {
            const val = parseInt(e.target.value);
            if (!grPreview) return;
            if (isNaN(val)) {
                grPreview.innerText = "Escribe un número...";
                grPreview.style.color = "#888";
                return;
            }
            const gangData = allGangs.find(g => g.name === selectedGangName);
            let gradeName = "Desconocido";
            if (gangData && gangData.grades) {
                if (gangData.grades[val]) gradeName = gangData.grades[val].name;
                else if (gangData.grades[val.toString()]) gradeName = gangData.grades[val.toString()].name;
                else {
                    gradeName = "❌ Rango no existe";
                    grPreview.style.color = "var(--danger)";
                }
                if (gradeName !== "❌ Rango no existe") grPreview.style.color = "var(--success)";
            }
            grPreview.innerText = gradeName;
        });
    }

    const btnConfirmGangRank = document.getElementById('btn-confirm-gang-rank');
    if (btnConfirmGangRank) {
        btnConfirmGangRank.addEventListener('click', () => {
            const grade = grInput ? grInput.value : "";
            if (grade === "") return;
            fetch(`https://${GetParentResourceName()}/setGangGrade`, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ targetId: selectedGangPlayerId, grade: grade })
            });
            closeGangRankModal();
        });
    }

    // 4. BUSCADOR DE BANDAS
    const gangSearchInput = document.getElementById('gang-search-input');
    if (gangSearchInput) {
        gangSearchInput.addEventListener('input', (e) => {
            const text = e.target.value.toLowerCase();
            if (text === "") {
                renderGangList(allGangs, true);
                return;
            }

            const filtered = allGangs.filter(gang => {
                const matchInfo = gang.name.toLowerCase().includes(text) || gang.label.toLowerCase().includes(text);
                const playerCount = gang.players ? gang.players.length : 0;
                const matchCount = (playerCount + " conectados").includes(text) || (playerCount.toString() === text);
                const matchPlayers = gang.players && gang.players.some(p =>
                    p.source.toString().includes(text) ||
                    p.name.toLowerCase().includes(text) ||
                    p.charName.toLowerCase().includes(text)
                );
                return matchInfo || matchCount || matchPlayers;
            });

            renderGangList(filtered, true);

            if (text.length > 1 && filtered.length < 5) {
                const cards = document.querySelectorAll('#gang-list-container .accordion-card');
                cards.forEach(card => card.classList.add('expanded'));
            }
        });
    }

    // ==========================================================================
    // 19. FUNCIONES AUXILIARES DE TRABAJOS (ACORDEÓN Y MODALES) - VERSIÓN SEGURA
    // ==========================================================================

    // 1. LÓGICA DEL ACORDEÓN
    window.toggleJobAccordion = (headerElement) => {
        const card = headerElement.parentElement;
        card.classList.toggle('expanded');
    };

    // 2. LÓGICA MODAL: GESTIONAR
    const jmModal = document.getElementById('job-manage-modal');
    const jmName = document.getElementById('jm-player-name');

    // Referencias a los nuevos elementos Select del HTML
    const wrapJmJob = document.getElementById('wrap-jm-job');
    const trigJmJob = document.getElementById('trig-jm-job');
    const optsJmJob = document.getElementById('opts-jm-job');
    const valJmJob = document.getElementById('val-jm-job');

    const wrapJmGrade = document.getElementById('wrap-jm-grade');
    const trigJmGrade = document.getElementById('trig-jm-grade');
    const optsJmGrade = document.getElementById('opts-jm-grade');
    const valJmGrade = document.getElementById('val-jm-grade');

    // ABRIR MODAL
    window.openJobManageModal = (playerId, playerName) => {
        selectedJobPlayerId = playerId;
        if (jmName) jmName.innerText = playerName;

        // Resetear visualmente (con seguridad)
        if (valJmJob) valJmJob.value = "";
        if (trigJmJob) trigJmJob.querySelector('span').innerText = "Seleccionar Trabajo...";

        if (valJmGrade) valJmGrade.value = "0";
        if (trigJmGrade) trigJmGrade.querySelector('span').innerText = "Primero elige un trabajo...";
        if (wrapJmGrade) wrapJmGrade.classList.add('disabled');

        populateJobOptions(); // Cargar la lista
        if (jmModal) jmModal.style.display = 'flex';
    };

    window.closeJobManageModal = () => {
        if (jmModal) jmModal.style.display = 'none';
        if (wrapJmJob) wrapJmJob.classList.remove('open');
        if (wrapJmGrade) wrapJmGrade.classList.remove('open');
    };

    // FUNCIÓN: Rellenar lista de trabajos
    function populateJobOptions() {
        if (!optsJmJob) return; // Seguridad
        optsJmJob.innerHTML = '';
        const sortedJobs = [...allJobs].sort((a, b) => a.label.localeCompare(b.label));

        sortedJobs.forEach(job => {
            const option = document.createElement('span');
            option.className = 'custom-option';
            option.setAttribute('data-value', job.name);
            option.innerText = `${job.label}`;

            option.addEventListener('click', () => {
                if (valJmJob) valJmJob.value = job.name;
                if (trigJmJob) trigJmJob.querySelector('span').innerText = job.label;
                if (wrapJmJob) wrapJmJob.classList.remove('open');
                populateGradeOptions(job); // Cargar rangos al elegir job
            });
            optsJmJob.appendChild(option);
        });
    }

    // FUNCIÓN: Rellenar lista de rangos
    function populateGradeOptions(jobData) {
        if (!optsJmGrade) return; // Seguridad
        optsJmGrade.innerHTML = '';
        if (wrapJmGrade) wrapJmGrade.classList.remove('disabled');
        if (valJmGrade) valJmGrade.value = "0";

        let gradesArray = [];
        if (jobData.grades) {
            for (const [level, data] of Object.entries(jobData.grades)) {
                gradesArray.push({ level: parseInt(level), name: data.name });
            }
        }
        gradesArray.sort((a, b) => a.level - b.level);

        if (trigJmGrade) {
            if (gradesArray.length > 0) {
                trigJmGrade.querySelector('span').innerText = `${gradesArray[0].name} (0)`;
            } else {
                trigJmGrade.querySelector('span').innerText = "Sin rangos";
            }
        }

        gradesArray.forEach(grade => {
            const option = document.createElement('span');
            option.className = 'custom-option';
            option.setAttribute('data-value', grade.level);
            option.innerText = `${grade.name} (${grade.level})`;

            option.addEventListener('click', () => {
                if (valJmGrade) valJmGrade.value = grade.level;
                if (trigJmGrade) trigJmGrade.querySelector('span').innerText = option.innerText;
                if (wrapJmGrade) wrapJmGrade.classList.remove('open');
            });
            optsJmGrade.appendChild(option);
        });
    }

    // LISTENERS SEGUROS (Aquí es donde daba el error)
    if (trigJmJob) {
        trigJmJob.addEventListener('click', (e) => {
            if (wrapJmJob) wrapJmJob.classList.toggle('open');
            if (wrapJmGrade) wrapJmGrade.classList.remove('open');
            e.stopPropagation();
        });
    }
    if (trigJmGrade) {
        trigJmGrade.addEventListener('click', (e) => {
            if (wrapJmGrade && wrapJmGrade.classList.contains('disabled')) return;
            if (wrapJmGrade) wrapJmGrade.classList.toggle('open');
            if (wrapJmJob) wrapJmJob.classList.remove('open');
            e.stopPropagation();
        });
    }
    window.addEventListener('click', (e) => {
        if (wrapJmJob && !wrapJmJob.contains(e.target)) wrapJmJob.classList.remove('open');
        if (wrapJmGrade && !wrapJmGrade.contains(e.target)) wrapJmGrade.classList.remove('open');
    });

    // A. BOTÓN DEL MODAL "GESTIONAR" (CAMBIAR TRABAJO Y RANGO)
    const btnSetJob = document.getElementById('btn-set-job');
    if (btnSetJob) {
        btnSetJob.addEventListener('click', () => {
            const newJob = valJmJob ? valJmJob.value : null;
            const newGrade = valJmGrade ? valJmGrade.value : 0;
            if (!newJob) return;

            // ESTA ES LA LÍNEA QUE FALTABA:
            fetch(`https://${GetParentResourceName()}/setJob`, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({
                    targetId: selectedJobPlayerId,
                    job: newJob,
                    grade: newGrade
                })
            });

            closeJobManageModal();
            // Truco: Recargamos la lista tras 500ms para ver el cambio
            setTimeout(() => {
                // Aquí podrías llamar a una función para refrescar si la tuvieras, 
                // o cerrar y abrir el menú.
            }, 500);
        });
    }

    // B. BOTÓN DEL MODAL "DESPEDIR"
    const btnFireJob = document.getElementById('btn-fire-job');
    if (btnFireJob) {
        btnFireJob.addEventListener('click', () => {
            showConfirmationModal(`¿Despedir a <b>${jmName ? jmName.innerText : 'Jugador'}</b>?`, () => {
                // Enviamos "unemployed" grado 0
                fetch(`https://${GetParentResourceName()}/setJob`, {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify({
                        targetId: selectedJobPlayerId,
                        job: "unemployed",
                        grade: 0
                    })
                });
            });
            closeJobManageModal();
        });
    }

    // C. BOTÓN DEL MODAL "SOLO RANGO" (EL AMARILLO)
    const btnConfirmRank = document.getElementById('btn-confirm-rank');
    if (btnConfirmRank) {
        btnConfirmRank.addEventListener('click', () => {
            const grade = jrInput ? jrInput.value : "";
            if (grade === "") return;

            fetch(`https://${GetParentResourceName()}/setJobGrade`, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({
                    targetId: selectedJobPlayerId,
                    grade: grade
                })
            });

            closeJobRankModal();
        });
    }

    // 3. LÓGICA MODAL: CAMBIAR RANGO (Input Simple)
    const jrModal = document.getElementById('job-rank-modal');
    const jrName = document.getElementById('jr-player-name');
    const jrInput = document.getElementById('jr-grade-input');
    const jrPreview = document.getElementById('jr-grade-preview');

    window.openJobRankModal = (playerId, playerName, jobName) => {
        selectedJobPlayerId = playerId;
        selectedJobName = jobName;
        if (jrName) jrName.innerText = playerName;
        if (jrInput) {
            jrInput.value = "";
            setTimeout(() => jrInput.focus(), 100);
        }
        if (jrPreview) {
            jrPreview.innerText = "Escribe un número...";
            jrPreview.style.color = "#888";
        }
        if (jrModal) jrModal.style.display = 'flex';
    };

    window.closeJobRankModal = () => { if (jrModal) jrModal.style.display = 'none'; };

    if (jrInput) {
        jrInput.addEventListener('input', (e) => {
            const val = parseInt(e.target.value);
            if (!jrPreview) return;

            if (isNaN(val)) {
                jrPreview.innerText = "Escribe un número...";
                jrPreview.style.color = "#888";
                return;
            }

            const jobData = allJobs.find(j => j.name === selectedJobName);
            let gradeName = "Desconocido";
            if (jobData && jobData.grades) {
                if (jobData.grades[val]) gradeName = jobData.grades[val].name;
                else if (jobData.grades[val.toString()]) gradeName = jobData.grades[val.toString()].name;
                else {
                    gradeName = "❌ Rango no existe";
                    jrPreview.style.color = "var(--danger)";
                }
                if (gradeName !== "❌ Rango no existe") jrPreview.style.color = "var(--success)";
            }
            jrPreview.innerText = gradeName;
        });
    }

    const jobSearchInput = document.getElementById('job-search-input');

    if (jobSearchInput) {
        jobSearchInput.addEventListener('input', (e) => {
            const text = e.target.value.toLowerCase();

            // Si está vacío, mostramos todo
            if (text === "") {
                renderJobList(allJobs);
                return;
            }

            const filtered = allJobs.filter(job => {
                // 1. ¿Coincide con el Nombre del Trabajo? (Ej: police, Policia)
                const matchJobInfo =
                    job.name.toLowerCase().includes(text) ||
                    job.label.toLowerCase().includes(text);

                // 2. ¿Coincide con el número de conectados? (Ej: "3 conectados")
                const playerCount = job.players ? job.players.length : 0;
                const matchCount = (playerCount + " conectados").includes(text) ||
                    (playerCount.toString() === text);

                // 3. ¿Coincide con ALGÚN Jugador dentro de ese trabajo?
                // (Buscamos por ID, Nombre Steam o Nombre Personaje)
                const matchInsidePlayers = job.players && job.players.some(p =>
                    p.source.toString().includes(text) ||           // Por ID (Ej: 145)
                    p.name.toLowerCase().includes(text) ||          // Por Steam (Ej: KikeGamer)
                    p.charName.toLowerCase().includes(text)         // Por PJ (Ej: Enrique Pastor)
                );

                // Si cumple CUALQUIERA de las condiciones, mostramos el trabajo
                return matchJobInfo || matchCount || matchInsidePlayers;
            });

            renderJobList(filtered);

            // TRUCO UX: Si estamos buscando y encontramos resultados, 
            // expandimos automáticamente las tarjetas para ver los jugadores encontrados
            if (text.length > 1 && filtered.length < 5) {
                const cards = document.querySelectorAll('#job-list-container .accordion-card');
                cards.forEach(card => card.classList.add('expanded'));
            }
        });
    }

    // Botón Limpiar Búsqueda
    const btnClearJobs = document.getElementById('btn-clear-jobs');
    if (btnClearJobs) {
        btnClearJobs.addEventListener('click', () => {
            if (jobSearchInput) jobSearchInput.value = '';
            renderJobList(allJobs);
        });
    }

    // ==========================================================================
    // MÓDULO: VEHÍCULOS (OPTIMIZADO CON LAZY LOAD / SCROLL INFINITO)
    // ==========================================================================
    const vehListContainer = document.getElementById('vehicle-list-container');
    const vehSearchInput = document.getElementById('veh-search-input');

    // Variables para el sistema de carga
    let allVehicles = [];      // La lista maestra completa
    let currentList = [];      // La lista que estamos viendo actualmente (filtrada o completa)
    let loadedCount = 0;       // Cuántos coches hay pintados en pantalla ahora mismo
    const BATCH_SIZE = 50;     // Cuántos coches cargamos por tanda (50 es ideal)
    let vehiclesLoaded = false; // Para saber si ya pedimos datos al server

    // 1. LISTENER DEL SCROLL (LA MAGIA)
    if (vehListContainer) {
        vehListContainer.addEventListener('scroll', () => {
            // Si el usuario ha scrolleado cerca del final (con un margen de 100px)
            if (vehListContainer.scrollTop + vehListContainer.clientHeight >= vehListContainer.scrollHeight - 100) {
                loadNextBatch();
            }
        });
    }

    // 2. DETECTAR CLIC EN PESTAÑA
    const vehTabBtn = document.querySelector('.tab[data-tab="vehicles"]'); // O usa getElementById si cambiaste a ID
    if (vehTabBtn) {
        vehTabBtn.addEventListener('click', () => {
            if (!vehiclesLoaded) {
                // Ponemos spinner de carga la primera vez
                vehListContainer.innerHTML = `
                    <div style="grid-column: 1/-1; text-align:center; color:#666; padding:40px; display:flex; flex-direction:column; align-items:center; gap:10px;">
                        <span class="iconify" data-icon="mdi:loading" data-rotate="360deg" style="font-size:30px; color:var(--primary);"></span>
                        <span>Cargando catálogo...</span>
                    </div>`;
                fetch(`https://${GetParentResourceName()}/requestVehicles`, { method: 'POST' });
            }
        });
    }

    // 3. FUNCIÓN PRINCIPAL DE RENDERIZADO (PREPARA LA LISTA)
    function renderVehicleList(list) {
        if (!vehListContainer) return;

        // Guardamos la lista actual para que el scroll sepa qué cargar
        currentList = list;
        loadedCount = 0; // Reseteamos contador

        // Limpiamos el contenedor
        vehListContainer.innerHTML = '';

        if (!list || list.length === 0) {
            vehListContainer.innerHTML = '<div style="grid-column:1/-1; padding:40px; text-align:center; color:#666; font-style:italic;">No se encontraron vehículos.</div>';
            return;
        }

        // Cargamos la primera tanda inmediatamente
        loadNextBatch();

        // Truco: Hacemos scroll arriba por si el usuario estaba abajo
        vehListContainer.scrollTop = 0;
    }

    // 4. FUNCIÓN QUE CARGA LOTES (LAZY LOAD)
    function loadNextBatch() {
        // Si ya hemos cargado todos, paramos
        if (loadedCount >= currentList.length) return;

        // Calculamos el rango a cargar (ej: del 0 al 50, o del 50 al 100)
        const nextBatch = currentList.slice(loadedCount, loadedCount + BATCH_SIZE);

        // Fragmento de documento (OPTIMIZACIÓN CLAVE: Dibuja todo en memoria y lo pega de golpe)
        const fragment = document.createDocumentFragment();

        nextBatch.forEach(veh => {
            const card = document.createElement('div');
            card.className = 'veh-card';

            const price = veh.price ? `$${veh.price.toLocaleString()}` : 'N/A';
            const brand = veh.brand || 'Desconocida';
            const category = veh.category || 'Sin Cat';
            const name = veh.name || veh.model;

            // HTML ESTRUCTURADO
            card.innerHTML = `
                <div class="veh-header">
                    <div class="veh-title" title="${name}">${name}</div>
                    <span class="iconify" data-icon="mdi:car-sports" style="color:#555; font-size:18px;"></span>
                </div>
                
                <div class="veh-body">
                    <div class="veh-info-grid">
                        <div class="veh-info-box">
                            <span class="veh-label">MARCA</span>
                            <span class="veh-value val-brand">${brand}</span>
                        </div>
                        <div class="veh-info-box">
                            <span class="veh-label">CATEGORÍA</span>
                            <span class="veh-value val-cat">${category}</span>
                        </div>
                        <div class="veh-info-box">
                            <span class="veh-label">PRECIO</span>
                            <span class="veh-value val-price">${price}</span>
                        </div>
                        <div class="veh-info-box">
                            <span class="veh-label">CÓDIGO</span>
                            <span class="veh-value val-code">${veh.model}</span>
                        </div>
                    </div>

                    <div class="veh-actions">
                        <button class="btn-spawn" onclick="spawnVehicle('${veh.model}')" title="Spawnear para mí">
                            <span class="iconify" data-icon="mdi:key-variant"></span> SPAWNEAR
                        </button>
                        
                        <button class="btn-give" onclick="window.openGiveVehicleModal('${veh.model}', '${veh.name}')" title="Dar a jugador">
                            <span class="iconify" data-icon="mdi:gift-outline"></span> DAR
                        </button>
                    </div>
                </div>
            `;
            fragment.appendChild(card);
        });

        // Pegamos todo el bloque de 50 coches de golpe (mucho más rápido)
        vehListContainer.appendChild(fragment);

        // Actualizamos el contador
        loadedCount += nextBatch.length;
    }

    // Función Global Spawn
    window.spawnVehicle = (model) => {
        fetch(`https://${GetParentResourceName()}/spawnVehicle`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ model: model })
        });
    };

    // 5. BUSCADOR INTELIGENTE
    if (vehSearchInput) {
        vehSearchInput.addEventListener('input', (e) => {
            const text = e.target.value.toLowerCase();

            // Si está vacío, le pasamos TODOS los coches a renderVehicleList
            if (text === "") {
                renderVehicleList(allVehicles);
                return;
            }

            // Si hay texto, filtramos sobre la lista MAESTRA (allVehicles)
            const filtered = allVehicles.filter(v =>
                (v.name && v.name.toLowerCase().includes(text)) ||
                (v.brand && v.brand.toLowerCase().includes(text)) ||
                (v.category && v.category.toLowerCase().includes(text)) ||
                (v.model && v.model.toLowerCase().includes(text)) ||
                (v.price && v.price.toString().includes(text))
            );

            // Renderizamos la lista filtrada (también se cargará de 50 en 50 si hay muchos resultados)
            renderVehicleList(filtered);
        });
    }

    // Botón limpiar
    const btnClearVeh = document.getElementById('btn-clear-veh');
    if (btnClearVeh) {
        btnClearVeh.addEventListener('click', () => {
            vehSearchInput.value = '';
            renderVehicleList(allVehicles);
        });
    }

    // ==========================================================================
    // MÓDULO: ÍTEMS (LAZY LOAD + GRID 2x2)
    // ==========================================================================
    const itemListContainer = document.getElementById('item-list-container');
    const itemSearchInput = document.getElementById('item-search-input');

    // Variables Lazy Load Items
    let allItems = [];
    let currentItemList = [];
    let itemsLoadedCount = 0;
    const ITEM_BATCH_SIZE = 50;
    let itemsDataLoaded = false;

    // 1. LISTENER DE SCROLL INFINITO
    if (itemListContainer) {
        itemListContainer.addEventListener('scroll', () => {
            if (itemListContainer.scrollTop + itemListContainer.clientHeight >= itemListContainer.scrollHeight - 100) {
                loadNextItemBatch();
            }
        });
    }

    // 2. ACTIVAR PESTAÑA
    const itemTabBtn = document.querySelector('.tab[data-tab="items"]');
    if (itemTabBtn) {
        itemTabBtn.addEventListener('click', () => {
            if (!itemsDataLoaded) {
                itemListContainer.innerHTML = `
                    <div style="grid-column: 1/-1; text-align:center; color:#666; padding:40px; display:flex; flex-direction:column; align-items:center; gap:10px;">
                        <span class="iconify" data-icon="mdi:loading" data-rotate="360deg" style="font-size:30px; color:var(--primary);"></span>
                        <span>Cargando inventario...</span>
                    </div>`;
                fetch(`https://${GetParentResourceName()}/requestItems`, { method: 'POST' });
            }
        });
    }

    // 3. FUNCIÓN AUXILIAR FORMATEO PESO
    function formatWeight(weight) {
        if (!weight) return "0 g";
        if (weight >= 1000) {
            let kg = (weight / 1000).toFixed(2);
            return parseFloat(kg) + ' Kg';
        } else {
            return weight + ' g';
        }
    }

    // 4. RENDERIZADO PRINCIPAL
    function renderItemList(list) {
        if (!itemListContainer) return;

        currentItemList = list;
        itemsLoadedCount = 0;
        itemListContainer.innerHTML = '';

        if (!list || list.length === 0) {
            itemListContainer.innerHTML = '<div style="grid-column:1/-1; padding:40px; text-align:center; color:#666; font-style:italic;">No se encontraron ítems.</div>';
            return;
        }

        loadNextItemBatch(); // Cargar primeros 50
        itemListContainer.scrollTop = 0;
    }

    // 5. CARGA POR LOTES (LAZY)
    function loadNextItemBatch() {
        if (itemsLoadedCount >= currentItemList.length) return;

        const nextBatch = currentItemList.slice(itemsLoadedCount, itemsLoadedCount + ITEM_BATCH_SIZE);
        const fragment = document.createDocumentFragment();

        nextBatch.forEach(item => {
            const card = document.createElement('div');
            card.className = 'veh-card';

            // Datos básicos
            const label = item.label || item.name;
            const code = item.name;
            const weight = item.weight ? item.weight : 0;
            // Recortar descripción solo si es EXTREMADAMENTE larga (+100 caracteres), si no, dejarla entera
            let desc = item.description || "Sin descripción";
            if (desc.length > 150) desc = desc.substring(0, 150) + "...";

            // ... dentro del bucle nextBatch.forEach ...

            // 1. DEFINIR COLUMNAS DINÁMICAS
            // Si tiene munición (es arma) usamos 3 columnas. Si no, 2 columnas.
            const gridStyle = item.ammoType
                ? 'grid-template-columns: 1fr 1fr 1fr;'
                : 'grid-template-columns: 1fr 1fr;';

            // 2. PREPARAR HTML DE MUNICIÓN (Si existe)
            let ammoHtml = '';
            if (item.ammoType) {
                let cleanAmmo = item.ammoType.replace('AMMO_', '');
                // Cajita central con estilo anaranjado
                ammoHtml = `
                <div class="veh-info-box" style="border-color: rgba(255, 165, 0, 0.3); background: rgba(255, 165, 0, 0.05);">
                    <span class="veh-label" style="color: #ffb74d;">MUNICIÓN</span>
                    <span class="veh-value" style="color: #fff; font-size: 11px;">${cleanAmmo}</span>
                </div>`;
            }

            // HTML ESTRUCTURADO
            card.innerHTML = `
                <div class="veh-header">
                    <div class="veh-title" title="${label}">${label}</div>
                    <span class="iconify" data-icon="${item.type === 'weapon' ? 'mdi:pistol' : 'mdi:cube-outline'}" style="color:#555; font-size:18px;"></span>
                </div>
                
                <div class="veh-body" style="display: flex; flex-direction: column; flex: 1; height: 100%;">
                    
                    <div class="veh-info-grid" style="${gridStyle} gap: 5px;">
                        
                        <div class="veh-info-box">
                            <span class="veh-label">PESO</span>
                            <span class="veh-value val-brand">${formatWeight(weight)}</span>
                        </div>
                        
                        ${ammoHtml}

                        <div class="veh-info-box">
                            <span class="veh-label">CÓDIGO</span>
                            <span class="veh-value val-code" style="font-size:11px;">${code}</span>
                        </div>
                        
                        <div class="veh-info-box" style="grid-column: 1 / -1; height: 80px; overflow: hidden; display:block; padding: 8px;">
                            <span class="veh-label">DESCRIPCIÓN</span>
                            <span class="veh-value" title="${item.description}" style="white-space: normal; line-height: 1.4; font-size: 11px; color: #ccc; display: block;">
                                ${desc}
                            </span>
                        </div>
                    </div>

                    <div class="veh-actions" style="margin-top: auto; padding-top: 10px;">
                        <button class="btn-spawn" onclick="spawnItem('${code}')" title="Darmelo a mí">
                            <span class="iconify" data-icon="mdi:download"></span> SACAR
                        </button>
                        
                        <button class="btn-give" onclick="openGiveItemModal('${code}', '${label}', '${item.type}', '${item.ammoType || ''}')" title="Dar a otro jugador">
                            <span class="iconify" data-icon="mdi:gift-outline"></span> DAR
                        </button>
                    </div>
                </div>
            `;
            fragment.appendChild(card);

            // ... fin del bucle ...
        });

        itemListContainer.appendChild(fragment);
        itemsLoadedCount += nextBatch.length;
    }

    // 6. SPAWN ACTION
    window.spawnItem = (itemName) => {
        fetch(`https://${GetParentResourceName()}/spawnItem`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ name: itemName })
        });
    };

    // 7. BUSCADOR
    if (itemSearchInput) {
        itemSearchInput.addEventListener('input', (e) => {
            const text = e.target.value.toLowerCase();

            if (text === "") {
                renderItemList(allItems);
                return;
            }

            const filtered = allItems.filter(i =>
                (i.label && i.label.toLowerCase().includes(text)) ||
                (i.name && i.name.toLowerCase().includes(text)) ||
                (i.description && i.description.toLowerCase().includes(text)) ||
                (i.weight && i.weight.toString().includes(text))
            );

            renderItemList(filtered);
        });
    }

    document.getElementById('btn-clear-items').addEventListener('click', () => {
        itemSearchInput.value = '';
        renderItemList(allItems);
    });

    // DAR ÍTEM A OTRO JUGADOR (MODAL)
    const giModal = document.getElementById('give-item-modal');
    const giItemName = document.getElementById('gi-item-name');
    const giAmount = document.getElementById('gi-amount');
    const giAmmoGroup = document.getElementById('gi-ammo-group');
    const giAmmoCheck = document.getElementById('gi-ammo-check');

    // Variables del Item Seleccionado
    let currentGiveItem = { code: null, type: null, ammo: null };

    // Select de Jugadores
    const wrapGiPlayer = document.getElementById('wrap-gi-player');
    const trigGiPlayer = document.getElementById('trig-gi-player');
    const optsGiPlayer = document.getElementById('opts-gi-player');
    const valGiPlayer = document.getElementById('val-gi-player');

    // 1. ABRIR MODAL
    window.openGiveItemModal = (code, label, type, ammoType) => {
        currentGiveItem = { code, type, ammo: ammoType };

        // Resetear visuales
        if (giItemName) giItemName.innerText = label;
        if (giAmount) giAmount.value = 1;
        if (giAmmoCheck) giAmmoCheck.checked = false;

        // Configurar Select Jugador (Reset)
        if (valGiPlayer) valGiPlayer.value = "";
        if (trigGiPlayer) trigGiPlayer.querySelector('span').innerText = "Seleccionar Jugador...";

        // Mostrar/Ocultar opción de munición
        if (giAmmoGroup) {
            if (type === 'weapon') {
                giAmmoGroup.style.display = 'flex'; // Es arma: mostrar toggle
            } else {
                giAmmoGroup.style.display = 'none'; // Es item: ocultar
            }
        }

        populateGivePlayers(); // Rellenar lista con los conectados
        if (giModal) giModal.style.display = 'flex';
    };

    window.closeGiveItemModal = () => {
        if (giModal) giModal.style.display = 'none';
        if (wrapGiPlayer) wrapGiPlayer.classList.remove('open');
    };

    // 2. RELLENAR SELECT DE JUGADORES (Usa la variable global allPlayers)
    function populateGivePlayers() {
        if (!optsGiPlayer) return;
        optsGiPlayer.innerHTML = '';

        // Ordenar alfabéticamente
        const sorted = [...allPlayers].sort((a, b) => a.id - b.id);

        sorted.forEach(p => {
            const option = document.createElement('span');
            option.className = 'custom-option';
            // Formato: [ID] Nombre (Personaje)
            option.innerHTML = `<span style="color:var(--primary); font-weight:bold;">[${p.id}]</span> ${p.name} <small style="color:#888;">(${p.charName})</small>`;

            option.addEventListener('click', () => {
                if (valGiPlayer) valGiPlayer.value = p.id;
                if (trigGiPlayer) trigGiPlayer.querySelector('span').innerText = `[${p.id}] ${p.name}`;
                if (wrapGiPlayer) wrapGiPlayer.classList.remove('open');
            });
            optsGiPlayer.appendChild(option);
        });
    }

    // Toggle del Select
    if (trigGiPlayer) {
        trigGiPlayer.addEventListener('click', (e) => {
            wrapGiPlayer.classList.toggle('open');
            e.stopPropagation();
        });
    }

    // 3. BOTÓN CONFIRMAR ENVÍO
    const btnConfirmGive = document.getElementById('btn-confirm-give');
    if (btnConfirmGive) {
        btnConfirmGive.addEventListener('click', () => {
            const targetId = valGiPlayer ? valGiPlayer.value : null;
            const amount = giAmount ? parseInt(giAmount.value) : 1;
            const withAmmo = giAmmoCheck ? giAmmoCheck.checked : false;

            if (!targetId) {
                // Pequeña animación de error si no hay jugador
                wrapGiPlayer.style.border = "1px solid red";
                setTimeout(() => wrapGiPlayer.style.border = "", 500);
                return;
            }
            if (amount <= 0) return;

            // Enviar al Lua
            fetch(`https://${GetParentResourceName()}/giveItemToPlayer`, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({
                    targetId: targetId,
                    item: currentGiveItem.code,
                    amount: amount,
                    type: currentGiveItem.type,
                    withAmmo: withAmmo, // true/false
                    ammoType: currentGiveItem.ammo // Código de la munición (AMMO_PISTOL, etc)
                })
            });

            closeGiveItemModal();
        });
    }

    // 4. CORRECCIÓN DEL TOGGLE DE MUNICIÓN
    if (giAmmoGroup && giAmmoCheck) {
        giAmmoGroup.addEventListener('click', (e) => {
            if (e.target.closest('.switch')) return;
            giAmmoCheck.checked = !giAmmoCheck.checked;
        });
    }

    // =========================================================
    // LÓGICA DAR VEHÍCULO (DP-GARAGES INTEGRATION)
    // =========================================================

    const gvModal = document.getElementById('give-vehicle-modal');
    const gvName = document.getElementById('gv-vehicle-name');
    const gvModel = document.getElementById('gv-vehicle-model');
    let currentVehicleToGive = { model: null, name: null };

    // Selectores Jugador
    const wrapGvPlayer = document.getElementById('wrap-gv-player');
    const trigGvPlayer = document.getElementById('trig-gv-player');
    const optsGvPlayer = document.getElementById('opts-gv-player');
    const valGvPlayer = document.getElementById('val-gv-player');

    // Selectores Garaje
    const wrapGvGarage = document.getElementById('wrap-gv-garage');
    const trigGvGarage = document.getElementById('trig-gv-garage');
    const optsGvGarage = document.getElementById('opts-gv-garage');
    const valGvGarage = document.getElementById('val-gv-garage');

    // LISTA DE GARAJES (Actualizada con tus datos)
    // El 'id' debe coincidir con la clave de la base de datos (lo que está entre corchetes ['...'])
    const availableGarages = [
        { id: 'PinkCage Motel', label: 'PinkCage Motel' },
        { id: 'Casino', label: 'Casino' },
        { id: 'North Rockford Drive', label: 'North Rockford Drive' },
        { id: 'Spanish Ave', label: 'Spanish Ave' },
        { id: 'Clinton Ave', label: 'Clinton Ave' },
        { id: 'Airport', label: 'Airport' },
        { id: 'Magellan Ave', label: 'Magellan Ave' },
        { id: 'Rute 68', label: 'Rute 68' },
        { id: 'Sandy Shore', label: 'Sandy Shore' },
        { id: 'Paleto Bay', label: 'Paleto Bay' },
        { id: 'Pillbox Hill', label: 'Pillbox Hill' },
        { id: 'Grapeseed', label: 'Grapeseed' },
        { id: 'Legion', label: 'Garaje Central (Legion)' } // Añado este por si acaso, suele ser común
    ];

    // 1. ABRIR MODAL
    window.openGiveVehicleModal = (model, name) => {
        currentVehicleToGive = { model, name };

        // Reset Visual
        if (gvName) gvName.innerText = name;
        if (gvModel) gvModel.innerText = model;

        // Reset Selects
        if (valGvPlayer) valGvPlayer.value = "";
        if (trigGvPlayer) trigGvPlayer.querySelector('span').innerText = "Seleccionar Jugador...";

        if (valGvGarage) valGvGarage.value = "";
        if (trigGvGarage) trigGvGarage.querySelector('span').innerText = "Seleccionar Garaje...";

        // Rellenar listas
        populateGvPlayers();
        populateGvGarages();

        if (gvModal) gvModal.style.display = 'flex';
    };

    window.closeGiveVehicleModal = () => {
        if (gvModal) gvModal.style.display = 'none';
        if (wrapGvPlayer) wrapGvPlayer.classList.remove('open');
        if (wrapGvGarage) wrapGvGarage.classList.remove('open');
    };

    // 2. POBLAR JUGADORES (Copia lógica de Items pero para este modal)
    function populateGvPlayers() {
        if (!optsGvPlayer) return;
        optsGvPlayer.innerHTML = '';
        const sorted = [...allPlayers].sort((a, b) => a.id - b.id);

        sorted.forEach(p => {
            const div = document.createElement('div');
            div.className = 'custom-option';
            div.innerHTML = `<span style="color:var(--primary); font-weight:bold;">[${p.id}]</span> ${p.name}`;

            div.addEventListener('click', () => {
                valGvPlayer.value = p.id;
                trigGvPlayer.querySelector('span').innerText = `[${p.id}] ${p.name}`;
                wrapGvPlayer.classList.remove('open');
            });
            optsGvPlayer.appendChild(div);
        });
    }

    // 3. POBLAR GARAJES (Dinámico)
    function populateGvGarages() {
        if (!optsGvGarage) return;
        optsGvGarage.innerHTML = '';

        availableGarages.forEach(g => {
            const div = document.createElement('div');
            div.className = 'custom-option';
            div.innerHTML = `<span class="iconify" data-icon="mdi:garage"></span> ${g.label}`;

            div.addEventListener('click', () => {
                valGvGarage.value = g.id;
                trigGvGarage.querySelector('span').innerText = g.label;
                wrapGvGarage.classList.remove('open');
            });
            optsGvGarage.appendChild(div);
        });
    }

    // Toggles de los selects
    if (trigGvPlayer) {
        trigGvPlayer.addEventListener('click', (e) => {
            wrapGvPlayer.classList.toggle('open');
            wrapGvGarage.classList.remove('open'); // Cerrar el otro si está abierto
            e.stopPropagation();
        });
    }
    if (trigGvGarage) {
        trigGvGarage.addEventListener('click', (e) => {
            wrapGvGarage.classList.toggle('open');
            wrapGvPlayer.classList.remove('open');
            e.stopPropagation();
        });
    }

    // 4. BOTÓN CONFIRMAR ENVÍO
    const btnConfirmGiveCar = document.getElementById('btn-confirm-give-vehicle');
    if (btnConfirmGiveCar) {
        btnConfirmGiveCar.addEventListener('click', () => {
            const targetId = valGvPlayer.value;
            const garageId = valGvGarage.value;

            if (!targetId) {
                wrapGvPlayer.style.border = "1px solid red";
                setTimeout(() => wrapGvPlayer.style.border = "", 500);
                return;
            }
            if (!garageId) {
                wrapGvGarage.style.border = "1px solid red";
                setTimeout(() => wrapGvGarage.style.border = "", 500);
                return;
            }

            // Enviar al servidor
            fetch(`https://${GetParentResourceName()}/giveVehicleToPlayer`, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({
                    targetId: targetId,
                    model: currentVehicleToGive.model,
                    garage: garageId
                })
            }).then(resp => resp.json()).then(resp => {
                if (resp === 'ok') closeGiveVehicleModal();
            });
        });
    }

    // =========================================================
    // LÓGICA DE LA PÁGINA STATUS (DASHBOARD)
    // =========================================================

    function loadStatusPage() {
        // 1. Pedir datos al servidor
        fetch(`https://${GetParentResourceName()}/getStatusData`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({})
        }).then(resp => resp.json()).then(data => {
            updateStatusUI(data);
        });
    }

    function updateStatusUI(data) {
        // A. Actualizar Tarjetas Superiores
        const statPlayers = document.getElementById('stat-players');
        const statAdmins = document.getElementById('stat-admins');
        const statUptime = document.getElementById('stat-uptime');
        const statReports = document.getElementById('stat-reports');
        const btnStaffMode = document.getElementById('dash-staffmode');

        // SINCRONIZAR BOTÓN STAFF MODE
        if (btnStaffMode && data.myStaffMode !== undefined) {
            btnStaffMode.checked = data.myStaffMode;
        }

        // Si el servidor envía los estados globales, actualizamos los interruptores
        if (data.serverStates) {
            const btnWhitelist = document.getElementById('dash-whitelist');
            const btnMaint = document.getElementById('dash-maintenance');
            const btnDiscord = document.getElementById('dash-discord');

            if (btnWhitelist) btnWhitelist.checked = data.serverStates.whitelist;
            if (btnMaint) btnMaint.checked = data.serverStates.maintenance;
            if (btnDiscord) btnDiscord.checked = data.serverStates.discord_logs;
        }

        if (statPlayers) {
            // Truco visual: Si data.players viene 0 pero tú estás dentro, mostramos 1
            let displayPlayers = parseInt(data.players) || 1;
            statPlayers.innerText = `${displayPlayers} / ${data.maxPlayers}`;
        }
        if (statAdmins) statAdmins.innerText = data.admins;
        if (statUptime) statUptime.innerText = data.uptime;
        if (statReports) statReports.innerText = data.reportsCount;


        // B. Actualizar Tabla de Logs (MEJORADO: VISUALIZACIÓN DUAL)
        const logsBody = document.getElementById('logs-body');
        if (logsBody) {
            logsBody.innerHTML = ''; // Limpiar

            if (!data.logs || data.logs.length === 0) {
                logsBody.innerHTML = '<tr><td colspan="4" style="text-align:center; padding:20px; color:#666;">Sin actividad reciente.</td></tr>';
            } else {
                // Rellenar filas
                data.logs.forEach(log => {
                    const tr = document.createElement('tr');

                    let badgeClass = 'log-action-badge';
                    if (log.action.includes('BAN')) badgeClass += ' log-action-ban';
                    else if (log.action.includes('SPAWN')) badgeClass += ' log-action-spawn';
                    else if (log.action.includes('REVIVE') || log.action.includes('HEAL')) badgeClass += ' log-action-revive';

                    const dateObj = new Date(log.date);
                    const timeStr = dateObj.toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' });

                    // --- LÓGICA DE NOMBRE DUAL ---
                    let adminDisplayHtml = log.admin_name; // Por defecto el texto plano (logs viejos)

                    // Intentamos leer si es el nuevo formato JSON {"steam":..., "char":...}
                    if (log.admin_name && (log.admin_name.startsWith('{') || log.admin_name.startsWith('['))) {
                        try {
                            const nameObj = JSON.parse(log.admin_name);
                            if (nameObj.steam && nameObj.char) {
                                // AQUÍ ESTÁ EL DISEÑO QUE PEDISTE:
                                adminDisplayHtml = `
                                    <div style="display:flex; flex-direction:column; line-height:1.2;">
                                        <span style="color: var(--primary); font-weight:bold; font-size:13px;">${nameObj.steam}</span>
                                        <span style="font-size: 10px; color: #777;">(${nameObj.char})</span>
                                    </div>
                                `;
                            }
                        } catch (e) {
                            // Si falla, se queda el texto original
                        }
                    } else {
                        // Si es texto plano (logs antiguos), lo ponemos azul por defecto
                        adminDisplayHtml = `<span style="font-weight:bold; color:var(--primary);">${log.admin_name}</span>`;
                    }
                    // -----------------------------

                    tr.innerHTML = `
                        <td>${adminDisplayHtml}</td>
                        <td><span class="${badgeClass}">${log.action}</span></td>
                        <td style="color:#aaa;">${log.details}</td>
                        <td style="text-align:right; font-family:monospace;">${timeStr}</td>
                    `;
                    logsBody.appendChild(tr);
                });
            }
        }

        // C. Actualizar Gráfica de Jugadores (AQUÍ ESTÁ LA CLAVE)
        if (data.stats) {
            log("JS: Recibidos stats para gráfica:", data.stats.length);

            // 1. Inicializamos la gráfica si no existe
            if (!activityChartInstance) {
                initPlayerChart();
            }

            // 2. Procesamos los datos (Esto llama a updateChart internamente)
            processStatsData(data.stats);
        }
    }

    // Función para el botón de refrescar manual
    window.refreshLogs = () => {
        loadStatusPage();
    };

    let activityChartInstance = null;
    let rawStatsData = [];
    let currentMetric = 'players'; // 'players', 'admins', 'reports'

    // Configuración de colores para cada métrica
    const metricConfig = {
        players: {
            label: 'Jugadores',
            color: '#00d2ff', // Cyan
            bg: 'rgba(0, 210, 255, 0.15)',
            title: 'FLUJO DE JUGADORES',
            icon: 'mdi:chart-line'
        },
        admins: {
            label: 'Admins Online',
            color: '#ffa500', // Naranja
            bg: 'rgba(255, 165, 0, 0.15)',
            title: 'ACTIVIDAD DE ADMINS',
            icon: 'mdi:shield-account'
        },
        reports: {
            label: 'Reportes Activos',
            color: '#ff4444', // Rojo
            bg: 'rgba(255, 68, 68, 0.15)',
            title: 'VOLUMEN DE REPORTES',
            icon: 'mdi:bug'
        }
    };

    function initPlayerChart() {
        const ctx = document.getElementById('playerActivityChart');
        if (!ctx) return;

        if (activityChartInstance) {
            activityChartInstance.destroy();
        }

        activityChartInstance = new Chart(ctx, {
            type: 'line',
            data: {
                labels: [],
                datasets: [{
                    label: 'Cantidad',
                    data: [],
                    borderColor: metricConfig.players.color,
                    backgroundColor: metricConfig.players.bg,
                    borderWidth: 2,
                    pointRadius: 3,
                    pointBackgroundColor: '#1a1a1a',
                    pointBorderColor: metricConfig.players.color,
                    tension: 0.3,
                    fill: true
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                animation: { duration: 750 },
                plugins: {
                    legend: { display: false },
                    tooltip: {
                        mode: 'index',
                        intersect: false,
                        backgroundColor: 'rgba(20, 20, 20, 0.9)',
                        titleColor: '#fff',
                        bodyColor: '#ccc',
                        borderColor: 'rgba(255,255,255,0.1)',
                        borderWidth: 1
                    }
                },
                scales: {
                    x: {
                        grid: { display: false },
                        ticks: { color: '#888', font: { size: 10 }, maxTicksLimit: 7 }
                    },
                    y: {
                        grid: { color: 'rgba(255,255,255,0.05)' },
                        ticks: { color: '#888', font: { size: 10 }, beginAtZero: true, precision: 0 }
                    }
                }
            }
        });
    }

    // 1. FUNCIÓN PARA CAMBIAR ENTRE JUGADORES / ADMINS / REPORTES (Click en Cards)
    window.switchMetric = (metric, cardElement) => {
        // Evitar recargar si ya estamos en esa métrica
        if (currentMetric === metric) return;

        currentMetric = metric;

        // A. Actualizar visualmente las Cards (Borde brillante)
        document.querySelectorAll('.stat-card').forEach(c => c.classList.remove('active-metric'));
        if (cardElement) cardElement.classList.add('active-metric');

        // B. Actualizar Título e Icono de la Gráfica
        const headerTitle = document.getElementById('chart-header-text');
        const headerIcon = document.getElementById('chart-header-icon');
        const conf = metricConfig[metric];

        if (headerTitle) headerTitle.innerText = conf.title;
        if (headerIcon) headerIcon.setAttribute('data-icon', conf.icon);

        // C. Refrescar la gráfica con los nuevos datos
        // Mantenemos el periodo de tiempo que ya estaba activo (daily, weekly...)
        const activeTimeBtn = document.querySelector('.chart-btn.active');
        const timeType = activeTimeBtn ? activeTimeBtn.getAttribute('onclick').match(/'([^']+)'/)[1] : 'daily';

        updateChart(timeType, activeTimeBtn);
    };

    function processStatsData(stats) {
        if (!stats) stats = [];
        rawStatsData = stats;

        // Al cargar por primera vez, forzamos actualización
        const activeBtn = document.querySelector('.chart-btn.active') || document.querySelector('.chart-btn');
        const type = activeBtn ? activeBtn.getAttribute('onclick').match(/'([^']+)'/)[1] : 'daily';

        updateChart(type, activeBtn);
    }

    // 2. FUNCIÓN DE FILTRADO Y ACTUALIZACIÓN (Timeframe + Metric)
    window.updateChart = (timeframe, btn) => {
        if (btn) {
            document.querySelectorAll('.chart-btn').forEach(b => b.classList.remove('active'));
            btn.classList.add('active');
        }

        if (!activityChartInstance) initPlayerChart();

        const now = new Date();
        const currentTimestamp = Math.floor(now.getTime() / 1000);

        let filteredData = [];
        let labels = [];
        let counts = [];

        // --- FILTRADO DE TIEMPO ---
        if (timeframe === 'daily') {
            const cutoff = currentTimestamp - 86400; // 24h
            filteredData = rawStatsData.filter(d => parseInt(d.date) >= cutoff);

            filteredData.forEach(d => {
                const date = new Date(d.date * 1000);
                const h = date.getHours().toString().padStart(2, '0');
                const m = date.getMinutes().toString().padStart(2, '0');
                labels.push(`${h}:${m}`);

                // AQUÍ ELEGIMOS QUÉ DATO GUARDAR SEGÚN LA MÉTRICA ACTIVA
                if (currentMetric === 'players') counts.push(d.player_count);
                else if (currentMetric === 'admins') counts.push(d.admin_count);
                else if (currentMetric === 'reports') counts.push(d.report_count);
            });

        } else if (timeframe === 'weekly') {
            const cutoff = currentTimestamp - (7 * 86400); // 7 dias
            filteredData = rawStatsData.filter(d => parseInt(d.date) >= cutoff);

            filteredData.forEach(d => {
                const date = new Date(d.date * 1000);
                const days = ['Dom', 'Lun', 'Mar', 'Mie', 'Jue', 'Vie', 'Sab'];
                const dayName = days[date.getDay()];
                const h = date.getHours();
                labels.push(`${dayName} ${h}:00`);

                if (currentMetric === 'players') counts.push(d.player_count);
                else if (currentMetric === 'admins') counts.push(d.admin_count);
                else if (currentMetric === 'reports') counts.push(d.report_count);
            });

        } else if (timeframe === 'monthly') {
            filteredData = rawStatsData; // Todos los datos disponibles (30 días)

            filteredData.forEach(d => {
                const date = new Date(d.date * 1000);
                const day = date.getDate().toString().padStart(2, '0');
                const month = (date.getMonth() + 1).toString().padStart(2, '0');
                labels.push(`${day}/${month}`);

                if (currentMetric === 'players') counts.push(d.player_count);
                else if (currentMetric === 'admins') counts.push(d.admin_count);
                else if (currentMetric === 'reports') counts.push(d.report_count);
            });
        }

        // --- MANEJO DE DATOS VACÍOS ---
        if (counts.length === 0) {
            labels = ["Sin Datos"];
            counts = [0];
        }

        // --- APLICAR ESTILOS Y DATOS ---
        const conf = metricConfig[currentMetric];

        // Actualizamos Colores
        activityChartInstance.data.datasets[0].borderColor = conf.color;
        activityChartInstance.data.datasets[0].backgroundColor = conf.bg;
        activityChartInstance.data.datasets[0].pointBorderColor = conf.color;
        activityChartInstance.data.datasets[0].label = conf.label;

        // Actualizamos Datos
        activityChartInstance.data.labels = labels;
        activityChartInstance.data.datasets[0].data = counts;

        activityChartInstance.update();
    };

    // Función llamada al cambiar cualquier interruptor del dashboard (Staff Mode, Whitelist...)
    window.toggleServerOption = (option, isActive) => {

        // ============================================================
        // 1. INTERCEPTOR DE SEGURIDAD (SOLO PARA WHITELIST)
        // ============================================================
        if (option === 'whitelist') {
            // A. FRENADO VISUAL: Revertimos el switch inmediatamente para que parezca que no se movió
            const switchEl = document.getElementById('dash-whitelist');
            if (switchEl) switchEl.checked = !isActive;

            // B. DEFINIR MENSAJE SEGÚN ACTIVAR O DESACTIVAR
            // Usamos HTML para que se vea bonito y claro en el modal
            const msg = isActive
                ? `<span style="color:#ff4444; font-weight:bold; font-size:18px;">⚠️ ¿ACTIVAR WHITELIST GLOBAL?</span><br><br>
                   <ul style="text-align:left; font-size:14px; color:#ccc; margin-left:15px; line-height: 1.6;">
                        <li>Se <b>expulsará</b> a todos los jugadores sin permisos.</li>
                        <li>El servidor quedará <b>bloqueado</b> para usuarios normales.</li>
                        <li>Se enviará un aviso de <b>60 segundos</b> antes del cierre.</li>
                   </ul>`
                : `<span style="color:#00C851; font-weight:bold; font-size:18px;">🔓 ¿DESACTIVAR WHITELIST?</span><br><br>
                   <div style="color:#ccc; font-size:14px;">El servidor volverá a ser público y accesible para todos los jugadores.</div>`;

            // C. PEDIR CONFIRMACIÓN AL ADMIN
            showConfirmationModal(msg, () => {
                // SI PULSA "CONFIRMAR":

                // 1. Ponemos el switch visualmente en la posición deseada (ahora sí)
                if (switchEl) switchEl.checked = isActive;

                // 2. Ejecutamos la lógica real de envío al servidor
                executeServerOption(option, isActive);
            });

            // IMPORTANTE: Detenemos la función aquí con 'return'. 
            // Si el usuario cancela o cierra el modal, no se ejecuta nada más.
            return;
        }

        // ============================================================
        // 2. SI NO ES WHITELIST, EJECUTAR DIRECTAMENTE
        // ============================================================
        executeServerOption(option, isActive);
    };

    // Función auxiliar para no repetir código (Tu lógica original encapsulada)
    function executeServerOption(option, isActive) {
        // 1. ACTUALIZACIÓN VISUAL INSTANTÁNEA (Staff Mode)
        if (option === 'staff_mode') {
            const adminCounter = document.getElementById('stat-admins');
            if (adminCounter) {
                let currentCount = parseInt(adminCounter.innerText) || 0;
                if (isActive) {
                    currentCount++;
                } else {
                    currentCount = Math.max(0, currentCount - 1);
                }
                adminCounter.innerText = currentCount;
            }
        }

        // 2. ENVIAR CAMBIO AL SERVIDOR
        // Respetando tu URL 'https://dp-adminmenu/...'
        fetch(`https://dp-adminmenu/toggleServerOption`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({
                option: option,
                state: isActive
            })
        });
    }

    // ==========================================================================
    // SISTEMA AVANZADO DE CHAT (PREVIEW + UPLOAD)
    // ==========================================================================

    // 1. Añadir imagen a la cola (Se llama al pegar)
    function addAttachment(file) {
        if (pendingAttachments.length >= MAX_ATTACHMENTS) {
            // Puedes poner un sonido de error aquí si quieres
            log("Límite de imágenes alcanzado");
            return;
        }
        pendingAttachments.push(file);
        renderAttachments();
    }

    // 2. Eliminar imagen de la cola (Botón X) - HACERLA GLOBAL
    window.removeAttachment = function (index) {
        pendingAttachments.splice(index, 1);
        renderAttachments();
    }

    // 3. Renderizar la zona de previsualización (HTML)
    function renderAttachments() {
        const container = document.getElementById('chat-attachments-area');
        container.innerHTML = ''; // Limpiar zona

        if (pendingAttachments.length === 0) {
            container.style.display = 'none';
            return;
        }

        container.style.display = 'flex'; // Mostrar zona

        pendingAttachments.forEach((file, index) => {
            const url = URL.createObjectURL(file); // Crear URL temporal local

            const itemDiv = document.createElement('div');
            itemDiv.className = 'att-item';
            itemDiv.innerHTML = `
            <img src="${url}" onclick="openImageModal('${url}')" style="cursor:pointer;" title="Ver en grande">
            <button class="att-remove" onclick="event.stopPropagation(); removeAttachment(${index})">✕</button>
        `;
            container.appendChild(itemDiv);
        });
    }

    // 4. Subir imagen a Discord y obtener URL (Magia negra)
    async function uploadImageToDiscord(file) {
        const formData = new FormData();
        formData.append('file', file);

        // IMPORTANTE: Añadimos ?wait=true para que Discord nos devuelva el JSON con la URL
        try {
            const response = await fetch(discordWebhook + "?wait=true", {
                method: 'POST',
                body: formData
            });

            if (!response.ok) throw new Error('Error subiendo imagen');

            const data = await response.json();
            // Discord devuelve un objeto Message con un array 'attachments'
            if (data.attachments && data.attachments.length > 0) {
                return data.attachments[0].url; // Retornamos la URL permanente
            }
        } catch (error) {
            console.error("Fallo al subir imagen:", error);
            return null;
        }
        return null;
    }

    // 5. FUNCIÓN PRINCIPAL DE ENVÍO (Maneja Texto + Fotos)
    async function handleChatSend() {
        const input = document.getElementById('chat-input-text');
        const msgText = input.value.trim();
        const btn = document.getElementById('btn-chat-send');

        // Validar: Debe haber texto O imágenes pendientes
        if (!msgText && pendingAttachments.length === 0) return;

        // Bloqueo visual (Loading...)
        if (btn) {
            const originalIcon = btn.innerHTML;
            btn.disabled = true;
            btn.innerHTML = '<span class="iconify" data-icon="eos-icons:loading"></span>';
        }

        let finalImageUrls = [];

        // 1. SI HAY FOTOS, SUBIRLAS PRIMERO A DISCORD
        if (pendingAttachments.length > 0) {
            // Usamos Promise.all para subirlas todas en paralelo (más rápido)
            const uploadPromises = pendingAttachments.map(file => uploadImageToDiscord(file));
            const results = await Promise.all(uploadPromises);

            // Filtramos las que hayan fallado (null) y nos quedamos con las URLs
            finalImageUrls = results.filter(url => url !== null);
        }

        // 2. ENVIAR DATOS AL LUA (SERVIDOR)
        // Enviamos el mensaje Y el array de fotos
        fetch(`https://${GetParentResourceName()}/sendAdminMessage`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({
                message: msgText,
                images: finalImageUrls
            })
        });

        // 3. LIMPIEZA
        input.value = '';
        pendingAttachments = []; // Vaciar array de fotos pendientes
        renderAttachments(); // Limpiar zona visual de fotos

        // Restaurar botón
        if (btn) {
            btn.disabled = false;
            btn.innerHTML = '<span class="iconify" data-icon="iconoir:send-solid"></span>';
        }
    }

    // ==========================================================================
    //      LISTENER PARA LA TECLA J (Modo Transparente / Cursor)
    // ==========================================================================
    document.addEventListener('keydown', function (event) {
        const menuContainer = document.getElementById('admin-menu');

        // 1. Si el menú está cerrado, no hacemos nada
        if (!menuContainer || menuContainer.style.display === 'none') return;

        // 2. Si escribimos en un input, ignoramos la J
        const activeTag = document.activeElement.tagName;
        if (activeTag === 'INPUT' || activeTag === 'TEXTAREA') return;

        // 3. Detectar tecla J
        if (event.key.toLowerCase() === 'j') {

            // Invertimos el estado
            cursorModeActive = !cursorModeActive;

            // LÓGICA DE OPACIDAD
            if (cursorModeActive) {
                // MODO JUEGO: Hacemos el menú casi transparente (25%)
                menuContainer.style.opacity = '0.5';
            } else {
                // MODO MENÚ: Lo devolvemos al 100%
                menuContainer.style.opacity = '1.0';
            }

            // Avisar a Lua (Esto sigue igual)
            fetch(`https://${GetParentResourceName()}/toggleCursorMode`, {
                method: 'POST',
                body: JSON.stringify({})
            });
        }
    });

    // =========================================
    //      MODALES: VER RANGOS (JOBS/GANGS)
    // =========================================

    // --- LOGICA TRABAJOS (JOBS) ---
    const btnJobAction = document.getElementById('btn-job-action');
    if (btnJobAction) {
        btnJobAction.addEventListener('click', function () {
            renderSimpleJobGrades();
            document.getElementById('job-grades-modal').style.display = 'flex';
        });
    }

    // Renderiza la lista izquierda
    function renderSimpleJobGrades() {
        const container = document.getElementById('job-grades-list-container');
        if (!container) return;
        container.innerHTML = '';

        if (!allJobs || allJobs.length === 0) {
            container.innerHTML = '<div style="padding:20px; text-align:center; color:#666;">No hay datos.</div>';
            return;
        }

        const sortedList = [...allJobs].sort((a, b) => a.label.localeCompare(b.label));

        sortedList.forEach(job => {
            let gradesCount = 0;
            if (job.grades) gradesCount = Object.keys(job.grades).length;

            const row = document.createElement('div');
            row.className = 'accordion-header job-item-row';

            // Evento Click
            row.onclick = function () {
                document.querySelectorAll('.job-item-row').forEach(r => r.classList.remove('active'));
                this.classList.add('active');
                openJobDetailsPanel(job);
            };

            row.innerHTML = `
            <span class="id-badge" style="padding:2px 0; text-transform:none; width:90px; text-align:center; background:#0f3443; color:#4dd0e1; border-radius: 4px; font-family:monospace; font-size:11px;">
                ${job.name}
            </span> 
            <span style="font-weight:600; color:#e0e0e0; font-size: 13px; margin-left: 12px;">
                ${job.label}
            </span>
            <span class="online-count-badge" style="margin-left: auto; background: rgba(255, 165, 0, 0.1); color: #ffa726; border: 1px solid rgba(255, 165, 0, 0.2); font-size:10px; padding: 2px 8px;">
                ${gradesCount} <span class="iconify" data-icon="mdi:chevron-right" style="vertical-align:middle; margin-left:2px;"></span>
            </span>
        `;
            container.appendChild(row);
        });
    }

    // Expande el modal y rellena la derecha
    function openJobDetailsPanel(jobData) {
        const modalBox = document.getElementById('job-modal-box');
        const title = document.getElementById('grade-list-title');
        const container = document.getElementById('specific-grades-list');

        // Título dinámico
        title.innerHTML = `
            <span class="grade-title-prefix">RANGOS DE:</span> 
            <span class="grade-title-job" title="${jobData.label.toUpperCase()}">${jobData.label.toUpperCase()}</span>
        `;

        // Expandir
        modalBox.classList.add('expanded');

        // Limpiar y Rellenar
        container.innerHTML = '';
        let gradesArray = [];
        if (jobData.grades) {
            Object.keys(jobData.grades).forEach(key => {
                const g = jobData.grades[key];
                gradesArray.push({
                    level: parseInt(key),
                    name: g.name || g.label || "Sin Nombre",
                    salary: g.payment || g.salary || 0
                });
            });
        }
        gradesArray.sort((a, b) => a.level - b.level);

        if (gradesArray.length === 0) {
            container.innerHTML = '<div style="padding:30px; color:#666; text-align:center;">Sin rangos configurados.</div>';
        } else {
            gradesArray.forEach(grade => {
                const row = document.createElement('div');
                // Estilo de fila de rango
                row.style.cssText = `
                display: flex; 
                justify-content: space-between; 
                padding: 10px 15px; 
                border-bottom: 1px solid rgba(255,255,255,0.03); 
                align-items: center;
                font-size: 13px;
            `;

                row.innerHTML = `
                <span class="id-badge" style="padding:2px 0; text-transform:none; width:50px; text-align:center; border-radius: 4px; font-family:monospace; font-size:11px;">
                    ${grade.level}
                </span>
                <span style="font-weight:600; color:#e0e0e0; font-size: 13px; margin-left: 12px;">
                    ${grade.name}
                </span>
                <div style="color: #2ecc71; font-family: monospace; font-weight:bold;">
                    $${grade.salary.toLocaleString()}
                </div>
            `;
                container.appendChild(row);
            });
        }
    }

    // Cerrar y Resetear
    window.closeJobGradesModal = function () {
        const modalBox = document.getElementById('job-modal-box');
        const overlay = document.getElementById('job-grades-modal');
        overlay.style.display = 'none';

        setTimeout(() => {
            modalBox.classList.remove('expanded');
            document.querySelectorAll('.job-item-row.active').forEach(r => r.classList.remove('active'));
        }, 100); // Reset rápido al cerrar
    }

    // --- LOGICA BANDAS (GANGS) ---
    const btnGangAction = document.getElementById('btn-gang-action');
    if (btnGangAction) {
        btnGangAction.addEventListener('click', function () {
            renderSimpleGangGrades();
            document.getElementById('gang-grades-modal').style.display = 'flex';
        });
    }

    // 1. Renderiza la lista izquierda (Bandas)
    function renderSimpleGangGrades() {
        const container = document.getElementById('gang-grades-list-container');
        if (!container) return;
        container.innerHTML = '';

        if (!allGangs || allGangs.length === 0) {
            container.innerHTML = '<div style="padding:20px; text-align:center; color:#666;">No hay bandas registradas.</div>';
            return;
        }

        const sortedList = [...allGangs].sort((a, b) => a.label.localeCompare(b.label));

        sortedList.forEach(gang => {
            let gradesCount = 0;
            if (gang.grades) gradesCount = Object.keys(gang.grades).length;

            const row = document.createElement('div');
            row.className = 'accordion-header gang-item-row';

            // Estilos base
            row.style.cssText = `
            padding: 4px 5px; 
            margin-bottom: 5px; 
            border-radius: 4px; 
            cursor: pointer; 
            display: flex; 
            align-items: center;
            border-left: 3px solid transparent;
            transition: all 0.2s ease;
        `;

            // Evento Click
            row.onclick = function () {
                // Limpiamos activos anteriores
                document.querySelectorAll('.gang-item-row').forEach(r => {
                    r.classList.remove('active');
                    r.style.backgroundColor = '';
                    r.style.borderLeft = '3px solid transparent';
                });

                // Activamos este
                this.classList.add('active');
                this.style.backgroundColor = 'rgba(255, 255, 255, 0.08)';
                this.style.borderLeft = '3px solid #d32f2f'; // Borde Rojo activo

                openGangDetailsPanel(gang);
            };

            // HTML INTERNO
            // La etiqueta (Badge) es ROJA (#5a1a1a)
            row.innerHTML = `
            <span class="id-badge" style="padding:2px 0; text-transform:none; width:90px; text-align:center; background:#5a1a1a; color:#ff8a80; border-radius: 4px; font-family:monospace; font-size:11px;">
                ${gang.name}
            </span> 
            
            <span style="font-weight:600; color:#e0e0e0; font-size: 13px; margin-left: 12px;">
                ${gang.label}
            </span>

            <span class="online-count-badge" style="margin-left: auto; background: rgba(211, 47, 47, 0.15); color: #ff5252; border: 1px solid rgba(211, 47, 47, 0.3); font-size:10px; padding: 2px 8px;">
                ${gradesCount} <span class="iconify" data-icon="mdi:chevron-right" style="vertical-align:middle; margin-left:2px;"></span>
            </span>
        `;
            container.appendChild(row);
        });
    }

    // 2. Expande el modal y rellena la derecha (SIN SALARIO y COLOR CORREGIDO)
    function openGangDetailsPanel(gangData) {
        const modalBox = document.getElementById('gang-modal-box');
        const title = document.getElementById('gang-grade-list-title');
        const container = document.getElementById('specific-gang-grades-list');

        // --- CORRECCIÓN DE COLOR ---
        // Usamos 'important' para sobrescribir el azul del CSS de trabajos
        title.style.setProperty('background-color', '#5a1a1a', 'important');
        title.style.setProperty('color', '#ff8a80', 'important');

        // Título dinámico
        title.innerHTML = `
        <span class="grade-title-prefix">RANGOS DE:</span> 
        <span class="grade-title-job" style="color: #ff8a80;" title="${gangData.label.toUpperCase()}">${gangData.label.toUpperCase()}</span>
    `;

        modalBox.classList.add('expanded');

        container.innerHTML = '';
        let gradesArray = [];
        if (gangData.grades) {
            Object.keys(gangData.grades).forEach(key => {
                const g = gangData.grades[key];
                gradesArray.push({
                    level: parseInt(key),
                    name: g.name || g.label || "Sin Nombre"
                });
            });
        }
        gradesArray.sort((a, b) => a.level - b.level);

        if (gradesArray.length === 0) {
            container.innerHTML = '<div style="padding:30px; color:#666; text-align:center;">Sin rangos configurados.</div>';
        } else {
            gradesArray.forEach(grade => {
                const row = document.createElement('div');

                // CSS: Alineado a la izquierda (flex-start)
                row.style.cssText = `
                display: flex; 
                align-items: center; 
                padding: 10px 15px; 
                border-bottom: 1px solid rgba(255,255,255,0.03); 
                font-size: 13px;
            `;

                row.innerHTML = `
                <span class="id-badge" style="padding:2px 0; text-transform:none; width:60px; text-align:center; border-radius: 4px; font-family:monospace; font-size:11px; background:rgba(255,255,255,0.1); color:#fff;">
                    ${grade.level}
                </span>

                <span style="font-weight:600; color:#e0e0e0; font-size: 13px; margin-left: 50px;">
                    ${grade.name}
                </span>
            `;
                container.appendChild(row);
            });
        }
    }

    // 3. Cerrar y Resetear
    window.closeGangGradesModal = function () {
        const modalBox = document.getElementById('gang-modal-box');
        const overlay = document.getElementById('gang-grades-modal');

        overlay.style.display = 'none';

        setTimeout(() => {
            modalBox.classList.remove('expanded');
            // Limpiamos selección visual
            document.querySelectorAll('.gang-item-row.active').forEach(r => {
                r.classList.remove('active');
                r.style.backgroundColor = '';
                r.style.borderLeft = '3px solid transparent';
            });
        }, 100);
    }

    // =========================================
    //      MODAL: SISTEMA "IR A" (GOTO)
    // =========================================

    window.openGotoModal = function () {
        renderGotoCategories();
        document.getElementById('goto-modal').style.display = 'flex';
    }

    function renderGotoCategories() {
        const container = document.getElementById('goto-categories-list');
        container.innerHTML = '';

        Object.keys(gotoLocations).forEach(cat => {
            const row = document.createElement('div');
            row.className = 'accordion-header job-item-row';
            row.style.marginBottom = "5px";

            row.onclick = function () {
                document.querySelectorAll('#goto-categories-list .job-item-row').forEach(r => r.classList.remove('active'));
                this.classList.add('active');
                renderGotoDestinations(cat);
            };

            row.innerHTML = `
            <span class="id-badge" style="background:#0f4324; color:#4de193; width:auto; padding: 0 10px;">${cat}</span>
            <span class="iconify" data-icon="mdi:chevron-right" style="margin-left:auto; color:#4de193;"></span>
        `;
            container.appendChild(row);
        });
    }

    function renderGotoDestinations(category) {
        const modalBox = document.getElementById('goto-modal-box');
        const container = document.getElementById('goto-destinations-list');
        const title = document.getElementById('goto-dest-list-title');

        modalBox.classList.add('expanded');
        title.innerText = category;
        container.innerHTML = '';

        gotoLocations[category].forEach(loc => {
            const row = document.createElement('div');
            row.className = 'job-player-row';
            row.style.cursor = "pointer";
            row.style.padding = "15px";
            row.style.marginBottom = "5px";

            row.onclick = function () {
                fetch(`https://${GetParentResourceName()}/triggerAction`, {
                    method: 'POST',
                    body: JSON.stringify({ action: 'goto_point', coords: loc.coords })
                });
                window.closeGotoModal();
            };

            row.innerHTML = `
            <div class="jp-info">
                <span class="iconify" data-icon="${loc.icon}" style="font-size:20px; color:var(--primary); margin-right:15px;"></span>
                <span style="font-weight:bold; color:white;">${loc.name}</span>
            </div>
        `;
            container.appendChild(row);
        });
    }

    window.closeGotoModal = function () {
        document.getElementById('goto-modal').style.display = 'none';
        document.getElementById('goto-modal-box').classList.remove('expanded');
    }

    // ==========================================================================
    //      SISTEMA DE ARRASTRE AVANZADO (CON LÍMITES Y ANTI-SALIDA)
    // ==========================================================================

    const dragContainer = document.getElementById('admin-menu');
    const saveBtn = document.getElementById('save-pos-btn');

    // 1. Activar Modo Edición
    window.enableDragMode = () => {
        isEditMode = true;
        dragContainer.classList.add('draggable-mode');
        if (saveBtn) saveBtn.style.display = 'block';

        // FIX BUG 2: No usamos getBoundingClientRect para evitar el desplazamiento
        // Simplemente forzamos que el transform-origin sea correcto y mantenemos
        // las coordenadas top/left que ya tiene el elemento en su style.

        dragContainer.style.transformOrigin = 'top left';
        dragContainer.style.transform = `scale(${currentScale / 100})`;
        dragContainer.style.margin = '0';

        // Si por alguna razón no tuviera posición (primera vez), entonces sí usamos un fallback
        if (!dragContainer.style.left) {
            const rect = dragContainer.getBoundingClientRect();
            dragContainer.style.left = ((rect.left / window.innerWidth) * 100) + '%';
            dragContainer.style.top = ((rect.top / window.innerHeight) * 100) + '%';
        }

        console.log("Modo edición activado. Posición congelada para evitar saltos.");
    };

    // 2. Guardar y Salir
    window.saveMenuPosition = () => {
        isEditMode = false;
        const dragContainer = document.getElementById('admin-menu');

        // Quitar modo visual
        dragContainer.classList.remove('draggable-mode');
        if (saveBtn) saveBtn.style.display = 'none';

        // Obtener datos finales
        const posData = {
            top: dragContainer.style.top,
            left: dragContainer.style.left,
            scale: currentScale // <--- AGREGA ESTA LÍNEA
        };

        fetch(`https://dp-adminmenu/saveMenuPos`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json; charset=UTF-8' },
            body: JSON.stringify(posData)
        });
    };

    // 3. LISTENERS DEL RATÓN

    // A. INICIAR ARRASTRE
    dragContainer.addEventListener('mousedown', (e) => {
        if (!isEditMode) return;
        isDragging = true;

        const rect = dragContainer.getBoundingClientRect();

        // Calculamos el offset relativo al clic, pero lo dividimos por la escala 
        // para que el movimiento sea 1:1 con el ratón
        dragOffsetX = e.clientX - rect.left;
        dragOffsetY = e.clientY - rect.top;
    });

    // B. MOVER (DENTRO DEL LISTENER mousemove)
    document.addEventListener('mousemove', (e) => {
        if (!isDragging || !isEditMode) return;

        e.preventDefault();

        const screenWidth = window.innerWidth;
        const screenHeight = window.innerHeight;

        // getBoundingClientRect nos da el tamaño REAL ocupado en pantalla tras la escala
        const menuRect = dragContainer.getBoundingClientRect();

        // 1. Calculamos la posición donde debería estar la esquina superior izquierda
        let rawX = e.clientX - dragOffsetX;
        let rawY = e.clientY - dragOffsetY;

        // 2. LIMITES: Usamos el ancho/alto VISUAL (ya escalado)
        const minX = 0;
        const maxX = screenWidth - menuRect.width;
        const minY = 0;
        const maxY = screenHeight - menuRect.height;

        // 3. CLAMP: Bloqueamos el menú dentro de esos límites
        let clampedX = Math.max(minX, Math.min(rawX, maxX));
        let clampedY = Math.max(minY, Math.min(rawY, maxY));

        // 4. CONVERSIÓN A PORCENTAJES
        let percentLeft = (clampedX / screenWidth) * 100;
        let percentTop = (clampedY / screenHeight) * 100;

        // 5. APLICAR
        dragContainer.style.left = percentLeft.toFixed(4) + '%';
        dragContainer.style.top = percentTop.toFixed(4) + '%';

        // Mantenemos escala y origen consistentes
        dragContainer.style.transform = `scale(${currentScale / 100})`;
        dragContainer.style.transformOrigin = 'top left';
    });

    // C. SOLTAR
    document.addEventListener('mouseup', () => {
        if (isDragging) {
            isDragging = false;
        }
    });

    // ==========================================
    // LÓGICA DE ESCALA
    // ==========================================
    let currentScale = 100;
    let originalScale = 100;

    window.previewScale = (val) => {
        val = parseInt(val);

        // Si no es un número (está vacío), no hacemos nada o ponemos 100
        if (isNaN(val)) return;

        // BLOQUEO DE SEGURIDAD: Forzamos que el valor esté entre 70 y 150
        if (val < 70) val = 70;
        if (val > 150) val = 150;

        currentScale = val;

        // Actualizamos ambos inputs para que muestren el valor corregido
        document.getElementById('scale-slider').value = val;
        document.getElementById('scale-number').value = val;

        const menu = document.getElementById('admin-menu');
        if (menu) {
            // Aplicamos la escala con el origen corregido (center center)
            menu.style.transformOrigin = 'center center';
            menu.style.transform = `scale(${val / 100})`;
        }
    };

    window.openScaleModal = () => {
        originalScale = currentScale;
        document.getElementById('scale-modal').style.display = 'flex';
    };

    window.closeScaleModal = () => {
        previewScale(originalScale);
        document.getElementById('scale-modal').style.display = 'none';
    };

    window.confirmScale = () => {
        saveMenuPosition(); // Esto llamará a tu función de guardado que ahora incluye la escala
        document.getElementById('scale-modal').style.display = 'none';
    };

    // ==========================================================================
    // 21. LOGICA DE IMÁGENES PARA REPORTES (INTEGRADO EN TU HTML)
    // ==========================================================================

    let reportAttachments = []; // Almacén temporal de las fotos

    // A. DETECTAR EL PASTE EN TU TEXTAREA ESPECÍFICO
    const reportDescInput = document.getElementById('report-desc');

    if (reportDescInput) {
        reportDescInput.addEventListener('paste', (e) => {
            const items = (e.clipboardData || e.originalEvent.clipboardData).items;
            let hasImage = false;

            for (let item of items) {
                if (item.type.indexOf('image') === 0) {
                    e.preventDefault(); // Evitamos que intente pegar "binary data"
                    const blob = item.getAsFile();
                    addReportAttachment(blob);
                    hasImage = true;
                }
            }
        });
    }

    // B. FUNCIÓN: AÑADIR A LA COLA VISUAL
    function addReportAttachment(file) {
        if (reportAttachments.length >= 3) {
            // Opcional: Sonido de error o notificación
            return;
        }
        reportAttachments.push(file);
        renderReportAttachments();
    }

    // C. FUNCIÓN: ELIMINAR DE LA COLA
    window.removeReportAttachment = (index) => {
        reportAttachments.splice(index, 1);
        renderReportAttachments();
    };

    // D. RENDERIZAR LA LISTA HORIZONTAL
    function renderReportAttachments() {
        const container = document.getElementById('report-attachments-area');
        container.innerHTML = '';

        if (reportAttachments.length === 0) {
            container.style.display = 'none';
            return;
        }

        container.style.display = 'flex'; // Mostramos el div

        reportAttachments.forEach((file, index) => {
            const url = URL.createObjectURL(file);

            const div = document.createElement('div');
            div.className = 'att-item';
            div.innerHTML = `
                <img src="${url}" onclick="openImageModal('${url}')">
                <button class="att-remove" onclick="removeReportAttachment(${index})">✕</button>
            `;
            container.appendChild(div);
        });
    }

    // ==========================================================================
    // 22. SOBRESCRIBIR EL BOTÓN DE ENVIAR REPORTE (LÓGICA ASYNC)
    // ==========================================================================

    // Primero, eliminamos listeners anteriores clonando el botón (truco limpio)
    const oldBtn = document.getElementById('btn-send-report');
    const newBtn = oldBtn.cloneNode(true);
    oldBtn.parentNode.replaceChild(newBtn, oldBtn);

    // Añadimos el nuevo listener inteligente
    newBtn.addEventListener('click', async () => {
        const title = document.getElementById('report-title').value;
        const descEl = document.getElementById('report-desc');
        let description = descEl.value;

        // Validaciones básicas
        if (!title) return; // Falta título
        if (!description && reportAttachments.length === 0) return; // Ni texto ni fotos

        // 1. BLOQUEO VISUAL (Feedback de carga)
        const originalText = newBtn.innerText;
        newBtn.disabled = true;
        newBtn.innerHTML = '<span class="iconify" data-icon="eos-icons:loading"></span> SUBIENDO...';
        newBtn.style.opacity = "0.7";

        // 2. SUBIDA DE IMÁGENES A DISCORD (Si las hay)
        if (reportAttachments.length > 0) {
            // Usamos la función global uploadImageToDiscord que definimos para el chat
            const uploadPromises = reportAttachments.map(file => uploadImageToDiscord(file));

            // Esperamos a que todas suban
            const uploadedUrls = await Promise.all(uploadPromises);

            // Filtramos errores (nulls) y formateamos para el texto
            const validUrls = uploadedUrls.filter(url => url !== null);

            if (validUrls.length > 0) {
                // AQUI ESTÁ EL TRUCO: Añadimos las URLs al texto del reporte
                // Dejamos dos saltos de línea para separarlo del texto del usuario
                description += "\n\n" + validUrls.join(" ");
            }
        }

        // 3. ENVÍO AL SERVIDOR (SQL)
        // Ahora 'description' contiene el texto original + las URLs de Discord
        fetch(`https://${GetParentResourceName()}/submitReport`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({
                title: title,
                description: description,
                type: currentReportType
            })
        });

        // 4. RESET Y CIERRE
        newBtn.disabled = false;
        newBtn.innerText = originalText;
        newBtn.style.opacity = "1";

        // Limpiamos formularios
        document.getElementById('report-title').value = '';
        descEl.value = '';
        reportAttachments = [];
        renderReportAttachments();

        window.closeReportMenu();
    });

}); // FIN DEL DOMContentLoaded