repeat task.wait() until game.Players.LocalPlayer and game.Players.LocalPlayer.Character
if not game:IsLoaded() then
    game.Loaded:Wait()
end

print("Supported game!")
local creator = game.CreatorId

local games = {
    [35860275] = 'https://raw.githubusercontent.com/x2zu/loader/refs/heads/main/ObfSource/OneTouch.lua', -- One Touch
    }

if games[creator] then
    print("Please wait, daddyhh~ loading..")
    loadstring(game:HttpGet(games[creator]))()
else
    warn("Unsupported game.")
end