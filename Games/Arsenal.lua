assert(Drawing, "Exploit not supported.")

repeat task.wait()

until game:IsLoaded()

local current = tick()

local runService = game:GetService("RunService")
local playerService = game:GetService("Players")
local userInputService = game:GetService("UserInputService")
local replicatedStorage = game:GetService("ReplicatedStorage")
local coreGui = game:GetService("CoreGui")
local lightingService = game:GetService("Lighting")

local localPlayer = playerService.LocalPlayer
local localCharacter = localPlayer.Character or localPlayer.CharacterAdded:Wait()
local humanoid = localCharacter:WaitForChild("Humanoid")

local camera = workspace.CurrentCamera
local mouse = localPlayer:GetMouse()


local meleeTable = {}

for _, melee in pairs(replicatedStorage.ItemData.Images.Melees:GetChildren()) do
    table.insert(meleeTable, melee.Name)
end

table.sort(meleeTable, function(a,b)
    return b > a
end)

local skinTable = {}

for _, skin in pairs(replicatedStorage.Skins:GetChildren()) do
    table.insert(skinTable, skin.Name)
end

table.sort(skinTable, function(a,b)
    return b > a
end)

local repo = "https://raw.githubusercontent.com/pr3cisionn/Librarys/main/"

local Library = loadstring(game:HttpGet(repo .. "Library.lua"))()
local ThemeManager = loadstring(game:HttpGet(repo .. "ThemeManager.lua"))()
local SaveManager = loadstring(game:HttpGet(repo .. "SaveManager.lua"))()

local settings = {
    Hitparts = {
        "Head",
        "LowerTorso",
        "UpperTorso",
        "HumanoidRootPart",
    },
    Aimbot = {
        Enabled = false,
        Wallcheck = false,
        Teamcheck = false,
        Hitpart = "Head",
        Smoothness = 0.5,

        isAiming = false,

        Notifications = false,

        FOV = {
            Enabled = false,
            Radius = 100,
            Colour = Color3.new(1, 0, 0),
        },
    },
    Silent = {
        Enabled = false,
        UseChance = false,
        Teamcheck = false,
        HeadChance = 50,
        BodyChance = 50,
        Hitpart = "Head",
        ToHit = "Head",

        Target = nil,
        OnScreen = false,

        FOV = {
            Enabled = false,
            Radius = 50,
            Colour = Color3.new(0, 0, 1),
        },
    },
    Trigger = {
        Enabled = false,
        Delay = 50,
        Teamcheck = false,
    },
    Visual = {
        Teamcheck = false,
        Line = {
            Enabled = false,
            Colour = Color3.new(1,1,1),
            UseTC = false,
            StartPosition = "Bottom",
        },
        Box = {
            Enabled = false,
            Outline = false,
            Colour = Color3.new(1,1,1),
            UseTC = false,
        },
        Name = {
            Enabled = false,
            Outline = false,
            Autoscale = false,
            UseTC = false,
            Colour = Color3.new(1,1,1),
            Font = 3,
            Size = 16,
        },
        Head = {
            Enabled = false,
            Filled = false,
            Colour = Color3.new(1,1,1),
            UseTC = false,
        },
        Chams = {
            Enabled = false,
            FillColour = Color3.new(1,1,1),
            OutlineColour = Color3.new(1,1,1),
            FillTransparency = 0.5,
            OutlineTransparency = 0,
            FillUseTC = false,
            OutlineUseTC = false,
        },
        Lighting = {
            CustomSkys = {
                "Default",
                "Galaxy 1",
                "Galaxy 2",
                "Cloudy 1",
                "Night 1",
                "Old 1",
                "Old 2",
                "Sunset 1",
            },

            Sky = "Default",
            Ambient = Color3.new(0,0,0),
            Brightness = 1,
        },
    },
    Swapper = {
        Melee = nil,

        Skin1 = nil,
        Skin2 = nil, 
    },
    Local = {
        ToggleWS = false,
        ToggleJP = false,

        ToggleBhop = false,
        BhopJumping = false,

        WS = 16,
        JP = 50,

        BS = 2,
    },
    Mods = {
        NoRecoil = false,
        NoSpread = false,
        FullAuto = false,
        FastEquip = false,
        FastReload = false,
        Firerate = false,
    },
    KickWhenMod = false,
}

local aimCircle = Drawing.new("Circle")
aimCircle.Visible = false

local silentCircle = Drawing.new("Circle")
silentCircle.Visible = false

userInputService.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == Enum.KeyCode.Space then
        settings.Local.BhopJumping = true
    end
end)

userInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == Enum.KeyCode.Space then
        settings.Local.BhopJumping = false
    end
end)

local swapSkin = function(skin1, skin2)
    if skin1 == nil or skin2 == nil then Library:Notify("Select a skin to swap/replace.") return end

    for i = 1,2 do
        if coreGui:FindFirstChild(skin1..i) then 
            coreGui[skin1..i]:Destroy()
        elseif coreGui:FindFirstChild(skin2..i) then
            coreGui[skin2..i]:Destroy()
        end
    end

    local c1 = replicatedStorage.Skins[skin2]:Clone()
    local c2 = replicatedStorage.Skins[skin1]:Clone()
    c1.Name = skin1
    c2.Name = skin2

    replicatedStorage.Skins[skin2]:Destroy()
    replicatedStorage.Skins[skin1]:Destroy()

    c1.Parent = replicatedStorage.Skins
    c2.Parent = replicatedStorage.Skins

    task.wait()
    Library:Notify("Swapped "..skin1.." with "..skin2..".")
