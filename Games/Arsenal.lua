assert(Drawing, "Exploit not supported.")

repeat task.wait()

until game:IsLoaded()

if game.PlaceVersion > 10460 then
    local Loaded,PromptLib = false,loadstring(game:HttpGet("https://raw.githubusercontent.com/AlexR32/Roblox/main/Useful/PromptLibrary.lua"))()
    PromptLib("Unsupported game version","You are at risk of getting autoban\nAre you sure you want to load Luaware?",{
        {Text = "Yes",LayoutOrder = 0,Primary = false,Callback = function() Loaded = true end},
        {Text = "No",LayoutOrder = 0,Primary = true,Callback = function() end}
    }) repeat task.wait(1) until Loaded
end

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
local humanoidRootPart = localCharacter:WaitForChild("HumanoidRootPart")

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
local ESP = loadstring(game:HttpGet("https://kiriot22.com/releases/ESP.lua"))()

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
    FOVEnabled = false,
    FOV = 120,
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
    Lighting = {
        Ambient = Color3.new(0,0,0),
        Brightness = 1,
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
    Spinbot = {
        Enabled = false,
        Speed = 90,
    },
    KickWhenMod = false,
    InfiniteJump = false,
    Hold = false,
}

local aimCircle = Drawing.new("Circle")
aimCircle.Visible = false

local silentCircle = Drawing.new("Circle")
silentCircle.Visible = false

userInputService.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == Enum.KeyCode.Space then
        settings.Local.BhopJumping = true

        if settings.InfiniteJump and not settings.Hold then
            humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        end
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

    settings.Lighting.Brightness = Options.LightingBrightness.Value 
    settings.Lighting.Ambient = Options.LightingAmbience.Value

    settings.Swapper.Melee = Options.MiscSwapperMelee.Value 
    settings.Swapper.Skin1 = Options.MiscSwapperSkin1.Value
    settings.Swapper.Skin2 = Options.MiscSwapperSkin2.Value

    settings.Local.ToggleWS = Toggles.ToggleLocalWalkspeed.Value
    settings.Local.ToggleBhop = Toggles.ToggleLocalBhop.Value
    settings.Local.WS = Options.LocalWalkspeed.Value
    settings.Local.BS = Options.LocalBhopSpeed.Value

    settings.Mods.NoRecoil = Toggles.ModRecoil.Value
    settings.Mods.NoSpread = Toggles.ModSpread.Value 
    settings.Mods.Automatic = Toggles.ModAuto.Value 
    settings.Mods.Firerate = Toggles.ModFirerate.Value 
    settings.Mods.FastEquip = Toggles.ModEquip.Value 
    settings.Mods.FastReload = Toggles.ModReload.Value

    ESP:Toggle(Toggles.ToggleESP.Value)
    ESP.TeamColor = Toggles.ToggleESPTeamcolour.Value
    ESP.Tracers = Toggles.ToggleTracers.Value
    ESP.Names = Toggles.ToggleName.Value
    ESP.Boxes = Toggles.ToggleBoxes.Value
    ESP.AutoRemove = true
    ESP.TeamMates = not Toggles.ToggleESPTeamcheck.Value
    ESP.Color = Options.ESPColour.Value
    ESP.FaceCamera = Toggles.ToggleESPFacecamera.Value

    settings.KickWhenMod = Toggles.MiscSafetyKick.Value

    settings.InfiniteJump = Toggles.ToggleInfiniteJump.Value
    settings.Hold = Toggles.ToggleInfiniteJumpHold.Value

    settings.FOVEnabled = Toggles.FieldOfViewEnabled.Value
    settings.FOV = Options.FieldOfView.Value 

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
            Library:Notify("Target : "..tostring(aim_getClosest().Name))
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

    lightingService.Ambient = settings.Lighting.Ambient
    lightingService.Brightness = settings.Lighting.Brightness

    if settings.InfiniteJump and settings.Hold and settings.Local.BhopJumping then
        humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
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


mt.__index = function(a, b)
    if tostring(a) == "Humanoid" and tostring(b) == "WalkSpeed" then
        if settings.Local.ToggleWS then
            return settings.Local.WS
        end
    end
    
    return oldIndex(a, b)
end

camera.Changed:Connect(function()
    if not settings.FOVEnabled then return end
    camera.FieldOfView = settings.FOV
end)

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

local Visual_MasterBox = Tabs.Visual:AddLeftTabbox("Visuals") do
    Main = Visual_MasterBox:AddTab("Visuals")

    Main:AddToggle("ToggleESP", {Text = "Enabled", Default = false})

    Main:AddDivider()

    Main:AddToggle("ToggleBoxes", {Text = "Boxes", Default = false})
    Main:AddToggle("ToggleTracers", {Text = "Tracers", Default = false})
    Main:AddToggle("ToggleName", {Text = "Name", Default = false})

    Main:AddDivider()

    Main:AddToggle("ToggleESPTeamcheck", {Text = "Teamcheck", Default = false})
    Main:AddToggle("ToggleESPFacecamera", {Text = "Face Camera", Default = false})
    Main:AddLabel("Colour"):AddColorPicker("ESPColour", {Default = Color3.new(1,1,1), Title = "Colour",})
    Main:AddToggle("ToggleESPTeamcolour", {Text = "Teamcolour", Default = false})

end

local Visual_LightingBox = Tabs.Visual:AddRightTabbox("Lighting") do 
    local Main = Visual_LightingBox:AddTab("Lighting")

    Main:AddLabel("Ambience"):AddColorPicker("LightingAmbience", {Default = Color3.new(0,0,0), Title = "Ambience",})
    Main:AddSlider("LightingBrightness", {Text = "Brightness", Default = 0, Min = 0, Max = 2, Rounding = 1, Compact = true})
end

local Local_CharacterBox = Tabs.Local:AddLeftTabbox("Character") do
    local Main = Local_CharacterBox:AddTab("Character")

    Main:AddToggle("ToggleLocalWalkspeed", {Text = "Enable Walkspeed", Default = false})
    Main:AddSlider("LocalWalkspeed", {Text = "Speed", Default = 16, Min = 16, Max = 250, Rounding = 0, Compact = true})

    Main:AddDivider()
    
    Main:AddToggle("ToggleLocalBhop", {Text = "Enable Bhop", Default = false})
    Main:AddSlider("LocalBhopSpeed", {Text = "Speed", Default = 1, Min = 1, Max = 100, Rounding = 0, Compact = true})

    Main:AddDivider()

    Main:AddToggle("ToggleInfiniteJump", {Text = "Infinite Jump", Default = false})
    Main:AddToggle("ToggleInfiniteJumpHold", {Text = "Hold Mode", Default = false})
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

    Main:AddDivider()

    Main:AddToggle("FieldOfViewEnabled", {Text = "FOV Enabled", Default = false})
    Main:AddSlider("FieldOfView", {Text = "FOV", Default = 70, Min = 70, Max = 120, Rounding = 0, Compact = true})
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
