local QBCore = exports['qb-core']:GetCoreObject()

-- ==========================================================================
--      1. VARIABLES GLOBALES Y UTILIDADES
-- ==========================================================================\n
local adminsInGodmode = {}
local AdminsOnDuty = {}

-- 1. Leemos la memoria del servidor (KVP)
local savedWhitelist = GetResourceKvpInt('dp_whitelist_active')

-- 2. APLICAMOS LA LÓGICA DEL FORCE UNLOCK
-- Si en el config dice TRUE, ignoramos lo que diga la memoria y lo apagamos a la fuerza.
if Config.Whitelist and Config.Whitelist.ForceUnlock then
    savedWhitelist = 0
    print("^1[DP-ADMIN] 🔓 FORCE UNLOCK DETECTADO EN CONFIG. La Whitelist ha sido desactivada forzosamente.^7")
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

-- Función para avisar a TODOS los admins de que refresquen datos
local function GlobalRefresh()
    TriggerClientEvent('dpadmin:client:refreshAllData', -1)
end

DebugLog("^2[DP-Admin] Server arrancao y listo. Debug Mode: " .. tostring(Config.Debug) .. "^7")

-- ==========================================================================
--      2. TAREAS EN SEGUNDO PLANO (THREADS)
-- ==========================================================================

-- Bucle Maestro de Godmode (Optimizado: 1 hilo para todos)
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
                    adminsInGodmode[src] = nil -- Limpieza si se desconecta
                end
            end
        end
        Citizen.Wait(2500)
    end
end)

-- BUCLE DE GRABACIÓN DE ESTADÍSTICAS
Citizen.CreateThread(function()
    -- Opcional: Esperamos un poco al arrancar para no cargar la DB mientras inicia el server
    Citizen.Wait(5000)

    while true do
        -- 1. Esperamos 1 Hora (3600000 ms) DENTRO del bucle
        -- Al ponerlo al principio, espera 30 min antes de la primera ejecución y entre cada una.
        Citizen.Wait(3600000)

        -- 2. Ejecutamos la lógica
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

        -- Limpieza de datos antiguos (más de 30 días)
        MySQL.query('DELETE FROM dp_stats WHERE created_at < NOW() - INTERVAL 30 DAY')

        -- (El bucle llega aquí, sube arriba y vuelve a esperar 30 minutos)
    end
end)

-- ==========================================================================
--      3. CALLBACKS (LECTURA DE DATOS PARA NUI)
-- ==========================================================================

-- Lista de Jugadores
QBCore.Functions.CreateCallback('dpadmin:getPlayers', function(source, cb)
    local playersList = {}

    for _, playerSrc in pairs(GetPlayers()) do
        local targetSrc = tonumber(playerSrc)
        local Player = QBCore.Functions.GetPlayer(targetSrc)

        if Player then
            -- CASO A: JUGADOR YA TIENE PERSONAJE (Jugando)
            table.insert(playersList, {
                id = targetSrc,
                name = GetPlayerName(targetSrc), -- Nombre de Steam/FiveM
                charName = Player.PlayerData.charinfo.firstname .. ' ' .. Player.PlayerData.charinfo.lastname,
                job = Player.PlayerData.job.label .. ' - ' .. Player.PlayerData.job.grade.name,
                ping = GetPlayerPing(targetSrc),
                discord = QBCore.Functions.GetIdentifier(targetSrc, 'discord') or "N/A",
                status = "playing" -- Para identificar en el JS si quieres ponerles icono verde
            })
        else
            -- CASO B: JUGADOR CONECTADO PERO SIN PERSONAJE (Multicharacter/Carga)
            table.insert(playersList, {
                id = targetSrc,
                name = GetPlayerName(targetSrc), -- Nombre de Steam/FiveM
                charName = "⏳ Seleccionando PJ...", -- Texto provisional
                job = "Conectando...",
                ping = GetPlayerPing(targetSrc),
                discord = QBCore.Functions.GetIdentifier(targetSrc, 'discord') or "N/A",
                status = "loading" -- Para identificar en el JS si quieres ponerles icono amarillo
            })
        end
    end

    -- Ordenar por ID ascendente (1, 2, 3...)
    table.sort(playersList, function(a, b)
        return a.id < b.id
    end)

    cb(playersList)
end)

-- Lista de Reportes
QBCore.Functions.CreateCallback('dpadmin:getReports', function(source, cb)
    MySQL.query("SELECT * FROM dp_reports WHERE status != 'closed' ORDER BY created_at ASC", {}, function(result)
        cb(result or {})
    end)
end)

-- Lista de Baneos
QBCore.Functions.CreateCallback('dpadmin:getBans', function(source, cb)
    -- Seleccionamos de 'bans'. Nota: QBCore usa 'bannedby', no 'banned_by'
    MySQL.query("SELECT * FROM bans WHERE status = 'active' ORDER BY id ASC", {}, function(result)
        -- Adaptamos los datos para que el JS no se rompa si los nombres de columna son distintos
        local adaptedResult = {}
        for _, ban in ipairs(result or {}) do
            table.insert(adaptedResult, {
                id = ban.id,
                name = ban.name,
                license = ban.license,
                reason = ban.reason,
                banned_by = ban.bannedby, -- Mapeamos 'bannedby' (DB) a 'banned_by' (JS)
                expire = ban.expire,
                status = ban.status,
                created_at = ban.created_at
            })
        end
        cb(adaptedResult)
    end)
end)

