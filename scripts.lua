if not game:IsLoaded() then
    game.Loaded:Wait()
end

local MarketplaceService = game:GetService("MarketplaceService")
local creator = MarketplaceService:GetProductInfo(game.PlaceId).Creator.CreatorTargetId

local script_key = false

if creator == 2753915549 then
    local url
    if script_key then
        url = "https://raw.githubusercontent.com/x2zu/loader/refs/heads/main/ObfSource/BloxFruits.lua" -- Blox Fruits
    else
        url = "https://raw.githubusercontent.com/x2zu/loader/refs/heads/main/ObfSource/BloxFruits.lua" -- Blox Fruits
    end
    loadstring(game:HttpGet(url))()
else
    warn("Script not supported this game!")
end
