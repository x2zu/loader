
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
    [7381705] = 'https://raw.githubusercontent.com/xwwwwwwwwwwwwwwwwwwwqd/loader/main/GamesData/Fisch.lua',
    [35102746] = 'https://raw.githubusercontent.com/xwwwwwwwwwwwwwwwwwwwqd/loader/refs/heads/main/GamesData/FishItFree.lua', -- Fish It
}

if communityCreators[creatorId] then 
    print("game supported! Loading script...")
    loadstring(game:HttpGet(communityCreators[creatorId]))()
else
    warn("Unsupported game.")
end

