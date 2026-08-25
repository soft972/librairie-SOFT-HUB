-- ================================================================
-- minicard.lua  (SoroniceLib module)
-- Composant "MiniCard" — cadre 100×150px
-- Grille automatique : 4 cartes par ligne, descend tout seul
--
-- Config :
--   Name         (string)  Texte sous l'image
--   Image        (string)  rbxassetid://...
--   ButtonText   (string)  Texte du bouton/toggle
--   Mode         (string)  "Button" (défaut) ou "Toggle"
--   ToggleStyle  (number)  1/2/3 — style du toggle
--   BaseShape    (string)  "Round" (défaut) ou "Square"
--   ButtonShape  (string)  "Round" (défaut) ou "Square"
--   HoverEffect  (bool)    true (défaut) — agrandit le bouton au survol
--   HoverStroke  (bool)    false (défaut) — change la couleur du contour au survol
--   CurrentValue (bool)    valeur initiale si Mode="Toggle"
--   Callback     (func)    appelée au clic ou changement de toggle
--   StrokeColor  (Color3)  couleur du contour de la carte
--   StrokeImage  (bool)    contour sur la zone image ? (défaut false)
--   StrokeButton (bool)    contour sur le bouton/toggle ? (défaut true)
--   BgTransparency (number) transparence du fond (0-1, défaut 0)
-- ================================================================