-- Historial de Chat
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

-- Lista de Trabajos
QBCore.Functions.CreateCallback('dpadmin:getJobs', function(source, cb)
    local jobsMap = {}

    -- 1. Estructura base
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

    -- 2. Rellenar jugadores con DATOS EXTRA (Duty, Payment)
    local players = QBCore.Functions.GetPlayers()
    for _, src in pairs(players) do
        local Player = QBCore.Functions.GetPlayer(src)
        if Player then
            local jobName = Player.PlayerData.job.name
            if jobsMap[jobName] then
                table.insert(jobsMap[jobName].players, {
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
    end

    -- 3. Convertir a lista y ordenar por cantidad de empleados activos
    local jobsList = {}
    for _, data in pairs(jobsMap) do
        table.insert(jobsList, data)
    end
    -- Ordenar: Primero los que tienen más jugadores conectados
    table.sort(jobsList, function(a, b)
        return #a.players > #b.players
    end)

    cb(jobsList)
end)

-- Lista de Bandas (Gangs)
QBCore.Functions.CreateCallback('dpadmin:getGangs', function(source, cb)
    local gangsMap = {}

    -- 1. Estructura base desde Shared
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

    -- 2. Rellenar jugadores
    local players = QBCore.Functions.GetPlayers()
    for _, src in pairs(players) do
        local Player = QBCore.Functions.GetPlayer(src)
        if Player then
            local gangName = Player.PlayerData.gang.name
            -- Solo añadimos si NO es "none" (sin banda) y la banda existe
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

    -- 3. Convertir a lista y ordenar
    local gangsList = {}
    for _, data in pairs(gangsMap) do
        table.insert(gangsList, data)
    end
    -- Ordenar A-Z
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
                model = model, -- El código (spawn code)
                name = data.name, -- El nombre visual
                brand = data.brand,
                category = data.category,
                price = data.price,
                shop = data.shop -- A veces útil saber si está en tienda
            })
        end
    end

    -- Ordenar alfabéticamente por nombre
    table.sort(vehList, function(a, b)
        return (a.name or "") < (b.name or "")
    end)

    cb(vehList)
end)

-- CALLBACK: OBTENER LISTA DE ÍTEMS
QBCore.Functions.CreateCallback('dpadmin:getItemList', function(source, cb)
    local itemList = {}

    if QBCore.Shared and QBCore.Shared.Items then
        for name, data in pairs(QBCore.Shared.Items) do

            -- Lógica para detectar munición si es un arma
            local ammoInfo = nil
            if data.type == 'weapon' and QBCore.Shared.Weapons then
                -- Buscamos el arma en la tabla de armas usando el nombre del item
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

    -- Ordenar alfabéticamente
    table.sort(itemList, function(a, b)
        return (a.label or "") < (b.label or "")
    end)

    cb(itemList)
end)

-- ==========================================================================
--      4. MÓDULOS DE GESTIÓN (BASE DE DATOS)
-- ==========================================================================

-- --- A. SISTEMA DE REPORTES ---
RegisterNetEvent('dpadmin:server:submitReport', function(data)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then
        return
    end

    local citizenid = Player.PlayerData.citizenid
    local charName = Player.PlayerData.charinfo.firstname .. " " .. Player.PlayerData.charinfo.lastname
    local steamName = GetPlayerName(src)

    MySQL.insert(
        'INSERT INTO dp_reports (citizenid, steam_name, sender_name, title, description, type, status) VALUES (?, ?, ?, ?, ?, ?, ?)',
        {citizenid, steamName, charName, data.title, data.description, data.type, 'open'}, function(id)
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
        {GetPlayerName(src), 'assigned', data.reportId}, function(affected)
            if affected > 0 then
                TriggerClientEvent('QBCore:Notify', src, 'Reporte #' .. data.reportId .. ' asignado a ti.', 'success')
            end
        end)
end)

RegisterNetEvent('dpadmin:server:closeReport', function(data)
    local src = source
    MySQL.update('UPDATE dp_reports SET status = ? WHERE id = ?', {'closed', data.reportId}, function(affected)
        if affected > 0 then
            TriggerClientEvent('QBCore:Notify', src, 'Reporte #' .. data.reportId .. ' cerrado y archivado.', 'error')
        end
    end)
end)

-- --- B. SISTEMA DE BANEOS ---
RegisterNetEvent('dpadmin:server:revokeBan', function(data)
    local src = source
    -- En QBCore, normalmente se borra la fila o se cambia estado.
    -- Nosotros cambiamos estado a 'revoked' para mantener historial.
    MySQL.update('UPDATE bans SET status = ? WHERE id = ?', {'revoked', data.banId}, function(affected)
        if affected > 0 then
            TriggerClientEvent('QBCore:Notify', src, 'Has perdonado el Ban #' .. data.banId, 'success')

            -- Opcional: Si QBCore necesita que se borre la fila para desbanear:
            -- MySQL.query('DELETE FROM bans WHERE id = ?', {data.banId})
        end
    end)
end)