end

local swapMelee = function(melee)
    if melee == nil then Library:Notify("Select a melee to swap.") return end

    localPlayer.Data.Shuffles.Melees:ClearAllChildren()

    local swapped = Instance.new("StringValue", localPlayer.Data.Shuffles.Melees)
    swapped.Name = melee

    Library:Notify("Changd Melee to "..melee..".")
end

local isVisible = function(character)
	if not settings.Aimbot.Wallcheck then return true end

    local ignore = {camera, localCharacter, workspace.Debris, workspace.Ray_Ignore, workspace.Map.Ignore}

	Origin = workspace.CurrentCamera.CFrame.p
	CheckRay = Ray.new(Origin, character.Head.Position - Origin)
	Hit = workspace:FindPartOnRayWithIgnoreList(CheckRay, ignore)
	if Hit.Parent == character then
	return true
	else
	return false
	end
end

local aim_teamCheck = function(player)
    if not settings.Aimbot.Teamcheck then return true end 

    if player.Team == localPlayer.Team then return false else return true end 
end

local silent_teamCheck = function(player)
    if not settings.Silent.Teamcheck then return true end 

    if player.Team == localPlayer.Team then return false else return true end 
end

local aim_getClosest = function()
    local maxdist, closest = math.huge, nil 

    for _, player in pairs(playerService:GetPlayers()) do
        if player ~= localPlayer and aim_teamCheck(player) then 
            local character = player.Character or player.CharacterAdded:Wait()

            if character and character:FindFirstChild("HumanoidRootPart") and character:FindFirstChild("Humanoid") and character:FindFirstChild("Humanoid").Health > 0 then 
                local pos = camera:WorldToViewportPoint(character.HumanoidRootPart.Position)
                local magnitude = (Vector2.new(mouse.X, mouse.Y) - Vector2.new(pos.X, pos.Y)).Magnitude 

                if magnitude < maxdist and magnitude < settings.Aimbot.FOV.Radius and isVisible(character) then 
                    maxdist, closest = magnitude, player
                end
            end
        end
    end

    return closest
end

local silent_getClosest = function()
    local maxdist, closest = math.huge, nil 

    for _, player in pairs(playerService:GetPlayers()) do
        if player ~= localPlayer and silent_teamCheck(player) then 
            local character = player.Character or player.CharacterAdded:Wait()

            if character and character:FindFirstChild("HumanoidRootPart") and character:FindFirstChild("Humanoid") and character:FindFirstChild("Humanoid").Health > 0 then 
                local pos = camera:WorldToViewportPoint(character.HumanoidRootPart.Position)
                local magnitude = (Vector2.new(mouse.X, mouse.Y) - Vector2.new(pos.X, pos.Y)).Magnitude 

                if magnitude < maxdist and magnitude < settings.Silent.FOV.Radius then 
                    maxdist, closest = magnitude, player
                end
            end
        end
    end

    return closest
end

local movemouse = function(vector2)
    vector2 = vector2 or Vector2.new(0,0)
    mousemoverel((vector2.X - mouse.X) * settings.Aimbot.Smoothness, (vector2.Y - mouse.Y) * settings.Aimbot.Smoothness)
end

local gunmod = function(num, value)
	local weaponsFolder = replicatedStorage.Weapons

	for i,v in pairs(weaponsFolder:GetChildren()) do 

		local backupFolder = coreGui:FindFirstChild("Backup") or Instance.new("Folder", coreGui)
		local backupWeapon = backupFolder:FindFirstChild(v.Name) or v:Clone()
		backupFolder.Name = "Backup"
		backupWeapon.Parent = backupFolder

		if num == 1 and v:FindFirstChild("Auto") then

			if value then
				v.Auto.Value = true
			else
				v.Auto.Value = backupWeapon.Auto.Value
			end
		end

		if num == 2 and v:FindFirstChild("Spread") and v:FindFirstChild("MaxSpread") then

			if value then
				v.Spread.Value = 0
				v.MaxSpread.Value = 0
			else
				v.Spread.Value = backupWeapon.Spread.Value
				v.MaxSpread.Value = backupWeapon.MaxSpread.Value
			end
		end

		if num == 3 and v:FindFirstChild("RecoilControl") then

			if value then
				v.RecoilControl.Value = 0
			else
				v.RecoilControl.Value = backupWeapon.RecoilControl.Value
			end
		end

		if num == 4 and v:FindFirstChild("EquipTime") then

			if value then
				v.EquipTime.Value = 0
			else
				v.EquipTime.Value = backupWeapon.EquipTime.Value
			end
		end

		if num == 5 and v:FindFirstChild("ReloadTime") then

			if value then
				v.ReloadTime.Value = 0
			else
				v.ReloadTime.Value = backupWeapon.ReloadTime.Value
			end
		end

		if num == 6 and v:FindFirstChild("FireRate") then

			if value then
				v.FireRate.Value = 0.05
			else
				v.FireRate.Value = backupWeapon.FireRate.Value
			end
		end

	end
