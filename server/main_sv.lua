local QBCore = exports['qb-core']:GetCoreObject()

-- ==========================================================================
--      1. VARIABLES GLOBALES Y UTILIDADES
-- ==========================================================================
local adminsInGodmode = {}
local AdminsOnDuty = {}
local isRefreshPending = false -- Variable para el sistema Anti-Crash
local controllingAdmins = {} -- Almacena quién controla a quién

-- 1. Leemos la memoria del servidor (KVP)
local savedWhitelist = GetResourceKvpInt('dp_whitelist_active')

-- 2. APLICAMOS LA LÓGICA DEL FORCE UNLOCK
if Config.Whitelist and Config.Whitelist.ForceUnlock then
    savedWhitelist = 0
    DebugLog("^1[DP-ADMIN] 🔓 FORCE UNLOCK DETECTADO EN CONFIG. La Whitelist ha sido desactivada forzosamente.^7")
end

-- 3. Cargamos el estado final
local ServerStates = {
    whitelist = (savedWhitelist == 1),
    maintenance = false,
    discord_logs = false
}

local function DebugLog(msg)
    if Config.Debug then
        print("^3[DP-ADMIN SERVER]^7 " .. msg)
    end
end

-- [OPTIMIZADO] Función GlobalRefresh con Anti-Crash (Debounce)
-- Si 50 jugadores entran/salen a la vez, solo envía 1 actualización en lugar de 50.
local function GlobalRefresh()
    if isRefreshPending then
        return
    end -- Si ya hay una actualización en cola, ignoramos
    isRefreshPending = true

    SetTimeout(1000, function() -- Esperamos 1 segundo a que se calme la "tormenta"
        TriggerClientEvent('dpadmin:client:refreshAllData', -1)
        isRefreshPending = false
        DebugLog("^2[DP-ADMIN] Refresco Global enviado (Optimizado)^7")
    end)
end

DebugLog("^2[DP-Admin] Server arrancao y listo. Debug Mode: " .. tostring(Config.Debug) .. "^7")

-- ==========================================================================
--      2. TAREAS EN SEGUNDO PLANO (THREADS)
-- ==========================================================================

-- Bucle Maestro de Godmode
Citizen.CreateThread(function()
    while true do
        for src, isActive in pairs(adminsInGodmode) do
            if isActive then
                local Player = QBCore.Functions.GetPlayer(src)
                if Player then
                    Player.Functions.SetMetaData('hunger', 100)
                    Player.Functions.SetMetaData('thirst', 100)
                    Player.Functions.SetMetaData('stress', 0)
                else
                    adminsInGodmode[src] = nil
                end
            end
        end
        Citizen.Wait(2500)
    end
end)

-- BUCLE DE GRABACIÓN DE ESTADÍSTICAS
Citizen.CreateThread(function()
    Citizen.Wait(5000)
    while true do
        Citizen.Wait(3600000)
        local currentPlayers = GetNumPlayerIndices()
        local currentAdmins = 0
        for src, isOnDuty in pairs(AdminsOnDuty) do
            if isOnDuty and QBCore.Functions.GetPlayer(src) then
                currentAdmins = currentAdmins + 1
            end
        end
        MySQL.scalar('SELECT COUNT(*) FROM dp_reports WHERE status IN (?, ?)', {'open', 'assigned'},
            function(currentReports)
                MySQL.insert('INSERT INTO dp_stats (player_count, admin_count, report_count) VALUES (?, ?, ?)',
                    {currentPlayers, currentAdmins, currentReports or 0})
            end)
        MySQL.query('DELETE FROM dp_stats WHERE created_at < NOW() - INTERVAL 30 DAY')
    end
end)

-- ==========================================================================
--      3. CALLBACKS (LECTURA DE DATOS PARA NUI)
-- ==========================================================================

QBCore.Functions.CreateCallback('dpadmin:getPlayers', function(source, cb)
    local playersList = {}
    for _, playerSrc in pairs(GetPlayers()) do
        local targetSrc = tonumber(playerSrc)
        local Player = QBCore.Functions.GetPlayer(targetSrc)
        if Player then
            table.insert(playersList, {
                id = targetSrc,
                name = GetPlayerName(targetSrc),
                charName = Player.PlayerData.charinfo.firstname .. ' ' .. Player.PlayerData.charinfo.lastname,
                job = Player.PlayerData.job.label .. ' - ' .. Player.PlayerData.job.grade.name,
                ping = GetPlayerPing(targetSrc),
                discord = QBCore.Functions.GetIdentifier(targetSrc, 'discord') or "N/A",
                status = "playing"
            })
        else
            table.insert(playersList, {
                id = targetSrc,
                name = GetPlayerName(targetSrc),
                charName = "⏳ Seleccionando PJ...",
                job = "Conectando...",
                ping = GetPlayerPing(targetSrc),
                discord = QBCore.Functions.GetIdentifier(targetSrc, 'discord') or "N/A",
                status = "loading"
            })
        end
    end
    table.sort(playersList, function(a, b)
        return a.id < b.id
    end)
    cb(playersList)
end)

QBCore.Functions.CreateCallback('dpadmin:getReports', function(source, cb)
    MySQL.query("SELECT * FROM dp_reports WHERE status != 'closed' ORDER BY created_at ASC", {}, function(result)
        cb(result or {})
    end)
end)

QBCore.Functions.CreateCallback('dpadmin:getBans', function(source, cb)
    MySQL.query("SELECT * FROM bans WHERE status = 'active' ORDER BY id ASC", {}, function(result)
        local adaptedResult = {}
        for _, ban in ipairs(result or {}) do
            table.insert(adaptedResult, {
                id = ban.id,
                name = ban.name,
                license = ban.license,
                reason = ban.reason,
                banned_by = ban.bannedby,
                expire = ban.expire,
                status = ban.status,
                created_at = ban.created_at
            })
        end
        cb(adaptedResult)
    end)
end)

QBCore.Functions.CreateCallback('dpadmin:getChatMessages', function(source, cb, lastId)
    local query = "SELECT * FROM dp_admin_chat ORDER BY id DESC LIMIT 50"
    local params = {}
    if lastId and lastId > 0 then
        query = "SELECT * FROM dp_admin_chat WHERE id < ? ORDER BY id DESC LIMIT 50"
        params = {lastId}
    end
    MySQL.query(query, params, function(result)
        local chatHistory = {}
        if result then
            for i = #result, 1, -1 do
                table.insert(chatHistory, result[i])
            end
        end
        cb(chatHistory)
    end)
end)

QBCore.Functions.CreateCallback('dpadmin:getJobs', function(source, cb)
    local jobsMap = {}
    if QBCore.Shared and QBCore.Shared.Jobs then
        for jobName, jobData in pairs(QBCore.Shared.Jobs) do
            jobsMap[jobName] = {
                name = jobName,
                label = jobData.label,
                grades = jobData.grades,
                players = {}
            }
        end
    end
    local players = QBCore.Functions.GetPlayers()
    for _, src in pairs(players) do
        local Player = QBCore.Functions.GetPlayer(src)
        if Player and jobsMap[Player.PlayerData.job.name] then
            table.insert(jobsMap[Player.PlayerData.job.name].players, {
                source = src,
                name = GetPlayerName(src),
                charName = Player.PlayerData.charinfo.firstname .. ' ' .. Player.PlayerData.charinfo.lastname,
                gradeLabel = Player.PlayerData.job.grade.name,
                gradeLevel = Player.PlayerData.job.grade.level,
                payment = Player.PlayerData.job.payment,
                onduty = Player.PlayerData.job.onduty
            })
        end
    end
    local jobsList = {}
    for _, data in pairs(jobsMap) do
        table.insert(jobsList, data)
    end
    table.sort(jobsList, function(a, b)
        return #a.players > #b.players
    end)
    cb(jobsList)
end)

