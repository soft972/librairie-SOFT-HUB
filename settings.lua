-- ================================================================
-- SoroniceLib_Settings.lua  (v2)
-- Module séparé : page Paramètres ⚙️
-- Nouveautés :
--   • Sauvegarde / Chargement des paramètres (writefile/readfile)
--   • Bouton "Paramètres prédéfinis" (reset + oblige à re-sauvegarder)
--   • Bouton mobile activable depuis PC
--   • Correctif resize : ContentContainer utilise déjà UDim2 relatif
--   • Section "Apparence prédéfinie" (valeurs par défaut définies ici)
-- ================================================================

return function(Ctx)
    local Settings         = Ctx.Settings
    local TweenService     = Ctx.TweenService
    local CreateElement    = Ctx.CreateElement
    local SettingsPage     = Ctx.SettingsPage
    local IsMobile         = Ctx.IsMobile
    local MainFrame        = Ctx.MainFrame
    local MainCorner       = Ctx.MainCorner
    local MainStroke       = Ctx.MainStroke
    local AlwaysVisible    = Ctx.AlwaysVisible      -- {value=bool}
    local ForceShow        = Ctx.ForceShow
    local StartMulticolor  = Ctx.StartMulticolor
    local StopMulticolor   = Ctx.StopMulticolor
    local antiAfkActive    = Ctx.antiAfkActive      -- {value=bool}
    local TargetSize       = Ctx.TargetSize
    local MobileOpenBtn    = Ctx.MobileOpenBtn
    local ToggleVisibility = Ctx.ToggleVisibility

    -- ============================================================
    -- PARAMÈTRES PRÉDÉFINIS (valeurs par défaut)
    -- C'est ici que le développeur définit les réglages initiaux.
    -- L'image prédéfinie n'est PAS modifiable depuis les paramètres.
    -- ============================================================
    local DEFAULTS = {
        BgTransparency   = 0.2,
        SquareCorners    = false,
        WindowWidth      = math.floor(TargetSize.X.Offset),
        WindowHeight     = math.floor(TargetSize.Y.Offset),
        StrokeEnabled    = true,
        StrokeRainbow    = false,
        StrokeColorR     = 200,   -- Rouge sang (prédéfini)
        StrokeColorG     = 0,
        StrokeColorB     = 0,
        StrokeThickness  = 1.5,
        AlwaysVisible    = false,
        MobileVisible    = false,
        AfkEnabled       = false,
    }

    -- ============================================================
    -- SYSTÈME DE SAUVEGARDE
    -- ============================================================
    local SAVE_FILE = "SoroniceSave.txt"
    local CurrentValues = {}  -- suit les valeurs courantes

    -- Sérialisation simple clé=valeur
    local function Serialize(tbl)
        local lines = {}
        for k, v in pairs(tbl) do
            table.insert(lines, tostring(k) .. "=" .. tostring(v))
        end
        table.sort(lines)
        return table.concat(lines, "\n")
    end

    local function Deserialize(str)
        local result = {}
        for line in (str .. "\n"):gmatch("([^\n]*)\n") do
            local k, v = line:match("^(.-)=(.+)$")
            if k then
                if v == "true" then
                    result[k] = true
                elseif v == "false" then
                    result[k] = false
                else
                    result[k] = tonumber(v) or v
                end
            end
        end
        return result
    end

    local function SaveToDisk()
        local ok, err = pcall(writefile, SAVE_FILE, Serialize(CurrentValues))
        local msg = ok and "✅ Paramètres sauvegardés !" or "⚠️ Sauvegarde impossible sur cet exécuteur."
        game.StarterGui:SetCore("SendNotification", {Title="Soronice HUB", Text=msg, Duration=3})
    end

    local function LoadFromDisk()
        local ok, content = pcall(readfile, SAVE_FILE)
        if ok and content and #content > 0 then
            return Deserialize(content)
        end
        return nil
    end

    -- ============================================================
    -- APPLICATION D'UNE TABLE DE VALEURS (loaded ou defaults)
    -- Chaque "Applier" est enregistré lors de la création des éléments.
    -- ============================================================
    local Appliers = {}  -- {key = function(value) ... end}
    local UIRefs   = {}  -- {key = returned_table_from_CreateElement}

    local function Apply(key, value)
        CurrentValues[key] = value
        if Appliers[key] then Appliers[key](value) end
        if UIRefs[key]   then UIRefs[key]:Set(value) end
    end

    local function ApplyAll(tbl)
        for k, v in pairs(tbl) do
            Apply(k, v)
        end
    end

    -- ============================================================
    -- AUTO-CHARGEMENT au démarrage
    -- ============================================================
    local saved = LoadFromDisk()
    -- On initialise CurrentValues avec les defaults puis on écrase avec le save
    for k, v in pairs(DEFAULTS) do CurrentValues[k] = v end
    if saved then
        for k, v in pairs(saved) do CurrentValues[k] = v end
    end

    -- ============================================================
    -- HELPER : crée un élément, enregistre son applier, et applique
    --          la valeur courante dès la création
    -- ============================================================
    local function CE(key, applier, elemType, config)
        -- On injecte la valeur actuelle comme CurrentValue si le type le supporte
        if CurrentValues[key] ~= nil then
            if elemType == "Toggle"   then config.CurrentValue = CurrentValues[key] end
            if elemType == "Dropdown" then config.CurrentOption = tostring(CurrentValues[key]) end
        end
        Appliers[key] = applier
        local ref = CreateElement(SettingsPage, elemType, config)
        UIRefs[key] = ref
        -- Applique immédiatement la valeur courante (pour les Dropdown/Slider qui ne le font pas seuls)
        if elemType == "Slider" and CurrentValues[key] then
            applier(CurrentValues[key])
        end
        return ref
    end

    -- ============================================================
    -- SECTION : Sauvegarde
    -- ============================================================
    CreateElement(SettingsPage, "Section", {Text = "💾 Sauvegarde"})

    CreateElement(SettingsPage, "Button", {
        Name = "💾 Sauvegarder les paramètres",
        Callback = SaveToDisk
    })

    CreateElement(SettingsPage, "Button", {
        Name = "↺  Rétablir les paramètres prédéfinis",
        Callback = function()
            ApplyAll(DEFAULTS)
            game.StarterGui:SetCore("SendNotification", {
                Title = "Soronice HUB",
                Text  = "Paramètres réinitialisés — pensez à sauvegarder !",
                Duration = 4
            })
        end
    })

    -- ============================================================
    -- SECTION : Fonctions de base
    -- ============================================================
    CreateElement(SettingsPage, "Section", {Text = "🎮 Fonctions"})

    CE("AfkEnabled",
        function(v) antiAfkActive.value = v end,
        "Toggle", {
            Name = "💤 Mode AFK (Anti-Kick)",
            Callback = function(v)
                CurrentValues.AfkEnabled = v
                antiAfkActive.value = v
                if v then game.StarterGui:SetCore("SendNotification", {Title="Anti-AFK", Text="Activé.", Duration=3}) end
            end
        }
    )

    if not IsMobile then
        CreateElement(SettingsPage, "Keybind", {
            Name = "Touche pour Cacher/Montrer",
            Callback = function() end
        })
    end

    -- ============================================================
    -- SECTION : Visibilité
    -- ============================================================
    CreateElement(SettingsPage, "Section", {Text = "👁️ Visibilité"})

    CE("AlwaysVisible",
        function(v)
            AlwaysVisible.value = v
            if v then ForceShow() end
        end,
        "Toggle", {
            Name = "👁️ Toujours visible (désactive le masquage)",
            Callback = function(v)
                CurrentValues.AlwaysVisible = v
                AlwaysVisible.value = v
                if v then ForceShow() end
            end
        }
    )

    -- Bouton mobile activable depuis PC (ou en permanence sur mobile)
    CE("MobileVisible",
        function(v)
            if MobileOpenBtn then
                MobileOpenBtn.Visible = v
            end
        end,
        "Toggle", {
            Name = "📱 Bouton flottant (visible en permanence)",
            Callback = function(v)
                CurrentValues.MobileVisible = v
                if MobileOpenBtn then
                    MobileOpenBtn.Visible = v
                end
            end
        }
    )

    -- ============================================================
    -- SECTION : Apparence de la fenêtre
    -- ============================================================
    CreateElement(SettingsPage, "Section", {Text = "🎛️ Apparence"})

    CE("SquareCorners",
        function(v)
            local r = v and UDim.new(0,0) or UDim.new(0,10)
            TweenService:Create(MainCorner, TweenInfo.new(0.2), {CornerRadius=r}):Play()
        end,
        "Toggle", {
            Name = "⬜ Coins carrés",
            Callback = function(v)
                CurrentValues.SquareCorners = v
                local r = v and UDim.new(0,0) or UDim.new(0,10)
                TweenService:Create(MainCorner, TweenInfo.new(0.2), {CornerRadius=r}):Play()
            end
        }
    )

    CE("BgTransparency",
        function(v) MainFrame.BackgroundTransparency = v end,
        "Dropdown", {
            Name     = "🌫️ Transparence",
            Options  = {"0.0","0.1","0.2","0.3","0.4","0.5","0.6","0.7"},
            CurrentOption = tostring(CurrentValues.BgTransparency or 0.2),
            Callback = function(v)
                local n = tonumber(v) or 0.2
                CurrentValues.BgTransparency = n
                MainFrame.BackgroundTransparency = n
            end
        }
    )

    CreateElement(SettingsPage, "ColorPicker", {
        Name = "🎨 Couleur de la fenêtre",
        Color = Settings.ThemeColor,
        Callback = function(c)
            MainFrame.BackgroundColor3 = c
        end
    })

    -- Taille de la fenêtre (les sliders redimensionnent ContentContainer
    -- automatiquement car il utilise maintenant UDim2 relatif)
    -- ✅ FIX : on utilise CurrentValues.WindowWidth/Height (déjà connus)
    -- au lieu de MainFrame.AbsoluteSize, qui peut être encore en train
    -- d'animer et donc donner une valeur fausse au moment de l'appliquer.
    CE("WindowWidth",
        function(v)
            CurrentValues.WindowWidth = v
            TweenService:Create(MainFrame, TweenInfo.new(0.2), {
                Size = UDim2.new(0, v, 0, CurrentValues.WindowHeight or 350)
            }):Play()
        end,
        "Slider", {
            Name = "📐 Largeur",
            Range = {300, 800},
            CurrentValue = CurrentValues.WindowWidth or 550,
            Callback = function(v)
                CurrentValues.WindowWidth = v
                TweenService:Create(MainFrame, TweenInfo.new(0.2), {
                    Size = UDim2.new(0, v, 0, CurrentValues.WindowHeight or 350)
                }):Play()
            end
        }
    )

    CE("WindowHeight",
        function(v)
            CurrentValues.WindowHeight = v
            TweenService:Create(MainFrame, TweenInfo.new(0.2), {
                Size = UDim2.new(0, CurrentValues.WindowWidth or 550, 0, v)
            }):Play()
        end,
        "Slider", {
            Name = "📐 Hauteur",
            Range = {200, 600},
            CurrentValue = CurrentValues.WindowHeight or 350,
            Callback = function(v)
                CurrentValues.WindowHeight = v
                TweenService:Create(MainFrame, TweenInfo.new(0.2), {
                    Size = UDim2.new(0, CurrentValues.WindowWidth or 550, 0, v)
                }):Play()
            end
        }
    )

    -- ============================================================
    -- SECTION : Contour de la fenêtre
    -- ============================================================
    CreateElement(SettingsPage, "Section", {Text = "🖼️ Contour"})

    CE("StrokeEnabled",
        function(v) MainStroke.Enabled = v end,
        "Toggle", {
            Name = "🔲 Afficher le contour",
            Callback = function(v)
                CurrentValues.StrokeEnabled = v
                MainStroke.Enabled = v
            end
        }
    )

    local MulticolorRef
    MulticolorRef = CE("StrokeRainbow",
        function(v)
            if v then StartMulticolor() else StopMulticolor() end
        end,
        "Toggle", {
            Name = "🌈 Contour multicolore (RGB)",
            Callback = function(v)
                CurrentValues.StrokeRainbow = v
                if v then StartMulticolor() else StopMulticolor() end
            end
        }
    )

    CreateElement(SettingsPage, "ColorPicker", {
        Name  = "🖌️ Couleur du contour",
        Color = Color3.fromRGB(
            CurrentValues.StrokeColorR or 200,
            CurrentValues.StrokeColorG or 0,
            CurrentValues.StrokeColorB or 0
        ),
        Callback = function(c)
            StopMulticolor()
            if MulticolorRef then MulticolorRef:Set(false) end
            CurrentValues.StrokeRainbow = false
            CurrentValues.StrokeColorR = math.floor(c.R*255)
            CurrentValues.StrokeColorG = math.floor(c.G*255)
            CurrentValues.StrokeColorB = math.floor(c.B*255)
            MainStroke.Color = c
        end
    })

    CE("StrokeThickness",
        function(v) MainStroke.Thickness = v end,
        "Dropdown", {
            Name    = "📏 Épaisseur du contour",
            Options = {"0.5","1","1.5","2","3","4","6"},
            CurrentOption = tostring(CurrentValues.StrokeThickness or 1.5),
            Callback = function(v)
                local n = tonumber(v) or 1.5
                CurrentValues.StrokeThickness = n
                MainStroke.Thickness = n
            end
        }
    )

    -- ============================================================
    -- APPLICATION des valeurs chargées / prédéfinies au démarrage
    -- (après que tous les éléments sont créés et leurs Appliers enregistrés)
    -- ============================================================
    task.defer(function()
        -- Applique les valeurs (saved ou defaults) à tous les éléments
        for key, value in pairs(CurrentValues) do
            if Appliers[key] then
                pcall(Appliers[key], value)
            end
        end
        -- Applique la couleur de contour depuis les composantes R/G/B
        pcall(function()
            MainStroke.Color = Color3.fromRGB(
                CurrentValues.StrokeColorR or 200,
                CurrentValues.StrokeColorG or 0,
                CurrentValues.StrokeColorB or 0
            )
        end)
    end)
end
