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
    [35815907] = 'https://api.luarmor.net/files/v3/loaders/9241b4f2109da4b022659da0416590c9.lua', -- Steal A Brainrot
    [35289532] = 'https://api.luarmor.net/files/v3/loaders/48cd8b3c6232e05c413ef2be2ab089f9.lua', -- Dig
    -- [36097789] = 'https://api.luarmor.net/files/v3/loaders/dc3f04fe723109806cdcddd81d2ede59.lua', -- My Singing Brainrot ( Discontinued )
    -- [35789249] = 'https://api.luarmor.net/files/v3/loaders/b93e4effaa843cb2c20f15ab3b7670cd.lua', -- Grow A Garden ( Discontinued )
    -- [9275288] = 'https://api.luarmor.net/files/v3/loaders/df9794a5edfcf119da293041f9368ce5.lua', -- Hide The Body ( Discontinued )
    [35888785] = 'https://api.luarmor.net/files/v3/loaders/5855fb7c80db4b87e10fc66309916005.lua', -- Prospecting 
    [3385385] = 'https://api.luarmor.net/files/v3/loaders/d03f35f5c3c18cc4d689583e0a8f6b7b.lua', -- Hypershot
    [35102746] = 'https://api.luarmor.net/files/v3/loaders/e0706dfb0d6f7d6c3f6fae1825b32cb1.lua', -- Fish It
} 

if games[creator] then 
    print("Please wait, daddyhh~ loading..")
    loadstring(game:HttpGet(games[creator]))()
else
    warn("Unsupported game.")
end