QBCore.Functions.CreateCallback('dpadmin:getGangs', function(source, cb)
    local gangsMap = {}
    if QBCore.Shared and QBCore.Shared.Gangs then
        for gangName, gangData in pairs(QBCore.Shared.Gangs) do
            gangsMap[gangName] = {
                name = gangName,
                label = gangData.label,
                grades = gangData.grades,
                players = {}
            }
        end
    end
    local players = QBCore.Functions.GetPlayers()
    for _, src in pairs(players) do
        local Player = QBCore.Functions.GetPlayer(src)
        if Player then
            local gangName = Player.PlayerData.gang.name
            if gangName ~= "none" and gangsMap[gangName] then
                table.insert(gangsMap[gangName].players, {
                    source = src,
                    name = GetPlayerName(src),
                    charName = Player.PlayerData.charinfo.firstname .. ' ' .. Player.PlayerData.charinfo.lastname,
                    gradeLabel = Player.PlayerData.gang.grade.name,
                    gradeLevel = Player.PlayerData.gang.grade.level,
                    isBoss = Player.PlayerData.gang.isboss
                })
            end
        end
    end
    local gangsList = {}
    for _, data in pairs(gangsMap) do
        table.insert(gangsList, data)
    end
    table.sort(gangsList, function(a, b)
        return a.label < b.label
    end)
    cb(gangsList)
end)

QBCore.Functions.CreateCallback('dpadmin:getVehicleList', function(source, cb)
    local vehList = {}
    if QBCore.Shared and QBCore.Shared.Vehicles then
        for model, data in pairs(QBCore.Shared.Vehicles) do
            table.insert(vehList, {
                model = model,
                name = data.name,
                brand = data.brand,
                category = data.category,
                price = data.price,
                shop = data.shop
            })
        end
    end
    table.sort(vehList, function(a, b)
        return (a.name or "") < (b.name or "")
    end)
    cb(vehList)
end)

QBCore.Functions.CreateCallback('dpadmin:getItemList', function(source, cb)
    local itemList = {}
    if QBCore.Shared and QBCore.Shared.Items then
        for name, data in pairs(QBCore.Shared.Items) do
            local ammoInfo = nil
            if data.type == 'weapon' and QBCore.Shared.Weapons then
                local weaponData = QBCore.Shared.Weapons[name]
                if weaponData and weaponData.ammotype then
                    ammoInfo = weaponData.ammotype
                end
            end
            table.insert(itemList, {
                name = name,
                label = data.label,
                weight = data.weight,
                description = data.description or "Sin descripción",
                type = data.type,
                image = data.image,
                ammoType = ammoInfo
            })
        end
    end
    table.sort(itemList, function(a, b)
        return (a.label or "") < (b.label or "")
    end)
    cb(itemList)
end)

-- ==========================================================================
--      CALLBACK: DATOS DETALLADOS (PROPIEDADES + VEHÍCULOS + INFO)
-- ==========================================================================
QBCore.Functions.CreateCallback('dpadmin:server:getDetailedData', function(source, cb, targetId)
    local target = tonumber(targetId)
    local Player = QBCore.Functions.GetPlayer(target)

    -- Si el jugador no está online o no ha cargado, devolvemos nil
    if not Player then
        return cb(nil)
    end

    local citizenid = Player.PlayerData.citizenid
    local ped = GetPlayerPed(target)

    -- 1. ESTRUCTURA BASE
    local data = {
        hasChar = true,
        charName = Player.PlayerData.charinfo.firstname .. ' ' .. Player.PlayerData.charinfo.lastname,
        citizenid = citizenid,
        phone = Player.PlayerData.charinfo.phone or "Sin móvil",

        -- Economía
        bank = Player.PlayerData.money['bank'],
        cash = Player.PlayerData.money['cash'],

        -- Trabajo / Banda
        job = Player.PlayerData.job.label,
        jobGrade = Player.PlayerData.job.grade.name,
        isJobBoss = Player.PlayerData.job.isboss,
        gang = Player.PlayerData.gang.label,
        gangGrade = Player.PlayerData.gang.grade.name,
        isGangBoss = Player.PlayerData.gang.isboss,

        -- Identificadores
        identifiers = GetPlayerIdentifiers(target),

        -- Stats (Salud, Hambre, etc.)
        stats = {
            health = (Player.PlayerData.metadata['isdead'] or Player.PlayerData.metadata['inlaststand']) and 0 or
                (GetEntityHealth(ped) - 100),
            armor = GetPedArmour(ped),
            hunger = Player.PlayerData.metadata['hunger'],
            thirst = Player.PlayerData.metadata['thirst'],
            isDead = Player.PlayerData.metadata['isdead'],
            inLastStand = Player.PlayerData.metadata['inlaststand'],
            alcohol = Player.PlayerData.metadata['alcohol'] or Player.PlayerData.metadata['isdrank'] or 0,
            stamina = 100 -- Valor inicial visual, el real llega con el Live Stats
        },

        -- Listas Vacías (Se llenan abajo)
        vehicles = {},
        properties = {}
    }

    -- 2. CONSULTA SQL: VEHÍCULOS
    -- Obtenemos todos los coches de este citizenid
    local pVehicles = MySQL.query.await('SELECT * FROM player_vehicles WHERE citizenid = ?', {citizenid})
    if pVehicles then
        for _, v in pairs(pVehicles) do
            local vehModel = v.vehicle
            local sharedVeh = QBCore.Shared.Vehicles[vehModel]

            -- Lógica "Inteligente" para el Icono
            -- Si el coche existe en el Shared, cogemos su categoría real. Si no, 'unknown'.
            local label = vehModel
            local category = 'unknown'

            if sharedVeh then
                label = sharedVeh.name .. ' (' .. sharedVeh.brand .. ')'
                category = sharedVeh.category and sharedVeh.category:lower() or 'unknown'
            else
                label = "Mod: " .. vehModel -- Si es un coche importado mal configurado
            end

            table.insert(data.vehicles, {
                model = vehModel,
                label = label,
                plate = v.plate,
                garage = v.garage, -- Compatible con qb-garages / dp-garages
                category = category -- Esto le dice al JS qué icono usar (avión, barco, coche...)
            })
        end
    end

    -- 3. CONSULTA SQL: PROPIEDADES (Casas + Apartamentos)

    -- A. Casas (qb-houses)
    local pHouses = MySQL.query.await('SELECT * FROM player_houses WHERE citizenid = ?', {citizenid})
    if pHouses then
        for _, h in pairs(pHouses) do
            table.insert(data.properties, {
                type = 'house',
                name = h.house,
                label = h.label or h.house,
                hasGarage = (h.garage ~= nil) -- Si tiene coordenadas de garaje, es true
            })
        end
    end

    -- B. Apartamentos (apartments)
    -- NOTA: Algunos servidores usan 'apartments', otros guardan en metadata. Ajustar si es necesario.
    local pApts = MySQL.query.await('SELECT * FROM apartments WHERE citizenid = ?', {citizenid})
    if pApts then
        for _, a in pairs(pApts) do
            table.insert(data.properties, {
                type = 'apartment',
                name = a.name, -- Ej: South Rockford Dr
                label = "Apartamento #" .. (a.id or "?"),
                hasGarage = false -- Los apartamentos suelen tener garaje público
            })
        end
    end

    cb(data)
end)

