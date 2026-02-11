local QBCore = exports['qb-core']:GetCoreObject()

-- ==========================================================================
--      1. CONSTANTES Y CONFIGURACIÓN
-- ==========================================================================

-- Tabla de colores GTA (RGB -> ID) para llantas y extras
local GtaColors = {{
    id = 0,
    r = 0,
    g = 0,
    b = 0
}, {
    id = 112,
    r = 255,
    g = 255,
    b = 255
}, {
    id = 27,
    r = 192,
    g = 10,
    b = 10
}, {
    id = 147,
    r = 0,
    g = 0,
    b = 20
}, {
    id = 64,
    r = 0,
    g = 50,
    b = 150
}, {
    id = 88,
    r = 255,
    g = 200,
    b = 0
}, {
    id = 55,
    r = 0,
    g = 150,
    b = 0
}, {
    id = 38,
    r = 210,
    g = 100,
    b = 0
}, {
    id = 135,
    r = 200,
    g = 0,
    b = 150
}, {
    id = 145,
    r = 100,
    g = 0,
    b = 150
}, {
    id = 37,
    r = 210,
    g = 180,
    b = 0
}, {
    id = 5,
    r = 180,
    g = 180,
    b = 180
}, {
    id = 120,
    r = 100,
    g = 100,
    b = 100
}, {
    id = 3,
    r = 50,
    g = 50,
    b = 50
}, {
    id = 92,
    r = 150,
    g = 220,
    b = 50
}, {
    id = 28,
    r = 218,
    g = 165,
    b = 32
}, {
    id = 74,
    r = 90,
    g = 130,
    b = 180
}, {
    id = 49,
    r = 0,
    g = 50,
    b = 30
}, {
    id = 33,
    r = 120,
    g = 90,
    b = 20
}, {
    id = 106,
    r = 224,
    g = 186,
    b = 122
}}

-- ==========================================================================
--      2. VARIABLES DE ESTADO (GLOBAL STATE)
-- ==========================================================================
-- Variables Generales
local isMenuOpen = false
local lastCoords = nil -- Para el comando BACK

-- CANDADOS DE SEGURIDAD (ANTI-CRASH)
local isGodmodeRunning = false
local isInvisibleRunning = false
local isStaminaRunning = false
local isSpeedRunning = false
local isJumpRunning = false
local isBlipsRunning = false
local isTagsRunning = false
local isEntityInfoRunning = false

-- Estados de Jugador
local godmodeActive = false
local invisibleActive = false
local staminaActive = false
local cuffsActive = false

-- Estados de HUD / UI
local blipsActive = false
local createdBlips = {}

-- Estados de Tags
local tagsActive = false
local tagsDataCache = {}
local showID, showName, showAccount = true, true, true
local showHealth, showArmor, showHunger, showThirst = true, true, true, true

-- Velocidad
local speedActive = false
local currentSpeedIndex = 4
local speedMultipliers = {0.1, 0.25, 0.5, 1.0, 1.5, 2.0, 3.0, 5.0}

-- Salto
local jumpActive = false
local currentJumpIndex = 2
local jumpMultipliers = {0.1, 1.0, 3.0, 5.0, 8.0, 10.0, 15.0}

-- Noclip
local noClipActive = false
local isNoClipLoopRunning = false
local noClipSpeed = 1.0
local minSpeed = 0.2
local maxSpeed = 5.0
local speedStep = 0.2

-- Entity Info
local isCursorModeActive = false

-- ==========================================================================
--      3. FUNCIONES DE UTILIDAD (HELPERS)
-- ==========================================================================

local function DebugLog(msg)
    if Config.Debug then
        print("^5[DP-ADMIN CLIENT]^7 " .. msg)
    end
end

DebugLog("CLIENTE INICIADO. Tamo ready pa la accion.")

local function DrawText3D(x, y, z, text)
    SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry("STRING")
    SetTextCentre(true)
    AddTextComponentString(text)
    SetDrawOrigin(x, y, z, 0)
    DrawText(0.0, 0.0)
    local factor = (string.len(text)) / 370
    DrawRect(0.0, 0.0 + 0.0125, 0.017 + factor, 0.03, 0, 0, 0, 75)
    ClearDrawOrigin()
end

local function GetClosestGtaColor(r, g, b)
    local minDistance = 999999
    local closestID = 0
    for _, color in ipairs(GtaColors) do
        local distance = (color.r - r) ^ 2 + (color.g - g) ^ 2 + (color.b - b) ^ 2
        if distance < minDistance then
            minDistance = distance
            closestID = color.id
        end
    end
    return closestID
end

-- ==========================================================================
--      4. LÓGICA DE BUCLES (WORKER THREADS BLINDADOS)
-- ==========================================================================

local function RunGodmodeLoop()
    if isGodmodeRunning then
        return
    end -- SI YA CORRE, SALIMOS
    isGodmodeRunning = true -- PONEMOS CANDADO

    Citizen.CreateThread(function()
        while godmodeActive do
            Wait(0)
            local ped = PlayerPedId()
            SetEntityInvincible(ped, true)
            SetPlayerInvincible(PlayerId(), true)
            SetPedCanRagdoll(ped, false)
            if GetEntityHealth(ped) < 200 then
                SetEntityHealth(ped, 200)
            end
        end
        -- Cleanup al salir
        local ped = PlayerPedId()
        SetEntityInvincible(ped, false)
        SetPlayerInvincible(PlayerId(), false)
        SetPedCanRagdoll(ped, true)
        TriggerServerEvent('dpadmin:server:setGodmodeState', false)

        isGodmodeRunning = false -- QUITAMOS CANDADO
    end)
end

local function RunInvisibleLoop()
    if isInvisibleRunning then
        return
    end
    isInvisibleRunning = true

    Citizen.CreateThread(function()
        local p = PlayerPedId()
        while invisibleActive do
            SetEntityLocallyVisible(p)
            SetEntityAlpha(p, 51, false) -- 51 es más transparente (20%)
            Wait(0)
        end
        SetEntityVisible(p, true, false)
        ResetEntityAlpha(p)
        isInvisibleRunning = false
    end)
end

local function RunStaminaLoop()
    if isStaminaRunning then
        return
    end
    isStaminaRunning = true

    Citizen.CreateThread(function()
        while staminaActive do
            RestorePlayerStamina(PlayerId(), 1.0)
            Wait(0)
        end
        isStaminaRunning = false
    end)
end

local function RunSpeedLoop()
    if isSpeedRunning then
        return
    end
    isSpeedRunning = true

    Citizen.CreateThread(function()
        while speedActive do
            Wait(0)
            local ped = PlayerPedId()
            local finalSpeed = speedMultipliers[currentSpeedIndex]
            if finalSpeed > 10.0 then
                finalSpeed = 10.0
            end

            SetPedMoveRateOverride(ped, finalSpeed)
            if finalSpeed > 1.0 then
                SetRunSprintMultiplierForPlayer(PlayerId(), 1.49)
            else
                SetRunSprintMultiplierForPlayer(PlayerId(), 1.0)
            end

            SetPedCanRagdoll(ped, false)
            SetPedRagdollOnCollision(ped, false)
            SetEntityInvincible(ped, true)

            -- Controles Rueda
            if not isMenuOpen then
                DisableControlAction(0, 14, true);
                DisableControlAction(0, 15, true)
                DisableControlAction(0, 261, true);
                DisableControlAction(0, 262, true)

                if IsDisabledControlJustPressed(0, 15) or IsDisabledControlJustPressed(0, 261) then -- Arriba
                    if currentSpeedIndex < #speedMultipliers then
                        currentSpeedIndex = currentSpeedIndex + 1
                        PlaySoundFrontend(-1, "NAV_UP_DOWN", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)
                        SendNUIMessage({
                            type = "updateSpeed",
                            value = speedMultipliers[currentSpeedIndex]
                        })
                    end
                end
                if IsDisabledControlJustPressed(0, 14) or IsDisabledControlJustPressed(0, 262) then -- Abajo
                    if currentSpeedIndex > 1 then
                        currentSpeedIndex = currentSpeedIndex - 1
                        PlaySoundFrontend(-1, "NAV_UP_DOWN", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)
                        SendNUIMessage({
                            type = "updateSpeed",
                            value = speedMultipliers[currentSpeedIndex]
                        })
                    end
                end
            end
        end
        -- Cleanup
        local ped = PlayerPedId()
        SetPedMoveRateOverride(ped, 0.0)
        SetRunSprintMultiplierForPlayer(PlayerId(), 1.0)
        SetPedCanRagdoll(ped, true)
        SetPedRagdollOnCollision(ped, true)
        if not godmodeActive then
            SetEntityInvincible(ped, false)
        end

        isSpeedRunning = false
    end)
end

