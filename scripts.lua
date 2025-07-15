repeat task.wait() until game.Players.LocalPlayer and game.Players.LocalPlayer.Character
if not game:IsLoaded() then
    game.Loaded:Wait()
end

print("Supported game!")
local creator = game.CreatorId

local games = {
    [35815907] = 'https://api.luarmor.net/files/v3/loaders/9241b4f2109da4b022659da0416590c9.lua', -- Steal A Brainrot
    [35289532] = 'https://api.luarmor.net/files/v3/loaders/48cd8b3c6232e05c413ef2be2ab089f9.lua', -- Dig
    [36097789] = 'https://api.luarmor.net/files/v3/loaders/dc3f04fe723109806cdcddd81d2ede59.lua', -- My Singing Brainrot
    [6042520]  = 'https://api.luarmor.net/files/v3/loaders/b918ceed6b4ed96e1e6b25e0f3686f6d.lua', -- 99 Nights
    [12398672] = 'https://api.luarmor.net/files/v3/loaders/67d568cc89eb0645549d8b5896934d5f.lua', -- Ink Games
} 

if games[creator] then 
    print("Please wait, daddyhh~ loading..")
    loadstring(game:HttpGet(games[creator]))()
else
    warn("Unsupported game.")
end