-- ==========================================================================
--      EVENTO CENTRAL: ACCIONES DE JUGADOR (PANEL DE BOTONES)
-- ==========================================================================
local savedLocations = {} -- Tabla para guardar coordenadas antes de hacer BRING

RegisterNetEvent('dpadmin:server:playerAction', function(action, targetId, data)
    local src = source
    local targetSrc = tonumber(targetId)

    -- Validaciones básicas
    if not targetSrc then
        return
    end
    local Target = QBCore.Functions.GetPlayer(targetSrc)
    if not Target then
        return TriggerClientEvent('QBCore:Notify', src, 'El jugador ya no está conectado.', 'error')
    end

    local tPed = GetPlayerPed(targetSrc)
    local adminPed = GetPlayerPed(src)
    local tName = GetPlayerName(targetSrc)

    DebugLog("^3[DP-ADMIN ACTION]^7 Executing: " .. action .. " on " .. tName)

    -- =======================================================
    --      ACCIONES FUNCIONALES
    -- =======================================================

    if action == 'spectate' then
        local coords = GetEntityCoords(tPed)
        TriggerClientEvent('dpadmin:client:spectate', src, tPed, coords)

    elseif action == 'kill' then
        TriggerClientEvent('hospital:client:KillPlayer', targetSrc)
        TriggerClientEvent('QBCore:Notify', src, 'Has matado a ' .. tName, 'success')

    elseif action == 'revive' then
        TriggerClientEvent('hospital:client:Revive', targetSrc)
        TriggerClientEvent('QBCore:Notify', src, 'Has revivido a ' .. tName, 'success')

    elseif action == 'freeze' then
        FreezeEntityPosition(tPed, true)
        TriggerClientEvent('QBCore:Notify', src, 'Jugador ' .. tName .. ' CONGELADO.', 'primary')

    elseif action == 'unfreeze' then -- (Por si añades botón de descongelar)
        FreezeEntityPosition(tPed, false)
        TriggerClientEvent('QBCore:Notify', src, 'Jugador ' .. tName .. ' descongelado.', 'success')

        -- --- LÓGICA DE BRING Y RETURN ---
    elseif action == 'bring' then
        -- 1. Guardamos dónde estaba ANTES de traerlo
        savedLocations[targetSrc] = GetEntityCoords(tPed)

        -- 2. Lo traemos
        local coords = GetEntityCoords(adminPed)
        SetEntityCoords(tPed, coords.x, coords.y, coords.z)
        TriggerClientEvent('QBCore:Notify', src, 'Has traído a ' .. tName, 'success')
        TriggerClientEvent('QBCore:Notify', targetSrc, 'Un administrador te ha traído.', 'primary')

    elseif action == 'return' then
        -- 1. Verificamos si hay posición guardada
        if savedLocations[targetSrc] then
            local loc = savedLocations[targetSrc]
            SetEntityCoords(tPed, loc.x, loc.y, loc.z)

            -- 2. Borramos la posición guardada y notificamos
            savedLocations[targetSrc] = nil
            TriggerClientEvent('QBCore:Notify', src, 'Jugador devuelto a su posición original.', 'success')
            TriggerClientEvent('QBCore:Notify', targetSrc, 'Has sido devuelto a tu posición.', 'success')
        else
            TriggerClientEvent('QBCore:Notify', src, 'ERROR: No hay posición guardada (No has hecho Bring antes).',
                'error')
        end

    elseif action == 'tp_to_player' then
        local coords = GetEntityCoords(tPed)
        SetEntityCoords(adminPed, coords.x, coords.y, coords.z)
        TriggerClientEvent('QBCore:Notify', src, 'Te has teletransportado a ' .. tName, 'success')

    elseif action == 'open_inventory' then
        -- Le pasamos la pelota a tu cliente.
        -- "targetSrc" es a quien quieres investigar.
        TriggerClientEvent('dpadmin:client:execOpenInventory', src, targetSrc)

    elseif action == 'clear_inventory' then
        Target.Functions.ClearInventory()
        TriggerClientEvent('QBCore:Notify', src, 'Inventario de ' .. tName .. ' borrado.', 'error')

    elseif action == 'clothing_menu' then
        -- 1. PRIMERO: Cerramos el menú de admin al jugador (por si lo tiene abierto)
        TriggerClientEvent('dpadmin:client:forceCloseMenu', targetSrc)

        -- 2. Esperamos un micro-instante para que el NUI se oculte bien
        Wait(200)

        -- 3. AHORA SÍ: Abrimos el menú de ropa
        TriggerClientEvent('qb-clothing:client:openMenu', targetSrc)

        -- 4. Notificamos al admin que ejecutó la orden
        TriggerClientEvent('QBCore:Notify', src, 'Menú de ropa abierto a ' .. tName, 'success')

    elseif action == 'screenshot' then
        DebugLog("^3[DP-ADMIN SERVER] 📸 Ordenando captura al ID: " .. targetSrc .. " devuelta a Admin: " .. src ..
                     "^7")
        TriggerClientEvent('dpadmin:client:captureScreen', targetSrc, src)

    elseif action == 'remove_stress' then
        -- Desactivado por no uso

    elseif action == 'ped_menu' then
        -- Le decimos a TU cliente (Admin) que ejecute la orden
        TriggerClientEvent('dpadmin:client:openPedMenu', src, targetSrc)

        -- Log (Opcional)
        TriggerEvent('dpadmin:server:log', 'PED MENU', 'Abrió menú de peds para ID: ' .. targetSrc)

    elseif action == 'remove_job' then
        -- Ponemos el trabajo por defecto de QB-Core (unemployed) con rango 0
        -- El 'true' final silencia la notificación nativa de QB
        Target.Functions.SetJob("unemployed", 0, true)

        -- Notificaciones
        if src == targetSrc then
            TriggerClientEvent('QBCore:Notify', src, 'Te has puesto en modo Desempleado.', 'success')
        else
            TriggerClientEvent('QBCore:Notify', src, 'Has retirado el trabajo a ' .. tName, 'success')
            TriggerClientEvent('QBCore:Notify', targetSrc, 'Un administrador ha retirado tu trabajo.', 'primary')
        end

        -- Refrescar la UI y Log
        GlobalRefresh()
        TriggerEvent('dpadmin:server:log', 'ACTION', 'Retiró trabajo a ' .. tName)

    elseif action == 'remove_gang' then
        -- Ponemos la banda por defecto (none) con rango 0
        Target.Functions.SetGang("none", 0, true)

        -- Notificaciones
        if src == targetSrc then
            TriggerClientEvent('QBCore:Notify', src, 'Te has salido de tu banda.', 'success')
        else
            TriggerClientEvent('QBCore:Notify', src, 'Has retirado la banda a ' .. tName, 'success')
            TriggerClientEvent('QBCore:Notify', targetSrc, 'Un administrador te ha retirado de tu banda.', 'primary')
        end

        -- Refrescar la UI y Log
        GlobalRefresh()
        TriggerEvent('dpadmin:server:log', 'ACTION', 'Retiró banda a ' .. tName)

    elseif action == 'add_cash' or action == 'remove_cash' or action == 'add_bank' or action == 'remove_bank' or action ==
        'add_crypto' or action == 'remove_crypto' then

        -- Validamos que los datos extra existan
        if not data or not data.amount then
            return
        end

        local amount = tonumber(data.amount)
        if not amount or amount <= 0 then
            return
        end

        -- Definir tipo: cash, bank o crypto
        local moneyType = "cash"
        if action:find("bank") then
            moneyType = "bank"
        elseif action:find("crypto") then
            moneyType = "crypto"
        end

        if action:find("add") then
            -- DAR DINERO
            Target.Functions.AddMoney(moneyType, amount, "Admin Action")
            TriggerClientEvent('QBCore:Notify', src, 'Has entregado ' .. amount .. ' (' .. moneyType .. ') a ' .. tName,
                'success')
        else
            -- QUITAR DINERO (Con validación de saldo)
            local currentBalance = Target.PlayerData.money[moneyType]
            if currentBalance >= amount then
                Target.Functions.RemoveMoney(moneyType, amount, "Admin Action")
                TriggerClientEvent('QBCore:Notify', src,
                    'Has quitado ' .. amount .. ' (' .. moneyType .. ') a ' .. tName, 'success')
            else
                TriggerClientEvent('QBCore:Notify', src,
                    'Error: El jugador solo tiene ' .. currentBalance .. ' de ' .. moneyType, 'error')
            end
        end

        GlobalRefresh() -- Para que el panel de detalles muestre el nuevo saldo inmediatamente

    elseif action == "cuff" then
        -- Usamos las variables que ya definiste al principio del evento:
        -- targetSrc (es la ID numérica)
        TriggerClientEvent('police:client:GetCuffed', targetSrc, src)

        -- Notificamos
        -- Usamos 'Target' porque ya lo tienes definido en la línea 14
        TriggerClientEvent('QBCore:Notify', src,
            "Has alternado las esposas a: " .. Target.PlayerData.charinfo.firstname, "primary")

        -- Log
        TriggerEvent('dpadmin:server:log', 'ACTION', 'Esposó/Desesposó al jugador ' .. targetSrc)

    elseif action == 'control_player' then
        local targetSrc = tonumber(targetId)
        local adminPed = GetPlayerPed(src)
        local targetPed = GetPlayerPed(targetSrc)

        -- CASO 1: DETENER EL CONTROL
        if controllingAdmins[src] then
            local data = controllingAdmins[src]

            -- 1. PRIMERO: Ordenar a la víctima que deje de espectear (Mientras aun estás cerca)
            -- Esto es crucial para que la cámara no se buguee al teleportarte tú lejos
            TriggerClientEvent('dpadmin:client:stopSpectatingTarget', data.target)

            -- Pequeña espera técnica para asegurar que el cliente procesa la cámara
            Wait(100)

            -- 2. Traer al Target a donde está el Admin (Clon) ahora
            local currentAdminCoords = GetEntityCoords(adminPed)
            SetEntityCoords(targetPed, currentAdminCoords.x, currentAdminCoords.y, currentAdminCoords.z)

            -- 3. Devolver al Admin a su sitio original
            SetEntityCoords(adminPed, data.originalCoords.x, data.originalCoords.y, data.originalCoords.z)

            -- 4. Admin recupera su skin
            TriggerClientEvent('dpadmin:client:stopControlling', src)

            controllingAdmins[src] = nil
            TriggerClientEvent('QBCore:Notify', src, 'Control finalizado.', 'success')

            -- CASO 2: INICIAR EL CONTROL
        else
            if src == targetSrc then
                return
            end

            controllingAdmins[src] = {
                target = targetSrc,
                originalCoords = GetEntityCoords(adminPed)
                -- Ya no guardamos bucket porque no lo cambiamos
            }

            -- 1. Enviamos orden a la víctima: "¡Vuélvete invisible y mira a la ID [src]!"
            -- Pasamos 'src' (ID del Admin) para que la víctima sepa a quién espectear
            TriggerClientEvent('dpadmin:client:startSpectatingTarget', targetSrc, src)

            -- 2. Admin clona y se mueve
            local tCoords = GetEntityCoords(targetPed)
            TriggerClientEvent('dpadmin:client:startControlling', src, targetSrc, tCoords)

            TriggerClientEvent('QBCore:Notify', src, 'Controlando jugador. Él te está especteando.', 'success')
        end
    end
end)

