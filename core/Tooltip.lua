-- Tooltip.lua - Sistema de tooltips integrado con WoW (API moderna)
-- Responsabilidad: Mostrar información de ratings en tooltips nativos de jugadores

-- Evita doble registro si el archivo se carga más de una vez
local _G = _G
local addonNS = _G.MyFirstAddon or {}
_G.MyFirstAddon = addonNS
addonNS._tooltipHooked = addonNS._tooltipHooked or false

-- Función que añade información de ratings al tooltip nativo
local function AddRatingInfoToTooltip(tooltip)
    local _, unit = tooltip:GetUnit()
    if unit and UnitIsPlayer(unit) then
        local playerName = UnitName(unit)
        if playerName and playerName ~= "" then
            -- Añadir línea separadora
            tooltip:AddLine(" ")
            tooltip:AddLine("|cff00ff00=== Player Ratings ===|r")
            
            -- Verificar si el jugador tiene datos en la whitelist
            if WhiteListDB[playerName] then
                -- Mostrar información por rol
                local roles = {"tank", "healer", "dps"}
                local roleNames = {tank = "Tank", healer = "Healer", dps = "DPS"}
                
                for _, role in ipairs(roles) do
                    local encounters = GetLastEncounters(playerName, role, 3) -- Últimos 3 encuentros
                    
                    if #encounters > 0 then
                        local avg = GetAverageNote(encounters)
                        local color = GetRatingColor(avg)
                        
                        -- Línea del rol con promedio
                        tooltip:AddLine(string.format("|cff%s%s:|r %.1f avg", 
                            color, roleNames[role], avg))
                        
                        -- Mostrar solo el último dungeon (sin fecha)
                        local lastEncounter = encounters[1]
                        if lastEncounter and lastEncounter.dungeon and lastEncounter.difficulty then
                            local encounterColor = GetRatingColor(lastEncounter.note)
                            local dungeonInfo = string.format(" - %s (%s)", lastEncounter.dungeon, lastEncounter.difficulty)
                            tooltip:AddLine(string.format("  |cff%s%d|r%s", 
                                encounterColor, lastEncounter.note, dungeonInfo))
                        end
                    end
                end
            else
                -- Mostrar mensaje cuando no hay datos
                tooltip:AddLine("|cff888888No data available|r")
            end
            
            tooltip:Show()
        end
    end
end

-- Función para obtener color basado en rating
function GetRatingColor(rating)
    if rating >= 8 then
        return "00ff00" -- Verde (excelente)
    elseif rating >= 6 then
        return "ffff00" -- Amarillo (bueno)
    elseif rating >= 4 then
        return "ff8800" -- Naranja (regular)
    else
        return "ff0000" -- Rojo (malo)
    end
end

-- Inicializar el sistema de tooltips
function InitializeTooltipSystem()
    -- API moderna de tooltips (Dragonflight+)
    if TooltipDataProcessor and Enum and Enum.TooltipDataType then
        -- Hook para tooltips de unidades (jugadores en el mundo)
        TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Unit, function(tooltip, data)
            AddRatingInfoToTooltip(tooltip)
        end)
        
        addonNS._tooltipHooked = true
        print("DEBUG: Tooltip system initialized with modern API")
    else
        print("DEBUG: Modern tooltip API not available")
    end
end
