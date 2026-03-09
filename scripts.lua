--[[ 
__   __ _____  _______   _ 
\ \ / // __  \|___  / | | |
 \ V / `' / /'   / /| | | |
 /   \   / /    / / | | | |
/ /^\ \./ /___./ /__| |_| |
\/   \/\_____/\_____/\___/
]]

local executor = "Unknown"

pcall(function()
    if identifyexecutor then
        executor = identifyexecutor()
    elseif getexecutorname then
        executor = getexecutorname()
    end
end)

executor = string.lower(tostring(executor))

local blocked = {
    "xeno",
    "solara"
}

for _,v in ipairs(blocked) do
    if string.find(executor, v) then
        game.Players.LocalPlayer:Kick("Executor not supported. Please use a high UNC executor.")
        return
    end
end

local requiredFunctions = {
    "getgc",
    "hookfunction",
    "getgenv"
}

for _,func in ipairs(requiredFunctions) do
    if not getfenv()[func] then
        game.Players.LocalPlayer:Kick("Your executor does not support required UNC level.")
        return
    end
end

repeat task.wait() until game.Players.LocalPlayer and game.Players.LocalPlayer.Character
if not game:IsLoaded() then
    game.Loaded:Wait()
end

print("Supported game!")

local creatorId = game.CreatorId

local communityCreators = {
    [35102746] = 'https://api.luarmor.net/files/v4/loaders/91c92d3c217d524123cd466ca83c4f16.lua', -- Fish It
    [7381705] = 'https://api.luarmor.net/files/v3/loaders/6bc668603e3c93919387e564af72fd88.lua', -- Fisch
    [8818124] = 'https://api.luarmor.net/files/v3/loaders/49a49c2667090f88ed7589c2c00c9d31.lua', -- Violance District
    [460048752] = 'https://api.luarmor.net/files/v4/loaders/162545b55841f58c896e6de5dbdd3ba5.lua', -- Garden Horizon
    [1066523035] = 'https://api.luarmor.net/files/v4/loaders/698cf9d8e549b30186ae959ea9bd8ea6.lua' -- Titan Fishing
}

if communityCreators[creatorId] then 
    print("game supported! Loading script...")
    loadstring(game:HttpGet(communityCreators[creatorId]))()
else
    warn("Unsupported game.")
end
