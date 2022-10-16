OrionLib = loadstring(game:HttpGet(('https://raw.githubusercontent.com/shlexware/Orion/main/source')))()

function Notify(text)
OrionLib:MakeNotification({
	Name = "luaware",
	Content = text,
	Image = "rbxassetid://11212490886",
	Time = 5
})
end