end

local old = aim_getClosest()

local mainupdate = function()
    settings.Aimbot.Enabled = Toggles.ToggleAimbot.Value
    settings.Aimbot.Wallcheck = Toggles.AimbotWallcheck.Value
    settings.Aimbot.Teamcheck = Toggles.AimbotTeamcheck.Value 
    settings.Aimbot.isAiming = Options.AimBindPicker:GetState()
    settings.Aimbot.Smoothness = Options.AimbotSmoothness.Value 
    settings.Aimbot.Hitpart = Options.AimbotHitpart.Value
    settings.Aimbot.Notifications = Toggles.ToggleAimbotNotifications.Value
    settings.Aimbot.FOV.Enabled = Toggles.ToggleAimbotFOV.Value 
    settings.Aimbot.FOV.Radius = Options.AimbotFOVSize.Value 
    settings.Aimbot.FOV.Colour = Options.AimbotFOVColour.Value

    settings.Silent.Enabled = Toggles.ToggleSilent.Value 
    settings.Silent.Teamcheck = Toggles.ToggleSilentTeamcheck.Value
    settings.Silent.UseChance = Toggles.ToggleSilentUseChance.Value 
    settings.Silent.Hitpart = Options.SilentHitpart.Value
    settings.Silent.HeadChance = Options.SilentHeadChance.Value
    settings.Silent.BodyChance = Options.SilentBodyChance.Value
    settings.Silent.FOV.Enabled = Toggles.ToggleSilentFOV.Value 
    settings.Silent.FOV.Radius = Options.SilentFOVSize.Value 
    settings.Silent.FOV.Colour = Options.SilentFOVColour.Value

    settings.Trigger.Enabled = Toggles.ToggleTriggerbot.Value
    settings.Trigger.Teamcheck = Toggles.ToggleTriggerbotTC.Value 
    settings.Trigger.Delay = Options.TriggerbotDelay.Value 

    settings.Visual.Teamcheck = Toggles.ToggleESPTeamcheck.Value

    settings.Visual.Line.Enabled = Toggles.ToggleESPLine.Value
    settings.Visual.Line.UseTC = Toggles.ESPLineUseTC.Value
    settings.Visual.Line.Colour = Options.ESPLineColour.Value 
    settings.Visual.Line.StartPosition = Options.ESPLineStart.Value

    settings.Visual.Box.Enabled = Toggles.ToggleESPBox.Value 
    settings.Visual.Box.Outline = Toggles.ToggleESPBoxOutline.Value
    settings.Visual.Box.Colour = Options.ESPBoxColour.Value 
    settings.Visual.Box.UseTC = Toggles.ESPBoxUseTC.Value

    settings.Visual.Name.Enabled = Toggles.ToggleESPName.Value 
    settings.Visual.Name.Autoscale = Toggles.ToggleESPNameAutoscale.Value
    settings.Visual.Name.Colour = Options.ESPNameColour.Value 
    settings.Visual.Name.UseTC = Toggles.ESPNameUseTC.Value 
    settings.Visual.Name.Font = Options.ESPNameFont.Value
    settings.Visual.Name.Size = Options.ESPNameSize.Value
    settings.Visual.Name.Outline = Toggles.ToggleESPNameOutline.Value

    settings.Visual.Head.Enabled = Toggles.ToggleESPHead.Value 
    settings.Visual.Head.Filled = Toggles.ToggleESPHeadFilled.Value 
    settings.Visual.Head.Colour = Options.ESPHeadColour.Value 
    settings.Visual.Head.UseTC = Toggles.ESPHeadUseTC.Value 

    settings.Visual.Chams.Enabled = Toggles.ToggleESPChams.Value 
    settings.Visual.Chams.FillUseTC = Toggles.ToggleESPChamsTCFill.Value 
    settings.Visual.Chams.OutlineUseTC = Toggles.ToggleESPChamsTCOutline.Value 
    settings.Visual.Chams.FillColour = Options.ESPChamsFillColour.Value 
    settings.Visual.Chams.OutlineColour = Options.ESPChamsOutlineColour.Value 
    settings.Visual.Chams.FillTransparency = Options.ESPChamsFillTransparency.Value
    settings.Visual.Chams.OutlineTransparency = Options.ESPChamsOutlineTransparency.Value

    settings.Visual.Lighting.Sky = Options.LightingCustomSky.Value
    settings.Visual.Lighting.Brightness = Options.LightingBrightness.Value 
    settings.Visual.Lighting.Ambient = Options.LightingAmbience.Value

    settings.Swapper.Melee = Options.MiscSwapperMelee.Value 
    settings.Swapper.Skin1 = Options.MiscSwapperSkin1.Value
    settings.Swapper.Skin2 = Options.MiscSwapperSkin2.Value

    settings.Local.ToggleWS = Toggles.ToggleLocalWalkspeed.Value
    settings.Local.ToggleJP = Toggles.ToggleLocalJumppower.Value
    settings.Local.ToggleBhop = Toggles.ToggleLocalBhop.Value
    settings.Local.WS = Options.LocalWalkspeed.Value
    settings.Local.JP = Options.LocalJumppower.Value 
    settings.Local.BS = Options.LocalBhopSpeed.Value

    settings.Mods.NoRecoil = Toggles.ModRecoil.Value
    settings.Mods.NoSpread = Toggles.ModSpread.Value 
    settings.Mods.Automatic = Toggles.ModAuto.Value 
    settings.Mods.Firerate = Toggles.ModFirerate.Value 
    settings.Mods.FastEquip = Toggles.ModEquip.Value 
    settings.Mods.FastReload = Toggles.ModReload.Value 

    settings.KickWhenMod = Toggles.MiscSafetyKick.Value

    aimCircle.Visible = settings.Aimbot.FOV.Enabled
    aimCircle.Radius = settings.Aimbot.FOV.Radius
    aimCircle.Color = settings.Aimbot.FOV.Colour
    aimCircle.Position = Vector2.new(userInputService:GetMouseLocation().X, userInputService:GetMouseLocation().Y)

    silentCircle.Visible = settings.Silent.FOV.Enabled
    silentCircle.Radius = settings.Silent.FOV.Radius
    silentCircle.Color = settings.Silent.FOV.Colour
    silentCircle.Position = Vector2.new(userInputService:GetMouseLocation().X, userInputService:GetMouseLocation().Y)

    if aim_getClosest() and settings.Aimbot.Enabled and settings.Aimbot.isAiming then
        local character = aim_getClosest().Character or aim_getClosest().CharacterAdded:Wait()
        local pos, os = camera:WorldToScreenPoint(aim_getClosest().Character[settings.Aimbot.Hitpart].Position)
        if not os then return end
        movemouse(pos)

        if settings.Aimbot.Notifications and old ~= aim_getClosest() then 
            Library:Notify("Target : "..aim_getClosest())
            old = aim_getClosest()
        end
    end

    


    if silent_getClosest() ~= nil then
        local character = silent_getClosest().Character or silent_getClosest().CharacterAdded:Wait()

        local _, os = camera:WorldToScreenPoint(character.HumanoidRootPart.Position)
        settings.Silent.OnScreen = os
        settings.Silent.Target = silent_getClosest().Character
    else
        settings.Silent.OnScreen = false
    end

    if settings.Silent.UseChance then
        local chance = math.random(0, 100)
        

        if chance <= settings.Silent.HeadChance then
            settings.Silent.ToHit = "HumanoidRootPart"
        elseif chance >= settings.Silent.BodyChance then
            settings.Silent.ToHit = "Head"
        else
            settings.Silent.ToHit = "Head"
        end
    else
        settings.Silent.ToHit = settings.Silent.Hitpart
    end

    if mouse.Target and settings.Trigger.Enabled then
        if mouse.Target.Parent:FindFirstChild("Humanoid") and playerService:FindFirstChild(mouse.Target.Parent.Name) then
            local player = playerService:FindFirstChild(mouse.Target.Parent.Name)

            if settings.Trigger.Teamcheck and player ~= localPlayer.Team then
                task.wait(settings.Trigger.Delay/1000)
                mouse1press()
                task.wait()
                mouse1release()
            else
                task.wait(settings.Trigger.Delay/1000)
                mouse1press()
                task.wait()
                mouse1release()
            end
        end
    end

    if settings.Local.ToggleBhop and settings.Local.BhopJumping then
        humanoid.Jump = true
        if humanoid.MoveDirection.Magnitude > 0 then
            localCharacter:TranslateBy(humanoid.MoveDirection * settings.Local.BS / 50)
        end
    end

    gunmod(1, settings.Mods.Automatic)
    gunmod(2, settings.Mods.NoSpread)
    gunmod(3, settings.Mods.NoRecoil)
    gunmod(4, settings.Mods.FastEquip)
    gunmod(5, settings.Mods.FastReload)
    gunmod(6, settings.Mods.Firerate)

    lightingService.Ambient = settings.Visual.Lighting.Ambient
    lightingService.Brightness = settings.Visual.Lighting.Brightness

    if settings.Visual.Lighting.Sky == "Default" then

    elseif settings.Visual.Lighting.Sky == "Galaxy 1" then

    elseif settings.Visual.Lighting.Sky == "Galaxy 2" then
        
    elseif settings.Visual.Lighting.Sky == "Cloudy 1" then

    elseif settings.Visual.Lighting.Sky == "Night 1" then

    elseif settings.Visual.Lighting.Sky == "Old 1" then
    
    elseif settings.Visual.Lighting.Sky == "Old 2" then

    elseif settings.Visual.Lighting.Sky == "Sunset 1" then

    end
