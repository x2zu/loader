repeat task.wait() until game.Players.LocalPlayer and game.Players.LocalPlayer.Character
if not game:IsLoaded() then
    game.Loaded:Wait()
end

print("Supported game!")
local creator = game.CreatorId

local games = {
    [8605341] = 'https://raw.githubusercontent.com/x2zu/loader/refs/heads/main/ObfSource/Pixel%20Blade.lua', -- Pixel Blade ( Discontinued )
    [35980748] = 'https://raw.githubusercontent.com/x2zu/loader/main/ObfSource/My%20Fishing%20Pier.lua', -- My Fishing Pier ( Discontinued )
    [3739465] = 'https://raw.githubusercontent.com/x2zu/loader/main/ObfSource/Dungeon%20Heroes.lua', -- Dungeon Heroes ( Discontinued )
    [35812225] = 'https://raw.githubusercontent.com/x2zu/loader/refs/heads/main/ObfSource/Anime%20Shadow2.lua', -- Anime Shadow 2 ( Discontinued )
    [4372130] = 'https://raw.githubusercontent.com/x2zu/loader/main/ObfSource/BloxFruits.lua', -- Blox Fruits ( Discontinued )
    [35860275] = 'https://raw.githubusercontent.com/x2zu/loader/refs/heads/main/ObfSource/OneTouch.lua', -- One Touch
    [34063840] = 'https://raw.githubusercontent.com/x2zu/loader/refs/heads/main/ObfSource/AnimeRising.lua', -- Anime Rising ( Discontinued )
    [5096106] = 'https://raw.githubusercontent.com/x2zu/loader/main/ObfSource/AnimeRails.lua', -- Anime Rails ( Discontinued )
    [35815907] = 'https://raw.githubusercontent.com/x2zu/loader/refs/heads/main/ObfSource/StealABrainrot.lua', -- Steal A Brainrot ( Discontinued )
    [12836673] = 'https://raw.githubusercontent.com/x2zu/loader/refs/heads/main/ObfSource/BladeBall.lua', -- Blade Ball
    [6042520] = 'https://raw.githubusercontent.com/x2zu/loader/refs/heads/main/ObfSource/99Nights.lua', -- 99 Nights
    [35289532] = 'https://raw.githubusercontent.com/x2zu/loader/refs/heads/main/ObfSource/Dig.lua', -- Dig
    [35289532] = 'https://raw.githubusercontent.com/x2zu/loader/refs/heads/main/ObfSource/BestFeatureDig.lua', -- Best Feature Dig
    [3959677] = 'https://raw.githubusercontent.com/x2zu/loader/refs/heads/main/ObfSource/StealAPets.lua', -- Steal A Pets
    [12398672] = 'https://raw.githubusercontent.com/x2zu/loader/refs/heads/main/ObfSource/InkGame.lua', -- InkGame
    }

if games[creator] then
    print("Please wait, daddyhh~ loading..")
    loadstring(game:HttpGet(games[creator]))()
else
    warn("Unsupported game.")
end
