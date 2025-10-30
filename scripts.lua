--[[
__   __ _____  _______   _ 
\ \ / // __  \|___  / | | |
 \ V / `' / /'   / /| | | |
 /   \   / /    / / | | | |
/ /^\ \./ /___./ /__| |_| |
\/   \/\_____/\_____/\___/
]]

repeat task.wait() until game.Players.LocalPlayer and game.Players.LocalPlayer.Character
if not game:IsLoaded() then
    game.Loaded:Wait()
end

local creatorId = game.CreatorId
local communityCreators = {
    [35102746] = 'https://api.luarmor.net/files/v3/loaders/91c92d3c217d524123cd466ca83c4f16.lua', -- Fish Atelier (Fish It)
    [7381705] = 'https://api.luarmor.net/files/v3/loaders/978109b2813eaafe5878888c42527259.lua', -- Fisching (Fisch)
    [6042520] = 'https://api.luarmor.net/files/v3/loaders/57d0844789542ad8f7cae069edaf352e.lua', -- Grandma's Favourite Games (99 Nights)
    [34869880] = 'https://api.luarmor.net/files/v3/loaders/a6271160c4b4adca2aa3744e705e07ee.lua' -- Yo-Gurt Studio (Plants vs Brainrot)
}

if communityCreators[creatorId] then 
    print("game supported! Loading script...")
    loadstring(game:HttpGet(communityCreators[creatorId]))()
else
    warn("Unsupported game.")
end