end

local mt = getrawmetatable(game)
local oldNamecall = mt.__namecall
local oldIndex = mt.__index
if setreadonly then
    setreadonly(mt, false)
else
    make_writeable(mt, true)
end
local namecallMethod = getnamecallmethod or get_namecall_method
local newClose = newcclosure or function(f)
   return f
end
mt.__namecall = newClose(function(...)
   local method = namecallMethod()
   local args = {...}

   if method == "FindPartOnRayWithIgnoreList" and settings.Silent.Enabled then
	    if settings.Silent.OnScreen then
			args[2] = Ray.new(camera.CFrame.Position, (settings.Silent.Target[settings.Silent.ToHit].CFrame.p - camera.CFrame.Position).unit * 500)
		end
   end

   return oldNamecall(unpack(args))
end)


--[[mt.__index = function(a, b)
    if tostring(a) == "Humanoid" and tostring(b) == "JumpHeight" then
        if settings.Local.ToggleJP then
            return settings.Local.JP
        end
    end

    return oldIndex(a, b)
end]]

local Window = Library:CreateWindow({Title = "luaware | Arsenal", Center = true, AutoShow = true})

local Tabs = {
    Aim = Window:AddTab("Aim Assist"), 
    Visual = Window:AddTab("Visuals"), 
    Local = Window:AddTab("Localplayer"), 
    Misc = Window:AddTab("Misc"),
    Menu = Window:AddTab("Menu"),
}