local function RunJumpLoop()
    if isJumpRunning then
        return
    end
    isJumpRunning = true

    Citizen.CreateThread(function()
        local hasJumped = false
        while jumpActive do
            Wait(0)
            local ped = PlayerPedId()
            local mult = jumpMultipliers[currentJumpIndex]

            SetEntityInvincible(ped, true)
            SetPedCanRagdoll(ped, true)
            SetPedRagdollOnCollision(ped, true)

            if mult < 1.0 then
                DisableControlAction(0, 22, true)
            elseif mult > 1.0 then
                if IsPedJumping(ped) then
                    DisableControlAction(0, 22, true)
                    if not hasJumped then
                        local force = (mult - 1.0) * 8.0
                        ApplyForceToEntity(ped, 1, 0.0, 0.0, force, 0.0, 0.0, 0.0, 0, false, true, true, false, true)
                        hasJumped = true
                    end
                elseif IsPedFalling(ped) then
                    DisableControlAction(0, 22, true)
                else
                    if not IsPedFalling(ped) then
                        hasJumped = false
                    end
                end
            end

            -- Controles Rueda
            if not isMenuOpen then
                DisableControlAction(0, 14, true);
                DisableControlAction(0, 15, true)
                if IsDisabledControlJustPressed(0, 15) or IsDisabledControlJustPressed(0, 261) then -- Arriba
                    if currentJumpIndex < #jumpMultipliers then
                        currentJumpIndex = currentJumpIndex + 1
                        SendNUIMessage({
                            type = "updateJump",
                            value = jumpMultipliers[currentJumpIndex]
                        })
                    end
                end
                if IsDisabledControlJustPressed(0, 14) or IsDisabledControlJustPressed(0, 262) then
                    if currentJumpIndex > 1 then
                        currentJumpIndex = currentJumpIndex - 1
                        SendNUIMessage({
                            type = "updateJump",
                            value = jumpMultipliers[currentJumpIndex]
                        })
                    end
                end
            end
        end
        if not godmodeActive then
            SetEntityInvincible(PlayerPedId(), false)
        end
        isJumpRunning = false
    end)
end

local function RunBlipsLoop()
    if isBlipsRunning then
        return
    end
    isBlipsRunning = true

    Citizen.CreateThread(function()
        while blipsActive do
            local players = GetActivePlayers()
            for _, player in ipairs(players) do
                local ped = GetPlayerPed(player)
                if DoesEntityExist(ped) then
                    if not DoesBlipExist(createdBlips[player]) then
                        local blip = AddBlipForEntity(ped)
                        SetBlipSprite(blip, 1)
                        SetBlipColour(blip, 0)
                        SetBlipScale(blip, 0.85)
                        SetBlipShowCone(blip, true)
                        SetBlipCategory(blip, 7)
                        BeginTextCommandSetBlipName("STRING")
                        AddTextComponentString(GetPlayerName(player))
                        EndTextCommandSetBlipName(blip)
                        createdBlips[player] = blip
                    end
                end
            end
            -- Limpiar blips de desconectados
            for player, blip in pairs(createdBlips) do
                if not NetworkIsPlayerActive(player) or not DoesEntityExist(GetPlayerPed(player)) then
                    RemoveBlip(blip)
                    createdBlips[player] = nil
                end
            end
            Wait(1000)
        end
        -- Cleanup al salir
        for _, blip in pairs(createdBlips) do
            if DoesBlipExist(blip) then
                RemoveBlip(blip)
            end
        end
        createdBlips = {}
        isBlipsRunning = false
    end)
end

