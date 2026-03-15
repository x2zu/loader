repeat task.wait() until game.Players.LocalPlayer and game.Players.LocalPlayer.Character
if not game:IsLoaded() then
    game.Loaded:Wait()
end
print("Supported game!")

local creatorId = game.CreatorId
local communityCreators = {
    [7381705]    = 'https://raw.githubusercontent.com/x2zu/loader/refs/heads/main/UI/FischFreeNemesis.lua',
    [35102746]   = 'https://raw.githubusercontent.com/x2zu/loader/refs/heads/main/UI/obfuscated_script-1770551344769.lua',
    [1066523035] = 'https://raw.githubusercontent.com/x2zu/loader/refs/heads/main/UI/TitanFishing.lua'
}

if communityCreators[creatorId] then
    print("game supported! Loading script...")

    if script_key and script_key ~= "" then
        getgenv().script_key = script_key
    end

    loadstring(game:HttpGet(communityCreators[creatorId]))()
else
    warn("Unsupported game.")
end
