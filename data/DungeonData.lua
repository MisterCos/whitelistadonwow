-- DungeonData.lua - Manejo de información de dungeons y keys
-- Responsabilidad: Obtener información de la dungeon actual y dificultad de key

-- Función principal para obtener información de la dungeon actual
function GetCurrentDungeonInfo()
    -- Por ahora usamos la versión mock, pero mantenemos la real comentada
    -- return GetMockDungeonInfo()
    
    -- Versión real (comentada para pruebas)
    return GetRealDungeonInfo()
end

-- Obtener información real de la dungeon actual
function GetRealDungeonInfo()
    local dungeonInfo = {
        name = "Unknown",
        keyLevel = 0,
        difficulty = "Unknown",
        isKey = false
    }
    
    -- Verificar si estamos en una dungeon
    local inInstance, instanceType = IsInInstance()
    if not inInstance or instanceType ~= "party" then
        return dungeonInfo
    end
    
    -- Obtener información de la instancia actual
    local mapID = C_Map.GetBestMapForUnit("player")
    if mapID then
        local mapInfo = C_Map.GetMapInfo(mapID)
        if mapInfo then
            dungeonInfo.name = mapInfo.name or "Unknown"
        end
    end
    
    -- Verificar si es una key de mythic+ usando la API moderna
    if C_ChallengeMode then
        -- API moderna: GetActiveKeystoneInfo() devuelve un número (el nivel) o nil
        local keyLevel = C_ChallengeMode.GetActiveKeystoneInfo()
        if keyLevel and keyLevel > 0 then
            dungeonInfo.isKey = true
            dungeonInfo.keyLevel = keyLevel
            dungeonInfo.difficulty = "Mythic+ " .. keyLevel
        end
    end
    
    -- Si no es key, determinar la dificultad
    if not dungeonInfo.isKey then
        local difficulty = select(3, GetInstanceInfo())
        if difficulty then
            local difficultyNames = {
                [1] = "Normal",
                [2] = "Heroic",
                [8] = "Mythic",
                [23] = "Mythic+"
            }
            dungeonInfo.difficulty = difficultyNames[difficulty] or "Unknown"
        end
    end
    
    return dungeonInfo
end

-- Obtener información simulada de dungeon para pruebas
function GetMockDungeonInfo()
    -- Simular diferentes dungeons para pruebas
    local mockDungeons = {
        {
            name = "Black Rook Hold",
            keyLevel = 15,
            difficulty = "Mythic+ 15",
            isKey = true
        },
        {
            name = "Halls of Valor",
            keyLevel = 12,
            difficulty = "Mythic+ 12",
            isKey = true
        },
        {
            name = "Neltharion's Lair",
            keyLevel = 18,
            difficulty = "Mythic+ 18",
            isKey = true
        },
        {
            name = "Vault of the Wardens",
            keyLevel = 0,
            difficulty = "Heroic",
            isKey = false
        },
        {
            name = "Eye of Azshara",
            keyLevel = 0,
            difficulty = "Normal",
            isKey = false
        }
    }
    
    -- Seleccionar una dungeon aleatoria para la simulación
    local randomIndex = math.random(1, #mockDungeons)
    return mockDungeons[randomIndex]
end

-- Función para obtener el nombre de la dungeon actual
function GetCurrentDungeonName()
    local dungeonInfo = GetCurrentDungeonInfo()
    return dungeonInfo.name
end

-- Función para obtener la dificultad de la key actual
function GetCurrentKeyDifficulty()
    local dungeonInfo = GetCurrentDungeonInfo()
    return dungeonInfo.difficulty
end

-- Función para verificar si estamos en una key de mythic+
function IsInMythicPlusKey()
    local dungeonInfo = GetCurrentDungeonInfo()
    return dungeonInfo.isKey
end

-- Función para obtener el nivel de la key
function GetCurrentKeyLevel()
    local dungeonInfo = GetCurrentDungeonInfo()
    return dungeonInfo.keyLevel
end

-- Función para formatear la información de dungeon para mostrar
function FormatDungeonInfo()
    local dungeonInfo = GetCurrentDungeonInfo()
    
    if dungeonInfo.isKey then
        return string.format("%s (%s)", dungeonInfo.name, dungeonInfo.difficulty)
    else
        return string.format("%s (%s)", dungeonInfo.name, dungeonInfo.difficulty)
    end
end