local function RunTagsLoop()
    if isTagsRunning then
        return
    end
    isTagsRunning = true

    -- Hilo 1: Obtener Datos
    Citizen.CreateThread(function()
        while tagsActive do
            local myCoords = GetEntityCoords(PlayerPedId())
            local activePlayers = GetActivePlayers()
            local nearbyPlayers = {}
            for _, player in ipairs(activePlayers) do
                local targetPed = GetPlayerPed(player)
                local targetCoords = GetEntityCoords(targetPed)
                if #(myCoords - targetCoords) < 300.0 then
                    table.insert(nearbyPlayers, GetPlayerServerId(player))
                end
            end
            if #nearbyPlayers > 0 then
                TriggerServerEvent('dpadmin:server:getTagsData', nearbyPlayers)
            end
            Wait(1000)
        end
    end)

    -- Hilo 2: Dibujar y Controles
    Citizen.CreateThread(function()
        local barWidth = 0.035
        local barHeight = 0.006
        local barSpacing = 0.001

        local function Draw3DBar(x, y, z, xOffset, pct, r, g, b)
            SetDrawOrigin(x, y, z, 0)
            if pct > 0 then
                local fillWidth = barWidth * pct
                local fillOffset = xOffset - (barWidth / 2) + (fillWidth / 2)
                DrawRect(fillOffset, 0.0, fillWidth, barHeight, r, g, b, 255)
            end
            ClearDrawOrigin()
        end

        while tagsActive do
            -- Controles NumPad
            DisableControlAction(0, 118, true);
            DisableControlAction(0, 111, true)
            DisableControlAction(0, 117, true);
            DisableControlAction(0, 109, true)
            DisableControlAction(0, 110, true);
            DisableControlAction(0, 108, true)
            DisableControlAction(0, 96, true)

            if IsDisabledControlJustPressed(0, 118) then
                showID = not showID
            end
            if IsDisabledControlJustPressed(0, 111) then
                showName = not showName
            end
            if IsDisabledControlJustPressed(0, 117) then
                showAccount = not showAccount
            end
            if IsDisabledControlJustPressed(0, 109) then
                showHealth = not showHealth
            end
            if IsDisabledControlJustPressed(0, 110) then
                showArmor = not showArmor
            end
            if IsDisabledControlJustPressed(0, 108) then
                showHunger = not showHunger
            end
            if IsDisabledControlJustPressed(0, 96) then
                showThirst = not showThirst
            end

            local myCoords = GetEntityCoords(PlayerPedId())
            local activePlayers = GetActivePlayers()

            for _, player in ipairs(activePlayers) do
                local ped = GetPlayerPed(player)
                local pedCoords = GetEntityCoords(ped)
                local distance = #(myCoords - pedCoords)

                if distance < 300.0 and IsEntityVisible(ped) then
                    local serverID = GetPlayerServerId(player)
                    local data = tagsDataCache[serverID]

                    if data then
                        local x, y, z = table.unpack(pedCoords)
                        z = z + 1.15

                        -- Texto
                        local textLine = ""
                        if showID then
                            textLine = textLine .. "~g~[" .. serverID .. "]~w~ "
                        end
                        if showName then
                            textLine = textLine .. data.charName .. " "
                        end
                        if showAccount then
                            textLine = textLine .. "~b~(" .. data.steamName .. ")~w~"
                        end
                        if textLine ~= "" then
                            DrawText3D(x, y, z, textLine)
                        end

                        -- Barras
                        local barsZ = z - 0.20
                        local activeBars = {}
                        if showHealth then
                            local hp = GetEntityHealth(ped) - 100
                            local pct = math.max(0.0, math.min(1.0, hp / 100.0))
                            local r, g, b = 46, 204, 113
                            if pct < 0.5 then
                                r, g, b = 231, 76, 60
                            elseif pct < 0.8 then
                                r, g, b = 241, 196, 15
                            end
                            table.insert(activeBars, {
                                pct = pct,
                                r = r,
                                g = g,
                                b = b
                            })
                        end
                        if showArmor then
                            table.insert(activeBars, {
                                pct = math.max(0.0, math.min(1.0, GetPedArmour(ped) / 100.0)),
                                r = 52,
                                g = 152,
                                b = 219
                            })
                        end
                        if showHunger and data.hunger then
                            table.insert(activeBars, {
                                pct = math.max(0.0, math.min(1.0, data.hunger / 100.0)),
                                r = 230,
                                g = 126,
                                b = 34
                            })
                        end
                        if showThirst and data.thirst then
                            table.insert(activeBars, {
                                pct = math.max(0.0, math.min(1.0, data.thirst / 100.0)),
                                r = 52,
                                g = 225,
                                b = 235
                            })
                        end

                        if #activeBars > 0 then
                            local totalGroupWidth = (barWidth * #activeBars) + (barSpacing * (#activeBars - 1))
                            local currentXOffset = -(totalGroupWidth / 2) + (barWidth / 2)
                            for _, bar in ipairs(activeBars) do
                                Draw3DBar(x, y, barsZ, currentXOffset, bar.pct, bar.r, bar.g, bar.b)
                                currentXOffset = currentXOffset + barWidth + barSpacing
                            end
                        end
                    end
                end
            end
            Wait(0)
        end
        isTagsRunning = false
    end)
end

-- ==========================================================================
--      ENTIDAD INFO (RAYCAST DEV TOOL)
-- ==========================================================================
local entityInfoActive = false
local cursorActive = false -- Variable global para el comando

-- Función Raycast
local function GetEntityInView()
    local camCoords = GetGameplayCamCoord()
    local camRot = GetGameplayCamRot(2)
    local fwd = vector3(-math.sin(math.rad(camRot.z)) * math.abs(math.cos(math.rad(camRot.x))),
        math.cos(math.rad(camRot.z)) * math.abs(math.cos(math.rad(camRot.x))), math.sin(math.rad(camRot.x)))
    local endCoords = camCoords + (fwd * 30.0)
    local ray = StartShapeTestRay(camCoords.x, camCoords.y, camCoords.z, endCoords.x, endCoords.y, endCoords.z, -1,
        PlayerPedId(), 0)
    local _, hit, hitCoords, _, entityHit = GetShapeTestResult(ray)
    return hit, entityHit, hitCoords
end

-- COMANDO J (CURSOR)
RegisterCommand('toggleDevCursor', function()
    if not entityInfoActive then
        return
    end

    cursorActive = not cursorActive
    SetNuiFocus(cursorActive, cursorActive)
    SetNuiFocusKeepInput(cursorActive)

    if cursorActive then
        QBCore.Functions.Notify("🖱️ CURSOR ACTIVADO", "primary")
    else
        QBCore.Functions.Notify("📷 CÁMARA ACTIVADA", "success")
    end
end)
RegisterKeyMapping('toggleDevCursor', 'DevTool: Cursor', 'keyboard', 'J')

-- BUCLE PRINCIPAL
local function RunEntityInfoLoop()
    if isEntityInfoRunning then
        return
    end
    isEntityInfoRunning = true

    -- 1. RESETEAR ESTADO AL INICIAR
    cursorActive = false
    SetNuiFocus(false, false)
    SetNuiFocusKeepInput(false)

    Citizen.CreateThread(function()
        local lastUpdate = 0

        while entityInfoActive do
            Wait(0)

            -- BLOQUEO DE CONTROLES
            if cursorActive then
                DisableControlAction(0, 1, true);
                DisableControlAction(0, 2, true)
                DisableControlAction(0, 24, true);
                DisableControlAction(0, 25, true)
                DisableControlAction(0, 30, true);
                DisableControlAction(0, 31, true)
                DisableControlAction(0, 22, true)
            end

            -- 1. CALCULAR EL RAYO (LÁSER)
            local hit, entity, hitCoords = GetEntityInView()
            local myPed = PlayerPedId()

            -- CAMBIO 1: USAR HUESO DEL PECHO (SPINE3)
            local startLaser = GetPedBoneCoords(myPed, 24818, 0.0, 0.0, 0.0)

            -- Si el rayo no toca nada, calculamos el final en el aire
            local endLaser = hitCoords
            if hit == 0 then
                local camRot = GetGameplayCamRot(2)
                local fwd = vector3(-math.sin(math.rad(camRot.z)) * math.abs(math.cos(math.rad(camRot.x))),
                    math.cos(math.rad(camRot.z)) * math.abs(math.cos(math.rad(camRot.x))), math.sin(math.rad(camRot.x)))
                endLaser = GetGameplayCamCoord() + (fwd * 30.0)
            end

            -- 2. DIBUJAR LÁSER Y BOLA (NEGROS)
            DrawLine(startLaser.x, startLaser.y, startLaser.z, endLaser.x, endLaser.y, endLaser.z, 0, 0, 0, 200)

            if hit == 1 then
                DrawMarker(28, endLaser.x, endLaser.y, endLaser.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.2, 0.2, 0.2, 0, 0, 0,
                    200, false, true, 2, nil, nil, false)
            end

            -- 3. LÓGICA DE ENTIDAD
            local entType = GetEntityType(entity)

            if hit == 1 and DoesEntityExist(entity) and entType ~= 0 then
                -- [E] ELIMINAR
                if IsControlJustPressed(0, 38) then
                    if IsEntityAPed(entity) and IsPedAPlayer(entity) then
                        QBCore.Functions.Notify("❌ Jugadores no.", "error")
                    else
                        NetworkRequestControlOfEntity(entity)
                        SetEntityAsMissionEntity(entity, true, true)
                        DeleteEntity(entity)
                        QBCore.Functions.Notify("🗑️ Eliminado.", "success")
                    end
                end

                -- [G] CONGELAR
                if IsControlJustPressed(0, 47) then
                    NetworkRequestControlOfEntity(entity)
                    local isFrozen = IsEntityPositionFrozen(entity)
                    FreezeEntityPosition(entity, not isFrozen)
                    if isFrozen then
                        QBCore.Functions.Notify("💧 Soltado", "success")
                    else
                        QBCore.Functions.Notify("🧊 Congelado", "primary")
                    end
                end
            end

            -- ENVIAR DATOS A JS (Cada 100ms)
            if GetGameTimer() - lastUpdate > 100 then
                lastUpdate = GetGameTimer()
                local data = {}

                if hit == 1 and DoesEntityExist(entity) and entType ~= 0 then
                    data.hash = GetEntityModel(entity)
                    data.name = "ENTIDAD"
                    if entType == 2 then
                        data.name = GetLabelText(GetDisplayNameFromVehicleModel(data.hash))
                    elseif entType == 1 then
                        data.name = "PED/NPC"
                    elseif entType == 3 then
                        if IsEntityAMissionEntity(entity) then
                            data.name = "OBJETO (SCRIPT)"
                        else
                            data.name = "OBJETO (MAPA)"
                        end
                    end

                    data.id = entity
                    data.netId = NetworkGetNetworkIdFromEntity(entity)
                    local owner = NetworkGetEntityOwner(entity)
                    data.owner = (owner > 0) and GetPlayerServerId(owner) or "Local"

                    local coords = GetEntityCoords(entity)
                    data.coords = string.format("%.2f, %.2f, %.2f", coords.x, coords.y, coords.z)
                    data.distance = string.format("%.2f", #(GetEntityCoords(PlayerPedId()) - coords))
                    data.heading = string.format("%.2f", GetEntityHeading(entity))
                    data.speed = string.format("%.1f", GetEntitySpeed(entity) * 3.6)

                    data.health = GetEntityHealth(entity)
                    data.maxHealth = GetEntityMaxHealth(entity)

                    if entType == 1 then
                        data.armour = GetPedArmour(entity)
                        data.relGroup = GetPedRelationshipGroupHash(entity)
                        data.relToPlayer = GetRelationshipBetweenPeds(entity, PlayerPedId())
                    else
                        data.armour = "N/A";
                        data.relGroup = "N/A";
                        data.relToPlayer = "N/A"
                    end
                else
                    data = {
                        hash = 0,
                        name = "NINGUNO",
                        id = 0,
                        netId = 0,
                        owner = 0,
                        coords = "0,0,0",
                        distance = 0,
                        heading = 0,
                        speed = 0,
                        health = 0,
                        maxHealth = 0,
                        armour = 0,
                        relGroup = 0,
                        relToPlayer = "N/A"
                    }
                end

                SendNUIMessage({
                    type = "updateEntityInfo",
                    data = data
                })
            end
        end

        -- AL SALIR: LIMPIEZA
        cursorActive = false
        if not isMenuOpen then
            SetNuiFocus(false, false)
            SetNuiFocusKeepInput(false)
        end
        EnableAllControlActions(0)
        isEntityInfoRunning = false
    end)
end

-- ==========================================================================
--      5. GESTIÓN DEL MENÚ
-- ==========================================================================

local function toggleMenu(state)
    isMenuOpen = state
    SetNuiFocus(state, state)
    DebugLog("Menu puesto en: " .. tostring(state))

    if state then
        -- 1. NUEVO: PEDIMOS LA POSICIÓN PRIMERO
        QBCore.Functions.TriggerCallback('dpadmin:server:getMenuPos', function(pos)

            -- 2. CARGA DE DATOS ORIGINAL (CASCADA)
            QBCore.Functions.TriggerCallback('dpadmin:getPlayers', function(players)
                QBCore.Functions.TriggerCallback('dpadmin:getReports', function(reports)
                    QBCore.Functions.TriggerCallback('dpadmin:getBans', function(bans)
                        QBCore.Functions.TriggerCallback('dpadmin:getChatMessages', function(chat)
                            QBCore.Functions.TriggerCallback('dpadmin:getJobs', function(jobsList)
                                QBCore.Functions.TriggerCallback('dpadmin:getGangs', function(gangsList)

                                    local currentState = {
                                        freezeTime = GlobalState.FreezeTime or false,
                                        freezeWeather = GlobalState.FreezeWeather or false,
                                        blackout = GlobalState.Blackout or false,
                                        wind = GlobalState.HighWind or false,
                                        waves = GlobalState.HighWaves or false,
                                        currentWeather = GlobalState.CurrentWeather or "EXTRASUNNY",
                                        timeHour = (GlobalState.Time and GlobalState.Time.hour) or 12
                                    }

                                    SendNUIMessage({
                                        type = "open",
                                        debugMode = Config.Debug,
                                        playerCount = #players,
                                        players = players,
                                        reports = reports,
                                        bans = bans,
                                        chat = chat,
                                        jobs = jobsList,
                                        gangs = gangsList,
                                        weatherState = currentState,
                                        menuPosition = pos
                                    })

                                end)
                            end)
                        end)
                    end)
                end)
            end)

        end) -- Fin del callback de posición

        -- Hilo de Tiempo Real (Solo mientras menú abierto)
        Citizen.CreateThread(function()
            while isMenuOpen do
                SendNUIMessage({
                    type = "updateGameTime",
                    hours = GetClockHours(),
                    minutes = GetClockMinutes(),
                    weather = GlobalState.CurrentWeather or "CLEAR"
                })
                Wait(1000)
            end
        end)
    else
        SendNUIMessage({
            type = "close"
        })
    end
end

local function ForceResetAll()
    local p = PlayerPedId()
    if godmodeActive then
        godmodeActive = false;
        Wait(100)
    end
    if invisibleActive then
        invisibleActive = false;
        Wait(100)
    end
    if staminaActive then
        staminaActive = false;
        Wait(100)
    end
    if blipsActive then
        blipsActive = false;
        createdBlips = {};
        Wait(100)
    end
    if tagsActive then
        tagsActive = false;
        tagsDataCache = {};
        Wait(100)
    end
    if cuffsActive then
        cuffsActive = false
        if QBCore.Functions.GetPlayerData().metadata["ishandcuffed"] then
            TriggerEvent('police:client:GetCuffed', GetPlayerServerId(PlayerId()))
            ClearPedTasks(p)
        end
    end

    -- Restaurar estado ped
    SetEntityInvincible(p, false)
    SetPlayerInvincible(PlayerId(), false)
    SetPedCanRagdoll(p, true)
    TriggerServerEvent('dpadmin:server:setGodmodeState', false)
    SetEntityVisible(p, true, false)
    ResetEntityAlpha(p)
    DebugLog("SISTEMA: Poderes reseteados.")
end

-- ==========================================================================
--      6. EVENTOS Y COMANDOS DE INICIALIZACIÓN
-- ==========================================================================

RegisterCommand(Config.Commands.Admin, function()
    toggleMenu(true)
end)

RegisterCommand(Config.Commands.Report, function()
    SetNuiFocus(true, true);
    SendNUIMessage({
        type = "openReportMenu"
    })
end)

AddEventHandler('onResourceStart', function(r)
    if GetCurrentResourceName() == r then
        ForceResetAll()
    end
end)

AddEventHandler('onResourceStop', function(resourceName)
    if (GetCurrentResourceName() ~= resourceName) then
        return
    end

    -- 1. Ejecutamos TU limpieza original (si existe la función)
    -- Esto limpia lo que ya tenías programado antes
    if ForceResetAll then
        ForceResetAll()
    end

    -- 2. LIMPIEZA DE EMERGENCIA DEL NOCLIP
    -- Esto asegura que no te quedes invisible ni congelado si reinicias
    local ped = PlayerPedId()
    SetEntityVisible(ped, true, false)
    FreezeEntityPosition(ped, false)
    SetEntityCollision(ped, true, true)
    SetEntityVelocity(ped, 0.0, 0.0, 0.0)
    ResetEntityAlpha(ped)

    -- 3. Limpieza de Foco (Por si te pilló con el menú abierto)
    SetNuiFocus(false, false)
    SetNuiFocusKeepInput(false)
end)

RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    ForceResetAll()
end)

-- Listeners globales (Viento y Olas)
CreateThread(function()
    while true do
        Wait(1000)
        if GlobalState.HighWind then
            SetWind(1.0);
            SetWindSpeed(12.0);
            SetWindDirection(GetGameplayCamRelativeHeading())
        else
            SetWind(0.1)
        end
        if GlobalState.HighWaves then
            SetDeepOceanScaler(10.0)
        else
            ResetDeepOceanScaler()
        end
    end
end)

-- ==========================================================================
--      7. NUI CALLBACKS (CONTROLADORES)
-- ==========================================================================

-- --- A. SISTEMA GENERAL ---
RegisterNUICallback('closeMenu', function(data, cb)
    toggleMenu(false);
    cb('ok')
    isCursorModeActive = false
    SetNuiFocusKeepInput(false)
end)

RegisterNUICallback('closeReport', function(data, cb)
    SetNuiFocus(false, false);
    cb('ok')
end)

-- --- B. DATOS (REPORTES, BANS, CHAT) ---
RegisterNUICallback('submitReport', function(data, cb)
    SetNuiFocus(false, false)
    TriggerServerEvent('dpadmin:server:submitReport', data)
    cb('ok')
end)

RegisterNUICallback('assignReport', function(data, cb)
    TriggerServerEvent('dpadmin:server:assignReport', data)
    SetTimeout(500, function()
        QBCore.Functions.TriggerCallback('dpadmin:getReports', function(r)
            SendNUIMessage({
                type = "updateReports",
                reports = r
            })
        end)
    end)
    cb('ok')
end)

RegisterNUICallback('deleteReport', function(data, cb)
    TriggerServerEvent('dpadmin:server:closeReport', data)
    SetTimeout(500, function()
        QBCore.Functions.TriggerCallback('dpadmin:getReports', function(r)
            SendNUIMessage({
                type = "updateReports",
                reports = r
            })
        end)
    end)
    cb('ok')
end)

RegisterNUICallback('revokeBan', function(data, cb)
    TriggerServerEvent('dpadmin:server:revokeBan', data)
    SetTimeout(500, function()
        QBCore.Functions.TriggerCallback('dpadmin:getBans', function(b)
            SendNUIMessage({
                type = "open",
                bans = b
            })
        end)
    end)
    cb('ok')
end)

RegisterNUICallback('extendBan', function(data, cb)
    TriggerServerEvent('dpadmin:server:extendBan', data)
    SetTimeout(500, function()
        QBCore.Functions.TriggerCallback('dpadmin:getBans', function(b)
            SendNUIMessage({
                type = "open",
                bans = b
            })
        end)
    end)
    cb('ok')
end)

RegisterNUICallback('getMoreChatMessages', function(data, cb)
    QBCore.Functions.TriggerCallback('dpadmin:getChatMessages', function(c)
        cb(c)
    end, data.oldestId)
end)

-- ENVIAR MENSAJE (Soporte para texto + imágenes)
RegisterNUICallback('sendAdminMessage', function(data, cb)
    -- data ahora contiene { message = "...", images = ["url1", "url2"] }
    TriggerServerEvent('dpadmin:server:sendChatMessage', data)
    cb('ok')
end)

RegisterNetEvent('dpadmin:client:receiveChatMessage', function(msg)
    if isMenuOpen then
        SendNUIMessage({
            type = "newChatMessage",
            message = msg
        })
    end
end)

RegisterNetEvent('dpadmin:client:receiveTagsData', function(data)
    for _, info in ipairs(data) do
        tagsDataCache[info.id] = info
    end
end)

RegisterNUICallback('sendAnnouncement', function(data, cb)
    toggleMenu(false);
    TriggerServerEvent('dpadmin:server:sendAnnouncement', data);
    cb('ok')
end)

RegisterNetEvent('dpadmin:client:showAnnouncement', function(msg, dur)
    SendNUIMessage({
        type = "showAnnouncement",
        message = msg,
        duration = dur
    })
end)

-- Este evento actualiza HOME y JOBS sin cerrar el menú
RegisterNetEvent('dpadmin:client:refreshAllData', function()
    if isMenuOpen then
        -- 1. HOME
        QBCore.Functions.TriggerCallback('dpadmin:getPlayers', function(players)
            -- 2. JOBS
            QBCore.Functions.TriggerCallback('dpadmin:getJobs', function(jobsList)
                -- 3. GANGS
                QBCore.Functions.TriggerCallback('dpadmin:getGangs', function(gangsList)
                    SendNUIMessage({
                        type = "updateAllLists",
                        players = players,
                        jobs = jobsList,
                        gangs = gangsList
                    })
                end)
            end)
        end)
    end
end)

RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    Citizen.Wait(2000)
    TriggerServerEvent('dpadmin:server:playerFullyLoaded')
end)