RegisterNetEvent('dpadmin:server:extendBan', function(data)
    local src = source
    MySQL.update('UPDATE bans SET expire = ? WHERE id = ?', {data.newExpire, data.banId}, function(affected)
        if affected > 0 then
            TriggerClientEvent('QBCore:Notify', src, 'Tiempo del Ban #' .. data.banId .. ' modificado.', 'success')
        end
    end)
end)

-- Función auxiliar para extraer identificadores de forma segura
local function ExtractIdentifiers(src)
    local identifiers = {
        license = "Unknown",
        discord = "Unknown",
        ip = "Unknown"
    }
    for _, v in pairs(GetPlayerIdentifiers(src)) do
        if string.sub(v, 1, string.len("license:")) == "license:" then
            identifiers.license = v
        elseif string.sub(v, 1, string.len("discord:")) == "discord:" then
            identifiers.discord = v
        elseif string.sub(v, 1, string.len("ip:")) == "ip:" then
            identifiers.ip = v
        end
    end
    return identifiers
end

RegisterNetEvent('dpadmin:server:banPlayer', function(targetSource, reason, expire)
    local src = source

    -- CORRECCIÓN DEL ERROR:
    -- Si 'src' no es un número (porque lo llama el servidor), lo ponemos a 0
    if type(src) ~= 'number' then
        src = 0
    end

    local Player = QBCore.Functions.GetPlayer(targetSource)

    -- Definimos quién banea
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

                -- Solo notificamos al admin si es un jugador real
                if src > 0 then
                    TriggerClientEvent('QBCore:Notify', src, 'Jugador baneado correctamente.', 'success')
                end
            end)
    end
end)

-- ==========================================================================
--      COMANDO DE PRUEBA (ESTRUCTURA SEGÚN EL DOC DE QBCORE)
-- ==========================================================================
-- name: 'autoban'
-- help: 'Explicación...'
-- arguments: {} (vacío porque no pide args extra)
-- argsrequired: false (no obligatorio)
-- callback: la función
-- permission: 'admin'

QBCore.Commands.Add('autoban', 'Test de baneo a ti mismo (10 min)', {}, false, function(source, args)
    local src = source

    -- 10 minutos = 600 segundos
    local expireDate = os.time() + 600

    TriggerEvent('dpadmin:server:banPlayer', src, "Test Auto-Ban (10 Minutos)", expireDate)

end, 'admin')

-- --- C. SISTEMA DE CHAT (Soporte Multi-Imagen) ---
RegisterNetEvent('dpadmin:server:sendChatMessage', function(data)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then
        return
    end

    local name = GetPlayerName(src)

    -- 1. Convertimos el Array de imágenes (Lua Table) a Texto JSON para guardarlo en SQL
    -- data.images viene del JS como ["url1", "url2"]
    local imagesJson = "[]"
    if data.images and #data.images > 0 then
        imagesJson = json.encode(data.images)
    end

    -- 2. Insertamos en la DB (Nota: añadimos la columna image_url)
    MySQL.insert('INSERT INTO dp_admin_chat (sender_name, license, message, image_url) VALUES (?, ?, ?, ?)',
        {name, Player.PlayerData.license, data.message, imagesJson}, function(id)

            -- 3. Preparamos el mensaje para devolverlo al instante a los clientes
            local newMessage = {
                id = id,
                sender_name = name,
                message = data.message,
                image_url = imagesJson, -- Enviamos el JSON string, el JS renderChat ya sabe leerlo
                created_at = os.time()
            }

            -- 4. Difundimos el mensaje a todos los admins conectados
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

-- --- A. PERSONALES (SELF) ---
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
        DebugLog("Admin " .. GetPlayerName(src) .. " auto-revivido.")
    end
end)

RegisterNetEvent('dpadmin:server:setGodmodeState', function(state)
    local src = source
    if state then
        adminsInGodmode[src] = true;
        DebugLog("Godmode ON: " .. src)
    else
        adminsInGodmode[src] = nil;
        DebugLog("Godmode OFF: " .. src)
    end
end)

-- --- B. GLOBALES ---
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
    if weather == 'HALLOWEEN' then
        hour = 0
    end

    -- GlobalState
    GlobalState.CurrentWeather = weather
    GlobalState.Time = {
        hour = hour,
        min = 0
    }
    GlobalState.FreezeTime = extras.freezeTime
    if extras.wind ~= nil then
        GlobalState.HighWind = extras.wind
    end
    if extras.waves ~= nil then
        GlobalState.HighWaves = extras.waves
    end

    -- WeatherSync Exports
    exports['qb-weathersync']:setWeather(weather)
    exports['qb-weathersync']:setTime(hour, 0)
    exports['qb-weathersync']:setTimeFreeze(extras.freezeTime)
    if extras.freezeWeather ~= nil then
        exports['qb-weathersync']:setDynamicWeather(not extras.freezeWeather)
    end
    if extras.blackout ~= nil then
        exports['qb-weathersync']:setBlackout(extras.blackout)
    end

    TriggerClientEvent('QBCore:Notify', src, 'Tiempo y Clima sincronizados.', 'success')
end)

