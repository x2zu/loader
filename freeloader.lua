
--[[
__   __ _____  _______   _ 
\ \ / // __  \|___  / | | |
 \ V / `' / /'   / /| | | |
 /   \   / /    / / | | | |
/ /^\ \./ /___./ /__| |_| |
\/   \/\_____/\_____/\___/
]]

repeat task.wait() until game.Players.LocalPlayer and game.Players.LocalPlayer.Character
if not game:IsLoaded() then
    game.Loaded:Wait()
end
print("Supported game!")
local creatorId = game.CreatorId
local communityCreators = {
    [7381705] = 'https://raw.githubusercontent.com/x2zu/loader/refs/heads/main/UI/FischFreeNemesis.lua', -- Fisch
    [35102746] = 'https://raw.githubusercontent.com/x2zu/loader/refs/heads/main/UI/obfuscated_script-1770551344769.lua', -- Fish It
    [8818124] = 'https://raw.githubusercontent.com/x2zu/loader/refs/heads/main/UI/nemesisnewfree.lua', -- Violance District
    [34898222] = 'https://raw.githubusercontent.com/x2zu/loader/refs/heads/main/UI/ABYSSFREE-obfuscated.lua', -- Abyss
}

if communityCreators[creatorId] then 
    print("game supported! Loading script...")
    loadstring(game:HttpGet(communityCreators[creatorId]))()
else
    warn("Unsupported game.")
end