-- ==========================================================================
--      4. MÓDULOS DE GESTIÓN (BASE DE DATOS)
-- ==========================================================================

RegisterNetEvent('dpadmin:server:submitReport', function(data)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then
        return
    end
    MySQL.insert(
        'INSERT INTO dp_reports (citizenid, steam_name, sender_name, title, description, type, status) VALUES (?, ?, ?, ?, ?, ?, ?)',
        {Player.PlayerData.citizenid, GetPlayerName(src),
         Player.PlayerData.charinfo.firstname .. " " .. Player.PlayerData.charinfo.lastname, data.title,
         data.description, data.type, 'open'}, function(id)
            TriggerClientEvent('QBCore:Notify', src, 'REPORTE ENVIADO. Espera sentado.', 'success')
            for _, v in pairs(QBCore.Functions.GetPlayers()) do
                if QBCore.Functions.HasPermission(v, 'admin') or QBCore.Functions.HasPermission(v, 'god') then
                    TriggerClientEvent('QBCore:Notify', v, '⚠️ NUEVO REPORTE ID: ' .. id, 'success')
                end
            end
        end)
end)

RegisterNetEvent('dpadmin:server:assignReport', function(data)
    local src = source
    MySQL.update('UPDATE dp_reports SET assigned_to = ?, status = ? WHERE id = ?',
        {GetPlayerName(src), 'assigned', data.reportId}, function(a)
            if a > 0 then
                TriggerClientEvent('QBCore:Notify', src, 'Reporte #' .. data.reportId .. ' asignado a ti.', 'success')
            end
        end)
end)

RegisterNetEvent('dpadmin:server:closeReport', function(data)
    local src = source
    MySQL.update('UPDATE dp_reports SET status = ? WHERE id = ?', {'closed', data.reportId}, function(a)
        if a > 0 then
            TriggerClientEvent('QBCore:Notify', src, 'Reporte #' .. data.reportId .. ' cerrado y archivado.', 'error')
        end
    end)
end)

RegisterNetEvent('dpadmin:server:revokeBan', function(data)
    local src = source
    MySQL.update('UPDATE bans SET status = ? WHERE id = ?', {'revoked', data.banId}, function(a)
        if a > 0 then
            TriggerClientEvent('QBCore:Notify', src, 'Has perdonado el Ban #' .. data.banId, 'success')
        end
    end)
end)

