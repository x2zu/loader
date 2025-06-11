if not game:IsLoaded() then
    game.Loaded:Wait()
end
print("Supported game!")
local creator = game.CreatorId

local games = {
    [18172550962] = 'https://raw.githubusercontent.com/x2zu/loader/refs/heads/main/ObfSource/Pixel%20Blade.lua', -- Pixel Blade
    [94682676231618] = 'https://raw.githubusercontent.com/x2zu/loader/main/ObfSource/My%20Fishing%20Pier.lua', -- My Fishing Pier
    [94845773826960] = 'https://raw.githubusercontent.com/x2zu/loader/main/ObfSource/Dungeon%20Heroes.lua', -- Dungeon Heroes
    [136755111277466] = 'https://raw.githubusercontent.com/x2zu/loader/refs/heads/main/ObfSource/Anime%20Shadow2.lua', -- Anime Shadow 2
    [101949297449238] = 'https://raw.githubusercontent.com/x2zu/loader/main/ObfSource/Build%20An%20Island.lua', -- Build An Island
    [2753915549] = 'https://raw.githubusercontent.com/x2zu/loader/main/ObfSource/BloxFruits.lua', -- Blox Fruits
    [126884695634066] = 'https://raw.githubusercontent.com/x2zu/loader/main/ObfSource/GrowAGarden.lua', -- Grow A Garden
}

if games[creator] then
    loadstring(game:HttpGet(games[creator]))()
else
    warn("Unsupported game")
end
