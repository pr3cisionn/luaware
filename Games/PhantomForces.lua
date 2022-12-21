repeat task.wait()
    
until game:IsLoaded()

local espsettings = {
    enabled = false;

    depthmode = Enum.HighlightDepthMode.AlwaysOnTop;

    fillcolor = Color3.new(1, 1, 1);
    filltransparency = 1;

    outlinecolor = Color3.new(1, 1, 1);
    outlinetransparency = 0;
}

local aimsettings = {
    enabled = false;
    isaiming = false;

    tohit = "Head";
    hitpart = "Head";
    smoothness = 0.5;
    wallcheck = false;

    fov = 150;
    showfov = true;
    fovcolour = Color3.new(1,1,1);

}

local playerService = game:GetService("Players")
local runService = game:GetService("RunService")
local userInputService = game:GetService("UserInputService")

local player = playerService.LocalPlayer
local mouse = player:GetMouse()
local camera = workspace.CurrentCamera

local highlightFolder = Instance.new("Folder", game:GetService("CoreGui"))

local circle = Drawing.new("Circle")

userInputService.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        aimsettings.isaiming = true
    end
end)

userInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        aimsettings.isaiming = false
    end
end)

local function addhighlight(object)

   local highlight = Instance.new("Highlight", highlightFolder)
   highlight.Adornee = object

   highlight.Enabled = espsettings.enabled

   highlight.FillColor = espsettings.fillcolor
   highlight.FillTransparency = espsettings.filltransparency

   highlight.OutlineColor = espsettings.outlinecolor
   highlight.OutlineTransparency = espsettings.outlinetransparency

   

   highlight.Adornee.Changed:Connect(function()
       if not highlight.Adornee or not highlight.Adornee.Parent then
           highlight:Destroy()    
       end
   end)

   return highlight
end

local function addtoplayer(object)
   if object:IsA"Model" and object.Name == "Player" and object.Parent.Name ~= tostring(player.TeamColor) then
       addhighlight(object)
   end
end

local function wallCheck(object, ignorelist)
    if not aimsettings.wallcheck then return true end

    Origin = workspace.CurrentCamera.CFrame.p
	CheckRay = Ray.new(Origin, object.Head.Position - Origin)
	Hit = workspace:FindPartOnRayWithIgnoreList(CheckRay, ignorelist)

    if Hit and Hit.Parent == object then
         return true
    else
        return false
    end
end

function IsVisible(character, ignore)
	if not aimSettings.WallCheck then return true end

	origin = workspace.CurrentCamera.CFrame.p
	checkRay = Ray.new(origin, character.Head.Position - origin)
	hit = workspace:FindPartOnRayWithIgnoreList(checkRay, ignore)
	
	if hit and hit.Parent == character then return true else return false end
end

local function getClosestPlayer()
    local maxdist, target = math.huge, nil

    for i,v in pairs(workspace.Players:GetDescendants()) do
        if v and v:IsA"Model" and v.Name == "Player" and v.Parent.Name ~= tostring(player.TeamColor) then

            local pos = camera:WorldToViewportPoint(v.Torso.Position)
            local distance = (Vector3.new(camera.CFrame.X, camera.CFrame.Y, camera.CFrame.Z) - v.Torso.Position).Magnitude

            local mag = (Vector2.new(mouse.X, mouse.Y) - Vector2.new(pos.X, pos.Y)).Magnitude

            if mag < maxdist and mag < aimsettings.fov and (distance < 1000 or distance > -1000) and wallCheck(v, {workspace.Players[tostring(player.TeamColor.Name)], camera}) then
                maxdist = mag
                target = v
            end
            
        end
    end
    return target
end

for i,v in pairs(workspace.Players:GetDescendants()) do
   addtoplayer(v)
end

workspace.Players.DescendantAdded:Connect(function(v)
   addtoplayer(v)
end)

