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

-- Variables de Estado
local noClipActive = false
local isNoClipLoopRunning = false
local noClipEntity = nil -- La entidad que realmente moveremos

-- Variables de Velocidad
local noClipSpeed = 1.0
local minSpeed = 0.2
local maxSpeed = 15.0 -- Aumentado para poder ir rápido en aviones/coches
local speedStep = 0.5
local lastWheelChange = 0
local wheelCooldown = 50

-- Entity Info
local isCursorModeActive = false

-- Trolls
local lastKidnapLoc = 0

-- ==========================================================================
--      3. FUNCIONES DE UTILIDAD (HELPERS)
-- ==========================================================================

local function DebugLog(msg)
    if Config.Debug then
        print("^5[DP-AdminMenu CLIENT]^7 " .. msg)
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
        TriggerServerEvent('DP-AdminMenu:server:setGodmodeState', false)

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
                TriggerServerEvent('DP-AdminMenu:server:getTagsData', nearbyPlayers)
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

            -- USAR BONE DEL PECHO (SPINE3)
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
        -- 1. PEDIMOS LA POSICIÓN PRIMERO
        QBCore.Functions.TriggerCallback('DP-AdminMenu:server:getMenuPos', function(pos)

            -- 2. CARGA DE DATOS ORIGINAL (CASCADA)
            QBCore.Functions.TriggerCallback('DP-AdminMenu:getPlayers', function(players)
                QBCore.Functions.TriggerCallback('DP-AdminMenu:getReports', function(reports)
                    QBCore.Functions.TriggerCallback('DP-AdminMenu:getBans', function(bans)
                        QBCore.Functions.TriggerCallback('DP-AdminMenu:getChatMessages', function(chat)
                            QBCore.Functions.TriggerCallback('DP-AdminMenu:getJobs', function(jobsList)
                                QBCore.Functions.TriggerCallback('DP-AdminMenu:getGangs', function(gangsList)

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
                                        adminName = GetPlayerName(PlayerId()),
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
    TriggerServerEvent('DP-AdminMenu:server:setGodmodeState', false)
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
    local veh = GetVehiclePedIsIn(ped, false)
    local entity = (veh ~= 0) and veh or ped

    SetEntityVisible(entity, true, false)
    FreezeEntityPosition(entity, false)
    SetEntityCollision(entity, true, true)
    SetEntityVelocity(entity, 0.0, 0.0, 0.0)
    ResetEntityAlpha(entity)

    -- 3. Limpieza de Foco (Por si te pilló con el menú abierto)
    SetNuiFocus(false, false)
    SetNuiFocusKeepInput(false)
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
    TriggerServerEvent('DP-AdminMenu:server:submitReport', data)
    cb('ok')
end)

RegisterNUICallback('assignReport', function(data, cb)
    TriggerServerEvent('DP-AdminMenu:server:assignReport', data)
    SetTimeout(500, function()
        QBCore.Functions.TriggerCallback('DP-AdminMenu:getReports', function(r)
            SendNUIMessage({
                type = "updateReports",
                reports = r
            })
        end)
    end)
    cb('ok')
end)

RegisterNUICallback('deleteReport', function(data, cb)
    TriggerServerEvent('DP-AdminMenu:server:closeReport', data)
    SetTimeout(500, function()
        QBCore.Functions.TriggerCallback('DP-AdminMenu:getReports', function(r)
            SendNUIMessage({
                type = "updateReports",
                reports = r
            })
        end)
    end)
    cb('ok')
end)

RegisterNUICallback('revokeBan', function(data, cb)
    TriggerServerEvent('DP-AdminMenu:server:revokeBan', data)
    SetTimeout(500, function()
        QBCore.Functions.TriggerCallback('DP-AdminMenu:getBans', function(b)
            SendNUIMessage({
                type = "open",
                bans = b
            })
        end)
    end)
    cb('ok')
end)

RegisterNUICallback('extendBan', function(data, cb)
    TriggerServerEvent('DP-AdminMenu:server:extendBan', data)
    SetTimeout(500, function()
        QBCore.Functions.TriggerCallback('DP-AdminMenu:getBans', function(b)
            SendNUIMessage({
                type = "open",
                bans = b
            })
        end)
    end)
    cb('ok')
end)

RegisterNUICallback('getMoreChatMessages', function(data, cb)
    QBCore.Functions.TriggerCallback('DP-AdminMenu:getChatMessages', function(c)
        cb(c)
    end, data.oldestId)
end)

-- ENVIAR MENSAJE (Soporte para texto + imágenes)
RegisterNUICallback('sendAdminMessage', function(data, cb)
    -- data ahora contiene { message = "...", images = ["url1", "url2"] }
    TriggerServerEvent('DP-AdminMenu:server:sendChatMessage', data)
    cb('ok')
end)

RegisterNetEvent('DP-AdminMenu:client:receiveChatMessage', function(msg)
    if isMenuOpen then
        SendNUIMessage({
            type = "newChatMessage",
            message = msg
        })
    end
end)

RegisterNetEvent('DP-AdminMenu:client:receiveTagsData', function(data)
    for _, info in ipairs(data) do
        tagsDataCache[info.id] = info
    end
end)

RegisterNUICallback('sendAnnouncement', function(data, cb)
    toggleMenu(false);
    TriggerServerEvent('DP-AdminMenu:server:sendAnnouncement', data);
    cb('ok')
end)

RegisterNetEvent('DP-AdminMenu:client:showAnnouncement', function(msg, dur)
    SendNUIMessage({
        type = "showAnnouncement",
        message = msg,
        duration = dur
    })
end)

-- Este evento actualiza HOME y JOBS sin cerrar el menú
RegisterNetEvent('DP-AdminMenu:client:refreshAllData', function()
    if isMenuOpen then
        -- 1. HOME
        QBCore.Functions.TriggerCallback('DP-AdminMenu:getPlayers', function(players)
            -- 2. JOBS
            QBCore.Functions.TriggerCallback('DP-AdminMenu:getJobs', function(jobsList)
                -- 3. GANGS
                QBCore.Functions.TriggerCallback('DP-AdminMenu:getGangs', function(gangsList)
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
    ForceResetAll()
    Citizen.Wait(2000)
    TriggerServerEvent('DP-AdminMenu:server:playerFullyLoaded')
end)

-- EVENTO PARA FORZAR ACTUALIZACIÓN DEL UI (SYNC GLOBAL)
RegisterNetEvent('DP-AdminMenu:client:forceStatusUpdate', function()
    -- Enviamos mensaje al NUI para que recargue la página de Status si está abierta
    SendNUIMessage({
        type = "forceStatusRefresh"
    })
end)

RegisterNUICallback('updateWeather', function(data, cb)
    TriggerServerEvent('DP-AdminMenu:server:updateWeather', data.weather, data.hour, data.extras);
    cb('ok')
end)

-- --- C. ACCIONES (TRIGGER) ---
RegisterNUICallback('triggerAction', function(data, cb)
    local action = data.action
    DebugLog("Action Trigger: " .. action)

    if action == 'open_map_menu' then
        toggleMenu(false) -- Cierra el menú de admin actual
        TriggerEvent('DP-AdminMenu:client:openMap') -- Lanza el evento del mapa
        return cb('ok') -- Termina aquí para no seguir leyendo
    end

    if action == 'noclip' then
        -- ExecuteCommand('noclip') -- Comando externo (normalmente qb-admin)
        TriggerServerEvent('DP-AdminMenu:server:log', 'NOCLIP', 'Alternó el estado de NoClip.')

    elseif action == 'revive' then
        TriggerEvent('hospital:client:Revive')
        TriggerEvent('QBCore:Client:SetStatus', 'is_dead', false)
        TriggerEvent('QBCore:Client:SetStatus', 'in_laststand', false)
        TriggerServerEvent('DP-AdminMenu:server:log', 'REVIVE', 'El administrador se revivió a sí mismo.')

    elseif action == 'clothing' then
        toggleMenu(false);
        Wait(100);
        TriggerEvent('qb-clothing:client:openMenu')
        TriggerServerEvent('DP-AdminMenu:server:log', 'CLOTHING', 'Abrió el menú de ropa.')

    elseif action == 'reviveall' then
        TriggerServerEvent('DP-AdminMenu:server:reviveAll')
        QBCore.Functions.Notify("Enviada orden de REVIVIR A TODOS...", "primary")
        TriggerServerEvent('DP-AdminMenu:server:log', 'REVIVE ALL', 'Revivió a todos los jugadores del servidor.')

    elseif action == 'delete_nearby_veh' then
        TriggerServerEvent('DP-AdminMenu:server:deleteVehicles', 'nearby')
        TriggerServerEvent('DP-AdminMenu:server:log', 'DELETE VEHICLES', 'Borró vehículos cercanos.')

    elseif action == 'delete_all_veh' then
        TriggerServerEvent('DP-AdminMenu:server:deleteVehicles', 'all')
        TriggerServerEvent('DP-AdminMenu:server:log', 'DELETE VEHICLES', '¡BORRÓ TODOS LOS VEHÍCULOS DEL MAPA!')

    elseif action == 'delete_nearby_peds' then
        TriggerServerEvent('DP-AdminMenu:server:deletePeds', 'nearby')
        TriggerServerEvent('DP-AdminMenu:server:log', 'DELETE PEDS', 'Borró NPCs cercanos.')

    elseif action == 'delete_all_peds' then
        TriggerServerEvent('DP-AdminMenu:server:deletePeds', 'all')
        TriggerServerEvent('DP-AdminMenu:server:log', 'DELETE PEDS', '¡BORRÓ TODOS LOS NPCS DEL MAPA!')

    elseif action == 'delete_nearby_objects' then
        TriggerServerEvent('DP-AdminMenu:server:deleteObjects', 'nearby')
        TriggerServerEvent('DP-AdminMenu:server:log', 'DELETE OBJECTS', 'Borró objetos cercanos.')

    elseif action == 'delete_all_objects' then
        TriggerServerEvent('DP-AdminMenu:server:deleteObjects', 'all')
        TriggerServerEvent('DP-AdminMenu:server:log', 'DELETE OBJECTS', '¡BORRÓ TODOS LOS OBJETOS DEL MAPA!')

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
        TriggerServerEvent('DP-AdminMenu:server:log', 'TPM', 'Se teletransportó al marcador del mapa.')

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
        TriggerServerEvent('DP-AdminMenu:server:log', 'GOTO', 'TP Rápido ejecutado.')

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
        TriggerServerEvent('DP-AdminMenu:server:log', 'REPAIR', 'Reparó el vehículo actual.')

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
        TriggerServerEvent('DP-AdminMenu:server:log', 'REFUEL', 'Llenó el tanque del vehículo.')

    elseif action == 'wash_vehicle' then
        local veh = GetVehiclePedIsIn(PlayerPedId(), false)
        if not veh or veh == 0 then
            veh = QBCore.Functions.GetClosestVehicle()
        end
        if veh and veh ~= 0 then
            SetVehicleDirtLevel(veh, 0.0);
            QBCore.Functions.Notify("🧼 Vehículo lavado.", "success")
        end
        TriggerServerEvent('DP-AdminMenu:server:log', 'WASH', 'Lavó un vehículo.')

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
        TriggerServerEvent('DP-AdminMenu:server:log', 'UNLOCK', 'Forzó el desbloqueo de un vehículo.')

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
        TriggerServerEvent('DP-AdminMenu:server:log', 'LOCK', 'Forzó el bloqueo de un vehículo.')

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
        TriggerServerEvent('DP-AdminMenu:server:log', 'TUNING', 'Aplicó tuning visual aleatorio.')
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
            TriggerServerEvent('DP-AdminMenu:server:setGodmodeState', true);
            RunGodmodeLoop()
        else
            QBCore.Functions.Notify("MODO DIOS: OFF", "error")
        end
        TriggerServerEvent('DP-AdminMenu:server:log', 'GODMODE', 'Ha cambiado el modo Dios.')

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
        TriggerServerEvent('DP-AdminMenu:server:log', 'INVISIBLE', 'Ha cambiado la invisibilidad.')

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
        TriggerServerEvent('DP-AdminMenu:server:log', 'SPEED', 'Ha alterado su velocidad de correr.')

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
        TriggerServerEvent('DP-AdminMenu:server:log', 'JUMP', 'Ha alterado su salto.')

    elseif action == 'stamina' then
        staminaActive = state
        if state then
            QBCore.Functions.Notify("RESISTENCIA: ON", "success");
            RunStaminaLoop()
        else
            QBCore.Functions.Notify("RESISTENCIA: OFF", "error")
        end
        TriggerServerEvent('DP-AdminMenu:server:log', 'STAMINA', 'Ha cambiado resistencia infinita.')

    elseif action == 'blips' then
        blipsActive = state
        if state then
            QBCore.Functions.Notify("BLIPS: ON", "success");
            RunBlipsLoop()
        else
            QBCore.Functions.Notify("BLIPS: OFF", "error")
        end
        TriggerServerEvent('DP-AdminMenu:server:log', 'BLIPS', 'Ha cambiado la visualización de Blips (Nombres).')

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
        TriggerServerEvent('DP-AdminMenu:server:log', 'TAGS', 'Ha cambiado la visualización de GamerTags.')

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
        TriggerServerEvent('DP-AdminMenu:server:log', 'CUFFS', 'Se ha puesto/quitado las esposas.')

    elseif action == 'entity_info' then
        entityInfoActive = state

        SendNUIMessage({
            type = "toggleEntityUI",
            show = state
        })

        if state then
            RunEntityInfoLoop()
        else
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
    TriggerServerEvent('DP-AdminMenu:server:toggleDuty', data.targetId)
    cb('ok')
end)

RegisterNUICallback('setJob', function(data, cb)
    TriggerServerEvent('DP-AdminMenu:server:setJob', data.targetId, data.job, data.grade)
    cb('ok')
end)

RegisterNUICallback('setJobGrade', function(data, cb)
    TriggerServerEvent('DP-AdminMenu:server:setJobGrade', data.targetId, data.grade)
    cb('ok')
end)

RegisterNUICallback('setGang', function(data, cb)
    if data.targetId and data.gang then
        TriggerServerEvent('DP-AdminMenu:server:setGang', data.targetId, data.gang, data.grade)
    end
    cb('ok')
end)

RegisterNUICallback('setGangGrade', function(data, cb)
    TriggerServerEvent('DP-AdminMenu:server:setGangGrade', data.targetId, data.grade)
    cb('ok')
end)

-- Puente: JS pide vehículos -> Cliente pide a Server -> Server devuelve a Cliente -> Cliente envía a JS
RegisterNUICallback('requestVehicles', function(data, cb)
    QBCore.Functions.TriggerCallback('DP-AdminMenu:getVehicleList', function(vehList)
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
    TriggerServerEvent('DP-AdminMenu:server:giveVehicle', data)
    cb('ok')
end)

-- PETICIÓN DE ÍTEMS (PUENTE)
RegisterNUICallback('requestItems', function(data, cb)
    QBCore.Functions.TriggerCallback('DP-AdminMenu:getItemList', function(itemList)
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
    TriggerServerEvent('DP-AdminMenu:server:spawnItem', data.name)
    cb('ok')
end)

-- DAR ÍTEM A OTRO JUGADOR
RegisterNUICallback('giveItemToPlayer', function(data, cb)
    TriggerServerEvent('DP-AdminMenu:server:giveItemToPlayer', data)
    cb('ok')
end)

-- CALLBACK DE ESTADÍSTICAS
RegisterNUICallback('getStatusData', function(data, cb)
    QBCore.Functions.TriggerCallback('DP-AdminMenu:server:getStatusData', function(result)
        cb(result)
    end)
end)

-- CALLBACK PARA OPCIONES DE SERVIDOR (STAFF MODE, WHITELIST, ETC)
RegisterNUICallback('toggleServerOption', function(data, cb)
    local option = data.option
    local state = data.state

    -- Enviamos al servidor la orden
    TriggerServerEvent('DP-AdminMenu:server:toggleOption', option, state)

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
    TriggerServerEvent('DP-AdminMenu:server:saveMenuPos', data)
    cb('ok')
end)

-- Funciones matemáticas auxiliares para la cámara
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

    -- Detectar entidad inicial
    local veh = GetVehiclePedIsIn(ped, false)
    local inVehicle = (veh ~= 0)
    noClipEntity = inVehicle and veh or ped

    -- ===========================
    --      ACTIVAR NOCLIP
    -- ===========================
    if noClipActive then
        if isNoClipLoopRunning then
            return
        end -- Evitar doble ejecución
        isNoClipLoopRunning = true

        -- Configuración inicial "Fantasma"
        FreezeEntityPosition(noClipEntity, true)
        SetEntityCollision(noClipEntity, false, false)
        SetEntityVisible(noClipEntity, false, false)
        SetEntityAlpha(noClipEntity, 51, false)

        -- Si estamos a pie, limpiamos tareas para que no se quede corriendo
        if not inVehicle then
            ClearPedTasksImmediately(ped)
        end

        -- HUD ON
        SendNUIMessage({
            type = "toggleNoClipUI",
            show = true,
            value = noClipSpeed
        })

        Citizen.CreateThread(function()
            while noClipActive do
                Wait(0)

                -- Actualizar entidad dinámicamente (por si entras/sales de un coche siendo admin)
                ped = PlayerPedId()
                veh = GetVehiclePedIsIn(ped, false)
                inVehicle = (veh ~= 0)
                local currentTarget = inVehicle and veh or ped

                -- Si cambiamos de entidad (subimos/bajamos de coche), actualizamos propiedades
                if noClipEntity ~= currentTarget then
                    -- Restauramos la entidad vieja
                    SetEntityVisible(noClipEntity, true, false)
                    SetEntityCollision(noClipEntity, true, true)
                    ResetEntityAlpha(noClipEntity)
                    FreezeEntityPosition(noClipEntity, false)

                    -- Configuramos la nueva
                    noClipEntity = currentTarget
                    FreezeEntityPosition(noClipEntity, true)
                    SetEntityCollision(noClipEntity, false, false)
                    SetEntityVisible(noClipEntity, false, false)
                    SetEntityAlpha(noClipEntity, 51, false)
                end

                -- REFUERZO VISUAL Y DE COLISIÓN CONSTANTE
                SetEntityVisible(noClipEntity, false, false)
                SetEntityLocallyVisible(noClipEntity)

                -- =========================================================
                --      BLOQUEO DE CONTROLES (PARA QUE NO CORRA/DISPARE)
                -- =========================================================
                DisableControlAction(0, 30, true) -- Move LR
                DisableControlAction(0, 31, true) -- Move UD
                DisableControlAction(0, 32, true) -- Move Up (W)
                DisableControlAction(0, 33, true) -- Move Down (S)
                DisableControlAction(0, 34, true) -- Move Left (A)
                DisableControlAction(0, 35, true) -- Move Right (D)
                DisableControlAction(0, 44, true) -- Cover (Q)
                DisableControlAction(0, 37, true) -- Weapon Wheel (Tab)
                DisableControlAction(0, 266, true) -- Move
                DisableControlAction(0, 267, true) -- Move
                DisableControlAction(0, 268, true) -- Move
                DisableControlAction(0, 269, true) -- Move

                -- >>> AÑADE ESTO AQUÍ PARA LA RADIO <<<
                DisableControlAction(0, 85, true) -- RADIO WHEEL (La Q)
                DisableControlAction(0, 81, true) -- NEXT RADIO STATION
                DisableControlAction(0, 82, true) -- PREV RADIO STATION
                DisableControlAction(0, 83, true) -- NEXT RADIO TRACK
                DisableControlAction(0, 84, true) -- PREV RADIO TRACK

                -- SI ESTAMOS EN VEHÍCULO, FORZAR SILENCIO
                if inVehicle then
                    SetVehRadioStation(noClipEntity, "OFF")
                end

                -- =========================================================
                --      ROTACIÓN: LA ENTIDAD MIRA A LA CÁMARA
                -- =========================================================
                local camRot = GetGameplayCamRot(0)
                SetEntityHeading(noClipEntity, camRot.z)

                -- =========================================================
                --      CÁLCULOS MATEMÁTICOS DE MOVIMIENTO
                -- =========================================================
                local coords = GetEntityCoords(noClipEntity)

                -- Obtener vectores de dirección
                local fwdX, fwdY, fwdZ = GetCamDirection()

                -- Calcular vector derecho (Cross Product aproximado) para A y D
                local vecRightX = fwdY
                local vecRightY = -fwdX

                -- Velocidad actual con modificadores
                local currentSpeed = noClipSpeed
                if IsDisabledControlPressed(0, 21) then -- SHIFT (Turbo)
                    currentSpeed = currentSpeed * 4.0
                elseif IsDisabledControlPressed(0, 19) then -- ALT (Lento)
                    currentSpeed = currentSpeed * 0.1
                end

                -- =========================================================
                --      INPUTS DE MOVIMIENTO
                -- =========================================================
                local newPos = coords

                -- W (Adelante)
                if IsDisabledControlPressed(0, 32) then
                    newPos = vec3(newPos.x + fwdX * currentSpeed, newPos.y + fwdY * currentSpeed,
                        newPos.z + fwdZ * currentSpeed)
                end
                -- S (Atrás)
                if IsDisabledControlPressed(0, 33) or IsDisabledControlPressed(0, 269) then
                    newPos = vec3(newPos.x - fwdX * currentSpeed, newPos.y - fwdY * currentSpeed,
                        newPos.z - fwdZ * currentSpeed)
                end
                -- A (Izquierda)
                if IsDisabledControlPressed(0, 34) then
                    newPos = vec3(newPos.x - vecRightX * currentSpeed, newPos.y - vecRightY * currentSpeed, newPos.z)
                end
                -- D (Derecha)
                if IsDisabledControlPressed(0, 35) then
                    newPos = vec3(newPos.x + vecRightX * currentSpeed, newPos.y + vecRightY * currentSpeed, newPos.z)
                end
                -- Q / Espacio (Subir vertical)
                if IsDisabledControlPressed(0, 22) or IsDisabledControlPressed(0, 44) then
                    newPos = vec3(newPos.x, newPos.y, newPos.z + (currentSpeed * 0.5))
                end
                -- E / Control (Bajar vertical)
                if IsDisabledControlPressed(0, 36) or IsDisabledControlPressed(0, 38) then
                    newPos = vec3(newPos.x, newPos.y, newPos.z - (currentSpeed * 0.5))
                end

                -- APLICAR NUEVA POSICIÓN
                SetEntityCoordsNoOffset(noClipEntity, newPos.x, newPos.y, newPos.z, true, true, true)

                -- =========================================================
                --      CONTROL RUEDA RATÓN (VELOCIDAD)
                -- =========================================================
                local time = GetGameTimer()
                if time - lastWheelChange > wheelCooldown then
                    if IsControlJustPressed(0, 15) then -- Rueda Arriba
                        noClipSpeed = math.min(noClipSpeed + speedStep, maxSpeed)
                        SendNUIMessage({
                            type = "updateNoClipSpeed",
                            value = noClipSpeed
                        })
                        lastWheelChange = time
                    elseif IsControlJustPressed(0, 14) then -- Rueda Abajo
                        noClipSpeed = math.max(noClipSpeed - speedStep, minSpeed)
                        SendNUIMessage({
                            type = "updateNoClipSpeed",
                            value = noClipSpeed
                        })
                        lastWheelChange = time
                    end
                end
            end

            -- ===========================
            --      SALIR DEL BUCLE
            -- ===========================
            isNoClipLoopRunning = false
            SendNUIMessage({
                type = "toggleNoClipUI",
                show = false
            })

            -- Restaurar entidad
            FreezeEntityPosition(noClipEntity, false)
            SetEntityCollision(noClipEntity, true, true)
            SetEntityVisible(noClipEntity, true, false)
            ResetEntityAlpha(noClipEntity)

            -- Si es un coche, ponerlo bien en el suelo para que no rebote
            if IsEntityAVehicle(noClipEntity) then
                SetVehicleOnGroundProperly(noClipEntity)
            end
        end)

    else
        -- ===========================
        --      DESACTIVAR (OFF)
        -- ===========================
        SendNUIMessage({
            type = "toggleNoClipUI",
            show = false
        })

        if DoesEntityExist(noClipEntity) then
            FreezeEntityPosition(noClipEntity, false)
            SetEntityCollision(noClipEntity, true, true)
            SetEntityVisible(noClipEntity, true, false)
            SetEntityVelocity(noClipEntity, 0.0, 0.0, 0.0)
            ResetEntityAlpha(noClipEntity)

            -- Intentar aterrizaje suave si estamos cerca del suelo
            local coords = GetEntityCoords(noClipEntity)
            local found, groundZ = GetGroundZFor_3dCoord(coords.x, coords.y, coords.z, false)
            if found and (coords.z - groundZ) < 10.0 then
                SetEntityCoordsNoOffset(noClipEntity, coords.x, coords.y, groundZ, true, true, true)
            end

            if IsEntityAVehicle(noClipEntity) then
                SetVehicleOnGroundProperly(noClipEntity)
            end
        end
    end
end

-- =======================================================
--              EVENTOS DEL MAPA TÁCTICO
-- =======================================================

-- 1. Comando/Evento para abrir el mapa
-- (Llama a esto desde donde quieras abrir el menú)
RegisterNetEvent('DP-AdminMenu:client:openMap', function()
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

-- Callback para el Mapa Táctico desde Detalles del Jugador
RegisterNUICallback('teleportTargetToCoords', function(data, cb)
    if data.targetId and data.coords then
        -- Enviamos la ID del objetivo y las coordenadas al servidor
        TriggerServerEvent('DP-AdminMenu:server:teleportTargetTactical', data.targetId, data.coords)
    end
    cb('ok')
end)

-- 3. Cerrar Menú (Solo si no tienes ya un callback 'closeMenu' repetido arriba)
RegisterNUICallback('closeMenu', function(_, cb)
    SetNuiFocus(false, false)
    cb('ok')
end)

-- ==========================================================================
--      9. EVENTOS PARA EL MODAL DE DETALLES (PLAYER DETAILS)
-- ==========================================================================

local isSpectating = false
local lastSpectateCoords = nil

-- 1. NUI CALLBACK: Acciones del Panel (Matar, Congelar, Espectear...)
RegisterNUICallback('playerAction', function(data, cb)
    -- Enviamos: 1. La acción, 2. La ID, 3. TODO el objeto data (donde va el 'amount' si existe)
    TriggerServerEvent('DP-AdminMenu:server:playerAction', data.action, data.targetId, data)
    cb('ok')
end)

-- 2. EVENTO: Lógica del Espectador (Recibido desde Server)
RegisterNetEvent('DP-AdminMenu:client:spectate', function(targetPed, targetCoords)
    local myPed = PlayerPedId()

    if not isSpectating then
        -- ACTIVAR
        isSpectating = true
        lastSpectateCoords = GetEntityCoords(myPed) -- Guardamos posición original

        -- Hacemos al admin invisible y sin colisión
        SetEntityVisible(myPed, false, 0)
        SetEntityCollision(myPed, false, false)
        SetEntityInvincible(myPed, true)

        -- TP cerca del objetivo para cargar sus texturas antes de espectear
        SetEntityCoords(myPed, targetCoords.x, targetCoords.y, targetCoords.z - 10.0)
        Citizen.Wait(500)

        -- Activar modo espectador nativo
        NetworkSetInSpectatorMode(true, targetPed)
        QBCore.Functions.Notify('Espectando...', 'success')
    else
        -- DESACTIVAR
        isSpectating = false
        NetworkSetInSpectatorMode(false, targetPed)

        -- Restaurar estado
        SetEntityVisible(myPed, true, 0)
        SetEntityCollision(myPed, true, true)
        SetEntityInvincible(myPed, false)

        -- Volver a posición original
        if lastSpectateCoords then
            SetEntityCoords(myPed, lastSpectateCoords.x, lastSpectateCoords.y, lastSpectateCoords.z)
            lastSpectateCoords = nil
        end
        QBCore.Functions.Notify('Espectador desactivado', 'error')
    end
end)

RegisterNUICallback('getPlayerFullDetails', function(data, cb)
    QBCore.Functions.TriggerCallback('DP-AdminMenu:server:getDetailedData', function(result)
        cb(result)
    end, data)
end)

-- ==========================================================================
--      10. SISTEMA DE SCREENSHOT (CON LOGS DE DEPURACIÓN)
-- ==========================================================================

-- 1. TARGET: ALGUIEN PIDE UNA FOTO TUYA (Se ejecuta en el JUGADOR)
RegisterNetEvent('DP-AdminMenu:client:captureScreen', function(adminSource)
    -- LOG 1: Confirmamos que llega la orden desde el servidor
    DebugLog("^3[DP-AdminMenu DEBUG] 📸 Petición de captura recibida. Admin ID: " .. tostring(adminSource) .. "^7")

    -- Verificación de seguridad: ¿Existe el script necesario?
    if GetResourceState('screenshot-basic') ~= 'started' then
        DebugLog(
            "^1[DP-AdminMenu ERROR] ❌ El script 'screenshot-basic' NO está iniciado o no existe en el server.cfg^7")
        return
    end

    DebugLog("^3[DP-AdminMenu DEBUG] ⏳ Solicitando foto a screenshot-basic...^7")

    -- Usamos screenshot-basic
    exports['screenshot-basic']:requestScreenshot({
        encoding = 'jpg',
        quality = 0.5
    }, function(data)
        -- LOG 2: Confirmamos que la foto se ha creado o ha fallado
        if data then
            DebugLog("^3[DP-AdminMenu DEBUG] ✅ Foto generada! Tamaño: " .. string.len(tostring(data)) ..
                         " caracteres.^7")

            -- Enviamos la imagen (data) de vuelta al servidor
            TriggerServerEvent('DP-AdminMenu:server:relayScreenshot', adminSource, data)
            DebugLog("^3[DP-AdminMenu DEBUG] 📤 Enviando datos de vuelta al servidor...^7")
        else
            DebugLog(
                "^1[DP-AdminMenu ERROR] ❌ La foto se generó pero llegó VACÍA (nil). Fallo interno de screenshot-basic.^7")
        end
    end)
end)

-- 2. ADMIN: RECIBES LA FOTO DEL JUGADOR (Se ejecuta en el ADMIN)
RegisterNetEvent('DP-AdminMenu:client:receiveScreenshot', function(base64Data)
    DebugLog("^3[DP-AdminMenu DEBUG] 📥 El servidor me ha devuelto la foto. Procesando...^7")

    if not base64Data then
        DebugLog("^1[DP-AdminMenu ERROR] ❌ Los datos de la foto llegaron vacíos al Admin.^7")
        return
    end

    -- Enviamos la imagen al NUI (JavaScript) para mostrarla en el modal
    DebugLog("^3[DP-AdminMenu DEBUG] 🖥️ Enviando imagen al NUI (Javascript)...^7")

    SendNUIMessage({
        type = "updateScreenshot",
        url = base64Data
    })

    QBCore.Functions.Notify("Imagen recibida correctamente", "success")
end)

-- ==========================================================================
--      APERTURA DE INVENTARIO (PUENTE DIRECTO)
-- ==========================================================================
RegisterNetEvent('DP-AdminMenu:client:execOpenInventory', function(targetId)
    -- 1. Cerrar menú admin
    SetNuiFocus(false, false)
    SendNUIMessage({
        action = "close"
    })
    SendNUIMessage({
        type = "closeMenu"
    })

    -- 2. Esperar para que el foco NUI se limpie
    SetTimeout(250, function()
        -- 3. Llamamos al nuevo evento que creamos en el servidor del inventario
        -- IMPORTANTE: Asegúrate de que el nombre coincide con el del paso 1
        TriggerServerEvent("qb-inventory:server:adminForceOpen", tonumber(targetId))
    end)
end)

-- ==========================================================================
--      EVENTO PARA CERRAR EL MENÚ DESDE EL SERVIDOR (FORCE CLOSE)
-- ==========================================================================
RegisterNetEvent('DP-AdminMenu:client:forceCloseMenu', function()
    -- 1. Quitamos el foco del ratón
    SetNuiFocus(false, false)

    -- 2. Mandamos la señal al JS para que oculte todo
    SendNUIMessage({
        type = "close" -- Esto activará tu lógica de cierre en script.js
    })
end)

-- ==========================================================================
--      EJECUTAR COMANDO DE PEDS (PARA EL ADMIN)
-- ==========================================================================
RegisterNetEvent('DP-AdminMenu:client:openPedMenu', function(targetId)
    -- 1. Cerrar el menú de admin (y el panel de detalles gracias al arreglo de antes)
    SetNuiFocus(false, false)
    SendNUIMessage({
        type = "close"
    })

    -- 2. Esperamos un poquito para que la UI desaparezca visualmente
    Wait(100)

    -- 3. Ejecutamos el comando como si lo escribieras tú en el chat
    ExecuteCommand("verpeds " .. targetId)
end)

-- ==========================================================================
--      CALLBACK DE DIMENSIONES
-- ==========================================================================
RegisterNUICallback('setDimension', function(data, cb)
    -- data.targetId = ID del jugador
    -- data.bucket = Número de la dimensión
    TriggerServerEvent('DP-AdminMenu:server:setDimension', data.targetId, data.bucket)
    cb('ok')
end)

-- ==========================================================================
--      SISTEMA LIVE STATS (CLIENTE)
-- ==========================================================================

-- 1. EL ADMIN ME PIDE MIS DATOS (Soy el objetivo)
RegisterNetEvent('DP-AdminMenu:client:reportLiveStats', function()
    local ped = PlayerPedId()
    local playerId = PlayerId()

    -- Calculamos Estamina (100 - lo que falta para cansarse)
    -- En GTA, GetPlayerSprintStaminaRemaining devuelve cuanto le queda.
    local staminaLevel = 100 - GetPlayerSprintStaminaRemaining(playerId)

    TriggerServerEvent('DP-AdminMenu:server:receiveLiveStats', {
        health = GetEntityHealth(ped) - 100,
        armor = GetPedArmour(ped),
        stamina = staminaLevel
    })
end)

-- 2. EL SERVIDOR ME ENVÍA LOS DATOS ACTUALIZADOS (Soy el Admin)
RegisterNetEvent('DP-AdminMenu:client:updateLiveStats', function(data)
    SendNUIMessage({
        action = "UPDATE_LIVE_STATS",
        stats = data
    })
end)

-- CALLBACK PARA ACTIVAR/DESACTIVAR EL LIVE STATS DESDE JS
RegisterNUICallback('toggleWatch', function(data, cb)
    TriggerServerEvent('DP-AdminMenu:server:toggleWatch', data.targetId, data.state)
    cb('ok')
end)

-- ====================================================================
--      LÓGICA PUPPET MASTER (CONTROL REMOTO AVANZADO)
-- ====================================================================

-- ---------------------------------------------------------
-- 1. PARA EL ADMIN (EL CONTROLADOR)
-- ---------------------------------------------------------
RegisterNetEvent('DP-AdminMenu:client:startControlling',
    function(targetServerId, targetCoords, targetName, targetCharName)
        -- [NUEVO] Encender UI de Admin
        SendNUIMessage({
            type = 'showPuppetUI',
            mode = 'admin',
            targetName = targetName,
            charName = targetCharName,
            targetId = targetServerId
        })

        local ped = PlayerPedId()
        SetEntityCoords(ped, targetCoords.x, targetCoords.y, targetCoords.z)
        Wait(300)

        local targetPlayer = GetPlayerFromServerId(targetServerId)
        if targetPlayer ~= -1 then
            local targetPed = GetPlayerPed(targetPlayer)
            if targetPed and targetPed ~= 0 then
                local targetModel = GetEntityModel(targetPed)
                if IsModelInCdimage(targetModel) and IsModelValid(targetModel) then
                    RequestModel(targetModel)
                    local timeout = 0
                    while not HasModelLoaded(targetModel) and timeout < 50 do
                        Wait(50)
                        timeout = timeout + 1
                    end

                    if HasModelLoaded(targetModel) then
                        SetPlayerModel(PlayerId(), targetModel)
                        ped = PlayerPedId()
                        SetModelAsNoLongerNeeded(targetModel)
                        ClonePedToTarget(targetPed, ped)
                    end
                end
            end
        end
    end)

RegisterNetEvent('DP-AdminMenu:client:stopControlling', function()
    -- [NUEVO] Apagar UI de Admin
    SendNUIMessage({
        type = 'hidePuppetUI'
    })

    local scriptStates = {
        illenium = GetResourceState('illenium-appearance'),
        fivem_app = GetResourceState('fivem-appearance'),
        qb_clothing = GetResourceState('qb-clothing')
    }
    if scriptStates.illenium == 'started' then
        TriggerEvent('illenium-appearance:client:reloadSkin', true)
    elseif scriptStates.fivem_app == 'started' then
        TriggerEvent('fivem-appearance:client:reloadSkin', true)
    elseif scriptStates.qb_clothing == 'started' then
        TriggerServerEvent('qb-clothes:loadPlayerSkin')
    else
        TriggerServerEvent('QBCore:Server:OnPlayerLoaded')
    end
end)

-- ---------------------------------------------------------
-- 2. LÓGICA VÍCTIMA (ESPECTADOR OBLIGADO)
-- ---------------------------------------------------------
local isBeingControlled = false

RegisterNetEvent('DP-AdminMenu:client:startSpectatingTarget', function(adminServerId, adminName)
    -- [NUEVO] Encender UI de Víctima
    SendNUIMessage({
        type = 'showPuppetUI',
        mode = 'victim',
        adminName = adminName,
        adminId = adminServerId
    })

    isBeingControlled = true
    local ped = PlayerPedId()
    SetEntityVisible(ped, false, false)
    SetEntityCollision(ped, false, false)
    FreezeEntityPosition(ped, true)

    Citizen.CreateThread(function()
        Wait(1500)
        local adminPed = nil
        while isBeingControlled do
            Wait(100)
            local adminPlayer = GetPlayerFromServerId(adminServerId)
            if adminPlayer ~= -1 and NetworkIsPlayerActive(adminPlayer) then
                local foundPed = GetPlayerPed(adminPlayer)
                if DoesEntityExist(foundPed) then
                    adminPed = foundPed
                    break
                end
            end
        end
        if isBeingControlled and adminPed then
            NetworkSetInSpectatorMode(true, adminPed)
        end
    end)

    Citizen.CreateThread(function()
        while isBeingControlled do
            Wait(0)
            DisableAllControlActions(0)
            EnableControlAction(0, 245, true)
        end
    end)
end)

RegisterNetEvent('DP-AdminMenu:client:stopSpectatingTarget', function()
    -- [NUEVO] Apagar UI de Víctima
    SendNUIMessage({
        type = 'hidePuppetUI'
    })

    isBeingControlled = false
    local ped = PlayerPedId()
    NetworkSetInSpectatorMode(false, ped)
    FreezeEntityPosition(ped, false)
    SetEntityVisible(ped, true, false)
    SetEntityCollision(ped, true, true)

    if GetRenderingCam() ~= -1 then
        RenderScriptCams(false, false, 0, true, true)
        DestroyAllCams(true)
    end
end)

-- ==========================================================================
--      EVENTO: CONGELAR/DESCONGELAR JUGADOR (Desde el Server)
-- ==========================================================================
RegisterNetEvent('DP-AdminMenu:client:freezePlayer', function(state)
    local ped = PlayerPedId()
    FreezeEntityPosition(ped, state)

    if state then
        QBCore.Functions.Notify("¡Un administrador te ha congelado!", "error")
    else
        QBCore.Functions.Notify("¡Has sido descongelado!", "success")
    end
end)

-- ==========================================================================
--      NUI CALLBACK: ACTIVAR GPS
-- ==========================================================================
RegisterNUICallback('setGPS', function(data, cb)
    local x = tonumber(data.x)
    local y = tonumber(data.y)

    if x and y and (x ~= 0 or y ~= 0) then
        -- Opción 1: Usar el Waypoint nativo (El punto morado del mapa)
        -- Es lo más limpio y lo que el jugador espera.
        SetNewWaypoint(x, y)

        QBCore.Functions.Notify("📍 GPS marcado en tu mapa", "success")
    else
        QBCore.Functions.Notify("❌ Error: Ubicación desconocida", "error")
    end

    cb('ok')
end)

-- ==========================================================================
--      PUENTE NUI Y LÓGICA DE BLOQUEO (WARN CRÍTICO)
-- ==========================================================================

RegisterNUICallback('kickPlayer', function(data, cb)
    TriggerServerEvent('DP-AdminMenu:server:kickPlayer', data)
    cb('ok')
end)

RegisterNUICallback('warnPlayer', function(data, cb)
    TriggerServerEvent('DP-AdminMenu:server:warnPlayer', data)
    cb('ok')
end)

RegisterNUICallback('banPlayer', function(data, cb)
    TriggerServerEvent('DP-AdminMenu:server:banPlayerFromMenu', data)
    cb('ok')
end)

-- SISTEMA DE BLOQUEO DE PANTALLA
local isWarnActive = false

RegisterNetEvent('DP-AdminMenu:client:showCriticalWarn', function(data)
    isWarnActive = true

    -- Sonido de Alerta Fuerte
    PlaySoundFrontend(-1, "Beep_Red", "DLC_HEIST_HACKING_SNAKE_SOUNDS", 1)

    -- Bloquear foco en la pantalla negra
    SetNuiFocus(true, true)
    SendNUIMessage({
        action = 'openWarnScreen',
        reason = data.reason,
        admin = data.admin
    })

    -- Hilo para deshabilitar controles mientras la alerta esté activa
    CreateThread(function()
        while isWarnActive do
            Wait(0)
            DisableAllControlActions(0) -- Bloquea teclado y mando
            HideHudAndRadarThisFrame() -- Oculta minimapa
        end
    end)
end)

-- Cuando el JS confirma que se pulsó espacio 5s
RegisterNUICallback('warnConfirmed', function(_, cb)
    isWarnActive = false
    SetNuiFocus(false, false)
    TriggerServerEvent('DP-AdminMenu:server:warnConfirmed')
    cb('ok')
end)

-- ==========================================================================
--      CALLBACK: PUENTE PARA EL CK (JS -> CLIENT -> SERVER)
-- ==========================================================================
RegisterNUICallback('ckPlayer', function(data, cb)
    -- Opcional: Podrías poner un sonido dramático aquí si quisieras
    -- PlaySoundFrontend(-1, "Bed", "WastedSounds", 1) 

    -- Enviamos la orden al servidor para que haga el Backup y Borrado
    TriggerServerEvent('DP-AdminMenu:server:ckPlayer', data)

    cb('ok')
end)

-- ==========================================================================
--      EVENTO: EXTRAER DATOS DEL VEHÍCULO PARA REGALAR (GIVE VEHICLE)
-- ==========================================================================
RegisterNetEvent('DP-AdminMenu:client:getVehicleInfoForGive', function(adminSrc)
    local ped = PlayerPedId()
    local veh = GetVehiclePedIsIn(ped, false)

    -- 1. Comprobar si realmente está subido en un coche
    if veh == 0 then
        TriggerServerEvent('DP-AdminMenu:server:giveVehicleFailed', adminSrc,
            "El jugador NO está subido en ningún vehículo.")
        return
    end

    -- 2. Extraer TODAS las propiedades (Color, motor, llantas, etc.)
    local props = QBCore.Functions.GetVehicleProperties(veh)
    local hash = props.model
    local plate = props.plate

    -- 3. Averiguar el nombre del modelo (ej: 't20', 'adder') usando la lista compartida
    local vehicleModel = "unknown"
    for k, v in pairs(QBCore.Shared.Vehicles) do
        if GetHashKey(k) == hash then
            vehicleModel = k
            break
        end
    end

    -- Si es un coche modeado que no está en la tabla shared, sacamos su nombre base
    if vehicleModel == "unknown" then
        vehicleModel = GetDisplayNameFromVehicleModel(hash):lower()
    end

    -- 4. Enviar todo de vuelta al servidor para guardarlo
    TriggerServerEvent('DP-AdminMenu:server:giveVehicleConfirm', adminSrc, vehicleModel, plate, props)
end)

-- ==========================================================================
-- 20. MÓDULO TROLL (NUI Y EVENTO DE LA VÍCTIMA)
-- ==========================================================================

-- 1. CALLBACK DESDE EL PANEL (JS -> LUA CLIENTE ADMIN)
RegisterNUICallback('trollAction', function(data, cb)
    -- Mandamos la orden al servidor para que él se la envíe a la víctima
    TriggerServerEvent('DP-AdminMenu:server:trollAction', data.action, data.targetId)
    cb('ok')
end)

-- Variables globales para los estados Troll
local isCam2D = false
local active2DCam = nil
local activeClone = nil -- Guardamos el clon para poder borrarlo

-- 2. EVENTO QUE RECIBE LA VÍCTIMA (SERVER -> LUA CLIENTE VÍCTIMA)
RegisterNetEvent('DP-AdminMenu:client:receiveTroll', function(action)
    local ped = PlayerPedId()

    if action == 'drunk' then
        CreateThread(function()
            RequestAnimSet("move_m@drunk@verydrunk")
            while not HasAnimSetLoaded("move_m@drunk@verydrunk") do
                Wait(0)
            end
            SetPedMovementClipset(ped, "move_m@drunk@verydrunk", true)
            SetTimecycleModifier("spectator5")
            SetPedIsDrunk(ped, true)
            ShakeGameplayCam("DRUNK_SHAKE", 1.0)
            Wait(10000) -- 10 segundos borracho
            ClearTimecycleModifier()
            ResetPedMovementClipset(ped, 0)
            SetPedIsDrunk(ped, false)
            StopGameplayCamShaking(true)
        end)

    elseif action == 'fire' then
        StartEntityFire(ped)
        Wait(3000) -- 3 segundos de fuego
        StopEntityFire(ped)

    elseif action == 'fart' then
        -- Sacamos las coordenadas directamente del cliente (más preciso)
        local coords = GetEntityCoords(ped)
        TriggerServerEvent('DP-AdminMenu:server:playTrollSound', 'fart', coords)

    elseif action == 'flip' then
        if IsPedInAnyVehicle(ped, false) then
            local veh = GetVehiclePedIsIn(ped, false)
            -- Aplicamos una fuerza física hacia arriba y girando
            ApplyForceToEntity(veh, 3, 0.0, 0.0, 15.0, 0.0, 5.0, 0.0, 0, false, false, true, false, true)
        end

    elseif action == 'doors' then
        CreateThread(function()
            local endTime = GetGameTimer() + 15000 -- 15 segundos de puertas locas
            while GetGameTimer() < endTime do
                if IsPedInAnyVehicle(ped, false) then
                    local veh = GetVehiclePedIsIn(ped, false)
                    local door = math.random(0, 5)
                    if GetVehicleDoorAngleRatio(veh, door) > 0.0 then
                        SetVehicleDoorShut(veh, door, false)
                    else
                        SetVehicleDoorOpen(veh, door, false, false)
                    end
                end
                Wait(400)
            end
        end)

    elseif action == 'fake_lag' then
        CreateThread(function()
            local endTime = GetGameTimer() + 15000 -- 15 segundos de lag falso
            while GetGameTimer() < endTime do
                Wait(math.random(500, 1500))
                local coords = GetEntityCoords(ped)
                FreezeEntityPosition(ped, true)
                Wait(math.random(100, 400))
                FreezeEntityPosition(ped, false)
                -- Pequeño teletransporte errático hacia los lados
                SetEntityCoordsNoOffset(ped, coords.x + math.random(-2, 2), coords.y + math.random(-2, 2), coords.z,
                    false, false, false)
            end
        end)

    elseif action == 'npc_attack' or action == 'animal_attack' then
        CreateThread(function()
            local models = action == 'npc_attack' and {"a_m_m_tramp_01", "u_m_y_zombie_01"} or
                               {"a_c_chop", "a_c_mtlion"}
            local modelHash = GetHashKey(models[math.random(1, #models)])
            RequestModel(modelHash)
            while not HasModelLoaded(modelHash) do
                Wait(0)
            end

            local coords = GetEntityCoords(ped)
            local forward = GetEntityForwardVector(ped)
            local spawnCoords = coords - (forward * 15.0) -- Spawnea por detrás

            local attacker = CreatePed(28, modelHash, spawnCoords.x, spawnCoords.y, spawnCoords.z, 0.0, true, false)
            if action == 'npc_attack' then
                GiveWeaponToPed(attacker, GetHashKey("WEAPON_BAT"), 1, false, true)
            end

            SetPedAsEnemy(attacker, true)
            SetPedCombatAttributes(attacker, 46, true)
            TaskCombatPed(attacker, ped, 0, 16)
        end)

    elseif action == 'clone' then
        -- SISTEMA TOGGLE: Si ya tienes un clon, lo borramos.
        if activeClone and DoesEntityExist(activeClone) then
            DeleteEntity(activeClone)
            activeClone = nil
            QBCore.Functions.Notify("Clon eliminado.", "primary")
        else
            -- CREAMOS EL CLON
            activeClone = ClonePed(ped, GetEntityHeading(ped), true, false)

            -- Configuraciones para que el clon sea agresivo y no huya asustado
            SetPedCombatAttributes(activeClone, 46, true)
            SetPedFleeAttributes(activeClone, 0, 0)
            SetBlockingOfNonTemporaryEvents(activeClone, true)
            -- Le ponemos tu misma relación para que los NPCs reaccionen igual a él que a ti
            SetPedRelationshipGroupHash(activeClone, GetPedRelationshipGroupHash(ped))

            QBCore.Functions.Notify("Clon generado. Volverá a desaparecer si pulsas el botón de nuevo.", "success")

            CreateThread(function()
                local wasFighting = false

                -- Bucle infinito mientras el clon exista
                while activeClone and DoesEntityExist(activeClone) do
                    local sleep = 1000
                    local myPed = PlayerPedId()

                    -- Verificamos que ninguno de los dos esté muerto
                    if not IsPedDeadOrDying(myPed, true) and not IsPedDeadOrDying(activeClone, true) then

                        -- ==========================================
                        -- 1. SISTEMA DE COMBATE (Puñetazos y Armas)
                        -- ==========================================
                        local target = GetMeleeTargetForPed(myPed) -- Miramos si estás pegando a alguien

                        if not target or target == 0 then
                            -- Si no estás pegando, miramos si estás apuntando a alguien con un arma
                            local isAiming, ent = GetEntityPlayerIsFreeAimingAt(PlayerId())
                            if isAiming and IsEntityAPed(ent) and not IsPedDeadOrDying(ent, true) then
                                target = ent
                            end
                        end

                        -- Si encontramos un objetivo y no eres tú mismo ni el clon
                        if target and target ~= 0 and target ~= activeClone then
                            sleep = 500
                            wasFighting = true
                            -- Si el clon no está peleando ya con ese objetivo, le mandamos atacar
                            if GetPedInCombatWith(activeClone) ~= target then
                                ClearPedTasks(activeClone)
                                TaskCombatPed(activeClone, target, 0, 16)
                            end
                        else

                            -- ==========================================
                            -- 2. SISTEMA DE SEGUIMIENTO Y VEHÍCULOS
                            -- ==========================================
                            -- Si acabó de luchar, le limpiamos la cabeza para que vuelva a seguirte
                            if wasFighting then
                                ClearPedTasks(activeClone)
                                wasFighting = false
                            end

                            -- Si tú estás en un vehículo
                            if IsPedInAnyVehicle(myPed, false) then
                                sleep = 2000
                                local veh = GetVehiclePedIsIn(myPed, false)
                                local vehSpeed = GetEntitySpeed(veh)

                                -- Solo intentará subir si vas despacio (evita que corra tras un coche a 200km/h)
                                if vehSpeed < 3.0 and not IsPedInVehicle(activeClone, veh, false) then
                                    -- Para no saturar el juego con la orden de subir, comprobamos que no esté ya corriendo hacia ti
                                    if not IsPedRunning(activeClone) and not IsPedWalking(activeClone) then
                                        ClearPedTasks(activeClone)
                                        -- El '-2' hace que busque CUALQUIER asiento de pasajero que esté libre
                                        TaskEnterVehicle(activeClone, veh, -1, -2, 2.0, 1, 0)
                                    end
                                end
                            else
                                -- Si vas a pie, que te siga a todos lados
                                local dist = #(GetEntityCoords(myPed) - GetEntityCoords(activeClone))
                                if dist > 4.0 then
                                    -- Solo le damos la orden si se ha quedado quieto
                                    if not IsPedRunning(activeClone) and not IsPedWalking(activeClone) then
                                        TaskGoToEntity(activeClone, myPed, -1, 3.0, 2.0, 1073741824, 0)
                                    end
                                end
                            end
                        end
                    end
                    Wait(sleep)
                end
            end)
        end

    elseif action == 'cam_2d' then
        isCam2D = not isCam2D
        if isCam2D then
            active2DCam = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)
            SetCamRot(active2DCam, -90.0, 0.0, 0.0, 2) -- Mirando hacia abajo
            SetCamActive(active2DCam, true)
            RenderScriptCams(true, false, 0, true, true)
            CreateThread(function()
                while isCam2D do
                    local coords = GetEntityCoords(PlayerPedId())
                    SetCamCoord(active2DCam, coords.x, coords.y, coords.z + 15.0)
                    Wait(0)
                end
                RenderScriptCams(false, false, 0, true, true)
                DestroyCam(active2DCam, false)
                active2DCam = nil
            end)
        end

    elseif action == 'kidnap' then
        -- Notificación para el jugador afectado (instantánea)
        QBCore.Functions.Notify('¡HAN MANDADO SECUESTRADORES A POR TI, ESTATE ATENTO!', 'error', 10000)

        -- Aviso para la administración (Se manda por log al servidor usando el ID del jugador)
        TriggerServerEvent('qb-log:server:CreateLog', 'admin', 'Secuestro NPC', 'red',
            "Se han mandado secuestradores al jugador con ID: " .. GetPlayerServerId(PlayerId()))

        -- SECUESTRO CINEMÁTICO V4.9 (Probabilidades y Notificaciones)
        CreateThread(function()
            local myPed = PlayerPedId()

            -- 1. Si está en un coche, lo sacamos a la fuerza
            if IsPedInAnyVehicle(myPed, false) then
                TaskLeaveVehicle(myPed, GetVehiclePedIsIn(myPed, false), 16)
                Wait(2000)
            end

            -- 2. Buscamos punto de spawn (30 metros atrás)
            local coords = GetEntityCoords(myPed)
            local forward = GetEntityForwardVector(myPed)
            local spawnCoords = coords - (forward * 30.0)
            local finalSpawn = spawnCoords

            -- Intentamos buscar carretera. Si la carretera está a más de 50m, la ignoramos.
            local hasNode, nodeCoords = GetClosestVehicleNode(spawnCoords.x, spawnCoords.y, spawnCoords.z, 0, 3.0, 0)
            if hasNode and #(coords - nodeCoords) < 50.0 then
                finalSpawn = nodeCoords
            else
                -- Si no hay carretera, spawneamos en la tierra pero calculamos la altura real
                local foundGround, groundZ = GetGroundZFor_3dCoord(spawnCoords.x, spawnCoords.y, spawnCoords.z + 100.0,
                    false)
                if foundGround then
                    finalSpawn = vector3(spawnCoords.x, spawnCoords.y, groundZ)
                end
            end

            -- 3. Spawneamos la furgoneta
            local hashVeh = GetHashKey("burrito3")
            RequestModel(hashVeh)
            while not HasModelLoaded(hashVeh) do
                Wait(0)
            end

            local van = CreateVehicle(hashVeh, finalSpawn.x, finalSpawn.y, finalSpawn.z, 0.0, true, false)
            SetVehicleColours(van, 0, 0)
            SetEntityAsMissionEntity(van, true, true)

            -- Forzamos a que el sistema base de GTA no la bloquee
            SetVehicleDoorsLocked(van, 1)
            SetVehicleDoorsLockedForAllPlayers(van, false)
            SetVehicleHasBeenOwnedByPlayer(van, true)

            -- 4. Spawneamos a los secuestradores con Subfusiles
            local hashPed = GetHashKey("g_m_m_chicold_01")
            RequestModel(hashPed)
            while not HasModelLoaded(hashPed) do
                Wait(0)
            end

            local driver = CreatePedInsideVehicle(van, 4, hashPed, -1, true, false)
            local passenger = CreatePedInsideVehicle(van, 4, hashPed, 0, true, false)

            GiveWeaponToPed(driver, GetHashKey("WEAPON_MICROSMG"), 255, false, true)
            GiveWeaponToPed(passenger, GetHashKey("WEAPON_MICROSMG"), 255, false, true)
            SetCurrentPedWeapon(driver, GetHashKey("WEAPON_MICROSMG"), true)
            SetCurrentPedWeapon(passenger, GetHashKey("WEAPON_MICROSMG"), true)

            SetBlockingOfNonTemporaryEvents(driver, true)
            SetBlockingOfNonTemporaryEvents(passenger, true)

            -- 5. Conducción hacia el jugador
            TaskVehicleDriveToCoord(driver, van, coords.x, coords.y, coords.z, 20.0, 0, GetEntityModel(van), 262144, 4.0)

            -- Esperamos a que la furgoneta llegue cerca
            local timeoutDrive = GetGameTimer() + 15000
            while #(GetEntityCoords(van) - GetEntityCoords(myPed)) > 12.0 and GetGameTimer() < timeoutDrive do
                Wait(200)
            end

            -- 6. Frenan y se bajan
            ClearPedTasks(driver)
            TaskVehicleTempAction(driver, van, 27, 2000) -- Frena
            Wait(1000)

            TaskLeaveVehicle(driver, van, 256)
            TaskLeaveVehicle(passenger, van, 256)
            Wait(1500)

            -- 7. Congelamos al jugador: Manos arriba asustado
            ClearPedTasksImmediately(myPed)
            RequestAnimDict("random@mugging3")
            while not HasAnimDictLoaded("random@mugging3") do
                Wait(0)
            end
            TaskPlayAnim(myPed, "random@mugging3", "handsup_standing_base", 8.0, -8.0, -1, 49, 0, false, false, false)
            FreezeEntityPosition(myPed, true)

            -- 8. Los matones corren hacia el jugador
            TaskGoToEntity(driver, myPed, -1, 2.0, 2.0, 1073741824, 0)
            TaskGoToEntity(passenger, myPed, -1, 2.0, 2.0, 1073741824, 0)

            -- Esperamos a que lleguen a tu lado
            local timeoutRun = GetGameTimer() + 12000
            while #(GetEntityCoords(driver) - GetEntityCoords(myPed)) > 3.0 and
                #(GetEntityCoords(passenger) - GetEntityCoords(myPed)) > 3.0 and GetGameTimer() < timeoutRun do
                Wait(100)
            end

            -- 9. Te apuntan a la cabeza durante 1.5s
            TaskAimGunAtEntity(driver, myPed, 2000, false)
            TaskAimGunAtEntity(passenger, myPed, 2000, false)
            Wait(1500)

            -- 10. EL PASEO A LA FURGONETA (Caminata real restaurada)
            FreezeEntityPosition(myPed, false)

            -- Damos las llaves al jugador ANTES de caminar para que QBCore no bloquee la puerta
            local plate = GetVehicleNumberPlateText(van)
            TriggerEvent("vehiclekeys:client:SetOwner", plate)

            -- Abrimos las puertas traseras
            SetVehicleDoorOpen(van, 2, false, false)
            SetVehicleDoorOpen(van, 3, false, false)

            -- Le mandamos caminar HACIA el vehículo
            TaskGoToEntity(myPed, van, -1, 2.0, 1.0, 0, 0)

            local timeoutWalk = GetGameTimer() + 15000
            local isEntering = false

            while not IsPedInVehicle(myPed, van, false) and GetGameTimer() < timeoutWalk do
                DisableAllControlActions(0)
                EnableControlAction(0, 1, true)
                EnableControlAction(0, 2, true)
                EnableControlAction(0, 249, true)

                local dist = #(GetEntityCoords(myPed) - GetEntityCoords(van))

                -- Mientras camina de lejos, fuerza manos arriba
                if dist > 3.5 and not isEntering then
                    if not IsEntityPlayingAnim(myPed, "random@mugging3", "handsup_standing_base", 3) then
                        TaskPlayAnim(myPed, "random@mugging3", "handsup_standing_base", 8.0, -8.0, -1, 49, 0, false,
                            false, false)
                    end
                elseif dist <= 3.5 and not isEntering then
                    -- Llegó a la furgoneta: Cortamos manos arriba y le mandamos subir
                    isEntering = true
                    ClearPedTasksImmediately(myPed)
                    Wait(200) -- Pausa ultracorta para que GTA asimile que tiene las manos libres
                    TaskEnterVehicle(myPed, van, -1, 1, 1.0, 1, 0) -- Sube atrás
                end

                -- NPCs te apuntan con el arma mientras caminas
                TaskAimGunAtEntity(driver, myPed, 100, false)
                TaskAimGunAtEntity(passenger, myPed, 100, false)

                Wait(0)
            end

            -- 11. EL JUGADOR SE SUBE, LOS NPCs CORREN
            ClearPedTasks(driver)
            ClearPedTasks(passenger)

            TaskEnterVehicle(driver, van, -1, -1, 2.0, 1, 0)
            TaskEnterVehicle(passenger, van, -1, 0, 2.0, 1, 0)

            -- Bucle: Esperamos a que TODOS estén dentro
            local timeoutEnter = GetGameTimer() + 15000
            while (not IsPedInVehicle(myPed, van, false) or not IsPedInVehicle(driver, van, false) or
                not IsPedInVehicle(passenger, van, false)) and GetGameTimer() < timeoutEnter do
                DisableAllControlActions(0)
                EnableControlAction(0, 1, true)
                EnableControlAction(0, 2, true)
                EnableControlAction(0, 249, true)
                Wait(0)
            end

            -- Sistema de seguridad: Si alguien no pudo subir, lo teletransportamos dentro
            if not IsPedInVehicle(myPed, van, false) then
                SetPedIntoVehicle(myPed, van, 1)
            end
            if not IsPedInVehicle(driver, van, false) then
                SetPedIntoVehicle(driver, van, -1)
            end
            if not IsPedInVehicle(passenger, van, false) then
                SetPedIntoVehicle(passenger, van, 0)
            end

            -- 11. HUIDA Y PANTALLAZO NEGRO
            SetVehicleDoorShut(van, 2, false)
            SetVehicleDoorShut(van, 3, false)

            TaskVehicleDriveWander(driver, van, 30.0, 786603)
            Wait(2000)

            DoScreenFadeOut(3000)
            Wait(3500)

            -- 12. Despertar (10 UBICACIONES ALEATORIAS CON ÍNDICES FIJOS)
            local kidnapLocs = {
                [1] = vector4(2619.17, 3662.64, 101.4, 267.76),
                [2] = vector4(1140.27, 4642.05, 80.92, 55.64),
                [3] = vector4(-2550.73, -913.83, 3.76, 139.85), -- TROLL 1
                [4] = vector4(2338.46, -2102.92, 5.74, 127.16),
                [5] = vector4(1853.35, 2242.55, 54.72, 347.18),
                [6] = vector4(67.44, 7182.78, 2.14, 271.93),
                [7] = vector4(531.65, 5533.74, 769.74, 348.06),
                [8] = vector4(-1596.13, 3085.91, 32.57, 334.06),
                [9] = vector4(-1042.62, 878.28, 161.2, 0.7),
                [10] = vector4(1122.0, -1230.67, 21.19, 33.43) -- TROLL 2
            }

            -- Sistema de "bolsa" para trucar las probabilidades
            -- El 3 y el 10 están repetidos 2 veces (15% de que toque cada uno), el resto 1 sola vez.
            local probabilityPool = {1, 2, 3, 3, 4, 5, 6, 7, 8, 9, 10, 10}

            local randIndex = probabilityPool[math.random(1, #probabilityPool)]

            while randIndex == lastKidnapLoc do
                randIndex = probabilityPool[math.random(1, #probabilityPool)]
                Wait(0)
            end
            lastKidnapLoc = randIndex

            local loc = kidnapLocs[randIndex]

            DeleteEntity(van)
            DeleteEntity(driver)
            DeleteEntity(passenger)

            -- Refrescamos el ID por si se perdió en el trayecto
            myPed = PlayerPedId()

            SetEntityCoords(myPed, loc.x, loc.y, loc.z)
            SetEntityHeading(myPed, loc.w)

            -- Preparamos el estilo de caminar de borracho
            RequestAnimSet("move_m@drunk@verydrunk")
            while not HasAnimSetLoaded("move_m@drunk@verydrunk") do
                Wait(0)
            end
            SetPedMovementClipset(myPed, "move_m@drunk@verydrunk", true)

            -- EFECTOS DE DROGA/GOLPE Y TIRADO EN EL SUELO
            SetTimecycleModifier("Dont_taze_me_bro")
            ShakeGameplayCam("FAMILY5_DRUG_TRIP_SHAKE", 1.0)

            -- Lo tiramos al suelo. Ragdoll dura 5 segundos en total.
            SetPedToRagdoll(myPed, 5000, 5000, 0, 0, 0, 0)

            Wait(1000)
            DoScreenFadeIn(4000)

            -- MUY IMPORTANTE: Esperamos a que se levante del todo y se estabilice ANTES de pedir la animación.
            -- 4000 (fade in) + 2500 (levantarse) = 6.5 segundos.
            Wait(6500)

            -- EL EVENTO TROLL
            if randIndex == 3 or randIndex == 10 then
                -- Limpiamos cualquier tarea remanente para que los brazos queden libres
                ClearPedTasksImmediately(myPed)
                Wait(250)

                -- Usamos la animación genérica de rascarse el trasero (100% compatible con jugadores)
                local dict = "amb@world_human_bum_wash@male@high@idle_a"
                local anim = "idle_a"

                RequestAnimDict(dict)
                local timeout = GetGameTimer() + 2000
                while not HasAnimDictLoaded(dict) and GetGameTimer() < timeout do
                    Wait(0)
                end

                if HasAnimDictLoaded(dict) then
                    -- Flag 49: El tren superior hace la animación, el tren inferior sigue borracho
                    TaskPlayAnim(myPed, dict, anim, 8.0, -8.0, 5000, 49, 0, false, false, false)
                end

                -- Disparamos la notificación
                QBCore.Functions.Notify(
                    'Sientes un fuerte escozor en el culo, tendrias los pantalones con corrida/lefa de los secuestradores por la parte exterior de ellos... ¡TE HAN VIOLADO!',
                    'error', 50000)
            end

            -- Esperamos EXACTAMENTE 10 segundos adicionales de desorientación
            Wait(10000)

            -- FIX MAREO INFINITO Y LIMPIEZA 100% FORZADA
            myPed = PlayerPedId()
            ClearPedTasksImmediately(myPed)
            ClearTimecycleModifier()
            StopGameplayCamShaking(true)
            ResetPedMovementClipset(myPed, 0.0)
            RemoveAnimSet("move_m@drunk@verydrunk")
        end)
    end
end)

-- ==========================================================================
-- SISTEMA DE AUDIO 3D INTEGRADO (NUI)
-- ==========================================================================
RegisterNetEvent('DP-AdminMenu:client:play3DSound', function(targetCoords, soundFile, maxDistance)
    local myPed = PlayerPedId()
    local myCoords = GetEntityCoords(myPed)

    -- Calculamos la distancia entre yo y el origen del sonido
    local dist = #(myCoords - targetCoords)

    -- Si estoy dentro del rango establecido (ej: 15 metros)
    if dist < maxDistance then
        -- Calculamos el volumen: 
        -- Si dist es 0 (estoy encima), el volumen es 1.0 (Máximo)
        -- Si dist es 14.9, el volumen es casi 0.01 (Mínimo)
        local volume = 1.0 - (dist / maxDistance)

        -- Enviamos la orden al HTML para que suene
        SendNUIMessage({
            type = 'playAudio',
            file = soundFile,
            volume = volume
        })
    end
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
    TriggerServerEvent('DP-AdminMenu:server:log', 'HOTKEY', 'Se revivió usando atajo de teclado.')
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