-- --- C. LIMPIEZA DE ENTIDADES ---
RegisterNetEvent('dpadmin:server:deleteVehicles', function(type)
    local src = source
    local count = 0
    local allVehs = GetAllVehicles()

    if type == 'nearby' then
        local pCoords = GetEntityCoords(GetPlayerPed(src))
        for _, veh in ipairs(allVehs) do
            if DoesEntityExist(veh) and #(pCoords - GetEntityCoords(veh)) <= 25.0 then
                DeleteEntity(veh)
                count = count + 1
            end
        end
        TriggerClientEvent('QBCore:Notify', src, '🧹 ' .. count .. ' vehículos cercanos eliminados.', 'success')
    elseif type == 'all' then
        for _, veh in ipairs(allVehs) do
            if DoesEntityExist(veh) then
                DeleteEntity(veh);
                count = count + 1
            end
        end
        TriggerClientEvent('QBCore:Notify', src, '⚠️ WIPE TOTAL: ' .. count .. ' vehículos eliminados.', 'primary')
    end
end)

RegisterNetEvent('dpadmin:server:deletePeds', function(type)
    local src = source
    local count = 0
    local allPeds = GetAllPeds()

    if type == 'nearby' then
        local pCoords = GetEntityCoords(GetPlayerPed(src))
        for _, ped in ipairs(allPeds) do
            if DoesEntityExist(ped) and not IsPedAPlayer(ped) and #(pCoords - GetEntityCoords(ped)) <= 25.0 then
                DeleteEntity(ped)
                count = count + 1
            end
        end
        TriggerClientEvent('QBCore:Notify', src, '🧹 ' .. count .. ' peatones cercanos eliminados.', 'success')
    elseif type == 'all' then
        for _, ped in ipairs(allPeds) do
            if DoesEntityExist(ped) and not IsPedAPlayer(ped) then
                DeleteEntity(ped);
                count = count + 1
            end
        end
        TriggerClientEvent('QBCore:Notify', src, '⚠️ POBLACIÓN ELIMINADA: ' .. count .. ' NPCs.', 'primary')
    end
end)

RegisterNetEvent('dpadmin:server:deleteObjects', function(type)
    local src = source
    local count = 0
    local allObjs = GetAllObjects()

    if type == 'nearby' then
        local pCoords = GetEntityCoords(GetPlayerPed(src))
        for _, obj in ipairs(allObjs) do
            if DoesEntityExist(obj) and GetEntityPopulationType(obj) ~= 7 and #(pCoords - GetEntityCoords(obj)) <= 25.0 then
                DeleteEntity(obj)
                count = count + 1
            end
        end
        TriggerClientEvent('QBCore:Notify', src, '🧹 ' .. count .. ' objetos cercanos eliminados.', 'success')
    elseif type == 'all' then
        for _, obj in ipairs(allObjs) do
            if DoesEntityExist(obj) and GetEntityPopulationType(obj) ~= 7 then
                DeleteEntity(obj);
                count = count + 1
            end
        end
        TriggerClientEvent('QBCore:Notify', src, '♻️ LIMPIEZA DE BASURA: ' .. count .. ' objetos eliminados.',
            'primary')
    end
end)

-- --- D. UTILIDADES EXTRA ---
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

-- ACTUALIZAR EVENTO DE DUTY
RegisterNetEvent('dpadmin:server:toggleDuty', function(targetId)
    local src = source
    local Player = QBCore.Functions.GetPlayer(tonumber(targetId))

    if Player then
        Player.Functions.SetJobDuty(not Player.PlayerData.job.onduty)

        TriggerClientEvent('QBCore:Notify', src, 'Estado de servicio cambiado.', 'success')
        TriggerClientEvent('QBCore:Notify', targetId, 'Tu estado de servicio ha cambiado.', 'primary')

        -- ¡AVISAMOS A TODOS PARA QUE SE ACTUALICE LA LISTA!
        GlobalRefresh()
    end
end)

-- EVENTO: CAMBIAR TRABAJO
RegisterNetEvent('dpadmin:server:setJob', function(targetId, jobName, jobGrade)
    local src = source
    local Target = QBCore.Functions.GetPlayer(tonumber(targetId))
    if Target then
        local grade = tonumber(jobGrade) or 0
        if QBCore.Shared.Jobs[jobName] then
            Target.Functions.SetJob(jobName, grade)

            TriggerClientEvent('QBCore:Notify', src, 'Trabajo cambiado correctamente', 'success')
            TriggerClientEvent('QBCore:Notify', Target.PlayerData.source, 'Tu trabajo ha sido actualizado.', 'primary')

            -- AVISAMOS AL ADMIN PARA QUE REPRESQUE LA LISTA
            TriggerClientEvent('dpadmin:client:refreshJobs', src)
        else
            TriggerClientEvent('QBCore:Notify', src, 'El trabajo no existe.', 'error')
        end
    end
end)

-- EVENTO: CAMBIAR SOLO RANGO
RegisterNetEvent('dpadmin:server:setJobGrade', function(targetId, jobGrade)
    local src = source
    local Target = QBCore.Functions.GetPlayer(tonumber(targetId))
    if Target then
        local currentJob = Target.PlayerData.job.name
        local grade = tonumber(jobGrade) or 0
        Target.Functions.SetJob(currentJob, grade)

        TriggerClientEvent('QBCore:Notify', src, 'Rango actualizado.', 'success')
        TriggerClientEvent('QBCore:Notify', Target.PlayerData.source, 'Tu rango ha sido actualizado.', 'primary')

        -- AVISAMOS AL ADMIN PARA QUE REPRESQUE LA LISTA
        TriggerClientEvent('dpadmin:client:refreshJobs', src)
    end
end)

