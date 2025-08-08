


-- crearmos fichero sino exsite 
WhiteListDB = WhiteListDB or {}

local frame = CreateFrame("Frame")
frame:RegisterEvent("PLAYER_LOGIN")
frame:SetScript("OnEvent", function(self, event)
    printWhiteList()
    -- Inicializar la interfaz de calificación
    InitializeDungeonRatingUI()
end)






