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
        [12836673]   = "https://api.luarmor.net/files/v4/loaders/8054403591652dbba82017c92d2e6e63.lua", 
        [35102746]   = "https://raw.githubusercontent.com/x2zu/loader/main/UI/obfuscated_script-1770551344769.lua", -- Fish It
        [1002185259]    = 'https://api.luarmor.net/files/v4/loaders/3ffb6ffd4d3a34de745876cf07db0cd1.lua', -- Sailor Piece
}

if communityCreators[creatorId] then 
    print("game supported! Loading script...")
    loadstring(game:HttpGet(communityCreators[creatorId]))()
else
    warn("Unsupported game.")
end
