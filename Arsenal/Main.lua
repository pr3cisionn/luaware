-- Luaware 

--// Variables

local playerService = game:GetService("Players")
local runService = game:GetService("RunService")
local userInputService = game:GetService("UserInputService")
local replicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = workspace or game:GetService("Workspace")

local localPlayer = playerService.LocalPlayer
local localCharacter = localPlayer.Character or localPlayer.CharacterAdded:Wait()
local localSettings
local mouse = localPlayer:GetMouse()

local camera = Workspace.CurrentCamera

--\\


repeat
	task.wait()
until localPlayer:FindFirstChild("Settings")

localSettings = localPlayer:FindFirstChild("Settings")



if not Drawing then
	warn("Exploit Not Supported")
	return
end


--// Settings

local aimSettings = {
	Aimbot = false,
	isAiming = false,
	TeamCheck = false,
	WallCheck = false,
	AimPart = "Head",
	Smoothness = 1,
	Keybind = Enum.UserInputType.MouseButton2
}

local silentSettings = {
	Enabled = false,
    Enabled2 = true,
	AimPart = "Head",
	silentTarget = nil
}

local triggerBotSettings = {
	Enabled = false,
	Delay = 0,
}

local circleSettings = {
	UseFov = true,
	ShowFov = false,
	Radius = 150,
	Colour = Color3.new(1,0,0),
	Sides = 16
}

local espSettings = {
	TeamCheck = false,

	Name = {
		Enabled = false,
		Size = 14,
		Outline = true,
		UseTC = false,
		ShowDist = true,
		Colour = Color3.new(1,1,1),
		Font = 3,
		AutoScale = false
	},
	Tracer = {
		Enabled = false,
		Thickness = 1,
		Colour = Color3.new(1,0,0),
		UseTC = false,
		Bone = 2
	},
	Highlight = {
		Enabled = false,
		UseTCOutline = false,
		OutlineColour = Color3.new(1,0,0),
		OutlineTransparency = 0,
		UseTCFill = false,
		FillColour = Color3.new(1,0,0),
		FillTransparency = 0.5,
		DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
	},
	Box = {
		Enabled = true
	}
}

local bhopSettings = {
    Enabled = false,
	Jumping = false,
	Speed = 75
}

local fovCircle = Drawing.new("Circle")
fovCircle.Color = circleSettings.Colour
fovCircle.Radius = circleSettings.Radius
fovCircle.NumSides = circleSettings.Sides
fovCircle.Visible = circleSettings.ShowFov

--\\

--// Functions

userInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end

	if input.UserInputType == aimSettings.Keybind then
		aimSettings.isAiming = true
	elseif input.KeyCode == aimSettings.Keybind then
		aimSettings.isAiming = true
	elseif input.KeyCode == Enum.KeyCode.Space then
		bhopSettings.Jumping = true
	end
end)

userInputService.InputEnded:Connect(function(input, gameProcessed)
	if gameProcessed then return end

	if input.UserInputType == aimSettings.Keybind then
		aimSettings.isAiming = false
	elseif input.KeyCode == aimSettings.Keybind then
		aimSettings.isAiming = false
	elseif input.KeyCode == Enum.KeyCode.Space then
		bhopSettings.Jumping = false
	end
end)

local function teamCheck(player)
	if not aimSettings.TeamCheck then return true end

	if player.Team ~= localPlayer.Team then
		return true
	else
		return false
	end

end

function IsVisible(part, ignore)
	if not aimSettings.WallCheck then return true end

	Origin = workspace.CurrentCamera.CFrame.p
	CheckRay = Ray.new(Origin, part.Position - Origin)
	Hit = workspace:FindPartOnRayWithIgnoreList(CheckRay, ignore)
	return Hit == nil
end

