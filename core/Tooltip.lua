-- Tooltip.lua - Sistema de tooltips personalizados
-- Responsabilidad: Mostrar información de ratings en tooltips de jugadores

local tooltipFrame = nil
local customTooltip = nil
local lastProcessedUnit = nil

-- Inicializar el sistema de tooltips
function InitializeTooltipSystem()
    -- Crear frame para manejar eventos
    tooltipFrame = CreateFrame("Frame")
    tooltipFrame:RegisterEvent("UPDATE_MOUSEOVER_UNIT")
    
    tooltipFrame:SetScript("OnEvent", function(self, event, ...)
        if event == "UPDATE_MOUSEOVER_UNIT" then
            OnMouseOverUnit()
        end
    end)
    
    -- Crear nuestro tooltip personalizado
    CreateCustomTooltip()
    
    -- Timer para ocultar el tooltip cuando no hay mouseover
    C_Timer.NewTicker(0.1, function()
        if not UnitExists("mouseover") then
            HideCustomTooltip()
        end
    end)
end

-- Crear nuestro tooltip personalizado
function CreateCustomTooltip()
    -- Crear un frame simple en lugar de GameTooltip
    customTooltip = CreateFrame("Frame", "MyFirstAddonTooltip", UIParent)
    customTooltip:SetSize(300, 200) -- Aumentado para más información
    customTooltip:SetFrameStrata("TOOLTIP")
    
    -- Crear fondo con textura
    local background = customTooltip:CreateTexture(nil, "BACKGROUND")
    background:SetAllPoints()
    background:SetColorTexture(0, 0, 0, 0.9)
    
    -- Crear borde
    local border = customTooltip:CreateTexture(nil, "BORDER")
    border:SetAllPoints()
    border:SetColorTexture(0.5, 0.5, 0.5, 0.8)
    border:SetTexCoord(0, 1, 0, 1)
    
    -- Crear texto
    local textFrame = customTooltip:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    textFrame:SetPoint("TOPLEFT", 10, -10)
    textFrame:SetPoint("BOTTOMRIGHT", -10, 10)
    textFrame:SetJustifyH("LEFT")
    textFrame:SetJustifyV("TOP")
    textFrame:SetTextColor(1, 1, 1, 1) -- Texto blanco
    
    -- Asignar el texto al frame
    customTooltip.text = textFrame
    
    -- Debug: verificar que se creó correctamente
    print("DEBUG: Custom tooltip created successfully")
    print("DEBUG: Text frame created: " .. tostring(customTooltip.text))
end

-- Función llamada cuando el ratón pasa sobre una unidad
function OnMouseOverUnit()
    local unit = "mouseover"
    if not UnitExists(unit) then 
        HideCustomTooltip()
        return 
    end
    
    local playerName = UnitName(unit)
    if not playerName then 
        HideCustomTooltip()
        return 
    end
    
    -- Evitar procesar la misma unidad múltiples veces
    if lastProcessedUnit == playerName then return end
    lastProcessedUnit = playerName
    
    print("DEBUG: Processing tooltip for: " .. playerName)
    
    -- Mostrar nuestro tooltip personalizado
    ShowCustomTooltip(playerName)
end

-- Mostrar nuestro tooltip personalizado
function ShowCustomTooltip(playerName)
    if not customTooltip then 
        print("DEBUG: Custom tooltip is nil!")
        return 
    end
    
    if not customTooltip.text then
        print("DEBUG: Custom tooltip.text is nil!")
        return
    end
    
    print("DEBUG: Showing tooltip for: " .. playerName)
    
    -- Construir texto del tooltip
    local tooltipText = "|cff00ff00Ratings|r\n\n"
    tooltipText = tooltipText .. "Player: " .. playerName .. "\n"
    
    -- Añadir información de ratings
    local ratingText = GetRatingInfoText(playerName)
    tooltipText = tooltipText .. ratingText
    
    print("DEBUG: Full tooltip text:")
    print(tooltipText)
    
    -- Establecer el texto
    customTooltip.text:SetText(tooltipText)
    
    -- Debug: verificar que el texto se estableció
    print("DEBUG: Text set to tooltip")
    print("DEBUG: Tooltip text content: " .. customTooltip.text:GetText())
    
    -- Posicionar el tooltip al lado del GameTooltip
    local gameTooltip = GameTooltip
    local x, y, scale
    
    if gameTooltip:IsVisible() then
        -- Si el GameTooltip está visible, posicionar nuestro tooltip a la derecha
        local gameTooltipPoint, _, gameTooltipRelativePoint, gameTooltipX, gameTooltipY = gameTooltip:GetPoint()
        local gameTooltipWidth = gameTooltip:GetWidth()
        
        -- Posicionar nuestro tooltip a la derecha del GameTooltip
        customTooltip:SetPoint("TOPLEFT", gameTooltip, "TOPRIGHT", 5, 0)
        
        -- Para debug, obtener posición del cursor
        x, y = GetCursorPosition()
        scale = UIParent:GetEffectiveScale()
    else
        -- Si no hay GameTooltip, posicionar cerca del cursor
        x, y = GetCursorPosition()
        scale = UIParent:GetEffectiveScale()
        customTooltip:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", x/scale + 10, y/scale + 10)
    end
    
    -- Mostrar el tooltip
    customTooltip:Show()
    
    print("DEBUG: Tooltip should be visible now")
    print("DEBUG: Tooltip is visible: " .. tostring(customTooltip:IsVisible()))
    print("DEBUG: Tooltip position: " .. x/scale .. ", " .. y/scale)
end

-- Ocultar nuestro tooltip personalizado
function HideCustomTooltip()
    if customTooltip then
        customTooltip:Hide()
    end
    lastProcessedUnit = nil
end

-- Función para obtener texto de información de ratings
function GetRatingInfoText(playerName)
    print("DEBUG: GetRatingInfoText called for: " .. playerName)
    
    -- Verificar si el jugador está en nuestra whitelist
    if not WhiteListDB[playerName] then
        print("DEBUG: Player not found in WhiteListDB")
        return "|cff888888No rating data available|r"
    end
    
    print("DEBUG: Player found in WhiteListDB")
    local text = "\n"
    
    -- Mostrar información por rol
    local roles = {"tank", "healer", "dps"}
    local roleNames = {tank = "Tank", healer = "Healer", dps = "DPS"}
    
    for _, role in ipairs(roles) do
        print("DEBUG: Checking role: " .. role)
        local encounters = GetLastEncounters(playerName, role, 5) -- Últimos 5 encuentros
        print("DEBUG: Found " .. #encounters .. " encounters for role " .. role)
        
        if #encounters > 0 then
            local avg = GetAverageNote(encounters)
            local color = GetRatingColor(avg)
            
            text = text .. string.format("|cff%s%s:|r %.1f avg\n", 
                color, roleNames[role], avg)
            
            -- Mostrar las últimas 5 dungeons con sus notas
            for i, encounter in ipairs(encounters) do
                local encounterColor = GetRatingColor(encounter.note)
                local dungeonInfo = ""
                
                if encounter.dungeon and encounter.difficulty then
                    dungeonInfo = string.format(" - %s (%s)", encounter.dungeon, encounter.difficulty)
                end
                
                text = text .. string.format("  |cff%s%d|r%s\n", 
                    encounterColor, encounter.note, dungeonInfo)
            end
            
            text = text .. "\n" -- Espacio entre roles
        end
    end
    
    print("DEBUG: Final text length: " .. string.len(text))
    return text
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
