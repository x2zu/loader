repeat task.wait() until game.Players.LocalPlayer and game.Players.LocalPlayer.Character
if not game:IsLoaded() then
    game.Loaded:Wait()
end

print("Supported game!")
local creator = game.CreatorId

local games = {
    [35815907] = 'https://raw.githubusercontent.com/x2zu/loader/refs/heads/main/ObfSource/StealABrainrot.lua', -- Steal A Brainrot
    [35289532] = 'https://raw.githubusercontent.com/x2zu/loader/refs/heads/main/ObfSource/Dig.lua', -- Dig
    [36097789] = 'https://raw.githubusercontent.com/x2zu/loader/refs/heads/main/ObfSource/MySingingBrainrot.lua', -- My Singing Brainrot
    }

if games[creator] then
    print("Please wait, daddyhh~ loading..")
    loadstring(game:HttpGet(games[creator]))()
else
    warn("Unsupported game.")
end
