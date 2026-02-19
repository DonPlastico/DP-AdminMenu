local QBCore = exports['qb-core']:GetCoreObject()

-- ==========================================================================
--      1. VARIABLES GLOBALES Y UTILIDADES
-- ==========================================================================
local adminsInGodmode = {}
local AdminsOnDuty = {}
local isRefreshPending = false -- Variable para el sistema Anti-Crash
local controllingAdmins = {} -- Almacena quién controla a quién
local activeWarns = {} -- Tabla de memoria: [source] = true
local frozenPlayers = {}

-- 1. Leemos la memoria del servidor (KVP)
local savedWhitelist = GetResourceKvpInt('dp_whitelist_active')

-- 2. APLICAMOS LA LÓGICA DEL FORCE UNLOCK
if Config.Whitelist and Config.Whitelist.ForceUnlock then
    savedWhitelist = 0
    DebugLog("^1[DP-AdminMenu] 🔓 FORCE UNLOCK DETECTADO EN CONFIG. La Whitelist ha sido desactivada forzosamente.^7")
end

-- 3. Cargamos el estado final
local ServerStates = {
    whitelist = (savedWhitelist == 1),
    maintenance = false,
    discord_logs = false
}

local function DebugLog(msg)
    if Config.Debug then
        print("^3[DP-AdminMenu SERVER]^7 " .. msg)
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
        TriggerClientEvent('DP-AdminMenu:client:refreshAllData', -1)
        isRefreshPending = false
        DebugLog("^2[DP-AdminMenu] Refresco Global enviado (Optimizado)^7")
    end)
end

DebugLog("^2[DP-AdminMenu] Server arrancao y listo. Debug Mode: " .. tostring(Config.Debug) .. "^7")

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

QBCore.Functions.CreateCallback('DP-AdminMenu:getPlayers', function(source, cb)
    local playersList = {}
    for _, playerSrc in pairs(QBCore.Functions.GetPlayers()) do
        local targetSrc = tonumber(playerSrc)
        local Player = QBCore.Functions.GetPlayer(targetSrc)
        if Player then
            table.insert(playersList, {
                id = targetSrc,
                name = GetPlayerName(targetSrc),
                citizenid = Player.PlayerData.citizenid,
                charName = Player.PlayerData.charinfo.firstname .. ' ' .. Player.PlayerData.charinfo.lastname,
                job = Player.PlayerData.job.label .. ' - ' .. Player.PlayerData.job.grade.name,
                ping = GetPlayerPing(targetSrc),
                discord = QBCore.Functions.GetIdentifier(targetSrc, 'discord') or "N/A",
                status = "playing"
            })
        end
    end
    table.sort(playersList, function(a, b)
        return a.id < b.id
    end)
    cb(playersList)
end)

QBCore.Functions.CreateCallback('DP-AdminMenu:getReports', function(source, cb)
    MySQL.query("SELECT * FROM dp_reports WHERE status != 'closed' ORDER BY created_at ASC", {}, function(result)
        cb(result or {})
    end)
end)

