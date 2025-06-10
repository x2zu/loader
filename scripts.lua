
if not game:IsLoaded() then
    game.Loaded:Wait()
end

local supportedGames = {
    [101949297449238] = "https://raw.githubusercontent.com/x2zu/loader/main/ObfSource/Build%20An%20Island.lua",
    [18172550962] = "https://raw.githubusercontent.com/x2zu/loader/main/ObfSource/Pixel%20Blade.lua",
    [94682676231618] = "https://raw.githubusercontent.com/x2zu/loader/main/ObfSource/My%20Fishing%20Pier.lua",
    [126884695634066] = "https://raw.githubusercontent.com/x2zu/loader/main/ObfSource/BloxFruits.lua",
    [136755111277466] = "https://raw.githubusercontent.com/x2zu/loader/main/ObfSource/Anime%20Shadow2.lua",
}

local allowedPixelBladePlaceIds = {
    [18172553902] = true,
    [6161049307] = true,
    [18172550962] = true,
}

local gameId = game.GameId
local placeId = game.PlaceId

if supportedGames[gameId] then
    -- Special handling for Pixel Blade
    if gameId == 18172550962 then
        if allowedPixelBladePlaceIds[placeId] then
            loadstring(game:HttpGet(supportedGames[gameId]))()
        end
    else
        loadstring(game:HttpGet(supportedGames[gameId]))()
    end
end
