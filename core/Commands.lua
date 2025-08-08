-- commands.lua

--Add user to whitelist
SLASH_ADDUSER1 = "/adduser"
SlashCmdList["ADDUSER"] = function(msg)
    local playerName, note, role = msg:match("^(%S+)%s+(%S+)%s+(.+)$")
    if not playerName or not note or not role then
            print("Correct usage: /adduser PlayerName Rating Role")
        return
    end

    -- Obtener información de la dungeon actual (o mock si no estamos en una)
    local dungeonInfo = GetCurrentDungeonInfo()
    
    AddPlayerToWhitelist(playerName, note, role, dungeonInfo)
    local dungeonText = string.format(" - %s (%s)", dungeonInfo.name, dungeonInfo.difficulty)
    print("Player added: "..playerName.." Rating: "..note.." Role: "..role..dungeonText)
end

-- print white list
SLASH_PRINTWHITELIST1 = "/printwhitelist"
SlashCmdList["PRINTWHITELIST"] = function(msg)
    PrintWhiteList()
end

-- empty white list
SLASH_EMPTYWHITELIST1 = "/emptywhitelist"
SlashCmdList["EMPTYWHITELIST"] = function(msg)
    RemoveWhiteList()
            print("Whitelist is empty")
end


--show stats from a player
SLASH_SHOWSTATS1 = "/showstats"
SlashCmdList["SHOWSTATS"] = function(msg)
    local playerName, role = msg:match("^(%S+)%s+(%S+)$")
    if not playerName or not role then
        print("Usage: /showstats PlayerName Role")
        return
    end
    
    -- pasar a minusculas
    role = string.lower(role)
    local encounters = GetLastEncounters(playerName, role, 5) -- últimos 5 encuentros
    if #encounters == 0 then
        print("No encounters found for "..playerName.." as "..role)
        return
    end

            print("Latest encounters for "..playerName.." as "..role..":")
    for i, encounter in ipairs(encounters) do
        local dungeonText = ""
        if encounter.dungeon and encounter.difficulty then
            dungeonText = string.format(" - %s (%s)", encounter.dungeon, encounter.difficulty)
        end
        print(i..". Rating: "..encounter.note.." Date: "..encounter.date..dungeonText)
    end

    local avg = GetAverageNote(encounters)
            print("Average rating: "..string.format("%.2f", avg))
end
