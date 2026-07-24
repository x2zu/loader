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
local creatorId = game.CreatorId
local communityCreators = {
    [794813948]    = 'https://api.luarmor.net/files/v4/loaders/79d12854ac6076bc620b95a4b5052f97.lua',
}

if communityCreators[creatorId] then 
    print("game supported! Loading script...")
    loadstring(game:HttpGet(communityCreators[creatorId]))()
else
    warn("Unsupported game.")
end
