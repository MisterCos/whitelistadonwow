-- LFGTooltips.lua - Sistema de tooltips para el buscador de grupos
-- Responsabilidad: Mostrar información de ratings en tooltips del buscador de grupos (LFG)

local frame = CreateFrame("Frame")
local isInitialized = false

-- Inicializar el sistema de tooltips para LFG
function InitializeLFGTooltipSystem()
    -- Registrar evento para cuando se carga la interfaz de LFG
    frame:RegisterEvent("ADDON_LOADED")
    frame:RegisterEvent("LFG_LIST_SEARCH_RESULTS_RECEIVED")
    frame:RegisterEvent("LFG_LIST_APPLICANT_LIST_UPDATED")
    
    frame:SetScript("OnEvent", function(self, event, ...)
        if event == "ADDON_LOADED" then
            local addonName = ...
            if addonName == "Blizzard_LookingForGroupUI" then
                C_Timer.After(1, function()
                    HookLFGTooltips()
                end)
            end
        elseif event == "LFG_LIST_SEARCH_RESULTS_RECEIVED" then
            C_Timer.After(0.5, function()
                HookLFGSearchResultTooltips()
            end)
        elseif event == "LFG_LIST_APPLICANT_LIST_UPDATED" then
            C_Timer.After(0.5, function()
                HookLFGApplicantTooltips()
            end)
        end
    end)
    
    -- Si la interfaz ya está cargada, hookear inmediatamente
    if C_AddOns.IsAddOnLoaded("Blizzard_LookingForGroupUI") then
        HookLFGTooltips()
    end
end

-- Hook principal para todos los tooltips de LFG
function HookLFGTooltips()
    HookLFGSearchResultTooltips()
    HookLFGApplicantTooltips()
    isInitialized = true
end

-- Hook para tooltips de grupos en la lista de búsqueda
function HookLFGSearchResultTooltips()
    if not LFGListFrame or not LFGListFrame.SearchPanel then
        return
    end
    
    local searchPanel = LFGListFrame.SearchPanel
    
    -- Buscar la estructura moderna de la interfaz
    local scrollFrame = searchPanel.ScrollFrame or searchPanel.results or searchPanel.ResultsScrollFrame
    if not scrollFrame then
        return
    end
    
    -- Buscar botones de diferentes maneras
    local buttons = scrollFrame.buttons or scrollFrame.Buttons or {}
    if #buttons == 0 and scrollFrame.scrollChild then
        -- Buscar en scrollChild
        for i = 1, 20 do
            local button = scrollFrame.scrollChild["Button" .. i] or _G["LFGListSearchPanelScrollFrameButton" .. i]
            if button then
                table.insert(buttons, button)
            end
        end
    end
    
    if #buttons == 0 then
        -- Método alternativo: buscar todos los frames hijos
        HookLFGFramesRecursive(searchPanel, "search")
        return
    end
    
    for i, button in ipairs(buttons) do
        if button and button.HasScript and button:HasScript("OnEnter") and not button._ratingTooltipHooked then
            button:HookScript("OnEnter", function(self)
                local resultID = self.resultID
                if resultID then
                    local searchResultInfo = C_LFGList.GetSearchResultInfo(resultID)
                    if searchResultInfo and searchResultInfo.leaderName then
                        ShowLFGPlayerTooltip(searchResultInfo.leaderName, self)
                    end
                end
            end)
            
            button:HookScript("OnLeave", function(self)
                GameTooltip:Hide()
            end)
            
            button._ratingTooltipHooked = true
        end
    end
end

-- Hook para tooltips de aplicantes
function HookLFGApplicantTooltips()
    if not LFGListFrame or not LFGListFrame.ApplicationViewer then
        return
    end
    
    local appViewer = LFGListFrame.ApplicationViewer
    
    -- Buscar la estructura moderna de la interfaz
    local scrollFrame = appViewer.ScrollFrame or appViewer.applicants or appViewer.ApplicantsScrollFrame
    if not scrollFrame then
        return
    end
    
    -- Buscar botones de diferentes maneras
    local buttons = scrollFrame.buttons or scrollFrame.Buttons or {}
    if #buttons == 0 and scrollFrame.scrollChild then
        -- Buscar en scrollChild
        for i = 1, 20 do
            local button = scrollFrame.scrollChild["Button" .. i] or _G["LFGListApplicationViewerScrollFrameButton" .. i]
            if button then
                table.insert(buttons, button)
            end
        end
    end
    
    if #buttons == 0 then
        -- Método alternativo: buscar todos los frames hijos
        HookLFGFramesRecursive(appViewer, "applicant")
        return
    end
    
    for i, button in ipairs(buttons) do
        if button and button.HasScript and button:HasScript("OnEnter") and not button._ratingTooltipHooked then
            button:HookScript("OnEnter", function(self)
                local applicantID = self.applicantID
                if applicantID then
                    local applicantInfo = C_LFGList.GetApplicantInfo(applicantID)
                    if applicantInfo and applicantInfo.name then
                        ShowLFGPlayerTooltip(applicantInfo.name, self)
                    end
                end
            end)
            
            button:HookScript("OnLeave", function(self)
                GameTooltip:Hide()
            end)
            
            button._ratingTooltipHooked = true
        end
    end
end

