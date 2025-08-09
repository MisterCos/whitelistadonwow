-- GroupData.lua - Manejo de datos del grupo
-- Responsabilidad: Obtener información de los jugadores del grupo actual

-- Función principal para obtener jugadores del grupo
function GetCurrentGroupPlayers()
    -- Por ahora usamos la versión real, pero mantenemos la simulada comentada
    return GetRealGroupPlayers()
    
    -- Versión simulada (comentada para pruebas)
    -- return GetMockGroupPlayers()
end

-- Obtener jugadores reales del grupo actual
function GetRealGroupPlayers()
    local players = {}
    local currentPlayerName = UnitName("player")
    
    -- Si estás solo, no devolver ningún jugador (no puedes puntuarte a ti mismo)
    if not IsInGroup() then
        return players -- Lista vacía
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
        
        -- Excluir al jugador actual del listado
        if name and role and role ~= "NONE" and name ~= currentPlayerName then
            -- Mapear roles de WoW a nuestros roles
            local mappedRole = string.lower(role)
            if mappedRole == "damager" then
                mappedRole = "dps"
            end
            
            table.insert(players, {
                name = name,
                role = mappedRole,
                class = class
            })
        end
    end
    
    return players
end

-- Obtener jugadores simulados para pruebas
function GetMockGroupPlayers()
    local currentPlayerName = UnitName("player")
    local mockPlayers = {
        {name = "Jugador1", role = "dps", class = "WARRIOR"},
        {name = "Jugador2", role = "healer", class = "PRIEST"},
        {name = "Jugador3", role = "tank", class = "DEATHKNIGHT"},
        {name = "Jugador4", role = "dps", class = "MAGE"},
        {name = "Jugador5", role = "dps", class = "ROGUE"}
    }
    
    -- Filtrar al jugador actual si aparece en la lista simulada
    local filteredPlayers = {}
    for _, player in ipairs(mockPlayers) do
        if player.name ~= currentPlayerName then
            table.insert(filteredPlayers, player)
        end
    end
    
    return filteredPlayers
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