local function update()

    espsettings.enabled = Toggles.ESPEnabled.Value
    espsettings.filltransparency = Options.FillTransparency.Value
    espsettings.fillcolor = Options.FillColour.Value
    espsettings.outlinetransparency = Options.OutlineTransparency.Value
    espsettings.outlinecolor = Options.OutlineColour.Value
    espsettings.depthmode = Enum.HighlightDepthMode[Options.Depthmode.Value]

    aimsettings.enabled = Toggles.AimbotEnabled.Value
    aimsettings.tohit = Options.AimbotHitpart.Value
    aimsettings.fov = Options.AimbotFOVRadius.Value
    aimsettings.smoothness = Options.AimbotSmoothness.Value
    aimsettings.fovcolour = Options.AimbotFOVColour.Value
    aimsettings.wallcheck = Toggles.AimbotWallcheck.Value

    circle.Radius = aimsettings.fov
    circle.Color = aimsettings.fovcolour
    circle.Position = Vector2.new(userInputService:GetMouseLocation().X, userInputService:GetMouseLocation().Y)
    circle.Visible = aimsettings.showfov

    for _, v in pairs(highlightFolder:GetChildren()) do
        if v:IsA("Highlight") then
            v.Enabled = espsettings.enabled

            v.DepthMode = espsettings.depthmode

            v.FillColor = espsettings.fillcolor
            v.FillTransparency = espsettings.filltransparency
            
            v.OutlineColor = espsettings.outlinecolor
            v.OutlineTransparency = espsettings.outlinetransparency
        end 
    end

end

local repo = "https://raw.githubusercontent.com/wally-rblx/LinoriaLib/main/"

local Library = loadstring(game:HttpGet(repo .. "Library.lua"))()

local Window = Library:CreateWindow("luaware | V1.0")

local AimTab = Window:AddTab("Aim")
local VisualTab = Window:AddTab("Visuals")
local MenuTab = Window:AddTab("Menu")

local ESPBox = VisualTab:AddLeftTabbox("Highlights") do
    local Main = ESPBox:AddTab("Highlight")

    Main:AddToggle("ESPEnabled", {Text = "Enabled", Default = espsettings.enabled})

    Main:AddDropdown("Depthmode", {Values = { "AlwaysOnTop", "Occluded"}, Default = 1, Multi = false, Text = "Depthmode"})

    Main:AddSlider("FillTransparency", {Text = "Fill Transparency", Default = 1, Min = 0, Max = 1, Rounding = 1, Compact = false, })

    Main:AddLabel("Fill Colour"):AddColorPicker("FillColour", {Default = Color3.new(1, 1, 1), Title = "Fill Colour", })

    Main:AddSlider("OutlineTransparency", {Text = "Outline Transparency", Default = 0, Min = 0, Max = 1, Rounding = 1, Compact = false,})

    Main:AddLabel("Outline Colour"):AddColorPicker("OutlineColour", {Default = Color3.new(1, 1, 1), Title = "Outline Colour", })

end

local AimBox = AimTab:AddLeftTabbox("Aimbot") do
    local Main = AimBox:AddTab("Aimbot")
    local Other = AimBox:AddTab("FOV")

    Main:AddToggle("AimbotEnabled", {Text = "Enabled", Default = aimsettings.enabled})

    Main:AddToggle("AimbotWallcheck", {Text = "Wallcheck", Default = aimsettings.wallcheck})

    Main:AddDropdown("AimbotHitpart", {Values = { "Head", "Torso", "Left Arm", "Right Arm", "Left Leg", "Right Leg"}, Default = 1, Multi = false, Text = "Hitpart"})

    Main:AddSlider("AimbotSmoothness", {Text = "Smoothness", Default = aimsettings.smoothness, Min = 0.1, Max = 2, Rounding = 1, Compact = false,})

    Other:AddToggle("AimbotShowFOV", {Text = "Enabled", Default = aimsettings.showfov})

    Other:AddSlider("AimbotFOVRadius", {Text = "FOV", Default = aimsettings.fov, Min = 50, Max = 1000, Rounding = 0, Compact = false,})

    Other:AddLabel("FOV Colour"):AddColorPicker("AimbotFOVColour", {Default = Color3.new(1, 1, 1), Title = "FOV Colour", })

end

local MenuBox = MenuTab:AddLeftTabbox("Menu") do
    local Main = MenuBox:AddTab("Menu")
    
    Main:AddToggle("WatermarkEnabled", {Text = "Watermark", Default = true})
end

Library.ToggleKeybind = Options.MenuKeybind 

runService.RenderStepped:Connect(function(deltaTime)
    update()

    if Toggles.WatermarkEnabled.Value then
        Library:SetWatermark("luaware | "..math.floor(1 / deltaTime).."fps | "..math.round(player:GetNetworkPing() * 2000).."ms")
    else
        Library:SetWatermarkVisibility(false)
    end

    if aimsettings.enabled and aimsettings.isaiming and getClosestPlayer() ~= nil then
        local pos = camera:WorldToScreenPoint(getClosestPlayer()[aimsettings.hitpart].Position)

        mousemoverel((pos.X - mouse.X) * aimsettings.smoothness, (pos.Y - mouse.Y) * aimsettings.smoothness)
    end
end)
