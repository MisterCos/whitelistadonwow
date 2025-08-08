


-- Main.lua - Punto de entrada principal del addon
-- Responsabilidad: Inicialización básica y coordinación de sistemas

-- Crear base de datos si no existe
WhiteListDB = WhiteListDB or {}

local frame = CreateFrame("Frame")
frame:RegisterEvent("PLAYER_LOGIN")

frame:SetScript("OnEvent", function(self, event)
    if event == "PLAYER_LOGIN" then
        -- Inicializar todos los sistemas
        PrintWhiteList()
        InitializeDungeonRatingUI()
        InitializeTooltipSystem()
        InitializeLFGTooltipSystem()
        
        print("DEBUG: MyFirstAddon initialized successfully")
    end
end)