local function getClosestPlayer()
	local closestPlayer, dist = nil, math.huge

	for index,player in pairs(playerService:GetChildren()) do
		if player ~= localPlayer and teamCheck(player) then 
			local character = player.Character or player.CharacterAdded:Wait() 

			if character:FindFirstChild("Humanoid") and character:FindFirstChild("HumanoidRootPart") and character.Humanoid.Health > 0 then 
				local playerPosition, playerOnScreen = camera:WorldToViewportPoint(character.HumanoidRootPart.Position)
				local magnitude = (Vector2.new(playerPosition.X, playerPosition.Y) - Vector2.new(mouse.X, mouse.Y)).Magnitude

				if (magnitude < dist and magnitude < circleSettings.Radius and IsVisible(character[aimSettings.AimPart], {camera, localCharacter, Workspace.Debris, Workspace.Ray_Ignore, character, Workspace.Map.Ignore})) then
					dist = magnitude
					closestPlayer = player
				end
			end
		end
	end
	return closestPlayer
end



local function aimAt(position)
	mousemoverel((position.X - mouse.X) * aimSettings.Smoothness, (position.Y - mouse.Y) * aimSettings.Smoothness)
end

local function updateFOVCircle()
	fovCircle.Color = circleSettings.Colour
	fovCircle.Radius = circleSettings.Radius
	fovCircle.NumSides = circleSettings.Sides
	fovCircle.Visible = circleSettings.ShowFov
	fovCircle.Position = Vector2.new(userInputService:GetMouseLocation().X, userInputService:GetMouseLocation().Y)
end


local function gunMod(num)


	local weaponsFolder = replicatedStorage.Weapons

	for i,v in pairs(weaponsFolder:GetChildren()) do 

		if num == 1 and v:FindFirstChild("Auto") then

			v.Auto.Value = true

		end

		if num == 2 and v:FindFirstChild("Spread") and v:FindFirstChild("MaxSpread") then

			v.Spread.Value = 0
			v.MaxSpread.Value = 0

		end

		if num == 3 and v:FindFirstChild("RecoilControl") then

			v.RecoilControl.Value = 0

		end

		if num == 4 and v:FindFirstChild("EquipTime") then

			v.EquipTime.Value = 0

		end

		if num == 5 and v:FindFirstChild("ReloadTime") then

			v.ReloadTime.Value = 0

		end

		if num == 6 and v:FindFirstChild("FireRate") then

			v.FireRate.Value = 0.05

		end

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

   if method == "FindPartOnRayWithIgnoreList" and silentSettings.Enabled then
   if silentSettings.Enabled2 then
        args[2] = Ray.new(camera.CFrame.Position, (silentSettings.silentTarget[silentSettings.AimPart].CFrame.p - camera.CFrame.Position).unit * 500)
        end
   end

   return oldNamecall(unpack(args))
end)

--\\

--// Loops

local mainLoop

mainLoop = runService.RenderStepped:Connect(function()

	updateFOVCircle()

	

	if getClosestPlayer() ~= nil and getClosestPlayer().Character ~= nil then
		local position, onscreen = camera:WorldToScreenPoint(getClosestPlayer().Character[aimSettings.AimPart].Position)
        if onscreen then
		silentSettings.silentTarget = getClosestPlayer().Character
        silentSettings.Enabled2 = true
        end
		if aimSettings.Aimbot and aimSettings.isAiming then
			aimAt(position)
		end
	else
		silentSettings.Enabled2 = false
	end


	if mouse.Target and triggerBotSettings.Enabled then
		if mouse.Target.Parent:FindFirstChild("Humanoid") then
			if triggerBotSettings.Delay == 0 then 
			mouse1click()
			else
			task.wait(triggerBotSettings.Delay / 1000)
			mouse1click()
			end
		end
	end

	if bhopSettings.Enabled and bhopSettings.Jumping and localCharacter ~= nil then
		localCharacter.Humanoid.Jump = true
		localCharacter.Humanoid.WalkSpeed = bhopSettings.Speed
	end
end)

