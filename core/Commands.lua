-- commands.lua

--Add user to whitelist
SLASH_ADDUSER1 = "/adduser"
SlashCmdList["ADDUSER"] = function(msg)
    local playerName, note, role = msg:match("^(%S+)%s+(%S+)%s+(.+)$")
    if not playerName or not note or not role then
                        print("Correct usage: /adduser PlayerName Rating Role")
        return
    end

    AddPlayerToWhitelist(playerName, note, role)
            print("Player added: "..playerName.." Rating: "..note.." Role: "..role)
end

-- print white list
SLASH_PRINTWHITELIST1 = "/printwhitelist"
SlashCmdList["PRINTWHITELIST"] = function(msg)
    printWhiteList()
end

-- empty white list
SLASH_EMPTYWHITELIST1 = "/emptywhitelist"
SlashCmdList["EMPTYWHITELIST"] = function(msg)
    removeWhiteList()
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
        print(i..". Rating: "..encounter.note.." Date: "..encounter.date)
    end

    local avg = GetAverageNote(encounters)
            print("Average rating: "..string.format("%.2f", avg))
end
