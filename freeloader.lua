
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
    [121864768012064] = 'https://raw.githubusercontent.com/xwwwwwwwwwwwwwwwwwwwqd/loader/main/GamesData/FishItFree.lua', -- Fish It
    [16732694052] = 'https://raw.githubusercontent.com/xwwwwwwwwwwwwwwwwwwwqd/loader/main/GamesData/Fisch.lua', -- Fisch
}

if games[gameId] then 
    print("Please wait, daddyhh~ loading..")
    loadstring(game:HttpGet(games[gameId]))()
else
    warn("Unsupported game.")
end