-- EVENTO PARA FORZAR ACTUALIZACIÓN DEL UI (SYNC GLOBAL)
RegisterNetEvent('dpadmin:client:forceStatusUpdate', function()
    -- Enviamos mensaje al NUI para que recargue la página de Status si está abierta
    SendNUIMessage({
        type = "forceStatusRefresh"
    })
end)

RegisterNUICallback('updateWeather', function(data, cb)
    TriggerServerEvent('dpadmin:server:updateWeather', data.weather, data.hour, data.extras);
    cb('ok')
end)

-- --- C. ACCIONES (TRIGGER) ---
RegisterNUICallback('triggerAction', function(data, cb)
    local action = data.action
    DebugLog("Action Trigger: " .. action)

    if action == 'open_map_menu' then
        toggleMenu(false) -- Cierra el menú de admin actual
        TriggerEvent('dpadmin:client:openMap') -- Lanza el evento del mapa nuevo
        return cb('ok') -- Termina aquí para no seguir leyendo
    end

    if action == 'noclip' then
        -- ExecuteCommand('noclip') -- Comando externo (normalmente qb-admin)
        TriggerServerEvent('dpadmin:server:log', 'NOCLIP', 'Alternó el estado de NoClip.')

    elseif action == 'revive' then
        TriggerEvent('hospital:client:Revive')
        TriggerEvent('QBCore:Client:SetStatus', 'is_dead', false)
        TriggerEvent('QBCore:Client:SetStatus', 'in_laststand', false)
        TriggerServerEvent('dpadmin:server:log', 'REVIVE', 'El administrador se revivió a sí mismo.')

    elseif action == 'clothing' then
        toggleMenu(false);
        Wait(100);
        TriggerEvent('qb-clothing:client:openMenu')
        TriggerServerEvent('dpadmin:server:log', 'CLOTHING', 'Abrió el menú de ropa.')

    elseif action == 'reviveall' then
        TriggerServerEvent('dpadmin:server:reviveAll')
        QBCore.Functions.Notify("Enviada orden de REVIVIR A TODOS...", "primary")
        TriggerServerEvent('dpadmin:server:log', 'REVIVE ALL', 'Revivió a todos los jugadores del servidor.')

    elseif action == 'delete_nearby_veh' then
        TriggerServerEvent('dpadmin:server:deleteVehicles', 'nearby')
        TriggerServerEvent('dpadmin:server:log', 'DELETE VEHICLES', 'Borró vehículos cercanos.')

    elseif action == 'delete_all_veh' then
        TriggerServerEvent('dpadmin:server:deleteVehicles', 'all')
        TriggerServerEvent('dpadmin:server:log', 'DELETE VEHICLES', '¡BORRÓ TODOS LOS VEHÍCULOS DEL MAPA!')

    elseif action == 'delete_nearby_peds' then
        TriggerServerEvent('dpadmin:server:deletePeds', 'nearby')
        TriggerServerEvent('dpadmin:server:log', 'DELETE PEDS', 'Borró NPCs cercanos.')

    elseif action == 'delete_all_peds' then
        TriggerServerEvent('dpadmin:server:deletePeds', 'all')
        TriggerServerEvent('dpadmin:server:log', 'DELETE PEDS', '¡BORRÓ TODOS LOS NPCS DEL MAPA!')

    elseif action == 'delete_nearby_objects' then
        TriggerServerEvent('dpadmin:server:deleteObjects', 'nearby')
        TriggerServerEvent('dpadmin:server:log', 'DELETE OBJECTS', 'Borró objetos cercanos.')

    elseif action == 'delete_all_objects' then
        TriggerServerEvent('dpadmin:server:deleteObjects', 'all')
        TriggerServerEvent('dpadmin:server:log', 'DELETE OBJECTS', '¡BORRÓ TODOS LOS OBJETOS DEL MAPA!')

    elseif action == 'tpm' then
        toggleMenu(false)
        Citizen.CreateThread(function()
            local entity = PlayerPedId()
            if IsPedInAnyVehicle(entity, false) then
                entity = GetVehiclePedIsUsing(entity)
            end
            local blip = GetFirstBlipInfoId(8)
            if DoesBlipExist(blip) then
                lastCoords = GetEntityCoords(entity)
                local coords = GetBlipInfoIdCoord(blip)
                local zPos, foundGround = 0.0, false
                DoScreenFadeOut(500);
                Wait(500);
                FreezeEntityPosition(entity, true)
                for i = 0, 1000, 50 do
                    RequestCollisionAtCoord(coords.x, coords.y, i + 0.0)
                    SetEntityCoordsNoOffset(entity, coords.x, coords.y, i + 0.0, false, false, false)
                    Wait(50)
                    local found, z = GetGroundZFor_3dCoord(coords.x, coords.y, i + 0.0, true)
                    if found then
                        zPos = z + 1.0;
                        foundGround = true;
                        break
                    end
                end
                if not foundGround then
                    zPos = 100.0
                end
                SetEntityCoordsNoOffset(entity, coords.x, coords.y, zPos, false, false, false)
                FreezeEntityPosition(entity, false);
                DoScreenFadeIn(500)
                QBCore.Functions.Notify("Teletransportado al marcador", "success")
            else
                QBCore.Functions.Notify("No has marcado nada en el mapa", "error")
            end
        end)
        TriggerServerEvent('dpadmin:server:log', 'TPM', 'Se teletransportó al marcador del mapa.')

    elseif action == 'goto_point' then
        toggleMenu(false)
        local coords = data.coords
        local entity = PlayerPedId()

        -- Si estás en un vehículo, teletransportamos el vehículo
        if IsPedInAnyVehicle(entity, false) then
            entity = GetVehiclePedIsUsing(entity)
        end

        -- 1. Iniciamos el fundido a negro
        DoScreenFadeOut(500)
        while not IsScreenFadedOut() do
            Wait(0)
        end

        -- 2. Guardamos posición actual (para el sistema BACK si lo usas luego)
        lastCoords = GetEntityCoords(PlayerPedId())

        -- 3. Congelamos y movemos
        FreezeEntityPosition(entity, true)
        SetEntityCoordsNoOffset(entity, coords.x, coords.y, coords.z, false, false, false)

        -- 4. Forzamos carga de la zona
        RequestCollisionAtCoord(coords.x, coords.y, coords.z)
        NewLoadSceneStart(coords.x, coords.y, coords.z, coords.x, coords.y, coords.z, 50.0, 0)

        -- 5. Bucle de espera con "Timeout" (Máximo 2.5 segundos)
        local timeout = 0
        while not HasCollisionLoadedAroundEntity(entity) and timeout < 250 do
            Wait(10)
            timeout = timeout + 1
        end

        -- 6. Limpieza y liberación
        NewLoadSceneStop()
        FreezeEntityPosition(entity, false)

        -- 7. Esperamos un poco antes de quitar el negro para que carguen texturas
        Wait(1000)
        DoScreenFadeIn(1000)

        QBCore.Functions.Notify("Teletransportado a destino", "success")
        TriggerServerEvent('dpadmin:server:log', 'GOTO', 'TP Rápido ejecutado.')

        -- Acciones Vehículo
    elseif action == 'repair_vehicle' then
        local veh = GetVehiclePedIsIn(PlayerPedId(), false)
        if veh and veh ~= 0 then
            local fuel = GetVehicleFuelLevel(veh)
            SetVehicleFixed(veh);
            SetVehicleDeformationFixed(veh);
            SetVehicleUndriveable(veh, false)
            SetVehicleEngineOn(veh, true, true);
            SetVehicleDirtLevel(veh, 0.0)
            SetVehicleEngineHealth(veh, 1000.0);
            SetVehicleBodyHealth(veh, 1000.0);
            SetVehiclePetrolTankHealth(veh, 1000.0)
            SetVehicleFuelLevel(veh, fuel)
            if GetResourceState('LegacyFuel') == 'started' then
                exports['LegacyFuel']:SetFuel(veh, fuel)
            end
            QBCore.Functions.Notify("🔧 Vehículo reparado y limpiado.", "success")
        else
            QBCore.Functions.Notify("¡No estás en un vehículo!", "error")
        end
        TriggerServerEvent('dpadmin:server:log', 'REPAIR', 'Reparó el vehículo actual.')

    elseif action == 'refuel_vehicle' then
        local veh = GetVehiclePedIsIn(PlayerPedId(), false)
        if veh and veh ~= 0 then
            local amount = data.value + 0.0
            SetVehicleFuelLevel(veh, amount)
            if GetResourceState('LegacyFuel') == 'started' then
                exports['LegacyFuel']:SetFuel(veh, amount)
            end
            QBCore.Functions.Notify("⛽ Combustible: " .. amount .. "L", "success")
        end
        TriggerServerEvent('dpadmin:server:log', 'REFUEL', 'Llenó el tanque del vehículo.')

    elseif action == 'wash_vehicle' then
        local veh = GetVehiclePedIsIn(PlayerPedId(), false)
        if not veh or veh == 0 then
            veh = QBCore.Functions.GetClosestVehicle()
        end
        if veh and veh ~= 0 then
            SetVehicleDirtLevel(veh, 0.0);
            QBCore.Functions.Notify("🧼 Vehículo lavado.", "success")
        end
        TriggerServerEvent('dpadmin:server:log', 'WASH', 'Lavó un vehículo.')

    elseif action == 'force_unlock' then
        local veh = QBCore.Functions.GetClosestVehicle()
        if veh and veh ~= 0 then
            SetVehicleDoorsLocked(veh, 1);
            SetVehicleDoorsLockedForAllPlayers(veh, false)
            PlayVehicleDoorOpenSound(veh, 0)
            TriggerServerEvent('qb-vehiclekeys:server:AcquireVehicleKeys', QBCore.Functions.GetPlate(veh))
            SetVehicleLights(veh, 2);
            Wait(250);
            SetVehicleLights(veh, 0);
            Wait(200);
            SetVehicleLights(veh, 2);
            Wait(250);
            SetVehicleLights(veh, 0)
            QBCore.Functions.Notify("🔓 Vehículo DESBLOQUEADO", "success")
        end
        TriggerServerEvent('dpadmin:server:log', 'UNLOCK', 'Forzó el desbloqueo de un vehículo.')

    elseif action == 'force_lock' then
        local veh = QBCore.Functions.GetClosestVehicle()
        if veh and veh ~= 0 then
            SetVehicleDoorsLocked(veh, 2);
            SetVehicleDoorsLockedForAllPlayers(veh, true)
            PlayVehicleDoorCloseSound(veh, 1)
            SetVehicleLights(veh, 2);
            Wait(200);
            SetVehicleLights(veh, 0)
            QBCore.Functions.Notify("🔒 Vehículo BLOQUEADO", "success")
        end
        TriggerServerEvent('dpadmin:server:log', 'LOCK', 'Forzó el bloqueo de un vehículo.')

    elseif action == 'random_visuals' then
        local veh = GetVehiclePedIsIn(PlayerPedId(), false)
        if veh and veh ~= 0 then
            SetVehicleModKit(veh, 0)
            local visualIDs = {0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 23, 24, 25, 27, 30, 33, 34, 35, 38}
            for _, modID in ipairs(visualIDs) do
                local numMods = GetNumVehicleMods(veh, modID)
                if numMods > 0 then
                    SetVehicleMod(veh, modID, math.random(-1, numMods - 1), false)
                end
            end
            ToggleVehicleMod(veh, 22, true);
            SetVehicleXenonLightsColor(veh, math.random(0, 12)) -- Xenon
            SetVehicleNeonLightsColour(veh, math.random(0, 255), math.random(0, 255), math.random(0, 255)) -- Neon
            for i = 0, 3 do
                SetVehicleNeonLightEnabled(veh, i, true)
            end
            QBCore.Functions.Notify("Estética aleatoria aplicada.", "success")
        end
        TriggerServerEvent('dpadmin:server:log', 'TUNING', 'Aplicó tuning visual aleatorio.')
    end
    cb('ok')
end)