local function esp(player,character)

	local humanoid = cr:WaitForChild("Humanoid")
	local humanoidRootPart = cr:WaitForChild("HumanoidRootPart")

	local highlightFolder = game.CoreGui:FindFirstChild("ESP") or Instance.new("Folder", game.CoreGui)
	highlightFolder.Name = "ESP"

	if highlightFolder:FindFirstChild(p.Name) then highlightFolder[p.Name]:Destroy() end

	local highlight = Instance.new("Highlight", highlightFolder)
	highlight.Name = p.Name
	highlight.FillColor = espSettings.Highlight.FillColour
	highlight.FillTransparency = espSettings.Highlight.FillTransparency
	highlight.OutlineColor = espSettings.Highlight.OutlineColour
	highlight.OutlineTransparency = espSettings.Highlight.OutlineTransparency
	highlight.DepthMode = espSettings.Highlight.DepthMode

	local line = Drawing.new("Line")
	line.Color = Color3.new(1,1,1)
	line.Thickness = 1
	line.Transparency = 1

	local text = Drawing.new("Text")
	text.Font = espSettings.Name.Font
	text.Color = espSettings.Name.Colour
	text.Outline = espSettings.Name.Outline
	text.Size = espSettings.Name.Size
	text.Center = true

	local text2 = Drawing.new("Text")
	text2.Font = espSettings.Name.Font
	text2.Color = espSettings.Name.Colour
	text2.Outline = espSettings.Name.Outline
	text2.Size = espSettings.Name.Size
	text2.Center = true


	local c1
	local c2
	local c3

	local function dc()
		line.Visible = false
		line:Remove()

		text.Visible = false
		text:Remove()

		text2.Visible = false
		text2:Remove()

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
		local root_pos,onscreen = camera:WorldToViewportPoint(humanoidRootPart.Position)
		if onscreen and player ~= localPlayer then

			local mag = math.round((root_pos.Position - localCharacter.HumanoidRootPart.Position).Magnitude)

			highlight.Adornee = character
			highlight.Enabled = espSettings.Highlight.Enabled
			highlight.FillColor = espSettings.Highlight.FillColour
			highlight.FillTransparency = espSettings.Highlight.FillTransparency
			highlight.DepthMode = espSettings.Highlight.DepthMode
			highlight.OutlineColor = espSettings.Highlight.OutlineColour
			highlight.OutlineTransparency = espSettings.Highlight.OutlineTransparency


			line.To = Vector2.new(root_pos.X, root_pos.Y)
			line.From = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 1)
			line.Thickness = espSettings.Tracer.Thickness
			line.Visible = espSettings.Tracer.Enabled

			text.Position = Vector2.new(root_pos.X, root_pos.Y)
			text.Visible = espSettings.Name.Enabled
			text.Outline = espSettings.Name.Outline
			text.Font = espSettings.Name.Font
			text.Text = tostring(p.Name)

			text2.Position = Vector2.new(root_pos.X, root_pos.Y + 36)

			if espSettings.Highlight.UseTCFill then
				highlight.FillColor = player.TeamColor.Color
			end

			if espSettings.Highlight.UseTCOutline then
				highlight.OutlineColor = player.TeamColor.Color
			end

			if espSettings.Name.Enabled then
				text2.Visible = espSettings.Name.ShowDist
			else
				text2.Visible = false
			end
			text2.Outline = espSettings.Name.Outline
			text2.Font = espSettings.Name.Font
			text2.Text = (mag.."s")

			if player.Team == localPlayer.Team and espSettings.TeamCheck then
				line.Visible = false
				text.Visible = false
				text2.Visible = false
				highlight.Enabled = false
			else
				if espSettings.Tracer.UseTC then
					line.Color = player.TeamColor.Color
				else
					line.Color = espSettings.Tracer.Colour
				end

				if espSettings.Name.UseTC then
					text.Color = player.TeamColor.Color
				else
					text.Color = espSettings.Name.Colour
				end

				if espSettings.Name.AutoScale then
					text.Size = (mag / 50)
					text2.Size = (mag / 20)
				end
			end


		else
			line.Visible = false
			text.Visible = false
			text2.Visible = false
			highlight.Enabled = false
		end
	end)

