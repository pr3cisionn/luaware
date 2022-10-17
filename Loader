repeat task.wait()

until game.PlaceId ~= 0 

local OrionLib = loadstring(game:HttpGet(('https://raw.githubusercontent.com/shlexware/Orion/main/source')))()

local function Notify(text)
OrionLib:MakeNotification({
	Name = "luaware",
	Content = text,
	Image = "rbxassetid://11212490886",
	Time = 5
})
end

local supported = {
    286090429
}

if table.find(supported, game.PlaceId) then
local url = ("https://raw.githubusercontent.com/pr3cisionn/luaware/main/Games/"..game.PlaceId)
loadstring(syn.request({ Url = url }).Body)()
else
Notify("Unsupported game.")
end
