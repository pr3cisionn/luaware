local gid = {
    ["PF"] = 292439477;
    ["Arsenal"] = 286090429;
}

if game.PlaceId == gid.PF then
    loadstring(game:HttpGet("https://raw.githubusercontent.com/pr3cisionn/luaware/main/Games/PhantomForces.lua"))()
elseif game.PlaceId == gid.Arsenal then
    loadstring(game:HttpGet("https://raw.githubusercontent.com/pr3cisionn/luaware/main/Games/Arsenal.lua"))()
end