-- --- D. TOGGLES (INTERRUPTORES) ---
RegisterNUICallback('toggleAction', function(data, cb)
    local action, state = data.action, data.state
    local logDetails = ""
    DebugLog("Toggle: " .. action .. " [" .. tostring(state) .. "]")

    if action == 'noclip' then
        ToggleNoClip(state)

    elseif action == 'godmode' then
        godmodeActive = state
        if state then
            QBCore.Functions.Notify("MODO DIOS: ON", "success");
            TriggerServerEvent('dpadmin:server:setGodmodeState', true);
            RunGodmodeLoop()
        else
            QBCore.Functions.Notify("MODO DIOS: OFF", "error")
        end
        TriggerServerEvent('dpadmin:server:log', 'GODMODE', 'Ha cambiado el modo Dios.')

    elseif action == 'invisible' then
        invisibleActive = state
        if state then
            SetEntityVisible(PlayerPedId(), false, false);
            SetEntityAlpha(PlayerPedId(), 200, false);
            QBCore.Functions.Notify("INVISIBLE: ON", "success");
            RunInvisibleLoop()
        else
            QBCore.Functions.Notify("INVISIBLE: OFF", "error")
        end
        TriggerServerEvent('dpadmin:server:log', 'INVISIBLE', 'Ha cambiado la invisibilidad.')

    elseif action == 'superspeed' then
        speedActive = state
        if state then
            currentSpeedIndex = 4
            SendNUIMessage({
                type = "toggleSpeedUI",
                show = true,
                value = speedMultipliers[currentSpeedIndex]
            })
            QBCore.Functions.Notify("VELOCIDAD: ON", "success")
            RunSpeedLoop()
        else
            SendNUIMessage({
                type = "toggleSpeedUI",
                show = false
            })
            QBCore.Functions.Notify("VELOCIDAD: OFF", "error")
        end
        TriggerServerEvent('dpadmin:server:log', 'SPEED', 'Ha alterado su velocidad de correr.')

    elseif action == 'superjump' then
        jumpActive = state
        if state then
            currentJumpIndex = 2
            SendNUIMessage({
                type = "toggleJumpUI",
                show = true,
                value = jumpMultipliers[currentJumpIndex]
            })
            QBCore.Functions.Notify("SALTO: ON", "success")
            RunJumpLoop()
        else
            SendNUIMessage({
                type = "toggleJumpUI",
                show = false
            })
            QBCore.Functions.Notify("SALTO: OFF", "error")
        end
        TriggerServerEvent('dpadmin:server:log', 'JUMP', 'Ha alterado su salto.')

    elseif action == 'stamina' then
        staminaActive = state
        if state then
            QBCore.Functions.Notify("RESISTENCIA: ON", "success");
            RunStaminaLoop()
        else
            QBCore.Functions.Notify("RESISTENCIA: OFF", "error")
        end
        TriggerServerEvent('dpadmin:server:log', 'STAMINA', 'Ha cambiado resistencia infinita.')

    elseif action == 'blips' then
        blipsActive = state
        if state then
            QBCore.Functions.Notify("BLIPS: ON", "success");
            RunBlipsLoop()
        else
            QBCore.Functions.Notify("BLIPS: OFF", "error")
        end
        TriggerServerEvent('dpadmin:server:log', 'BLIPS', 'Ha cambiado la visualización de Blips (Nombres).')

    elseif action == 'tags' then
        tagsActive = state
        if state then
            QBCore.Functions.Notify("TAGS: ON", "success");
            SendNUIMessage({
                type = "toggleTagsUI",
                show = true
            });
            RunTagsLoop()
        else
            SendNUIMessage({
                type = "toggleTagsUI",
                show = false
            });
            QBCore.Functions.Notify("TAGS: OFF", "error")
        end
        TriggerServerEvent('dpadmin:server:log', 'TAGS', 'Ha cambiado la visualización de GamerTags.')

    elseif action == 'cuffs' then
        cuffsActive = state
        local isHandcuffed = QBCore.Functions.GetPlayerData().metadata["ishandcuffed"]
        if state then
            if not isHandcuffed then
                TriggerEvent('police:client:GetCuffed', GetPlayerServerId(PlayerId()), true);
                QBCore.Functions.Notify("AUTO-ESPOSADO: ON", "success")
            else
                QBCore.Functions.Notify("Ya estabas esposado", "primary")
            end
        else
            if isHandcuffed then
                TriggerEvent('police:client:GetCuffed', GetPlayerServerId(PlayerId()));
                QBCore.Functions.Notify("AUTO-ESPOSADO: OFF", "error");
                ClearPedTasks(PlayerPedId())
            else
                QBCore.Functions.Notify("No estabas esposado", "error")
            end
        end
        TriggerServerEvent('dpadmin:server:log', 'CUFFS', 'Se ha puesto/quitado las esposas.')

    elseif action == 'entity_info' then
        entityInfoActive = state

        SendNUIMessage({
            type = "toggleEntityUI",
            show = state
        })

        if state then
            QBCore.Functions.Notify("DEV TOOL: Activada. Usa 'J' para cursor.", "success")
            RunEntityInfoLoop()
        else
            QBCore.Functions.Notify("DEV TOOL: Desactivada.", "error")

            if not isMenuOpen then
                SetNuiFocus(false, false)
                SetNuiFocusKeepInput(false)
            end
        end

    end
    cb('ok')
end)

