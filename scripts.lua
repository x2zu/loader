repeat task.wait() until game.Players.LocalPlayer and game.Players.LocalPlayer.Character
if not game:IsLoaded() then
    game.Loaded:Wait()
end

print("Supported game!")
local creator = game.CreatorId

local games = {
    [8605341] = 'https://raw.githubusercontent.com/x2zu/loader/refs/heads/main/ObfSource/Pixel%20Blade.lua', -- Pixel Blade
    [35980748] = 'https://raw.githubusercontent.com/x2zu/loader/main/ObfSource/My%20Fishing%20Pier.lua', -- My Fishing Pier
    [3739465] = 'https://raw.githubusercontent.com/x2zu/loader/main/ObfSource/Dungeon%20Heroes.lua', -- Dungeon Heroes
    [35812225] = 'https://raw.githubusercontent.com/x2zu/loader/refs/heads/main/ObfSource/Anime%20Shadow2.lua', -- Anime Shadow 2
    [4372130] = 'https://raw.githubusercontent.com/x2zu/loader/main/ObfSource/BloxFruits.lua', -- Blox Fruits
    [35789249] = 'https://raw.githubusercontent.com/x2zu/loader/main/ObfSource/GrowAGarden.lua', -- Grow A Garden
    [35860275] = 'https://raw.githubusercontent.com/x2zu/loader/refs/heads/main/ObfSource/OneTouch.lua', -- One Touch
    [34063840] = 'https://raw.githubusercontent.com/x2zu/loader/refs/heads/main/ObfSource/AnimeRising.lua', -- Anime Rising
    [5096106] = 'https://raw.githubusercontent.com/x2zu/loader/main/ObfSource/AnimeRails.lua', -- Anime Rails
    [35815907] = 'https://raw.githubusercontent.com/x2zu/loader/refs/heads/main/ObfSource/StealABrainrot.lua', -- Steal A Brainrot
    }

if games[creator] then
    print("Please wait, daddyhh~ loading..")
    loadstring(game:HttpGet(games[creator]))()
else
    warn("Unsupported game.")
end