-- CAMBIAR BANDA COMPLETA
RegisterNetEvent('dpadmin:server:setGang', function(targetId, gangName, gangGrade)
    local src = source
    local Target = QBCore.Functions.GetPlayer(tonumber(targetId))
    if Target then
        local grade = tonumber(gangGrade) or 0
        if QBCore.Shared.Gangs[gangName] or gangName == "none" then
            Target.Functions.SetGang(gangName, grade)
            TriggerClientEvent('QBCore:Notify', src, 'Banda actualizada.', 'success')
            TriggerClientEvent('QBCore:Notify', Target.PlayerData.source, 'Tu banda ha sido actualizada.', 'primary')
            GlobalRefresh() -- Refresco automático
        else
            TriggerClientEvent('QBCore:Notify', src, 'Esa banda no existe.', 'error')
        end
    end
end)

-- CAMBIAR SOLO RANGO DE BANDA
RegisterNetEvent('dpadmin:server:setGangGrade', function(targetId, gangGrade)
    local src = source
    local Target = QBCore.Functions.GetPlayer(tonumber(targetId))
    if Target then
        local currentGang = Target.PlayerData.gang.name
        if currentGang == "none" then
            TriggerClientEvent('QBCore:Notify', src, 'El jugador no está en ninguna banda.', 'error')
            return
        end
        local grade = tonumber(gangGrade) or 0
        Target.Functions.SetGang(currentGang, grade)
        TriggerClientEvent('QBCore:Notify', src, 'Rango de banda actualizado.', 'success')
        TriggerClientEvent('QBCore:Notify', Target.PlayerData.source, 'Tu rango de banda ha sido actualizado.',
            'primary')
        GlobalRefresh() -- Refresco automático
    end
end)

-- Este evento lo recibe cuando el jugador ya ha pasado el Multicharacter y el Spawn
RegisterNetEvent('dpadmin:server:playerFullyLoaded', function()
    GlobalRefresh()
end)

-- DAR VEHÍCULO A JUGADOR (Con guardado en DP-GARAGES)
RegisterNetEvent('dpadmin:server:giveVehicle', function(data)
    local src = source
    local targetId = tonumber(data.targetId)
    local model = data.model
    local garage = data.garage -- El ID del garaje seleccionado (ej: 'legion')

    local Target = QBCore.Functions.GetPlayer(targetId)
    if not Target then
        TriggerClientEvent('QBCore:Notify', src, 'El jugador ya no está conectado.', 'error')
        return
    end

    -- 1. Generar Matrícula (Función auxiliar simple)
    local function GeneratePlate()
        local plate = QBCore.Shared.RandomInt(1) .. QBCore.Shared.RandomStr(2) .. QBCore.Shared.RandomInt(3) ..
                          QBCore.Shared.RandomStr(2)
        local result = MySQL.scalar.await('SELECT plate FROM player_vehicles WHERE plate = ?', {plate})
        if result then
            return GeneratePlate()
        end
        return plate:upper()
    end

    local plate = GeneratePlate()

    -- 2. Datos básicos del vehículo (Mods vacíos por defecto)
    local mods = '{}'
    local vehicleData = {} -- Si quisieras guardar datos extra

    -- 3. Inserción en Base de Datos
    MySQL.insert(
        'INSERT INTO player_vehicles (license, citizenid, vehicle, hash, mods, plate, garage, state) VALUES (?, ?, ?, ?, ?, ?, ?, ?)',
        {Target.PlayerData.license, Target.PlayerData.citizenid, model, GetHashKey(model), mods, plate, garage, 1 -- State 1 = Guardado (Stored) para que aparezca en el garaje directamente
        }, function(id)
            if id then
                TriggerClientEvent('QBCore:Notify', src,
                    'Vehículo entregado: ' .. model .. ' a ' .. Target.PlayerData.charinfo.firstname, 'success')
                TriggerClientEvent('QBCore:Notify', targetId,
                    '¡ADMIN TE HA REGALADO UN COCHE! Revisa tu garaje: ' .. garage, 'primary')
            else
                TriggerClientEvent('QBCore:Notify', src, 'Error al guardar en base de datos.', 'error')
            end
        end)
end)

-- EVENTO: DAR ÍTEM A JUGADOR
RegisterNetEvent('dpadmin:server:spawnItem', function(itemName)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)

    if Player then
        -- Añadimos 1 unidad del ítem
        if Player.Functions.AddItem(itemName, 1) then
            -- Notificamos al inventario para que salga la cajita visual (si usas qb-inventory)
            TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[itemName], "add")
            TriggerClientEvent('QBCore:Notify', src, 'Has sacado: ' .. itemName, 'success')
        else
            TriggerClientEvent('QBCore:Notify', src, 'No tienes espacio o el ítem no es válido.', 'error')
        end
    end
end)

