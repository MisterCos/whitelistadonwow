-- UI.lua - Interfaz de calificación de jugadores (versión completamente en Lua)

local playerFrames = {}
local currentGroupPlayers = {}
local mainFrame = nil

-- Función para inicializar la interfaz
function InitializeDungeonRatingUI()
    -- Crear botón de prueba
    local testButton = CreateFrame("Button", "TestDungeonEndButton", UIParent, "UIPanelButtonTemplate")
    testButton:SetSize(150, 30)
    testButton:SetPoint("TOPLEFT", 10, -10)
    testButton:SetText("Simulate Dungeon End")
    testButton:SetScript("OnClick", function()
        ShowDungeonRatingFrame()
    end)
    

end

-- Función para mostrar la modal de calificación
function ShowDungeonRatingFrame()
    -- Obtener jugadores del grupo actual (simulado para pruebas)
    currentGroupPlayers = GetCurrentGroupPlayers()
    
    -- Crear la interfaz si no existe
    if not mainFrame then
        CreateMainFrame()
    end
    
    -- Crear frames para cada jugador
    CreatePlayerFrames()
    
    -- Mostrar la modal
    mainFrame:Show()
end

-- Crear el frame principal
function CreateMainFrame()
    -- Frame principal
    mainFrame = CreateFrame("Frame", "DungeonRatingFrame", UIParent, "BackdropTemplate")
    mainFrame:SetSize(350, 320)
    mainFrame:SetPoint("CENTER")
    mainFrame:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
        tile = true,
        tileSize = 32,
        edgeSize = 32,
        insets = {left = 11, right = 12, top = 12, bottom = 11}
    })
    mainFrame:SetMovable(true)
    mainFrame:EnableMouse(true)
    mainFrame:RegisterForDrag("LeftButton")
    mainFrame:SetScript("OnDragStart", mainFrame.StartMoving)
    mainFrame:SetScript("OnDragStop", mainFrame.StopMovingOrSizing)
    mainFrame:Hide()
    
    -- Título
    local title = mainFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("TOP", 0, -15)
    title:SetText("Rate Players")
    
    -- Botón de cerrar
    local closeButton = CreateFrame("Button", nil, mainFrame, "UIPanelCloseButton")
    closeButton:SetPoint("TOPRIGHT", 2, 2)
    closeButton:SetScript("OnClick", function()
        HideRatingFrame()
    end)
    
    -- Botón de guardar
    local saveButton = CreateFrame("Button", nil, mainFrame, "UIPanelButtonTemplate")
    saveButton:SetSize(120, 25)
    saveButton:SetPoint("BOTTOM", -60, 15)
    saveButton:SetText("Save Ratings")
    saveButton:SetScript("OnClick", function()
        SaveRatings()
    end)
    
    -- Botón de cancelar
    local cancelButton = CreateFrame("Button", nil, mainFrame, "UIPanelButtonTemplate")
    cancelButton:SetSize(80, 25)
    cancelButton:SetPoint("BOTTOM", 60, 15)
    cancelButton:SetText("Cancel")
    cancelButton:SetScript("OnClick", function()
        HideRatingFrame()
    end)
    
    -- Frame para la lista de jugadores (sin scroll)
    local playerContainer = CreateFrame("Frame", nil, mainFrame)
    playerContainer:SetSize(330, 220)
    playerContainer:SetPoint("TOP", 0, -50)
    
    -- Guardar referencias
    mainFrame.playerContainer = playerContainer
    mainFrame.saveButton = saveButton
    mainFrame.cancelButton = cancelButton
    mainFrame.closeButton = closeButton
    mainFrame.title = title
end

-- Función para ocultar la modal
function HideRatingFrame()
    if mainFrame then
        mainFrame:Hide()
        ClearPlayerFrames()
    end
end

-- Esta función ahora está en GroupData.lua
-- Se mantiene aquí por compatibilidad, pero usa la del archivo GroupData.lua

-- Crear frames para cada jugador
function CreatePlayerFrames()
    ClearPlayerFrames()
    
    if not mainFrame or not mainFrame.playerContainer then
        return
    end
    
    local playerContainer = mainFrame.playerContainer
    local yOffset = 0
    
    for i, player in ipairs(currentGroupPlayers) do
        local frame = CreateFrame("Frame", "PlayerRatingFrame" .. i, playerContainer, "BackdropTemplate")
        frame:SetSize(320, 40)
        frame:SetPoint("TOPLEFT", 5, yOffset)
        
        -- Fondo del frame
        frame:SetBackdrop({
            bgFile = "Interface\\Buttons\\WHITE8x8",
            edgeFile = "Interface\\Buttons\\WHITE8x8",
            tile = true,
            tileSize = 8,
            edgeSize = 1,
        })
        frame:SetBackdropColor(0.1, 0.1, 0.1, 0.5)
        frame:SetBackdropBorderColor(0.3, 0.3, 0.3, 0.8)
        
        -- Icono de clase
        local classIcon = frame:CreateTexture(nil, "OVERLAY")
        classIcon:SetSize(16, 16)
        classIcon:SetPoint("LEFT", 10, 0)
        classIcon:SetTexture(GetClassIcon(player.class))
        frame.classIcon = classIcon
        
        -- Nombre del jugador (con color de clase)
        local nameText = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        nameText:SetPoint("LEFT", 35, 0)
        nameText:SetText(ColorizePlayerName(player.name, player.class))
        frame.name = nameText
        
        -- Icono de rol
        local roleIcon = frame:CreateTexture(nil, "OVERLAY")
        roleIcon:SetSize(20, 20)
        roleIcon:SetPoint("LEFT", 150, 0)
        
        -- Asignar icono según el rol (usando coordenadas optimizadas del sprite sheet)
        local texture, coords = GetRoleIconWithCoords(player.role)
        roleIcon:SetTexture(texture)
        roleIcon:SetTexCoord(unpack(coords))
        
        frame.role = roleIcon
        
        -- Dropdown para la nota
        local dropdown = CreateFrame("Frame", "RatingDropdown" .. i, frame, "UIDropDownMenuTemplate")
        dropdown:SetPoint("RIGHT", -10, 0)
        UIDropDownMenu_SetWidth(dropdown, 80)
        
        UIDropDownMenu_Initialize(dropdown, function(self, level)
            local info = UIDropDownMenu_CreateInfo()
            for rating = 1, 10 do
                info.text = tostring(rating)
                info.value = rating
                info.checked = (rating == player.rating)
                info.func = function()
                    UIDropDownMenu_SetSelectedValue(dropdown, rating)
                    player.rating = rating
                end
                UIDropDownMenu_AddButton(info)
            end
        end)
        
        -- Establecer valor por defecto
        player.rating = 5
        UIDropDownMenu_SetSelectedValue(dropdown, 5)
        
        frame.ratingDropdown = dropdown
        table.insert(playerFrames, frame)
        yOffset = yOffset - 45
    end
end

-- Limpiar frames de jugadores
function ClearPlayerFrames()
    for _, frame in ipairs(playerFrames) do
        frame:Hide()
        frame:SetParent(nil)
    end
    playerFrames = {}
end

-- Guardar calificaciones
function SaveRatings()
    local savedCount = 0
    
    for _, player in ipairs(currentGroupPlayers) do
        if player.rating then
            AddPlayerToWhitelist(player.name, player.rating, player.role)
            savedCount = savedCount + 1
        end
    end
    
    if savedCount > 0 then
        print("Ratings saved for " .. savedCount .. " players.")
    else
        print("No ratings were saved.")
    end
    
    HideRatingFrame()
end