local Aim_AimbotBox = Tabs.Aim:AddLeftTabbox("Aimbot") do 
    local Main = Aim_AimbotBox:AddTab("Aimbot")
    local Other = Aim_AimbotBox:AddTab("FOV")

    Main:AddToggle("ToggleAimbot", {Text = "Enabled", Default = false})
    Main:AddToggle("AimbotWallcheck", {Text = "Wallcheck", Default = false})
    Main:AddToggle("AimbotTeamcheck", {Text = "Teamcheck", Default = false})
    Main:AddLabel("Aim Bind"):AddKeyPicker("AimBindPicker", {Default = "MB2", SyncToggleState = false, Mode = "Hold", Text = "Aim Bind", NoUI = false,})
    Main:AddSlider("AimbotSmoothness", {Text = "Smoothness", Default = 0.5, Min = 0.1, Max = 2, Rounding = 1, Compact = true})
    Main:AddDropdown("AimbotHitpart", {Values = settings.Hitparts, Default = 1, Multi = false, Text = "Hitpart",})
    Main:AddDivider()
    Main:AddToggle("ToggleAimbotNotifications", {Text = "Notifications", Default = false})

    Other:AddToggle("ToggleAimbotFOV", {Text = "Enabled", Default = false})
    Other:AddSlider("AimbotFOVSize", {Text = "Radius", Default = 150, Min = 50, Max = 1000, Rounding = 0, Compact = true})
    Other:AddLabel("FOV Colour"):AddColorPicker("AimbotFOVColour", {Default = Color3.new(1,0,0), Title = "FOV Colour",})
end

local Aim_SilentBox = Tabs.Aim:AddRightTabbox("Silent") do
    local Main = Aim_SilentBox:AddTab("Silent")
    local Other = Aim_SilentBox:AddTab("FOV")

    Main:AddToggle("ToggleSilent", {Text = "Enabled", Default = false})
    Main:AddToggle("ToggleSilentTeamcheck", {Text = "Teamcheck", Default = false})
    --Main:AddToggle("ToggleSilentWallbang", {Text = "Wallbang", Default = false})
    Main:AddToggle("ToggleSilentUseChance", {Text = "Use Chance", Default = false})
    Main:AddDropdown("SilentHitpart", {Values = settings.Hitparts, Default = 1, Multi = false, Text = "Hitpart",})
    Main:AddSlider("SilentHeadChance", {Text = "Head Chance", Default = 50, Min = 0, Max = 100, Rounding = 0, Compact = true})
    Main:AddSlider("SilentBodyChance", {Text = "Body Chance", Default = 50, Min = 0, Max = 100, Rounding = 0, Compact = true})

    Other:AddToggle("ToggleSilentFOV", {Text = "Enabled", Default = false})
    Other:AddSlider("SilentFOVSize", {Text = "Radius", Default = 50, Min = 50, Max = 1000, Rounding = 0, Compact = true})
    Other:AddLabel("FOV Colour"):AddColorPicker("SilentFOVColour", {Default = Color3.new(0,0,1), Title = "FOV Colour",})
end

local Aim_TriggerBox = Tabs.Aim:AddLeftTabbox("Triggerbot") do
    local Main = Aim_TriggerBox:AddTab("Triggerbot")

    Main:AddToggle("ToggleTriggerbot", {Text = "Enabled", Default = false})
    Main:AddToggle("ToggleTriggerbotTC", {Text = "Teamcheck", Default = false})
    Main:AddSlider("TriggerbotDelay", {Text = "Delay (ms)", Default = 50, Min = 1, Max = 1000, Rounding = 0, Compact = true})
end

local Visual_MasterBox = Tabs.Visual:AddLeftTabbox("Masterswitch") do
    Main = Visual_MasterBox:AddTab("Masterswitch")

    Main:AddToggle("ToggleESPTeamcheck", {Text = "Teamcheck", Default = false})
end

