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
    [121864768012064] = 'https://api.luarmor.net/files/v3/loaders/91c92d3c217d524123cd466ca83c4f16.lua', -- Fish It
    [131716211654599] = 'https://api.luarmor.net/files/v3/loaders/978109b2813eaafe5878888c42527259.lua', -- Fisch
    [127742093697776] = 'https://api.luarmor.net/files/v3/loaders/a6271160c4b4adca2aa3744e705e07ee.lua', -- Plant Vs Brainrots
    [79546208627805] = 'https://api.luarmor.net/files/v3/loaders/57d0844789542ad8f7cae069edaf352e.lua', -- 99 Nights
}

if games[gameId] then 
    print("Please wait, daddyhh~ loading..")
    loadstring(game:HttpGet(games[gameId]))()
else
    warn("Unsupported game.")
end 



