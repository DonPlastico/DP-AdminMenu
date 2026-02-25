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
    if (isDebugActive) console.log(`^4[DP-AdminMenu JAVASCRIPT]^7 ${msg}`);
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
let currentDetailsId = null;
let wasDetailsOpen = false;
let isProcessingAction = false; // Bloqueador global para evitar acciones simultáneas
let currentPlayerDataGlobal = null; // Para guardar datos del jugador (online/offline)
let pendingSanction = { type: null, targetId: null, citizenid: null, reason: null, duration: 0 };
let warnSpaceHeld = false;
let warnStartTime = 0;
let warnTimerInterval = null;
const WARN_DURATION = 5000; // 5 Segundos


// Estados de Botones (Toggle) - AQUÍ GUARDAMOS SI LA HERRAMIENTA ESTÁ ACTIVA
const actionStates = {
    noclip: false,
    godmode: false,
    invisible: false,
    entity_info: false,
    control_player: false
};

// Configuración Externa
const imgbbApiKey = "3171000eda16cef09aa593f4cc1ede01";
// const imgbbApiKey = "PONE_AQUI_TU_API_KEY_DE_IMGBB";

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
// 3. INICIALIZACIÓN DEL DOM (ARRANQUE)
// ==========================================================================

document.addEventListener('DOMContentLoaded', () => {
    log("DOM Listo. Arrancando interfaz DP-AdminMenu...");

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


    // --- LÓGICA DE IDENTIFICADORES (SPOILER) ---
    const identifiersBox = document.getElementById('pd-identifiers');

    if (identifiersBox) {
        // 1. Al hacer click DENTRO de la caja -> Revelar
        identifiersBox.addEventListener('click', (e) => {
            e.stopPropagation();
            identifiersBox.classList.add('revealed');
        });
    }

    // 2. Al hacer click en CUALQUIER OTRO SITIO -> Ocultar de nuevo
    document.addEventListener('click', (e) => {
        if (identifiersBox && identifiersBox.classList.contains('revealed')) {
            if (!identifiersBox.contains(e.target)) {
                identifiersBox.classList.remove('revealed');
            }
        }
    });

    // ==========================================================================
    // 4. NUI MESSAGE HANDLER (COMUNICACIÓN LUA -> JS)
    // ==========================================================================

    window.addEventListener('message', (event) => {
        const data = event.data;

        // --- ABRIR MENÚ ---
        if (data.type === 'open') {
            if (data.adminName) {
                document.getElementById("admin-user-name").innerText = data.adminName;
            } else {
                document.getElementById("admin-user-name").innerText = "Administrador";
            }
            mainAdminPanel.style.display = 'flex';

            // ==========================================================
            // FIX DEFINITIVO: RESETEAR LA BANDERA DE "ABIERTO"
            // ==========================================================
            selectedPlayer = null;
            wasDetailsOpen = false;
            currentDetailsId = null;

            // >>> ¡ESTA ES LA LÍNEA QUE FALTABA! <<<
            if (typeof isDetailsOpen !== 'undefined') isDetailsOpen = false;
            // (Usamos typeof por si acaso la variable se llama distinto, pero debería ser esa)

            // 3. Limpieza visual
            const detailsModal = document.getElementById('player-details-modal');
            if (detailsModal) detailsModal.style.display = 'none';
            document.querySelectorAll('.player-list-item').forEach(el => el.classList.remove('selected'));
            // ==========================================================

            if (data.menuPosition) {
                mainAdminPanel.style.top = data.menuPosition.top;
                mainAdminPanel.style.left = data.menuPosition.left;

                currentScale = data.menuPosition.scale || 100;

                if (document.getElementById('scale-slider')) {
                    document.getElementById('scale-slider').value = currentScale;
                    document.getElementById('scale-number').value = currentScale;
                }

                mainAdminPanel.style.transformOrigin = 'top left';
                mainAdminPanel.style.transform = `scale(${currentScale / 100})`;
                mainAdminPanel.style.margin = '0';
            }

            mainAdminPanel.style.opacity = '1.0';
            cursorModeActive = false;

            document.body.classList.add('menu-open');
            isDebugActive = data.debugMode;

            // FIX: Solo reemplazamos la memoria si el servidor envía el dato. Si no lo envía (undefined), conservamos lo que teníamos.
            if (data.players !== undefined) allPlayers = data.players;
            if (data.bans !== undefined) allBans = data.bans;
            if (data.jobs !== undefined) allJobs = data.jobs;
            if (data.gangs !== undefined) allGangs = data.gangs;

            renderPlayerList(allPlayers);
            if (data.reports !== undefined) renderReports(data.reports);
            renderBans(allBans);
            if (data.chat !== undefined) renderChat(data.chat);
            renderJobList(allJobs);
            renderGangList(allGangs);

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

            if (typeof closePlayerDetails === 'function') {
                closePlayerDetails();
            }

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

            // AJUSTAR VOLUMEN
            if (soundIn) soundIn.volume = 0.6;
            if (soundOut) soundOut.volume = 0.4;

            marquee.innerText = data.message;
            marquee.style.animation = 'none';
            bar.classList.remove('hide-announce');

            // --- SONIDO DE ENTRADA (ALERTA) ---
            if (soundIn) {
                soundIn.currentTime = 0;
                soundIn.play().catch(e => console.log("Audio play interceptado por navegador"));
            }

            // APLICAMOS CLASE DE ENTRADA Y MOSTRAMOS
            bar.classList.add('show-announce');
            bar.style.display = 'flex';

            // 🚀 EL FIX MÁGICO: Esperar al siguiente "Frame" visual para medir
            requestAnimationFrame(() => {
                // Ahora sí, el contenedor existe visualmente y podemos medirlo
                const anchoBarra = content.offsetWidth;
                const anchoTexto = marquee.offsetWidth;

                const recorridoTotal = anchoBarra + anchoTexto;
                const pixelesPorSegundo = 180; // Velocidad de lectura óptima
                const tiempoDeUnaVuelta = recorridoTotal / pixelesPorSegundo;

                // Definimos las variables de inicio y fin para el CSS
                marquee.style.setProperty('--start-x', `${anchoBarra}px`);
                marquee.style.setProperty('--end-x', `-${anchoTexto}px`);

                // Arrancamos la animación
                marquee.style.animation = `marquee-scroll ${tiempoDeUnaVuelta}s linear infinite`;
            });

            // Limpiamos el timer anterior si spamean anuncios
            if (announceTimeout) clearTimeout(announceTimeout);

            announceTimeout = setTimeout(() => {
                // --- SONIDO DE SALIDA (WHOOSH) ---
                if (soundOut) {
                    soundOut.currentTime = 0;
                    soundOut.play().catch(e => console.log("Audio play interceptado"));
                }

                // Animación de salida
                bar.classList.remove('show-announce');
                bar.classList.add('hide-announce');

                // Esperamos a que termine la animación visual (500ms)
                setTimeout(() => {
                    if (bar.classList.contains('hide-announce')) {
                        bar.style.display = 'none';
                        marquee.style.animation = 'none';
                        bar.classList.remove('hide-announce');
                    }
                }, 500);

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
            // FIX: Solo actualizamos lo que nos envíe el servidor en este momento
            if (data.players !== undefined) allPlayers = data.players;
            if (data.jobs !== undefined) allJobs = data.jobs;
            if (data.gangs !== undefined) allGangs = data.gangs;
            if (data.bans !== undefined) {
                allBans = data.bans;
                renderBans(allBans);
            }

            renderPlayerList(allPlayers);

            if (isDetailsOpen && currentDetailsId) {
                // Buscamos al jugador que estamos mirando en la NUEVA lista actualizada
                const target = allPlayers.find(p => p.id === currentDetailsId);

                if (target) {
                    // Si el jugador sigue ahí, refrescamos el modal para que se actualicen
                    // los datos (de "Seleccionando..." a "Nombre Real")
                    openPlayerDetails(target);
                } else {
                    // Si el jugador ya no está en la lista (se desconectó)
                    const badgeEl = document.getElementById('pd-status-badge');
                    if (badgeEl) {
                        badgeEl.textContent = "DESCONECTADO";
                        badgeEl.className = "status-badge offline";
                    }
                }
            }

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
            const ui = document.getElementById('noclip-ui');
            if (ui) {
                // Mostramos u ocultamos el HUD pequeño
                ui.style.display = data.show ? "block" : "none";

                // Si se activa, actualizamos el número de velocidad inicial
                if (data.show && (data.value !== undefined)) {
                    const num = document.getElementById('noclip-number');
                    if (num) num.innerText = data.value.toFixed(1);
                }
            }

        } else if (data.type === "updateNoClipSpeed") {
            // Actualizamos solo el número cuando giras la rueda del ratón
            const num = document.getElementById('noclip-number');
            if (num) num.innerText = data.value.toFixed(1);

        } else if (data.type === 'updateScreenshot') {
            const img = document.getElementById('screenshot-img');

            if (img) {
                // 1. Guardamos la foto (aunque esté oculta)
                img.src = data.url;

                // 2. Marcamos la bandera de "Recibido"
                isImageReceived = true;

                // 3. Intentamos mostrar
                // (Si el timer de 10s no ha acabado, esta función no hará nada todavía)
                tryShowScreenshot();
            }

        } else if (data.action === "UPDATE_LIVE_STATS") {
            // Solo actualizamos si el modal está realmente abierto
            if (typeof isDetailsOpen !== 'undefined' && !isDetailsOpen) return;

            const s = data.stats;

            // --- 1. HEALTH (Gestión especial para muertos) ---
            // Solo pasamos texto si está muerto/herido para que salga ROJO
            // Si está vivo, pasamos 'null' o nada para que salga BLANCO
            if (s.health <= 0) {
                // Dependiendo de tu lógica de muerte, a veces health llega negativo o 0
                // Si quieres detectar muerte real necesitas enviar isDead desde server, 
                // pero visualmente 0% está bien.
            }
            // Para Live Stats, mantenemos simple: solo valor numérico
            updateStatBar('stat-health', s.health);

            // --- 2. RESTO DE STATS (Sin 3er argumento para que sean BLANCOS) ---
            updateStatBar('stat-armor', s.armor);
            updateStatBar('stat-hunger', s.hunger);
            updateStatBar('stat-thirst', s.thirst);

            // --- 3. STATS ---
            updateStatBar('stat-alcohol', s.alcohol);
            updateStatBar('stat-stamina', s.stamina);

        } else if (data.action === 'close' || data.type === 'closeMenu') {
            const detailsModal = document.getElementById('player-details-modal');
            if (detailsModal) detailsModal.style.display = 'none';

            const screenshotModal = document.getElementById('screenshot-modal');
            if (screenshotModal) screenshotModal.style.display = 'none';

            const allContainers = document.querySelectorAll('.container');
            allContainers.forEach(el => el.style.display = 'none');

            selectedPlayer = null;
            if (typeof isDetailsOpen !== 'undefined') isDetailsOpen = false;

            const allItems = document.querySelectorAll('.player-list-item');
            allItems.forEach(item => item.classList.remove('selected'));

        } else if (data.action === 'refresh_player_details') {
            const targetCid = data.citizenid;

            // Verificamos si tenemos abierto el panel de ese mismo jugador
            if (isDetailsOpen && currentPlayerDataGlobal && currentPlayerDataGlobal.citizenid === targetCid) {

                // Forzamos la recarga de datos (badges, historial, etc.)
                // Usamos 'currentDetailsId' que ya lo tenemos guardado
                window.openPlayerDetails({
                    id: currentDetailsId,
                    citizenid: targetCid,
                    name: currentPlayerDataGlobal.name
                });
            }

        } else if (data.action === "openMap") {
            const modal = document.getElementById('goto-modal');
            if (modal) {
                modal.style.display = "flex";
                if (data.locations) {
                    setupMapData(data.locations);
                }
                window.resetMap();
            }

        } else if (data.action === 'openWarnScreen') {

            // 1. CERRAR CUALQUIER OTRA INTERFAZ ABIERTA (Admin Menu y Detalles)
            if (mainAdminPanel) mainAdminPanel.style.display = 'none'; // Ocultar menú principal
            const detailsModal = document.getElementById('player-details-modal');
            if (detailsModal) detailsModal.style.display = 'none';     // Ocultar detalles jugador
            document.body.classList.remove('menu-open');             // Quitar estado de menú abierto

            // 2. Mostrar Pantalla de Warn
            const screen = document.getElementById('warn-screen');
            if (screen) {
                document.getElementById('warn-reason-text').textContent = data.reason || "SIN MOTIVO";
                document.getElementById('warn-admin-name').textContent = data.admin || "SISTEMA";
                screen.style.display = 'flex';
            }

            // 3. Resetear barra y variables
            const bar = document.getElementById('warn-progress-fill');
            if (bar) bar.style.width = '0%';

            warnSpaceHeld = false;
            if (warnTimerInterval) clearInterval(warnTimerInterval);

            // 4. Lógica de Teclado
            const handleKeyDown = (e) => {
                if (e.code === 'Space' && !warnSpaceHeld) {
                    warnSpaceHeld = true;
                    warnStartTime = Date.now();

                    // Iniciar animación
                    warnTimerInterval = setInterval(() => {
                        const elapsed = Date.now() - warnStartTime;
                        // Calculamos porcentaje (0 a 100)
                        const progress = Math.min((elapsed / WARN_DURATION) * 100, 100);

                        if (bar) bar.style.width = `${progress}%`;

                        // ¡COMPLETADO! (>= 5000ms)
                        if (elapsed >= WARN_DURATION) {
                            // Forzamos visualmente el 100% por si acaso
                            if (bar) bar.style.width = '100%';

                            clearInterval(warnTimerInterval);

                            // Pequeña espera de 100ms para que el usuario vea la barra llena
                            setTimeout(() => {
                                completeWarn(handleKeyDown, handleKeyUp);
                            }, 100);
                        }
                    }, 20); // 20ms = 50 FPS (Fluido)
                }
            };

            const handleKeyUp = (e) => {
                if (e.code === 'Space') {
                    warnSpaceHeld = false;
                    clearInterval(warnTimerInterval);
                    if (bar) bar.style.width = '0%'; // Resetear si suelta
                }
            };

            // 5. Función de Éxito
            function completeWarn(downFn, upFn) {
                document.removeEventListener('keydown', downFn);
                document.removeEventListener('keyup', upFn);

                // Ocultar UI de Warn
                if (screen) screen.style.display = 'none';

                // Avisar al Servidor
                fetch(`https://${GetParentResourceName()}/warnConfirmed`, {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify({})
                });
            }

            // Registrar eventos
            document.addEventListener('keydown', handleKeyDown);
            document.addEventListener('keyup', handleKeyUp);

        } else if (data.type === 'showPuppetUI') {
            const container = document.getElementById('puppet-ui-container');
            const content = document.getElementById('puppet-text-content');
            if (container && content) {
                if (data.mode === 'admin') {
                    // Vista del Administrador
                    content.innerHTML = `
                        <span class="iconify" data-icon="mdi:controller-classic-outline" style="font-size: 24px; color: #00ffcc;"></span> 
                        <span>ESTÁS CONTROLANDO AL JUGADOR:</span> 
                        <span class="puppet-highlight">${data.targetName}</span> 
                        <span class="puppet-charname">(${data.charName})</span> 
                        <span class="puppet-badge">ID: ${data.targetId}</span>
                    `;
                } else if (data.mode === 'victim') {
                    // Vista de la Víctima
                    content.innerHTML = `
                        <span class="iconify" data-icon="mdi:eye-outline" style="font-size: 24px; color: var(--danger);"></span> 
                        <span>ESTÁS SIENDO CONTROLADO POR EL ADMINISTRADOR:</span> 
                        <span class="puppet-highlight">${data.adminName}</span> 
                        <span class="puppet-badge">ID: ${data.adminId}</span>
                    `;
                }
                container.style.display = 'flex';
            }

        } else if (data.type === 'hidePuppetUI') {
            const container = document.getElementById('puppet-ui-container');
            if (container) container.style.display = 'none';

        } else if (data.type === 'playAudio') {
            // Mini sistema de audio dinámico (PEDOS Y TROLLEOS)
            let audio = new Audio(`sounds/${data.file}`);
            audio.volume = data.volume || 0.5;
            audio.play().catch(e => console.log("Error al reproducir audio:", e));
        }
    });

    // ==========================================================================
    // 5. NAVEGACIÓN Y TECLADO
    // ==========================================================================

    tabs.forEach(tab => {
        tab.addEventListener('click', () => {
            // 1.Si cambias de pestaña, cierra el modal de detalles
            if (typeof closePlayerDetails === 'function') {
                closePlayerDetails();
            }

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
            if (document.activeElement && (document.activeElement.tagName === 'INPUT' || document.activeElement.tagName === 'TEXTAREA')) {
                document.activeElement.blur();
                return;
            }

            // PRIORIDAD ALTA - CANCELAR MODO EDICIÓN (ARRASTRE)
            if (isEditMode) {
                cancelDragMode();
                return;
            }

            // PASO 2: Función auxiliar para comprobar visibilidad
            const isVisible = (id) => {
                const el = document.getElementById(id);
                if (!el) return false;
                if (el.style.display === 'none') return false;
                const style = window.getComputedStyle(el);
                return !(style.display === 'none' || style.visibility === 'hidden' || style.opacity === '0');
            };

            // --- A. PRIORIDAD: CERRAR MODALES SECUNDARIOS ---
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
            if (isVisible('goto-modal')) { closeMapMenu(); return; }
            if (isVisible('scale-modal')) { closeScaleModal(); return; }
            if (isVisible('screenshot-modal')) { closeScreenshotModal(); return; }
            if (isVisible('dimension-modal')) { closeDimensionModal(); return; }
            if (isVisible('troll-menu-modal')) { closeTrollMenu(); return; }
            if (isVisible('confirm-sanction-modal')) { closeConfirmSanctionModal(); return; }

            // --- B. CERRAR HUD DE ENTIDADES (DEV TOOL) ---
            if (document.getElementById('entity-info-hud') && document.getElementById('entity-info-hud').style.display !== 'none') {
                toggleAction('entity_info');
                return;
            }

            // --- GESTIÓN DE PERSISTENCIA PLAYER DETAILS ---
            if (isVisible('player-details-modal')) {
                wasDetailsOpen = true;
                closePlayerDetails();
            } else {
                wasDetailsOpen = false;
            }

            selectedPlayer = null;
            document.querySelectorAll('.player-list-item').forEach(item => item.classList.remove('selected'));

            // --- C. CERRAR MENÚ PRINCIPAL ---
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
        const totalPlayersCounter = document.getElementById('total-players');
        if (totalPlayersCounter) {
            totalPlayersCounter.innerText = `${list ? list.length : 0}`;
        }

        playerListContainer.innerHTML = '';

        if (!list || list.length === 0) {
            playerListContainer.innerHTML = '<div style="padding:15px; color:#888;">No hay nadie conectado :(</div>';
            return;
        }

        list.forEach(player => {
            const card = document.createElement('div');
            card.className = 'player-card';

            // Evento onclick pasando los datos
            card.onclick = function () {
                openPlayerDetails({
                    id: player.id,
                    name: player.name,
                    charName: player.charName || "Desconocido" // Aseguramos que tenga nombre
                });
            };

            card.innerHTML = `<span class="id-badge">${player.id}</span> ${escapeHtml(player.name)}`;
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

        // Actualizar visualmente los botones (Clases originales)
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

        // 1. Limpiamos el texto
        let safeText = escapeHtml(text);

        // 2. Detectamos estrictamente URLs que terminen en formatos de imagen
        const imageRegex = /(https?:\/\/\S+\.(?:png|jpg|jpeg|gif|webp)(\?\S*)?)/gi;

        // 3. Reemplazamos
        return safeText.replace(imageRegex, function (url) {
            return `<img src="${url}" 
                     class="report-inline-img" 
                     onclick="openImageModal('${url}')" 
                     title="Click para ampliar">`;
        });
    }

    function renderReports(list) {
        const container = document.querySelector('.report-list');

        const totalReportsCounter = document.getElementById('total-reports');
        if (totalReportsCounter) totalReportsCounter.innerText = `${list ? list.length : 0}`;

        container.innerHTML = '';

        if (!list || list.length === 0) {
            container.innerHTML = `
                <div style="grid-column: 1 / -1; padding: 50px; text-align: center; color: #666; display: flex; flex-direction: column; align-items: center; gap: 10px;">
                    <span class="iconify" data-icon="mdi:check-circle-outline" style="font-size: 40px; color: var(--success);"></span>
                    <h2>TODO LIMPIO</h2>
                    <p>No hay reportes pendientes en este momento.</p>
                </div>`;
            return;
        }

        list.forEach(rep => {
            // SEGURIDAD: Limpiamos los nombres y títulos
            const steamName = escapeHtml(rep.steam_name || "Anonimo");
            const charName = escapeHtml(rep.sender_name || "Anonimo");
            const titleSafe = escapeHtml(rep.title || "Sin Asunto");

            // Lógica de Jugador Online/Offline
            const onlinePlayer = typeof allPlayers !== 'undefined'
                ? allPlayers.find(p => p.citizenid === rep.citizenid)
                : null;

            let playerParams = {};

            if (onlinePlayer) {
                playerParams = {
                    id: onlinePlayer.id,
                    name: onlinePlayer.name,
                    charName: onlinePlayer.charName,
                    citizenid: rep.citizenid
                };
            } else {
                playerParams = {
                    id: null,
                    citizenid: rep.citizenid,
                    name: steamName,
                    charName: charName,
                    isOffline: true
                };
            }

            const paramsString = JSON.stringify(playerParams).replace(/"/g, "&quot;");

            // Estilos dinámicos según estado
            const isOpen = rep.status === 'open';

            const statusBadge = isOpen
                ? `<span class="badge unassigned"><span class="iconify" data-icon="mdi:clock-alert-outline"></span> PENDIENTE</span>`
                : `<span class="badge assigned"><span class="iconify" data-icon="mdi:account-hard-hat"></span> ASIGNADO: ${escapeHtml(rep.assigned_to)}</span>`;

            const assignBtn = isOpen
                ? `<button class="btn-assign" data-id="${rep.id}" data-player="${steamName}"><span class="iconify" data-icon="mdi:hand-back-right"></span> ATENDER</button>`
                : `<button class="btn-disabled" disabled><span class="iconify" data-icon="mdi:lock-outline"></span> OCUPADO</button>`;

            // TRADUCTOR DE ETIQUETAS
            let translatedType = rep.type.toUpperCase();
            if (rep.type === 'support') translatedType = 'SOPORTE';
            if (rep.type === 'player') translatedType = 'JUGADOR';

            const card = document.createElement('div');
            card.className = 'report-card';

            // Inyectamos los datos con el nuevo HTML estructurado
            card.innerHTML = `
                <div class="rc-header">
                    <div class="rc-user-info">
                        <span class="iconify" data-icon="mdi:account-box"></span>
                        <span class="rc-title">${steamName} <small>(${charName})</small></span>
                        <span class="rc-id">#${rep.id}</span>
                    </div>
                    <div class="rc-badges">
                        ${statusBadge}
                        <span class="badge type"><span class="iconify" data-icon="mdi:tag-outline"></span> ${translatedType}</span>
                    </div>
                </div>
                <div class="rc-body">
                    <div class="rc-subject">
                        ${titleSafe}
                    </div>
                    <div class="rc-desc">${formatReportDescription(rep.description)}</div>
                </div>
                <div class="rc-footer">
                    ${assignBtn}
                    <button class="btn-info" onclick="openPlayerDetails(${paramsString})">
                        <span class="iconify" data-icon="mdi:card-account-details"></span> JUGADOR
                    </button>
                    <button class="btn-delete" data-id="${rep.id}">
                        <span class="iconify" data-icon="mdi:check-all"></span> CERRAR
                    </button>
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

        const totalBansCounter = document.getElementById('total-bans');
        if (totalBansCounter) totalBansCounter.innerText = `${list ? list.length : 0}`;

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
                        <button class="btn-mini btn-revoke" onclick="revokeBan(${ban.id}, '${ban.name}')" data-tooltip="Desbanear"><span class="iconify" data-icon="mdi:lock-open-check"></span></button>
                        <button class="btn-mini btn-extend" onclick="openExtendModal(${ban.id}, ${ban.expire})" data-tooltip="Extender Tiempo"><span class="iconify" data-icon="mdi:clock-edit-outline"></span></button>
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
                contentHtml += `<div class="chat-images-grid" style="display:flex; gap:5px; flex-wrap:wrap;/* margin-top:5px; */padding: 5px 15px;background: linear-gradient(90deg, rgba(255, 255, 255, 0.03) 0%, rgba(255, 255, 255, 0) 100%);border-left: 2px solid #444444;animation: slideInUp 0.5s ease-out forwards;transition: all 0.2s ease;">`;
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

    // Confirmación Modal corregida para evitar desenfoque
    let onConfirm = null;
    window.showConfirmationModal = (msg, callback) => {
        const modal = document.getElementById('confirm-modal');
        const container = modal.querySelector('.troll-custom-container');

        // 1. Inyectamos contenido
        document.getElementById('modal-message').innerHTML = msg;
        onConfirm = callback;

        // 2. Preparamos el contenedor quitando la animación previa si existiera
        container.style.animation = 'none';

        // 3. Mostramos el overlay
        modal.style.display = 'flex';

        // 4. TRUCO DE RENDERIZADO: Forzamos un reflow
        // Esto obliga al navegador a dibujar el modal en su sitio ANTES de animarlo
        void modal.offsetWidth;

        // 5. Animación de opacidad (NUNCA se ve borrosa)
        container.style.animation = 'fadeIn 0.2s ease-out forwards';
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
        if (extendOriginalExpire === 0) { document.getElementById('ext-current-date').innerHTML = '<span style="color:#ffffff">PERMANENTE</span>'; extPerm.checked = true; }
        else { document.getElementById('ext-current-date').textContent = new Date(extendOriginalExpire * 1000).toLocaleString('es-ES', dateOptions); extPerm.checked = false; }
        extVal.value = ''; recalcNewDate(); extModal.style.display = 'flex';
    };
    window.closeExtendModal = () => { extModal.style.display = 'none'; extendBanId = null; };

    function recalcNewDate() {
        if (extPerm.checked) { extDateDisp.innerHTML = '<span style="color:#ffffff; font-weight:bold;">PERMANENTE</span>'; extVal.disabled = true; extUnit.disabled = true; return; }
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

    // ==========================================================================
    // LÓGICA SELECT DESPLEGABLE (AISLADO PARA EVITAR CONFLICTOS DE IDs)
    // ==========================================================================
    if (extModal) {
        // Buscamos el wrapper y el trigger ESPECÍFICAMENTE dentro de este modal
        const localWrap = extModal.querySelector('.custom-select-wrapper');
        const localTrig = extModal.querySelector('.custom-select-trigger');

        if (localTrig && localWrap) {

            // 1. Abrir/Cerrar al hacer click
            localTrig.addEventListener('click', (e) => {
                e.stopPropagation();
                if (!extPerm.checked) localWrap.classList.toggle('open');
            });

            // 2. Seleccionar una opción
            localWrap.querySelectorAll('.custom-option').forEach(opt => {
                opt.addEventListener('click', function (e) {
                    e.stopPropagation();
                    localWrap.querySelectorAll('.custom-option').forEach(o => o.classList.remove('selected'));
                    this.classList.add('selected');
                    localTrig.querySelector('span').textContent = this.textContent;

                    if (extUnit) extUnit.value = this.getAttribute('data-value');
                    localWrap.classList.remove('open');
                    recalcNewDate(); // Recalcula la fecha abajo
                });
            });

            // 3. Cerrar si se hace click fuera del menú
            window.addEventListener('click', (e) => {
                if (!localWrap.contains(e.target)) {
                    localWrap.classList.remove('open');
                }
            });
        }
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
    // LÓGICA SELECT DESPLEGABLE Y SWITCH PARA EL SANCTION MODAL
    // ==========================================================================
    const banTimeTrigger = document.getElementById('ban-time-trigger');
    const banTimeUnit = document.getElementById('ban-time-unit');
    const banTimeVal = document.getElementById('ban-time-val');
    const banPermCheck = document.getElementById('ban-perm-check');

    if (banTimeTrigger) {
        const banTimeWrapper = banTimeTrigger.closest('.custom-select-wrapper');

        // 1. Abrir/Cerrar al hacer click (bloqueado si es permanente)
        banTimeTrigger.addEventListener('click', (e) => {
            e.stopPropagation();
            // Si el checkbox de permanente está marcado, no hacemos nada
            if (banPermCheck && banPermCheck.checked) return;

            banTimeWrapper.classList.toggle('open');
        });

        // 2. Seleccionar una opción
        banTimeWrapper.querySelectorAll('.custom-option').forEach(opt => {
            opt.addEventListener('click', function (e) {
                e.stopPropagation();
                banTimeWrapper.querySelectorAll('.custom-option').forEach(o => o.classList.remove('selected'));
                this.classList.add('selected');
                banTimeTrigger.querySelector('span').textContent = this.textContent;

                if (banTimeUnit) banTimeUnit.value = this.getAttribute('data-value');
                banTimeWrapper.classList.remove('open');
            });
        });

        // 3. Cerrar si se hace click fuera
        window.addEventListener('click', (e) => {
            if (!banTimeWrapper.contains(e.target)) {
                banTimeWrapper.classList.remove('open');
            }
        });

        // 4. Lógica del interruptor PERMANENTE
        if (banPermCheck) {
            banPermCheck.addEventListener('change', (e) => {
                const isPerm = e.target.checked;

                // Si es permanente, bloqueamos y atenuamos el input y el selector
                if (isPerm) {
                    banTimeVal.disabled = true;
                    banTimeVal.style.opacity = '0.4';
                    banTimeWrapper.style.opacity = '0.4';
                    banTimeWrapper.classList.remove('open'); // Cerramos por si estaba abierto
                } else {
                    banTimeVal.disabled = false;
                    banTimeVal.style.opacity = '1';
                    banTimeWrapper.style.opacity = '1';
                }
            });
        }
    }

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

        let openJobs = new Set();
        if (keepState) {
            jobListContainer.querySelectorAll('.accordion-card.expanded').forEach(card => {
                const idBadge = card.querySelector('.id-badge');
                if (idBadge) openJobs.add(idBadge.innerText);
            });
        }

        jobListContainer.innerHTML = '';
        if (totalJobsCounter) totalJobsCounter.innerText = `${list ? list.length : 0}`;

        if (!list || list.length === 0) {
            jobListContainer.innerHTML = '<div style="padding:30px; color:#888; text-align:center;">No se encontraron trabajos.</div>';
            return;
        }

        list.sort((a, b) => a.label.localeCompare(b.label));

        list.forEach(job => {
            const card = document.createElement('div');
            const isExpanded = keepState && openJobs.has(job.name);
            card.className = isExpanded ? 'accordion-card expanded' : 'accordion-card';

            const playerCount = job.players ? job.players.length : 0;
            const countClass = playerCount > 0 ? 'online-count-badge active' : 'online-count-badge';

            let html = `
            <div class="accordion-header" onclick="toggleJobAccordion(this)">
                <div style="display: flex; align-items: center; gap: 15px;">
                    <span class="id-badge" style="min-width: 110px;">${job.name}</span> 
                    <span class="accordion-label">${job.label}</span>
                </div>
                <div style="display: flex; align-items: center; gap: 15px;">
                    <span class="${countClass}">${playerCount} conectados</span>
                    <span class="iconify accordion-icon" data-icon="mdi:chevron-down" style="font-size: 20px;"></span>
                </div>
            </div>
            <div class="accordion-content">
        `;

            if (playerCount === 0) {
                html += `<div style="padding:20px; font-size:13px; color:#666; text-align:center; font-style:italic;">Nadie trabajando aquí ahora mismo.</div>`;
            } else {
                job.players.forEach(p => {
                    const dutyClass = p.onduty ? 'jp-duty on' : 'jp-duty off';
                    const dutyIcon = p.onduty ? 'mdi:clock-check-outline' : 'mdi:clock-remove-outline';
                    const dutyText = p.onduty ? 'EN SERVICIO' : 'FUERA SERVICIO';

                    html += `
                    <div class="job-player-row">
                        <div class="jp-info">
                            <span class="id-badge">${p.source}</span>
                            <div class="jp-names">
                                <div class="jp-char-name">${p.charName}</div>
                                <div class="jp-steam-name">(${p.name})</div>
                            </div>
                            <div class="jp-meta">
                                <div class="jp-grade">
                                    <span class="iconify" data-icon="mdi:police-badge-outline"></span>
                                    ${p.gradeLabel} <span class="jp-grade-num">${p.gradeLevel}</span>
                                </div>
                                <div class="${dutyClass}" onclick="toggleDutyPlayer(${p.source})" title="Click para cambiar">
                                    <span class="iconify" data-icon="${dutyIcon}"></span> ${dutyText}
                                </div>
                            </div>
                        </div>
                        <div class="icon-actions">
                            <div class="icon-btn" onclick="openPlayerDetails({ id: '${p.source}', name: '${escapeHtml(p.name)}', charName: '${escapeHtml(p.charName)}' })" data-tooltip="Detalles">
                                <span class="iconify" data-icon="mdi:account-details"></span>
                            </div>
                            <div class="icon-btn" onclick="openJobRankModal('${p.source}', '${p.name}', '${job.name}')" data-tooltip="Cambiar Rango">
                                <span class="iconify" data-icon="mdi:arrow-up-bold-hexagon-outline"></span>
                            </div>
                            <div class="icon-btn" onclick="openJobManageModal('${p.source}', '${p.name}')" data-tooltip="Cambiar Trabajo">
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
    // 18. MÓDULO: BANDAS (GANGS) - VERSIÓN CORREGIDA Y UNIFICADA
    // ==========================================================================
    const gangListContainer = document.getElementById('gang-list-container');
    const totalGangsCounter = document.getElementById('total-gangs');

    // Variables globales para Bandas
    let selectedGangPlayerId = null;
    let selectedGangName = null;

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

    // 1. RENDERIZADO DE BANDAS
    function renderGangList(list, keepState = false) {
        if (!gangListContainer) return;
        let openGangs = new Set();
        if (keepState) {
            gangListContainer.querySelectorAll('.accordion-card.expanded').forEach(card => {
                const idBadge = card.querySelector('.id-badge');
                if (idBadge) openGangs.add(idBadge.innerText);
            });
        }
        gangListContainer.innerHTML = '';
        if (totalGangsCounter) totalGangsCounter.innerText = `${list ? list.length : 0}`;
        if (!list || list.length === 0) {
            gangListContainer.innerHTML = '<div style="padding:30px; color:#888; text-align:center;">No se encontraron bandas activas.</div>';
            return;
        }
        list.sort((a, b) => a.label.localeCompare(b.label));
        list.forEach(gang => {
            const card = document.createElement('div');
            const isExpanded = keepState && openGangs.has(gang.name);
            card.className = isExpanded ? 'accordion-card expanded' : 'accordion-card';
            const playerCount = gang.players ? gang.players.length : 0;
            const countClass = playerCount > 0 ? 'online-count-badge active' : 'online-count-badge';

            card.innerHTML = `
        <div class="accordion-header" onclick="toggleJobAccordion(this)">
            <div style="display: flex; align-items: center; gap: 15px;">
                <span class="id-badge" style="min-width: 110px;">${gang.name}</span> 
                <span class="accordion-label">${gang.label}</span>
            </div>
            <div style="display: flex; align-items: center; gap: 15px;">
                <span class="${countClass}">${playerCount} conectados</span>
                <span class="iconify accordion-icon" data-icon="mdi:chevron-down" style="font-size: 20px;"></span>
            </div>
        </div>
        <div class="accordion-content">
            ${playerCount === 0 ? '<div style="padding:20px; font-size:13px; color:#666; text-align:center; font-style:italic;">Nadie conectado.</div>' : ''}
        </div>`;

            const content = card.querySelector('.accordion-content');
            if (gang.players) {
                gang.players.forEach(p => {
                    const row = document.createElement('div');
                    row.className = 'job-player-row';

                    row.innerHTML = `
                <div class="jp-info">
                    <span class="id-badge">${p.source}</span>
                    <div class="jp-names">
                        <div class="jp-char-name">${p.charName}</div>
                        <div class="jp-steam-name">(${p.name})</div>
                    </div>
                    <div class="jp-meta">
                        <div class="jp-grade">
                            <span class="iconify" data-icon="mdi:skull-crossbones-outline"></span>
                            ${p.gradeLabel} <span class="jp-grade-num">${p.gradeLevel}</span>
                        </div>
                    </div>
                </div>
                <div class="icon-actions">
                    <div class="icon-btn" onclick="openPlayerDetails({ id: '${p.source}', name: '${escapeHtml(p.name)}', charName: '${escapeHtml(p.charName)}' })" data-tooltip="Detalles">
                        <span class="iconify" data-icon="mdi:account-details"></span>
                    </div>
                    <div class="icon-btn" onclick="openGangRankModal('${p.source}', '${escapeHtml(p.name)}', '${gang.name}')" data-tooltip="Cambiar Rango">
                        <span class="iconify" data-icon="mdi:arrow-up-bold-hexagon-outline"></span>
                    </div>
                    <div class="icon-btn" onclick="openGangManageModal('${p.source}', '${escapeHtml(p.name)}')" data-tooltip="Cambiar Banda">
                        <span class="iconify" data-icon="mdi:account-cancel-outline"></span>
                    </div>
                </div>`;
                    content.appendChild(row);
                });
            }
            gangListContainer.appendChild(card);
        });
    }

    // 2. MODAL GESTIONAR
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
        wrapGmGang?.classList.remove('open');
        wrapGmGrade?.classList.remove('open');
    };

    function populateGangOptions() {
        if (!optsGmGang) return;
        optsGmGang.innerHTML = '';
        [...allGangs].sort((a, b) => a.label.localeCompare(b.label)).forEach(g => {
            const option = document.createElement('span');
            option.className = 'custom-option';
            option.innerText = g.label;
            option.onclick = () => {
                valGmGang.value = g.name;
                trigGmGang.querySelector('span').innerText = g.label;
                wrapGmGang.classList.remove('open');
                populateGangGradeOptions(g);
            };
            optsGmGang.appendChild(option);
        });
    }

    function populateGangGradeOptions(gangData) {
        optsGmGrade.innerHTML = '';
        wrapGmGrade.classList.remove('disabled');
        valGmGrade.value = "0";
        let gradesArray = Object.entries(gangData.grades || {}).map(([lvl, data]) => ({ level: parseInt(lvl), name: data.name }));
        gradesArray.sort((a, b) => a.level - b.level);
        trigGmGrade.querySelector('span').innerText = gradesArray.length > 0 ? `${gradesArray[0].name} (0)` : "Sin rangos";

        gradesArray.forEach(grade => {
            const option = document.createElement('span');
            option.className = 'custom-option';
            option.innerText = `${grade.name} (${grade.level})`;
            option.onclick = () => {
                valGmGrade.value = grade.level;
                trigGmGrade.querySelector('span').innerText = option.innerText;
                wrapGmGrade.classList.remove('open');
            };
            optsGmGrade.appendChild(option);
        });
    }

    // FUNCIÓN DE PROCESADO ÚNICA (Evita duplicados)
    const processSetGang = (gangName, gradeLevel) => {
        if (isProcessingAction) return;
        isProcessingAction = true;

        fetch(`https://${GetParentResourceName()}/setGang`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({
                targetId: selectedGangPlayerId,
                gang: gangName,
                grade: parseInt(gradeLevel)
            })
        }).then(() => {
            const targetId = selectedGangPlayerId;
            closeGangManageModal();
            // Auto-Refresco inteligente si estamos en Detalles
            if (isDetailsOpen && currentDetailsId == targetId) {
                setTimeout(() => {
                    window.openPlayerDetails({ id: targetId });
                    isProcessingAction = false;
                }, 600);
            } else {
                isProcessingAction = false;
            }
        }).catch(err => {
            console.error("Error SetGang:", err);
            isProcessingAction = false;
        });
    };

    // ASIGNACIÓN DE CLICS (Usamos onclick para limpiar cualquier listener previo)
    const btnSaveGang = document.getElementById('btn-set-gang');
    if (btnSaveGang) {
        btnSaveGang.onclick = function () {
            const g = valGmGang.value;
            const gr = valGmGrade.value || 0;
            if (!g || !selectedGangPlayerId) return;
            processSetGang(g, gr);
        };
    }

    const btnFireGang = document.getElementById('btn-fire-gang');
    if (btnFireGang) {
        btnFireGang.onclick = function () {
            showConfirmationModal(`¿Expulsar de su banda?`, () => {
                processSetGang("none", 0);
            });
        };
    }

    // Selectores UI
    trigGmGang?.addEventListener('click', (e) => {
        wrapGmGang.classList.toggle('open');
        wrapGmGrade.classList.remove('open');
        e.stopPropagation();
    });

    trigGmGrade?.addEventListener('click', (e) => {
        if (!wrapGmGrade.classList.contains('disabled')) wrapGmGrade.classList.toggle('open');
        wrapGmGang.classList.remove('open');
        e.stopPropagation();
    });

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

            // Si borras el número o está vacío
            if (isNaN(val)) {
                grPreview.innerHTML = "Escribe un número...";
                grPreview.style.color = "#888";
                return;
            }

            const gangData = allGangs.find(g => g.name === selectedGangName);
            let rankExists = false;
            let gradeName = "";

            if (gangData && gangData.grades) {
                if (gangData.grades[val]) {
                    gradeName = gangData.grades[val].name;
                    rankExists = true;
                } else if (gangData.grades[val.toString()]) {
                    gradeName = gangData.grades[val.toString()].name;
                    rankExists = true;
                }
            }

            // Si el rango existe, mostramos el nombre en blanco
            if (rankExists) {
                grPreview.innerHTML = gradeName;
                grPreview.style.color = "white";
            } else {
                // Si no existe, inyectamos el icono de Iconify en rojo oscuro y el texto en gris
                grPreview.innerHTML = `<span class="iconify" data-icon="mdi:close-circle-outline" style="font-size: 16px; margin-right: 4px; color: #888; vertical-align: text-bottom;"></span>Rango no existe`;
                grPreview.style.color = "#888";
            }
        });
    }

    const btnConfirmGangRank = document.getElementById('btn-confirm-gang-rank');
    if (btnConfirmGangRank) {
        btnConfirmGangRank.onclick = function () {
            if (isProcessingAction) return;
            const grade = grInput ? grInput.value : "";
            if (grade === "" || !selectedGangPlayerId) return;

            isProcessingAction = true;
            fetch(`https://${GetParentResourceName()}/setGangGrade`, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ targetId: selectedGangPlayerId, grade: grade })
            }).then(() => {
                const tId = selectedGangPlayerId;
                closeGangRankModal();
                setTimeout(() => {
                    if (isDetailsOpen) window.openPlayerDetails({ id: tId });
                    isProcessingAction = false;
                }, 600);
            });
        };
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
        // Usamos .onclick para asegurar que solo haya 1 evento activo y no se dupliquen
        btnSetJob.onclick = () => {
            const newJob = valJmJob ? valJmJob.value : null;
            const newGrade = valJmGrade ? valJmGrade.value : 0;

            // CORRECCIÓN: Usamos 'selectedJobPlayerId' que es la variable real de tu script
            if (!newJob || !selectedJobPlayerId) return;

            // Enviar al servidor
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

            // === LÓGICA DE AUTO-REFRESCO ===
            // Si el panel de detalles está abierto Y estamos editando a la misma persona
            if (typeof isDetailsOpen !== 'undefined' && isDetailsOpen && currentDetailsId == selectedJobPlayerId) {
                // Esperamos un poquito (500ms) a que la base de datos guarde el cambio
                setTimeout(() => {
                    if (typeof window.openPlayerDetails === 'function') {
                        // Recargamos los detalles para ver el nuevo trabajo al instante
                        window.openPlayerDetails({ id: selectedJobPlayerId });
                    }
                }, 500);
            }
        };
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
            const brand = veh.brand || 'Desc.';
            const category = veh.category || 'Sin Cat';
            const name = veh.name || veh.model;

            // LÓGICA DE ICONOS DINÁMICOS
            const catLower = category.toLowerCase();
            const modLower = veh.model.toLowerCase();
            let dynIcon = 'mdi:car'; // Icono por defecto

            if (modLower.includes('police') || modLower.includes('cop') || modLower.includes('sheriff') || modLower.includes('fib')) dynIcon = 'mdi:car-emergency';
            else if (modLower.includes('ambulance') || modLower.includes('ems') || modLower.includes('medic')) dynIcon = 'mdi:ambulance';
            else if (modLower.includes('taxi') || modLower.includes('cab')) dynIcon = 'mdi:taxi';
            else if (catLower === 'emergency') dynIcon = 'mdi:car-emergency';
            else if (['motorcycles', 'motorcycle'].includes(catLower) || modLower.includes('moto')) dynIcon = 'mdi:motorbike';
            else if (['cycles', 'bicycles', 'bicycle'].includes(catLower) || modLower.includes('bmx')) dynIcon = 'mdi:bicycle';
            else if (['helicopters', 'helicopter'].includes(catLower)) dynIcon = 'mdi:helicopter';
            else if (['planes', 'plane'].includes(catLower)) dynIcon = 'mdi:airplane';
            else if (['boats', 'boat'].includes(catLower)) dynIcon = 'mdi:sail-boat';
            else if (['commercial', 'industrial', 'trucks', 'utility'].includes(catLower)) dynIcon = 'mdi:truck';

            // HTML ESTRUCTURADO (Rediseño limpio)
            card.innerHTML = `
                <div class="veh-header">
                    <div class="veh-icon-wrapper">
                        <span class="iconify" data-icon="${dynIcon}"></span>
                    </div>
                    <div class="veh-title-group">
                        <div class="veh-name" title="${name}">${name}</div>
                        <div class="veh-brand">${brand}</div>
                    </div>
                </div>
                
                <div class="veh-details">
                    <div class="veh-detail-row">
                        <span class="veh-detail-label">CÓDIGO</span>
                        <span class="veh-detail-value" style="font-family: monospace; color: #aaa;">${veh.model}</span>
                    </div>
                    <div class="veh-detail-row">
                        <span class="veh-detail-label">CATEGORÍA</span>
                        <span class="veh-detail-value" style="color: #999;">${category}</span>
                    </div>
                    <div class="veh-detail-row">
                        <span class="veh-detail-label">PRECIO</span>
                        <span class="veh-detail-value" style="color: #fff;">${price}</span>
                    </div>
                </div>

                <div class="veh-actions">
                    <button class="btn-veh" onclick="spawnVehicle('${veh.model}')">
                        <span class="iconify" data-icon="mdi:car-key"></span> SPAWN
                    </button>
                    <button class="btn-veh" onclick="window.openGiveVehicleModal('${veh.model}', '${veh.name}')">
                        <span class="iconify" data-icon="mdi:gift-outline"></span> DAR
                    </button>
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

            // Recortar descripción solo si es extremadamente larga
            let desc = item.description || "Sin descripción";
            if (desc.length > 150) desc = desc.substring(0, 150) + "...";

            // ==========================================
            // LÓGICA DINÁMICA DE ICONOS BLINDADA (MDI STRICT)
            // ==========================================
            const itemNameLower = (item.name || '').toLowerCase();
            let dynIcon = 'mdi:cube-outline'; // Icono por defecto (Caja)
            let typeLabel = 'OBJETO COMÚN';

            // 1. MUNICIÓN (Balas)
            if (itemNameLower.endsWith('_ammo') || itemNameLower.includes('ammo_') || itemNameLower === 'ammo' || itemNameLower.includes('municion')) {
                dynIcon = 'mdi:ammunition';
                typeLabel = 'MUNICIÓN';
            }
            // 2. TINTES DE ARMA (Sprays y Camuflajes)
            else if (itemNameLower.includes('weapontint') || itemNameLower.includes('tint') || itemNameLower.includes('camo_attachment') || itemNameLower.includes('finish_attachment') || itemNameLower.includes('luxury') || itemNameLower.includes('etching')) {
                dynIcon = 'mdi:spray';
                typeLabel = 'TINTE DE ARMA';
            }
            // 3. ACCESORIOS DE ARMAS (Excluye cosas como "cooler_attachment" o "bench")
            else if (
                itemNameLower.includes('clip') || itemNameLower.includes('mag') || itemNameLower.includes('drum_attachment') ||
                itemNameLower.includes('scope') || itemNameLower.includes('sight') ||
                itemNameLower.includes('suppressor') || itemNameLower.includes('silencer') ||
                itemNameLower.includes('flashlight') || itemNameLower.includes('laser') ||
                itemNameLower.includes('grip') || itemNameLower.includes('barrel_attachment')
            ) {
                typeLabel = 'ACCESORIO DE ARMA';
                dynIcon = 'mdi:puzzle-outline'; // Icono base si no detecta cuál

                if (itemNameLower.includes('clip') || itemNameLower.includes('mag') || itemNameLower.includes('drum')) {
                    dynIcon = 'mdi:archive-outline'; // Cargador (Caja de archivo)
                    typeLabel = 'CARGADOR';
                } else if (itemNameLower.includes('scope') || itemNameLower.includes('sight')) {
                    dynIcon = 'mdi:crosshairs'; // Mira telescópica
                    typeLabel = 'MIRA / VISOR';
                } else if (itemNameLower.includes('suppressor') || itemNameLower.includes('silencer')) {
                    dynIcon = 'mdi:volume-off'; // Silenciador (Volumen apagado)
                    typeLabel = 'SILENCIADOR';
                } else if (itemNameLower.includes('flashlight')) {
                    dynIcon = 'mdi:flashlight'; // Linterna
                    typeLabel = 'LINTERNA';
                } else if (itemNameLower.includes('laser')) {
                    dynIcon = 'mdi:laser-pointer'; // Láser
                    typeLabel = 'LÁSER';
                } else if (itemNameLower.includes('barrel')) {
                    dynIcon = 'mdi:pipe'; // Cañón (Tubo)
                    typeLabel = 'CAÑÓN';
                } else if (itemNameLower.includes('grip')) {
                    dynIcon = 'mdi:hand-back-right-outline'; // Empuñadura
                    typeLabel = 'EMPUÑADURA';
                }
            }
            // 4. ARMAS DE FUEGO Y CUERPO A CUERPO
            else if (item.type === 'weapon' || itemNameLower.startsWith('weapon_')) {
                typeLabel = 'PISTOLA / ARMA CORTA';
                dynIcon = 'mdi:pistol'; // Por defecto para pistolas y revólveres (revolver, doubleaction, navyrevolver...)

                // Pistola Taser
                if (itemNameLower.includes('stun') || itemNameLower.includes('taser')) {
                    dynIcon = 'mdi:lightning-bolt';
                    typeLabel = 'TASER / ELÉCTRICA';
                }
                // Pistola de Bengalas
                else if (itemNameLower.includes('flaregun')) {
                    dynIcon = 'mdi:flare';
                    typeLabel = 'PISTOLA BENGALAS';
                }
                // Arma Experimental (Up-n-Atomizer / Raypistol)
                else if (itemNameLower.includes('raypistol')) {
                    dynIcon = 'mdi:blaster'; // Icono de pistola láser/espacial
                    typeLabel = 'ARMA EXPERIMENTAL';
                }
                // Francotiradores
                else if (itemNameLower.includes('sniper') || itemNameLower.includes('marksman')) {
                    dynIcon = 'mdi:crosshairs-gps';
                    typeLabel = 'FRANCOTIRADOR';
                }
                // Escopetas
                else if (itemNameLower.includes('shotgun') || itemNameLower.includes('musket') || itemNameLower.includes('pump') || itemNameLower.includes('sweeper') || itemNameLower.includes('escopeta')) {
                    dynIcon = 'mdi:flare';
                    typeLabel = 'ESCOPETA';
                }
                // Rifles de Asalto / Carabinas
                else if (itemNameLower.includes('rifle') || itemNameLower.includes('carbine') || itemNameLower.includes('carabina') || itemNameLower.includes('bullpup') || itemNameLower.includes('ak47')) {
                    dynIcon = 'mdi:target-account';
                    typeLabel = 'RIFLE / CARABINA';
                }
                // Subfusiles
                else if (itemNameLower.includes('smg') || itemNameLower.includes('pdw') || itemNameLower.includes('gusenberg') || itemNameLower.includes('machinepistol') || itemNameLower.includes('subfusil')) {
                    dynIcon = 'mdi:flash-outline';
                    typeLabel = 'SUBFUSIL';
                }
                // Ametralladoras Ligeras / Pesadas (LMG, Combat MG, Minigun) - ¡Sin cohetes!
                else if (itemNameLower.includes('mg') || itemNameLower.includes('minigun')) {
                    dynIcon = 'mdi:bullseye';
                    typeLabel = 'AMETRALLADORA';
                }
                // Lanzacohetes / Armas de Destrucción Masiva
                else if (itemNameLower.includes('rpg') || itemNameLower.includes('launcher') || itemNameLower.includes('railgun')) {
                    dynIcon = 'mdi:rocket-launch';
                    typeLabel = 'LANZACOHETES';
                }
                // Explosivos
                else if (itemNameLower.includes('grenade') || itemNameLower.includes('bomb') || itemNameLower.includes('sticky') || itemNameLower.includes('molotov') || itemNameLower.includes('proxmine') || itemNameLower === 'weapon_flare') {
                    dynIcon = 'mdi:bomb';
                    typeLabel = 'EXPLOSIVO';
                }
                // --- ARMAS RARAS Y TROLLS ---
                else if (itemNameLower.includes('briefcase')) {
                    dynIcon = 'mdi:briefcase';
                    typeLabel = 'MALETÍN';
                }
                else if (itemNameLower.includes('garbagebag')) {
                    dynIcon = 'mdi:trash-can-outline';
                    typeLabel = 'BOLSA DE BASURA';
                }
                else if (itemNameLower.includes('handcuffs')) {
                    dynIcon = 'mdi:handcuffs';
                    typeLabel = 'GRILLETES';
                }
                else if (itemNameLower.includes('bread') || itemNameLower.includes('baguette') || itemNameLower.includes('candycane')) {
                    dynIcon = 'mdi:food-apple';
                    typeLabel = 'COMIDA (ARMA)';
                }
                // --- CUERPO A CUERPO / ARMAS BLANCAS ---
                else if (
                    itemNameLower.includes('knife') || itemNameLower.includes('machete') ||
                    itemNameLower.includes('dagger') || itemNameLower.includes('hatchet') ||
                    itemNameLower.includes('knuckle') || itemNameLower.includes('bottle') ||
                    itemNameLower.includes('poolcue') || itemNameLower.includes('wrench') ||
                    itemNameLower.includes('hammer') || itemNameLower.includes('crowbar') ||
                    itemNameLower.includes('golfclub') || itemNameLower.includes('nightstick') ||
                    itemNameLower.includes('switchblade') || itemNameLower.includes('battleaxe') ||
                    itemNameLower === 'weapon_bat' || itemNameLower.endsWith('_bat')
                ) {
                    dynIcon = 'mdi:knife-military';
                    typeLabel = 'CUERPO A CUERPO';
                }
            }
            // 5. DINERO Y CRYPTO (Alta prioridad)
            else if (itemNameLower === 'cash' || itemNameLower === 'money' || itemNameLower.includes('money')) {
                dynIcon = 'mdi:cash-multiple';
                typeLabel = itemNameLower.includes('black') ? 'DINERO SUCIO' : 'DINERO';
            }
            else if (itemNameLower.includes('crypto') || itemNameLower.includes('bitcoin') || itemNameLower.includes('qbit')) {
                dynIcon = 'mdi:bitcoin';
                typeLabel = 'CRIPTODIVISA';
            }
            // 6. RESTO DE COSAS
            else if (itemNameLower.includes('phone') || itemNameLower.includes('radio') || itemNameLower.includes('gps')) {
                dynIcon = 'mdi:cellphone';
                typeLabel = 'ELECTRÓNICA';
            }
            else if (itemNameLower.includes('water') || itemNameLower.includes('drink') || itemNameLower.includes('coffee') || itemNameLower.includes('cola') || itemNameLower.includes('beer') || itemNameLower.includes('vodka')) {
                dynIcon = 'mdi:cup'; // Icono básico 100% garantizado en MDI
                typeLabel = 'BEBIDA';
            }
            else if (itemNameLower.includes('burger') || itemNameLower.includes('food') || itemNameLower.includes('bread') || itemNameLower.includes('sandwich') || itemNameLower.includes('donut') || itemNameLower.includes('taco')) {
                dynIcon = 'mdi:food-apple';
                typeLabel = 'COMIDA';
            }
            else if (itemNameLower.includes('medkit') || itemNameLower.includes('bandage') || itemNameLower.includes('pill') || itemNameLower.includes('heal') || itemNameLower.includes('firstaid')) {
                dynIcon = 'mdi:medical-bag';
                typeLabel = 'MÉDICO';
            }
            else if (itemNameLower.includes('repair') || itemNameLower.includes('fixkit') || itemNameLower.includes('toolbox') || itemNameLower.includes('kit') || itemNameLower.includes('lockpick')) {
                dynIcon = 'mdi:toolbox';
                typeLabel = 'HERRAMIENTA';
            }
            else if (itemNameLower.includes('card') || itemNameLower.includes('id_') || itemNameLower.includes('license')) {
                dynIcon = 'mdi:card-account-details';
                typeLabel = 'DOCUMENTO';
            }
            else if (itemNameLower.includes('weed') || itemNameLower.includes('coke') || itemNameLower.includes('meth') || itemNameLower.includes('drug') || itemNameLower.includes('joint')) {
                dynIcon = 'mdi:cannabis';
                typeLabel = 'ILEGAL';
            }

            // Preparar HTML de munición si es un arma
            let ammoHtml = '';
            if (item.ammoType) {
                let cleanAmmo = item.ammoType.replace('AMMO_', '');
                ammoHtml = `
                <div class="veh-detail-row">
                    <span class="veh-detail-label" style="color: #ffb74d;">MUNICIÓN</span>
                    <span class="veh-detail-value" style="color: #fff;">${cleanAmmo}</span>
                </div>`;
            }

            // HTML ESTRUCTURADO (Estilo Limpio)
            card.innerHTML = `
                <div class="veh-header">
                    <div class="veh-icon-wrapper">
                        <span class="iconify" data-icon="${dynIcon}"></span>
                    </div>
                    <div class="veh-title-group">
                        <div class="veh-name" title="${label}">${label}</div>
                        <div class="veh-brand">${typeLabel}</div>
                    </div>
                </div>
                
                <div class="veh-details" style="flex: 1;">
                    <div class="veh-detail-row">
                        <span class="veh-detail-label">CÓDIGO</span>
                        <span class="veh-detail-value" style="font-family: monospace; color: #aaa;">${code}</span>
                    </div>
                    <div class="veh-detail-row">
                        <span class="veh-detail-label">PESO</span>
                        <span class="veh-detail-value" style="color: #999;">${formatWeight(weight)}</span>
                    </div>
                    
                    ${ammoHtml}

                    <div style="margin-top: 8px; padding-top: 8px; border-top: 1px dashed rgba(255,255,255,0.05);">
                        <span class="veh-detail-label" style="display:block; margin-bottom:4px;">DESCRIPCIÓN</span>
                        <span class="veh-detail-value" title="${item.description}" style="white-space: normal; line-height: 1.4; font-size: 11px; color: #888; text-align: left; display: block;">
                            ${desc}
                        </span>
                    </div>
                </div>

                <div class="veh-actions">
                    <button class="btn-veh" onclick="spawnItem('${code}')" title="Dármelo a mí">
                        <span class="iconify" data-icon="mdi:download"></span> SACAR
                    </button>
                    <button class="btn-veh" onclick="openGiveItemModal('${code}', '${label}', '${item.type}', '${item.ammoType || ''}')" title="Dar a otro jugador">
                        <span class="iconify" data-icon="mdi:gift-outline"></span> DAR
                    </button>
                </div>
            `;
            fragment.appendChild(card);
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
            color: '#ffffff', // Rojo
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
                ? `<span style="color:#ffffff; font-weight:bold; font-size:18px;">⚠️ ¿ACTIVAR WHITELIST GLOBAL?</span><br><br>
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
        // Respetando tu URL 'https://DP-AdminMenu/...'
        fetch(`https://DP-AdminMenu/toggleServerOption`, {
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

    // 4. Subir imagen a ImgBB y obtener URL permanente
    async function uploadImageToImgBB(file) {
        const formData = new FormData();
        formData.append('image', file);

        try {
            const response = await fetch(`https://api.imgbb.com/1/upload?key=${imgbbApiKey}`, {
                method: 'POST',
                body: formData
            });

            if (!response.ok) throw new Error('Error subiendo imagen a ImgBB');

            const data = await response.json();

            // LA CLAVE: 'display_url' es el enlace directo (termina en .png/.jpg)
            if (data && data.data && data.data.display_url) {
                return data.data.display_url;
            } else if (data && data.data && data.data.url) {
                return data.data.url; // Fallback por si acaso
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
            const uploadPromises = pendingAttachments.map(file => uploadImageToImgBB(file));
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
        const detailsModal = document.getElementById('player-details-modal');

        // 1. Si el menú está cerrado, no hacemos nada
        if (!menuContainer || menuContainer.style.display === 'none') return;

        // 2. Si escribimos en un input, ignoramos la J
        const activeTag = document.activeElement.tagName;
        if (activeTag === 'INPUT' || activeTag === 'TEXTAREA') return;

        // 3. Detectar tecla J
        if (event.key.toLowerCase() === 'j') {

            // Invertimos el estado
            cursorModeActive = !cursorModeActive;

            // Agrupamos todos los cambios para que se apliquen en el MISMO fotograma visual a la vez
            requestAnimationFrame(() => {
                const opacidad = cursorModeActive ? '0.2' : '1.0';
                const puntero = cursorModeActive ? 'none' : 'auto';

                // Menú principal
                menuContainer.style.setProperty('opacity', opacidad, 'important');
                menuContainer.style.setProperty('pointer-events', puntero, 'important');

                // Detalles del Jugador (Se aplicará exactamente a la vez)
                if (detailsModal) {
                    detailsModal.style.setProperty('opacity', opacidad, 'important');
                    detailsModal.style.setProperty('pointer-events', puntero, 'important');
                }
            });

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

    // =======================================================
    //      SISTEMA MAPA TÁCTICO (CON COLORES DINÁMICOS)
    // =======================================================

    // --- 1. PUENTE Y CONFIGURACIÓN ---

    window.triggerMapOpen = function () {
        fetch(`https://${GetParentResourceName()}/triggerAction`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ action: 'open_map_menu' })
        });
    }

    const MAP_CONFIG = {
        // --- CALIBRACIÓN MATEMÁTICA PARA IMAGEN 2500x3000 ---

        // 1. DIVISORES DE ESCALA (Zoom del mundo)
        // Para mantener los blips circulares y no "ovalados", la relación entre
        // width y height debe coincidir con la de la imagen (2500/3000 = 0.833).

        width: 11150,    // Ancho del mundo GTA que cubre la imagen horizontalmente
        height: 13150,  // Ajustado para que el pixel sea cuadrado 1:1

        // 2. PUNTO CERO (Donde está el 0,0 del juego en tu imagen %)
        // El 0,0 de GTA (cerca del Maze Bank) está horizontalmente centrado,
        // pero verticalmente está más cerca del sur (la isla es más larga hacia el norte).

        offsetX: 43.8,    // DE LADOS
        offsetY: 63.9     // ALTURA
    };

    // [ACTUALIZADO] PALETA DE COLORES TÁCTICOS (ORDEN DE TU WEB)
    const CATEGORY_COLORS = {
        "Atracos / Robos": "#c0392b",           // Rojo Oscuro (Máscara/Peligro)
        "Misiones / Ilegal": "#8e44ad",         // Morado (Calavera/Misterio)
        "Garajes / Almacenes": "#7f8c8d",       // Gris Industrial (Warehouse)
        "Barrios / Bandas": "#e74c3c",          // Rojo Vivo (Territorio/House)
        "Locales / Comercios": "#f39c12",       // Amarillo/Naranja (Shop)
        "Oficinas": "#2980b9",                  // Azul Corporativo (Briefcase)
        "Viviendas / Apartamentos": "#1abc9c",  // Turquesa (Cama/Hogar)
        "Policía": "#3498db",                   // Azul Policial (Escudo)
        "Hospital": "#e84393",                  // Rosa (Doctor/Salud)
        "Mecánicos": "#d35400",                 // Naranja Mecánico (Llave)
        "Otros / Mapeados Generales": "#34495e" // Gris Azulado (Capas/General)
    };

    // Color por defecto si la categoría no está en la lista de arriba
    const DEFAULT_COLOR = "#95a5a6";

    let mapState = {
        scale: 1, panning: false,
        pointX: 0, pointY: 0,
        startX: 0, startY: 0,
        selectedCoords: null
    };

    let cachedLocations = {};
    let activeFilters = {};

    const mapViewport = document.getElementById('map-viewport');
    const mapContent = document.getElementById('map-content');

    // --- 2. MATEMÁTICAS ---

    function clamp(value, min, max) { return Math.min(Math.max(value, min), max); }

    function gtaToCss(x, y) {
        // Fórmula: (Coordenada / Divisor * 100) + OffsetCentral

        // X: Positivo es Derecha
        const leftPercent = ((x / MAP_CONFIG.width) * 100) + MAP_CONFIG.offsetX;

        // Y: Positivo es Arriba en juego, pero 'top' CSS empieza arriba. 
        // Invertimos Y (-y).
        const topPercent = ((-y / MAP_CONFIG.height) * 100) + MAP_CONFIG.offsetY;

        return { left: leftPercent, top: topPercent };
    }

    // --- 3. GESTIÓN DE FILTROS Y DATOS ---

    function setupMapData(categories) {
        cachedLocations = categories;
        activeFilters = {};
        for (const catName of Object.keys(categories)) {
            activeFilters[catName] = true;
        }
        renderFilterList();
        refreshMapBlips();
    }

    // Genera botones con GRADIENTES PREMIUM DINÁMICOS
    function renderFilterList() {
        const container = document.getElementById('filters-list');
        if (!container) return;
        container.innerHTML = '';

        for (const catName of Object.keys(cachedLocations)) {
            const item = document.createElement('div');
            const isActive = activeFilters[catName];

            // Obtenemos el color de la categoría o el default (Ej: "#ff0000")
            const catColor = CATEGORY_COLORS[catName] || DEFAULT_COLOR;

            item.className = isActive ? 'filter-item active' : 'filter-item';

            // ESTILOS DINÁMICOS SEGÚN ESTADO (Estilo Premium)
            if (isActive) {
                // Gradiente: Empieza con el color de la categoría al 10% de opacidad ("1A") y termina transparente
                item.style.background = `linear-gradient(90deg, ${catColor}1A 0%, transparent 100%)`;

                // He puesto que el borde izquierdo también coja el color de la categoría. 
                // (Si lo quieres estrictamente gris oscuro siempre, cámbialo por "2px solid #444444")
                item.style.borderLeft = `2px solid ${catColor}`;

                item.style.color = "#fff";
                item.style.fontWeight = "bold";
                item.style.cursor = "pointer";

                // El text-shadow coge el color de la cat con un 50% de opacidad ("80")
                item.style.textShadow = `0 0 5px ${catColor}80`;
            } else {
                // Si está inactivo: Gris apagado con el borde gris oscuro por defecto
                item.style.background = "rgba(0,0,0,0.4)";
                item.style.borderLeft = "2px solid #444444";
                item.style.color = "#666";
                item.style.fontWeight = "normal";
                item.style.textShadow = "none";
                item.style.cursor = "pointer";
            }

            const count = cachedLocations[catName].length;
            item.innerHTML = `
            <span>${catName}</span>
            <span style="font-size:0.8em; opacity:0.6;">[${count}]</span>
        `;

            item.onclick = () => {
                activeFilters[catName] = !activeFilters[catName];
                renderFilterList();
                refreshMapBlips();
            };

            container.appendChild(item);
        }
    }

    // [MODIFICADO] Dibuja los blips con el COLOR DE SU CATEGORÍA
    function refreshMapBlips() {
        const layer = document.getElementById('blip-layer');
        if (!layer) return;

        layer.innerHTML = '';

        for (const [catName, locations] of Object.entries(cachedLocations)) {
            if (!activeFilters[catName]) continue;

            // Obtenemos el color
            const catColor = CATEGORY_COLORS[catName] || DEFAULT_COLOR;

            locations.forEach(loc => {
                const pos = gtaToCss(loc.coords.x, loc.coords.y);
                const el = document.createElement('div');
                el.className = 'map-blip';
                el.style.left = `${pos.left}%`;
                el.style.top = `${pos.top}%`;

                // APLICAMOS EL COLOR AL BLIP
                el.style.backgroundColor = catColor;
                el.style.boxShadow = `0 0 15px ${catColor}`; // Glow del mismo color

                el.innerHTML = `<span class="iconify" data-icon="${loc.icon || 'mdi:map-marker'}"></span>`;

                el.onclick = (e) => {
                    e.stopPropagation();
                    window.openSidePanel(loc);
                };
                el.title = `${loc.name} (${catName})`;
                layer.appendChild(el);
            });
        }
    }

    // --- RESTO DE FUNCIONES ---

    window.toggleFilterPanel = function () {
        const panel = document.getElementById('map-filters-panel');
        if (panel) panel.classList.toggle('hidden-panel-left');
    }

    window.closeFilterPanel = function () {
        const panel = document.getElementById('map-filters-panel');
        if (panel) panel.classList.add('hidden-panel-left');
    }

    window.toggleAllFilters = function (state) {
        for (const key in activeFilters) {
            activeFilters[key] = state;
        }
        renderFilterList();
        refreshMapBlips();
    }

    function updateMapTransform() {
        if (!mapContent || !mapViewport) return;
        const viewW = mapViewport.offsetWidth;
        const viewH = mapViewport.offsetHeight;
        const mapW = mapContent.offsetWidth;
        const mapH = mapContent.offsetHeight;

        const minPosX = viewW - (mapW * mapState.scale);
        const minPosY = viewH - (mapH * mapState.scale);
        const maxPosX = 0, maxPosY = 0;

        if ((mapW * mapState.scale) < viewW) mapState.pointX = (viewW - (mapW * mapState.scale)) / 2;
        else mapState.pointX = clamp(mapState.pointX, minPosX, maxPosX);

        if ((mapH * mapState.scale) < viewH) mapState.pointY = (viewH - (mapH * mapState.scale)) / 2;
        else mapState.pointY = clamp(mapState.pointY, minPosY, maxPosY);

        mapContent.style.transform = `translate(${mapState.pointX}px, ${mapState.pointY}px) scale(${mapState.scale})`;

        // Actualizamos la variable CSS para que los blips sepan cuánto reducirse
        mapContent.style.setProperty('--current-zoom', mapState.scale);
    }

    window.mapZoomIn = function () {
        mapState.scale *= 1.2;
        if (mapState.scale > 8) mapState.scale = 8;
        updateMapTransform();
    }

    window.mapZoomOut = function () {
        mapState.scale /= 1.2;
        const minScaleW = mapViewport.offsetWidth / mapContent.offsetWidth;
        const minScaleH = mapViewport.offsetHeight / mapContent.offsetHeight;
        const minScale = Math.max(minScaleW, minScaleH);
        if (mapState.scale < minScale) mapState.scale = minScale;
        updateMapTransform();
    }

    window.resetMap = function () {
        if (!mapContent || !mapViewport) return;
        mapState.scale = 1;
        const viewW = mapViewport.offsetWidth, viewH = mapViewport.offsetHeight;
        const mapW = mapContent.offsetWidth, mapH = mapContent.offsetHeight;
        mapState.pointX = (viewW - mapW) / 2;
        mapState.pointY = (viewH - mapH) / 2;
        // Aseguramos que la variable vuelva a 1
        mapContent.style.setProperty('--current-zoom', 1);

        updateMapTransform();
        window.closeSidePanel();
    }

    if (mapViewport) {
        mapViewport.onmousedown = function (e) {
            e.preventDefault();
            mapState.startX = e.clientX - mapState.pointX;
            mapState.startY = e.clientY - mapState.pointY;
            mapState.panning = true;
            mapViewport.style.cursor = 'grabbing';
        };
        mapViewport.onwheel = function (e) {
            e.preventDefault();
            const oldScale = mapState.scale;
            const delta = -e.deltaY;
            (delta > 0) ? (mapState.scale *= 1.1) : (mapState.scale /= 1.1);

            const minScale = Math.max(mapViewport.offsetWidth / mapContent.offsetWidth, mapViewport.offsetHeight / mapContent.offsetHeight);
            if (mapState.scale < minScale) mapState.scale = minScale;
            if (mapState.scale > 8) mapState.scale = 8;

            const rect = mapContent.getBoundingClientRect();
            const mouseX = (e.clientX - rect.left) / oldScale;
            const mouseY = (e.clientY - rect.top) / oldScale;
            mapState.pointX -= mouseX * (mapState.scale - oldScale);
            mapState.pointY -= mouseY * (mapState.scale - oldScale);
            updateMapTransform();
        };
    }
    window.addEventListener('mouseup', function () { mapState.panning = false; if (mapViewport) mapViewport.style.cursor = 'grab'; });
    window.addEventListener('mousemove', function (e) {
        if (!mapState.panning) return;
        e.preventDefault();
        mapState.pointX = e.clientX - mapState.startX;
        mapState.pointY = e.clientY - mapState.startY;
        updateMapTransform();
    });

    window.openSidePanel = function (data) {
        const panel = document.getElementById('map-side-panel');
        if (!panel) return;
        document.getElementById('panel-img').src = data.img || 'img/default_loc.jpg';
        document.getElementById('panel-title').innerText = data.name;
        document.getElementById('panel-desc').innerText = data.description || "Sin información disponible.";
        document.getElementById('panel-coords-text').innerText = `X: ${data.coords.x.toFixed(0)} | Y: ${data.coords.y.toFixed(0)}`;
        mapState.selectedCoords = data.coords;
        panel.classList.remove('hidden-panel');
    }

    window.closeSidePanel = function () {
        const panel = document.getElementById('map-side-panel');
        if (panel) panel.classList.add('hidden-panel');
    }

    // --- BOTÓN DE TELETRANSPORTE (DENTRO DEL PANEL LATERAL DEL MAPA) ---
    const btnTp = document.getElementById('btn-tp');
    if (btnTp) {
        btnTp.onclick = function () {
            if (!mapState.selectedCoords) return;

            // Extraemos las coordenadas del punto seleccionado en el mapa
            const coords = {
                x: mapState.selectedCoords.x,
                y: mapState.selectedCoords.y,
                z: mapState.selectedCoords.z
            };

            if (mapTargetId) {
                // MODO TÁCTICO: Mandamos al jugador seleccionado en "Detalles"
                fetch(`https://${GetParentResourceName()}/teleportTargetToCoords`, {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify({
                        targetId: mapTargetId,
                        coords: coords
                    })
                });

                // IMPORTANTE: Limpiamos el target para que la próxima vez que 
                // abras el mapa desde el menú principal sea para TI.
                mapTargetId = null;
            } else {
                // MODO NORMAL: Teletransporte para el Administrador
                fetch(`https://${GetParentResourceName()}/tpToLocation`, {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify({
                        x: coords.x,
                        y: coords.y,
                        z: coords.z
                    })
                });
            }

            // Cerramos el panel lateral y el modal del mapa
            window.closeSidePanel();
            window.closeMapMenu(); // Usamos tu función de cerrar
        };
    }

    window.closeMapMenu = function () {
        const mapModal = document.getElementById('goto-modal');
        if (mapModal) {
            mapModal.style.display = "none";
            window.closeSidePanel();
            window.closeFilterPanel();
        }

        // Reseteamos el target al cerrar por si acaso
        mapTargetId = null;

        fetch(`https://${GetParentResourceName()}/closeMenu`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({})
        });
    }

    // ==========================================================================
    //      SISTEMA DE ARRASTRE AVANZADO (CON LÍMITES Y ANTI-SALIDA)
    // ==========================================================================

    const dragContainer = document.getElementById('admin-menu');
    const saveBtn = document.getElementById('save-pos-btn');

    // 1. Activar Modo Edición
    window.enableDragMode = () => {
        isEditMode = true;
        const dragContainer = document.getElementById('admin-menu');

        // --- Referencia al nuevo contenedor de controles ---
        const controls = document.getElementById('drag-controls');

        dragContainer.classList.add('draggable-mode');

        // Mostramos el contenedor entero (usamos 'flex' para que los botones queden alineados)
        if (controls) controls.style.display = 'flex';

        // FIX BUG 2: Posicionamiento seguro
        dragContainer.style.transformOrigin = 'top left';
        dragContainer.style.transform = `scale(${currentScale / 100})`;
        dragContainer.style.margin = '0';

        if (!dragContainer.style.left) {
            const rect = dragContainer.getBoundingClientRect();
            dragContainer.style.left = ((rect.left / window.innerWidth) * 100) + '%';
            dragContainer.style.top = ((rect.top / window.innerHeight) * 100) + '%';
        }

        log("Modo edición activado.");
    };

    // 2. Guardar y Salir
    window.saveMenuPosition = () => {
        isEditMode = false;
        const dragContainer = document.getElementById('admin-menu');

        // --- Ocultamos el contenedor ---
        const controls = document.getElementById('drag-controls');

        dragContainer.classList.remove('draggable-mode');

        if (controls) controls.style.display = 'none';

        // Obtener datos finales
        const posData = {
            top: dragContainer.style.top,
            left: dragContainer.style.left,
            scale: currentScale
        };

        fetch(`https://${GetParentResourceName()}/saveMenuPos`, {
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

    // Función para cancelar el arrastre (Escape)
    window.cancelDragMode = () => {
        isEditMode = false;
        const dragContainer = document.getElementById('admin-menu');

        // --- Ocultamos el contenedor ---
        const controls = document.getElementById('drag-controls');

        if (dragContainer) dragContainer.classList.remove('draggable-mode');

        if (controls) controls.style.display = 'none';

        log("Modo edición cancelado.");
    };

    // ==========================================
    // LÓGICA DE ESCALA
    // ==========================================
    let currentScale = 90;
    let originalScale = 90;

    window.previewScale = (val) => {
    val = parseInt(val);
    if (isNaN(val)) return;

    // BLOQUEO DE SEGURIDAD
    if (val < 70) val = 70;
    if (val > 117) val = 117;

    currentScale = val;

    const slider = document.getElementById('scale-slider');
    const numberInput = document.getElementById('scale-number');

    slider.value = val;
    numberInput.value = val;

    const percentage = ((val - 70) / 47) * 100;
    slider.style.background = `linear-gradient(90deg, var(--primary) ${percentage}%, rgba(0,0,0,0.6) ${percentage}%)`;

    const menu = document.getElementById('admin-menu');
    if (menu) {
        // CAMBIA ESTA LÍNEA DE 'center center' A 'top left'
        menu.style.transformOrigin = 'top left'; 
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
            // Sonido de error o notificación
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
            const uploadPromises = reportAttachments.map(file => uploadImageToImgBB(file));

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

    // --- LÓGICA PLAYER DETAILS ---

    let isDetailsOpen = false;

    // --- FUNCIÓN AUXILIAR PARA LAS BARRAS ---
    function updateStatBar(idBase, value, overrideText = null) {
        let val = Math.floor(value);
        if (val > 100) val = 100;
        if (val < 0) val = 0;

        const bar = document.getElementById(idBase + '-bar');
        const txt = document.getElementById(idBase + '-val');

        if (bar) bar.style.width = val + '%';

        if (txt) {
            txt.textContent = overrideText ? overrideText : val + '%';

            // Si hay texto especial, lo ponemos en rojo brillante y negrita
            if (overrideText) {
                txt.style.color = "#ffffff";
                txt.style.fontWeight = "bold";
                txt.style.fontSize = "9px"; // Un pelín más pequeño para que quepa el texto largo
            } else {
                txt.style.color = "";
                txt.style.fontWeight = "";
                txt.style.fontSize = "";
            }
        }
    }

    window.openPlayerDetails = function (playerData) {
        const detailsModal = document.getElementById('player-details-modal');
        const mainMenu = document.getElementById('admin-menu');

        if (!detailsModal || !mainMenu) return;

        // --- LIMPIEZA INICIAL DE CONTENEDORES (Anti-Bucle) ---
        ['pd-properties-list', 'pd-vehicles-list', 'pd-punishments-list', 'pd-multichar-list'].forEach(id => {
            const el = document.getElementById(id);
            if (el) el.innerHTML = '<div class="pd-empty-state"><span class="iconify pd-empty-icon" data-icon="mdi:loading" style="animation: spin 1s linear infinite; display: inline-block;"></span><span>Cargando...</span></div>';
        });

        // Determinamos si está realmente online
        const isOnline = (playerData.id && playerData.id != 0 && !playerData.isOffline);

        if (playerData) {
            currentDetailsId = playerData.id;

            // 1. FIX BUG: LIMPIAR MEMORIA SI ES OTRO JUGADOR
            if (currentPlayerDataGlobal) {
                let isSamePlayer = false;
                if (playerData.citizenid && currentPlayerDataGlobal.citizenid === playerData.citizenid) isSamePlayer = true;
                if (playerData.id && currentPlayerDataGlobal.id === playerData.id) isSamePlayer = true;

                // Si NO es el mismo jugador, borramos la memoria para no cruzar datos
                if (!isSamePlayer) {
                    currentPlayerDataGlobal = null;
                }
            }

            // 2. RESCATAMOS LA LISTA DEL PERFIL ANTERIOR (Solo si es el mismo)
            // Como ya le hemos inyectado la lista en el paso anterior, ahora se guarda con ella.
            currentPlayerDataGlobal = playerData;

            if (isOnline) {
                fetch(`https://${GetParentResourceName()}/toggleWatch`, {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify({ targetId: playerData.id, state: true })
                });
            }
        }

        if (!isDetailsOpen) {
            isDetailsOpen = true;
            detailsModal.style.display = 'flex';
            detailsModal.classList.remove('details-closing');
            void detailsModal.offsetWidth;
            detailsModal.classList.add('details-active');
        }

        // --- 1. DATOS INICIALES (HEADER) ---
        if (playerData) {
            document.getElementById('pd-charname').textContent = playerData.name || "Jugador";
            document.getElementById('pd-ic-name').textContent = "Obteniendo datos...";

            const badgeEl = document.getElementById('pd-status-badge');
            if (badgeEl) {
                badgeEl.textContent = isOnline ? "EN LÍNEA" : "DESCONECTADO";
                badgeEl.className = isOnline ? "status-badge online" : "status-badge offline";
            }
        }

        // ============================================================
        // RESET VISUAL DE CAMPOS Y BOTONES
        // ============================================================
        document.getElementById('pd-bank').textContent = "...";
        document.getElementById('pd-citizenid').textContent = "...";
        document.getElementById('pd-phone').textContent = "...";
        document.getElementById('pd-identifiers').innerHTML = '<span>Cargando...</span>';

        // RESET DEL BOTÓN CONGELAR
        const freezeBtn = document.getElementById('pd-btn-freeze');
        if (freezeBtn) {
            freezeBtn.classList.remove('active');
            freezeBtn.innerHTML = 'CONGELAR';
            if (typeof actionStates !== 'undefined') actionStates.freeze = false;
        }

        // --- 2. PETICIÓN AL SERVIDOR ---
        fetch(`https://${GetParentResourceName()}/getPlayerFullDetails`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({
                targetId: playerData.id,
                citizenid: playerData.citizenid
            })
        })
            .then(resp => resp.json())
            .then(fullDataRaw => {
                // Manejo de respuesta vacía
                // Si el servidor falla (devuelve null/vacío)
                if (!fullDataRaw || (Object.keys(fullDataRaw).length === 0 && !fullDataRaw.data)) {
                    console.warn("Datos no disponibles para este personaje (Offline/Error SQL).");

                    // 1. Limpiamos la interfaz para que no ponga "Cargando..."
                    document.getElementById('pd-ic-name').textContent = playerData.charName || "Desconocido"; // Usamos el nombre que ya teníamos
                    document.getElementById('pd-bank').textContent = "Sin datos";
                    document.getElementById('pd-citizenid').textContent = playerData.citizenid || "?";
                    document.getElementById('pd-phone').textContent = "Sin datos";
                    document.getElementById('pd-job-label').textContent = "Sin datos";
                    document.getElementById('pd-gang-label').textContent = "Sin datos";

                    // 2. Ponemos mensajes de error en las listas de abajo
                    ['pd-properties-list', 'pd-vehicles-list', 'pd-punishments-list'].forEach(id => {
                        const el = document.getElementById(id);
                        if (el) el.innerHTML = '<div class="pd-empty-state"><span style="color:#aaa">Datos no disponibles</span></div>';
                    });

                    // --- 3. RECUPERAR LA LISTA MULTI-CHAR DE LA MEMORIA ---
                    const charList = document.getElementById('pd-multichar-list');
                    if (charList) {
                        charList.innerHTML = '';
                        if (currentPlayerDataGlobal && currentPlayerDataGlobal.relatedCharacters && currentPlayerDataGlobal.relatedCharacters.length > 0) {

                            // ORDENAR: El conectado (Online) se pone el primero en la lista
                            const sortedChars = [...currentPlayerDataGlobal.relatedCharacters].sort((a, b) => {
                                if (a.isOnlineChar && !b.isOnlineChar) return -1;
                                if (!a.isOnlineChar && b.isOnlineChar) return 1;
                                return 0; // El resto se queda en su orden normal de BD
                            });

                            sortedChars.forEach(char => {
                                // Marcamos como activo el que acabamos de clicar (aunque haya fallado la carga)
                                const isActive = (char.citizenid === playerData.citizenid);
                                const isOnlineChar = char.isOnlineChar;

                                const card = document.createElement('div');
                                card.className = `mini-char-card ${isActive ? 'active-profile' : ''} ${isOnlineChar ? 'is-online-char' : ''}`;

                                let html = `
                                <div class="mc-name" title="${char.name}">${char.name}</div>
                                <div class="mc-cid">${char.citizenid}</div>
                            `;
                                if (isOnlineChar) html += `<div class="mc-online-tag">ONLINE</div>`;

                                card.innerHTML = html;

                                // CLICK: Para poder volver al personaje online u otros
                                card.onclick = () => {
                                    if (isActive) return;

                                    // Importante: Usamos el nombre de Steam GLOBAL para no perderlo
                                    const steamName = currentPlayerDataGlobal.name;

                                    openPlayerDetails({
                                        id: isOnlineChar ? currentPlayerDataGlobal.id : null, // Si es el online, recuperamos su ID real
                                        citizenid: char.citizenid,
                                        name: steamName,
                                        charName: char.name,
                                        isOffline: !isOnlineChar
                                    });
                                };
                                charList.appendChild(card);
                            });
                        } else {
                            // DISEÑO PARA CUANDO NO TIENE PERSONAJES (NUEVO)
                            charList.innerHTML = `
                            <div style="height:100%; display:flex; flex-direction:column; align-items:center; justify-content:center; color:#444; padding: 20px;">
                                <span class="iconify" data-icon="mdi:account-off-outline" style="font-size:30px; opacity:0.2;"></span>
                                <span style="font-size:10px; font-weight:700; margin-top:5px; opacity:0.5; text-align:center;">SIN PERFILES<br>ASOCIADOS</span>
                            </div>`;
                        }
                    }

                    return; // Paramos aquí para que no explote el resto del script
                }

                const fullData = fullDataRaw.data ? fullDataRaw.data : fullDataRaw;

                // ============================================================
                // 🚨 ACTUALIZACIÓN DE MEMORIA GLOBAL (FIX CK)
                // ============================================================
                if (fullData) {
                    if (!currentPlayerDataGlobal) currentPlayerDataGlobal = {};
                    currentPlayerDataGlobal = { ...currentPlayerDataGlobal, ...fullData };
                    if (fullData.citizenid) currentPlayerDataGlobal.citizenid = fullData.citizenid;
                    if (fullData.identifiers) {
                        const licenseEntry = fullData.identifiers.find(id => id.includes('license:'));
                        if (licenseEntry) currentPlayerDataGlobal.license = licenseEntry;
                    }
                }

                // ============================================================
                // ❄️ NUEVO: LECTURA DEL ESTADO REAL DE CONGELACIÓN
                // ============================================================
                if (typeof actionStates === 'undefined') window.actionStates = {};

                // Leemos el estado del servidor
                actionStates.freeze = fullData.isFrozen || false;

                const freezeBtnReal = document.getElementById('pd-btn-freeze');
                if (freezeBtnReal) {
                    if (actionStates.freeze) {
                        freezeBtnReal.classList.add('active');
                        freezeBtnReal.innerHTML = 'DESCONGELAR';
                    } else {
                        freezeBtnReal.classList.remove('active');
                        freezeBtnReal.innerHTML = 'CONGELAR';
                    }
                }
                // ============================================================

                if (!fullData) {
                    ['pd-properties-list', 'pd-vehicles-list', 'pd-punishments-list'].forEach(id => {
                        document.getElementById(id).innerHTML = '<div class="pd-empty-state"><span>Datos no encontrados</span></div>';
                    });
                    return;
                }

                // Badge de desconectado (si viene de SQL)
                if (fullDataRaw.fromSQL || !fullData.id) {
                    const badgeEl = document.getElementById('pd-status-badge');
                    if (badgeEl) {
                        badgeEl.textContent = "DESCONECTADO";
                        badgeEl.className = "status-badge offline";
                    }
                }

                // ============================================================
                // RENDERIZADO DE PERFILES MULTI-PERSONAJE
                // ============================================================
                const charList = document.getElementById('pd-multichar-list');
                if (charList) {
                    charList.innerHTML = '';
                    if (fullData.relatedCharacters && fullData.relatedCharacters.length > 0) {

                        // ORDENAR: El conectado (Online) se pone el primero en la lista
                        const sortedChars = [...fullData.relatedCharacters].sort((a, b) => {
                            if (a.isOnlineChar && !b.isOnlineChar) return -1;
                            if (!a.isOnlineChar && b.isOnlineChar) return 1;
                            return 0; // El resto se queda en su orden normal de BD
                        });

                        sortedChars.forEach(char => {
                            const isActive = (char.citizenid === fullData.citizenid);
                            const isOnlineChar = char.isOnlineChar;

                            const card = document.createElement('div');
                            // Clases dinámicas para el CSS
                            card.className = `mini-char-card ${isActive ? 'active-profile' : ''} ${isOnlineChar ? 'is-online-char' : ''}`;

                            // Icono: Relleno si es el activo, contorno si no
                            const icon = isActive ? 'mdi:account' : 'mdi:account-outline';

                            // Estado: Verde si online, Gris si offline
                            const statusTitle = isOnlineChar ? 'Online' : 'Offline';

                            // --- ESTRUCTURA HTML (Icono + Info) ---
                            card.innerHTML = `
                                <div class="status-indicator" title="${statusTitle}"></div>
                                
                                <div class="mc-icon-box">
                                    <span class="iconify" data-icon="${icon}"></span>
                                </div>
                                
                                <div class="mc-info">
                                    <div class="mc-name" title="${char.name}">${char.name}</div>
                                    <div class="mc-cid">${char.citizenid}</div>
                                </div>
                            `;

                            // CLICK: Cambiar de perfil (Lógica intacta)
                            card.onclick = () => {
                                if (isActive) return;

                                // 1. Detectar ID
                                const targetId = isOnlineChar ? fullData.id : null;

                                // 2. Recuperar nombre Steam global
                                const steamName = currentPlayerDataGlobal ? currentPlayerDataGlobal.name : fullData.name;

                                // 3. Llamar a detalles
                                openPlayerDetails({
                                    id: targetId,
                                    citizenid: char.citizenid,
                                    name: steamName,
                                    charName: char.name,
                                    isOffline: !isOnlineChar
                                });
                            };
                            charList.appendChild(card);
                        });
                    } else {
                        charList.innerHTML = '<div class="pd-empty-state" style="font-size:10px; opacity:0.5;">Un solo perfil</div>';
                    }
                }

                // ============================================================
                // 🔒 NUEVO: GESTIÓN DE BOTONES DE ACCIÓN (BLOQUEO OFFLINE)
                // ============================================================
                const isViewingOfflineProfile = (fullDataRaw.fromSQL === true || !fullData.id);
                const actionButtons = document.querySelectorAll('.btn-action');
                const onlineOnlyIds = ['btn-kill', 'btn-revive', 'btn-freeze', 'btn-bring', 'btn-goto', 'btn-clothing'];

                actionButtons.forEach(btn => {
                    if (onlineOnlyIds.some(id => btn.id.includes(id))) {
                        if (isViewingOfflineProfile) {
                            btn.classList.add('action-disabled');
                            btn.title = "No disponible (Offline)";
                        } else {
                            btn.classList.remove('action-disabled');
                            btn.title = "";
                        }
                    }
                });

                // ============================================================
                // RENDERIZADO DE DATOS (MEJORADO CON SOPORTE JSON)
                // ============================================================

                // --- A) LÓGICA DE EXTRACCIÓN INTELIGENTE ---
                // 1. DINERO: Busca en 'money.bank', 'accounts.bank' o 'bank' directo
                let bankAmount = 0;
                if (typeof fullData.bank === 'number') {
                    bankAmount = fullData.bank;
                } else if (fullData.money && typeof fullData.money.bank !== 'undefined') {
                    bankAmount = fullData.money.bank; // QBCore
                } else if (fullData.accounts && typeof fullData.accounts.bank !== 'undefined') {
                    bankAmount = fullData.accounts.bank; // ESX
                }

                // 2. TELÉFONO: Busca en 'charinfo.phone' o 'phone' directo
                let phoneNumber = "Sin datos";
                if (fullData.phone) {
                    phoneNumber = fullData.phone;
                } else if (fullData.charinfo && fullData.charinfo.phone) {
                    phoneNumber = fullData.charinfo.phone; // QBCore
                }

                // 3. NOMBRE REAL: Si viene en charinfo, lo usamos preferentemente
                let realName = fullData.charName || playerData.charName || "Desconocido";
                if (fullData.charinfo && fullData.charinfo.firstname && fullData.charinfo.lastname) {
                    realName = `${fullData.charinfo.firstname} ${fullData.charinfo.lastname}`;
                }

                // --- B) ACTUALIZACIÓN DEL DOM ---
                // Nombre del personaje en la cabecera
                document.getElementById('pd-ic-name').textContent = realName;

                // Lista de campos (Info General)
                const fields = [
                    { id: 'pd-bank', val: `$${Math.floor(bankAmount).toLocaleString()}` },
                    { id: 'pd-citizenid', val: fullData.citizenid || "N/A" },
                    { id: 'pd-phone', val: phoneNumber },
                    { id: 'pd-job-label', val: `${fullData.job || '?'} | ${fullData.jobGrade || '?'}` },
                    { id: 'pd-gang-label', val: `${fullData.gang || '?'} | ${fullData.gangGrade || '?'}` }
                ];

                fields.forEach(f => {
                    const el = document.getElementById(f.id);
                    if (el) el.textContent = f.val;
                });

                // Mostrar/Ocultar iconos de Boss (Jefe)
                if (document.getElementById('pd-job-boss')) {
                    document.getElementById('pd-job-boss').style.display = fullData.isJobBoss ? 'block' : 'none';
                }
                if (document.getElementById('pd-gang-boss')) {
                    document.getElementById('pd-gang-boss').style.display = fullData.isGangBoss ? 'block' : 'none';
                }

                // --- C) ESTADÍSTICAS (STATS) ---
                // Mantenemos tu código original de las barras
                if (fullData.stats) {
                    updateStatBar('stat-health', fullData.stats.health || 0);
                    updateStatBar('stat-armor', fullData.stats.armor || 0);
                    updateStatBar('stat-hunger', fullData.stats.hunger || 0);
                    updateStatBar('stat-thirst', fullData.stats.thirst || 0);
                    updateStatBar('stat-alcohol', fullData.stats.alcohol || 0);
                    updateStatBar('stat-stamina', fullData.stats.stamina || 100);
                }

                // ===========================================
                // 3. RENDERIZADO DE PROPIEDADES (TU CÓDIGO)
                // ===========================================
                const propList = document.getElementById('pd-properties-list');
                const props = fullData.properties || [];
                const propCount = document.getElementById('pd-prop-count');
                const propLabel = document.getElementById('pd-prop-label');

                if (propCount) propCount.innerText = props.length;
                if (propLabel) propLabel.innerText = (props.length === 1) ? "PROPIEDAD" : "PROPIEDADES";

                if (propList) {
                    propList.innerHTML = '';
                    if (props.length === 0) {
                        propList.innerHTML = `
                        <div style="height:100%; display:flex; flex-direction:column; align-items:center; justify-content:center; color:#444;">
                            <span class="iconify" data-icon="mdi:home-off-outline" style="font-size:30px; opacity:0.2;"></span>
                            <span style="font-size:9px; font-weight:700; margin-top:5px; opacity:0.5;">SIN PROPIEDADES</span>
                        </div>`;
                    } else {
                        props.forEach(p => {
                            const hasCoords = (p.coords && typeof p.coords.x === 'number' && typeof p.coords.y === 'number');
                            const cx = hasCoords ? p.coords.x : 0;
                            const cy = hasCoords ? p.coords.y : 0;
                            const gpsBtnStyle = hasCoords ? '' : 'opacity: 0.3; cursor: not-allowed;';
                            const gpsAction = hasCoords ? `onclick="setGPS(${cx}, ${cy})"` : '';

                            const icon = p.type === 'house' ? 'mdi:home-variant-outline' : 'mdi:office-building-outline';
                            const garageClass = p.hasGarage ? 'badge-garage-yes' : 'badge-garage-no';
                            const garageText = p.hasGarage ? 'TIENE GARAJE' : 'NO GARAJE';
                            const rowClass = p.hasGarage ? 'row-active' : 'row-inactive';

                            const item = document.createElement('div');
                            item.className = `asset-item-row ${rowClass}`;
                            item.innerHTML = `
                            <div class="asset-icon-box">
                                <span class="iconify" data-icon="${icon}"></span>
                            </div>
                            <div class="asset-info">
                                <div class="asset-title">${p.label}</div>
                                <div class="asset-badges-row">
                                    <span class="pd-mini-badge badge-loc">${p.name}</span>
                                    <span class="pd-mini-badge ${garageClass}">${garageText}</span>
                                </div>
                            </div>
                            <button class="btn-gps-modern" style="${gpsBtnStyle}" ${gpsAction} title="${hasCoords ? 'Marcar GPS' : 'Sin ubicación'}">
                                <span class="iconify" data-icon="mdi:crosshairs-gps"></span>
                            </button>
                        `;
                            propList.appendChild(item);
                        });
                    }
                }

                // ===========================================
                // 4. RENDERIZADO DE VEHÍCULOS
                // ===========================================
                const vehList = document.getElementById('pd-vehicles-list');
                const vehs = fullData.vehicles || [];
                const vehCount = document.getElementById('pd-veh-count');
                const vehLabel = document.getElementById('pd-veh-label');

                if (vehCount) vehCount.innerText = vehs.length;
                if (vehLabel) vehLabel.innerText = (vehs.length === 1) ? "VEHÍCULO" : "VEHÍCULOS";

                if (vehList) {
                    vehList.innerHTML = '';
                    if (vehs.length === 0) {
                        vehList.innerHTML = `
                        <div style="height:100%; display:flex; flex-direction:column; align-items:center; justify-content:center; color:#444;">
                            <span class="iconify" data-icon="mdi:car-off" style="font-size:30px; opacity:0.2;"></span>
                            <span style="font-size:9px; font-weight:700; margin-top:5px; opacity:0.5;">A PIE</span>
                        </div>`;
                    } else {
                        const vehIcons = {
                            'car': 'mdi:car-sports', 'bike': 'mdi:motorbike', 'heli': 'mdi:helicopter',
                            'plane': 'mdi:airplane', 'boat': 'mdi:sail-boat', 'truck': 'mdi:truck', 'unknown': 'mdi:car'
                        };

                        vehs.forEach(v => {
                            const hasCoords = (v.coords && typeof v.coords.x === 'number' && typeof v.coords.y === 'number');
                            const cx = hasCoords ? v.coords.x : 0;
                            const cy = hasCoords ? v.coords.y : 0;
                            const gpsBtnStyle = hasCoords ? '' : 'opacity: 0.3; cursor: not-allowed;';
                            const gpsAction = hasCoords ? `onclick="setGPS(${cx}, ${cy})"` : '';

                            // NUEVA LÓGICA DE ICONOS DINÁMICOS
                            const catLower = (v.category || '').toLowerCase();
                            const modLower = (v.model || v.name || '').toLowerCase();
                            let dynIcon = 'mdi:car'; // Por defecto

                            if (modLower.includes('police') || modLower.includes('cop') || modLower.includes('sheriff') || modLower.includes('fib')) dynIcon = 'mdi:car-emergency';
                            else if (modLower.includes('ambulance') || modLower.includes('ems') || modLower.includes('medic')) dynIcon = 'mdi:ambulance';
                            else if (modLower.includes('taxi') || modLower.includes('cab')) dynIcon = 'mdi:taxi';
                            else if (catLower === 'emergency') dynIcon = 'mdi:car-emergency';
                            else if (['motorcycles', 'motorcycle'].includes(catLower) || modLower.includes('moto')) dynIcon = 'mdi:motorbike';
                            else if (['cycles', 'bicycles', 'bicycle'].includes(catLower) || modLower.includes('bmx')) dynIcon = 'mdi:bicycle';
                            else if (['helicopters', 'helicopter'].includes(catLower)) dynIcon = 'mdi:helicopter';
                            else if (['planes', 'plane'].includes(catLower)) dynIcon = 'mdi:airplane';
                            else if (['boats', 'boat'].includes(catLower)) dynIcon = 'mdi:sail-boat';
                            else if (['commercial', 'industrial', 'trucks', 'utility'].includes(catLower)) dynIcon = 'mdi:truck';

                            const isOut = !v.garage || v.garage === 'Out' || v.state === 0;
                            const rowClass = isOut ? 'row-active' : 'row-inactive';
                            const locationText = isOut ? "EN LA CALLE" : (v.garage || "GARAJE CENTRAL");
                            const plateText = v.plate || "S/P";

                            const item = document.createElement('div');
                            item.className = `asset-item-row ${rowClass}`;
                            item.innerHTML = `
                            <div class="asset-icon-box">
                                <span class="iconify" data-icon="${dynIcon}"></span>
                            </div>
                            <div class="asset-info">
                                <div class="asset-title">${v.label || v.name}</div>
                                <div class="asset-badges-row">
                                    <span class="pd-mini-badge badge-plate">${plateText}</span>
                                    <span class="pd-mini-badge badge-loc">${locationText}</span>
                                </div>
                            </div>
                            <button class="btn-gps-modern" style="${gpsBtnStyle}" ${gpsAction} title="${hasCoords ? 'Marcar GPS' : 'Ubicación desconocida'}">
                                <span class="iconify" data-icon="mdi:crosshairs-gps"></span>
                            </button>
                            `;
                            vehList.appendChild(item);
                        });
                    }
                }

                // ===========================================
                // 5. RENDERIZADO DE SANCIONES (TU CÓDIGO)
                // ===========================================
                const punishList = document.getElementById('pd-punishments-list');
                const punishCounts = fullData.punishCounts || { bans: 0, kicks: 0, warns: 0 }; // NUEVO: Extraemos los contadores

                // NUEVO: Actualizamos los Badges del HTML
                const countBansEl = document.getElementById('pd-count-bans');
                const countKicksEl = document.getElementById('pd-count-kicks');
                const countWarnsEl = document.getElementById('pd-count-warns');

                if (countBansEl) countBansEl.textContent = punishCounts.bans;
                if (countKicksEl) countKicksEl.textContent = punishCounts.kicks;
                if (countWarnsEl) countWarnsEl.textContent = punishCounts.warns;

                if (punishList) {
                    punishList.innerHTML = '';
                    const history = fullData.history || [];

                    if (history.length === 0) {
                        punishList.innerHTML = `
                        <div style="height:100%; display:flex; flex-direction:column; align-items:center; justify-content:center; color:#444;">
                            <span class="iconify" data-icon="mdi:shield-check-outline" style="font-size:40px; opacity:0.2;"></span>
                            <span style="font-size:10px; font-weight:700; margin-top:5px; opacity:0.5;">LIMPIO</span>
                        </div>`;
                    } else {
                        history.forEach(h => {
                            let rowClass = "row-warn"; // Clase por defecto
                            let statusLabel = "WARN";
                            let icon = "mdi:alert-circle-outline";

                            if (h.type === 'BAN') {
                                rowClass = "row-ban";
                                statusLabel = "BAN";
                                icon = "mdi:gavel";

                            } else if (h.type === 'KICK') {
                                rowClass = "row-kick";
                                statusLabel = "KICK";
                                icon = "mdi:door-open";

                            } else if (h.type === 'CK') {
                                rowClass = "row-ck"; // Necesitarás crear esta clase en CSS si quieres borde rojo oscuro
                                statusLabel = "CK";
                                icon = "mdi:skull-crossbones";
                            }

                            const item = document.createElement('div');
                            item.className = `punish-item-row ${rowClass}`;
                            item.innerHTML = `
                                <div class="punish-icon-box">
                                    <span class="iconify" data-icon="${icon}"></span>
                                </div>
                                <div class="punish-main-info">
                                    <div class="punish-reason">${h.reason || 'Sin motivo'}</div>
                                    <div class="punish-meta">
                                        <span>POR: <strong>${h.admin || '?'}</strong></span>
                                    </div>
                                </div>
                                <div class="punish-date-box">
                                    <div class="punish-status-text">${statusLabel}</div>
                                    <div class="punish-date">${h.date}</div>
                                </div>
                            `;
                            punishList.appendChild(item);
                        });
                    }
                }

                // 6. IDENTIFICADORES
                const idList = document.getElementById('pd-identifiers');
                if (idList) {
                    idList.classList.remove('revealed');
                    if (fullData.identifiers && fullData.identifiers.length > 0) {
                        idList.textContent = `[${fullData.identifiers.join(', ')}]`;
                    } else {
                        idList.textContent = '[Sin identificadores]';
                    }
                }
            })
            .catch(err => console.error("Error en Fetch Details:", err));

        if (typeof syncDetailsPosition === 'function') syncDetailsPosition();
    };

    window.closePlayerDetails = function () {
        // Detener rastreo para ahorrar recursos
        fetch(`https://${GetParentResourceName()}/toggleWatch`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ targetId: null, state: false })
        });

        currentDetailsId = null;

        const detailsModal = document.getElementById('player-details-modal');

        // Solo cerramos si está visible
        if (detailsModal && isDetailsOpen) {
            isDetailsOpen = false;

            // Quitamos la clase de entrada y ponemos la de salida
            detailsModal.classList.remove('details-active');
            detailsModal.classList.add('details-closing');

            // Esperamos a que termine la animación (300ms) antes de hacer display:none
            setTimeout(() => {
                if (!isDetailsOpen) {
                    detailsModal.style.display = 'none';
                    detailsModal.classList.remove('details-closing');
                }
            }, 300);
        }
    };

    function syncDetailsPosition() {
        if (!isDetailsOpen) return;

        const mainMenu = document.getElementById('admin-menu');
        const detailsModal = document.querySelector('.player-details-container');
        if (!mainMenu || !detailsModal) return;

        // --- CONFIGURACIÓN DINÁMICA ---
        const ESCALA_BASE = 90;
        const scale = currentScale / ESCALA_BASE;
        const gap = 15;
        const minWidth = 350;
        const viewportWidth = window.innerWidth;

        const menuRect = mainMenu.getBoundingClientRect();
        let currentWidth = detailsModal.offsetWidth;
        let realVisibleWidth = currentWidth * scale;

        let targetLeft = 0;
        let shouldHide = false;

        detailsModal.style.transformOrigin = 'top left';

        // ==========================================
        // CÁLCULO DE ALTURA IGUALADA
        // ==========================================
        // menuRect.height es la altura REAL que se ve en pantalla (ya escalada).
        // Dividimos por la escala del panel para que al aplicarse el transform, 
        // la altura final coincida píxel por píxel con el menú.
        let targetHeight = menuRect.height / scale;

        // A. LADO IZQUIERDO
        if (menuRect.left > (realVisibleWidth + gap)) {
            targetLeft = menuRect.left - realVisibleWidth - gap;
        }
        // B. LADO DERECHO
        else if ((viewportWidth - menuRect.right) > (realVisibleWidth + gap)) {
            targetLeft = menuRect.right + gap;
        }
        // C. MODO SQUEEZE
        else {
            const spaceLeft = menuRect.left - gap;
            const spaceRight = viewportWidth - menuRect.right - gap;

            if (spaceLeft > spaceRight) {
                let dynamicWidth = spaceLeft / scale;
                let finalW = Math.max(minWidth, dynamicWidth);
                detailsModal.style.width = finalW + "px";
                targetLeft = menuRect.left - (finalW * scale) - gap;
            } else {
                let dynamicWidth = spaceRight / scale;
                detailsModal.style.width = Math.max(minWidth, dynamicWidth) + "px";
                targetLeft = menuRect.right + gap;
            }

            if (spaceLeft < 100 && spaceRight < 100) shouldHide = true;
        }

        if (shouldHide) {
            detailsModal.style.opacity = "0";
            detailsModal.style.pointerEvents = "none";
        } else {
            detailsModal.style.opacity = "1";
            detailsModal.style.pointerEvents = "all";
            detailsModal.style.display = "flex";

            detailsModal.style.transform = `scale(${scale})`;
            detailsModal.style.top = menuRect.top + "px";
            detailsModal.style.left = targetLeft + "px";

            // Aplicamos la altura calculada
            detailsModal.style.height = targetHeight + "px";
        }
    }

    // LISTENER PARA MOVER EL MODAL JUNTO AL MENÚ
    document.addEventListener('mousemove', (e) => {
        // Si estamos arrastrando el menú principal y el detalle está abierto...
        if (isDragging && isDetailsOpen) {
            syncDetailsPosition();
        }
    });

    // Hacer que los valores se copien al portapapeles al hacer doble click
    document.querySelectorAll('.pd-value').forEach(el => {
        el.addEventListener('dblclick', function () {
            const text = this.innerText.replace('$', '').replace(/,/g, ''); // Limpiamos formato si es dinero
            const textArea = document.createElement("textarea");
            textArea.value = text;
            document.body.appendChild(textArea);
            textArea.select();
            document.execCommand("copy");
            textArea.remove();

            // Opcional: Notificación visual rápida en el texto
            const originalText = this.innerText;
            this.innerText = "¡COPIADO!";
            this.style.color = "var(--primary)";
            setTimeout(() => {
                this.innerText = originalText;
                this.style.color = "";
            }, 800);
        });
    });

    // Variables de estado para los modales reutilizados
    let mapTargetId = null;

    window.playerAction = (action) => {
        // Validar que tenemos un objetivo
        if (!currentDetailsId) {
            log("Error: No hay jugador seleccionado");
            return;
        }

        // ============================================================
        // 0. INTERCEPTOR DE SANCIONES (BAN / KICK / WARN)
        // ============================================================
        if (action === 'kick' || action === 'warn' || action === 'ban') {
            openSanctionInput(action); // <-- Llamamos a la función del modal nuevo
            return; // IMPORTANTE: Detiene la ejecución aquí
        }

        if (action === 'ck') return; // Ignoramos CK por ahora


        // --- 1. Interceptamos acciones de Dinero y Dimensión para abrir el modal
        const moneyActions = ['add_cash', 'remove_cash', 'add_bank', 'remove_bank', 'add_crypto', 'remove_crypto'];

        if (moneyActions.includes(action) || action === 'dimension_menu') {
            // Si es 'dimension_menu', el segundo parámetro es null. Si es dinero, pasamos la acción.
            const mode = (action === 'dimension_menu') ? null : action;
            openDimensionModal(currentDetailsId, mode);
            return;
        }

        // --- 2. INTERCEPTOR PARA MAPA TÁCTICO ---
        if (action === 'tactical_map') {
            mapTargetId = currentDetailsId;
            const mainMenu = document.getElementById('admin-menu');
            if (mainMenu) mainMenu.style.display = 'none';

            if (typeof triggerMapOpen === 'function') {
                triggerMapOpen();
            }
            return;
        }

        // --- 3. INTERCEPTORES DE GESTIÓN (TRABAJO/BANDA) ---
        if (action === 'set_job' || action === 'set_gang') {
            const nameEl = document.getElementById('pd-charname');
            const name = nameEl ? nameEl.textContent : "Jugador";
            if (action === 'set_job') openJobManageModal(currentDetailsId, name);
            else openGangManageModal(currentDetailsId, name);
            return;
        }

        // --- 4. INTERCEPTOR PARA DIMENSIONES ---
        // (Nota: Ya estaba cubierto en el punto 1, pero si lo tienes separado, déjalo)
        if (action === 'dimension_menu') {
            currentMoneyAction = null; // Nos aseguramos de limpiar el modo dinero
            openDimensionModal(currentDetailsId);
            return;
        }

        // --- 5. INTERCEPTOR PARA SCREENSHOT ---
        if (action === 'screenshot') {
            openScreenshotModal(); // 1. Arranca la cinemática en el HTML

            // 2. Avisamos al servidor PARA QUE SAQUE LA FOTO AHORA MISMO
            fetch(`https://${GetParentResourceName()}/playerAction`, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({
                    action: 'screenshot',
                    targetId: currentDetailsId
                })
            }).catch(err => console.error("Error pidiendo screenshot:", err));

            return; // 3. Paramos aquí para no enviar un segundo fetch en el punto 7
        }

        // --- 6. INTERCEPTOR PARA CONTROLAR JUGADOR (VISUAL) ---
        if (action === 'control_player') {
            // 1. Cambiamos el estado true/false
            actionStates.control_player = !actionStates.control_player;

            // 2. Actualizamos el botón visualmente (Verde SI/NO)
            const btn = document.getElementById('btn-control-player');
            if (btn) {
                actionStates.control_player ? btn.classList.add('active') : btn.classList.remove('active');
            }

            // NO hacemos return. Dejamos que el código siga baje al "Fetch Genérico"
            // así envía automáticamente { action: 'control_player', targetId: ID } al Lua.
        }

        // --- 7. INTERCEPTOR PARA CONGELAR ---
        if (action === 'freeze') {
            // Inicializamos el estado si no existe
            if (typeof actionStates.freeze === 'undefined') {
                actionStates.freeze = false;
            }

            // Invertimos el estado
            actionStates.freeze = !actionStates.freeze;

            // Cambiamos la acción real que se envía al servidor
            const realAction = actionStates.freeze ? 'freeze' : 'unfreeze';

            // Actualizamos el botón visualmente
            const freezeBtn = document.getElementById('pd-btn-freeze');
            if (freezeBtn) {
                if (actionStates.freeze) {
                    freezeBtn.classList.add('active'); // O ponle la clase que lo ponga azul/rojo
                    freezeBtn.innerHTML = 'DESCONGELAR';
                } else {
                    freezeBtn.classList.remove('active');
                    freezeBtn.innerHTML = 'CONGELAR';
                }
            }

            // Enviamos la petición modificada y SALIMOS para que no haga el envío genérico doble
            fetch(`https://${GetParentResourceName()}/playerAction`, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({
                    action: realAction,
                    targetId: currentDetailsId
                })
            });
            return;
        }

        // --- ENVÍO GENÉRICO (Resto de botones: Revive, Kill, Freeze, etc.) ---
        fetch(`https://${GetParentResourceName()}/playerAction`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({
                action: action,
                targetId: currentDetailsId
            })
        });
    };

    // ==========================================================================
    // MENÚ TROLL - LÓGICA
    // ==========================================================================
    window.openTrollMenu = function () {
        if (!currentDetailsId) return;
        const modal = document.getElementById('troll-menu-modal');
        const nameSpan = document.getElementById('troll-target-name');

        // Ponemos el nombre del jugador al que vamos a trollear
        if (nameSpan && currentPlayerDataGlobal) {
            nameSpan.innerText = currentPlayerDataGlobal.name || "Desconocido";
        }

        if (modal) {
            modal.classList.remove('troll-closing'); // Aseguramos que no tenga la clase de salida
            modal.style.display = 'flex';
        }
    };

    window.closeTrollMenu = function () {
        const modal = document.getElementById('troll-menu-modal');
        if (modal) {
            // Añadimos la clase para que inicie la animación de salida
            modal.classList.add('troll-closing');

            // Esperamos 200ms (lo que dura la animación zoomOut en CSS) antes de ocultarlo
            setTimeout(() => {
                modal.style.display = 'none';
                modal.classList.remove('troll-closing');
            }, 200);
        }
    };

    window.trollAction = function (actionType) {
        if (!currentDetailsId) return;

        // Enviamos la petición al cliente
        fetch(`https://${GetParentResourceName()}/trollAction`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({
                action: actionType,
                targetId: currentDetailsId
            })
        }).catch(err => console.error("Error ejecutando acción troll:", err));
    };

    // ==========================================================================
    // LÓGICA DE CAPTURA DE PANTALLA (CINEMÁTICA 5 SEGUNDOS)
    // ==========================================================================

    const screenshotModal = document.getElementById('screenshot-modal');
    const screenshotWrapper = document.getElementById('screenshot-wrapper');
    const screenshotImg = document.getElementById('screenshot-img');
    const screenshotLoader = document.getElementById('screenshot-loader');
    const loaderText = document.getElementById('loader-text');

    let isImageReceived = false;
    let isTimeCompleted = false;
    let activeTimeouts = [];

    // 1. ABRIR MODAL E INICIAR LA CUENTA ATRÁS
    function openScreenshotModal() {
        if (!screenshotModal) return;

        screenshotModal.style.display = 'flex';
        screenshotLoader.style.display = 'flex';
        screenshotWrapper.style.display = 'none';
        screenshotWrapper.classList.remove('printing-active');

        if (loaderText) loaderText.innerText = "RECIBIENDO DATOS...";
        if (screenshotImg) screenshotImg.src = "";

        isImageReceived = false;
        isTimeCompleted = false;

        // Timer 1: A los 2.5 segundos cambiamos el texto
        let t1 = setTimeout(() => {
            if (loaderText) loaderText.innerText = "CARGANDO IMAGEN...";
        }, 2500);

        // Timer 2: A los 5 segundos, intentamos mostrar la foto
        let t2 = setTimeout(() => {
            isTimeCompleted = true;
            tryShowScreenshot();
        }, 5000);

        activeTimeouts.push(t1, t2);
    }

    // 2. INTENTAR MOSTRAR
    function tryShowScreenshot() {
        if (isImageReceived && isTimeCompleted) {
            if (screenshotLoader) screenshotLoader.style.display = 'none';

            if (screenshotWrapper) {
                screenshotWrapper.style.display = 'flex';
                setTimeout(() => {
                    screenshotWrapper.classList.add('printing-active');
                }, 50);
            }
        }
    }

    // 3. CERRAR MODAL
    window.closeScreenshotModal = () => {
        if (screenshotModal) {
            screenshotModal.style.display = 'none';
            activeTimeouts.forEach(t => clearTimeout(t));
            activeTimeouts = [];
        }
    };

    // ==========================================================================
    // LÓGICA MULTIUSO: DIMENSIONES Y DINERO (MODAL DINÁMICO PREMIUM)
    // ==========================================================================
    const dimModal = document.getElementById('dimension-modal');
    const dimInput = document.getElementById('dim-input');
    let selectedDimTarget = null;
    let currentMoneyAction = null; // Variable para saber si es Dinero o Dimensión

    // ABRIR EL MODAL
    window.openDimensionModal = (targetId, action = null) => {
        selectedDimTarget = targetId;
        currentMoneyAction = action;

        // Seleccionamos los elementos del nuevo diseño Premium por ID
        const title = document.getElementById('dim-modal-title');
        const desc = document.getElementById('dim-modal-desc');
        const label = document.getElementById('dim-modal-label');
        const btn = document.getElementById('btn-set-dimension');

        // Elementos visuales dinámicos
        const icon = document.getElementById('dim-modal-icon');
        const iconBg = document.getElementById('dim-icon-bg');
        const inputIcon = document.getElementById('dim-input-icon');

        if (action) {
            // --- MODO DINERO / CRIPTO ---
            const config = {
                add_cash: { t: "DAR EFECTIVO", d: "Añade dinero físico a la billetera.", l: "CANTIDAD EN $", b: "ENTREGAR DINERO", i: "mdi:cash-multiple", c: "rgba(14, 160, 33, 0.1)", bc: "rgba(14, 160, 33, 0.3)", ic: "#0ea021" },
                remove_cash: { t: "QUITAR EFECTIVO", d: "Retira dinero de la billetera.", l: "CANTIDAD EN $", b: "QUITAR DINERO", i: "mdi:cash-remove", c: "rgba(255, 68, 68, 0.1)", bc: "rgba(255, 68, 68, 0.3)", ic: "#ffffff" },
                add_bank: { t: "DAR BANCO", d: "Añade fondos a la cuenta bancaria.", l: "CANTIDAD EN $", b: "INGRESAR AL BANCO", i: "mdi:bank", c: "rgba(0, 136, 255, 0.1)", bc: "rgba(0, 136, 255, 0.3)", ic: "#0088ff" },
                remove_bank: { t: "QUITAR BANCO", d: "Retira fondos de la cuenta bancaria.", l: "CANTIDAD EN $", b: "RESTAR DEL BANCO", i: "mdi:bank-minus", c: "rgba(255, 68, 68, 0.1)", bc: "rgba(255, 68, 68, 0.3)", ic: "#ffffff" },
                add_crypto: { t: "DAR CRIPTO", d: "Añade criptomonedas al balance.", l: "CANTIDAD DE CRIPTOS", b: "ENTREGAR CRIPTOS", i: "mdi:bitcoin", c: "rgba(214, 129, 0, 0.1)", bc: "rgba(214, 129, 0, 0.3)", ic: "#d68100" },
                remove_crypto: { t: "QUITAR CRIPTO", d: "Retira criptomonedas del balance.", l: "CANTIDAD DE CRIPTOS", b: "QUITAR CRIPTOS", i: "mdi:currency-btc", c: "rgba(255, 68, 68, 0.1)", bc: "rgba(255, 68, 68, 0.3)", ic: "#ffffff" }
            };
            const c = config[action];
            title.innerText = c.t;
            desc.innerText = c.d;
            label.innerText = c.l;
            btn.innerText = c.b;
            dimInput.value = "";
            dimInput.placeholder = "0";

            // Aplicar estilos e iconos según la acción
            icon.setAttribute('data-icon', c.i);
            inputIcon.setAttribute('data-icon', 'mdi:currency-usd');
            iconBg.style.background = c.c;
            iconBg.style.borderColor = c.bc;
            icon.style.color = c.ic;

        } else {
            // --- MODO DIMENSIÓN (Default) ---
            title.innerText = "VIAJE DIMENSIONAL";
            desc.innerHTML = 'Estás a punto de mover a este jugador a una realidad paralela.<br><strong style="color: #fff;">Dimensión 0</strong> es el mundo normal.';
            label.innerText = "NÚMERO DE DIMENSIÓN";
            btn.innerText = "MANDAR A LA DIMENSIÓN";
            dimInput.value = "0";

            // Restaurar iconos y colores a modo neutro/blanco
            icon.setAttribute('data-icon', 'mdi:earth');
            inputIcon.setAttribute('data-icon', 'mdi:rotate-3d');
            iconBg.style.background = 'rgba(255, 255, 255, 0.05)';
            iconBg.style.borderColor = 'rgba(255, 255, 255, 0.1)';
            icon.style.color = '#fff';
        }

        if (dimModal) dimModal.style.display = 'flex';
        setTimeout(() => dimInput.focus(), 100);
    }

    window.closeDimensionModal = () => {
        if (dimModal) dimModal.style.display = 'none';
        selectedDimTarget = null;
        currentMoneyAction = null;
    }

    // EL BOTÓN DE CONFIRMACIÓN (Dual)
    const btnDim = document.getElementById('btn-set-dimension');
    if (btnDim) {
        btnDim.onclick = () => {
            if (!selectedDimTarget) return;
            let val = parseInt(dimInput.value);

            if (currentMoneyAction) {
                // CASO DINERO
                if (isNaN(val) || val < 1) return;
                fetch(`https://${GetParentResourceName()}/playerAction`, {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify({
                        action: currentMoneyAction,
                        targetId: selectedDimTarget,
                        amount: val
                    })
                });
            } else {
                // CASO DIMENSIÓN
                if (isNaN(val) || val < 0) val = 0;
                fetch(`https://${GetParentResourceName()}/setDimension`, {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify({ targetId: selectedDimTarget, bucket: val })
                });
            }
            closeDimensionModal();
        };
    }

    // ==========================================================================
    //      SISTEMA GPS (NECESARIO PARA EL BOTÓN)
    // ==========================================================================
    window.setGPS = function (x, y) {
        // 1. Convertimos a float (Decimales) para asegurar que son números
        const lat = parseFloat(x);
        const lon = parseFloat(y);

        // 2. Validación de seguridad:
        // - isNaN: Si no es un número válido
        // - (0,0): Si son las coordenadas "null island" (error común)
        if (isNaN(lat) || isNaN(lon) || (lat === 0 && lon === 0)) {
            console.error("[GPS] Error: Coordenadas inválidas recibidas:", x, y);
            return; // No hacemos nada
        }

        // 3. Enviamos al Lua (Client) datos limpios
        fetch(`https://${GetParentResourceName()}/setGPS`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({
                x: lat,
                y: lon
            })
        });
    };

    // ==========================================================================
    //      SISTEMA DE SANCIONES (DEBUG VERSION)
    // ==========================================================================

    // 1. ABRIR EL MODAL DE INPUT
    function openSanctionInput(type) {
        log(`[DP-AdminMenu] Abriendo modal para: ${type}`); // DEBUG

        if (!currentDetailsId && !currentPlayerDataGlobal) {
            log("[DP-AdminMenu] No hay datos de jugador (currentDetailsId o Global perdidos)");
            return;
        }

        pendingSanction.type = type;
        pendingSanction.targetId = currentDetailsId;

        if (currentPlayerDataGlobal) {
            pendingSanction.citizenid = currentPlayerDataGlobal.citizenid;
        }

        const modal = document.getElementById('sanction-modal');
        if (!modal) return log("[DP-AdminMenu] No encuentro el div 'sanction-modal' en el HTML");

        // Resetear campos
        document.getElementById('sanction-reason').value = "";
        document.getElementById('ban-time-val').value = "";
        modal.style.display = 'flex';

        // Textos
        const title = document.getElementById('sanction-title');
        const durationGroup = document.getElementById('ban-duration-group');

        if (type === 'kick') {
            title.innerText = "EXPULSAR JUGADOR (KICK)";
            durationGroup.style.display = 'none';
        } else if (type === 'warn') {
            title.innerText = "ENVIAR ADVERTENCIA (WARN)";
            durationGroup.style.display = 'none';
        } else if (type === 'ban') {
            title.innerText = "BANEAR JUGADOR (BAN)";
            durationGroup.style.display = 'block';
        }
    }

    // Funciones globales para cerrar (HTML onclick)
    window.closeSanctionModal = () => { document.getElementById('sanction-modal').style.display = 'none'; };
    window.closeConfirmSanctionModal = () => { document.getElementById('confirm-sanction-modal').style.display = 'none'; };

    // ==========================================================================
    //      INICIALIZACIÓN SEGURA DE BOTONES (DISEÑO PREMIUM)
    // ==========================================================================
    function initSanctionButtons() {
        log("[DP-AdminMenu] Inicializando botones de sanción...");

        const btnNext = document.getElementById('btn-sanction-next');
        const btnExecute = document.getElementById('btn-sanction-execute');
        const btnCk = document.getElementById('btn-ck-player');

        if (!btnNext) console.error("[DP-AdminMenu] No encuentro el botón 'btn-sanction-next'");
        if (!btnExecute) console.error("[DP-AdminMenu] No encuentro el botón 'btn-sanction-execute'");

        // ----------------------------------------------------------------------
        // 1. LÓGICA BOTÓN CK (DISEÑO ROJO Y PELIGROSO)
        // ----------------------------------------------------------------------
        if (btnCk) {
            const newCk = btnCk.cloneNode(true);
            btnCk.parentNode.replaceChild(newCk, btnCk);

            newCk.addEventListener('click', () => {
                if (!currentPlayerDataGlobal) return log("No hay datos de jugador para CK");

                pendingSanction = {
                    type: 'ck',
                    targetId: currentPlayerDataGlobal.id,
                    citizenid: currentPlayerDataGlobal.citizenid,
                    reason: "CK - Eliminación Total"
                };

                const msgEl = document.getElementById('confirm-sanction-msg');

                // HTML PREMIUM PARA CK
                msgEl.innerHTML = `
                    <div class="confirm-summary-box">
                        <div class="confirm-row">
                            <span class="c-label">JUGADOR</span>
                            <span class="c-value">${currentPlayerDataGlobal.name}</span>
                        </div>
                        <div class="confirm-row">
                            <span class="c-label">ACCIÓN</span>
                            <span class="c-badge ck">CHARACTER KILL</span>
                        </div>
                        <div class="confirm-row">
                            <span class="c-label">CITIZEN ID</span>
                            <span class="c-value">${currentPlayerDataGlobal.citizenid}</span>
                        </div>
                    </div>

                    <div class="danger-alert-box">
                        <span class="iconify danger-icon" data-icon="mdi:alert-decagram"></span>
                        <div class="danger-text">
                            <b>⚠️ ADVERTENCIA IRREVERSIBLE</b><br>
                            Se generará un <u><strong>Backup Completo</strong></u> en el archivo <strong>ck_backups.json</strong> y se borrarán:<br>
                            • Personaje, Cuentas Bancarias.<br>
                            • Vehículos, Casas y sus inventarios.<br>
                            • Básicamente todo lo que tenga que ver con el jugador seleccionado.<br>
                        </div>
                    </div>
                `;

                closeSanctionModal();

                const modalContainer = document.querySelector('.sanction-modal-container');
                if (modalContainer) {
                    modalContainer.classList.remove('is-standard');
                    modalContainer.classList.add('is-ck');
                }

                document.getElementById('confirm-sanction-modal').style.display = 'flex';
            });
        }

        // ----------------------------------------------------------------------
        // 2. LÓGICA BOTÓN "CONTINUAR" (DISEÑO LIMPIO PARA WARN/BAN/KICK)
        // ----------------------------------------------------------------------
        if (btnNext) {
            const newBtn = btnNext.cloneNode(true);
            btnNext.parentNode.replaceChild(newBtn, btnNext);

            newBtn.addEventListener('click', () => {
                const reason = document.getElementById('sanction-reason').value;

                if (!reason || reason.trim().length < 2) {
                    const area = document.getElementById('sanction-reason');
                    area.style.border = "1px solid red";
                    setTimeout(() => area.style.border = "1px solid #555", 2000);
                    return;
                }

                // Lógica BAN
                let durationText = "N/A";
                if (pendingSanction.type === 'ban') {
                    const timeVal = document.getElementById('ban-time-val').value;
                    const timeUnit = document.getElementById('ban-time-unit').value;

                    if (timeUnit !== 'perm' && (!timeVal || timeVal <= 0)) {
                        document.getElementById('ban-time-val').style.border = "1px solid red";
                        return;
                    }

                    if (timeUnit === 'perm') {
                        pendingSanction.duration = 2147483647;
                        durationText = "PERMANENTE";
                    } else {
                        pendingSanction.duration = parseInt(timeVal) * parseInt(timeUnit);
                        // Texto bonito para duración
                        const unitLabel = (timeUnit == 3600) ? "Horas" : (timeUnit == 86400) ? "Días" : "Meses";
                        durationText = `${timeVal} ${unitLabel}`;
                    }
                }

                // Preparar HTML PREMIUM
                const msgEl = document.getElementById('confirm-sanction-msg');
                const typeUpper = pendingSanction.type.toUpperCase();
                const badgeClass = pendingSanction.type; // 'warn', 'kick', 'ban'

                // HTML LIMPIO
                let htmlContent = `
                    <div class="confirm-summary-box">
                        <div class="confirm-row">
                            <span class="c-label">OBJETIVO</span>
                            <span class="c-value">${currentPlayerDataGlobal ? currentPlayerDataGlobal.name : 'Desconocido'}</span>
                        </div>
                        <div class="confirm-row">
                            <span class="c-label">TIPO SANCIÓN</span>
                            <span class="c-badge ${badgeClass}">${typeUpper}</span>
                        </div>
                `;

                // Si es BAN, añadimos fila de duración
                if (pendingSanction.type === 'ban') {
                    htmlContent += `
                        <div class="confirm-row">
                            <span class="c-label">DURACIÓN</span>
                            <span class="c-value" style="color:#ffcc00">${durationText}</span>
                        </div>
                    `;
                }

                // Añadimos el motivo al final
                htmlContent += `
                        <div class="confirm-row">
                            <span class="c-label">MOTIVO</span>
                            <span class="c-value reason-text" title="${reason}">${reason}</span>
                        </div>
                    </div>
                `;

                msgEl.innerHTML = htmlContent;

                pendingSanction.reason = reason;
                closeSanctionModal();

                const modalContainer = document.querySelector('.sanction-modal-container');
                if (modalContainer) {
                    modalContainer.classList.remove('is-ck');
                    modalContainer.classList.add('is-standard');
                }

                document.getElementById('confirm-sanction-modal').style.display = 'flex';
            });
        }

        // ----------------------------------------------------------------------
        // 3. LÓGICA BOTÓN "CONFIRMAR" (IGUAL QUE ANTES)
        // ----------------------------------------------------------------------
        if (btnExecute) {
            const newExec = btnExecute.cloneNode(true);
            btnExecute.parentNode.replaceChild(newExec, btnExecute);

            newExec.addEventListener('click', () => {
                log("[DP-AdminMenu] Click en CONFIRMAR. Enviando fetch...");
                if (isProcessingAction) return;
                isProcessingAction = true;

                let endpoint = 'kickPlayer';
                if (pendingSanction.type === 'ck') endpoint = 'ckPlayer';
                else if (pendingSanction.type === 'warn') endpoint = 'warnPlayer';
                else if (pendingSanction.type === 'ban') endpoint = 'banPlayer';

                const payload = {
                    targetId: pendingSanction.targetId,
                    citizenid: pendingSanction.citizenid,
                    reason: pendingSanction.reason,
                    duration: pendingSanction.duration,
                    license: currentPlayerDataGlobal ? currentPlayerDataGlobal.license : null
                };

                fetch(`https://${GetParentResourceName()}/${endpoint}`, {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify(payload)
                }).then(resp => resp.text())
                    .then(respText => {
                        log("[DP-AdminMenu] Respuesta Server:", respText);
                        closeConfirmSanctionModal();
                        isProcessingAction = false;
                    }).catch(err => {
                        console.error("[DP-AdminMenu] Error en el FETCH:", err);
                        isProcessingAction = false;
                        closeConfirmSanctionModal();
                    });
            });
        }
    }

    // Llamamos a la inicialización cuando el script carga (con un pequeño delay para asegurar HTML)
    setTimeout(initSanctionButtons, 500);

}); // FIN DEL DOMContentLoaded