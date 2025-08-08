


-- crearmos fichero sino exsite 
WhiteListDB = WhiteListDB or {}

local frame = CreateFrame("Frame")
frame:RegisterEvent("PLAYER_LOGIN")
frame:SetScript("OnEvent", function(self, event)
    PrintWhiteList()
    -- Inicializar la interfaz de calificación
    InitializeDungeonRatingUI()
    -- Inicializar el sistema de tooltips
    InitializeTooltipSystem()
end)