RegisterNUICallback('manualSpeedUpdate', function(data, cb)
    if not speedActive then
        return
    end
    if data.dir > 0 then
        if currentSpeedIndex < #speedMultipliers then
            currentSpeedIndex = currentSpeedIndex + 1
        else
            QBCore.Functions.Notify("Velocidad Máxima", "error")
        end
    else
        if currentSpeedIndex > 1 then
            currentSpeedIndex = currentSpeedIndex - 1
        end
    end
    SendNUIMessage({
        type = "updateSpeed",
        value = speedMultipliers[currentSpeedIndex]
    })
    cb('ok')
end)

-- --- E. VEHÍCULOS (TUNING / PINTURA / LIVERY) ---
RegisterNUICallback('applyPerformance', function(data, cb)
    local veh = GetVehiclePedIsIn(PlayerPedId(), false)
    local m = data.mods
    if veh and veh ~= 0 then
        SetVehicleModKit(veh, 0)
        local function Set(id, val)
            if val == "-1" then
                return
            end
            if val == "max" then
                SetVehicleMod(veh, id, GetNumVehicleMods(veh, id) - 1, false)
            else
                SetVehicleMod(veh, id, tonumber(val), false)
            end
        end
        Set(11, m.engine);
        Set(12, m.brakes);
        Set(13, m.transmission);
        Set(15, m.suspension);
        Set(16, m.armor)
        if m.turbo ~= "-1" then
            ToggleVehicleMod(veh, 18, (m.turbo == "on"))
        end
        QBCore.Functions.Notify("🔧 Mejoras instaladas.", "success")
    end
    cb('ok')
end)

RegisterNUICallback('applyPaint', function(data, cb)
    local veh = GetVehiclePedIsIn(PlayerPedId(), false)
    local p = data.paint
    if veh and veh ~= 0 then
        SetVehicleModKit(veh, 0)
        -- Primario
        if p.primary.type == 'normal' then
            ClearVehicleCustomPrimaryColour(veh);
            SetVehicleCustomPrimaryColour(veh, p.primary.rgb[1], p.primary.rgb[2], p.primary.rgb[3])
        else
            ClearVehicleCustomPrimaryColour(veh);
            SetVehicleColours(veh, p.primary.id, select(2, GetVehicleColours(veh)))
        end
        -- Secundario
        if p.secondary.type == 'normal' then
            ClearVehicleCustomSecondaryColour(veh);
            SetVehicleCustomSecondaryColour(veh, p.secondary.rgb[1], p.secondary.rgb[2], p.secondary.rgb[3])
        else
            ClearVehicleCustomSecondaryColour(veh);
            SetVehicleColours(veh, select(1, GetVehicleColours(veh)), p.secondary.id)
        end

        -- Extras
        for i = 0, 3 do
            SetVehicleNeonLightEnabled(veh, i, true)
        end
        SetVehicleNeonLightsColour(veh, p.neon[1], p.neon[2], p.neon[3])
        SetVehicleExtraColours(veh, tonumber(p.pearlescent) or 0,
            GetClosestGtaColor(p.wheels[1], p.wheels[2], p.wheels[3]))
        ToggleVehicleMod(veh, 20, true);
        SetVehicleTyreSmokeColor(veh, p.smoke[1], p.smoke[2], p.smoke[3])
        if tonumber(p.xenon) ~= -1 then
            ToggleVehicleMod(veh, 22, true);
            SetVehicleXenonLightsColor(veh, tonumber(p.xenon))
        end

        QBCore.Functions.Notify("🎨 Pintura aplicada.", "success")
    end
    cb('ok')
end)

RegisterNUICallback('getVehicleLiveries', function(_, cb)
    local veh = GetVehiclePedIsIn(PlayerPedId(), false)
    local list = {}
    if veh and veh ~= 0 then
        SetVehicleModKit(veh, 0)
        local count = GetNumVehicleMods(veh, 48)
        for i = 0, count - 1 do
            local name = GetLabelText(GetModTextLabel(veh, 48, i))
            if name == "NULL" or name == nil then
                name = "Diseño #" .. (i + 1)
            end
            table.insert(list, {
                id = i,
                name = name
            })
        end
    end
    cb(list)
end)

RegisterNUICallback('getCoords', function(data, cb)
    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)
    local heading = GetEntityHeading(ped)

    -- Redondeamos a 2 decimales para que quede limpio
    local x = tonumber(string.format("%.2f", coords.x))
    local y = tonumber(string.format("%.2f", coords.y))
    local z = tonumber(string.format("%.2f", coords.z))
    local h = tonumber(string.format("%.2f", heading))

    local result = ""

    if data.format == 'vector3' then
        result = string.format("vector3(%s, %s, %s)", x, y, z)
    elseif data.format == 'vec3' then
        result = string.format("vec3(%s, %s, %s)", x, y, z)
    elseif data.format == 'vector4' then
        result = string.format("vector4(%s, %s, %s, %s)", x, y, z, h)
    elseif data.format == 'vec4' then
        result = string.format("vec4(%s, %s, %s, %s)", x, y, z, h)
    elseif data.format == 'xyz' then
        result = string.format("%s, %s, %s", x, y, z)
    elseif data.format == 'xyzh' then
        result = string.format("%s, %s, %s, %s", x, y, z, h)
    end

    -- Notificación en juego para confirmar
    QBCore.Functions.Notify("📋 Coordenadas copiadas: " .. result, "success")

    cb({
        coords = result
    })
end)

RegisterNUICallback('setVehicleLivery', function(data, cb)
    local veh = GetVehiclePedIsIn(PlayerPedId(), false)
    if veh and veh ~= 0 then
        SetVehicleMod(veh, 48, data.liveryIndex, false)
        QBCore.Functions.Notify(data.liveryIndex == -1 and "Calcomanía eliminada." or "Calcomanía aplicada.",
            "success")
    end
    cb('ok')
end)

