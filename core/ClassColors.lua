-- ClassColors.lua - Utilidades para colores de clase
-- Responsabilidad: Manejar colores y iconos de clase

-- Colores de clase de WoW (RGB en formato 0-1)
local CLASS_COLORS = {
    ["DEATHKNIGHT"] = {r = 0.77, g = 0.12, b = 0.23},
    ["DEMONHUNTER"] = {r = 0.64, g = 0.19, b = 0.79},
    ["DRUID"] = {r = 1.00, g = 0.49, b = 0.04},
    ["EVOKER"] = {r = 0.20, g = 0.58, b = 0.50},
    ["HUNTER"] = {r = 0.67, g = 0.83, b = 0.45},
    ["MAGE"] = {r = 0.25, g = 0.78, b = 0.92},
    ["MONK"] = {r = 0.00, g = 1.00, b = 0.59},
    ["PALADIN"] = {r = 0.96, g = 0.55, b = 0.73},
    ["PRIEST"] = {r = 1.00, g = 1.00, b = 1.00},
    ["ROGUE"] = {r = 1.00, g = 0.96, b = 0.41},
    ["SHAMAN"] = {r = 0.00, g = 0.44, b = 0.87},
    ["WARLOCK"] = {r = 0.53, g = 0.53, b = 0.93},
    ["WARRIOR"] = {r = 0.78, g = 0.61, b = 0.43}
}

-- Obtener color de clase
function GetClassColor(class)
    if CLASS_COLORS[class] then
        return CLASS_COLORS[class].r, CLASS_COLORS[class].g, CLASS_COLORS[class].b
    end
    -- Color por defecto (gris) si no se encuentra la clase
    return 0.7, 0.7, 0.7
end

-- Obtener color de clase como string hexadecimal
function GetClassColorHex(class)
    local r, g, b = GetClassColor(class)
    return string.format("|cff%02x%02x%02x", r * 255, g * 255, b * 255)
end

-- Aplicar color de clase a un texto
function ColorizePlayerName(name, class)
    local colorHex = GetClassColorHex(class)
    return colorHex .. name .. "|r"
end

-- Obtener ruta del icono de clase
function GetClassIcon(class)
    local iconPaths = {
        ["DEATHKNIGHT"] = "Interface\\Icons\\ClassIcon_DeathKnight",
        ["DEMONHUNTER"] = "Interface\\Icons\\ClassIcon_DemonHunter",
        ["DRUID"] = "Interface\\Icons\\ClassIcon_Druid",
        ["EVOKER"] = "Interface\\Icons\\ClassIcon_Evoker",
        ["HUNTER"] = "Interface\\Icons\\ClassIcon_Hunter",
        ["MAGE"] = "Interface\\Icons\\ClassIcon_Mage",
        ["MONK"] = "Interface\\Icons\\ClassIcon_Monk",
        ["PALADIN"] = "Interface\\Icons\\ClassIcon_Paladin",
        ["PRIEST"] = "Interface\\Icons\\ClassIcon_Priest",
        ["ROGUE"] = "Interface\\Icons\\ClassIcon_Rogue",
        ["SHAMAN"] = "Interface\\Icons\\ClassIcon_Shaman",
        ["WARLOCK"] = "Interface\\Icons\\ClassIcon_Warlock",
        ["WARRIOR"] = "Interface\\Icons\\ClassIcon_Warrior"
    }
    
    return iconPaths[class] or "Interface\\Icons\\INV_Misc_QuestionMark"
end

-- Obtener nombre de clase en español
function GetClassDisplayName(class)
    local classNames = {
        ["DEATHKNIGHT"] = "Caballero de la Muerte",
        ["DEMONHUNTER"] = "Cazador de Demonios",
        ["DRUID"] = "Druida",
        ["EVOKER"] = "Evocador",
        ["HUNTER"] = "Cazador",
        ["MAGE"] = "Mago",
        ["MONK"] = "Monje",
        ["PALADIN"] = "Paladín",
        ["PRIEST"] = "Sacerdote",
        ["ROGUE"] = "Pícaro",
        ["SHAMAN"] = "Chamán",
        ["WARLOCK"] = "Brujo",
        ["WARRIOR"] = "Guerrero"
    }
    
    return classNames[class] or class
end

-- Obtener icono de rol usando iconos individuales de alta resolución
function GetRoleIcon(role)
    local iconPaths = {
        ["tank"] = "Interface\\LFGFrame\\UI-LFG-ICON-ROLES",      -- Textura con iconos individuales
        ["healer"] = "Interface\\LFGFrame\\UI-LFG-ICON-ROLES",    -- Textura con iconos individuales
        ["dps"] = "Interface\\LFGFrame\\UI-LFG-ICON-ROLES"        -- Textura con iconos individuales
    }
    
    local coords = {
        ["tank"] = {0, 0.5, 0, 0.5},         -- Escudo (esquina superior izquierda)
        ["healer"] = {0.5, 1, 0, 0.5},       -- Cruz (esquina superior derecha)
        ["dps"] = {0, 0.5, 0.5, 1}           -- Espada (esquina inferior izquierda)
    }
    
    return iconPaths[role] or iconPaths["dps"], coords[role] or coords["dps"]
end

-- Función para usar coordenadas optimizadas basadas en el sprite sheet
function GetRoleIconWithCoords(role)
    local texture = "Interface\\LFGFrame\\LFGRole"
    local coords = {
        ["tank"] = {0.5, 0.75, 0, 1},              -- Tank (icono 6)
        ["healer"] = {0.75, 1, 0, 1},              -- Healer (icono 3)
        ["dps"] = {0.25, 0.5, 0, 1}                -- DPS (icono 5)
    }
    
    return texture, coords[role] or coords["dps"]
end