-- EVENTO: DAR ÍTEM A OTRO JUGADOR
RegisterNetEvent('dpadmin:server:giveItemToPlayer', function(data)
    local src = source
    local Target = QBCore.Functions.GetPlayer(tonumber(data.targetId))

    if Target then
        local amount = tonumber(data.amount) or 1
        local itemData = QBCore.Shared.Items[data.item]

        if not itemData then
            TriggerClientEvent('QBCore:Notify', src, 'El ítem no existe en la base de datos.', 'error')
            return
        end

        -- === CASO 1: ES UN ARMA (Damos 1 por 1 para generar METADATA COMPLETA) ===
        if itemData.type == 'weapon' then
            local successCount = 0

            -- Bucle: Damos el arma X veces
            for i = 1, amount do
                -- IMPORTANTE: El 4º argumento es 'info'. Lo ponemos en NIL.
                -- Al ser nil, QBCore genera automáticamente: { quality=100, serie=GENERADO, attachments={} }
                -- Si ponemos { quality = 100 }, rompemos los attachments y el script de armas falla.
                if Target.Functions.AddItem(data.item, 1, nil, nil) then
                    successCount = successCount + 1
                end
            end

            if successCount > 0 then
                TriggerClientEvent('inventory:client:ItemBox', Target.PlayerData.source, itemData, "add")
                TriggerClientEvent('QBCore:Notify', src,
                    'Enviaste ' .. successCount .. 'x ' .. itemData.label .. ' (Full Metadata)', 'success')
                TriggerClientEvent('QBCore:Notify', Target.PlayerData.source, 'Admin te dio armas: ' .. itemData.label,
                    'primary')

                if data.withAmmo and data.ammoType then
                    local ammoAmount = 5 * amount -- 5 balas por arma

                    local ammoMap = {
                        ['AMMO_PISTOL'] = 'pistol_ammo',
                        ['AMMO_SMG'] = 'smg_ammo',
                        ['AMMO_SHOTGUN'] = 'shotgun_ammo',
                        ['AMMO_RIFLE'] = 'rifle_ammo',
                        ['AMMO_MG'] = 'mg_ammo',
                        ['AMMO_SNIPER'] = 'snp_ammo',
                        ['AMMO_SNIPER_REMOTE'] = 'snp_ammo',
                        ['AMMO_EMP'] = 'emp_ammo',
                        ['AMMO_STUNGUN'] = 'taser_cartridge'
                    }

                    local itemToGive = ammoMap[data.ammoType]

                    if not itemToGive then
                        local cleanName = string.lower(string.gsub(data.ammoType, 'AMMO_', ''))
                        itemToGive = cleanName .. '_ammo'
                    end

                    if QBCore.Shared.Items[itemToGive] then
                        Target.Functions.AddItem(itemToGive, ammoAmount)
                        TriggerClientEvent('inventory:client:ItemBox', Target.PlayerData.source,
                            QBCore.Shared.Items[itemToGive], "add")
                        TriggerClientEvent('QBCore:Notify', src, '(Extra) Se añadieron ' .. ammoAmount .. 'x ' ..
                            QBCore.Shared.Items[itemToGive].label, 'success')
                    else
                        TriggerClientEvent('QBCore:Notify', src, 'Error: No encuentro el ítem para ' .. data.ammoType,
                            'error')
                    end
                end

            else
                TriggerClientEvent('QBCore:Notify', src, 'El inventario del jugador está lleno.', 'error')
            end

            -- === CASO 2: ES UN ÍTEM NORMAL (Damos todo junto) ===
        else
            if Target.Functions.AddItem(data.item, amount) then
                TriggerClientEvent('inventory:client:ItemBox', Target.PlayerData.source, itemData, "add")
                TriggerClientEvent('QBCore:Notify', src, 'Enviaste ' .. amount .. 'x ' .. itemData.label, 'success')
                TriggerClientEvent('QBCore:Notify', Target.PlayerData.source, 'Admin te dio: ' .. itemData.label,
                    'primary')
            else
                TriggerClientEvent('QBCore:Notify', src, 'Error: Inventario lleno o ítem inválido.', 'error')
            end
        end
    else
        TriggerClientEvent('QBCore:Notify', src, 'Jugador no encontrado.', 'error')
    end
end)

-- EVENTO: REGISTRAR ACCIÓN EN LOGS
RegisterNetEvent('dpadmin:server:log', function(action, details)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)

    if Player then
        -- 1. Capturamos ambos nombres
        local steamName = GetPlayerName(src) -- Nombre de Steam/FiveM
        local charName = Player.PlayerData.charinfo.firstname .. " " .. Player.PlayerData.charinfo.lastname -- Nombre PJ

        -- 2. Creamos un paquete JSON con los dos
        local nameData = {
            steam = steamName,
            char = charName
        }
        local finalName = json.encode(nameData) -- Guardamos: {"steam":"Kike","char":"Enrique Pastor"}

        local license = QBCore.Functions.GetIdentifier(src, 'license') or "Unknown"

        -- 3. Insertar en la base de datos
        MySQL.insert('INSERT INTO dp_logs (admin_name, admin_identifier, action, details) VALUES (?, ?, ?, ?)',
            {finalName, license, action, details})

        -- Debug en consola (bonito)
        if Config.Debug then
            DebugLog("^2[LOG]^7 " .. steamName .. " (" .. charName .. ") ejecutó: " .. action)
        end
    end
end)

