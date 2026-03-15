repeat task.wait() until game.Players.LocalPlayer and game.Players.LocalPlayer.Character
if not game:IsLoaded() then
    game.Loaded:Wait()
end
print("Supported game!")

-- ── LOAD NEMESISUI DULU ──────────────────────────────────────
local NemesisUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/x2zu/OPEN-SOURCE-UI-ROBLOX/refs/heads/main/ui-main/ui-main/main.lua"))()
getgenv().NemesisUI = NemesisUI  -- share ke semua game script

-- ── FUNGSI VALIDASI KEY ──────────────────────────────────────
local function validateKey(key)
    local ok, result = pcall(function()
        local req = syn and syn.request or http_request or request
        local res = req({
            Url    = "https://nemesis-api-production.up.railway.app/api/universal-key/validate",
            Method = "POST",
            Headers = { ["Content-Type"] = "application/json" },
            Body   = game:GetService("HttpService"):JSONEncode({ key = key })
        })
        if res.StatusCode == 200 then
            return game:GetService("HttpService"):JSONDecode(res.Body).success
        end
        return false
    end)
    return ok and result
end

-- ── CEK KEY ──────────────────────────────────────────────────
local sk = getgenv().script_key or script_key or ""

-- Coba load saved key dari file jika tidak ada script_key
if sk == "" then
    pcall(function()
        if isfile and isfile("Nemesis_ValidKey.txt") then
            sk = readfile("Nemesis_ValidKey.txt")
            print("[Nemesis] Found saved key, validating...")
        end
    end)
end

-- Validasi key
local keyValid = false
if sk ~= "" then
    keyValid = validateKey(sk)
    if keyValid then
        print("[Nemesis] Key valid! Welcome back.")
        pcall(function()
            if writefile then writefile("Nemesis_ValidKey.txt", sk) end
        end)
    else
        print("[Nemesis] Key invalid, clearing saved key...")
        sk = ""
        pcall(function()
            if isfile and isfile("Nemesis_ValidKey.txt") then
                delfile("Nemesis_ValidKey.txt")
            end
        end)
    end
end

-- ── TAMPIL GUI KEY JIKA BELUM VALID ──────────────────────────
if not keyValid then
    -- Pakai buildKeySystem standalone dari NemesisUI
    local keyDone = false
    NemesisUI:Window({
        Title = "Nemesis",
        KeySystem = {
            Title        = "Nemesis",
            Icon         = "117121414363374",
            AutoSaveLoad = false,  -- kita handle sendiri di sini
            GetKeyLinks  = {
                { Name = "Website",     Url = "https://www.nemesishub.xyz/" },
                { Name = "Direct Link", Url = "https://www.nemesishub.xyz/" },
            },
            Placeholder = "Paste your key here...",
            Default     = "",
            Buttons     = {
                {
                    Name  = "Exit",
                    Style = "secondary",
                    Callback = function(key) end,
                },
                {
                    Name  = "Discord",
                    Style = "discord",
                    Callback = function(key)
                        pcall(function() setclipboard("https://discord.gg/nemesis") end)
                    end,
                },
                {
                    Name  = "Get Key",
                    Style = "secondary",
                    Callback = function(key) end,
                },
                {
                    Name  = "Submit",
                    Style = "primary",
                    Callback = function(key)
                        if validateKey(key) then
                            pcall(function()
                                if writefile then
                                    writefile("Nemesis_ValidKey.txt", key)
                                    print("[Nemesis] Key saved!")
                                end
                            end)
                            getgenv().script_key = key
                            keyDone = true
                            return true   -- ✅ key valid, tutup GUI
                        end
                        return false      -- ❌ key invalid
                    end,
                },
            },
        },
    })
    -- Tunggu sampai key selesai divalidasi
    repeat task.wait(0.1) until keyDone
end

-- ── KEY VALID: LOAD GAME SCRIPT ───────────────────────────────
local creatorId = game.CreatorId
local communityCreators = {
    [7381705]    = 'https://raw.githubusercontent.com/x2zu/loader/refs/heads/main/UI/FischFreeNemesis.lua',
    [35102746]   = 'https://raw.githubusercontent.com/x2zu/loader/refs/heads/main/UI/obfuscated_script-1770551344769.lua',
    [1066523035] = 'https://raw.githubusercontent.com/x2zu/loader/refs/heads/main/UI/TitanFishing.lua'
}

if communityCreators[creatorId] then
    print("game supported! Loading script...")
    loadstring(game:HttpGet(communityCreators[creatorId]))()
else
    warn("Unsupported game.")
end
