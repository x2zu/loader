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
local creator = game.CreatorId

local games = {
    [35102746] = 'https://api.luarmor.net/files/v3/loaders/d577db7077756aa9249772848de92121.lua', -- Fish It
    [36015593] = 'https://api.luarmor.net/files/v3/loaders/f2b7376ca7f42ef61be98fd82a23502d.lua', -- Plants Vs Brainrots
 
} 

if games[creator] then 
    print("Please wait, daddyhh~ loading..")
    loadstring(game:HttpGet(games[creator]))()
else
    warn("Unsupported game.")
end






