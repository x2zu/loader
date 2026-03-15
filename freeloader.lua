repeat task.wait() until game.Players.LocalPlayer and game.Players.LocalPlayer.Character
if not game:IsLoaded() then
    game.Loaded:Wait()
end
print("Supported game!")

-- ── VALIDASI KEY DULU SEBELUM LOAD GAME SCRIPT ──────────────
local function validateKey(key)
    local success, response = pcall(function()
        local req = syn and syn.request
            or http_request
            or request

        local res = req({
            Url    = "https://nemesis-api-production.up.railway.app/api/universal-key/validate",
            Method = "POST",
            Headers = { ["Content-Type"] = "application/json" },
            Body   = game:GetService("HttpService"):JSONEncode({ key = key })
        })

        if res.StatusCode == 200 then
            local data = game:GetService("HttpService"):JSONDecode(res.Body)
            return data.success
        end
        return false
    end)
    return success and response
end

-- Cek script_key dari user
local sk = getgenv().script_key or script_key or ""

-- Kalau tidak ada script_key, load NemesisUI untuk input key
if sk == "" then
    -- Load saved key dari file
    pcall(function()
        if isfile and isfile("Nemesis_ValidKey.txt") then
            sk = readfile("Nemesis_ValidKey.txt")
        end
    end)
end

-- Validasi key
local keyValid = false
if sk ~= "" then
    print("[Nemesis] Validating key...")
    keyValid = validateKey(sk)
    if keyValid then
        print("[Nemesis] Key valid! Loading game script...")
        getgenv().script_key = sk
        -- Simpan key
        pcall(function()
            if writefile then writefile("Nemesis_ValidKey.txt", sk) end
        end)
    else
        print("[Nemesis] Key invalid, opening key GUI...")
        sk = ""
        pcall(function()
            if isfile and isfile("Nemesis_ValidKey.txt") then
                delfile("Nemesis_ValidKey.txt")
            end
        end)
    end
end

-- Kalau key tidak valid / kosong → tampilkan GUI input key
if not keyValid then
    local NemesisUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/x2zu/OPEN-SOURCE-UI-ROBLOX/refs/heads/main/ui-main/ui-main/main.lua"))()
    local keyResolved = false

    NemesisUI:KeySystem({
        Title        = "Nemesis",
        Icon         = "117121414363374",
        GetKeyLinks  = {
            { Name = "Website",     Url = "https://www.nemesishub.xyz/" },
            { Name = "Direct Link", Url = "https://www.nemesishub.xyz/" },
        },
        Placeholder = "Paste your key here...",
        Buttons = {
            { Name = "Exit",    Style = "secondary", Callback = function() end },
            { Name = "Discord", Style = "discord",   Callback = function() pcall(function() setclipboard("https://discord.gg/nemesis") end) end },
            { Name = "Get Key", Style = "secondary", Callback = function() end },
            {
                Name  = "Submit",
                Style = "primary",
                Callback = function(key)
                    if validateKey(key) then
                        pcall(function()
                            if writefile then writefile("Nemesis_ValidKey.txt", key) end
                        end)
                        getgenv().script_key = key
                        keyResolved = true
                        return true
                    end
                    return false
                end
            },
        },
    })

    -- Tunggu sampai key resolved
    repeat task.wait(0.1) until keyResolved
end

-- ── KEY VALID: load game script ──────────────────────────────
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
