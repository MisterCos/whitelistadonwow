-- commands.lua

--Add user to whitelist
SLASH_ADDUSER1 = "/adduser"
SlashCmdList["ADDUSER"] = function(msg)
    local playerName, note, role = msg:match("^(%S+)%s+(%S+)%s+(.+)$")
    if not playerName or not note or not role then
        print("Uso correcto: /adduser NombreJugador Nota Rol")
        return
    end

    AddPlayerToWhitelist(playerName, note, role)
    print("Jugador añadido: "..playerName.." Nota: "..note.." Rol: "..role)
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
    print("White list empty")
end


--show stats from a player
SLASH_SHOWSTATS1 = "/showstats"
SlashCmdList["SHOWSTATS"] = function(msg)
    local playerName, role = msg:match("^(%S+)%s+(%S+)$")
    if not playerName or not role then
        print("Uso: /showstats NombreJugador Rol")
        return
    end
    
    -- pasar a minusculas
    role = string.lower(role)
    local encounters = GetLastEncounters(playerName, role, 5) -- últimos 5 encuentros
    if #encounters == 0 then
        print("No hay encuentros para "..playerName.." como "..role)
        return
    end

    print("Últimos encuentros de "..playerName.." como "..role..":")
    for i, encounter in ipairs(encounters) do
        print(i..". Nota: "..encounter.note.." Fecha: "..encounter.date)
    end

    local avg = GetAverageNote(encounters)
    print("Nota media: "..string.format("%.2f", avg))
end
