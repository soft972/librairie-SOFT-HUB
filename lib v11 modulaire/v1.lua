-- [[ SORONICE UI LIBRARY - V11.0 (NOUVEL ID RECHERCHE + TAILLE ORIGINALE + FIX DRAG) ]] --

local SoroniceLib = {}

-- [ SERVICES ] --
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local MarketplaceService = game:GetService("MarketplaceService") 
local HttpService = game:GetService("HttpService")
local StatsService = game:GetService("Stats") 
local LocalPlayer = game.Players.LocalPlayer
local CoreGui = game:GetService("CoreGui")
local VirtualUser = game:GetService("VirtualUser")
local StarterGui = game:GetService("StarterGui")

-- [ DÉTECTION MOBILE ] --
local IsMobile = UserInputService.TouchEnabled and not UserInputService.MouseEnabled

-- [ CONFIGURATION GLOBALE ] --
local Settings = {
    Keybind = Enum.KeyCode.P,
    ThemeColor = Color3.fromRGB(20, 20, 20),
    AccentColor = Color3.fromRGB(0, 54, 203),
    TextColor = Color3.fromRGB(255, 255, 255),
    SubTextColor = Color3.fromRGB(180, 180, 180),
    StatsColor = Color3.fromRGB(35, 35, 35)
}

-- [ LISTE DES ÉLÉMENTS ACTIFS ] --
local ActiveToggles = {} 

-- [ SYSTÈME AFK ] --
local antiAfkActive = false
LocalPlayer.Idled:Connect(function()
    if antiAfkActive then
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
    end
end)

-- [ DÉTECTION NOM DU JEU ] --
local GameNameText = "Détection..."
task.spawn(function()
    local success, info = pcall(function()
        return MarketplaceService:GetProductInfo(game.PlaceId)
    end)
    if success and info and info.Name then
        GameNameText = info.Name
    else
        GameNameText = "Jeu Inconnu"
    end
end)

-- [ FONCTION LOGIN ] --
local function SpawnLoginSystem(SettingsLogin)
    local Validated = false
    local RealPassword = SettingsLogin.Key or "1234"
    
    if SettingsLogin.GrabKeyFromSite == true then
        pcall(function()
            local content = game:HttpGet(SettingsLogin.Key)
            RealPassword = string.gsub(content, "%s+", "")
        end)
    end

    local LoginGui = Instance.new("ScreenGui")
    LoginGui.Name = "SoroniceLoginSystem"
    LoginGui.Parent = CoreGui
    LoginGui.ResetOnSpawn = false

    local BlurEffect = Instance.new("BlurEffect")
    BlurEffect.Parent = game.Lighting
    BlurEffect.Size = 24

    local BackgroundImage = Instance.new("ImageLabel")
    BackgroundImage.Parent = LoginGui
    BackgroundImage.AnchorPoint = Vector2.new(0.5, 0.5)
    BackgroundImage.Position = UDim2.new(0.5, 0, 0.5, 0)
    BackgroundImage.Size = UDim2.new(0, 500, 0, 350)
    BackgroundImage.Image = "rbxassetid://114617892791025"
    BackgroundImage.BackgroundTransparency = 1

    local TitleText = Instance.new("TextLabel")
    TitleText.Parent = BackgroundImage
    TitleText.BackgroundTransparency = 1
    TitleText.Position = UDim2.new(0.1, 0, 0.04, 0)
    TitleText.Size = UDim2.new(0.5, 0, 0.15, 0)
    TitleText.Font = Enum.Font.FredokaOne
    TitleText.Text = SettingsLogin.Title or "ACCÈS PREMIUM"
    TitleText.TextColor3 = Color3.new(1,1,1)
    TitleText.TextScaled = true
    TitleText.TextXAlignment = Enum.TextXAlignment.Left

    local CloseButton = Instance.new("TextButton")
    CloseButton.Parent = BackgroundImage
    CloseButton.BackgroundTransparency = 1
    CloseButton.Position = UDim2.new(0.92, 0, 0.14, 0)
    CloseButton.Size = UDim2.new(0.06, 0, 0.08, 0)
    CloseButton.Text = ""
    CloseButton.MouseButton1Click:Connect(function() 
        LoginGui:Destroy() 
        BlurEffect:Destroy() 
        script:Destroy() 
    end)

    local InputBg = Instance.new("ImageLabel")
    InputBg.Parent = BackgroundImage
    InputBg.BackgroundTransparency = 1
    InputBg.Position = UDim2.new(0.18, 0, 0.42, 0)
    InputBg.Size = UDim2.new(0.62, 0, 0.15, 0)
    InputBg.Image = "rbxassetid://75238927890132"

    local PasswordBox = Instance.new("TextBox")
    PasswordBox.Parent = InputBg
    PasswordBox.BackgroundTransparency = 1
    PasswordBox.Position = UDim2.new(0.15, 0, 0, 0)
    PasswordBox.Size = UDim2.new(0.8, 0, 1, 0)
    PasswordBox.Font = Enum.Font.SourceSansBold
    PasswordBox.Text = ""
    PasswordBox.PlaceholderText = "Entrez la clé ici..."
    PasswordBox.TextColor3 = Color3.new(1,1,1)
    PasswordBox.TextSize = 18
    PasswordBox.TextXAlignment = Enum.TextXAlignment.Left

    local ValidateBtn = Instance.new("TextButton")
    ValidateBtn.Parent = BackgroundImage
    ValidateBtn.BackgroundColor3 = Color3.fromRGB(167, 167, 167)
    ValidateBtn.Position = UDim2.new(0.5, 0, 0.68, 0)
    ValidateBtn.AnchorPoint = Vector2.new(0.5, 0)
    ValidateBtn.Size = UDim2.new(0.4, 0, 0.12, 0)
    ValidateBtn.Text = "VALIDER"
    ValidateBtn.Font = Enum.Font.SourceSansBold
    ValidateBtn.TextSize = 18
    Instance.new("UICorner", ValidateBtn).CornerRadius = UDim.new(0, 10)

    local LinkBtn = Instance.new("TextButton")
    LinkBtn.Parent = BackgroundImage
    LinkBtn.BackgroundColor3 = Color3.fromRGB(167, 167, 167)
    LinkBtn.Position = UDim2.new(0.5, 0, 0.85, 0)
    LinkBtn.AnchorPoint = Vector2.new(0.5, 0)
    LinkBtn.Size = UDim2.new(0.4, 0, 0.12, 0)
    LinkBtn.Text = SettingsLogin.LinkText or "Obtenir la clé"
    LinkBtn.Font = Enum.Font.SourceSans
    LinkBtn.TextSize = 14
    Instance.new("UICorner", LinkBtn).CornerRadius = UDim.new(0, 10)

    local function Verify()
        if PasswordBox.Text == RealPassword then 
            Validated = true 
            LoginGui:Destroy() 
            BlurEffect:Destroy()
        else 
            PasswordBox.Text = "" 
            PasswordBox.PlaceholderText = "Mot de passe INCORRECT !" 
            wait(1.5) 
            PasswordBox.PlaceholderText = "Entrez la clé ici..." 
        end
    end

    ValidateBtn.MouseButton1Click:Connect(Verify)
    LinkBtn.MouseButton1Click:Connect(function()
        if SettingsLogin.Link then 
            setclipboard(SettingsLogin.Link) 
            LinkBtn.Text = "Lien copié !" 
            wait(2) 
            LinkBtn.Text = SettingsLogin.LinkText or "Obtenir la clé" 
        end
    end)

    repeat wait() until Validated or not LoginGui.Parent
    if not Validated then 
        script:Destroy() 
        while true do wait(999) end 
    end
end

