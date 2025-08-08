-- whitelist.lua

-- TODO: we have to add the rest of the information to the whitelist
function AddPlayerToWhitelist(playerName,note,role)
   -- Inicializar jugador si no existe
   if not WhiteListDB[playerName] then
        WhiteListDB[playerName] = { dps = {}, healer = {}, tank = {} }
    end

    -- Normalizar el rol a minúsculas
    role = string.lower(role)

    -- Validar rol
    if not WhiteListDB[playerName][role] then
                        print("Invalid role: "..role)
        return
    end

    -- Crear el nuevo encuentro
    local newEncounter = {
        date = date("%d/%m/%Y %H:%M:%S"),
        note = note
    }

    -- Añadir el encuentro al final del array
    table.insert(WhiteListDB[playerName][role], newEncounter)

    -- Ordenar por fecha (más reciente primero) para mantener el orden
    table.sort(WhiteListDB[playerName][role], function(a, b)
        return a.date > b.date -- Orden descendente (más reciente primero)
    end)

            print("Encounter added for "..playerName.." - Role: "..role.." Rating: "..note)
end


function removeWhiteList()
    WhiteListDB = {}
end


function printWhiteList()
    for playerName, roles in pairs(WhiteListDB) do
        print("Player: "..playerName)
        for role, encounters in pairs(roles) do
            print("  Role: "..role)
            for i, encounter in ipairs(encounters) do
                print(string.format("    %d - Date: %s, Rating: %d",
                    i, encounter.date, encounter.note))
            end
        end
    end
end

-- Devuelve los últimos 'count' encuentros para un jugador y rol
-- Los datos ya están ordenados por fecha (más reciente primero)
function GetLastEncounters(playerName, role, count)
    local encounters = {}
    
    -- Verificar si el jugador y rol existen
    if not WhiteListDB[playerName] then
        return encounters
    end
    
    if not WhiteListDB[playerName][role] then
        return encounters
    end
    
    local roleEncounters = WhiteListDB[playerName][role]
    local totalEncounters = #roleEncounters
    
    -- Si no hay encuentros, devolver array vacío
    if totalEncounters == 0 then
        return encounters
    end
    
    -- Como los datos están ordenados (más reciente primero), 
    -- solo necesitamos tomar los primeros 'count' elementos
    local maxCount = math.min(count, totalEncounters)
    for i = 1, maxCount do
        table.insert(encounters, roleEncounters[i])
    end
    
    return encounters
end

-- Calcula la media de nota de un array de encuentros
function GetAverageNote(encounters)
    local total = 0
    local count = #encounters
    if count == 0 then return nil end
    for _, encounter in ipairs(encounters) do
        total = total + tonumber(encounter.note)
    end
    return total / count
end