repeat task.wait() until game.Players.LocalPlayer and game.Players.LocalPlayer.Character
if not game:IsLoaded() then
    game.Loaded:Wait()
end

print("Supported game!")
print("CreatorId terbaca:", game.CreatorId) -- Tambahkan ini untuk debug

local creator = game.CreatorId

local games = {
    [8605341] = 'https://raw.githubusercontent.com/x2zu/loader/refs/heads/main/ObfSource/Pixel%20Blade.lua',
}

if games[creator] then
    print("Game didukung, memuat script...")
    loadstring(game:HttpGet(games[creator]))()
else
    warn("Unsupported game. CreatorId saat ini:", creator)
end