-- FUNCIÓN AUXILIAR: Verificar permisos de Whitelist
local function IsPlayerWhitelisted(src)
    if not src then
        return false
    end
    -- 1. Admins y Dioses siempre pasan
    if QBCore.Functions.HasPermission(src, 'god') or QBCore.Functions.HasPermission(src, 'admin') then
        return true
    end

    -- 2. Revisar roles extra del Config (ej: 'mod', 'whitelist')
    if Config.Whitelist and Config.Whitelist.BypassRoles then
        for _, role in ipairs(Config.Whitelist.BypassRoles) do
            if QBCore.Functions.HasPermission(src, role) then
                return true
            end
        end
    end
    return false
end

-- EVENTO PARA CAMBIAR OPCIONES (STAFF MODE, WHITELIST, ETC)
RegisterNetEvent('dpadmin:server:toggleOption', function(option, state)
    local src = source

    -- 1. Lógica del cambio
    if option == 'staff_mode' then
        AdminsOnDuty[src] = state
        if state then
            TriggerClientEvent('QBCore:Notify', src, 'STAFF MODE: ON', 'success')
        else
            TriggerClientEvent('QBCore:Notify', src, 'STAFF MODE: OFF', 'primary')
        end

    elseif option == 'whitelist' then
        -- === LÓGICA DE WHITELIST === --
        ServerStates.whitelist = state
        SetResourceKvpInt('dp_whitelist_active', state and 1 or 0) -- Guardar Persistencia

        if state then
            -- A. ACTIVACIÓN (Cuenta atrás y Kick CON BARRA VISUAL)
            Citizen.CreateThread(function()
                -- 1. ANUNCIO 60 SEGUNDOS (Barra Visual)
                local msg60 = string.format(Config.Lang.WhitelistAnnounce or "⚠️ WHITELIST EN %s SEGUNDOS", 60)
                TriggerClientEvent('dpadmin:client:showAnnouncement', -1, msg60, 30000)

                Citizen.Wait(30000) -- Esperamos 30s reales

                -- 2. ANUNCIO 30 SEGUNDOS
                local msg30 = string.format(Config.Lang.WhitelistAnnounce or "⚠️ WHITELIST EN %s SEGUNDOS", 30)
                TriggerClientEvent('dpadmin:client:showAnnouncement', -1, msg30, 20000)

                Citizen.Wait(20000) -- Esperamos 20s reales (Total acumulado: 50s)

                -- 3. ANUNCIO 10 SEGUNDOS (FINAL)
                local msg10 = string.format(Config.Lang.WhitelistAnnounce or "⚠️ WHITELIST EN %s SEGUNDOS", 10)
                TriggerClientEvent('dpadmin:client:showAnnouncement', -1, msg10, 10000)

                Citizen.Wait(10000) -- Esperamos 10s reales (Total acumulado: 60s)

                -- BARRIDO FINAL (KICK MASIVO)
                local players = QBCore.Functions.GetPlayers()
                local kickedCount = 0
                for _, pId in pairs(players) do
                    if not IsPlayerWhitelisted(pId) then
                        DropPlayer(pId, Config.Lang.WhitelistKick or
                            "⛔ El servidor ha activado la Whitelist. Acceso restringido.")
                        kickedCount = kickedCount + 1
                    end
                end
                print("^1[WHITELIST]^7 Activada. Jugadores expulsados: " .. kickedCount)
            end)
        else
            -- B. DESACTIVACIÓN (AHORA CON NOTIFICACIÓN QB-CORE)
            -- Usamos TriggerClientEvent con -1 para enviarlo a TODOS
            TriggerClientEvent('QBCore:Notify', -1,
                Config.Lang.WhitelistDisabled or "🔓 Whitelist DESACTIVADA. Servidor abierto.", "success", 5000)
        end

    elseif ServerStates[option] ~= nil then
        -- Otras opciones
        ServerStates[option] = state
        DebugLog("^3[DP-Admin]^7 Opción global '" .. option .. "' cambiada a: " .. tostring(state))
    end

    -- 2. Sincronizar menús de admins
    TriggerClientEvent('dpadmin:client:forceStatusUpdate', -1)
end)

-- CALLBACK MEJORADO (ENVÍA ESTADOS REALES)
QBCore.Functions.CreateCallback('dpadmin:server:getStatusData', function(source, cb)
    local players = GetNumPlayerIndices()
    local maxPlayers = GetConvarInt('sv_maxclients', 48)

    -- Contar Admins (Solo los que están en Staff Mode)
    local adminsCount = 0
    for _, v in pairs(QBCore.Functions.GetPlayers()) do
        if QBCore.Functions.HasPermission(v, 'admin') or QBCore.Functions.HasPermission(v, 'god') then
            -- Si es nil (acaba de entrar), asumimos TRUE por defecto
            local isOnDuty = AdminsOnDuty[v]
            if isOnDuty == nil then
                isOnDuty = true
            end

            if isOnDuty then
                adminsCount = adminsCount + 1
            end
        end
    end

    -- Estado personal del Staff Mode
    local myState = AdminsOnDuty[source]
    if myState == nil then
        myState = true
    end -- Por defecto ON al entrar

    local uptimeMs = GetGameTimer()
    local hours = math.floor(uptimeMs / 3600000)
    local mins = math.floor((uptimeMs % 3600000) / 60000)
    local uptimeStr = string.format("%dh %02dm", hours, mins)

    MySQL.query('SELECT * FROM dp_logs ORDER BY id DESC LIMIT 50', {}, function(logs)
        MySQL.query(
            'SELECT player_count, admin_count, report_count, UNIX_TIMESTAMP(created_at) as date FROM dp_stats WHERE created_at > NOW() - INTERVAL 30 DAY ORDER BY created_at ASC',
            {}, function(stats)
                MySQL.scalar('SELECT COUNT(*) FROM dp_reports WHERE created_at > CURDATE()', {}, function(reportCount)

                    cb({
                        players = players,
                        maxPlayers = maxPlayers,
                        admins = adminsCount,
                        uptime = uptimeStr,
                        reportsCount = reportCount or 0,
                        logs = logs or {},
                        stats = stats or {},
                        -- Enviamos todos los estados para sincronizar los interruptores
                        myStaffMode = myState,
                        serverStates = ServerStates
                    })
                end)
            end)
    end)
end)