end

local function player_added(player)
	if player.Character then
		esp(player,player.Character)
	end
	player.CharacterAdded:Connect(function(character)
		esp(player,character)
	end)
end

for index,player in next, playerService:GetPlayers() do 
	if player ~= localPlayer then
		p_added(player)
	end
end

playerService.PlayerAdded:Connect(player_added)



--\\

--// UI Library

local OrionLib = loadstring(game:HttpGet(('https://raw.githubusercontent.com/shlexware/Orion/main/source')))()
local Window = OrionLib:MakeWindow({Name = "luaware (Private Release)", HidePremium = true, SaveConfig = false, ConfigFolder = "luaware", IntroEnabled = true, IntroText = "luaware", IntroIcon = "rbxassetid://11212490886"})

local LegitTab = Window:MakeTab({
	Name = "Legit",
	Icon = "rbxassetid://4483345998",
	PremiumOnly = false
})

local ModTab = Window:MakeTab({
	Name = "Gun Mods",
	Icon = "rbxassetid://4483345737",
	PremiumOnly = false
})

local VisualTab = Window:MakeTab({
	Name = "Visuals",
	Icon = "rbxassetid://10802204364",
	PremiumOnly = false
})

local OtherTab = Window:MakeTab({
	Name = "Other",
	Icon = "rbxassetid://6961018885",
	PremiumOnly = false
})

local AimbotSection = LegitTab:AddSection({
	Name = "Aimbot"
})

LegitTab:AddToggle({
	Name = "Enabled",
	Default = aimSettings.Aimbot,
	Callback = function(Value)
		aimSettings.Aimbot = Value
	end    
})
LegitTab:AddToggle({
	Name = "TeamCheck",
	Default = aimSettings.TeamCheck,
	Callback = function(Value)
		aimSettings.TeamCheck = Value
	end    
})
LegitTab:AddToggle({
	Name = "WallCheck",
	Default = aimSettings.WallCheck,
	Callback = function(Value)
		aimSettings.WallCheck = Value
	end    
})

local db = false

local Keybind = LegitTab:AddLabel("Keybind - "..aimSettings.Keybind.Name)


LegitTab:AddButton({
	Name = "Keybind",
	Callback = function()
	db = false
		local a = userInputService.InputBegan:Connect(function(input, gameProcessed)
			if gameProcessed then return end

			if db then return end

			db = true

			aimSettings.Keybind = input.KeyCode or input.UserInputType
			Keybind:Set("Keybind - "..aimSettings.Keybind.Name)


		end)
  	end    
})

LegitTab:AddSlider({
	Name = "Smoothness",
	Min = 0.1,
	Max = 3,
	Default = aimSettings.Smoothness,
	Color = Color3.fromRGB(255,255,255),
	Increment = 0.1,
	ValueName = "",
	Callback = function(Value)
		aimSettings.Smoothness = Value
	end    
})

LegitTab:AddDropdown({
	Name = "AimPart",
	Default = aimSettings.AimPart,
	Options = {"Head", "HumanoidRootPart", "UpperTorso", "LowerTorso"},
	Callback = function(Value)
		aimSettings.AimPart = Value
	end    
})

local SilentSection = LegitTab:AddSection({
	Name = "Silent"
})

LegitTab:AddToggle({
	Name = "Enabled",
	Default = silentSettings.Enabled,
	Callback = function(Value)
		silentSettings.Enabled = Value
	end    
})

LegitTab:AddDropdown({
	Name = "AimPart",
	Default = silentSettings.AimPart,
	Options = {"Head", "HumanoidRootPart"},
	Callback = function(Value)
		silentSettings.AimPart = Value
	end    
})

local TriggerSection = LegitTab:AddSection({
	Name = "Triggerbot"
})

