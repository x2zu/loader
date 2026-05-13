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
    [8818124] = 'https://api.luarmor.net/files/v3/loaders/49a49c2667090f88ed7589c2c00c9d31.lua', -- Violance District
    [12836673]    = 'https://api.luarmor.net/files/v4/loaders/efb0cd190f8a22cd3a625d8bb72c0449.lua', -- Blade Ball
    [1002185259]    = 'https://api.luarmor.net/files/v4/loaders/91763d409370ae9688fc1f0b6dd886fb.lua', -- Sailor Piece
    [534034976]    = 'https://api.luarmor.net/files/v4/loaders/17a756a631c557aaad68d4b5be1e6889.lua', -- Anime Apocalypse
    [548854077]    = 'https://api.luarmor.net/files/v4/loaders/20c4dfc8ed6ce78ba598fcf64f8a2f90.lua', -- Bees
    [959433345]    = 'https://api.luarmor.net/files/v4/loaders/15cf8c434f2125a409df0816b17762a8.lua', -- gatau lupa
    [56920323]    = 'https://api.luarmor.net/files/v4/loaders/fa795b44121acf9b08666e1bb91ae99b.lua', -- Shells
    [559846885]    = 'https://api.luarmor.net/files/v4/loaders/819ff3bd693ad97203f77bcc35ab4688.lua', -- Iron Soul Dungeon
    [509055872]    = 'https://api.luarmor.net/files/v4/loaders/8a009fe90c61cdda3614a6a7b21e01fe.lua', -- Wizard Alchemy
}

if communityCreators[creatorId] then 
    print("game supported! Loading script...")
    loadstring(game:HttpGet(communityCreators[creatorId]))()
else
    warn("Unsupported game.")
end

