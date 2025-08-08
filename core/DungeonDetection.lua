-- DungeonDetection.lua - Detección automática del final de dungeon
-- Responsabilidad: Detectar cuando una dungeon termina y abrir automáticamente la modal de rating

local frame = CreateFrame("Frame")
local dungeonCompleted = false
local lastEncounterID = nil

-- Inicializar el sistema de detección de final de dungeon
function InitializeDungeonDetectionSystem()
    -- Registrar eventos modernos para detección de final de dungeon
    frame:RegisterEvent("CHALLENGE_MODE_COMPLETED")
    frame:RegisterEvent("ENCOUNTER_END")
    frame:RegisterEvent("SCENARIO_COMPLETED")
    frame:RegisterEvent("INSTANCE_ENCOUNTER_ENGAGE_UNIT")
    frame:RegisterEvent("PLAYER_ENTERING_WORLD")
    
    frame:SetScript("OnEvent", function(self, event, ...)
        if event == "CHALLENGE_MODE_COMPLETED" then
            -- Mythic+ key completada (API moderna)
            HandleDungeonCompletion("Mythic+ Key Completed")
            
        elseif event == "ENCOUNTER_END" then
            local encounterID, encounterName, difficultyID, groupSize, success = ...
            if success then
                lastEncounterID = encounterID
                -- Esperar un poco para verificar si es el último boss
                C_Timer.After(2, function()
                    CheckIfDungeonCompleted(encounterID, encounterName)
                end)
            end
            
        elseif event == "SCENARIO_COMPLETED" then
            -- Para algunos tipos de contenido como scenarios
            HandleDungeonCompletion("Scenario Completed")
            
        elseif event == "INSTANCE_ENCOUNTER_ENGAGE_UNIT" then
            -- Resetear flag cuando empieza un nuevo encuentro
            dungeonCompleted = false
            
        elseif event == "PLAYER_ENTERING_WORLD" then
            -- Resetear estado al cambiar de zona
            dungeonCompleted = false
            lastEncounterID = nil
        end
    end)
end

-- Función principal para manejar la finalización de dungeon
function HandleDungeonCompletion(reason)
    if dungeonCompleted then 
        return -- Evitar múltiples activaciones
    end
    
    dungeonCompleted = true
    
    -- Verificar que estamos en una dungeon válida
    if not IsInValidDungeon() then
        return
    end
    
    -- Verificar que estamos en grupo
    if not IsInGroup() then
        return
    end
    
    -- Esperar un poco para que la UI se estabilice después del combate
    C_Timer.After(3, function()
        local dungeonInfo = GetCurrentDungeonInfo()
        if dungeonInfo and dungeonInfo.name ~= "Unknown" then
            print("Dungeon completed! Opening rating interface...")
            ShowDungeonRatingFrame()
        end
    end)
end

-- Verificar si la dungeon se completó basado en el encounter
function CheckIfDungeonCompleted(encounterID, encounterName)
    if not IsInValidDungeon() then
        return
    end
    
    local dungeonInfo = GetCurrentDungeonInfo()
    if not dungeonInfo or dungeonInfo.name == "Unknown" then
        return
    end
    
    -- Para Mythic+, usar el evento específico CHALLENGE_MODE_COMPLETED
    if dungeonInfo.isKey then
        return -- Se maneja por el evento específico
    end
    
    -- Para dungeons normales, verificar si es el último boss
    if IsLastBossOfCurrentDungeon(encounterID, dungeonInfo.name) then
        HandleDungeonCompletion("Final Boss Defeated: " .. encounterName)
    end
end

-- Verificar si estamos en una dungeon válida para rating
function IsInValidDungeon()
    local inInstance, instanceType = IsInInstance()
    if not inInstance then
        return false
    end
    
    -- Solo dungeons (party) son válidas para rating
    if instanceType ~= "party" then
        return false
    end
    
    return true
end