LegitTab:AddToggle({
	Name = "Enabled",
	Default = triggerBotSettings.Enabled,
	Callback = function(Value)
		triggerBotSettings.Enabled = Value
	end    
})

LegitTab:AddSlider({
	Name = "Delay (ms)",
	Min = 0,
	Max = 1000,
	Default = silentSettings.Delay,
	Color = Color3.fromRGB(255,255,255),
	Increment = 1,
	ValueName = "",
	Callback = function(Value)
		silentSettings.Delay = Value
	end    
})

local FOVSection = LegitTab:AddSection({
	Name = "FOV"
})

LegitTab:AddToggle({
	Name = "Show FOV",
	Default = circleSettings.ShowFov,
	Callback = function(Value)
		circleSettings.ShowFov = Value
	end    
})

LegitTab:AddColorpicker({
	Name = "Colour",
	Default = circleSettings.Colour,
	Callback = function(Value)
		circleSettings.Colour = Value
	end	  
})

LegitTab:AddSlider({
	Name = "Radius",
	Min = 1,
	Max = 1000,
	Default = circleSettings.Radius,
	Color = Color3.fromRGB(255,255,255),
	Increment = 1,
	ValueName = "",
	Callback = function(Value)
		circleSettings.Radius = Value
	end    
})

LegitTab:AddSlider({
	Name = "Sides",
	Min = 1,
	Max = 256,
	Default = circleSettings.Sides,
	Color = Color3.fromRGB(255,255,255),
	Increment = 1,
	ValueName = "",
	Callback = function(Value)
		circleSettings.Sides = Value
	end    
})

VisualTab:AddToggle({
	Name = "Teamcheck",
	Default = espSettings.TeamCheck,
	Callback = function(Value)
		espSettings.TeamCheck = Value
	end    
})

local NameSection = VisualTab:AddSection({
	Name = "Name"
})

VisualTab:AddToggle({
	Name = "Enabled",
	Default = espSettings.Name.Enabled,
	Callback = function(Value)
		espSettings.Name.Enabled = Value
	end    
})

VisualTab:AddToggle({
	Name = "Show Distance",
	Default = espSettings.Name.ShowDist,
	Callback = function(Value)
		espSettings.Name.ShowDist = Value
	end    
})

VisualTab:AddColorpicker({
	Name = "Colour",
	Default = espSettings.Name.Colour,
	Callback = function(Value)
		espSettings.Name.Colour = Value
	end	  
})

VisualTab:AddToggle({
	Name = "Use TeamColour",
	Default = espSettings.Name.UseTC,
	Callback = function(Value)
		espSettings.Name.UseTC = Value
	end    
})

VisualTab:AddToggle({
	Name = "Outline",
	Default = espSettings.Name.Outline,
	Callback = function(Value)
		espSettings.Name.Outline = Value
	end    
})

VisualTab:AddSlider({
	Name = "Size",
	Min = 1,
	Max = 100,
	Default = espSettings.Name.Size,
	Color = Color3.fromRGB(255,255,255),
	Increment = 1,
	ValueName = "",
	Callback = function(Value)
		espSettings.Name.Size = Value
	end    
})

--[[VisualTab:AddToggle({
	Name = "AutoScale",
	Default = espSettings.Name.AutoScale,
	Callback = function(Value)
		espSettings.Name.AutoScale = Value
	end    
})]]


VisualTab:AddSlider({
	Name = "Font",
	Min = 1,
	Max = 3,
	Default = espSettings.Name.Font,
	Color = Color3.fromRGB(255,255,255),
	Increment = 1,
	ValueName = "",
	Callback = function(Value)
		espSettings.Name.Font = Value
	end    
})

local TracerSection = VisualTab:AddSection({
	Name = "Tracer"
})

VisualTab:AddToggle({
	Name = "Enabled",
	Default = espSettings.Tracer.Enabled,
	Callback = function(Value)
		espSettings.Tracer.Enabled = Value
	end    
})

