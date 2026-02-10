Config = {}

-- =========================================
--      MODO DEBUG (TRUE = VER LOGS EN F8)
-- =========================================
Config.Debug = false

-- =========================================
--      CONFIGURACION DE COMANDOS
-- =========================================
Config.Commands = {
    Admin = "dpadmin",
    Report = "dpreports",
    -- Comando de emergencia (Solo consola)
    EmergencyWhitelist = "togglewhitelist_emergency"
}

-- =========================================
--      CONFIGURACION DE WHITELIST
-- =========================================
Config.Whitelist = {
    -- Si 'ForceUnlock' es true, la whitelist se desactiva ignorando la base de datos.
    -- Útil si te quedas fuera y no tienes acceso a la consola (se cambia desde el archivo y se reinicia el script).
    ForceUnlock = false,

    -- Permisos que BYPASSEAN la whitelist (no son expulsados)
    BypassRoles = {"god", "admin", "mod" -- Puedes añadir "whitelist" aquí si creas ese permiso en QB-Core
    }
}

-- =========================================
--      TEXTOS Y TRADUCCIONES (IDIOMA)
-- =========================================
Config.Lang = {
    TitleAdmin = "ADMINISTRADOR",
    TitleReport = "ENVIAR REPORTE",
    Players = "JUGADORES",
    SearchPlaceholder = "Buscar por Nombre o ID...",
    NoPlayers = "No se encontraron jugadores.",
    ErrorNoWeapon = "No tienes arma",
    ErrorNoTarget = "No hay objetivo",
    SuccessGodmodeOn = "MODO DIOS: ON",
    SuccessGodmodeOff = "MODO DIOS: OFF",

    -- Nuevos textos para la Whitelist
    WhitelistKick = "⛔ EL SERVIDOR HA ACTIVADO LA WHITELIST. Acceso restringido a personal autorizado.",
    WhitelistEnterDeny = "⛔ WHITELIST ACTIVA: No tienes permisos para entrar en este momento.",
    WhitelistAnnounce = "⚠️ MANTENIMIENTO: La Whitelist se activará en %s segundos. Jugadores no autorizados serán expulsados.",
    WhitelistEnabled = "🔒 Whitelist ACTIVADA globalmente.",
    WhitelistDisabled = "🔓 Whitelist DESACTIVADA globalmente."
}