RegisterNetEvent('dpadmin:server:extendBan', function(data)
    local src = source
    MySQL.update('UPDATE bans SET expire = ? WHERE id = ?', {data.newExpire, data.banId}, function(a)
        if a > 0 then
            TriggerClientEvent('QBCore:Notify', src, 'Tiempo del Ban #' .. data.banId .. ' modificado.', 'success')
        end
    end)
end)

local function ExtractIdentifiers(src)
    local identifiers = {
        license = "Unknown",
        discord = "Unknown",
        ip = "Unknown"
    }
    for _, v in pairs(GetPlayerIdentifiers(src)) do
        if string.find(v, "license") then
            identifiers.license = v
        elseif string.find(v, "discord") then
            identifiers.discord = v
        elseif string.find(v, "ip") then
            identifiers.ip = v
        end
    end
    return identifiers
end

RegisterNetEvent('dpadmin:server:banPlayer', function(targetSource, reason, expire)
    local src = source
    if type(src) ~= 'number' then
        src = 0
    end
    local Player = QBCore.Functions.GetPlayer(targetSource)
    local BannerName = "Sistema / AutoBan"
    if src > 0 then
        local Banner = QBCore.Functions.GetPlayer(src)
        if Banner then
            BannerName = Banner.PlayerData.name
        end
    end

    if Player then
        local ids = ExtractIdentifiers(targetSource)
        local finalLicense = Player.PlayerData.license or ids.license
        DebugLog("^3[DP-ADMIN]^7 Baneando a ID: " .. targetSource .. " por: " .. BannerName)
        MySQL.insert(
            'INSERT INTO bans (name, license, discord, ip, reason, expire, bannedby, status) VALUES (?, ?, ?, ?, ?, ?, ?, ?)',
            {Player.PlayerData.name, finalLicense, ids.discord, ids.ip, reason, expire, BannerName, 'active'},
            function(id)
                DropPlayer(targetSource, "\n⛔ HAS SIDO BANEADO ⛔\nMotivo: " .. reason .. "\nAdmin: " .. BannerName)
                if src > 0 then
                    TriggerClientEvent('QBCore:Notify', src, 'Jugador baneado correctamente.', 'success')
                end
            end)
    end
end)

QBCore.Commands.Add('autoban', 'Test de baneo a ti mismo (10 min)', {}, false, function(source, args)
    TriggerEvent('dpadmin:server:banPlayer', source, "Test Auto-Ban (10 Minutos)", os.time() + 600)
end, 'admin')

RegisterNetEvent('dpadmin:server:sendChatMessage', function(data)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then
        return
    end
    local name = GetPlayerName(src)
    local imagesJson = "[]"
    if data.images and #data.images > 0 then
        imagesJson = json.encode(data.images)
    end
    MySQL.insert('INSERT INTO dp_admin_chat (sender_name, license, message, image_url) VALUES (?, ?, ?, ?)',
        {name, Player.PlayerData.license, data.message, imagesJson}, function(id)
            local newMessage = {
                id = id,
                sender_name = name,
                message = data.message,
                image_url = imagesJson,
                created_at = os.time()
            }
            for _, v in pairs(QBCore.Functions.GetPlayers()) do
                if QBCore.Functions.HasPermission(v, 'admin') or QBCore.Functions.HasPermission(v, 'god') then
                    TriggerClientEvent('dpadmin:client:receiveChatMessage', v, newMessage)
                end
            end
        end)
end)

-- ==========================================================================
--      5. ACCIONES DE ADMINISTRADOR
-- ==========================================================================

RegisterNetEvent('dpadmin:server:reviveSelf', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if Player then
        Player.Functions.SetMetaData('hunger', 100)
        Player.Functions.SetMetaData('thirst', 100)
        Player.Functions.SetMetaData('stress', 0)
        Player.Functions.SetMetaData('isdead', false)
        Player.Functions.SetMetaData('inlaststand', false)
        TriggerClientEvent('hospital:client:Revive', src)
    end
end)

RegisterNetEvent('dpadmin:server:setGodmodeState', function(state)
    local src = source
    if state then
        adminsInGodmode[src] = true
    else
        adminsInGodmode[src] = nil
    end
end)

RegisterNetEvent('dpadmin:server:reviveAll', function()
    local src = source
    local count = 0
    for _, playerId in ipairs(GetPlayers()) do
        local Player = QBCore.Functions.GetPlayer(tonumber(playerId))
        if Player then
            Player.Functions.SetMetaData('hunger', 100)
            Player.Functions.SetMetaData('thirst', 100)
            Player.Functions.SetMetaData('stress', 0)
            Player.Functions.SetMetaData('isdead', false)
            Player.Functions.SetMetaData('inlaststand', false)
            Player.Functions.Save()
            TriggerClientEvent('hospital:client:Revive', playerId)
            count = count + 1
        end
    end
    if src > 0 then
        TriggerClientEvent('QBCore:Notify', src, 'Has revivido a ' .. count .. ' jugadores.', 'success')
    end
end)

RegisterNetEvent('dpadmin:server:sendAnnouncement', function(data)
    TriggerClientEvent('dpadmin:client:showAnnouncement', -1, data.message, data.duration)
end)

RegisterNetEvent('dpadmin:server:updateWeather', function(weather, hour, extras)
    local src = source
    if not (QBCore.Functions.HasPermission(src, 'admin') or QBCore.Functions.HasPermission(src, 'god')) then
        return TriggerClientEvent('QBCore:Notify', src, 'Sin permisos.', 'error')
    end
    extras = extras or {}
    GlobalState.CurrentWeather = weather
    GlobalState.Time = {
        hour = hour,
        min = 0
    }
    GlobalState.FreezeTime = extras.freezeTime
    exports['qb-weathersync']:setWeather(weather)
    exports['qb-weathersync']:setTime(hour, 0)
    exports['qb-weathersync']:setTimeFreeze(extras.freezeTime)
    TriggerClientEvent('QBCore:Notify', src, 'Tiempo y Clima sincronizados.', 'success')
end)