VisualTab:AddSlider({
	Name = "Thickness",
	Min = 1,
	Max = 5,
	Default = espSettings.Tracer.Thickness,
	Color = Color3.fromRGB(255,255,255),
	Increment = 1,
	ValueName = "",
	Callback = function(Value)
		espSettings.Tracer.Thickness = Value
	end    
})

VisualTab:AddColorpicker({
	Name = "Colour",
	Default = espSettings.Tracer.Colour,
	Callback = function(Value)
		espSettings.Tracer.Colour = Value
	end	  
})

VisualTab:AddToggle({
	Name = "Use TeamColour",
	Default = espSettings.Tracer.UseTC,
	Callback = function(Value)
		espSettings.Tracer.UseTC = Value
	end    
})

local HighlightSection = VisualTab:AddSection({
	Name = "Highlight"
})

VisualTab:AddToggle({
	Name = "Enabled",
	Default = espSettings.Highlight.Enabled,
	Callback = function(Value)
		espSettings.Highlight.Enabled = Value
	end    
})

VisualTab:AddToggle({
	Name = "Team Color Outline",
	Default = espSettings.Highlight.UseTCOutline,
	Callback = function(Value)
		espSettings.Highlight.UseTCOutline = Value
	end    
})

VisualTab:AddToggle({
	Name = "Team Color Fill",
	Default = espSettings.Highlight.UseTCFill,
	Callback = function(Value)
		espSettings.Highlight.UseTCFill = Value
	end    
})

VisualTab:AddColorpicker({
	Name = "Outline Colour",
	Default = espSettings.Highlight.OutlineColour,
	Callback = function(Value)
		espSettings.Highlight.OutlineColour = Value
	end	  
})

VisualTab:AddSlider({
	Name = "Outline Transparency",
	Min = 0,
	Max = 1,
	Default = espSettings.Highlight.OutlineTransparency,
	Color = Color3.fromRGB(255,255,255),
	Increment = 0.1,
	ValueName = "",
	Callback = function(Value)
		espSettings.Highlight.OutlineTransparency = Value
	end    
})

VisualTab:AddColorpicker({
	Name = "Fill Colour",
	Default = espSettings.Highlight.FillColour,
	Callback = function(Value)
		espSettings.Highlight.FillColour = Value
	end	  
})

VisualTab:AddSlider({
	Name = "Fill Transparency",
	Min = 0,
	Max = 1,
	Default = espSettings.Highlight.FillTransparency,
	Color = Color3.fromRGB(255,255,255),
	Increment = 0.1,
	ValueName = "",
	Callback = function(Value)
		espSettings.Highlight.FillTransparency = Value
	end    
})

VisualTab:AddDropdown({
	Name = "Depth Mode",
	Default = "AlwaysOnTop",
	Options = {"AlwaysOnTop", "Occluded"},
	Callback = function(Value)
		if Value == "AlwaysOnTop" then
			espSettings.Highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
		else
			espSettings.Highlight.DepthMode = Enum.HighlightDepthMode.Occluded
		end
	end    
})

local ModSection = ModTab:AddSection({
	Name = "Gun Mods"
})

ModTab:AddLabel("If not working respawn")

ModTab:AddButton({
	Name = "No Recoil",
	Callback = function(Value)
		gunMod(3)
	end    
})

ModTab:AddButton({
	Name = "No Spread",
	Callback = function(Value)
		gunMod(2)
	end    
})

ModTab:AddButton({
	Name = "Automatic",
	Callback = function(Value)
		gunMod(1)
	end    
})

ModTab:AddButton({
	Name = "Fast Reload",
	Callback = function(Value)
		gunMod(5)
	end    
})

ModTab:AddButton({
	Name = "Fast Equip",
	Callback = function(Value)
		gunMod(4)
	end    
})

ModTab:AddButton({
	Name = "Firerate",
	Callback = function(Value)
		gunMod(6)
	end    
})

