```game.Loaded:Wait()

local MarketplaceService = game:GetService("MarketplaceService")
local creator = MarketplaceService:GetProductInfo(game.PlaceId).Creator.CreatorTargetId

local script_key = false

local supportedGames = {
    [101949297449238] = "https://raw.githubusercontent.com/x2zu/loader/main/ObfSource/Build%20An%20Island.lua",
    [18172550962] = "https://raw.githubusercontent.com/x2zu/loader/main/ObfSource/Pixel%20Blade.lua",
    [94682676231618] = "https://raw.githubusercontent.com/x2zu/loader/main/ObfSource/My%20Fishing%20Pier.lua",
    [126884695634066] = "https://raw.githubusercontent.com/x2zu/loader/main/ObfSource/BloxFruits.lua",
    [136755111277466] = "https://raw.githubusercontent.com/x2zu/loader/main/ObfSource/Anime%20Shadow2.lua",
}

if creator == 2753915549 or supportedGames[game.PlaceId] then
    local url = supportedGames[game.PlaceId]

    if url == "" then
        warn("Url doesnt found in this game!:", game.PlaceId)
    else
        loadstring(game:HttpGet(url))()
    end
else
    warn("Script not supported this game!")
end
```