RegisterNUICallback('toggleDuty', function(data, cb)
    TriggerServerEvent('dpadmin:server:toggleDuty', data.targetId)
    cb('ok')
end)

RegisterNUICallback('setJob', function(data, cb)
    TriggerServerEvent('dpadmin:server:setJob', data.targetId, data.job, data.grade)
    cb('ok')
end)

RegisterNUICallback('setJobGrade', function(data, cb)
    TriggerServerEvent('dpadmin:server:setJobGrade', data.targetId, data.grade)
    cb('ok')
end)

RegisterNUICallback('setGang', function(data, cb)
    TriggerServerEvent('dpadmin:server:setGang', data.targetId, data.gang, data.grade)
    cb('ok')
end)

RegisterNUICallback('setGangGrade', function(data, cb)
    TriggerServerEvent('dpadmin:server:setGangGrade', data.targetId, data.grade)
    cb('ok')
end)

-- Puente: JS pide vehículos -> Cliente pide a Server -> Server devuelve a Cliente -> Cliente envía a JS
RegisterNUICallback('requestVehicles', function(data, cb)
    QBCore.Functions.TriggerCallback('dpadmin:getVehicleList', function(vehList)
        SendNUIMessage({
            type = "updateVehicles",
            vehicles = vehList
        })
    end)
    cb('ok')
end)

-- SPAWNEAR VEHÍCULO (ADMIN)
RegisterNUICallback('spawnVehicle', function(data, cb)
    local model = data.model
    -- Usamos el evento de QBCore para spawnear vehículos (admin safe)
    TriggerServerEvent('QBCore:CallCommand', "car", {model})

    cb('ok')
end)

-- DAR VEHÍCULO A OTRO JUGADOR
RegisterNUICallback('giveVehicleToPlayer', function(data, cb)
    TriggerServerEvent('dpadmin:server:giveVehicle', data)
    cb('ok')
end)

-- PETICIÓN DE ÍTEMS (PUENTE)
RegisterNUICallback('requestItems', function(data, cb)
    QBCore.Functions.TriggerCallback('dpadmin:getItemList', function(itemList)
        SendNUIMessage({
            type = "updateItems",
            items = itemList
        })
    end)
    cb('ok')
end)

-- SPAWNEAR ÍTEM (DARSE A UNO MISMO)
RegisterNUICallback('spawnItem', function(data, cb)
    -- Llamamos al evento directo del servidor, mucho más fiable
    TriggerServerEvent('dpadmin:server:spawnItem', data.name)
    cb('ok')
end)

-- DAR ÍTEM A OTRO JUGADOR
RegisterNUICallback('giveItemToPlayer', function(data, cb)
    TriggerServerEvent('dpadmin:server:giveItemToPlayer', data)
    cb('ok')
end)

-- CALLBACK DE ESTADÍSTICAS
RegisterNUICallback('getStatusData', function(data, cb)
    QBCore.Functions.TriggerCallback('dpadmin:server:getStatusData', function(result)
        cb(result)
    end)
end)

-- CALLBACK PARA OPCIONES DE SERVIDOR (STAFF MODE, WHITELIST, ETC)
RegisterNUICallback('toggleServerOption', function(data, cb)
    local option = data.option
    local state = data.state

    -- Enviamos al servidor la orden
    TriggerServerEvent('dpadmin:server:toggleOption', option, state)

    cb('ok')
end)

RegisterNUICallback('toggleCursorMode', function(data, cb)
    isCursorModeActive = not isCursorModeActive

    if isCursorModeActive then
        -- MODO MOVERSE (J Activada)
        -- Focus: TRUE (para que el JS siga detectando la tecla J)
        -- Cursor: FALSE (para que desaparezca el puntero del ratón)
        SetNuiFocus(true, false)

        -- KeepInput: TRUE (Esto es lo que te deja caminar)
        SetNuiFocusKeepInput(true)
    else
        -- MODO MENÚ (Normal)
        SetNuiFocus(true, true)
        SetNuiFocusKeepInput(false)
    end

    cb('ok')
end)

RegisterNUICallback('saveMenuPos', function(data, cb)
    -- data.top y data.left son strings "15.50%"
    TriggerServerEvent('dpadmin:server:saveMenuPos', data)
    cb('ok')
end)

-- Función auxiliar para obtener la dirección de la cámara
local function GetCamDirection()
    local heading = GetGameplayCamRelativeHeading() + GetEntityHeading(PlayerPedId())
    local pitch = GetGameplayCamRelativePitch()

    local x = -math.sin(heading * math.pi / 180.0)
    local y = math.cos(heading * math.pi / 180.0)
    local z = math.sin(pitch * math.pi / 180.0)

    local len = math.sqrt(x * x + y * y + z * z)
    if len ~= 0 then
        x = x / len
        y = y / len
        z = z / len
    end

    return x, y, z
end

-- Variables de configuración del NoClip
local minSpeed = 0.2
local maxSpeed = 5.0
local speedStep = 0.2
local lastWheelChange = 0
local wheelCooldown = 100 -- ms entre cambios

function ToggleNoClip(state)
    noClipActive = state
    local ped = PlayerPedId()

    if noClipActive then
        -- SI YA HAY UN BUCLE CORRIENDO, PARAMOS
        if isNoClipLoopRunning then
            return
        end

        -- ===========================
        --      ACTIVAR NOCLIP
        -- ===========================
        isNoClipLoopRunning = true

        -- 1. ACTIVAMOS EL HUD VISUAL
        SendNUIMessage({
            type = "toggleNoClipUI",
            show = true,
            value = noClipSpeed
        })

        Citizen.CreateThread(function()
            -- Configuración inicial: Fantasma
            SetEntityVisible(ped, false, false)
            SetEntityLocallyVisible(ped)
            SetEntityAlpha(ped, 51, false)
            SetEntityCollision(ped, false, false)
            FreezeEntityPosition(ped, true)

            while noClipActive do
                Wait(0)
                local ped = PlayerPedId()

                -- Refuerzo visual constante
                SetEntityVisible(ped, false, false)
                SetEntityLocallyVisible(ped)

                local coords = GetEntityCoords(ped)
                local dx, dy, dz = GetCamDirection()

                -- CÁLCULO DE VELOCIDAD
                local currentSpeed = noClipSpeed

                -- MODIFICADORES DE TECLAS
                if IsControlPressed(0, 21) then -- SHIFT (Turbo)
                    currentSpeed = currentSpeed * 3
                elseif IsControlPressed(0, 19) then -- ALT IZQUIERDO (Tortuga/Precisión)
                    currentSpeed = currentSpeed * 0.1 -- Se mueve al 10% de la velocidad base
                end

                -- =============================
                --      MOVIMIENTOS (WASD)
                -- =============================

                -- ADELANTE (W)
                if IsControlPressed(0, 32) then
                    coords = vec3(coords.x + dx * currentSpeed, coords.y + dy * currentSpeed,
                        coords.z + dz * currentSpeed)
                end

                -- ATRÁS (S)
                if IsControlPressed(0, 269) or IsControlPressed(0, 33) then
                    coords = vec3(coords.x - dx * currentSpeed, coords.y - dy * currentSpeed,
                        coords.z - dz * currentSpeed)
                end

                -- IZQUIERDA (A) - Calculamos el vector perpendicular
                -- Matemáticamente: (-dy, dx) nos da el vector izquierdo en plano horizontal
                if IsControlPressed(0, 34) then
                    coords = vec3(coords.x - dy * currentSpeed, coords.y + dx * currentSpeed, coords.z)
                end

                -- DERECHA (D)
                -- Matemáticamente: (dy, -dx) nos da el vector derecho en plano horizontal
                if IsControlPressed(0, 35) or IsControlPressed(0, 9) then
                    coords = vec3(coords.x + dy * currentSpeed, coords.y - dx * currentSpeed, coords.z)
                end

                -- ==========================================================================
                --      ALTURA (ESPACIO/E para Subir | CTRL/Q para Bajar)
                -- ==========================================================================

                -- SUBIR: Se activa con Espacio (22) O con la Q (44)
                if IsControlPressed(0, 22) or IsControlPressed(0, 44) then
                    coords = vec3(coords.x, coords.y, coords.z + currentSpeed)
                end

                -- BAJAR: Se activa con CTRL Izquierdo (36) O con la E (38)
                if IsControlPressed(0, 36) or IsControlPressed(0, 38) then
                    coords = vec3(coords.x, coords.y, coords.z - currentSpeed)
                end

                -- APLICAR NUEVA POSICIÓN
                SetEntityCoordsNoOffset(ped, coords.x, coords.y, coords.z, true, true, true)

                -- =============================
                --      AJUSTE DE VELOCIDAD SUAVE
                -- =============================
                local currentTime = GetGameTimer()

                -- Solo procesar cambios si ha pasado el cooldown
                if currentTime - lastWheelChange > wheelCooldown then
                    -- RUEDA ARRIBA (Aumentar velocidad)
                    if IsControlJustPressed(0, 15) then
                        noClipSpeed = noClipSpeed + speedStep
                        if noClipSpeed > maxSpeed then
                            noClipSpeed = maxSpeed
                        end

                        SendNUIMessage({
                            type = "updateNoClipSpeed",
                            value = noClipSpeed
                        })

                        lastWheelChange = currentTime

                        -- RUEDA ABAJO (Disminuir velocidad)
                    elseif IsControlJustPressed(0, 14) then
                        noClipSpeed = noClipSpeed - speedStep
                        if noClipSpeed < minSpeed then
                            noClipSpeed = minSpeed
                        end

                        SendNUIMessage({
                            type = "updateNoClipSpeed",
                            value = noClipSpeed
                        })

                        lastWheelChange = currentTime
                    end
                end
            end

            -- AL SALIR DEL BUCLE
            isNoClipLoopRunning = false

            -- 2. OCULTAMOS EL HUD
            SendNUIMessage({
                type = "toggleNoClipUI",
                show = false
            })

            -- Limpieza de seguridad
            SetEntityVisible(ped, true, false)
            FreezeEntityPosition(ped, false)
            SetEntityCollision(ped, true, true)
            ResetEntityAlpha(ped)
        end)

    else
        -- ===========================
        --      DESACTIVAR (CON ATERRIZAJE)
        -- ===========================

        -- 3. OCULTAMOS EL HUD
        SendNUIMessage({
            type = "toggleNoClipUI",
            show = false
        })

        local coords = GetEntityCoords(ped)
        local rayHandle = StartShapeTestRay(coords.x, coords.y, coords.z, coords.x, coords.y, coords.z - 500.0, 1, ped,
            0)
        local _, hit, endCoords, _, _ = GetShapeTestResult(rayHandle)

        if hit == 1 then
            SetEntityCoordsNoOffset(ped, endCoords.x, endCoords.y, endCoords.z + 1.0, true, true, true)
        end

        -- Restaurar estado normal
        SetEntityVisible(ped, true, false)
        FreezeEntityPosition(ped, false)
        SetEntityCollision(ped, true, true)
        SetEntityVelocity(ped, 0.0, 0.0, 0.0)
        ResetEntityAlpha(ped)
    end
