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
    [121864768012064] = 'https://api.luarmor.net/files/v3/loaders/d577db7077756aa9249772848de92121.lua', -- Fish It
    [127742093697776] = 'https://api.luarmor.net/files/v3/loaders/82b75b1b4e2028dfbc858df2d5cebae6.lua', -- Plants Vs Brainrots
}

if games[gameId] then 
    print("Please wait, daddyhh~ loading..")
    loadstring(game:HttpGet(games[gameId]))()
else
    warn("Unsupported game.")
end