-- Base de datos moderna de dungeons y sus bosses finales
function IsLastBossOfCurrentDungeon(encounterID, dungeonName)
    -- Base de datos actualizada para TWW (The War Within)
    local lastBossEncounters = {
        -- Dungeons de TWW
        ["The Stonevault"] = {2656, 2657, 2658, 2659},
        ["City of Threads"] = {2594, 2595, 2596, 2597},
        ["Ara-Kara, City of Echoes"] = {2562, 2563, 2564, 2565},
        ["The Dawnbreaker"] = {2580, 2581, 2582, 2583},
        ["Cinderbrew Meadery"] = {2789, 2790, 2791, 2792},
        ["Darkflame Cleft"] = {2798, 2799, 2800, 2801},
        ["Priory of the Sacred Flame"] = {2593, 2594, 2595, 2596},
        ["The Rookery"] = {2570, 2571, 2572, 2573},
        
        -- Dungeons rotacionales (de expansiones anteriores)
        ["Siege of Boralus"] = {2140, 2141, 2142, 2143},
        ["Grim Batol"] = {1048, 1049, 1050, 1051},
        ["Mists of Tirna Scithe"] = {2400, 2401, 2402, 2403},
        ["The Necrotic Wake"] = {2395, 2396, 2397, 2398},
        
        -- Fallback para dungeons no reconocidas (usar lista genérica)
        ["Unknown"] = {}
    }
    
    -- Buscar en la base de datos específica
    local dungeonBosses = lastBossEncounters[dungeonName]
    if dungeonBosses and #dungeonBosses > 0 then
        for _, bossID in ipairs(dungeonBosses) do
            if encounterID == bossID then
                return true
            end
        end
        return false -- Si conocemos la dungeon pero no es el último boss
    end
    
    -- Si no conocemos la dungeon específica, usar heurística
    return UseHeuristicForLastBoss(encounterID, dungeonName)
end

-- Heurística para determinar si es el último boss cuando no conocemos la dungeon
function UseHeuristicForLastBoss(encounterID, dungeonName)
    -- Verificar si hay más encuentros activos o próximos
    local activeEncounters = C_EncounterJournal.GetEncountersForMap(C_Map.GetBestMapForUnit("player"))
    
    if activeEncounters and #activeEncounters > 0 then
        -- Si este es el encuentro con el ID más alto, probablemente es el último
        local maxEncounterID = 0
        for _, encounter in ipairs(activeEncounters) do
            if encounter.encounterID > maxEncounterID then
                maxEncounterID = encounter.encounterID
            end
        end
        
        if encounterID == maxEncounterID then
            return true
        end
    end
    
    -- Fallback conservador: asumir que podría ser el último después de 30 segundos
    C_Timer.After(30, function()
        if not dungeonCompleted then
            -- Si no se ha detectado finalización después de 30s, asumir que terminó
            HandleDungeonCompletion("Timeout - Assuming dungeon completed")
        end
    end)
    
    return false
end

-- Función para verificar manualmente si una dungeon debería considerarse completada
function CheckDungeonCompletionStatus()
    local dungeonInfo = GetCurrentDungeonInfo()
    local inInstance, instanceType = IsInInstance()
    
    print("Dungeon Completion Status:")
    print("- In Instance: " .. tostring(inInstance))
    print("- Instance Type: " .. tostring(instanceType))
    print("- Dungeon Name: " .. tostring(dungeonInfo and dungeonInfo.name or "Unknown"))
    print("- Is Key: " .. tostring(dungeonInfo and dungeonInfo.isKey or false))
    print("- In Group: " .. tostring(IsInGroup()))
    print("- Completed Flag: " .. tostring(dungeonCompleted))
    print("- Last Encounter ID: " .. tostring(lastEncounterID))
end

-- Comando para testing y debug
SLASH_DUNGEONDETECTION1 = "/ddtest"
SlashCmdList["DUNGEONDETECTION"] = function(msg)
    if msg == "status" then
        CheckDungeonCompletionStatus()
    elseif msg == "force" then
        print("Forcing dungeon completion...")
        HandleDungeonCompletion("Manual Force")
    elseif msg == "reset" then
        dungeonCompleted = false
        lastEncounterID = nil
        print("Dungeon detection state reset.")
    else
        print("Dungeon Detection Commands:")
        print("- /ddtest status - Show current status")
        print("- /ddtest force - Force open rating modal")
        print("- /ddtest reset - Reset detection state")
    end
end