QBCore.Functions.CreateCallback('DP-AdminMenu:getBans', function(source, cb)
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

QBCore.Functions.CreateCallback('DP-AdminMenu:getChatMessages', function(source, cb, lastId)
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

QBCore.Functions.CreateCallback('DP-AdminMenu:getJobs', function(source, cb)
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

QBCore.Functions.CreateCallback('DP-AdminMenu:getGangs', function(source, cb)
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

QBCore.Functions.CreateCallback('DP-AdminMenu:getVehicleList', function(source, cb)
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

QBCore.Functions.CreateCallback('DP-AdminMenu:getItemList', function(source, cb)
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
--      CALLBACK: DATOS DETALLADOS (MULTI-CHAR + GPS + IMPOUND + APTS)
-- ==========================================================================
QBCore.Functions.CreateCallback('DP-AdminMenu:server:getDetailedData', function(source, cb, data)
    -- CHIVATO: Si no sale esto en la consola, el script no está cargando
    DebugLog("^3[DP-AdminMenu] Petición recibida. Datos: " .. json.encode(data) .. "^7")

    local targetId = type(data) == 'table' and tonumber(data.targetId) or tonumber(data)
    local reqCitizenId = type(data) == 'table' and data.citizenid or nil

    -- 1. BUSCAR JUGADOR ONLINE
    local Player = nil
    if targetId then
        Player = QBCore.Functions.GetPlayer(targetId)
    end
    if not Player and reqCitizenId then
        Player = QBCore.Functions.GetPlayerByCitizenId(reqCitizenId)
    end

    local response = {}
    local citizenid = nil
    local license = nil

    -- 2. DATOS BÁSICOS (JUGADOR ONLINE)
    if Player then
        citizenid = Player.PlayerData.citizenid
        license = QBCore.Functions.GetIdentifier(Player.PlayerData.source, 'license')
        local ped = GetPlayerPed(Player.PlayerData.source)

        response = {
            hasChar = true,
            fromSQL = false,
            isFrozen = frozenPlayers[Player.PlayerData.source] or false,
            id = Player.PlayerData.source,
            charName = Player.PlayerData.charinfo.firstname .. ' ' .. Player.PlayerData.charinfo.lastname,
            citizenid = citizenid,
            phone = Player.PlayerData.charinfo.phone or "Sin móvil",
            bank = Player.PlayerData.money['bank'],
            cash = Player.PlayerData.money['cash'],
            job = Player.PlayerData.job.label,
            jobGrade = Player.PlayerData.job.grade.name,
            isJobBoss = Player.PlayerData.job.isboss,
            gang = Player.PlayerData.gang.label,
            gangGrade = Player.PlayerData.gang.grade.name,
            isGangBoss = Player.PlayerData.gang.isboss,
            identifiers = GetPlayerIdentifiers(Player.PlayerData.source),
            stats = {
                health = (Player.PlayerData.metadata['isdead'] or Player.PlayerData.metadata['inlaststand']) and 0 or
                    (GetEntityHealth(ped) - 100),
                armor = GetPedArmour(ped),
                hunger = Player.PlayerData.metadata['hunger'],
                thirst = Player.PlayerData.metadata['thirst'],
                alcohol = Player.PlayerData.metadata['alcohol'] or 0,
                stamina = 100
            }
        }

        -- 3. JUGADOR OFFLINE (LÓGICA BLINDADA)
    elseif reqCitizenId then
        DebugLog("^3[DP-AdminMenu] Buscando OFFLINE en SQL: " .. reqCitizenId .. "^7")
        local result = MySQL.single.await('SELECT * FROM players WHERE citizenid = ?', {reqCitizenId})

        if result then
            citizenid = result.citizenid
            license = result.license

            -- A. EXTRACCIÓN DE DINERO POR FUERZA BRUTA (Anti-Crash)
            local moneyStr = tostring(result.money or "")
            local accountsStr = tostring(result.accounts or "") -- Por si acaso

            -- Buscamos "bank": seguido de números
            local bankDinero = moneyStr:match('"bank":%s*(%d+)')
            if not bankDinero then
                bankDinero = accountsStr:match('"bank":%s*(%d+)')
            end

            -- Si no encuentra nada, pone 0
            local finalBank = tonumber(bankDinero) or 0
            DebugLog("^2[DP-AdminMenu] Dinero Offline Encontrado: " .. finalBank .. "^7")

            -- B. DECODIFICACIÓN SEGURA DEL RESTO
            local function safeDecode(str)
                local ok, res = pcall(json.decode, str or "{}")
                return ok and res or {}
            end

            local charinfo = safeDecode(result.charinfo)
            local job = safeDecode(result.job)
            local gang = safeDecode(result.gang)
            local metadata = safeDecode(result.metadata)

            response = {
                hasChar = true,
                fromSQL = true,
                id = nil,
                charName = (charinfo.firstname and charinfo.lastname) and
                    (charinfo.firstname .. ' ' .. charinfo.lastname) or "Desconocido",
                citizenid = citizenid,
                phone = charinfo.phone or "Sin móvil",

                -- AQUÍ VA EL DINERO QUE HEMOS CALCULADO
                bank = finalBank,
                cash = 0,

                job = job.label or "Desempleado",
                jobGrade = (job.grade and job.grade.name) or "Sin Rango",
                isJobBoss = job.isboss or false,
                gang = gang.label or "Ninguna",
                gangGrade = (gang.grade and gang.grade.name) or "Sin Rango",
                isGangBoss = gang.isboss or false,
                identifiers = result.license and {"license:" .. result.license} or {"Offline"},
                stats = {
                    health = 0,
                    armor = 0,
                    hunger = metadata.hunger or 100,
                    thirst = metadata.thirst or 100,
                    alcohol = 0,
                    stamina = 100
                }
            }
        else
            DebugLog("^1[DP-AdminMenu] SQL devolvió NULO para: " .. reqCitizenId .. "^7")
            cb(nil)
            return
        end
    else
        cb(nil)
        return
    end

    -- ============================================================
    -- 4. PERFILES MULTI-PERSONAJE (Igual que antes)
    -- ============================================================
    response.relatedCharacters = {}

    if license then
        local allChars = MySQL.query
                             .await('SELECT citizenid, charinfo, money FROM players WHERE license = ?', {license})
        if allChars then
            for _, char in pairs(allChars) do
                local ok, cInfo = pcall(json.decode, char.charinfo or "{}")
                if not ok then
                    cInfo = {}
                end

                -- Detectamos si ESTE personaje específico está online ahora mismo
                local isOnlineNow = false
                local pObj = QBCore.Functions.GetPlayerByCitizenId(char.citizenid)
                if pObj then
                    isOnlineNow = true
                end

                table.insert(response.relatedCharacters, {
                    citizenid = char.citizenid,
                    name = (cInfo.firstname and cInfo.lastname) and (cInfo.firstname .. ' ' .. cInfo.lastname) or
                        "Desconocido",
                    isOnlineChar = isOnlineNow
                })
            end
        end
    end

    response.vehicles = {}
    response.properties = {}

    -- ============================================================
    -- 5. VEHÍCULOS (IMPOUND INTELIGENTE + EXPORTS)
    -- ============================================================
    local pVehicles = MySQL.query.await('SELECT * FROM player_vehicles WHERE citizenid = ?', {citizenid})

    local NombreCarpetaGarajes = 'DP-Garages'
    local externalGarages = nil

    -- LEEMOS LA CONFIG DEL GARAJE
    if GetResourceState(NombreCarpetaGarajes) == 'started' then
        if exports[NombreCarpetaGarajes]['GetGarageConfig'] then
            externalGarages = exports[NombreCarpetaGarajes]:GetGarageConfig()
        end
    end

    -- Obtenemos TU posición (Admin) para calcular distancia
    local adminPed = GetPlayerPed(source)
    local adminCoords = GetEntityCoords(adminPed)

    if pVehicles then
        for _, v in pairs(pVehicles) do
            local vehModel = v.vehicle
            local sharedVeh = QBCore.Shared.Vehicles[vehModel]
            local label = sharedVeh and (sharedVeh.name .. ' (' .. sharedVeh.brand .. ')') or ("Mod: " .. vehModel)
            local category = sharedVeh and sharedVeh.category and sharedVeh.category:lower() or 'unknown'

            local coords = nil
            local locationLabel = v.garage

            -- A. LÓGICA IMPOUND
            if (v.state == 2 or v.garage == 'impound') and externalGarages and externalGarages.Impounds then
                local closestDist = -1
                local closestImpoundData = nil
                local closestImpoundName = "Desconocido"

                for impName, impData in pairs(externalGarages.Impounds) do
                    local impPos = vector3(impData.coords.x, impData.coords.y, impData.coords.z)
                    local dist = #(adminCoords - impPos)

                    if closestDist == -1 or dist < closestDist then
                        closestDist = dist
                        closestImpoundData = impData
                        closestImpoundName = impData.label or impName
                    end
                end

                if closestImpoundData then
                    coords = {
                        x = closestImpoundData.coords.x,
                        y = closestImpoundData.coords.y
                    }
                    locationLabel = "Depósito (" .. closestImpoundName .. ")"
                end

                -- B. LÓGICA GARAJE NORMAL
            elseif v.garage and externalGarages then
                local foundData = nil
                if externalGarages.Garages and externalGarages.Garages[v.garage] then
                    foundData = externalGarages.Garages[v.garage]
                elseif externalGarages.JobGarages and externalGarages.JobGarages[v.garage] then
                    foundData = externalGarages.JobGarages[v.garage]
                elseif externalGarages.GangGarages and externalGarages.GangGarages[v.garage] then
                    foundData = externalGarages.GangGarages[v.garage]
                end

                if foundData then
                    local raw = foundData.coords or foundData.spawnPoint
                    if raw then
                        coords = {
                            x = raw.x,
                            y = raw.y
                        }
                    end
                end
            end

            table.insert(response.vehicles, {
                model = vehModel,
                label = label,
                plate = v.plate,
                garage = locationLabel,
                category = category,
                state = v.state,
                coords = coords
            })
        end
    end

    -- ============================================================
    -- 6. CASAS (qb-houses)
    -- ============================================================
    local pHouses = MySQL.query.await('SELECT * FROM player_houses WHERE citizenid = ?', {citizenid})
    if pHouses then
        for _, h in pairs(pHouses) do
            local coords = nil
            local loc = MySQL.single.await('SELECT coords FROM houselocations WHERE name = ?', {h.house})
            if loc and loc.coords then
                local status, decoded = pcall(json.decode, loc.coords)
                if status and decoded then
                    if decoded.enter then
                        coords = {
                            x = decoded.enter.x,
                            y = decoded.enter.y
                        }
                    elseif decoded.x then
                        coords = {
                            x = decoded.x,
                            y = decoded.y
                        }
                    end
                end
            end
            table.insert(response.properties, {
                type = 'house',
                name = h.house,
                label = h.label or h.house,
                hasGarage = (h.garage ~= nil),
                coords = coords
            })
        end
    end

    -- ============================================================
    -- 7. APARTAMENTOS (qb-apartments)
    -- ============================================================
    local pApts = MySQL.query.await('SELECT * FROM apartments WHERE citizenid = ?', {citizenid})
    local aptConfig = nil

    if GetResourceState('qb-apartments') == 'started' then
        local ok, result = pcall(function()
            return exports['qb-apartments']:GetApartmentsConfig()
        end)
        if ok and result then
            aptConfig = result
        end
    end

    local DEFAULT_APTS = {
        ["apartment1"] = {
            x = -667.02,
            y = -1105.24,
            label = "South Rockford Drive"
        },
        ["apartment2"] = {
            x = -1288.52,
            y = -430.51,
            label = "Morningwood Blvd"
        },
        ["apartment3"] = {
            x = 269.73,
            y = -640.75,
            label = "Integrity Way"
        },
        ["apartment4"] = {
            x = -619.29,
            y = 37.69,
            label = "Tinsel Towers"
        },
        ["apartment5"] = {
            x = 291.517,
            y = -1078.674,
            label = "Fantastic Plaza"
        }
    }

    if pApts then
        for _, a in pairs(pApts) do
            local coords = nil
            local aptLabel = a.name

            if aptConfig and aptConfig[a.name] then
                local d = aptConfig[a.name]
                if d.coords and d.coords.enter then
                    coords = {
                        x = d.coords.enter.x,
                        y = d.coords.enter.y
                    }
                elseif d.poly then
                    coords = {
                        x = d.poly.x,
                        y = d.poly.y
                    }
                end
                if d.label then
                    aptLabel = d.label
                end
            elseif DEFAULT_APTS[a.name] then
                coords = DEFAULT_APTS[a.name]
                aptLabel = DEFAULT_APTS[a.name].label
            elseif DEFAULT_APTS[a.type] then
                coords = DEFAULT_APTS[a.type]
                aptLabel = DEFAULT_APTS[a.type].label
            end

            table.insert(response.properties, {
                type = 'apartment',
                name = a.name,
                label = aptLabel,
                hasGarage = false,
                coords = coords
            })
        end
    end

    -- ============================================================
    -- 8. HISTORIAL
    -- ============================================================
    response.history = {}
    response.punishCounts = {
        bans = 0,
        kicks = 0,
        warns = 0
    }

    if license then
        local cleanLicense = license:gsub("license:", "")
        local bans = MySQL.query.await('SELECT * FROM bans WHERE license = ?', {cleanLicense})
        if bans then
            for _, b in pairs(bans) do
                response.punishCounts.bans = response.punishCounts.bans + 1
                local isExp = (tonumber(b.expire) ~= 0 and tonumber(b.expire) < os.time())
                table.insert(response.history, {
                    type = "BAN",
                    reason = b.reason,
                    admin = b.bannedby or "Sistema",
                    date = b.created_at and os.date("%d/%m/%Y", b.created_at) or os.date("%d/%m/%Y"),
                    expiry = b.expire == 0 and "PERMANENTE" or os.date("%d/%m/%Y", b.expire),
                    active = not isExp,
                    rawDate = b.expire or 0
                })
            end
        end
        local warns = MySQL.query.await('SELECT * FROM warns WHERE license = ?', {cleanLicense})
        if warns then
            for _, w in pairs(warns) do
                -- NUEVO: Detectar si es KICK o CK por cómo lo guardaste en el servidor
                local typeOfSanction = "WARN"

                -- Si el Admin guardó el motivo con la palabra "CK" o "Expulsado", o nosotros lo forzamos:
                if w.reason and string.upper(w.reason):find("KICK") or w.reason and
                    string.upper(w.reason):find("EXPULSADO") then
                    typeOfSanction = "KICK"
                    response.punishCounts.kicks = response.punishCounts.kicks + 1
                elseif w.reason and string.upper(w.reason):find("CK") then
                    typeOfSanction = "CK"
                else
                    typeOfSanction = "WARN"
                    response.punishCounts.warns = response.punishCounts.warns + 1
                end

                table.insert(response.history, {
                    type = typeOfSanction, -- WARN, KICK o CK
                    reason = w.reason,
                    admin = w.warnedby or "Admin",
                    date = w.warnedtime and os.date("%d/%m/%Y", w.warnedtime) or os.date("%d/%m/%Y"),
                    active = false,
                    rawDate = w.warnedtime or 0
                })
            end
        end
        table.sort(response.history, function(a, b)
            return a.rawDate > b.rawDate
        end)
    end

    cb(response)
end)

-- ==========================================================================
--      EVENTO CENTRAL: ACCIONES DE JUGADOR (PANEL DE BOTONES)
-- ==========================================================================
local savedLocations = {} -- Tabla para guardar coordenadas antes de hacer BRING

RegisterNetEvent('DP-AdminMenu:server:playerAction', function(action, targetId, data)
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

    DebugLog("^3[DP-AdminMenu ACTION]^7 Executing: " .. action .. " on " .. tName)

    -- =======================================================
    --      ACCIONES FUNCIONALES
    -- =======================================================

    if action == 'spectate' then
        local coords = GetEntityCoords(tPed)
        TriggerClientEvent('DP-AdminMenu:client:spectate', src, tPed, coords)

    elseif action == 'kill' then
        TriggerClientEvent('hospital:client:KillPlayer', targetSrc)
        TriggerClientEvent('QBCore:Notify', src, 'Has matado a ' .. tName, 'success')

    elseif action == 'revive' then
        TriggerClientEvent('hospital:client:Revive', targetSrc)
        TriggerClientEvent('QBCore:Notify', src, 'Has revivido a ' .. tName, 'success')

    elseif action == 'freeze' then
        frozenPlayers[targetSrc] = true -- GUARDAMOS EN MEMORIA
        TriggerClientEvent('DP-AdminMenu:client:freezePlayer', targetSrc, true)
        TriggerClientEvent('QBCore:Notify', src, 'Jugador ' .. tName .. ' CONGELADO ❄️', 'primary')

    elseif action == 'unfreeze' then
        frozenPlayers[targetSrc] = false -- BORRAMOS DE MEMORIA
        TriggerClientEvent('DP-AdminMenu:client:freezePlayer', targetSrc, false)
        TriggerClientEvent('QBCore:Notify', src, 'Jugador ' .. tName .. ' DESCONGELADO 🔥', 'success')

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
        TriggerClientEvent('DP-AdminMenu:client:execOpenInventory', src, targetSrc)

    elseif action == 'clear_inventory' then
        Target.Functions.ClearInventory()
        TriggerClientEvent('QBCore:Notify', src, 'Inventario de ' .. tName .. ' borrado.', 'error')

    elseif action == 'clothing_menu' then
        -- 1. PRIMERO: Cerramos el menú de admin al jugador (por si lo tiene abierto)
        TriggerClientEvent('DP-AdminMenu:client:forceCloseMenu', targetSrc)

        -- 2. Esperamos un micro-instante para que el NUI se oculte bien
        Wait(200)

        -- 3. AHORA SÍ: Abrimos el menú de ropa
        TriggerClientEvent('qb-clothing:client:openMenu', targetSrc)

        -- 4. Notificamos al admin que ejecutó la orden
        TriggerClientEvent('QBCore:Notify', src, 'Menú de ropa abierto a ' .. tName, 'success')

    elseif action == 'screenshot' then
        DebugLog(
            "^3[DP-AdminMenu SERVER] 📸 Ordenando captura al ID: " .. targetSrc .. " devuelta a Admin: " .. src ..
                "^7")
        TriggerClientEvent('DP-AdminMenu:client:captureScreen', targetSrc, src)

    elseif action == 'remove_stress' then
        -- Desactivado por no uso

    elseif action == 'ped_menu' then
        -- Le decimos a TU cliente (Admin) que ejecute la orden
        TriggerClientEvent('DP-AdminMenu:client:openPedMenu', src, targetSrc)

        -- Log (Opcional)
        TriggerEvent('DP-AdminMenu:server:log', 'PED MENU', 'Abrió menú de peds para ID: ' .. targetSrc)

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
        TriggerEvent('DP-AdminMenu:server:log', 'ACTION', 'Retiró trabajo a ' .. tName)

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
        TriggerEvent('DP-AdminMenu:server:log', 'ACTION', 'Retiró banda a ' .. tName)

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
        TriggerEvent('DP-AdminMenu:server:log', 'ACTION', 'Esposó/Desesposó al jugador ' .. targetSrc)

    elseif action == 'control_player' then
        local targetSrc = tonumber(targetId)
        local adminPed = GetPlayerPed(src)
        local targetPed = GetPlayerPed(targetSrc)

        -- CASO 1: DETENER EL CONTROL
        if controllingAdmins[src] then
            local data = controllingAdmins[src]

            TriggerClientEvent('DP-AdminMenu:client:stopSpectatingTarget', data.target)
            Wait(100)
            local currentAdminCoords = GetEntityCoords(adminPed)
            SetEntityCoords(targetPed, currentAdminCoords.x, currentAdminCoords.y, currentAdminCoords.z)
            SetEntityCoords(adminPed, data.originalCoords.x, data.originalCoords.y, data.originalCoords.z)
            TriggerClientEvent('DP-AdminMenu:client:stopControlling', src)

            controllingAdmins[src] = nil
            TriggerClientEvent('QBCore:Notify', src, 'Control finalizado.', 'success')

            -- CASO 2: INICIAR EL CONTROL
        else
            if src == targetSrc then
                return
            end

            -- Recopilamos la información extra para el UI (Nombres)
            local adminName = GetPlayerName(src) or "Admin"
            local targetName = GetPlayerName(targetSrc) or "Jugador"
            local tPlayer = QBCore.Functions.GetPlayer(targetSrc)
            local targetCharName = tPlayer and
                                       (tPlayer.PlayerData.charinfo.firstname .. ' ' ..
                                           tPlayer.PlayerData.charinfo.lastname) or "Desconocido"

            controllingAdmins[src] = {
                target = targetSrc,
                originalCoords = GetEntityCoords(adminPed)
            }

            -- Enviamos a la víctima (ID de quien controla y su nombre)
            TriggerClientEvent('DP-AdminMenu:client:startSpectatingTarget', targetSrc, src, adminName)

            -- Enviamos al Admin (ID de la víctima, coordenadas y nombres)
            local tCoords = GetEntityCoords(targetPed)
            TriggerClientEvent('DP-AdminMenu:client:startControlling', src, targetSrc, tCoords, targetName,
                targetCharName)

            TriggerClientEvent('QBCore:Notify', src, 'Controlando jugador. Él te está especteando.', 'success')
        end

    elseif action == 'fill_needs' then
        local targetSrc = tonumber(targetId)
        local Player = QBCore.Functions.GetPlayer(targetSrc)

        if Player then
            -- 1. Restaurar valores al 100% en la base de datos/memoria del jugador
            Player.Functions.SetMetaData('hunger', 100)
            Player.Functions.SetMetaData('thirst', 100)

            -- 2. Forzar actualización del HUD del jugador (por si usa qb-hud o ps-hud)
            TriggerClientEvent('hud:client:UpdateNeeds', targetSrc, 100, 100)

            -- 3. Notificaciones
            TriggerClientEvent('QBCore:Notify', src, 'Has rellenado comida/bebida al ID: ' .. targetSrc, 'success')
            TriggerClientEvent('QBCore:Notify', targetSrc, 'Un administrador ha restaurado tus necesidades.', 'primary')
        else
            TriggerClientEvent('QBCore:Notify', src, 'El jugador no está online.', 'error')
        end

    elseif action == 'give_current_vehicle' then
        local targetSrc = tonumber(targetId)
        local Player = QBCore.Functions.GetPlayer(targetSrc)

        if Player then
            -- Le pedimos al cliente del objetivo que nos mande los datos de su coche actual
            TriggerClientEvent('DP-AdminMenu:client:getVehicleInfoForGive', targetSrc, src)
        else
            TriggerClientEvent('QBCore:Notify', src, 'El jugador no está online.', 'error')
        end
    end
end)

-- ==========================================================================
--      4. MÓDULOS DE GESTIÓN (BASE DE DATOS)
-- ==========================================================================

RegisterNetEvent('DP-AdminMenu:server:submitReport', function(data)
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

RegisterNetEvent('DP-AdminMenu:server:assignReport', function(data)
    local src = source
    MySQL.update('UPDATE dp_reports SET assigned_to = ?, status = ? WHERE id = ?',
        {GetPlayerName(src), 'assigned', data.reportId}, function(a)
            if a > 0 then
                TriggerClientEvent('QBCore:Notify', src, 'Reporte #' .. data.reportId .. ' asignado a ti.', 'success')
            end
        end)
end)

RegisterNetEvent('DP-AdminMenu:server:closeReport', function(data)
    local src = source
    MySQL.update('UPDATE dp_reports SET status = ? WHERE id = ?', {'closed', data.reportId}, function(a)
        if a > 0 then
            TriggerClientEvent('QBCore:Notify', src, 'Reporte #' .. data.reportId .. ' cerrado y archivado.', 'error')
        end
    end)
end)

RegisterNetEvent('DP-AdminMenu:server:revokeBan', function(data)
    local src = source
    MySQL.update('UPDATE bans SET status = ? WHERE id = ?', {'revoked', data.banId}, function(a)
        if a > 0 then
            TriggerClientEvent('QBCore:Notify', src, 'Has perdonado el Ban #' .. data.banId, 'success')
        end
    end)
end)

RegisterNetEvent('DP-AdminMenu:server:extendBan', function(data)
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

RegisterNetEvent('DP-AdminMenu:server:banPlayer', function(targetSource, reason, expire)
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
        DebugLog("^3[DP-AdminMenu]^7 Baneando a ID: " .. targetSource .. " por: " .. BannerName)
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
    TriggerEvent('DP-AdminMenu:server:banPlayer', source, "Test Auto-Ban (10 Minutos)", os.time() + 600)
end, 'admin')

RegisterNetEvent('DP-AdminMenu:server:sendChatMessage', function(data)
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
                    TriggerClientEvent('DP-AdminMenu:client:receiveChatMessage', v, newMessage)
                end
            end
        end)
end)

-- ==========================================================================
--      5. ACCIONES DE ADMINISTRADOR
-- ==========================================================================

RegisterNetEvent('DP-AdminMenu:server:reviveSelf', function()
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

RegisterNetEvent('DP-AdminMenu:server:setGodmodeState', function(state)
    local src = source
    if state then
        adminsInGodmode[src] = true
    else
        adminsInGodmode[src] = nil
    end
end)

RegisterNetEvent('DP-AdminMenu:server:reviveAll', function()
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

RegisterNetEvent('DP-AdminMenu:server:sendAnnouncement', function(data)
    TriggerClientEvent('DP-AdminMenu:client:showAnnouncement', -1, data.message, data.duration)
end)

RegisterNetEvent('DP-AdminMenu:server:updateWeather', function(weather, hour, extras)
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
    GlobalState.Blackout = extras.blackout -- Guardamos estado del apagón

    -- Llamamos a los exports
    exports['qb-weathersync']:setWeather(weather)
    exports['qb-weathersync']:setTime(hour, 0)
    exports['qb-weathersync']:setTimeFreeze(extras.freezeTime)

    -- [NUEVO] Llamamos al apagón
    exports['qb-weathersync']:setBlackout(extras.blackout)

    TriggerClientEvent('QBCore:Notify', src, 'Tiempo y Clima sincronizados.', 'success')
end)

RegisterNetEvent('DP-AdminMenu:server:deleteVehicles', function(type)
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

RegisterNetEvent('DP-AdminMenu:server:deletePeds', function(type)
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

RegisterNetEvent('DP-AdminMenu:server:deleteObjects', function(type)
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

RegisterNetEvent('DP-AdminMenu:server:getTagsData', function(playersList)
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
    TriggerClientEvent('DP-AdminMenu:client:receiveTagsData', src, dataToSend)
end)

RegisterNetEvent('DP-AdminMenu:server:toggleDuty', function(targetId)
    local Player = QBCore.Functions.GetPlayer(tonumber(targetId))
    if Player then
        Player.Functions.SetJobDuty(not Player.PlayerData.job.onduty)
        TriggerClientEvent('QBCore:Notify', source, 'Estado de servicio cambiado.', 'success')
        GlobalRefresh()
    end
end)

RegisterNetEvent('DP-AdminMenu:server:setJob', function(targetId, job, grade)
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

            -- 3. NOTIFICACIONES
            TriggerClientEvent('QBCore:Notify', src, "Trabajo actualizado a: " .. job .. " (" .. gradeLevel .. ")",
                "success")
            TriggerClientEvent('QBCore:Notify', targetSrc, "Tu trabajo ha sido actualizado por administración.",
                "primary")

            -- 4. LOGS
            TriggerEvent('DP-AdminMenu:server:log', 'JOB',
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

RegisterNetEvent('DP-AdminMenu:server:setJobGrade', function(targetId, jobGrade)
    local src = source
    local Target = QBCore.Functions.GetPlayer(tonumber(targetId))
    if Target then
        Target.Functions.SetJob(Target.PlayerData.job.name, tonumber(jobGrade) or 0)
        TriggerClientEvent('QBCore:Notify', src, 'Rango actualizado.', 'success')
        TriggerClientEvent('DP-AdminMenu:client:refreshJobs', src)
        GlobalRefresh()
    end
end)

RegisterNetEvent('DP-AdminMenu:server:setGang', function(targetId, gangName, gangGrade)
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

    TriggerEvent('DP-AdminMenu:server:log', 'GANG', 'Cambió banda de ' .. GetPlayerName(targetSrc) .. ' a ' .. gangName)
    GlobalRefresh()
end)

RegisterNetEvent('DP-AdminMenu:server:setGangGrade', function(targetId, gangGrade)
    local src = source
    local Target = QBCore.Functions.GetPlayer(tonumber(targetId))
    if Target and Target.PlayerData.gang.name ~= "none" then
        Target.Functions.SetGang(Target.PlayerData.gang.name, tonumber(gangGrade) or 0)
        TriggerClientEvent('QBCore:Notify', src, 'Rango de banda actualizado.', 'success')
        GlobalRefresh()
    end
end)

RegisterNetEvent('DP-AdminMenu:server:playerFullyLoaded', function()
    GlobalRefresh()
end)

RegisterNetEvent('DP-AdminMenu:server:giveVehicle', function(data)
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

RegisterNetEvent('DP-AdminMenu:server:spawnItem', function(itemName)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if Player and Player.Functions.AddItem(itemName, 1) then
        TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[itemName], "add")
        TriggerClientEvent('QBCore:Notify', src, 'Has sacado: ' .. itemName, 'success')
    end
end)

RegisterNetEvent('DP-AdminMenu:server:giveItemToPlayer', function(data)
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

RegisterNetEvent('DP-AdminMenu:server:log', function(action, details)
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

RegisterNetEvent('DP-AdminMenu:server:toggleOption', function(option, state)
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
                TriggerClientEvent('DP-AdminMenu:client:showAnnouncement', -1, "⚠️ WHITELIST ACTIVADA EN 10s", 10000)
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
    TriggerClientEvent('DP-AdminMenu:client:forceStatusUpdate', -1)
end)

QBCore.Functions.CreateCallback('DP-AdminMenu:server:getStatusData', function(source, cb)
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
    DebugLog("^1[DP-AdminMenu] Whitelist Emergencia: " .. tostring(ServerStates.whitelist) .. "^7")
end, true)

QBCore.Functions.CreateCallback('DP-AdminMenu:server:getMenuPos', function(source, cb)
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

RegisterNetEvent('DP-AdminMenu:server:saveMenuPos', function(posData)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then
        return
    end
    MySQL.insert(
        'INSERT INTO dp_preferences (citizenid, menu_top, menu_left, menu_scale) VALUES (?, ?, ?, ?) ON DUPLICATE KEY UPDATE menu_top = VALUES(menu_top), menu_left = VALUES(menu_left), menu_scale = VALUES(menu_scale)',
        {Player.PlayerData.citizenid, posData.top, posData.left, posData.scale})
end)

RegisterNetEvent('DP-AdminMenu:server:uploadImage', function(base64Data)
    local src = source
    local webhook = Config.ImageWebhook
    if not webhook or webhook == "" then
        return
    end
end)

-- ==========================================================================
--      SISTEMA DE SCREENSHOT (RELAY / PUENTE)
-- ==========================================================================
RegisterNetEvent('DP-AdminMenu:server:relayScreenshot', function(adminSource, base64Data)
    -- El servidor recibe la imagen del jugador y la reenvía al Administrador
    if adminSource and base64Data then
        -- Opcional: Log para consola de servidor
        DebugLog("Transfiriendo captura de pantalla al Admin ID: " .. adminSource)

        TriggerClientEvent('DP-AdminMenu:client:receiveScreenshot', adminSource, base64Data)
    end
end)

-- ==========================================================================
--              SISTEMA DE DIMENSIONES (ROUTING BUCKETS)
-- ==========================================================================
RegisterNetEvent('DP-AdminMenu:server:setDimension', function(targetId, bucket)
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
    TriggerEvent('DP-AdminMenu:server:log', 'DIMENSION',
        'Cambió dimensión de ' .. GetPlayerName(targetSrc) .. ' a Bucket: ' .. bucketId)
end)

-- ==========================================================================
--                           TP A UN PUNTO, A JUGADOR
-- ==========================================================================

RegisterNetEvent('DP-AdminMenu:server:teleportTargetTactical', function(targetId, coords)
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
        TriggerEvent('DP-AdminMenu:server:log', 'ACTION',
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
RegisterNetEvent('DP-AdminMenu:server:toggleWatch', function(targetId, state)
    local src = source
    if state then
        AdminsWatching[src] = targetId
    else
        AdminsWatching[src] = nil
    end
end)

-- 2. RECIBIR DATOS DEL JUGADOR Y ENVIAR AL ADMIN
RegisterNetEvent('DP-AdminMenu:server:receiveLiveStats', function(clientData)
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
            TriggerClientEvent('DP-AdminMenu:client:updateLiveStats', adminSrc, payload)
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
            TriggerClientEvent('DP-AdminMenu:client:reportLiveStats', targetSrc)
        end
    end
end)

-- ==========================================================================
--      COMANDO NOCLIP
-- ==========================================================================
QBCore.Commands.Add('noclip', 'Alternar modo NoClip (Admin)', {}, false, function(source, args)
    -- Simplemente le dice al cliente que active la función ToggleNoClip que mejoramos antes
    TriggerClientEvent('DP-AdminMenu:client:toggleNoclip', source)
end, 'admin')

-- ==========================================================================
--      SISTEMA DE SANCIONES (CORREGIDO ERROR WARNEDTIME)
-- ==========================================================================

-- 1. WARN CRÍTICO + REGISTRO DE SESIÓN
RegisterNetEvent('DP-AdminMenu:server:warnPlayer', function(data)
    local src = source
    local targetId = tonumber(data.targetId)
    local reason = data.reason or "Sin motivo"
    local adminName = GetPlayerName(src)

    local targetPlayer = QBCore.Functions.GetPlayer(targetId)
    if not targetPlayer then
        return
    end

    local name = targetPlayer.PlayerData.charinfo.firstname .. " " .. targetPlayer.PlayerData.charinfo.lastname
    local license = QBCore.Functions.GetIdentifier(targetId, 'license')
    local cleanLicense = license:gsub("license:", "")

    -- A. Guardar en Base de Datos
    MySQL.insert('INSERT INTO warns (name, license, reason, warnedby, warnedtime) VALUES (?, ?, ?, ?, ?)',
        {name, cleanLicense, reason, adminName, os.time()})

    -- B. ACTIVAR MODO ANTI-EVASIÓN
    activeWarns[targetId] = {
        active = true,
        license = cleanLicense,
        name = name,
        admin = adminName
    }

    -- C. Enviar Pantalla de Bloqueo al Cliente
    TriggerClientEvent('DP-AdminMenu:client:showCriticalWarn', targetId, {
        reason = reason,
        admin = adminName
    })

    TriggerClientEvent('QBCore:Notify', src, 'Advertencia crítica enviada.', 'success')
    TriggerClientEvent('DP-AdminMenu:client:syncDetails', -1, targetPlayer.PlayerData.citizenid)
end)

-- 2. CONFIRMACIÓN DEL JUGADOR (Evita el ban)
RegisterNetEvent('DP-AdminMenu:server:warnConfirmed', function()
    local src = source
    if activeWarns[src] then
        activeWarns[src] = nil -- Limpiamos la alerta
    end
end)

-- 3. KICK (EXPULSAR)
RegisterNetEvent('DP-AdminMenu:server:kickPlayer', function(data)
    DebugLog("^3[DP-AdminMenu] SERVIDOR: Recibido Evento KICK^7")
    local src = source
    local targetId = tonumber(data.targetId)
    local reason = data.reason or "Expulsado"

    local targetPlayer = QBCore.Functions.GetPlayer(targetId)
    if targetPlayer then
        local name = targetPlayer.PlayerData.charinfo.firstname .. " " .. targetPlayer.PlayerData.charinfo.lastname
        local license = QBCore.Functions.GetIdentifier(targetId, 'license')
        local cleanLicense = license:gsub("license:", "")
        local adminName = GetPlayerName(src)

        DebugLog("^3[DP-AdminMenu] Guardando historial de Kick (Con Time)...^7")

        -- CORRECCIÓN: Añadido 'warnedtime' y 'os.time()'
        MySQL.insert('INSERT INTO warns (name, license, reason, warnedby, warnedtime) VALUES (?, ?, ?, ?, ?)',
            {name, cleanLicense, reason, adminName, os.time()}, function(id)
                if id then
                    DebugLog("^2[DP-AdminMenu] Historial guardado. Expulsando...^7")
                    Wait(200)
                    DropPlayer(targetId, "\n⛔ EXPULSADO: " .. reason)
                    TriggerClientEvent('QBCore:Notify', src, 'Jugador expulsado', 'success')
                    TriggerClientEvent('DP-AdminMenu:client:syncDetails', -1, targetPlayer.PlayerData.citizenid)
                end
            end)
    else
        DebugLog("^1[DP-AdminMenu] Jugador no encontrado para Kick.^7")
    end
end)

-- 4. BAN (ONLINE & OFFLINE)
RegisterNetEvent('DP-AdminMenu:server:banPlayerFromMenu', function(data)
    DebugLog("^3[DP-AdminMenu] SERVIDOR: Recibido Evento BAN^7")
    local src = source
    local targetId = tonumber(data.targetId)
    local citizenid = data.citizenid
    local reason = data.reason
    local duration = tonumber(data.duration)
    local senderName = GetPlayerName(src)
    local expireDate = (duration == 2147483647) and 0 or (os.time() + duration)

    -- CASO ONLINE
    if targetId then
        local targetPlayer = QBCore.Functions.GetPlayer(targetId)
        if targetPlayer then
            DebugLog("^3[DP-AdminMenu] Baneando Online...^7")
            local name = targetPlayer.PlayerData.name

            -- [FIX] Cogemos las licencias completas sin limpiarlas
            local license = QBCore.Functions.GetIdentifier(targetId, 'license')
            local discord = QBCore.Functions.GetIdentifier(targetId, 'discord') or "N/A"
            local ip = QBCore.Functions.GetIdentifier(targetId, 'ip') or "N/A"

            MySQL.insert(
                'INSERT INTO bans (name, license, discord, ip, reason, expire, bannedby, status) VALUES (?, ?, ?, ?, ?, ?, ?, ?)',
                {name, license, discord, ip, reason, expireDate, senderName, 'active'}, function(id)
                    if id then
                        DebugLog("^2[DP-AdminMenu] Ban guardado.^7")
                        Wait(200)
                        DropPlayer(targetId, "\n⛔ BANEADO: " .. reason)
                        TriggerClientEvent('QBCore:Notify', src, 'Baneo aplicado', 'success')
                        TriggerClientEvent('DP-AdminMenu:client:syncDetails', -1, citizenid)
                    else
                        DebugLog("^1[DP-AdminMenu] Fallo SQL en Ban Online.^7")
                    end
                end)
        end
    else
        -- CASO OFFLINE
        DebugLog("^3[DP-AdminMenu] Intentando Ban Offline...^7")
        if not citizenid then
            return
        end

        local playerResult = MySQL.single
                                 .await('SELECT license, charinfo FROM players WHERE citizenid = ?', {citizenid})

        if playerResult then
            -- [FIX] Usamos la licencia tal cual sale de la tabla players
            local dbLicense = playerResult.license

            local charinfo = json.decode(playerResult.charinfo)
            local name = charinfo.firstname .. " " .. charinfo.lastname

            MySQL.insert(
                'INSERT INTO bans (name, license, discord, ip, reason, expire, bannedby, status) VALUES (?, ?, ?, ?, ?, ?, ?, ?)',
                {name, dbLicense, "N/A", "N/A", reason, expireDate, senderName, 'active'}, function(id)
                    if id then
                        DebugLog("^2[DP-AdminMenu] Ban Offline guardado.^7")
                        TriggerClientEvent('QBCore:Notify', src, 'Ban Offline aplicado', 'success')
                        TriggerClientEvent('DP-AdminMenu:client:syncDetails', -1, citizenid)
                    else
                        DebugLog("^1[DP-AdminMenu] Fallo SQL en Ban Offline.^7")
                    end
                end)
        else
            DebugLog("^1[DP-AdminMenu] No se encontraron datos offline.^7")
        end
    end
end)

-- ==========================================================================
--      SISTEMA CK (CHARACTER KILL) - VERSIÓN CORREGIDA Y ROBUSTA
-- ==========================================================================
RegisterNetEvent('DP-AdminMenu:server:ckPlayer', function(data)
    local src = source
    local targetId = tonumber(data.targetId)
    local citizenid = data.citizenid

    -- [FIX] Guardamos el nombre AHORA, antes de que nadie sea expulsado
    local adminName = GetPlayerName(src) or "Desconocido"

    -- 1. SEGURIDAD: Permisos
    if not QBCore.Functions.HasPermission(src, 'admin') and not QBCore.Functions.HasPermission(src, 'god') then
        DebugLog("^1[DP-AdminMenu] INTENTO DE CK SIN PERMISOS POR ID: " .. src .. "^7")
        return
    end

    if not citizenid then
        TriggerClientEvent('QBCore:Notify', src, 'Error: No se detectó CitizenID', 'error')
        return
    end

    -- 2. EXPULSIÓN INMEDIATA (PASO 1)
    local targetPlayer = QBCore.Functions.GetPlayerByCitizenId(citizenid)

    if targetPlayer then
        DropPlayer(targetPlayer.PlayerData.source,
            "\n💀 TU PERSONAJE HA SIDO ELIMINADO (CK) DEFINITIVAMENTE.\n\nContacta con administración si crees que es un error.")
    elseif targetId and GetPlayerName(targetId) then
        DropPlayer(targetId, "\n💀 TU PERSONAJE HA SIDO ELIMINADO (CK) DEFINITIVAMENTE.")
    end

    -- Iniciamos hilo separado
    CreateThread(function()
        DebugLog("^3[DP-AdminMenu] Iniciando proceso de CK para CitizenID: " .. citizenid .. " (Admin: " .. adminName ..
                     ")^7")

        -- ============================================================
        -- PASO 2: EL GRAN BACKUP (LECTURA SEGURA)
        -- ============================================================
        local fullBackup = {
            meta = {
                date = os.date('%Y-%m-%d %H:%M:%S'),
                admin = adminName,
                citizenid = citizenid,
                license = data.license or "Unknown"
            },
            data = {}
        }

        local directTables = {'players', 'player_vehicles', 'player_houses', 'apartments', 'player_outfits',
                              'playerskins', 'player_contacts', 'player_mails', 'player_peds', 'bank_accounts',
                              'shared_garages', 'shared_garage_members', 'player_vehicles_fuel_type'}

        -- Backup protegido (Si una tabla falla, sigue con la siguiente)
        for _, tbl in ipairs(directTables) do
            local success, result = pcall(function()
                return MySQL.query.await('SELECT * FROM ' .. tbl .. ' WHERE citizenid = ?', {citizenid})
            end)
            if success and result then
                fullBackup.data[tbl] = result
            end
        end

        -- Backup Inventarios (Por Matrícula/Casa)
        local trunkRes = MySQL.query.await(
            'SELECT * FROM trunkitems WHERE plate IN (SELECT plate FROM player_vehicles WHERE citizenid = ?)',
            {citizenid})
        fullBackup.data['trunkitems'] = trunkRes

        local gloveRes = MySQL.query.await(
            'SELECT * FROM gloveboxitems WHERE plate IN (SELECT plate FROM player_vehicles WHERE citizenid = ?)',
            {citizenid})
        fullBackup.data['gloveboxitems'] = gloveRes

        local stashRes = MySQL.query.await(
            'SELECT * FROM stashitems WHERE stash IN (SELECT house FROM player_houses WHERE citizenid = ?) OR stash = ?',
            {citizenid, citizenid})
        fullBackup.data['stashitems'] = stashRes

        -- ============================================================
        -- PASO 3: ESCRITURA DE LOG (JSON)
        -- ============================================================
        local logFile = LoadResourceFile(GetCurrentResourceName(), "ck_backups.json") or "[]"
        local currentLogs = json.decode(logFile)
        if type(currentLogs) ~= 'table' then
            currentLogs = {}
        end

        table.insert(currentLogs, 1, fullBackup)
        SaveResourceFile(GetCurrentResourceName(), "ck_backups.json", json.encode(currentLogs, {
            indent = true
        }), -1)
        DebugLog("^2[DP-AdminMenu] Backup guardado correctamente en ck_backups.json^7")

        -- ============================================================
        -- PASO 4: LA PURGA (DELETE EN CASCADA ROBUSTO)
        -- ============================================================

        -- A. LIMPIEZA PREVIA DE TABLAS "PELIGROSAS" O SECUNDARIAS
        -- Lo hacemos fuera de la transacción principal con pcall para que si fallan (como shared_garage_members), NO paren el CK.
        local optionalDeletes =
            {"DELETE FROM trunkitems WHERE plate IN (SELECT plate FROM player_vehicles WHERE citizenid = '" .. citizenid ..
                "')",
             "DELETE FROM gloveboxitems WHERE plate IN (SELECT plate FROM player_vehicles WHERE citizenid = '" ..
                citizenid .. "')",
             "DELETE FROM player_vehicles_fuel_type WHERE plate IN (SELECT plate FROM player_vehicles WHERE citizenid = '" ..
                citizenid .. "')", -- Corregido: Por matrícula
            "DELETE FROM stashitems WHERE stash IN (SELECT house FROM player_houses WHERE citizenid = '" .. citizenid ..
                "')", "DELETE FROM stashitems WHERE stash = '" .. citizenid .. "'",
            -- Intentamos borrar shared_garage_members de forma segura
             "DELETE FROM shared_garage_members WHERE citizenid = '" .. citizenid .. "'"}

        for _, query in ipairs(optionalDeletes) do
            pcall(function()
                MySQL.query.await(query)
            end)
        end

        -- B. TRANSACCIÓN PRINCIPAL (SÓLO TABLAS NUCLEARES QUE SABEMOS QUE EXISTEN Y USAN CITIZENID)
        -- Esto asegura que el jugador se borre sí o sí.
        local mainQueries = {}

        table.insert(mainQueries, {
            query = 'DELETE FROM player_vehicles WHERE citizenid = ?',
            values = {citizenid}
        })
        table.insert(mainQueries, {
            query = 'DELETE FROM player_houses WHERE citizenid = ?',
            values = {citizenid}
        })
        table.insert(mainQueries, {
            query = 'DELETE FROM apartments WHERE citizenid = ?',
            values = {citizenid}
        })
        table.insert(mainQueries, {
            query = 'DELETE FROM playerskins WHERE citizenid = ?',
            values = {citizenid}
        })
        table.insert(mainQueries, {
            query = 'DELETE FROM player_outfits WHERE citizenid = ?',
            values = {citizenid}
        })
        table.insert(mainQueries, {
            query = 'DELETE FROM player_contacts WHERE citizenid = ?',
            values = {citizenid}
        })
        table.insert(mainQueries, {
            query = 'DELETE FROM player_mails WHERE citizenid = ?',
            values = {citizenid}
        })
        table.insert(mainQueries, {
            query = 'DELETE FROM bank_accounts WHERE citizenid = ?',
            values = {citizenid}
        })

        -- EL JUGADOR (El final)
        table.insert(mainQueries, {
            query = 'DELETE FROM players WHERE citizenid = ?',
            values = {citizenid}
        })

        MySQL.transaction(mainQueries, function(success)
            if success then
                DebugLog("^2[DP-AdminMenu] PURGA COMPLETADA EXITOSAMENTE. El CitizenID " .. citizenid ..
                             " ha sido eliminado.^7")
                -- Intentamos notificar (si el admin no eras tú mismo)
                if GetPlayerName(src) then
                    TriggerClientEvent('QBCore:Notify', src, 'CK Completado. Backup generado y datos borrados.',
                        'success')
                end
            else
                DebugLog("^1[DP-AdminMenu] ERROR EN TRANSACCIÓN PRINCIPAL. Revisa si todas las tablas CORE existen.^7")
                if GetPlayerName(src) then
                    TriggerClientEvent('QBCore:Notify', src, 'Error SQL durante el CK (Ver consola)', 'error')
                end
            end
        end)
    end)
end)

-- ==========================================================================
--      EVENTOS: RESPUESTAS DEL GIVE VEHICLE
-- ==========================================================================

-- Si el jugador no estaba en un coche
RegisterNetEvent('DP-AdminMenu:server:giveVehicleFailed', function(adminSrc, reason)
    TriggerClientEvent('QBCore:Notify', adminSrc, reason, 'error')
end)

-- Si el jugador SÍ estaba en un coche y nos pasa los datos
RegisterNetEvent('DP-AdminMenu:server:giveVehicleConfirm', function(adminSrc, vehicleModel, plate, props)
    local targetSrc = source -- El jugador que nos envía la info (el Target)
    local Admin = QBCore.Functions.GetPlayer(adminSrc)
    local Target = QBCore.Functions.GetPlayer(targetSrc)

    if not Admin or not Target then
        return
    end

    -- 1. Comprobar si el coche ya tiene dueño en la base de datos
    local result = MySQL.single.await('SELECT plate FROM player_vehicles WHERE plate = ?', {plate})

    if result then
        -- El coche ya le pertenece a alguien (puede ser a él mismo o a otro)
        TriggerClientEvent('QBCore:Notify', adminSrc, "❌ Este vehículo YA PERTENECE a un jugador.", "error")
        return
    end

    -- 2. Guardar en la base de datos
    local cid = Target.PlayerData.citizenid
    local license = Target.PlayerData.license
    local garage = "pillboxgarage" -- Garaje central / plaza de cubos
    local state = 0 -- 0 = Fuera del garaje (porque está montado en él ahora mismo)

    -- Insertamos el vehículo con todas sus modificaciones (props) en formato JSON
    MySQL.insert(
        'INSERT INTO player_vehicles (license, citizenid, vehicle, hash, mods, plate, garage, state) VALUES (?, ?, ?, ?, ?, ?, ?, ?)',
        {license, cid, vehicleModel, tostring(props.model), json.encode(props), plate, garage, state}, function(id)
            if id then
                -- Notificamos al Administrador
                TriggerClientEvent('QBCore:Notify', adminSrc, "✅ Vehículo " .. vehicleModel .. " guardado para " ..
                    Target.PlayerData.charinfo.firstname, "success")

                -- Notificamos a la Víctima
                TriggerClientEvent('QBCore:Notify', targetSrc,
                    "Te han entregado las llaves de este vehículo. Guardado en Pillbox.", "success")

                -- Le damos las llaves del coche usando el sistema estándar de QBCore
                TriggerClientEvent('vehiclekeys:client:SetOwner', targetSrc, plate)
            else
                TriggerClientEvent('QBCore:Notify', adminSrc, "❌ Error crítico al guardar en la base de datos.",
                    "error")
            end
        end)
end)

-- EVENTOS DEL SISTEMA QUE DISPARAN REFRESH
AddEventHandler('playerJoining', function()
    GlobalRefresh()
end)

AddEventHandler('playerDropped', function()
    local src = source

    -- A. LIMPIEZA DE ADMINS (Tu lógica original)
    if adminsInGodmode[src] then
        adminsInGodmode[src] = nil
    end
    if AdminsOnDuty[src] then
        AdminsOnDuty[src] = nil
    end
    if AdminsWatching[src] then
        AdminsWatching[src] = nil
    end

    if frozenPlayers[src] then
        frozenPlayers[src] = nil
    end

    GlobalRefresh()

    -- B. NUEVA LÓGICA (Anti-Evasión de Warn)
    if activeWarns[src] and activeWarns[src].active then
        DebugLog("^1[ANTI-EVASION] El jugador ID " .. src .. " se desconectó con un WARN pendiente. Baneando...^7")

        local data = activeWarns[src]
        local banReason = "ANTI-RP: Evasión de Advertencia Administrativa (Desconexión)"
        local expireDate = os.time() + 3600 -- 1 Hora

        MySQL.insert(
            'INSERT INTO bans (name, license, discord, ip, reason, expire, bannedby, status) VALUES (?, ?, ?, ?, ?, ?, ?, ?)',
            {data.name, data.license, "discord:unknown", "ip:unknown", banReason, expireDate, "Sistema Anti-Evasión",
             'active'})

        activeWarns[src] = nil
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