local Visual_BoxESP_Box = Tabs.Visual:AddLeftTabbox("Box") do
    local Main = Visual_BoxESP_Box:AddTab("Box")

    Main:AddToggle("ToggleESPBox", {Text = "Enabled", Default = false})
    Main:AddToggle("ToggleESPBoxOutline", {Text = "Outline", Default = false})
    Main:AddToggle("ESPBoxUseTC", {Text = "Use TeamColour", Default = false})
    Main:AddLabel("Box Colour"):AddColorPicker("ESPBoxColour", {Default = Color3.new(1,1,1), Title = "Box Colour",})
end

local Visual_NameESP_Box = Tabs.Visual:AddRightTabbox("Name") do
    local Main = Visual_NameESP_Box:AddTab("Name")

    Main:AddToggle("ToggleESPName", {Text = "Enabled", Default = false})
    Main:AddToggle("ToggleESPNameOutline", {Text = "Outline", Default = false})
    Main:AddToggle("ToggleESPNameAutoscale", {Text = "Autoscale", Default = false})
    Main:AddToggle("ESPNameUseTC", {Text = "Use TeamColour", Default = false})
    Main:AddSlider("ESPNameFont", {Text = "Font", Default = 0, Min = 0, Max = 3, Rounding = 0, Compact = true})
    Main:AddSlider("ESPNameSize", {Text = "Size", Default = 14, Min = 5, Max = 25, Rounding = 1, Compact = true})
    Main:AddLabel("Name Colour"):AddColorPicker("ESPNameColour", {Default = Color3.new(1,1,1), Title = "Name Colour",})
end

local Visual_LineESP_Box = Tabs.Visual:AddLeftTabbox("Line") do
    local Main = Visual_LineESP_Box:AddTab("Line")

    Main:AddToggle("ToggleESPLine", {Text = "Enabled", Default = false})
    Main:AddToggle("ESPLineUseTC", {Text = "Use TeamColour", Default = false})
    Main:AddLabel("Line Colour"):AddColorPicker("ESPLineColour", {Default = Color3.new(1,1,1), Title = "Line Colour",})
    Main:AddDropdown("ESPLineStart", {Values = {"Top", "Center", "Bottom", "Mouse"}, Default = 3, Multi = false, Text = "Start Position",})
end

local Visual_HeadESP_Box = Tabs.Visual:AddRightTabbox("Head Circle") do
    local Main = Visual_HeadESP_Box:AddTab("Head Circle")

    Main:AddToggle("ToggleESPHead", {Text = "Enabled", Default = false})
    Main:AddToggle("ToggleESPHeadFilled", {Text = "Filled", Default = false})
    Main:AddToggle("ESPHeadUseTC", {Text = "Use TeamColour", Default = false})
    Main:AddLabel("Head Colour"):AddColorPicker("ESPHeadColour", {Default = Color3.new(1,1,1), Title = "Head Colour",})
end

local Visual_ChamsESP_Box = Tabs.Visual:AddLeftTabbox("Chams") do
    local Main = Visual_ChamsESP_Box:AddTab("Chams")

    Main:AddToggle("ToggleESPChams", {Text = "Enabled", Default = false})
    Main:AddToggle("ToggleESPChamsTCFill", {Text = "TeamColour Fill", Default = false})
    Main:AddToggle("ToggleESPChamsTCOutline", {Text = "TeamColour Outline", Default = false})
    Main:AddLabel("Fill Colour"):AddColorPicker("ESPChamsFillColour", {Default = Color3.new(1,1,1), Title = "Fill Colour",})
    Main:AddLabel("Outline Colour"):AddColorPicker("ESPChamsOutlineColour", {Default = Color3.new(1,1,1), Title = "Outline Colour",})
    Main:AddSlider("ESPChamsFillTransparency", {Text = "Fill Transparency", Default = 0.5, Min = 0, Max = 1, Rounding = 1, Compact = true})
    Main:AddSlider("ESPChamsOutlineTransparency", {Text = "Outline Transparency", Default = 0, Min = 0, Max = 1, Rounding = 1, Compact = true})
end

local Visual_SkyBox = Tabs.Visual:AddRightTabbox("Lighting") do 
    local Main = Visual_SkyBox:AddTab("Lighting")

    Main:AddLabel("Ambience"):AddColorPicker("LightingAmbience", {Default = Color3.new(0,0,0), Title = "Ambience",})
    Main:AddSlider("LightingBrightness", {Text = "Brightness", Default = 0, Min = 0, Max = 2, Rounding = 1, Compact = true})
    Main:AddDropdown("LightingCustomSky", {Values = settings.Visual.Lighting.CustomSkys, Default = 1, Multi = false, Text = "Custom Sky",})
    Main:AddLabel("Custom sky disabled.")
end