-- Método recursivo para encontrar y hookear frames
function HookLFGFramesRecursive(parentFrame, type)
    if not parentFrame then return end
    
    local regions = {parentFrame:GetRegions()}
    local children = {parentFrame:GetChildren()}
    
    -- Combinar regiones y frames hijos
    local allFrames = {}
    for _, region in ipairs(regions) do
        table.insert(allFrames, region)
    end
    for _, child in ipairs(children) do
        table.insert(allFrames, child)
    end
    
    for _, frame in ipairs(allFrames) do
        if frame and frame.HasScript and frame:HasScript("OnEnter") then
            local frameName = frame:GetName() or "unnamed"
            
            -- Buscar frames que parezcan botones de LFG
            if string.find(frameName:lower(), "button") or 
               string.find(frameName:lower(), "result") or
               string.find(frameName:lower(), "applicant") or
               frame:GetObjectType() == "Button" then
                
                if not frame._ratingTooltipHooked then
                    frame:HookScript("OnEnter", function(self)
                        -- Intentar extraer información del frame
                        local playerName = ExtractPlayerNameFromFrame(self, type)
                        if playerName then
                            ShowLFGPlayerTooltip(playerName, self)
                        end
                    end)
                    
                    frame:HookScript("OnLeave", function(self)
                        GameTooltip:Hide()
                    end)
                    
                    frame._ratingTooltipHooked = true
                end
            end
        end
        
        -- Recursión en frames hijos
        if frame and frame.GetChildren then
            HookLFGFramesRecursive(frame, type)
        end
    end
end

-- Función para extraer nombre de jugador de un frame
function ExtractPlayerNameFromFrame(frame, type)
    -- Intentar diferentes métodos para obtener el nombre
    
    -- Método 1: Propiedades directas
    if frame.resultID then
        local searchResultInfo = C_LFGList.GetSearchResultInfo(frame.resultID)
        if searchResultInfo and searchResultInfo.leaderName then
            return searchResultInfo.leaderName
        end
    end
    
    if frame.applicantID then
        local applicantInfo = C_LFGList.GetApplicantInfo(frame.applicantID)
        if applicantInfo and applicantInfo.name then
            return applicantInfo.name
        end
    end
    
    -- Método 2: Buscar en texto de regiones
    local regions = {frame:GetRegions()}
    for _, region in ipairs(regions) do
        if region and region:GetObjectType() == "FontString" then
            local text = region:GetText()
            if text and text ~= "" and string.len(text) > 2 and string.len(text) < 20 then
                -- Verificar que parece un nombre de jugador (no contiene números extraños)
                if not string.find(text, "%d%d") and not string.find(text, "%-") then
                    return text
                end
            end
        end
    end
    
    return nil
end

-- Mostrar tooltip personalizado para jugadores en LFG
function ShowLFGPlayerTooltip(playerName, frame)
    if not playerName or playerName == "" then 
        return 
    end
    
    -- ESPERAR un poco para que el tooltip original se muestre primero
    C_Timer.After(0.1, function()
        -- Si el tooltip está visible, añadir nuestras líneas
        if GameTooltip:IsVisible() then
            
            -- Añadir información de ratings
            GameTooltip:AddLine(" ")
            GameTooltip:AddLine("|cff00ff00=== Player Ratings ===|r")
            
            -- Verificar si el jugador tiene datos en la whitelist
            if WhiteListDB[playerName] then
                
                -- Mostrar información por rol
                local roles = {"tank", "healer", "dps"}
                local roleNames = {tank = "Tank", healer = "Healer", dps = "DPS"}
                
                local hasData = false
                for _, role in ipairs(roles) do
                    local encounters = GetLastEncounters(playerName, role, 3)
                    
                    if #encounters > 0 then
                        hasData = true
                        local avg = GetAverageNote(encounters)
                        local color = GetRatingColor(avg)
                        
                        -- Línea del rol con promedio
                        GameTooltip:AddLine(string.format("|cff%s%s:|r %.1f avg", 
                            color, roleNames[role], avg))
                        
                        -- Mostrar solo el último dungeon
                        local lastEncounter = encounters[1]
                        if lastEncounter and lastEncounter.dungeon and lastEncounter.difficulty then
                            local encounterColor = GetRatingColor(lastEncounter.note)
                            local dungeonInfo = string.format(" - %s (%s)", lastEncounter.dungeon, lastEncounter.difficulty)
                            GameTooltip:AddLine(string.format("  |cff%s%d|r%s", 
                                encounterColor, lastEncounter.note, dungeonInfo))
                        end
                    end
                end
                
                if not hasData then
                    GameTooltip:AddLine("|cff888888Player in database but no ratings yet|r")
                end
            else
                -- Mostrar mensaje cuando no hay datos
                GameTooltip:AddLine("|cff888888No rating data available|r")
            end
            
            -- Actualizar el tooltip
            GameTooltip:Show()
        end
    end)
end

-- Comando para testear el sistema
SLASH_LFGTOOLTIPTEST1 = "/lfgtest"
SlashCmdList["LFGTOOLTIPTEST"] = function(msg)
    print("LFG Tooltip System Status:")
    print("- Initialized: " .. tostring(isInitialized))
    print("- LFGListFrame exists: " .. tostring(LFGListFrame ~= nil))
    
    if LFGListFrame then
        print("- SearchPanel exists: " .. tostring(LFGListFrame.SearchPanel ~= nil))
        print("- ApplicationViewer exists: " .. tostring(LFGListFrame.ApplicationViewer ~= nil))
    end
    
    if msg and msg ~= "" then
        print("Testing tooltip for player: " .. msg)
        ShowLFGPlayerTooltip(msg, UIParent)
    end
end
