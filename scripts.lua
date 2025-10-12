
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

local gameId = game.PlaceId

local games = {
    [121864768012064] = 'https://api.luarmor.net/files/v3/loaders/c114f22ad9083078a16557cf4ba2dbf1.lua"', -- Fish It
    [127742093697776] = 'https://api.luarmor.net/files/v3/loaders/48f1736dfa373b940498ab06381ea6f4.lua', -- Plants Vs Brainrots
}

if games[gameId] then 
    print("Please wait, daddyhh~ loading..")
    loadstring(game:HttpGet(games[gameId]))()
else
    warn("Unsupported game.")
end
