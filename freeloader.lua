--[[ 
__   __ _____  _______   _ 
\ \ / // __  \|___  / | | |
 \ V / `' / /'   / /| | | |
 /   \   / /    / / | | | |
/ /^\ \./ /___./ /__| |_| |
\/   \/\_____/\_____/\___/
]]

-- local executor = "Unknown"

-- pcall(function()
--     if identifyexecutor then
--         executor = identifyexecutor()
--     elseif getexecutorname then
--         executor = getexecutorname()
--     end
-- end)

-- executor = string.lower(tostring(executor))

-- local blocked = {
--     "xeno",
--     "solara"
-- }

-- for _,v in ipairs(blocked) do
--     if string.find(executor, v) then
--         game.Players.LocalPlayer:Kick("Executor not supported. Please use a high UNC executor.")
--         return
--     end
-- end

-- local requiredFunctions = {
--     "getgc",
--     "hookfunction",
--     "getgenv"
-- }

-- for _,func in ipairs(requiredFunctions) do
--     if not getfenv()[func] then
--         game.Players.LocalPlayer:Kick("Your executor does not support required UNC level.")
--         return
--     end
-- end

repeat task.wait() until game.Players.LocalPlayer and game.Players.LocalPlayer.Character
if not game:IsLoaded() then
    game.Loaded:Wait()
end
print("Supported game!")
local creatorId = game.CreatorId
local communityCreators = {
    [7381705] = 'https://raw.githubusercontent.com/x2zu/loader/refs/heads/main/UI/FischFreeNemesis.lua', -- Fisch
    [35102746] = 'https://raw.githubusercontent.com/x2zu/loader/refs/heads/main/UI/obfuscated_script-1770551344769.lua', -- Fish It
    [1066523035] = 'https://raw.githubusercontent.com/x2zu/loader/refs/heads/main/UI/TitanFishing.lua' -- Titan Fishing
}

if communityCreators[creatorId] then 
    print("game supported! Loading script...")
    loadstring(game:HttpGet(communityCreators[creatorId]))()
else
    warn("Unsupported game.")
end