-- ==========================================================================
--      6. SISTEMA DE SEGURIDAD Y CONEXIÓN
-- ==========================================================================

-- HOOK DE CONEXIÓN (El Muro)
AddEventHandler('playerConnecting', function(name, setKickReason, deferrals)
    local src = source
    local identifiers = GetPlayerIdentifiers(src)

    -- Si la whitelist está apagada, dejar pasar.
    if not ServerStates.whitelist then
        return
    end

    deferrals.defer()
    Citizen.Wait(0)
    deferrals.update("🔍 Verificando permisos de Whitelist Global...")
    Citizen.Wait(1000)

    -- 1. Comprobar si es Admin de Consola (ACE Perms de server.cfg)
    -- Esto es vital: si te quedas sin base de datos, los admins de consola siempre entran.
    if IsPlayerAceAllowed(src, 'command') then
        deferrals.done()
        return
    end

    -- 2. Comprobar Roles de QBCore (Consultando BD)
    local license = nil
    for _, v in pairs(identifiers) do
        if string.find(v, 'license') then
            license = v
            break
        end
    end

    if license then
        -- Consultamos qué permiso tiene este usuario en la base de datos
        MySQL.scalar('SELECT `permission` FROM `permissions` WHERE `license` = ?', {license}, function(permission)
            local isAllowed = false

            -- Si el usuario tiene algún permiso, comprobamos si está en TU lista del Config
            if permission then
                if Config.Whitelist and Config.Whitelist.BypassRoles then
                    for _, allowedRole in ipairs(Config.Whitelist.BypassRoles) do
                        if permission == allowedRole then
                            isAllowed = true
                            break
                        end
                    end
                end
            end

            -- Veredicto final
            if isAllowed then
                deferrals.done() -- ¡Adentro!
            else
                deferrals.done(Config.Lang.WhitelistEnterDeny or
                                   "⛔ WHITELIST ACTIVA: No tienes permisos para entrar en este momento.")
            end
        end)
    else
        deferrals.done("❌ Error: No se pudo verificar tu licencia.")
    end
end)

-- COMANDO DE EMERGENCIA (Solo Consola)
-- Úsalo si te quedas fuera: "togglewhitelist_emergency" en la consola de txAdmin
RegisterCommand(Config.Commands.EmergencyWhitelist or "togglewhitelist_emergency", function(source, args)
    if source ~= 0 then
        print("^1[DP-ADMIN] Este comando es solo para consola de servidor.^7")
        return
    end

    ServerStates.whitelist = not ServerStates.whitelist
    SetResourceKvpInt('dp_whitelist_active', ServerStates.whitelist and 1 or 0)

    print("^1[DP-ADMIN] Whitelist de Emergencia cambiada a: " .. tostring(ServerStates.whitelist) .. "^7")
end, true)

-- ==========================================================================
--      7. SISTEMA DE POSICIONAMIENTO DEL MENÚ
-- ==========================================================================

-- Callback para obtener la posición
QBCore.Functions.CreateCallback('dpadmin:server:getMenuPos', function(source, cb)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then
        return cb(nil)
    end

    local cid = Player.PlayerData.citizenid

    MySQL.single('SELECT menu_top, menu_left, menu_scale FROM dp_preferences WHERE citizenid = ?', {cid}, function(row)
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

-- Evento para guardar la posición
RegisterNetEvent('dpadmin:server:saveMenuPos', function(posData)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then
        return
    end

    local cid = Player.PlayerData.citizenid

    MySQL.insert(
        'INSERT INTO dp_preferences (citizenid, menu_top, menu_left, menu_scale) VALUES (?, ?, ?, ?) ON DUPLICATE KEY UPDATE menu_top = VALUES(menu_top), menu_left = VALUES(menu_left), menu_scale = VALUES(menu_scale)',
        {cid, posData.top, posData.left, posData.scale})
end)

-- ==========================================================================
--      EVENTOS DEL SISTEMA
-- ==========================================================================

AddEventHandler('playerJoining', function()
    GlobalRefresh()
end)

AddEventHandler('playerDropped', function()
    local src = source
    if adminsInGodmode[src] then
        adminsInGodmode[src] = nil
    end

    GlobalRefresh()

    if AdminsOnDuty[src] then
        AdminsOnDuty[src] = nil
    end
end)

-- Detectar cambio de trabajo (SetJob)
AddEventHandler('QBCore:Server:OnPlayerUnload', function()
    GlobalRefresh()
end)