return function(Ctx)
    local S   = Ctx.Settings
    local TS  = Ctx.TweenService
    local AL  = Ctx.ApplyLock
    local AT  = Ctx.ActiveToggles

    local function Corner(Parent, Shape)
        local c = Instance.new("UICorner")
        c.Parent = Parent
        c.CornerRadius = (Shape == "Square") and UDim.new(0,4) or UDim.new(0,12)
        return c
    end

    local function CreateMiniCard(Page, Config)
        Config = Config or {}
        local RT = {}

        -- Conteneur en grille (4 par ligne, descend automatiquement)
        local Grid = Page:FindFirstChild("MiniCardGrid")
        if not Grid then
            Grid = Instance.new("Frame")
            Grid.Name = "MiniCardGrid"
            Grid.Parent = Page
            Grid.BackgroundTransparency = 1
            Grid.Size = UDim2.new(1, -10, 0, 0)
            Grid.AutomaticSize = Enum.AutomaticSize.Y

            local P = Instance.new("UIPadding"); P.Parent = Grid
            P.PaddingLeft = UDim.new(0,4); P.PaddingRight = UDim.new(0,4); P.PaddingTop = UDim.new(0,4)

            local GL = Instance.new("UIGridLayout"); GL.Parent = Grid
            GL.SortOrder = Enum.SortOrder.LayoutOrder
            GL.CellPadding = UDim2.new(0,6,0,6)
            GL.CellSize = UDim2.new(0,100,0,150)
            GL.FillDirectionMaxCells = 4
            GL.HorizontalAlignment = Enum.HorizontalAlignment.Left
        end

        -- Carte principale
        local Card = Instance.new("Frame"); Card.Parent = Grid
        Card.BackgroundColor3 = Color3.fromRGB(28,28,28)
        Card.BackgroundTransparency = Config.BgTransparency or 0
        Card.Size = UDim2.new(1,0,1,0)
        Card:SetAttribute("SearchName", string.lower(Config.Name or ""))
        Corner(Card, Config.BaseShape)

        local StrokeColor = Config.StrokeColor or Color3.fromRGB(55,55,55)
        local CS = Instance.new("UIStroke"); CS.Parent = Card
        CS.Color = StrokeColor; CS.Thickness = 1
        CS.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

        -- Image (zone haute)
        local Img = Instance.new("ImageLabel"); Img.Name = "Icon"; Img.Parent = Card
        Img.BackgroundColor3 = Color3.fromRGB(40,40,40); Img.BackgroundTransparency = 0.2
        Img.Position = UDim2.new(0,6,0,6); Img.Size = UDim2.new(1,-12,0,72)
        Img.Image = Config.Image or ""; Img.ScaleType = Enum.ScaleType.Fit
        Corner(Img, Config.BaseShape)
        if Config.StrokeImage then
            local IS = Instance.new("UIStroke"); IS.Parent = Img
            IS.Color = StrokeColor; IS.Thickness = 1
            IS.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        end

        -- Texte (milieu)
        local NL = Instance.new("TextLabel"); NL.Parent = Card
        NL.BackgroundTransparency = 1; NL.Position = UDim2.new(0,4,0,82); NL.Size = UDim2.new(1,-8,0,18)
        NL.Font = Enum.Font.SourceSansBold; NL.Text = Config.Name or ""
        NL.TextColor3 = S.TextColor; NL.TextSize = 13; NL.TextWrapped = true

        -- Bouton/Toggle (bas)
        local Mode = Config.Mode or "Button"
        local Locked = AL(Card, Config)

        local ActionRow = Instance.new("Frame"); ActionRow.Parent = Card
        ActionRow.AnchorPoint = Vector2.new(0.5,0); ActionRow.Position = UDim2.new(0.5,0,0,106)
        ActionRow.Size = UDim2.new(1,-12,0,34); ActionRow.BackgroundColor3 = Color3.fromRGB(40,40,40)
        Corner(ActionRow, Config.ButtonShape)

        if Config.StrokeButton ~= false then
            local BS2 = Instance.new("UIStroke"); BS2.Parent = ActionRow
            BS2.Color = StrokeColor; BS2.Thickness = 1
            BS2.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        end

        if Mode == "Toggle" then
            -- Label à gauche
            local BL = Instance.new("TextLabel"); BL.Parent = ActionRow
            BL.BackgroundTransparency = 1; BL.Position = UDim2.new(0,6,0,0); BL.Size = UDim2.new(0.55,0,1,0)
            BL.Font = Enum.Font.SourceSansBold; BL.Text = Config.ButtonText or ""
            BL.TextColor3 = S.TextColor; BL.TextSize = 12; BL.TextXAlignment = Enum.TextXAlignment.Left

            -- Pill toggle
            local Pill = Instance.new("Frame"); Pill.Parent = ActionRow
            Pill.BackgroundColor3 = Color3.fromRGB(40,40,40)
            Pill.AnchorPoint = Vector2.new(1,0.5); Pill.Position = UDim2.new(1,-4,0.5,0); Pill.Size = UDim2.new(0,44,0,20)
            Instance.new("UICorner",Pill).CornerRadius = UDim.new(1,0)

            -- Rainbow stroke (Style 3)
            if Config.ToggleStyle == 3 then
                local RS = Instance.new("UIStroke"); RS.Parent = Pill; RS.Thickness = 2
                task.spawn(function()
                    local h = 0
                    while Pill.Parent do h=(h+0.006)%1; RS.Color=Color3.fromHSV(h,1,1); task.wait(0.025) end
                end)
            end

            local Knob = Instance.new("Frame"); Knob.Parent = Pill
            Knob.BackgroundColor3 = Color3.fromRGB(220,220,220); Knob.AnchorPoint = Vector2.new(0,0.5)
            Knob.Position = UDim2.new(0,2,0.5,0); Knob.Size = UDim2.new(0,16,0,16)
            Instance.new("UICorner",Knob).CornerRadius = UDim.new(1,0)

            local Toggled = Config.CurrentValue or false
            table.insert(AT, {Callback = Config.Callback})

            local function UpdateToggle()
                local tp = Toggled and UDim2.new(1,-18,0.5,0) or UDim2.new(0,2,0.5,0)
                local tc = Toggled and S.AccentColor or Color3.fromRGB(40,40,40)
                TS:Create(Knob, TweenInfo.new(0.2), {Position=tp}):Play()
                TS:Create(Pill, TweenInfo.new(0.2), {BackgroundColor3=tc}):Play()
                if Config.Callback then Config.Callback(Toggled) end
            end
            if Toggled then UpdateToggle() end

            local CB = Instance.new("TextButton"); CB.Parent = Pill
            CB.BackgroundTransparency = 1; CB.Size = UDim2.new(1,0,1,0); CB.Text = ""; CB.ZIndex = 5
            if not Locked then
                CB.MouseButton1Click:Connect(function() Toggled = not Toggled; UpdateToggle() end)
            else CB.Active = false end

            function RT:Set(v) Toggled = v; UpdateToggle() end

        else
            -- Bouton classique
            local AB = Instance.new("TextButton"); AB.Parent = ActionRow
            AB.BackgroundTransparency = 1; AB.Size = UDim2.new(1,0,1,0)
            AB.Font = Enum.Font.SourceSansBold; AB.Text = Config.ButtonText or ""
            AB.TextColor3 = S.TextColor; AB.TextSize = 14

            if not Locked then
                AB.MouseButton1Click:Connect(function()
                    TS:Create(ActionRow, TweenInfo.new(0.1), {BackgroundColor3=Color3.fromRGB(60,60,60)}):Play()
                    task.wait(0.1)
                    TS:Create(ActionRow, TweenInfo.new(0.1), {BackgroundColor3=Color3.fromRGB(40,40,40)}):Play()
                    if Config.Callback then Config.Callback() end
                end)
            else AB.Active = false end

            function RT:Set(v) AB.Text = tostring(v) end
            function RT:SetButtonText(t) AB.Text = t end
        end

        -- Hover : agrandit le bouton uniquement (pas de changement de couleur du contour)
        -- Activer le changement de contour : Config.HoverStroke = true
        if Config.HoverEffect ~= false then
            local BS = ActionRow.Size
            Card.MouseEnter:Connect(function()
                TS:Create(ActionRow, TweenInfo.new(0.15, Enum.EasingStyle.Quad), {
                    Size = UDim2.new(BS.X.Scale, BS.X.Offset+6, BS.Y.Scale, BS.Y.Offset+4)
                }):Play()
                if Config.HoverStroke then
                    TS:Create(CS, TweenInfo.new(0.15), {Color=S.AccentColor, Thickness=2}):Play()
                end
            end)
            Card.MouseLeave:Connect(function()
                TS:Create(ActionRow, TweenInfo.new(0.15, Enum.EasingStyle.Quad), {Size=BS}):Play()
                if Config.HoverStroke then
                    TS:Create(CS, TweenInfo.new(0.15), {Color=StrokeColor, Thickness=1}):Play()
                end
            end)
        end

        -- Méthodes publiques
        function RT:SetImage(i)    Img.Image = i end
        function RT:SetText(t)     NL.Text = t; Card:SetAttribute("SearchName", string.lower(t)) end
        function RT:SetStroke(e)   CS.Enabled = e end
        function RT:SetStrokeColor(c) CS.Color = c end
        function RT:SetTransparency(a) Card.BackgroundTransparency = a end

        return RT
    end

    return CreateMiniCard
end