local MeleeSection = OtherTab:AddSection({
	Name = "Melee"
})

local meleeTable = {}

for index,melee in pairs(replicatedStorage.ItemData.Images.Melees:GetChildren()) do
	table.insert(meleeTable, melee.Name)
end

table.sort(meleeTable, function(a, b)
	return b > a
end)

OtherTab:AddDropdown({
	Name = "Melee Swap",
	Default = "",
	Options = meleeTable,
	Callback = function(Value)
		for index,value in pairs(localPlayer.Data.Shuffles.Melees:GetChildren()) do
			value:Destroy()
		end
		local melee = Instance.new("StringValue", localPlayer.Data.Shuffles.Melees)
		melee.Name = Value

		OrionLib:MakeNotification({
			Name = "luaware",
			Content = "Changed Melee to "..Value,
			Image = "rbxassetid://11212490886",
			Time = 5
		})
	end    
})

OtherTab:AddLabel("Set melees to shuffle to activate")

local WeaponSkinSection = OtherTab:AddSection({
	Name = "Weapon Skin"
})

local weaponSkinTable = {}

local old, new = nil, nil, nil, nil
local skinFolder = replicatedStorage.Skins

for index,skin in pairs(replicatedStorage.Skins:GetChildren()) do
	table.insert(weaponSkinTable, skin.Name)
end

table.sort(weaponSkinTable, function(a, b)
	return b > a
end)

OtherTab:AddDropdown({
	Name = "Skin 1",
	Default = "",
	Options = weaponSkinTable,
	Callback = function(Value)
	old = Value
	end    
})

OtherTab:AddDropdown({
	Name = "Skin 2",
	Default = "",
	Options = weaponSkinTable,
	Callback = function(Value)
	new = Value
	end    
})

OtherTab:AddButton({
	Name = "Swap",
	Callback = function()

	if new == nil or old == nil then 

OrionLib:MakeNotification({
	Name = "luaware",
	Content = "Pick a skin to swap/replace.",
	Image = "rbxassetid://11212490886",
	Time = 5
})
return
	end


for i = 1,2 do
	if game.CoreGui:FindFirstChild(new..i) then
		game.CoreGui[new..i]:Destroy()
	elseif game.CoreGui:FindFirstChild(old..i) then
		game.CoreGui[old..i]:Destroy()
	end
end


local c1 = skinFolder[new]:Clone()
local c2 = skinFolder[old]:Clone()
c1.Name = old
c2.Name = new

skinFolder[new]:Destroy()
skinFolder[old]:Destroy()

c1.Parent = skinFolder
c2.Parent = skinFolder


task.wait(0.01)

OrionLib:MakeNotification({
	Name = "luaware",
	Content = "Swapped "..old.." with "..new,
	Image = "rbxassetid://11212490886",
	Time = 5
})

end    

})

--[[local MovementSection = OtherTab:AddSection({
	Name = "Movement"
})

OtherTab:AddToggle({
	Name = "Enable Bhop",
	Default = bhopSettings.Enabled,
	Callback = function(Value)
		bhopSettings.Enabled = Value
	end    
})

OtherTab:AddSlider({
	Name = "Bhop Speed",
	Min = 0,
	Max = 1000,
	Default = bhopSettings.Speed,
	Color = Color3.fromRGB(255,255,255),
	Increment = 1,
	ValueName = "",
	Callback = function(Value)
		bhopSettings.Speed = Value
	end    
})]]

--\\

OrionLib:MakeNotification({
	Name = "luaware",
	Content = "Welcome, "..tostring(localPlayer.DisplayName),
	Image = "rbxassetid://11212490886",
	Time = 5
})

OrionLib:Init()

--// Free BattleBucks

local args = {[1] = "POG"}
game:GetService("ReplicatedStorage").Redeem:InvokeServer(unpack(args))
local args = {[1] = "BLOXY"}
game:GetService("ReplicatedStorage").Redeem:InvokeServer(unpack(args))

--\\