local Local_CharacterBox = Tabs.Local:AddLeftTabbox("Character") do
    local Main = Local_CharacterBox:AddTab("Character")

    Main:AddToggle("ToggleLocalWalkspeed", {Text = "Enable Walkspeed", Default = false})
    Main:AddSlider("LocalWalkspeed", {Text = "Speed", Default = 16, Min = 16, Max = 250, Rounding = 0, Compact = true})

    Main:AddDivider()

    Main:AddToggle("ToggleLocalJumppower", {Text = "Enable Jumpheight", Default = false})
    Main:AddSlider("LocalJumppower", {Text = "Jumpheight", Default = 3.5, Min = 3.5, Max = 100, Rounding = 0, Compact = true})

    Main:AddDivider()
    
    Main:AddToggle("ToggleLocalBhop", {Text = "Enable Bhop", Default = false})
    Main:AddSlider("LocalBhopSpeed", {Text = "Speed", Default = 1, Min = 1, Max = 100, Rounding = 0, Compact = true})
end

local Local_ModBox = Tabs.Local:AddRightTabbox("Mods") do
    local Main = Local_ModBox:AddTab("Mods")

    Main:AddToggle("ModRecoil", {Text = "No Recoil", Default = false})
    Main:AddToggle("ModSpread", {Text = "No Spread", Default = false})
    Main:AddToggle("ModAuto", {Text = "Automatic", Default = false})
    Main:AddToggle("ModReload", {Text = "Fast Reload", Default = false})
    Main:AddToggle("ModEquip", {Text = "Fast Equip", Default = false})
    Main:AddToggle("ModFirerate", {Text = "Firerate", Default = false})

    Main:AddLabel("Respawn/re-equip to apply.", true)
end

local Misc_SwapperBox = Tabs.Misc:AddLeftTabbox("Swapper") do
    local Main = Misc_SwapperBox:AddTab("Weapon Skin")
    local Other = Misc_SwapperBox:AddTab("Melee")

    Main:AddDropdown("MiscSwapperSkin1", {Values = skinTable, Default = 1, Multi = false, Text = "Skin 1",})
    Main:AddDropdown("MiscSwapperSkin2", {Values = skinTable, Default = 1, Multi = false, Text = "Skin 2",})
    local button = Main:AddButton("Swap", function()
        swapSkin(settings.Swapper.Skin1, settings.Swapper.Skin2)
    end)
    button:AddTooltip("Skin 1 = Old , Skin 2 = New", true)

    Other:AddDropdown("MiscSwapperMelee", {Values = meleeTable, Default = 1, Multi = false, Text = "Melee",})
    local button = Other:AddButton("Swap", function()
        swapMelee(settings.Swapper.Melee)
    end)
    button:AddTooltip("Set Melees to shuffle for this to work.", true)
end 

local Misc_SafeBox = Tabs.Misc:AddRightTabbox("Safety") do
    local Main = Misc_SafeBox:AddTab("Safety")

    Main:AddToggle("MiscSafetyKick", {Text = "Kick when moderator joins.", Default = false})
end



ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)
SaveManager:IgnoreThemeSettings() 
SaveManager:SetIgnoreIndexes({"MenuKeybind"}) 
ThemeManager:SetFolder("luaware")
SaveManager:SetFolder("luaware/Arsenal")
SaveManager:BuildConfigSection(Tabs.Menu) 
ThemeManager:ApplyToTab(Tabs.Menu)

