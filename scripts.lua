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
print("Supported game!")
local creatorId = game.CreatorId
local communityCreators = {
    [35102746] = 'https://api.luarmor.net/files/v4/loaders/91c92d3c217d524123cd466ca83c4f16.lua', -- Fish It
    [7381705] = 'https://api.luarmor.net/files/v3/loaders/6bc668603e3c93919387e564af72fd88.lua', -- Fisch
    [8818124] = 'https://api.luarmor.net/files/v3/loaders/49a49c2667090f88ed7589c2c00c9d31.lua', -- Violance District
}

if communityCreators[creatorId] then 
    print("game supported! Loading script...")
    loadstring(game:HttpGet(communityCreators[creatorId]))()
else
    warn("Unsupported game.")
end







