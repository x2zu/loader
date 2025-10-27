--[[ 
__   __ _____  _______   _ 
\ \ / // __  \|___  / | | |
 \ V / `' / /'   / /| | | |
 /   \   / /    / / | | | |
/ /^\ \./ /___./ /__| |_| |
\/   \/\_____/\_____/\___/
]]

-- Wait until player and character are loaded
repeat task.wait() until game.Players.LocalPlayer and game.Players.LocalPlayer.Character
if not game:IsLoaded() then
    game.Loaded:Wait()
end

print("Supported game!")

local gameId = game.GameId

local games = {
    [121864768012064] = 'https://api.luarmor.net/files/v3/loaders/91c92d3c217d524123cd466ca83c4f16.lua', -- Fish It
    [16732694052] = 'https://api.luarmor.net/files/v3/loaders/978109b2813eaafe5878888c42527259.lua', -- Fisch
}

if games[gameId] then 
    print("Please wait, daddyhh~ loading..")
    loadstring(game:HttpGet(games[gameId]))()
else
    warn("Unsupported game.")
end
