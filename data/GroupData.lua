-- GroupData.lua - Manejo de datos del grupo
-- Responsabilidad: Obtener información de los jugadores del grupo actual

-- Función principal para obtener jugadores del grupo
function GetCurrentGroupPlayers()
    -- Por ahora usamos la versión real, pero mantenemos la simulada comentada
    -- return GetRealGroupPlayers()
    
    -- Versión simulada (comentada para pruebas)
    return GetMockGroupPlayers()
end

-- Obtener jugadores reales del grupo actual
function GetRealGroupPlayers()
    local players = {}
    
    -- Si estás solo
    if not IsInGroup() then
        local playerName = UnitName("player")
        local playerRole = UnitGroupRolesAssigned("player")
        local playerClass = select(2, UnitClass("player"))
        
        if playerRole == "NONE" then
            -- Determinar rol por especialización
            local spec = GetSpecialization()
            if spec then
                local _, _, _, _, role = GetSpecializationInfo(spec)
                playerRole = role
            end
        end
        
        table.insert(players, {
            name = playerName,
            role = string.lower(playerRole or "dps"),
            class = playerClass
        })
        return players
    end
    
    -- Si estás en grupo
    local groupSize = GetNumGroupMembers()
    for i = 1, groupSize do
        local unit = "party" .. i
        if i == groupSize then
            unit = "player"  -- El último es siempre el jugador
        end
        
        local name = UnitName(unit)
        local role = UnitGroupRolesAssigned(unit)
        local class = select(2, UnitClass(unit))
        
        if name and role and role ~= "NONE" then
            table.insert(players, {
                name = name,
                role = string.lower(role),
                class = class
            })
        end
    end
    
    return players
end

-- Obtener jugadores simulados para pruebas
function GetMockGroupPlayers()
    return {
        {name = "Jugador1", role = "dps", class = "WARRIOR"},
        {name = "Jugador2", role = "healer", class = "PRIEST"},
        {name = "Jugador3", role = "tank", class = "DEATHKNIGHT"},
        {name = "Jugador4", role = "dps", class = "MAGE"},
        {name = "Jugador5", role = "dps", class = "ROGUE"}
    }
end

-- Función auxiliar para obtener información del grupo
function GetGroupInfo()
    local info = {
        inGroup = IsInGroup(),
        inRaid = IsInRaid(),
        groupSize = GetNumGroupMembers(),
        playerName = UnitName("player"),
        playerRole = UnitGroupRolesAssigned("player")
    }
    
    return info
end

-- Función para verificar si un jugador está en el grupo actual
function IsPlayerInCurrentGroup(playerName)
    local players = GetCurrentGroupPlayers()
    
    for _, player in ipairs(players) do
        if player.name == playerName then
            return true
        end
    end
    
    return false
end