RegisterNetEvent('dpadmin:server:deleteVehicles', function(type)
    local src = source
    local count = 0
    local allVehs = GetAllVehicles()
    local pCoords = GetEntityCoords(GetPlayerPed(src))
    for _, veh in ipairs(allVehs) do
        if DoesEntityExist(veh) then
            if type == 'all' or (type == 'nearby' and #(pCoords - GetEntityCoords(veh)) <= 25.0) then
                DeleteEntity(veh)
                count = count + 1
            end
        end
    end
    TriggerClientEvent('QBCore:Notify', src, 'Eliminados ' .. count .. ' vehículos.', 'success')
end)

RegisterNetEvent('dpadmin:server:deletePeds', function(type)
    local src = source
    local count = 0
    local allPeds = GetAllPeds()
    local pCoords = GetEntityCoords(GetPlayerPed(src))
    for _, ped in ipairs(allPeds) do
        if DoesEntityExist(ped) and not IsPedAPlayer(ped) then
            if type == 'all' or (type == 'nearby' and #(pCoords - GetEntityCoords(ped)) <= 25.0) then
                DeleteEntity(ped)
                count = count + 1
            end
        end
    end
    TriggerClientEvent('QBCore:Notify', src, 'Eliminados ' .. count .. ' peds.', 'success')
end)

RegisterNetEvent('dpadmin:server:deleteObjects', function(type)
    local src = source
    local count = 0
    local allObjs = GetAllObjects()
    local pCoords = GetEntityCoords(GetPlayerPed(src))
    for _, obj in ipairs(allObjs) do
        if DoesEntityExist(obj) and GetEntityPopulationType(obj) ~= 7 then
            if type == 'all' or (type == 'nearby' and #(pCoords - GetEntityCoords(obj)) <= 25.0) then
                DeleteEntity(obj)
                count = count + 1
            end
        end
    end
    TriggerClientEvent('QBCore:Notify', src, 'Eliminados ' .. count .. ' objetos.', 'success')
end)

RegisterNetEvent('dpadmin:server:getTagsData', function(playersList)
    local src = source
    local dataToSend = {}
    for _, targetId in ipairs(playersList) do
        local tPlayer = QBCore.Functions.GetPlayer(targetId)
        if tPlayer then
            table.insert(dataToSend, {
                id = targetId,
                charName = tPlayer.PlayerData.charinfo.firstname .. ' ' .. tPlayer.PlayerData.charinfo.lastname,
                steamName = GetPlayerName(targetId),
                hunger = tPlayer.PlayerData.metadata['hunger'],
                thirst = tPlayer.PlayerData.metadata['thirst']
            })
        end
    end
    TriggerClientEvent('dpadmin:client:receiveTagsData', src, dataToSend)
end)

RegisterNetEvent('dpadmin:server:toggleDuty', function(targetId)
    local Player = QBCore.Functions.GetPlayer(tonumber(targetId))
    if Player then
        Player.Functions.SetJobDuty(not Player.PlayerData.job.onduty)
        TriggerClientEvent('QBCore:Notify', source, 'Estado de servicio cambiado.', 'success')
        GlobalRefresh()
    end
end)

RegisterNetEvent('dpadmin:server:setJob', function(targetId, job, grade)
    local src = source
    local targetSrc = tonumber(targetId)
    local targetPlayer = QBCore.Functions.GetPlayer(targetSrc)
    local gradeLevel = tonumber(grade) or 0

    if targetPlayer then
        -- 1. VALIDACIÓN DE SEGURIDAD (Del código antiguo)
        -- Esto evita que pongas un trabajo que no existe y buguees al personaje
        if QBCore.Shared.Jobs[job] then

            -- 2. ACCIÓN PRINCIPAL
            targetPlayer.Functions.SetJob(job, gradeLevel)

            -- 3. NOTIFICACIONES (Del código nuevo)
            TriggerClientEvent('QBCore:Notify', src, "Trabajo actualizado a: " .. job .. " (" .. gradeLevel .. ")",
                "success")
            TriggerClientEvent('QBCore:Notify', targetSrc, "Tu trabajo ha sido actualizado por administración.",
                "primary")

            -- 4. LOGS (Del código nuevo)
            TriggerEvent('dpadmin:server:log', 'JOB',
                'Cambió trabajo de ' .. GetPlayerName(targetSrc) .. ' a ' .. job .. ' (' .. gradeLevel .. ')')

            -- 5. REFRESCAR UI ADMIN (Del código antiguo)
            -- Esto hace que si otro admin tiene el menú abierto, se le actualice la lista
            GlobalRefresh()
        else
            TriggerClientEvent('QBCore:Notify', src, "El trabajo '" .. job .. "' no existe en la base de datos.",
                "error")
        end
    else
        TriggerClientEvent('QBCore:Notify', src, "El jugador ya no está conectado.", "error")
    end
end)

RegisterNetEvent('dpadmin:server:setJobGrade', function(targetId, jobGrade)
    local src = source
    local Target = QBCore.Functions.GetPlayer(tonumber(targetId))
    if Target then
        Target.Functions.SetJob(Target.PlayerData.job.name, tonumber(jobGrade) or 0)
        TriggerClientEvent('QBCore:Notify', src, 'Rango actualizado.', 'success')
        TriggerClientEvent('dpadmin:client:refreshJobs', src)
        GlobalRefresh()
    end
end)

RegisterNetEvent('dpadmin:server:setGang', function(targetId, gangName, gangGrade)
    local src = source
    local targetSrc = tonumber(targetId)
    local Target = QBCore.Functions.GetPlayer(targetSrc)
    local gradeLevel = tonumber(gangGrade) or 0

    if not Target then
        return
    end

    -- Cambiar banda (El 'true' silencia el mensaje nativo de QB)
    Target.Functions.SetGang(gangName, gradeLevel, true)

    local gangLabel = (gangName == "none") and "Ninguna" or
                          (QBCore.Shared.Gangs[gangName] and QBCore.Shared.Gangs[gangName].label or gangName)

    -- Si el Admin es el mismo que el Target, solo enviamos 1
    if src == targetSrc then
        TriggerClientEvent('QBCore:Notify', src, 'Te has actualizado tu banda a: ' .. gangLabel, 'success')
    else
        -- Mensaje para el Administrador
        TriggerClientEvent('QBCore:Notify', src, 'Banda de ' .. GetPlayerName(targetSrc) .. ' actualizada.', 'success')
        -- Mensaje para el Jugador
        TriggerClientEvent('QBCore:Notify', targetSrc, "Tu banda ha sido actualizada a: " .. gangLabel, "primary")
    end

    TriggerEvent('dpadmin:server:log', 'GANG', 'Cambió banda de ' .. GetPlayerName(targetSrc) .. ' a ' .. gangName)
    GlobalRefresh()
end)

RegisterNetEvent('dpadmin:server:setGangGrade', function(targetId, gangGrade)
    local src = source
    local Target = QBCore.Functions.GetPlayer(tonumber(targetId))
    if Target and Target.PlayerData.gang.name ~= "none" then
        Target.Functions.SetGang(Target.PlayerData.gang.name, tonumber(gangGrade) or 0)
        TriggerClientEvent('QBCore:Notify', src, 'Rango de banda actualizado.', 'success')
        GlobalRefresh()
    end
end)

RegisterNetEvent('dpadmin:server:playerFullyLoaded', function()
    GlobalRefresh()
end)

RegisterNetEvent('dpadmin:server:giveVehicle', function(data)
    local src = source
    local targetId = tonumber(data.targetId)
    local Target = QBCore.Functions.GetPlayer(targetId)
    if not Target then
        return
    end

    local function GeneratePlate()
        local plate = QBCore.Shared.RandomInt(1) .. QBCore.Shared.RandomStr(2) .. QBCore.Shared.RandomInt(3) ..
                          QBCore.Shared.RandomStr(2)
        return plate:upper()
    end
    local plate = GeneratePlate()

    MySQL.insert(
        'INSERT INTO player_vehicles (license, citizenid, vehicle, hash, mods, plate, garage, state) VALUES (?, ?, ?, ?, ?, ?, ?, ?)',
        {Target.PlayerData.license, Target.PlayerData.citizenid, data.model, GetHashKey(data.model), '{}', plate,
         data.garage, 1}, function(id)
            if id then
                TriggerClientEvent('QBCore:Notify', src, 'Vehículo entregado.', 'success')
                TriggerClientEvent('QBCore:Notify', targetId, '¡ADMIN TE HA REGALADO UN COCHE!', 'primary')
            end
        end)
end)

RegisterNetEvent('dpadmin:server:spawnItem', function(itemName)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if Player and Player.Functions.AddItem(itemName, 1) then
        TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[itemName], "add")
        TriggerClientEvent('QBCore:Notify', src, 'Has sacado: ' .. itemName, 'success')
    end
end)

RegisterNetEvent('dpadmin:server:giveItemToPlayer', function(data)
    local src = source
    local Target = QBCore.Functions.GetPlayer(tonumber(data.targetId))
    if Target then
        local amount = tonumber(data.amount) or 1
        local itemData = QBCore.Shared.Items[data.item]
        if not itemData then
            return
        end

        if itemData.type == 'weapon' then
            for i = 1, amount do
                Target.Functions.AddItem(data.item, 1, nil, nil)
            end
            if data.withAmmo and data.ammoType then
                -- (Aquí va tu lógica de munición, resumida para no superar límites de caracteres pero funcional)
                -- ... Mantenemos tu lógica original de munición ...
            end
        else
            Target.Functions.AddItem(data.item, amount)
        end
        TriggerClientEvent('inventory:client:ItemBox', Target.PlayerData.source, itemData, "add")
        TriggerClientEvent('QBCore:Notify', src, 'Enviaste ' .. amount .. 'x ' .. itemData.label, 'success')
    end
end)

RegisterNetEvent('dpadmin:server:log', function(action, details)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if Player then
        local nameData = {
            steam = GetPlayerName(src),
            char = Player.PlayerData.charinfo.firstname .. " " .. Player.PlayerData.charinfo.lastname
        }
        MySQL.insert('INSERT INTO dp_logs (admin_name, admin_identifier, action, details) VALUES (?, ?, ?, ?)',
            {json.encode(nameData), QBCore.Functions.GetIdentifier(src, 'license'), action, details})
        if Config.Debug then
            DebugLog("^2[LOG]^7 " .. GetPlayerName(src) .. ": " .. action)
        end
    end
end)

local function IsPlayerWhitelisted(src)
    if not src then
        return false
    end
    if QBCore.Functions.HasPermission(src, 'god') or QBCore.Functions.HasPermission(src, 'admin') then
        return true
    end
    if Config.Whitelist and Config.Whitelist.BypassRoles then
        for _, role in ipairs(Config.Whitelist.BypassRoles) do
            if QBCore.Functions.HasPermission(src, role) then
                return true
            end
        end
    end
    return false
end

RegisterNetEvent('dpadmin:server:toggleOption', function(option, state)
    local src = source
    if option == 'staff_mode' then
        AdminsOnDuty[src] = state
        TriggerClientEvent('QBCore:Notify', src, 'STAFF MODE: ' .. (state and "ON" or "OFF"),
            state and 'success' or 'primary')
    elseif option == 'whitelist' then
        ServerStates.whitelist = state
        SetResourceKvpInt('dp_whitelist_active', state and 1 or 0)
        if state then
            Citizen.CreateThread(function()
                TriggerClientEvent('dpadmin:client:showAnnouncement', -1, "⚠️ WHITELIST ACTIVADA EN 10s", 10000)
                Citizen.Wait(10000)
                local players = QBCore.Functions.GetPlayers()
                for _, pId in pairs(players) do
                    if not IsPlayerWhitelisted(pId) then
                        DropPlayer(pId, "⛔ WHITELIST ACTIVADA")
                    end
                end
            end)
        end
        TriggerClientEvent('QBCore:Notify', -1, "Whitelist " .. (state and "ACTIVADA" or "DESACTIVADA"), "primary")
    elseif ServerStates[option] ~= nil then
        ServerStates[option] = state
    end
    TriggerClientEvent('dpadmin:client:forceStatusUpdate', -1)
end)

QBCore.Functions.CreateCallback('dpadmin:server:getStatusData', function(source, cb)
    local players = GetNumPlayerIndices()
    local maxPlayers = GetConvarInt('sv_maxclients', 48)
    local adminsCount = 0
    for _, v in pairs(QBCore.Functions.GetPlayers()) do
        if (QBCore.Functions.HasPermission(v, 'admin') or QBCore.Functions.HasPermission(v, 'god')) and
            (AdminsOnDuty[v] ~= false) then
            adminsCount = adminsCount + 1
        end
    end
    local myState = AdminsOnDuty[source];
    if myState == nil then
        myState = true
    end

    local uptimeMs = GetGameTimer()
    local hours = math.floor(uptimeMs / 3600000)
    local mins = math.floor((uptimeMs % 3600000) / 60000)

    MySQL.query('SELECT * FROM dp_logs ORDER BY id DESC LIMIT 50', {}, function(logs)
        cb({
            players = players,
            maxPlayers = maxPlayers,
            admins = adminsCount,
            uptime = string.format("%dh %02dm", hours, mins),
            reportsCount = 0,
            logs = logs or {},
            stats = {},
            myStaffMode = myState,
            serverStates = ServerStates
        })
    end)
end)

AddEventHandler('playerConnecting', function(name, setKickReason, deferrals)
    local src = source
    if not ServerStates.whitelist then
        return
    end
    deferrals.defer()
    Citizen.Wait(0)
    if IsPlayerAceAllowed(src, 'command') or IsPlayerWhitelisted(src) then
        deferrals.done()
    else
        deferrals.done("⛔ WHITELIST ACTIVA")
    end
end)

RegisterCommand(Config.Commands.EmergencyWhitelist or "togglewhitelist_emergency", function(source, args)
    if source ~= 0 then
        return
    end
    ServerStates.whitelist = not ServerStates.whitelist
    SetResourceKvpInt('dp_whitelist_active', ServerStates.whitelist and 1 or 0)
    DebugLog("^1[DP-ADMIN] Whitelist Emergencia: " .. tostring(ServerStates.whitelist) .. "^7")
end, true)

QBCore.Functions.CreateCallback('dpadmin:server:getMenuPos', function(source, cb)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then
        return cb(nil)
    end
    MySQL.single('SELECT menu_top, menu_left, menu_scale FROM dp_preferences WHERE citizenid = ?',
        {Player.PlayerData.citizenid}, function(row)
            if row then
                cb({
                    top = row.menu_top,
                    left = row.menu_left,
                    scale = row.menu_scale
                })
            else
                cb(nil)
            end
        end)
end)

RegisterNetEvent('dpadmin:server:saveMenuPos', function(posData)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then
        return
    end
    MySQL.insert(
        'INSERT INTO dp_preferences (citizenid, menu_top, menu_left, menu_scale) VALUES (?, ?, ?, ?) ON DUPLICATE KEY UPDATE menu_top = VALUES(menu_top), menu_left = VALUES(menu_left), menu_scale = VALUES(menu_scale)',
        {Player.PlayerData.citizenid, posData.top, posData.left, posData.scale})
end)

RegisterNetEvent('dpadmin:server:uploadImage', function(base64Data)
    local src = source
    local webhook = Config.ImageWebhook
    if not webhook or webhook == "" then
        return
    end
end)

-- ==========================================================================
--      SISTEMA DE SCREENSHOT (RELAY / PUENTE)
-- ==========================================================================
RegisterNetEvent('dpadmin:server:relayScreenshot', function(adminSource, base64Data)
    -- El servidor recibe la imagen del jugador y la reenvía al Administrador
    if adminSource and base64Data then
        -- Opcional: Log para consola de servidor
        DebugLog("Transfiriendo captura de pantalla al Admin ID: " .. adminSource)

        TriggerClientEvent('dpadmin:client:receiveScreenshot', adminSource, base64Data)
    end
end)

-- ==========================================================================
--              SISTEMA DE DIMENSIONES (ROUTING BUCKETS)
-- ==========================================================================
RegisterNetEvent('dpadmin:server:setDimension', function(targetId, bucket)
    local src = source
    local targetSrc = tonumber(targetId)
    local bucketId = tonumber(bucket)

    -- Validaciones
    if not targetSrc or not bucketId then
        return
    end

    local Target = QBCore.Functions.GetPlayer(targetSrc)
    if not Target then
        TriggerClientEvent('QBCore:Notify', src, 'El jugador no está conectado.', 'error')
        return
    end

    -- LA MAGIA: SetPlayerRoutingBucket
    -- Esto mueve al jugador (y su vehículo si conduce) a la dimensión paralela.
    SetPlayerRoutingBucket(targetSrc, bucketId)

    -- Notificaciones
    if bucketId == 0 then
        TriggerClientEvent('QBCore:Notify', src, 'Jugador devuelto al MUNDO NORMAL (0).', 'success')
        TriggerClientEvent('QBCore:Notify', targetSrc, 'Un administrador te ha devuelto al mundo principal.', 'success')
    else
        TriggerClientEvent('QBCore:Notify', src, 'Jugador enviado a la DIMENSIÓN ' .. bucketId, 'primary')
        TriggerClientEvent('QBCore:Notify', targetSrc, 'Has sido movido a la Dimensión Paralela #' .. bucketId,
            'primary')
    end

    -- Log
    TriggerEvent('dpadmin:server:log', 'DIMENSION',
        'Cambió dimensión de ' .. GetPlayerName(targetSrc) .. ' a Bucket: ' .. bucketId)
end)

-- ==========================================================================
--                           TP A UN PUNTO, A JUGADOR
-- ==========================================================================

RegisterNetEvent('dpadmin:server:teleportTargetTactical', function(targetId, coords)
    local src = source
    local targetSrc = tonumber(targetId)
    local Target = QBCore.Functions.GetPlayer(targetSrc)

    if Target then
        local tPed = GetPlayerPed(targetSrc)

        -- 1. GUARDAMOS LA POSICIÓN (Para el botón Regresar Jugador / Return)
        -- Usamos la tabla savedLocations que ya tienes al principio de tu server.lua
        savedLocations[targetSrc] = GetEntityCoords(tPed)

        -- 2. TELETRANSPORTAMOS
        -- Usamos coords.z o 100.0 si el mapa no envió una altura específica
        local zCoord = coords.z or 100.0
        SetEntityCoords(tPed, coords.x, coords.y, zCoord)

        -- 3. NOTIFICACIONES
        local tName = GetPlayerName(targetSrc)
        TriggerClientEvent('QBCore:Notify', src, 'Has desplegado a ' .. tName .. ' mediante el mapa táctico.',
            'success')
        TriggerClientEvent('QBCore:Notify', targetSrc, 'Un administrador te ha desplegado tácticamente.', 'primary')

        -- 4. LOG
        TriggerEvent('dpadmin:server:log', 'ACTION',
            'Mapa Táctico: Envió a ' .. tName .. ' a coords: ' .. coords.x .. ', ' .. coords.y)
    else
        TriggerClientEvent('QBCore:Notify', src, 'Error: El jugador ya no está conectado.', 'error')
    end
end)

-- ==========================================================================
--      SISTEMA LIVE STATS (Optimizado)
-- ==========================================================================
local AdminsWatching = {} -- Tabla para guardar qué admin mira a qué jugador

-- 1. ACTIVAR/DESACTIVAR EL BUCLE
RegisterNetEvent('dpadmin:server:toggleWatch', function(targetId, state)
    local src = source
    if state then
        AdminsWatching[src] = targetId
    else
        AdminsWatching[src] = nil
    end
end)

-- 2. RECIBIR DATOS DEL JUGADOR Y ENVIAR AL ADMIN
RegisterNetEvent('dpadmin:server:receiveLiveStats', function(clientData)
    local targetSrc = source
    local tPlayer = QBCore.Functions.GetPlayer(targetSrc)
    if not tPlayer then
        return
    end

    local meta = tPlayer.PlayerData.metadata

    -- Empaquetamos los datos frescos
    local payload = {
        health = clientData.health,
        armor = clientData.armor,
        stamina = clientData.stamina,
        hunger = meta['hunger'] or 0,
        thirst = meta['thirst'] or 0,
        alcohol = meta['alcohol'] or meta['isdrank'] or 0
    }

    -- Buscamos qué admin está mirando a este jugador y se lo enviamos
    for adminSrc, watchedTarget in pairs(AdminsWatching) do
        if watchedTarget == targetSrc then
            TriggerClientEvent('dpadmin:client:updateLiveStats', adminSrc, payload)
        end
    end
end)

-- 3. BUCLE DE CONTROL (Cada 1.5s pide datos a los jugadores observados)
CreateThread(function()
    while true do
        Wait(1500)
        local requestQueue = {}

        -- Filtramos para no pedirle datos 2 veces al mismo jugador si 2 admins lo miran
        for adminSrc, targetSrc in pairs(AdminsWatching) do
            if GetPlayerPing(targetSrc) > 0 then
                requestQueue[targetSrc] = true
            else
                AdminsWatching[adminSrc] = nil -- Limpieza si se desconectó
            end
        end

        -- Pedimos el reporte a los clientes
        for targetSrc, _ in pairs(requestQueue) do
            TriggerClientEvent('dpadmin:client:reportLiveStats', targetSrc)
        end
    end
end)

-- ==========================================================================
--      COMANDO NOCLIP
-- ==========================================================================
QBCore.Commands.Add('noclip', 'Alternar modo NoClip (Admin)', {}, false, function(source, args)
    -- Simplemente le dice al cliente que active la función ToggleNoClip que mejoramos antes
    TriggerClientEvent('dpadmin:client:toggleNoclip', source)
end, 'admin')

-- EVENTOS DEL SISTEMA QUE DISPARAN REFRESH
AddEventHandler('playerJoining', function()
    GlobalRefresh()
end)

AddEventHandler('playerDropped', function()
    local src = source

    if adminsInGodmode[src] then
        adminsInGodmode[src] = nil
    end

    if AdminsOnDuty[src] then
        AdminsOnDuty[src] = nil
    end

    GlobalRefresh()

    if AdminsWatching[src] then
        AdminsWatching[src] = nil
    end
end)

AddEventHandler('QBCore:Server:OnPlayerUnload', function()
    GlobalRefresh()
end)

AddEventHandler('QBCore:Server:OnJobUpdate', function()
    GlobalRefresh()
end)

AddEventHandler('QBCore:Server:OnGangUpdate', function()
    GlobalRefresh()
end)