-- [ SYSTÈME NOTIFY ] --
function SoroniceLib:Notify(NotifyConfig)
    local Title = NotifyConfig.Title or "Notification"
    local Content = NotifyConfig.Content or "Message"
    local Duration = NotifyConfig.Duration or 6.5
    local ImageId = NotifyConfig.Image or 4483362458
    
    if ImageId == "rewind" then 
        ImageId = 4483362458 
    end

    local NotifGui = CoreGui:FindFirstChild("SoroniceNotifs")
    if not NotifGui then
        NotifGui = Instance.new("ScreenGui")
        NotifGui.Name = "SoroniceNotifs"
        NotifGui.Parent = CoreGui
        NotifGui.ResetOnSpawn = false
    end

    local Frame = Instance.new("Frame")
    Frame.Name = "NotificationFrame"
    Frame.Parent = NotifGui
    Frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    Frame.BorderSizePixel = 0
    Frame.Position = UDim2.new(1, 10, 0.8, -((#NotifGui:GetChildren() - 1) * 110))
    Frame.Size = UDim2.new(0, 280, 0, 100)
    Frame.BackgroundTransparency = 1 

    local RealFrame = Instance.new("Frame")
    RealFrame.Parent = Frame
    RealFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    RealFrame.Size = UDim2.new(1, 0, 1, 0)
    
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 8)
    Corner.Parent = RealFrame

    local Icon = Instance.new("ImageLabel")
    Icon.Parent = RealFrame
    Icon.BackgroundTransparency = 1
    Icon.Position = UDim2.new(0, 15, 0, 25)
    Icon.Size = UDim2.new(0, 50, 0, 50)
    Icon.Image = "rbxassetid://"..tostring(ImageId)

    local TitleLbl = Instance.new("TextLabel")
    TitleLbl.Parent = RealFrame
    TitleLbl.BackgroundTransparency = 1
    TitleLbl.Position = UDim2.new(0, 75, 0, 15)
    TitleLbl.Size = UDim2.new(0, 195, 0, 20)
    TitleLbl.Font = Enum.Font.GothamBold
    TitleLbl.Text = Title
    TitleLbl.TextColor3 = Color3.fromRGB(240, 240, 240)
    TitleLbl.TextSize = 15
    TitleLbl.TextXAlignment = Enum.TextXAlignment.Left

    local DescLbl = Instance.new("TextLabel")
    DescLbl.Parent = RealFrame
    DescLbl.BackgroundTransparency = 1
    DescLbl.Position = UDim2.new(0, 75, 0, 40)
    DescLbl.Size = UDim2.new(0, 195, 0, 45)
    DescLbl.Font = Enum.Font.Gotham
    DescLbl.Text = Content
    DescLbl.TextColor3 = Color3.fromRGB(180, 180, 180)
    DescLbl.TextSize = 13
    DescLbl.TextXAlignment = Enum.TextXAlignment.Left
    DescLbl.TextWrapped = true
    DescLbl.TextYAlignment = Enum.TextYAlignment.Top

    TweenService:Create(Frame, TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Position = UDim2.new(1, -300, 0.8, -((#NotifGui:GetChildren() - 1) * 110))}):Play()
    TweenService:Create(Frame, TweenInfo.new(0.5), {BackgroundTransparency = 0}):Play()

    task.spawn(function()
        wait(Duration)
        TweenService:Create(Frame, TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {Position = UDim2.new(1, 10, 0.8, -((#NotifGui:GetChildren() - 1) * 110))}):Play()
        wait(0.5)
        Frame:Destroy()
    end)
end

-- --- [ CRÉATION DE LA FENÊTRE ] ---

function SoroniceLib:CreateWindow(Config)
    if Config.KeySystem == true then 
        SpawnLoginSystem(Config.KeySettings or {}) 
    end

    if Config.TextColor then 
        Settings.TextColor = Config.TextColor 
    end

	local TitleName = Config.Name or "SORONICE HUB"
    local BrandLogoId = Config.BrandLogo or "" 
    local VersionTagText = Config.VersionTag or "" 
    local StatusIconsList = Config.StatusIcons or {}
    
    local ShowDevice = Config.ShowDevice or false
    local ShowPing = Config.ShowPing or false
    local ShowFPS = Config.ShowFPS or false

	if CoreGui:FindFirstChild("Soronice_V6") then CoreGui:FindFirstChild("Soronice_V6"):Destroy() end
    if CoreGui:FindFirstChild("Soronice_V7") then CoreGui:FindFirstChild("Soronice_V7"):Destroy() end
    if CoreGui:FindFirstChild("Soronice_V9") then CoreGui:FindFirstChild("Soronice_V9"):Destroy() end
    if CoreGui:FindFirstChild("Soronice_V11") then CoreGui:FindFirstChild("Soronice_V11"):Destroy() end

	local ScreenGui = Instance.new("ScreenGui")
	ScreenGui.Name = "Soronice_V11"
	ScreenGui.Parent = CoreGui
    ScreenGui.ResetOnSpawn = false

    -- ============================================================
    -- CHARGEMENT DES MODULES GITHUB
    -- Repo : soft972/librairie-SOFT-HUB (branche main)
    -- ============================================================
    local BUTTONS_URL  = "https://raw.githubusercontent.com/soft972/librairie-SOFT-HUB/refs/heads/main/buttons.lua"
    local ICONCARD_URL = "https://raw.githubusercontent.com/soft972/librairie-SOFT-HUB/refs/heads/main/iconcard.lua"
    local SETTINGS_URL = "https://raw.githubusercontent.com/soft972/librairie-SOFT-HUB/refs/heads/main/settings.lua"
    local MINICARD_URL = "https://raw.githubusercontent.com/soft972/librairie-SOFT-HUB/refs/heads/main/minicard.lua"

    -- antiAfkActive passé par référence aux modules externes
    local antiAfkRef = { value = false }
    local AlwaysVisibleRef = { value = false }

    -- [APPLY LOCK FUNCTION]
    local function ApplyLock(TargetFrame, ElementConfig)
        if not ElementConfig then return false end
        
        local IsLocked = ElementConfig.Locked or false
        local LockReason = nil 

        if ElementConfig.BannedUsers and type(ElementConfig.BannedUsers) == "table" then
            for _, bannedId in pairs(ElementConfig.BannedUsers) do
                if LocalPlayer.UserId == bannedId then
                    IsLocked = true
                    LockReason = "Banned"
                    break
                end
            end
        end

        if not LockReason and ElementConfig.GamePassID then
            IsLocked = true 
            LockReason = "Gamepass"
        end

        if IsLocked then
            TargetFrame.ClipsDescendants = true 
            local LockOverlay = Instance.new("ImageButton")
            LockOverlay.Name = "LockOverlay"
            LockOverlay.Parent = TargetFrame
            LockOverlay.BackgroundTransparency = 1
            LockOverlay.Size = UDim2.new(1, 0, 1, 0)
            LockOverlay.Position = UDim2.new(0, 0, 0, 0)
            LockOverlay.ZIndex = 50 
            LockOverlay.Image = "rbxassetid://139868914964686" 
            LockOverlay.ImageTransparency = 0.53 
            
            LockOverlay.MouseButton1Click:Connect(function()
                if LockReason == "Gamepass" and ElementConfig.GamePassID then
                    MarketplaceService:PromptGamePassPurchase(LocalPlayer, ElementConfig.GamePassID)
                elseif LockReason == "Banned" then
                    game.StarterGui:SetCore("SendNotification", {Title = "Accès Refusé", Text = "Permission refusée.", Duration = 3})
                end
            end)
            return true 
        end
        return false 
    end

    -- [BOUTON FLOTTANT — créé sur tous les appareils, toujours caché par défaut]
    -- Mobile : s'affiche quand la fenêtre est réduite
    -- PC     : activable depuis les Paramètres ("Bouton flottant permanent")
    local MobileOpenBtn = Instance.new("ImageButton")
    MobileOpenBtn.Name = "MobileOpenButton"
    MobileOpenBtn.Parent = ScreenGui
    MobileOpenBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    MobileOpenBtn.BackgroundTransparency = 0.2
    MobileOpenBtn.Position = UDim2.new(0.1, 0, 0.1, 0)
    MobileOpenBtn.Size = UDim2.new(0, 50, 0, 50)
    MobileOpenBtn.Image = Config.MobileImage or "rbxassetid://133601263847208"
    MobileOpenBtn.Visible = false
    Instance.new("UICorner", MobileOpenBtn).CornerRadius = UDim.new(0, 12)
    do
        local dragging_mob, dragInput_mob, dragStart_mob, startPos_mob
        
        MobileOpenBtn.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging_mob = true
                dragStart_mob = input.Position
                startPos_mob = MobileOpenBtn.Position
            end
        end)
        
        MobileOpenBtn.InputChanged:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
                dragInput_mob = input
            end
        end)
        
        UserInputService.InputChanged:Connect(function(input)
            if input == dragInput_mob and dragging_mob then
                local delta = input.Position - dragStart_mob
                MobileOpenBtn.Position = UDim2.new(startPos_mob.X.Scale, startPos_mob.X.Offset + delta.X, startPos_mob.Y.Scale, startPos_mob.Y.Offset + delta.Y)
            end
        end)
        
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging_mob = false
            end
        end)
    end  -- fin do drag

	-- [ MAIN FRAME : TAILLE D'ORIGINE - 550px STRICTE ]
	local MainFrame = Instance.new("Frame")
	MainFrame.Name = "MainFrame"
	MainFrame.Parent = ScreenGui
	MainFrame.BackgroundColor3 = Settings.ThemeColor
	MainFrame.BackgroundTransparency = 0.2
    MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    
    local TargetSize
    if IsMobile then
        MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0) 
        TargetSize = UDim2.new(0, 400, 0, 260) 
    else
	    MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
        TargetSize = UDim2.new(0, 550, 0, 350) -- [TAILLE D'ORIGINE]
    end
    
    MainFrame.Size = UDim2.new(0, 0, 0, 0)
    MainFrame.ClipsDescendants = true 
    TweenService:Create(MainFrame, TweenInfo.new(0.7, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Size = TargetSize}):Play()
	
	local MainCorner = Instance.new("UICorner")
	MainCorner.CornerRadius = UDim.new(0, 10)
	MainCorner.Parent = MainFrame

    local MainStroke = Instance.new("UIStroke")
    MainStroke.Parent = MainFrame
    MainStroke.Color = Color3.fromRGB(50, 50, 50)
    MainStroke.Thickness = 1.5
    MainStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

    -- [ TOUJOURS VISIBLE ]
    -- AlwaysVisibleRef.value est mis à jour par le module Settings
    -- ToggleVisibility lit AlwaysVisibleRef.value directement

    -- [ CONTOUR MULTICOLORE (RGB) ] --
    local MulticolorToken = 0
    local function StopMulticolor()
        MulticolorToken = MulticolorToken + 1
    end
    local function StartMulticolor()
        MulticolorToken = MulticolorToken + 1
        local MyToken = MulticolorToken
        task.spawn(function()
            local Hue = 0
            while MulticolorToken == MyToken do
                Hue = (Hue + 0.008) % 1
                MainStroke.Color = Color3.fromHSV(Hue, 1, 1)
                task.wait(0.03)
            end
        end)
    end

	local TopBar = Instance.new("Frame")
	TopBar.Name = "TopBar"
	TopBar.Parent = MainFrame
	TopBar.BackgroundTransparency = 1 
	TopBar.Size = UDim2.new(1, 0, 0, 40) 
    TopBar.Position = UDim2.new(0,0,0,0)
    TopBar.ZIndex = 10

    -- [ HEADER GAUCHE ]
    local LeftContainer = Instance.new("Frame")
    LeftContainer.Parent = TopBar
    LeftContainer.BackgroundTransparency = 1
    LeftContainer.Position = UDim2.new(0, 10, 0, 0)
    LeftContainer.Size = UDim2.new(0.4, 0, 1, 0)
    
    local LeftLayout = Instance.new("UIListLayout")
    LeftLayout.Parent = LeftContainer
    LeftLayout.FillDirection = Enum.FillDirection.Horizontal
    LeftLayout.SortOrder = Enum.SortOrder.LayoutOrder
    LeftLayout.Padding = UDim.new(0, 8)
    LeftLayout.VerticalAlignment = Enum.VerticalAlignment.Center

    if BrandLogoId ~= "" then
        local BrandLogo = Instance.new("ImageLabel")
        BrandLogo.Parent = LeftContainer
        BrandLogo.Size = UDim2.new(0, 32, 0, 32)
        BrandLogo.BackgroundTransparency = 1
        BrandLogo.Image = "rbxassetid://" .. BrandLogoId
        BrandLogo.LayoutOrder = 1
        BrandLogo.ZIndex = 100 
    end

    local TextVerticalContainer = Instance.new("Frame")
    TextVerticalContainer.Parent = LeftContainer
    TextVerticalContainer.BackgroundTransparency = 1
    TextVerticalContainer.Size = UDim2.new(0, 200, 0, 38)
    TextVerticalContainer.LayoutOrder = 2

	local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Parent = TextVerticalContainer
	TitleLabel.BackgroundTransparency = 1
	TitleLabel.Size = UDim2.new(1, 0, 0.6, 0)
	TitleLabel.Font = Enum.Font.FredokaOne
	TitleLabel.Text = TitleName
	TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	TitleLabel.TextSize = 18
	TitleLabel.TextXAlignment = Enum.TextXAlignment.Left

    local GameLabel = Instance.new("TextLabel")
    GameLabel.Parent = TextVerticalContainer
    GameLabel.BackgroundTransparency = 1
    GameLabel.Position = UDim2.new(0,0,0.6,0)
    GameLabel.Size = UDim2.new(1, 0, 0.4, 0)
    GameLabel.Font = Enum.Font.SourceSans
    GameLabel.Text = GameNameText 
    GameLabel.TextColor3 = Settings.AccentColor
    GameLabel.TextSize = 13
    GameLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    task.spawn(function() 
        while GameNameText == "Détection..." do wait(0.1) end
        GameLabel.Text = GameNameText 
    end)

    -- [ HEADER DROITE ]
    local RightContainer = Instance.new("Frame")
    RightContainer.Parent = TopBar
    RightContainer.BackgroundTransparency = 1
    RightContainer.AnchorPoint = Vector2.new(1, 0)
    RightContainer.Position = UDim2.new(1, -110, 0, 0) -- On laisse de la place pour les boutons
    RightContainer.Size = UDim2.new(0.5, 0, 1, 0)

    local RightLayout = Instance.new("UIListLayout")
    RightLayout.Parent = RightContainer
    RightLayout.FillDirection = Enum.FillDirection.Horizontal
    RightLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
    RightLayout.SortOrder = Enum.SortOrder.LayoutOrder
    RightLayout.Padding = UDim.new(0, 6)
    RightLayout.VerticalAlignment = Enum.VerticalAlignment.Center

    local function CreateStatBadge(Text, Color, Order)
        local Badge = Instance.new("Frame")
        Badge.Parent = RightContainer
        Badge.BackgroundColor3 = Color or Settings.StatsColor
        Badge.Size = UDim2.new(0, 0, 0, 24)
        Badge.AutomaticSize = Enum.AutomaticSize.X
        Badge.LayoutOrder = Order
        Instance.new("UICorner", Badge).CornerRadius = UDim.new(0, 6)
        
        local Lbl = Instance.new("TextLabel")
        Lbl.Parent = Badge
        Lbl.BackgroundTransparency = 1
        Lbl.Size = UDim2.new(1, 0, 1, 0)
        Lbl.Font = Enum.Font.GothamBold
        Lbl.Text = "  " .. Text .. "  "
        Lbl.TextColor3 = Settings.TextColor
        Lbl.TextSize = 11
        return Lbl
    end

    if ShowDevice then
        local DeviceTxt = "PC"
        if UserInputService.TouchEnabled and not UserInputService.MouseEnabled then 
            DeviceTxt = "Mobile" 
        elseif UserInputService.GamepadEnabled then 
            DeviceTxt = "Console" 
        end
        CreateStatBadge(DeviceTxt, Color3.fromRGB(100, 60, 255), 1)
    end

    if VersionTagText ~= "" then
        CreateStatBadge(VersionTagText, Settings.AccentColor, 2)
    end

    if ShowFPS then
        local FpsLbl = CreateStatBadge("FPS: 60", Color3.fromRGB(255, 170, 0), 3)
        task.spawn(function()
            local lastTime = tick()
            local frameCount = 0
            RunService.RenderStepped:Connect(function()
                frameCount = frameCount + 1
                if tick() - lastTime >= 1 then
                    FpsLbl.Text = "FPS: " .. frameCount
                    frameCount = 0
                    lastTime = tick()
                end
            end)
        end)
    end

    if ShowPing then
        local PingLbl = CreateStatBadge("Ping: 0ms", Color3.fromRGB(0, 200, 80), 4)
        task.spawn(function()
            while true do
                if StatsService.Network:FindFirstChild("ServerStatsItem") then
                    local ping = math.floor(StatsService.Network.ServerStatsItem["Data Ping"]:GetValue())
                    PingLbl.Text = "Ping: " .. ping .. "ms"
                end
                wait(1)
            end
        end)
    end

    -- [ BOUTONS TOPBAR AVEC NOUVEL ID RECHERCHE ] --
    local ButtonsContainer = Instance.new("Frame")
    ButtonsContainer.Name = "ButtonsContainer"
    ButtonsContainer.Parent = TopBar
    ButtonsContainer.BackgroundTransparency = 1
    ButtonsContainer.AnchorPoint = Vector2.new(1, 0)
    ButtonsContainer.Position = UDim2.new(1, -10, 0, 0)
    ButtonsContainer.Size = UDim2.new(0, 100, 1, 0) -- Zone réservée aux boutons

    local SearchBtn = Instance.new("ImageButton")
    SearchBtn.Name = "SearchButton"
    SearchBtn.Parent = ButtonsContainer
    SearchBtn.BackgroundTransparency = 1
    SearchBtn.Position = UDim2.new(0, 0, 0, 5)
    SearchBtn.Size = UDim2.new(0, 30, 0, 30)
    SearchBtn.Image = "rbxassetid://84854196643814" -- [NOUVEL ID]
    SearchBtn.ImageColor3 = Color3.new(1,1,1) -- [BLANC]
    SearchBtn.ZIndex = 100 -- [FORCE AU PREMIER PLAN]

	local MinBtn = Instance.new("TextButton")
    MinBtn.Parent = ButtonsContainer
	MinBtn.Name = "Minimize"
	MinBtn.BackgroundTransparency = 1
	MinBtn.Position = UDim2.new(0, 35, 0, 5)
	MinBtn.Size = UDim2.new(0, 30, 0, 30)
	MinBtn.Font = Enum.Font.SourceSansBold
	MinBtn.Text = "-"
	MinBtn.TextColor3 = Settings.SubTextColor
	MinBtn.TextSize = 24
    
	local CloseBtn = Instance.new("TextButton")
    CloseBtn.Parent = ButtonsContainer
	CloseBtn.Name = "Close"
	CloseBtn.BackgroundTransparency = 1
	CloseBtn.Position = UDim2.new(0, 70, 0, 5)
	CloseBtn.Size = UDim2.new(0, 30, 0, 30)
	CloseBtn.Font = Enum.Font.SourceSansBold
	CloseBtn.Text = "X"
	CloseBtn.TextColor3 = Settings.SubTextColor
	CloseBtn.TextSize = 20

    -- [ DRAGGING GLOBAL (CORRECTION FINALE) ] --
	local dragging, dragInput, dragStart, startPos
    
    local function StartDrag(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            -- On vérifie si la souris est sur le container des boutons
            -- On utilise les coordonnées absolues pour être précis
            local mousePos = input.Position
            local btnPos = ButtonsContainer.AbsolutePosition
            local btnSize = ButtonsContainer.AbsoluteSize
            
            local isOverButtons = (mousePos.X >= btnPos.X and mousePos.X <= btnPos.X + btnSize.X and mousePos.Y >= btnPos.Y and mousePos.Y <= btnPos.Y + btnSize.Y)
            
            if not isOverButtons then
                dragging = true
                dragStart = input.Position
                startPos = MainFrame.Position
            end
        end
    end

	TopBar.InputBegan:Connect(StartDrag)
	TopBar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
	UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
	UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

	local IsHidden = false
    local isAnimating = false

    local function ToggleVisibility()
        if AlwaysVisibleRef.value then return end
        if isAnimating then return end
        isAnimating = true
        IsHidden = not IsHidden
        
        if IsHidden then
            local closeT = TweenService:Create(MainFrame, TweenInfo.new(0.7, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Size = UDim2.new(0,0,0,0)})
            closeT:Play()
            closeT.Completed:Wait()
            MainFrame.Visible = false
            if MobileOpenBtn then
                MobileOpenBtn.Visible = true
            end
        else
            if MobileOpenBtn then
                MobileOpenBtn.Visible = false
            end
            MainFrame.Visible = true
            local openT = TweenService:Create(MainFrame, TweenInfo.new(0.7, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Size = TargetSize})
            openT:Play()
            openT.Completed:Wait()
        end
        isAnimating = false
    end

    -- Réaffiche immédiatement la fenêtre si elle était cachée (utilisé par le mode "Toujours visible")
    local function ForceShow()
        if not IsHidden then return end
        IsHidden = false
        if MobileOpenBtn then
            MobileOpenBtn.Visible = false
        end
        MainFrame.Visible = true
        TweenService:Create(MainFrame, TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Size = TargetSize}):Play()
    end

	MinBtn.MouseButton1Click:Connect(ToggleVisibility)
    MobileOpenBtn.MouseButton1Click:Connect(ToggleVisibility)
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if not IsMobile and not gameProcessed and input.KeyCode == Settings.Keybind then 
            ToggleVisibility() 
        end
    end)

	CloseBtn.MouseButton1Click:Connect(function() 
        for _, ToggleData in pairs(ActiveToggles) do
            if ToggleData.Callback then
                ToggleData.Callback(false) 
            end
        end
        local CloseTween = TweenService:Create(MainFrame, TweenInfo.new(0.7, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {Size = UDim2.new(0,0,0,0)})
        CloseTween:Play()
        CloseTween.Completed:Wait() 
        ScreenGui:Destroy() 
    end)

    -- [ BARRE DE RECHERCHE ] --
    local SearchBarFrame = Instance.new("Frame")
    SearchBarFrame.Name = "SearchBar"
    SearchBarFrame.Parent = MainFrame
    SearchBarFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    SearchBarFrame.BorderSizePixel = 0
    SearchBarFrame.Position = UDim2.new(0, 80, 0, 45)
    SearchBarFrame.Size = UDim2.new(1, -90, 0, 0)
    SearchBarFrame.Visible = false
    SearchBarFrame.ClipsDescendants = true
    SearchBarFrame.ZIndex = 5
    Instance.new("UICorner", SearchBarFrame).CornerRadius = UDim.new(0, 6)

    local SearchInput = Instance.new("TextBox")
    SearchInput.Parent = SearchBarFrame
    SearchInput.BackgroundTransparency = 1
    SearchInput.Position = UDim2.new(0, 10, 0, 0)
    SearchInput.Size = UDim2.new(1, -20, 1, 0)
    SearchInput.Font = Enum.Font.SourceSans
    SearchInput.PlaceholderText = "Rechercher..."
    SearchInput.Text = ""
    SearchInput.TextColor3 = Settings.TextColor
    SearchInput.TextSize = 16
    SearchInput.TextXAlignment = Enum.TextXAlignment.Left
    SearchInput.ZIndex = 6

    local SearchOpen = false
    local isSearchAnimating = false

    local function ToggleSearch()
        if isSearchAnimating then return end
        isSearchAnimating = true
        SearchOpen = not SearchOpen

        if SearchOpen then
            SearchBarFrame.Visible = true
            TweenService:Create(SearchBarFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(1, -90, 0, 30)}):Play()
            SearchInput:CaptureFocus()
        else
            local closeTween = TweenService:Create(SearchBarFrame, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Size = UDim2.new(1, -90, 0, 0)})
            closeTween:Play()
            closeTween.Completed:Wait()
            SearchBarFrame.Visible = false
            SearchInput.Text = "" 
        end
        isSearchAnimating = false
    end
    SearchBtn.MouseButton1Click:Connect(ToggleSearch)

    UserInputService.InputBegan:Connect(function(input)
        if SearchOpen and input.UserInputType == Enum.UserInputType.MouseButton1 then
            local mousePos = UserInputService:GetMouseLocation()
            local sAbs = SearchBarFrame.AbsolutePosition
            local sSize = SearchBarFrame.AbsoluteSize
            local bAbs = SearchBtn.AbsolutePosition
            local bSize = SearchBtn.AbsoluteSize

            if not (mousePos.X >= sAbs.X and mousePos.X <= sAbs.X + sSize.X and mousePos.Y >= sAbs.Y - 36 and mousePos.Y <= sAbs.Y + sSize.Y) then
                 if not (mousePos.X >= bAbs.X and mousePos.X <= bAbs.X + bSize.X and mousePos.Y >= bAbs.Y - 36 and mousePos.Y <= bAbs.Y + bSize.Y) then
                    ToggleSearch()
                end
            end
        end
    end)

	local Sidebar = Instance.new("Frame")
	Sidebar.Parent = MainFrame
	Sidebar.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
	Sidebar.BackgroundTransparency = 0.5
	Sidebar.Position = UDim2.new(0, 10, 0, 50)
	Sidebar.Size = UDim2.new(0, 60, 1, -60) 
    Sidebar.ClipsDescendants = true 
	local SidebarCorner = Instance.new("UICorner")
	SidebarCorner.CornerRadius = UDim.new(0, 8)
	SidebarCorner.Parent = Sidebar
    
    local SidebarScroll = Instance.new("ScrollingFrame")
    SidebarScroll.Parent = Sidebar
    SidebarScroll.BackgroundTransparency = 1
    SidebarScroll.Position = UDim2.new(0, 0, 0, 0)
    SidebarScroll.Size = UDim2.new(1, 0, 1, -50) 
    SidebarScroll.ScrollBarThickness = 0
    SidebarScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    
	local SidebarLayout = Instance.new("UIListLayout")
	SidebarLayout.Parent = SidebarScroll
	SidebarLayout.SortOrder = Enum.SortOrder.LayoutOrder
	SidebarLayout.Padding = UDim.new(0, 10)
	SidebarLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    SidebarLayout.VerticalAlignment = Enum.VerticalAlignment.Top

	local ContentContainer = Instance.new("Frame")
	ContentContainer.Parent = MainFrame
	ContentContainer.BackgroundTransparency = 1
	ContentContainer.Position = UDim2.new(0, 80, 0, 50)
    -- Taille RELATIVE à MainFrame → se redimensionne automatiquement
    ContentContainer.Size = UDim2.new(1, -80, 1, -60)
    ContentContainer.ClipsDescendants = true 

    -- [ FILTRAGE ] --
    local function FilterItems(searchText)
        searchText = string.lower(searchText)
        for _, page in pairs(ContentContainer:GetChildren()) do
            if page:IsA("ScrollingFrame") and page.Visible then
                for _, element in pairs(page:GetChildren()) do
                    if element:IsA("Frame") and element:GetAttribute("SearchName") then
                        local itemName = element:GetAttribute("SearchName")
                        if string.find(itemName, searchText) then
                            element.Visible = true
                        else
                            element.Visible = false
                        end
                    elseif element.Name == "IconCardGrid" then
                        -- Les IconCard vivent une étage plus bas (dans leur grille), on les filtre aussi
                        for _, card in pairs(element:GetChildren()) do
                            if card:IsA("Frame") and card:GetAttribute("SearchName") then
                                local cardName = card:GetAttribute("SearchName")
                                if string.find(cardName, searchText) then
                                    card.Visible = true
                                else
                                    card.Visible = false
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    SearchInput:GetPropertyChangedSignal("Text"):Connect(function()
        FilterItems(SearchInput.Text)
    end)

	local SettingsBtn = Instance.new("TextButton")
	SettingsBtn.Name = "Settings_Btn"
	SettingsBtn.Parent = Sidebar 
	SettingsBtn.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	SettingsBtn.BackgroundTransparency = 0.5
    SettingsBtn.Position = UDim2.new(0.5, -22, 1, -50) 
    SettingsBtn.AnchorPoint = Vector2.new(0, 0) 
	SettingsBtn.Size = UDim2.new(0, 45, 0, 45)
	SettingsBtn.Text = ""
    SettingsBtn.ZIndex = 2 
    Instance.new("UICorner", SettingsBtn).CornerRadius = UDim.new(0, 8)
	local SettingsIcon = Instance.new("ImageLabel")
	SettingsIcon.Parent = SettingsBtn
	SettingsIcon.BackgroundTransparency = 1
	SettingsIcon.Position = UDim2.new(0, 5, 0, 5)
	SettingsIcon.Size = UDim2.new(0, 35, 0, 35)
	SettingsIcon.Image = "rbxassetid://74182569229556"
    SettingsIcon.ImageColor3 = Settings.SubTextColor

    local SettingsPage = Instance.new("ScrollingFrame")
    SettingsPage.Name = "Settings_Page"
    SettingsPage.Parent = ContentContainer
    SettingsPage.BackgroundTransparency = 1
    SettingsPage.Size = UDim2.new(1, 0, 1, 0)
    SettingsPage.ScrollBarThickness = 2 -- Scrollbar fine
    SettingsPage.Visible = false 
    SettingsPage.AutomaticCanvasSize = Enum.AutomaticSize.Y
    SettingsPage.CanvasSize = UDim2.new(0,0,0,0)

    local SettingsLayout = Instance.new("UIListLayout")
    SettingsLayout.Parent = SettingsPage
    SettingsLayout.Padding = UDim.new(0, 8)
    SettingsLayout.SortOrder = Enum.SortOrder.LayoutOrder

    SettingsBtn.MouseButton1Click:Connect(function()
        if SearchOpen then ToggleSearch() end
        for _, v in pairs(ContentContainer:GetChildren()) do v.Visible = false end
        SettingsPage.Visible = true
        for _, btn in pairs(SidebarScroll:GetChildren()) do
            if btn:IsA("TextButton") then TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(0,0,0)}):Play() end
        end
        TweenService:Create(SettingsBtn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(40,40,40)}):Play()
    end)

    -- ============================================================
    -- CONTEXTE PARTAGÉ pour les modules GitHub
    -- local déclarés ICI pour que CreateElement et le bloc Settings y accèdent
    -- ============================================================
    local ModuleCtx      -- déclaré avant l'assignation (fix: évite le nil à la ligne 978)
    local ButtonRegistry -- rempli au premier appel de CreateElement
    local IconCardFn     -- idem
    local MiniCardFn     -- idem (module minicard.lua séparé)

    ModuleCtx = {
        Settings         = Settings,
        TweenService     = TweenService,
        UserInputService = UserInputService,
        ApplyLock        = ApplyLock,
        ActiveToggles    = ActiveToggles,
        SettingsPage     = SettingsPage,
        IsMobile         = IsMobile,
        MainFrame        = MainFrame,
        MainCorner       = MainCorner,
        MainStroke       = MainStroke,
        AlwaysVisible    = AlwaysVisibleRef,
        antiAfkActive    = antiAfkRef,
        TargetSize       = TargetSize,
        ForceShow        = ForceShow,
        StartMulticolor  = StartMulticolor,
        StopMulticolor   = StopMulticolor,
        MobileOpenBtn    = MobileOpenBtn,
        ToggleVisibility = ToggleVisibility,
        CreateElement    = nil, -- mis à jour juste après la définition de CreateElement
    }

	local WindowFunctions = {}
	local FirstTab = true

    -- ============================================================
    -- PRÉ-CHARGEMENT IMMÉDIAT DES MODULES
    -- Les 3 chargements se font EN PARALLÈLE dès CreateWindow,
    -- avant même le premier onglet. Si GitHub est inaccessible,
    -- le fallback intégré prend le relais et TOUT continue de marcher.
    -- ============================================================
    local function MakeFallbackButtons(Ctx)
        -- Fallback intégré : tous les types de boutons, aucune dépendance réseau
        local S   = Ctx.Settings
        local TS  = Ctx.TweenService
        local UIS = Ctx.UserInputService
        local AL  = Ctx.ApplyLock
        local AT  = Ctx.ActiveToggles
        local Reg = {}

        -- BUTTON
        function Reg.Button(Page, Config)
            local RT = {}
            local F = Instance.new("Frame")
            F.Parent = Page; F.BackgroundColor3 = Color3.fromRGB(30,30,30)
            F.Size = UDim2.new(1,-10,0,35)
            Instance.new("UICorner",F).CornerRadius = UDim.new(0,6)
            F:SetAttribute("SearchName", string.lower(Config.Name or ""))
            local Btn = Instance.new("TextButton")
            Btn.Parent=F; Btn.BackgroundTransparency=1; Btn.Size=UDim2.new(1,0,1,0)
            Btn.Font=Enum.Font.SourceSans; Btn.Text="  "..(Config.Name or "")
            Btn.TextColor3=S.TextColor; Btn.TextSize=16; Btn.TextXAlignment=Enum.TextXAlignment.Left
            local Locked = AL(F, Config)
            if not Locked then
                Btn.MouseButton1Click:Connect(function()
                    TS:Create(F,TweenInfo.new(0.1),{BackgroundColor3=Color3.fromRGB(50,50,50)}):Play()
                    task.wait(0.1)
                    TS:Create(F,TweenInfo.new(0.1),{BackgroundColor3=Color3.fromRGB(30,30,30)}):Play()
                    if Config.Callback then Config.Callback() end
                end)
            else Btn.Active=false end
            function RT:Set(n) Btn.Text="  "..n end
            return RT
        end

        -- TOGGLE (style 1 classique)
        function Reg.Toggle(Page, Config)
            local RT = {}
            local Style = Config.ToggleStyle or 1
            local F = Instance.new("Frame")
            F.Parent=Page; F.BackgroundTransparency=1; F.Size=UDim2.new(1,-10,0,35)
            F:SetAttribute("SearchName", string.lower(Config.Name or ""))
            local Lbl = Instance.new("TextLabel")
            Lbl.Parent=F; Lbl.BackgroundTransparency=1; Lbl.Size=UDim2.new(0.7,0,1,0)
            Lbl.Position=UDim2.new(0,10,0,0); Lbl.Text=Config.Name or ""; Lbl.TextColor3=S.TextColor
            Lbl.TextXAlignment=Enum.TextXAlignment.Left; Lbl.TextSize=16; Lbl.Font=Enum.Font.SourceSans
            local Locked = AL(F, Config)
            local Toggled = Config.CurrentValue or false
            local SwitchBg = Instance.new("Frame")
            SwitchBg.Parent=F; SwitchBg.BackgroundColor3=Color3.fromRGB(40,40,40)
            SwitchBg.Position=UDim2.new(1,-60,0.5,-12); SwitchBg.Size=UDim2.new(0,50,0,24)
            Instance.new("UICorner",SwitchBg).CornerRadius=UDim.new(1,0)
            -- Rainbow stroke pour style 3
            if Style == 3 then
                local RS = Instance.new("UIStroke"); RS.Parent=SwitchBg; RS.Thickness=2
                task.spawn(function() local h=0
                    while SwitchBg.Parent do h=(h+0.006)%1; RS.Color=Color3.fromHSV(h,1,1); task.wait(0.025) end
                end)
            end
            local Knob = Instance.new("Frame")
            Knob.Parent=SwitchBg; Knob.BackgroundColor3=S.TextColor
            Knob.Position=UDim2.new(0,2,0.5,-10); Knob.Size=UDim2.new(0,20,0,20)
            Instance.new("UICorner",Knob).CornerRadius=UDim.new(1,0)
            table.insert(AT, {Callback=Config.Callback})
            local function Update()
                local tp = Toggled and UDim2.new(1,-22,0.5,-10) or UDim2.new(0,2,0.5,-10)
                local tc = Toggled and S.AccentColor or Color3.fromRGB(40,40,40)
                TS:Create(Knob,TweenInfo.new(0.2),{Position=tp}):Play()
                TS:Create(SwitchBg,TweenInfo.new(0.2),{BackgroundColor3=tc}):Play()
                if Config.Callback then Config.Callback(Toggled) end
            end
            if Toggled then Update() end
            local CB = Instance.new("TextButton"); CB.Parent=SwitchBg
            CB.BackgroundTransparency=1; CB.Size=UDim2.new(1,0,1,0); CB.Text=""
            if not Locked then CB.MouseButton1Click:Connect(function() Toggled=not Toggled; Update() end)
            else CB.Active=false end
            function RT:Set(v) Toggled=v; Update() end
            return RT
        end

        -- LABEL
        function Reg.Label(Page, Config)
            local RT = {}
            local F = Instance.new("Frame"); F.Parent=Page; F.BackgroundTransparency=1; F.Size=UDim2.new(1,-10,0,25)
            F:SetAttribute("SearchName", string.lower(Config.Text or ""))
            local T = Instance.new("TextLabel"); T.Parent=F; T.BackgroundTransparency=1
            T.Size=UDim2.new(1,0,1,0); T.Position=UDim2.new(0,10,0,0); T.Text=Config.Text or ""
            T.TextColor3=S.SubTextColor; T.TextXAlignment=Enum.TextXAlignment.Left
            T.Font=Enum.Font.SourceSans; T.TextSize=16
            function RT:Set(t) T.Text=t end; return RT
        end

        -- SECTION
        function Reg.Section(Page, Config)
            local RT = {}
            local F = Instance.new("Frame"); F.Parent=Page; F.BackgroundTransparency=1; F.Size=UDim2.new(1,-10,0,30)
            F:SetAttribute("SearchName", string.lower(Config.Text or ""))
            local T = Instance.new("TextLabel"); T.Parent=F; T.BackgroundTransparency=1
            T.Size=UDim2.new(1,0,1,0); T.Position=UDim2.new(0,10,0,0); T.Text=Config.Text or ""
            T.TextColor3=S.AccentColor; T.TextXAlignment=Enum.TextXAlignment.Left
            T.Font=Enum.Font.SourceSansBold; T.TextSize=18
            function RT:Set(t) T.Text=t end; return RT
        end

        -- DIVIDER
        function Reg.Divider(Page, Config)
            local RT = {}
            local F = Instance.new("Frame"); F.Parent=Page; F.BackgroundTransparency=1; F.Size=UDim2.new(1,-10,0,10)
            local L = Instance.new("Frame"); L.Parent=F; L.BackgroundColor3=Color3.fromRGB(60,60,60)
            L.Size=UDim2.new(1,0,0,2); L.Position=UDim2.new(0,0,0.5,0); L.BorderSizePixel=0
            function RT:Set(v) F.Visible=v end; return RT
        end

        -- PARAGRAPH
        function Reg.Paragraph(Page, Config)
            local RT = {}
            local F = Instance.new("Frame"); F.Parent=Page; F.BackgroundTransparency=1; F.Size=UDim2.new(1,-10,0,60)
            F:SetAttribute("SearchName", string.lower(Config.Title or ""))
            local T1 = Instance.new("TextLabel"); T1.Parent=F; T1.BackgroundTransparency=1
            T1.Size=UDim2.new(1,0,0,20); T1.Position=UDim2.new(0,10,0,0); T1.Text=Config.Title or ""
            T1.TextColor3=S.AccentColor; T1.TextXAlignment=Enum.TextXAlignment.Left
            T1.Font=Enum.Font.SourceSansBold; T1.TextSize=16
            local T2 = Instance.new("TextLabel"); T2.Parent=F; T2.BackgroundTransparency=1
            T2.Size=UDim2.new(1,-20,0,40); T2.Position=UDim2.new(0,10,0,20); T2.Text=Config.Content or ""
            T2.TextColor3=Color3.new(0.8,0.8,0.8); T2.TextXAlignment=Enum.TextXAlignment.Left
            T2.Font=Enum.Font.SourceSans; T2.TextSize=14; T2.TextWrapped=true
            function RT:Set(c) if c.Title then T1.Text=c.Title end; if c.Content then T2.Text=c.Content end end
            return RT
        end

        -- INPUT
        function Reg.Input(Page, Config)
            local RT = {}
            local F = Instance.new("Frame"); F.Parent=Page; F.BackgroundColor3=Color3.fromRGB(30,30,30)
            F.Size=UDim2.new(1,-10,0,35); Instance.new("UICorner",F).CornerRadius=UDim.new(0,6)
            F:SetAttribute("SearchName", string.lower(Config.Name or ""))
            local L = Instance.new("TextLabel"); L.Parent=F; L.BackgroundTransparency=1
            L.Position=UDim2.new(0,10,0,0); L.Size=UDim2.new(0.5,0,1,0); L.Text=Config.Name or ""
            L.TextColor3=S.TextColor; L.TextXAlignment=Enum.TextXAlignment.Left
            L.Font=Enum.Font.SourceSans; L.TextSize=16
            local Box = Instance.new("TextBox"); Box.Parent=F; Box.BackgroundColor3=Color3.fromRGB(40,40,40)
            Box.Position=UDim2.new(0.6,0,0.15,0); Box.Size=UDim2.new(0.38,0,0.7,0)
            Box.Font=Enum.Font.SourceSans; Box.Text=Config.CurrentValue or ""; Box.PlaceholderText=Config.PlaceholderText or ""
            Box.TextColor3=Color3.new(1,1,1); Box.TextSize=14
            Instance.new("UICorner",Box).CornerRadius=UDim.new(0,4)
            Box.FocusLost:Connect(function() if Config.Callback then Config.Callback(Box.Text) end end)
            function RT:Set(t) Box.Text=t end; return RT
        end

        -- KEYBIND
        function Reg.Keybind(Page, Config)
            local RT = {}
            local F = Instance.new("Frame"); F.Parent=Page; F.BackgroundColor3=Color3.fromRGB(30,30,30)
            F.Size=UDim2.new(1,-10,0,35); Instance.new("UICorner",F).CornerRadius=UDim.new(0,6)
            F:SetAttribute("SearchName", string.lower(Config.Name or ""))
            local L = Instance.new("TextLabel"); L.Parent=F; L.BackgroundTransparency=1
            L.Size=UDim2.new(0.7,0,1,0); L.Position=UDim2.new(0,10,0,0); L.Text=Config.Name or ""
            L.TextColor3=S.TextColor; L.TextXAlignment=Enum.TextXAlignment.Left
            L.Font=Enum.Font.SourceSans; L.TextSize=16
            local BB = Instance.new("TextButton"); BB.Parent=F; BB.BackgroundColor3=Color3.fromRGB(40,40,40)
            BB.Position=UDim2.new(1,-80,0.5,-12); BB.Size=UDim2.new(0,70,0,24)
            BB.Text=UIS:GetStringForKeyCode(S.Keybind); BB.Font=Enum.Font.SourceSansBold
            BB.TextColor3=S.TextColor; BB.TextSize=14
            Instance.new("UICorner",BB).CornerRadius=UDim.new(0,6)
            BB.MouseButton1Click:Connect(function()
                BB.Text="..."
                local Conn; Conn=UIS.InputBegan:Connect(function(input)
                    if input.UserInputType==Enum.UserInputType.Keyboard then
                        S.Keybind=input.KeyCode; BB.Text=UIS:GetStringForKeyCode(input.KeyCode)
                        Conn:Disconnect()
                    end
                end)
            end)
            function RT:Set(k) BB.Text=k end; return RT
        end

        -- DROPDOWN
        function Reg.Dropdown(Page, Config)
            local RT = {}
            local F = Instance.new("Frame"); F.Parent=Page; F.BackgroundColor3=Color3.fromRGB(30,30,30)
            F.Size=UDim2.new(1,-10,0,35); F.ClipsDescendants=true
            Instance.new("UICorner",F).CornerRadius=UDim.new(0,6)
            F:SetAttribute("SearchName", string.lower(Config.Name or ""))
            local Locked = AL(F, Config)
            local Open=false; local Options=Config.Options or {}; local Current=Config.CurrentOption or Options[1] or "..."
            local MB = Instance.new("TextButton"); MB.Parent=F; MB.BackgroundTransparency=1
            MB.Size=UDim2.new(1,0,0,35); MB.Font=Enum.Font.SourceSans
            MB.Text="  "..(Config.Name or "")..": "..Current; MB.TextColor3=Color3.new(1,1,1)
            MB.TextSize=16; MB.TextXAlignment=Enum.TextXAlignment.Left
            local OC = Instance.new("Frame"); OC.Parent=F; OC.BackgroundTransparency=1
            OC.Position=UDim2.new(0,0,0,35); OC.Size=UDim2.new(1,0,0,0); OC.Visible=false
            Instance.new("UIListLayout",OC).SortOrder=Enum.SortOrder.LayoutOrder
            local function Refresh(List)
                for _,v in pairs(OC:GetChildren()) do if v:IsA("TextButton") then v:Destroy() end end
                Options=List
                for _,opt in ipairs(Options) do
                    local OB=Instance.new("TextButton"); OB.Parent=OC; OB.BackgroundColor3=Color3.fromRGB(35,35,35)
                    OB.Size=UDim2.new(1,0,0,30); OB.Text="  "..opt; OB.TextColor3=S.TextColor
                    OB.TextXAlignment=Enum.TextXAlignment.Left; OB.Font=Enum.Font.SourceSans; OB.TextSize=15
                    OB.MouseButton1Click:Connect(function()
                        Current=opt; MB.Text="  "..(Config.Name or "")..": "..opt; Open=false
                        TS:Create(F,TweenInfo.new(0.2,Enum.EasingStyle.Quad,Enum.EasingDirection.In),{Size=UDim2.new(1,-10,0,35)}):Play()
                        task.wait(0.2); OC.Visible=false
                        if Config.Callback then Config.Callback(opt) end
                    end)
                end
            end
            Refresh(Options)
            if not Locked then
                MB.MouseButton1Click:Connect(function()
                    Open=not Open
                    if Open then OC.Visible=true
                        TS:Create(F,TweenInfo.new(0.2,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{Size=UDim2.new(1,-10,0,35+#Options*30)}):Play()
                    else
                        TS:Create(F,TweenInfo.new(0.2,Enum.EasingStyle.Quad,Enum.EasingDirection.In),{Size=UDim2.new(1,-10,0,35)}):Play()
                        task.wait(0.2); OC.Visible=false
                    end
                end)
            else MB.Active=false end
            function RT:Refresh(l) Refresh(l) end
            function RT:Set(o) Current=o; MB.Text="  "..(Config.Name or "")..": "..o end
            return RT
        end

        -- COLOR PICKER (simplifié)
        function Reg.ColorPicker(Page, Config)
            local RT = {}
            local F = Instance.new("Frame"); F.Parent=Page; F.BackgroundColor3=Color3.fromRGB(30,30,30)
            F.Size=UDim2.new(1,-10,0,160); Instance.new("UICorner",F).CornerRadius=UDim.new(0,6)
            F:SetAttribute("SearchName", string.lower(Config.Name or ""))
            local Locked=AL(F,Config)
            local L=Instance.new("TextLabel"); L.Parent=F; L.BackgroundTransparency=1
            L.Position=UDim2.new(0,10,0,5); L.Size=UDim2.new(1,0,0,20); L.Text=Config.Name or ""
            L.TextColor3=S.TextColor; L.TextXAlignment=Enum.TextXAlignment.Left
            L.Font=Enum.Font.SourceSansBold; L.TextSize=16
            local Preview=Instance.new("Frame"); Preview.Parent=F
            Preview.Position=UDim2.new(0,10,0,30); Preview.Size=UDim2.new(0,30,0,30)
            Preview.BackgroundColor3=Config.Color or Color3.new(1,1,1)
            Instance.new("UICorner",Preview).CornerRadius=UDim.new(0,4)
            local SVBox=Instance.new("TextButton"); SVBox.Parent=F; SVBox.BackgroundColor3=Color3.new(1,0,0)
            SVBox.Position=UDim2.new(0,60,0,30); SVBox.Size=UDim2.new(0,150,0,100); SVBox.Text=""
            local SVG=Instance.new("UIGradient"); SVG.Parent=SVBox
            SVG.Color=ColorSequence.new{ColorSequenceKeypoint.new(0,Color3.new(1,1,1)),ColorSequenceKeypoint.new(1,Color3.new(1,0,0))}
            local SVI=Instance.new("ImageLabel"); SVI.Parent=SVBox; SVI.Size=UDim2.new(1,0,1,0)
            SVI.Image="rbxassetid://156579757"; SVI.BackgroundTransparency=1
            local HueBar=Instance.new("TextButton"); HueBar.Parent=F; HueBar.Text=""
            HueBar.Position=UDim2.new(0,60,0,135); HueBar.Size=UDim2.new(0,150,0,15)
            local HG=Instance.new("UIGradient"); HG.Parent=HueBar
            HG.Color=ColorSequence.new{ColorSequenceKeypoint.new(0,Color3.new(1,0,0)),ColorSequenceKeypoint.new(0.167,Color3.new(1,1,0)),ColorSequenceKeypoint.new(0.333,Color3.new(0,1,0)),ColorSequenceKeypoint.new(0.5,Color3.new(0,1,1)),ColorSequenceKeypoint.new(0.667,Color3.new(0,0,1)),ColorSequenceKeypoint.new(0.833,Color3.new(1,0,1)),ColorSequenceKeypoint.new(1,Color3.new(1,0,0))}
            local H2,SA,V2=0,1,1
            local function UC(nh,ns,nv)
                H2=nh or H2; SA=ns or SA; V2=nv or V2
                local Col=Color3.fromHSV(H2,SA,V2); Preview.BackgroundColor3=Col
                SVBox.BackgroundColor3=Color3.fromHSV(H2,1,1)
                if Config.Callback then Config.Callback(Col) end
            end
            if not Locked then
                local dH,dSV=false,false
                UIS.InputChanged:Connect(function(i)
                    if i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch then
                        if dH then UC(math.clamp((i.Position.X-HueBar.AbsolutePosition.X)/HueBar.AbsoluteSize.X,0,1),nil,nil)
                        elseif dSV then UC(nil,math.clamp((i.Position.X-SVBox.AbsolutePosition.X)/SVBox.AbsoluteSize.X,0,1),1-math.clamp((i.Position.Y-SVBox.AbsolutePosition.Y)/SVBox.AbsoluteSize.Y,0,1)) end
                    end
                end)
                HueBar.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then dH=true end end)
                SVBox.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then dSV=true end end)
                UIS.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then dH=false; dSV=false end end)
            end
            if Config.Color then local h,s,v=Config.Color:ToHSV(); UC(h,s,v) end
            function RT:Set(c) local h,s,v=c:ToHSV(); UC(h,s,v) end
            return RT
        end

        -- MINI CARD (cadre 100×150 : image + texte + bouton/toggle)
        function Reg.MiniCard(Page, Config)
            local RT = {}
            local Corner = function(P,S2) local c=Instance.new("UICorner"); c.Parent=P; c.CornerRadius=(S2=="Square") and UDim.new(0,4) or UDim.new(0,12); return c end
            -- Conteneur en grille 4 par ligne
            local Grid=Page:FindFirstChild("MiniCardGrid")
            if not Grid then
                Grid=Instance.new("Frame"); Grid.Name="MiniCardGrid"; Grid.Parent=Page
                Grid.BackgroundTransparency=1; Grid.Size=UDim2.new(1,-10,0,0); Grid.AutomaticSize=Enum.AutomaticSize.Y
                local P2=Instance.new("UIPadding"); P2.Parent=Grid
                P2.PaddingLeft=UDim.new(0,4); P2.PaddingRight=UDim.new(0,4); P2.PaddingTop=UDim.new(0,4)
                local GL=Instance.new("UIGridLayout"); GL.Parent=Grid
                GL.SortOrder=Enum.SortOrder.LayoutOrder; GL.CellPadding=UDim2.new(0,6,0,6)
                GL.CellSize=UDim2.new(0,100,0,150); GL.FillDirectionMaxCells=4
                GL.HorizontalAlignment=Enum.HorizontalAlignment.Left
            end
            local Card=Instance.new("Frame"); Card.Parent=Grid
            Card.BackgroundColor3=Color3.fromRGB(28,28,28); Card.Size=UDim2.new(1,0,1,0)
            Card:SetAttribute("SearchName", string.lower(Config.Name or ""))
            Corner(Card, Config.BaseShape)
            local CS=Instance.new("UIStroke"); CS.Parent=Card
            CS.Color=Config.StrokeColor or Color3.fromRGB(55,55,55); CS.Thickness=1
            CS.ApplyStrokeMode=Enum.ApplyStrokeMode.Border
            -- Image (moitié haute)
            local Img=Instance.new("ImageLabel"); Img.Name="Icon"; Img.Parent=Card
            Img.BackgroundColor3=Color3.fromRGB(40,40,40); Img.BackgroundTransparency=0.2
            Img.Position=UDim2.new(0,6,0,6); Img.Size=UDim2.new(1,-12,0,72)
            Img.Image=Config.Image or ""; Img.ScaleType=Enum.ScaleType.Fit
            Corner(Img, Config.BaseShape)
            -- Texte (milieu bas)
            local NL=Instance.new("TextLabel"); NL.Parent=Card
            NL.BackgroundTransparency=1; NL.Position=UDim2.new(0,4,0,82); NL.Size=UDim2.new(1,-8,0,18)
            NL.Font=Enum.Font.SourceSansBold; NL.Text=Config.Name or ""
            NL.TextColor3=S.TextColor; NL.TextSize=13; NL.TextWrapped=true
            -- Bouton/Toggle (bas)
            local Mode=Config.Mode or "Button"
            local ActionRow=Instance.new("Frame"); ActionRow.Parent=Card
            ActionRow.AnchorPoint=Vector2.new(0.5,0); ActionRow.Position=UDim2.new(0.5,0,0,106)
            ActionRow.Size=UDim2.new(1,-12,0,34); ActionRow.BackgroundColor3=Color3.fromRGB(40,40,40)
            Corner(ActionRow, Config.ButtonShape)
            if Mode=="Toggle" then
                local BL=Instance.new("TextLabel"); BL.Parent=ActionRow
                BL.BackgroundTransparency=1; BL.Position=UDim2.new(0,6,0,0); BL.Size=UDim2.new(0.55,0,1,0)
                BL.Font=Enum.Font.SourceSansBold; BL.Text=Config.ButtonText or ""; BL.TextColor3=S.TextColor
                BL.TextSize=12; BL.TextXAlignment=Enum.TextXAlignment.Left
                local Pill=Instance.new("Frame"); Pill.Parent=ActionRow
                Pill.BackgroundColor3=Color3.fromRGB(40,40,40)
                Pill.AnchorPoint=Vector2.new(1,0.5); Pill.Position=UDim2.new(1,-4,0.5,0); Pill.Size=UDim2.new(0,44,0,20)
                Instance.new("UICorner",Pill).CornerRadius=UDim.new(1,0)
                local Knob=Instance.new("Frame"); Knob.Parent=Pill
                Knob.BackgroundColor3=Color3.fromRGB(220,220,220); Knob.AnchorPoint=Vector2.new(0,0.5)
                Knob.Position=UDim2.new(0,2,0.5,0); Knob.Size=UDim2.new(0,16,0,16)
                Instance.new("UICorner",Knob).CornerRadius=UDim.new(1,0)
                local Toggled=Config.CurrentValue or false
                local CB=Instance.new("TextButton"); CB.Parent=Pill; CB.BackgroundTransparency=1; CB.Size=UDim2.new(1,0,1,0); CB.Text=""
                local function UpT()
                    local tp=Toggled and UDim2.new(1,-18,0.5,0) or UDim2.new(0,2,0.5,0)
                    local tc=Toggled and S.AccentColor or Color3.fromRGB(40,40,40)
                    TS:Create(Knob,TweenInfo.new(0.2),{Position=tp}):Play(); TS:Create(Pill,TweenInfo.new(0.2),{BackgroundColor3=tc}):Play()
                    if Config.Callback then Config.Callback(Toggled) end
                end
                if Toggled then UpT() end
                CB.MouseButton1Click:Connect(function() Toggled=not Toggled; UpT() end)
                function RT:Set(v) Toggled=v; UpT() end
            else
                local AB=Instance.new("TextButton"); AB.Parent=ActionRow; AB.BackgroundTransparency=1
                AB.Size=UDim2.new(1,0,1,0); AB.Font=Enum.Font.SourceSansBold; AB.Text=Config.ButtonText or ""
                AB.TextColor3=S.TextColor; AB.TextSize=14
                AB.MouseButton1Click:Connect(function()
                    TS:Create(ActionRow,TweenInfo.new(0.1),{BackgroundColor3=Color3.fromRGB(60,60,60)}):Play()
                    task.wait(0.1); TS:Create(ActionRow,TweenInfo.new(0.1),{BackgroundColor3=Color3.fromRGB(40,40,40)}):Play()
                    if Config.Callback then Config.Callback() end
                end)
                function RT:Set(v) AB.Text=tostring(v) end
            end
            -- Hover sur le bouton uniquement (agrandissement centré)
            -- Config.HoverEffect = false pour désactiver
            -- Config.HoverStroke = true pour activer le changement de couleur du contour
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
                        TS:Create(CS, TweenInfo.new(0.15), {
                            Color=Config.StrokeColor or Color3.fromRGB(55,55,55), Thickness=1
                        }):Play()
                    end
                end)
            end
            function RT:SetImage(i) Img.Image=i end
            function RT:SetText(t) NL.Text=t; Card:SetAttribute("SearchName",string.lower(t)) end
            function RT:SetButtonText(t)
                for _,c in pairs(ActionRow:GetChildren()) do
                    if c:IsA("TextLabel") or c:IsA("TextButton") then c.Text=t end
                end
            end
            return RT
        end

        return Reg
    end

    -- [ FONCTIONS DE CRÉATION D'ÉLÉMENTS ] --

    -- Pré-chargement en parallèle dès CreateWindow (plus besoin d'attendre au 1er CreateElement)
    -- Si GitHub est inaccessible → le fallback intégré prend le relais automatiquement
    do
        local function LoadButtons()
            local ok, res = pcall(function()
                return loadstring(game:HttpGet(BUTTONS_URL))()(ModuleCtx)
            end)
            if ok and res then
                ButtonRegistry = res
            else
                warn("[SoroniceLib] Buttons GitHub inaccessible → fallback intégré actif")
                ButtonRegistry = MakeFallbackButtons(ModuleCtx)
            end
        end
        local function LoadIconCard()
            local ok, res = pcall(function()
                return loadstring(game:HttpGet(ICONCARD_URL))()(ModuleCtx)
            end)
            if ok and res then
                IconCardFn = res
            else
                warn("[SoroniceLib] IconCard GitHub inaccessible → MiniCard fallback actif")
                IconCardFn = nil  -- MiniCard disponible via ButtonRegistry["MiniCard"]
            end
        end
        local function LoadMiniCard()
            local ok, res = pcall(function()
                return loadstring(game:HttpGet(MINICARD_URL))()(ModuleCtx)
            end)
            if ok and res then
                MiniCardFn = res
            else
                warn("[SoroniceLib] minicard.lua GitHub inaccessible → fallback intégré actif")
                MiniCardFn = nil  -- utilisera ButtonRegistry["MiniCard"] (fallback intégré)
            end
        end
        -- Chargement synchrone (les onglets apparaissent dès que c'est prêt)
        LoadButtons()
        LoadIconCard()
        LoadMiniCard()
    end

    local function CreateElement(Page, Type, Config)
        Config = Config or {}
        local RT = {}
        if Type == "IconCard" then
            if IconCardFn then
                RT = IconCardFn(Page, Config) or {}
            elseif ButtonRegistry and ButtonRegistry["MiniCard"] then
                RT = ButtonRegistry["MiniCard"](Page, Config) or {}
            end
        elseif Type == "MiniCard" then
            if MiniCardFn then
                RT = MiniCardFn(Page, Config) or {}
            elseif ButtonRegistry and ButtonRegistry["MiniCard"] then
                RT = ButtonRegistry["MiniCard"](Page, Config) or {}
            end
        elseif ButtonRegistry and ButtonRegistry[Type] then
            RT = ButtonRegistry[Type](Page, Config) or {}
        end
        return RT
    end
    -- Rend CreateElement disponible au module Settings
    ModuleCtx.CreateElement = CreateElement

    -- ============================================================
    -- CHARGEMENT DU MODULE SETTINGS depuis GitHub
    -- Si inaccessible, fallback sur le bloc Settings intégré
    -- ============================================================
    do
        local ok, SettingsSetup = pcall(function()
            return loadstring(game:HttpGet(SETTINGS_URL))()(ModuleCtx)
        end)
        if not ok then
            warn("[SoroniceLib] Module Settings GitHub inaccessible — fallback intégré : " .. tostring(SettingsSetup))
            -- Fallback : éléments Settings directement ici
            CreateElement(SettingsPage, "Toggle", {
                Name = "💤 Mode AFK (Anti-Kick)",
                CurrentValue = false,
                Callback = function(Value)
                    antiAfkRef.value = Value
                    if Value then game.StarterGui:SetCore("SendNotification", {Title="Anti-AFK", Text="Activé.", Duration=3}) end
                end
            })
            if not IsMobile then
                CreateElement(SettingsPage, "Keybind", {Name = "Touche pour Cacher/Montrer", Callback = function() end})
            end
        end
    end



	function WindowFunctions:CreateTab(TabName, TabImageId, LockConfig) 
		local TabBtn = Instance.new("TextButton")
        TabBtn.Parent = SidebarScroll
		TabBtn.BackgroundColor3 = Color3.new(0,0,0)
        TabBtn.BackgroundTransparency=0.5
        TabBtn.Size=UDim2.new(0,45,0,45)
        TabBtn.Text=""
        Instance.new("UICorner", TabBtn).CornerRadius = UDim.new(0,8)
		if TabImageId and TabImageId ~= 0 then
			local Icon = Instance.new("ImageLabel")
            Icon.Parent = TabBtn
            Icon.BackgroundTransparency=1
            Icon.Position=UDim2.new(0,5,0,5)
            Icon.Size=UDim2.new(0,35,0,35)
            Icon.Image="rbxassetid://"..tostring(TabImageId)
		else
			TabBtn.Text = string.sub(TabName, 1, 1)
            TabBtn.TextColor3 = Color3.new(0.8,0.8,0.8)
            TabBtn.TextSize=20
            TabBtn.Font=Enum.Font.SourceSansBold
		end

        local IsButtonLocked = false
        if LockConfig and LockConfig.Locked then
             if LockConfig.LockMode ~= "Frame" then 
                 IsButtonLocked = ApplyLock(TabBtn, LockConfig) 
             end
        end

		local Page = Instance.new("ScrollingFrame")
        Page.Parent = ContentContainer
        Page.BackgroundTransparency=1
        Page.Size=UDim2.new(1,0,1,0)
        Page.ScrollBarThickness=6
        Page.Visible=FirstTab
        Page.AutomaticCanvasSize = Enum.AutomaticSize.Y 
        Page.CanvasSize = UDim2.new(0,0,0,0)
        Page.VerticalScrollBarInset = Enum.ScrollBarInset.None

        local PageLayout = Instance.new("UIListLayout")
        PageLayout.Parent = Page
        PageLayout.Padding = UDim.new(0,8)
        PageLayout.SortOrder = Enum.SortOrder.LayoutOrder

        if LockConfig and LockConfig.Locked and LockConfig.LockMode == "Frame" then 
            ApplyLock(Page, LockConfig) 
        end

		TabBtn.MouseButton1Click:Connect(function()
            if IsButtonLocked then return end
            if SearchOpen then ToggleSearch() end
			for _,v in pairs(ContentContainer:GetChildren()) do v.Visible=false end
			Page.Visible=true
            TweenService:Create(SettingsBtn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(0,0,0)}):Play()
		end)
		FirstTab = false

		local TabFunctions = {}
		function TabFunctions:CreateButton(Config) return CreateElement(Page, "Button", Config) end
        function TabFunctions:CreateToggle(Config) return CreateElement(Page, "Toggle", Config) end
        function TabFunctions:CreateColorPicker(Config) return CreateElement(Page, "ColorPicker", Config) end 
        function TabFunctions:CreateSection(Text) return CreateElement(Page, "Section", {Text=Text}) end
        function TabFunctions:CreateLabel(Text) return CreateElement(Page, "Label", {Text=Text}) end
        function TabFunctions:CreateDropdown(Config) return CreateElement(Page, "Dropdown", Config) end
        function TabFunctions:CreateInput(Config) return CreateElement(Page, "Input", Config) end 
        function TabFunctions:CreateParagraph(Config) return CreateElement(Page, "Paragraph", Config) end 
        function TabFunctions:CreateDivider() return CreateElement(Page, "Divider", {}) end 
        function TabFunctions:CreateIconCard(Config) return CreateElement(Page, "IconCard", Config) end 
        function TabFunctions:CreateMiniCard(Config) return CreateElement(Page, "MiniCard", Config) end 
        
        function TabFunctions:CreateSlider(Config)
             local SliderFrame = Instance.new("Frame")
             SliderFrame.Parent = Page
             SliderFrame.BackgroundTransparency=1
             SliderFrame.Size=UDim2.new(1,-10,0,50)
             SliderFrame:SetAttribute("SearchName", string.lower(Config.Name))
             
             local Locked = ApplyLock(SliderFrame, Config)
             local Label = Instance.new("TextLabel")
             Label.Parent = SliderFrame
             Label.BackgroundTransparency=1
             Label.Position=UDim2.new(0,10,0,0)
             Label.Size=UDim2.new(1,0,0,20)
             Label.Text=Config.Name
             Label.TextColor3=Color3.new(1,1,1)
             Label.TextXAlignment=Enum.TextXAlignment.Left
             Label.Font=Enum.Font.SourceSans
             Label.TextSize=16

             local ValLabel = Instance.new("TextLabel")
             ValLabel.Parent = SliderFrame
             ValLabel.BackgroundTransparency=1
             ValLabel.Position=UDim2.new(1,-60,0,0)
             ValLabel.Size=UDim2.new(0,50,0,20)
             ValLabel.TextColor3=Color3.new(1,1,1)
             ValLabel.TextXAlignment=Enum.TextXAlignment.Right
             ValLabel.Font=Enum.Font.SourceSansBold
             ValLabel.TextSize=16

             local Bar = Instance.new("Frame")
             Bar.Parent = SliderFrame
             Bar.BackgroundColor3=Color3.fromRGB(10,10,10)
             Bar.Position=UDim2.new(0,10,0,25)
             Bar.Size=UDim2.new(1,-20,0,10)
             Instance.new("UICorner", Bar).CornerRadius=UDim.new(1,0)

             local Knob = Instance.new("TextButton")
             Knob.Parent = Bar
             Knob.BackgroundColor3=Settings.AccentColor
             Knob.Size=UDim2.new(0,20,0,20)
             Knob.AnchorPoint=Vector2.new(0.5,0.5)
             Knob.Position=UDim2.new(0,0,0.5,0)
             Knob.Text=""
             Instance.new("UICorner", Knob).CornerRadius=UDim.new(1,0)

             local Min, Max = Config.Range[1] or 0, Config.Range[2] or 100
             local Default = Config.CurrentValue or Min
             ValLabel.Text = tostring(Default).."%"
             Knob.Position = UDim2.new((Default-Min)/(Max-Min), 0, 0.5, 0)
             
             if not Locked then
                 local dragging = false
                 Knob.InputBegan:Connect(function(input) 
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = true end 
                 end)
                 UserInputService.InputEnded:Connect(function(input) 
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = false end 
                 end)
                 UserInputService.InputChanged:Connect(function(input)
                    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                        local Percent = math.clamp((input.Position.X - Bar.AbsolutePosition.X)/Bar.AbsoluteSize.X, 0, 1)
                        Knob.Position = UDim2.new(Percent, 0, 0.5, 0)
                        local Val = math.floor(Min + (Max-Min)*Percent)
                        ValLabel.Text = tostring(Val).."%"
                        if Config.Callback then Config.Callback(Val) end
                    end
                 end)
            else
                Knob.Active = false 
            end
            
            local SliderObj = {}
            function SliderObj:Set(Value)
                 local Percent = (Value - Min) / (Max - Min)
                 Knob.Position = UDim2.new(Percent, 0, 0.5, 0)
                 ValLabel.Text = tostring(Value).."%"
                 if Config.Callback then Config.Callback(Value) end
            end
            return SliderObj
        end
		return TabFunctions
	end
	return WindowFunctions
end
return SoroniceLib