local function esp(player,character)

	local humanoid = character:WaitForChild("Humanoid")
	local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

	local highlightFolder = coreGui:FindFirstChild("Folder") or Instance.new("Folder", coreGui)

	if highlightFolder:FindFirstChild(player.Name) then highlightFolder[player.Name]:Destroy() end

	local highlight = Instance.new("Highlight", highlightFolder)
	highlight.Name = player.Name
	highlight.FillColor = settings.Visual.Chams.FillColour
	highlight.FillTransparency = settings.Visual.Chams.FillTransparency
	highlight.OutlineColor = settings.Visual.Chams.OutlineColour
	highlight.OutlineTransparency = settings.Visual.Chams.OutlineTransparency

	local line = Drawing.new("Line")
	line.Color = Color3.new(1,1,1)
	line.Thickness = 1
	line.Transparency = 1

	local text = Drawing.new("Text")
	text.Font = 3
	text.Color = Color3.new(1,1,1)
	text.Outline = true
	text.Size = 14
	text.Center = true

    local boxoutline = Drawing.new("Square")
    boxoutline.Color = Color3.new(0,0,0)
    boxoutline.Thickness = 3

    local box = Drawing.new("Square")
    box.Color = Color3.new(1,1,1)

    local headCircle = Drawing.new("Circle")
    headCircle.Radius = 5
    headCircle.Color = Color3.new(1,1,1)

	local c1
	local c2
	local c3

	local function dc()
		line.Visible = false
		line:Remove()

		text.Visible = false
		text:Remove()

        boxoutline.Visible = false
        boxoutline:Remove()

        box.Visible = false
        box:Remove()

        headCircle.Visible = false
        headCircle:Remove()

		highlight:Destroy()

		if c1 then
			c1:Disconnect()
			c1 = nil 
		end
		if c2 then
			c2:Disconnect()
			c2 = nil 
		end
		if c3 then
			c3:Disconnect()
			c3 = nil 
		end
	end

	c2 = character.AncestryChanged:Connect(function(_,parent)
		if not parent then
			dc()
		end
	end)

	c3 = humanoid.HealthChanged:Connect(function(v)
		if (v<=0) or (humanoid:GetState() == Enum.HumanoidStateType.Dead) then
			dc()
		end
	end)

	c1 = runService.RenderStepped:Connect(function()
        local mag = (humanoidRootPart.Position - localCharacter.HumanoidRootPart.Position).Magnitude
		local root_pos,onscreen = camera:WorldToViewportPoint(humanoidRootPart.Position)
        local head_pos,onscreen = camera:WorldToViewportPoint(character:WaitForChild("Head").Position + Vector3.new(0, 0.5, 0))
        local leg_pos,onscreen = camera:WorldToViewportPoint(humanoidRootPart.Position - Vector3.new(0, 3, 0))
		if onscreen and player ~= localPlayer then

			highlight.Adornee = character
			highlight.Enabled = settings.Visual.Chams.Enabled
            highlight.FillColor = settings.Visual.Chams.FillColour
            highlight.FillTransparency = settings.Visual.Chams.FillTransparency
            highlight.OutlineColor = settings.Visual.Chams.OutlineColour
            highlight.OutlineTransparency = settings.Visual.Chams.OutlineTransparency

            if settings.Visual.Chams.FillUseTC then
                highlight.FillColor = player.TeamColor.Color
            end
            if settings.Visual.Chams.OutlineUseTC then
                highlight.OutlineColor = player.TeamColor.Color
            end


			line.To = Vector2.new(root_pos.X, root_pos.Y)
            if settings.Visual.Line.StartPosition == "Top" then
                line.From = Vector2.new(camera.ViewportSize.X / 2, 0)
            elseif settings.Visual.Line.StartPosition == "Center" then
                line.From = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
            elseif settings.Visual.Line.StartPosition == "Bottom" then
                line.From = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y)
            elseif settings.Visual.Line.StartPosition == "Mouse" then
                line.From = Vector2.new(userInputService:GetMouseLocation().X, userInputService:GetMouseLocation().Y)
            end
			line.Visible = settings.Visual.Line.Enabled

            text.Position = Vector2.new(root_pos.X, root_pos.Y)
			text.Visible = settings.Visual.Name.Enabled
			text.Outline = settings.Visual.Name.Outline
            text.Size = settings.Visual.Name.Size

            text.Font = settings.Visual.Name.Font
			text.Text = tostring(player.Name)

            box.Visible = settings.Visual.Box.Enabled
            if settings.Visual.Box.Enabled then
                boxoutline.Visible = settings.Visual.Box.Outline
            else
                boxoutline.Visible = false
            end
            box.Size = Vector2.new((1000/ root_pos.Z), head_pos.Y - leg_pos.Y)
            boxoutline.Size = Vector2.new((1000/ root_pos.Z), head_pos.Y - leg_pos.Y)
            
            box.Position = Vector2.new(root_pos.X - box.Size.X / 2, root_pos.Y - box.Size.Y / 2)
            boxoutline.Position = Vector2.new(root_pos.X - box.Size.X / 2, root_pos.Y - box.Size.Y / 2)

            headCircle.Position = Vector2.new(head_pos.X, head_pos.Y)
            headCircle.Filled = settings.Visual.Head.Filled
            headCircle.Visible = settings.Visual.Head.Enabled

			if player.Team == localPlayer.Team and settings.Visual.Teamcheck then
				line.Visible = false
				text.Visible = false
				highlight.Enabled = false
                box.Visible = false
                boxoutline.Visible = false
                headCircle.Visible = false
			end

            if settings.Visual.Line.UseTC then
                line.Color = player.TeamColor.Color
            else
                line.Color = settings.Visual.Line.Colour
            end

            if settings.Visual.Name.UseTC then
                text.Color = player.TeamColor.Color
            else
                text.Color = settings.Visual.Name.Colour
            end
            if settings.Visual.Box.UseTC then
                box.Color = player.TeamColor.Color
            else
                box.Color = settings.Visual.Box.Colour
            end

            if settings.Visual.Head.UseTC then
                headCircle.Color = player.TeamColor.Color
            else
                headCircle.Color = settings.Visual.Head.Colour
            end

		else
			line.Visible = false
			text.Visible = false
			highlight.Enabled = false
            box.Visible = false
            headCircle.Visible = false
            boxoutline.Visible = false
		end

        return
	end)

end

local function playerAdded(player)
	if player.Character then
		esp(player,player.Character)
	end
	player.CharacterAdded:Connect(function(character)
		esp(player,character)
	end)
end

for _, player in next, playerService:GetPlayers() do 
	if player ~= localPlayer then
		playerAdded(player)
	end
end

playerService.PlayerAdded:Connect(playerAdded)

runService.RenderStepped:Connect(function(delta)
    mainupdate()
end)

local args

args = {[1] = "POG"}
replicatedStorage.Redeem:InvokeServer(unpack(args))
args = {[1] = "BLOXY"}
replicatedStorage.Redeem:InvokeServer(unpack(args))

print("Loaded luaware")

local loadTime = string.sub(tostring(tick()-current), 1, 5)

Library:Notify("Welcome, "..localPlayer.Name..".")
Library:Notify("Loaded in "..loadTime.."s.")