end

-- =======================================================
--      NUEVO SISTEMA: EVENTOS DEL MAPA TÁCTICO
-- =======================================================

-- 1. Comando/Evento para abrir el mapa
-- (Llama a esto desde donde quieras abrir el menú)
RegisterNetEvent('dpadmin:client:openMap', function()
    SetNuiFocus(true, true)
    SendNUIMessage({
        action = "openMap",
        locations = Config.GotoLocations -- Enviamos la tabla del Config
    })
end)

-- 2. Callback cuando haces click en "IR AL LUGAR"
RegisterNUICallback('tpToLocation', function(data, cb)
    local ped = PlayerPedId()
    local x = tonumber(data.x)
    local y = tonumber(data.y)
    local z = tonumber(data.z)

    if x and y then
        -- Si estás en un vehículo, lo movemos contigo
        if IsPedInAnyVehicle(ped, false) then
            ped = GetVehiclePedIsUsing(ped)
        end

        -- 1. Pantalla en negro para transición suave
        DoScreenFadeOut(500)
        while not IsScreenFadedOut() do
            Wait(0)
        end

        -- 2. Congelar para evitar caídas
        FreezeEntityPosition(ped, true)

        -- 3. Si la Z es 0 o nil (porque el mapa es 2D), buscamos suelo
        if z == 0.0 or z == nil then
            -- Intentamos una altura segura por defecto
            z = 100.0
            -- Pre-cargamos la zona en altura
            RequestCollisionAtCoord(x, y, z)
            NewLoadSceneStart(x, y, z, x, y, z, 50.0, 0)

            -- Buscamos el suelo real
            local foundGround = false
            local zTry = 0.0
            for i = 0, 100 do -- Buscamos hasta 1000 metros de altura
                zTry = zTry + 10.0
                RequestCollisionAtCoord(x, y, zTry)
                if i % 5 == 0 then
                    Wait(10)
                end -- Pequeña espera cada 5 intentos

                local ground, zPos = GetGroundZFor_3dCoord(x, y, zTry, false)
                if ground then
                    z = zPos + 1.0
                    foundGround = true
                    break
                end
            end
        else
            -- Si ya tenemos Z (del config), cargamos esa zona
            RequestCollisionAtCoord(x, y, z)
            NewLoadSceneStart(x, y, z, x, y, z, 50.0, 0)
        end

        -- 4. Mover entidad
        SetEntityCoordsNoOffset(ped, x, y, z, false, false, false)

        -- 5. Esperar a que las texturas carguen
        local timeout = 0
        while not HasCollisionLoadedAroundEntity(ped) and timeout < 200 do
            Wait(10)
            timeout = timeout + 1
        end

        -- 6. Limpieza
        NewLoadSceneStop()
        FreezeEntityPosition(ped, false)

        Wait(500) -- Pequeña pausa dramática
        DoScreenFadeIn(1000)

        QBCore.Functions.Notify("Despliegue táctico completado", "success")
    end
    cb('ok')
end)

-- 3. Cerrar Menú (Solo si no tienes ya un callback 'closeMenu' repetido arriba)
RegisterNUICallback('closeMenu', function(_, cb)
    SetNuiFocus(false, false)
    cb('ok')
end)

-- ==========================================================================
--      8. REGISTER KEY MAPPINGS (STAFF HOTKEYS)
-- ==========================================================================

-- Función genérica para registrar atajos sin tecla asignada
local function RegisterStaffKey(command, description, action)
    RegisterCommand(command, function()
        -- Solo permitir si es staff (podrías añadir aquí un check de QBCore si quieres)
        action()
    end, false)
    -- El último parámetro "" asegura que NO tenga tecla por defecto
    RegisterKeyMapping(command, 'Staff: ' .. description, 'keyboard', '')
end

-- 1. NOCLIP
RegisterStaffKey('admin_noclip', 'Alternar NoClip', function()
    ToggleNoClip(not noClipActive)
end)

-- 2. REVIVE
RegisterStaffKey('admin_revive', 'Revivirse a sí mismo', function()
    TriggerEvent('hospital:client:Revive')
    TriggerServerEvent('dpadmin:server:log', 'HOTKEY', 'Se revivió usando atajo de teclado.')
end)

-- 3. GODMODE
RegisterStaffKey('admin_godmode', 'Alternar Modo Dios', function()
    godmodeActive = not godmodeActive
    if godmodeActive then
        RunGodmodeLoop()
    end
    QBCore.Functions.Notify("MODO DIOS: " .. (godmodeActive and "ON" or "OFF"), godmodeActive and "success" or "error")
end)

-- 4. INVISIBLE
RegisterStaffKey('admin_invisible', 'Alternar Invisibilidad', function()
    invisibleActive = not invisibleActive
    if invisibleActive then
        RunInvisibleLoop()
    end
    QBCore.Functions.Notify("INVISIBLE: " .. (invisibleActive and "ON" or "OFF"),
        invisibleActive and "success" or "error")
end)

-- 5. BLIPS
RegisterStaffKey('admin_blips', 'Alternar Blips de Jugadores', function()
    blipsActive = not blipsActive
    if blipsActive then
        RunBlipsLoop()
    end
    QBCore.Functions.Notify("BLIPS: " .. (blipsActive and "ON" or "OFF"), blipsActive and "success" or "error")
end)

-- 6. TAGS / NOMBRES
RegisterStaffKey('admin_tags', 'Alternar Tags de Jugadores', function()
    tagsActive = not tagsActive
    SendNUIMessage({
        type = "toggleTagsUI",
        show = tagsActive
    })
    if tagsActive then
        RunTagsLoop()
    end
    QBCore.Functions.Notify("TAGS: " .. (tagsActive and "ON" or "OFF"), tagsActive and "success" or "error")
end)

-- 7. TPM (Teleport al Marcador)
RegisterStaffKey('admin_tpm', 'TP al marcador del mapa', function()
    -- Reutilizamos la lógica de triggerAction tpm
    ExecuteCommand('tpm') -- Si tienes el comando tpm de QB, si no, se puede copiar la lógica aquí
end)

-- 9. Abrir Menú de Administración
RegisterStaffKey('admin_weather', 'Abrir panel administrativo', function()
    toggleMenu(true)
end)

-- 10. REPARAR VEHÍCULO
RegisterStaffKey('admin_repair', 'Reparar vehículo actual', function()
    local veh = GetVehiclePedIsIn(PlayerPedId(), false)
    if veh ~= 0 then
        SetVehicleFixed(veh)
        SetVehicleDirtLevel(veh, 0.0)
        QBCore.Functions.Notify("Vehículo reparado", "success")
    end
end)

-- 11. FORZAR DESBLOQUEO
RegisterStaffKey('admin_unlock', 'Forzar desbloqueo de puertas', function()
    local veh = QBCore.Functions.GetClosestVehicle()
    if veh ~= 0 then
        SetVehicleDoorsLocked(veh, 1)
        QBCore.Functions.Notify("Puertas desbloqueadas", "success")
    end
end)

-- 12. FORZAR BLOQUEO
RegisterStaffKey('admin_lock', 'Forzar bloqueo de puertas', function()
    local veh = QBCore.Functions.GetClosestVehicle()
    if veh ~= 0 then
        SetVehicleDoorsLocked(veh, 2)
        QBCore.Functions.Notify("Puertas bloqueadas", "error")
    end
end)

-- 13. LAVAR VEHÍCULO
RegisterStaffKey('admin_wash', 'Lavar vehículo', function()
    local veh = GetVehiclePedIsIn(PlayerPedId(), false)
    if veh ~= 0 then
        SetVehicleDirtLevel(veh, 0.0)
        QBCore.Functions.Notify("Vehículo limpio", "success")
    end
end)

-- 14. HERRAMIENTAS DE DESARROLLO (Entity Info)
RegisterStaffKey('admin_devtool', 'Alternar Información de Entidades', function()
    entityInfoActive = not entityInfoActive
    SendNUIMessage({
        type = "toggleEntityUI",
        show = entityInfoActive
    })
    if entityInfoActive then
        RunEntityInfoLoop()
    end
end)
