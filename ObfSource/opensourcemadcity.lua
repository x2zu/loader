---===================================================================================================---
---                                INITIALISATION DES SERVICES ROBLOX                               ---
---===================================================================================================---
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local HttpService = game:GetService('HttpService')
local TeleportService = game:GetService("TeleportService")


---===================================================================================================---
---                                INITIALISATION DU JOUEUR ET DU PERSONNAGE                        ---
---===================================================================================================---
local LocalPlayer = Players.LocalPlayer

local Character = nil
local HumanoidRootPart = nil
local Humanoid = nil

-- Fonction pour initialiser/réinitialiser les références du personnage après chaque spawn
local function setupCharacterReferences(newCharacter)
    Character = newCharacter or LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
    Humanoid = Character:WaitForChild("Humanoid")
    -- Si vous avez du noclip ou d'autres propriétés du personnage à réinitialiser, faites-le ici
    -- Par exemple, si le noclip était activé, vous pourriez le réactiver pour le nouveau personnage
    -- if isNoclipActive then ToggleNoclip(true) end -- Nécessite une variable isNoclipActive
end

-- Connecter la fonction à l'événement CharacterAdded pour gérer le respawn
LocalPlayer.CharacterAdded:Connect(setupCharacterReferences)

-- Appeler la fonction une première fois pour le personnage initial (au démarrage du script)
setupCharacterReferences(LocalPlayer.Character)

local Event = ReplicatedStorage.Event
local RemoteEvent = ReplicatedStorage.RemoteEvent

-- Fonction utilitaire pour nettoyer une chaîne de montant d'argent (ex: "$12345" -> 12345)
local function cleanCashString(cashString)
    if type(cashString) == "string" then
        -- Wrap the gsub chain in parentheses to only get the first return value (the modified string)
        return tonumber((cashString:gsub("%$", ""):gsub("%s", ""))) or 0
    else
        warn("cleanCashString: L'entrée n'était pas une chaîne de caractères. Type reçu : " .. type(cashString))
        return 0 -- Retourne 0 si l'entrée n'est pas une chaîne valide
    end
end


-- Montant d'argent initial du joueur au démarrage du script
local StartCashAmount = cleanCashString(LocalPlayer.PlayerGui.MainGUI.StatsHUD.CashHUD.Cash.Amount.Text)

-- Démarrage du timer au démarrage du script
local startTimer = os.time()
---===================================================================================================---
---                                INITIALISATION DES VARIABLES GETGENV                               ---
---===================================================================================================---
-- Ces variables sont généralement définies par un exploit ou un injecteur pour contrôler le script.
-- Elles ont une valeur par défaut (par exemple, 'true' pour activer) si elles ne sont pas définies.

local serverhoptype = getgenv().serverHopType or "MostEmptyServer" -- Type de saut de serveur (le moins rempli ou aléatoire)

local robbigheist = getgenv().robBigHeist or true         -- Active/désactive les gros braquages
local robminirobberies = getgenv().robMiniRobberies or true -- Active/désactive les mini-braquages

local bank = getgenv().Bank or true       -- Active/désactive le braquage de la Banque
local casino = getgenv().Casino or true     -- Active/désactive le braquage du Casino
local club = getgenv().Club or true       -- Active/désactive le braquage du Club
local jewel = getgenv().Jewel or true       -- Active/désactive le braquage de la Bijouterie
local mall = getgenv().Mall or true       -- Active/désactive le braquage du Centre Commercial
local pyramid = getgenv().Pyramid or true   -- Active/désactive le braquage de la Pyramide
local metro = getgenv().Metro or true     -- Active/désactive le braquage du Métro (train)


---===================================================================================================---
---                                       CONSTANTES GLOBALES                                       ---
---===================================================================================================---
local QUICK_TELEPORT_DISTANCE = 750
local TELEPORT_SPEED = 8
local TELEPORT_OFFSET_Y = 1.25
local WAIT_AFTER_EVENT = 0.075
local WAIT_AFTER_ROBING = 0.15

-- Noms des lieux de braquage majeurs (utilisé pour la gestion du statut).
local HEIST_LOCATIONS = {
    "Bank", "Casino", "Club", "Jewel", "Mall", "Pyramid"
}

-- Noms des leviers pour le Casino.
local LeversCasino = {
    "Lever1", "Lever2", "Lever3", "Lever4"
}

-- Objets spécifiques à voler pour chaque braquage majeur.
local ColecteblesRobs = {
    ["Casino"] = {"Trayy"},
    ["Club"] = {"ClubDiamond", "MoneyStack"},
    ["Pyramid"] = {"TreasurePyramid"},
    ["MiniRobberies"] = {"Cash", "CashRegister", "DiamondBox", "Laptop", "Phone", "Luggage", "ATM", "TV", "Safe"} -- Ajouté pour la fonction robMiniRobberies
}

---===================================================================================================---
---                                      FONCTIONS UTILITAIRES                                      ---
---===================================================================================================---

-- Envoie un message formaté à l'écran du joueur via un RemoteEvent.
local function SendMessage(Message, duration)
    Event:FireServer("Dialogue",{
        {
            ["Text"] = Message,
            ["Delay"] = duration or 1
        }
    })
end

-- Récupère la position d'un objet (BasePart ou Model).
local function GetObjectPosition(obj: Instance): Vector3?
    if obj:IsA("BasePart") then
        return obj.Position
    elseif obj:IsA("Model") then
        return obj:GetPivot().Position
    end
    warn(string.format("GetObjectPosition: L'objet '%s' n'est ni une BasePart ni un Model gérable.", obj.Name))
    return nil
end

-- Calcule la distance entre deux objets.
local function GetMagnitude(objA: Instance, objB: Instance): number
    local posA = GetObjectPosition(objA)
    local posB = GetObjectPosition(objB)
    if posA and posB then
        return (posA - posB).Magnitude
    end
    warn("GetMagnitude: Impossible d'obtenir la position d'un ou des deux objets.")
    return 0
end

-- Récupère le premier RemoteEvent trouvé parmi les descendants d'une instance.
local function getevent(robberyTarget: Instance): RemoteEvent
    for _, child in next, robberyTarget:GetDescendants() do
        if child:IsA("RemoteEvent") then
            return child
        end
    end
    return nil
end

---===================================================================================================---
---                                  GESTION DU STATUT DES BRAQUAGES                                  ---
---===================================================================================================---
-- Chemin vers les BoolValues de statut dans ReplicatedStorage (ex: ReplicatedStorage.HeistStatus.Bank.Locked)
local HEIST_STATUS_PATH = ReplicatedStorage:WaitForChild("HeistStatus")
local HeistsStatus = {} -- Table pour stocker les statuts actuels des braquages

-- Initialise `HeistsStatus` et ses écouteurs d'événements pour mettre à jour les statuts en temps réel.
local function InitializeHeistsStatus()
    for _, locationName in ipairs(HEIST_LOCATIONS) do
        local locationFolder = HEIST_STATUS_PATH:WaitForChild(locationName)
        local lockedValue = locationFolder:WaitForChild("Locked")
        local robbingValue = locationFolder:WaitForChild("Robbing")

        if lockedValue:IsA("BoolValue") and robbingValue:IsA("BoolValue") then
            HeistsStatus[locationName] = {
                ["Locked"] = lockedValue.Value,
                ["Robbing"] = robbingValue.Value
            }
            lockedValue.Changed:Connect(function(newValue)
                HeistsStatus[locationName].Locked = newValue
            end)
            robbingValue.Changed:Connect(function(newValue)
                HeistsStatus[locationName].Robbing = newValue
            end)
        else
            warn(string.format("InitializeHeistsStatus: BoolValue 'Locked' ou 'Robbing' manquant(e) pour %s. Statut par défaut appliqué.", locationName))
            HeistsStatus[locationName] = {
                ["Locked"] = false,
                ["Robbing"] = false
            }
        end
    end
end

InitializeHeistsStatus() -- Appelle l'initialisation au chargement du script

-- Vérifie le statut "Locked" et "Robbing" d'un braquage spécifique.
local function CheckHeistStatus(heistName: string): table
    if HeistsStatus[heistName] then
        return HeistsStatus[heistName]
    else
        warn(string.format("CheckHeistStatus: Le braquage '%s' n'a pas été trouvé dans la table des statuts. Retourne un statut par défaut.", heistName))
        return {Locked = false, Robbing = false}
    end
end

---===================================================================================================---
---                                    FONCTIONS DE TÉLÉPORTATION                                   ---
---===================================================================================================---

-- Détermine si une téléportation instantanée est possible (si l'objet est suffisamment proche).
local function CanQuickTeleport(objectToTeleportTo: Instance): boolean
    return GetMagnitude(HumanoidRootPart, objectToTeleportTo) < QUICK_TELEPORT_DISTANCE
end

-- Effectue une téléportation instantanée du personnage à une position cible.
local function QuickTeleport(objectToTeleportTo: Instance)
    local targetPos = GetObjectPosition(objectToTeleportTo)
    if not targetPos then
        warn(string.format("QuickTeleport: Position cible non valide pour l'objet '%s'.", objectToTeleportTo and objectToTeleportTo.Name or "nil"))
        return
    end
    pcall(function()
        HumanoidRootPart.Position = targetPos + Vector3.new(0, TELEPORT_OFFSET_Y, 0)
    end)
end

-- Effectue une téléportation animée (tween) vers une position cible.
local function TweenTeleport(objectToTeleportTo: Instance)
    local targetPos = GetObjectPosition(objectToTeleportTo)
    if not targetPos then
        warn(string.format("TweenTeleport: Position cible non valide pour l'objet '%s'.", objectToTeleportTo and objectToTeleportTo.Name or "nil"))
        return
    end
    local distance = GetMagnitude(HumanoidRootPart, objectToTeleportTo)
    local duration = math.sqrt(distance) / TELEPORT_SPEED
    local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut)
    pcall(function()
        local tweenAnimation = TweenService:Create(HumanoidRootPart, tweenInfo, {CFrame = CFrame.new(targetPos)})
        tweenAnimation:Play()
        tweenAnimation.Completed:Wait()
    end)
    task.wait(0.5)
end

-- Choisit et exécute le type de téléportation (rapide ou animée) en fonction de la distance.
local function ChooseTeleport(objectToTeleportTo: Instance)
    if not objectToTeleportTo then
        warn("ChooseTeleport: L'objet cible est nil. Impossible de téléporter.")
        return
    end
    if CanQuickTeleport(objectToTeleportTo) then
        QuickTeleport(objectToTeleportTo)
    else
        TweenTeleport(objectToTeleportTo)
    end
end

---===================================================================================================---
---                                FONCTIONS DE GESTION D'ENVIRONNEMENT                               ---
---===================================================================================================---

-- Détruit certains éléments de l'environnement pour améliorer la visibilité ou les performances.
local function DestroySpecificElements()
    for _, v in pairs(Workspace:GetDescendants()) do
        if v.Name:find("Laser") or v.Name:find("DeathLights") or v.Name:find("Table") or v.Name:find("City") then
            pcall(function() v:Destroy() end)
        end
    end
end

---===================================================================================================---
---                                   FONCTIONS DE JOUEUR AVANCÉES                                    ---
---===================================================================================================---

-- Enleve le spawn menu
local function DisableSpawnMenu()
    local LocalPlayer = game:GetService("Players").LocalPlayer
    if LocalPlayer.PlayerScripts.UI:FindFirstChild("UI_Mainmenu") then
        LocalPlayer.PlayerScripts.UI.UI_Mainmenu:Destroy()
    end
    LocalPlayer.PlayerGui.SpawnGUI.Enabled = false
    LocalPlayer.PlayerGui.MainGUI.Enabled = true

    workspace.CurrentCamera.CameraType = "Custom"
    workspace.CurrentCamera.CameraSubject = game.Players.LocalPlayer.Character
end


-- No Clip le joueur
local function NoclipPlayer()
    game:GetService("RunService").Stepped:Connect(function()
        for _, part in pairs(game.Players.LocalPlayer.Character:GetChildren()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end)
end
-- Tue le joueur, souvent utilisé après un braquage pour réinitialiser la position ou l'état.
local function KillPlayer()
    if Humanoid and Humanoid.Parent then
        Humanoid.Health = 0
    end
end

---===================================================================================================---
---                                  FONCTIONS DE RETORUNE A LA BASE                                  ---
---===================================================================================================---

local function DepositMoney()
    QuickTeleport(Workspace.CriminalBase2.TouchEnd)
    task.wait(2)

    KillPlayer()
    
    LocalPlayer.CharacterAdded:Wait()
    setupCharacterReferences(LocalPlayer.Character)
    task.wait(1)
end

---===================================================================================================---
---                                    FONCTIONS DE BRAQUAGES MINI                                    ---
---===================================================================================================---

-- Trouve la cible de mini-braquage la plus proche et disponible.
local function getrobbery(): Instance
    local closestRobbery = nil
    local minDistance = math.huge
    if not HumanoidRootPart then warn("getrobbery: HumanoidRootPart non disponible."); return nil end

    for _, v in next, Workspace.ObjectSelection:GetChildren() do
        if table.find(ColecteblesRobs["MiniRobberies"], v.Name)  and not v:FindFirstChild("Nope")  then
            if getevent(v) then
                local distance = GetMagnitude(HumanoidRootPart, v)
                if distance < minDistance then
                    minDistance = distance
                    closestRobbery = v
                end
            end
        end
    end
    return closestRobbery
end

-- Exécute la routine des mini-braquages : trouve, se téléporte et interagit.
local function robMiniRobberies()
    pcall(function()
        repeat
            local robbery = getrobbery()
            if robbery then
                ChooseTeleport(robbery)
                for i = 1, 5 do
                    local robberyEvent = getevent(robbery)
                    if robberyEvent then
                        robberyEvent:FireServer()
                    else
                        warn(string.format("robMiniRobberies: RemoteEvent non trouvé pour %s.", robbery.Name))
                        break
                    end
                    task.wait(WAIT_AFTER_EVENT)
                end
                task.wait(WAIT_AFTER_ROBING)
            else
                task.wait(1)
            end
        until getrobbery() == nil
    end)
end

---===================================================================================================---
---                                      FONCTIONS DE BRAQUAGE MAJEUR                               ---
---===================================================================================================---

-- **RobBank**: Gère le braquage de la Banque.
local function RobBank()
    local bankStatus = CheckHeistStatus("Bank")
    if bankStatus.Locked then return end

    local vaultDoorTouch = Workspace.Heists.Bank.EssentialParts.VaultDoor.Touch
    local bankInteriorPoint = Workspace.Heists.Bank.Interior:GetChildren()[3]

    if bankStatus.Robbing then
        ChooseTeleport(bankInteriorPoint)
    else
        ChooseTeleport(vaultDoorTouch)
        task.wait(0.5)
        ChooseTeleport(bankInteriorPoint)
    end
    repeat
        task.wait(0.1)
        BankStatus = CheckHeistStatus("Bank") 
        local currentCashAmount = LocalPlayer.PlayerGui.MainGUI.StatsHUD.CashBagHUD.Cash.Amount.Text
    until (currentCashAmount == "$3000") or BankStatus.Locked

    DepositMoney()
end

-- **RobCasino**: Gère le braquage du Casino.
local function RobCasino()
    local CasinoStatus = CheckHeistStatus("Casino")
    if CasinoStatus.Locked then return end

    if not CasinoStatus.Robbing then
        -- Fonction pour trouver et activer l'ordinateur de piratage du casino.
        local function getHackComputer(): Instance
            local hackComp = Workspace.ObjectSelection.HackComputer:FindFirstChild("HackComputer")
            if hackComp and not hackComp:FindFirstChild("NoHack") then return hackComp end
            return nil
        end

        local function ActivateHackComputer()
            pcall(function()
                repeat
                    local hackComputer = getHackComputer()
                    if hackComputer then
                        ChooseTeleport(hackComputer)
                        local hackComputerEvent = getevent(hackComputer)
                        if hackComputerEvent then
                            for i = 1, 5 do hackComputerEvent:FireServer()
                                task.wait(WAIT_AFTER_EVENT)
                             end
                            task.wait(WAIT_AFTER_ROBING)
                        else
                            warn(string.format("ActivateHackComputer: RemoteEvent non trouvé pour l'ordinateur de piratage '%s'.", hackComputer and hackComputer.Name or "nil"))
                            break
                        end
                    else
                        task.wait(1)
                    end
                    CasinoStatus = CheckHeistStatus("Casino")
                    if CasinoStatus.Locked then break end
                until getHackComputer() == nil or CasinoStatus.Locked
            end)
        end
        ActivateHackComputer()

        -- Fonction pour trouver et activer les leviers du casino.
        local function getlever(): Instance
            local closestLever = nil
            local minDistance = math.huge
            if not HumanoidRootPart then warn("getlever: HumanoidRootPart non disponible."); return nil end

            for _, v in next, Workspace.ObjectSelection:GetChildren() do
                if table.find(LeversCasino, v.Name) then
                    local IsOpen = v:FindFirstChild("Open")
                    if IsOpen and IsOpen.Value then continue end
                    if getevent(v) then
                        local distance = GetMagnitude(HumanoidRootPart, v)
                        if distance < minDistance then
                            minDistance = distance
                            closestLever = v
                        end
                    end
                end
            end
            return closestLever
        end

        local function ActiveLeversCasino()
            pcall(function()
                repeat
                    local lever = getlever()
                    if lever then
                        ChooseTeleport(lever)
                        for i = 1, 5 do
                            local leverEvent = getevent(lever)
                            if leverEvent then leverEvent:FireServer() else break end
                            task.wait(WAIT_AFTER_EVENT)
                        end
                        task.wait(WAIT_AFTER_ROBING)
                    else
                        task.wait(1)
                    end
                until getlever() == nil
            end)
        end
        ActiveLeversCasino()
    end

    -- Fonction pour trouver et voler les objets du casino.
    local function getCasinoStealable(): Instance
        local closestStealable = nil
        local minDistance = math.huge
        if not HumanoidRootPart then warn("getCasinoStealable: HumanoidRootPart non disponible."); return nil end

        for _, v in next, Workspace.ObjectSelection:GetChildren() do
            if table.find(ColecteblesRobs["Casino"], v.Name) then
                local IsOpen = v:FindFirstChild("Open")
                if IsOpen and IsOpen.Value then continue end
                if getevent(v) then
                    local distance = GetMagnitude(HumanoidRootPart, v)
                    if distance < minDistance then
                        minDistance = distance
                        closestStealable = v
                    end
                end
            end
        end
        return closestStealable
    end

    local function StealCasinoItems()
        pcall(function()
            repeat
                local item = getCasinoStealable()
                if item then
                    ChooseTeleport(item)
                    for i = 1, 5 do
                        local itemEvent = getevent(item)
                        if itemEvent then itemEvent:FireServer() else break end
                        task.wait(WAIT_AFTER_EVENT)
                    end
                    task.wait(WAIT_AFTER_ROBING)
                else
                    task.wait(1)
                end
                CasinoStatus = CheckHeistStatus("Casino")
                local currentCashAmount = LocalPlayer.PlayerGui.MainGUI.StatsHUD.CashBagHUD.Cash.Amount.Text
            until (currentCashAmount == "$4000") or CasinoStatus.Locked
        end)
    end
    StealCasinoItems()

    DepositMoney()
end

-- **RobClub**: Gère le braquage du Club.
local function RobClub()
    local ClubStatus = CheckHeistStatus("Club")
    if ClubStatus.Locked then return end

    if not ClubStatus.Robbing then
        local TouchStart = Workspace.Club.TouchStart
        ChooseTeleport(TouchStart)
        task.wait(1)
    end

    -- Fonction pour trouver et activer le KeyPad de piratage.
    local function getHackKeyPad(): Instance
        local hackKeyPad = Workspace.ObjectSelection.HackKeyPad:FindFirstChild("HackKeyPad")
        if hackKeyPad and not hackKeyPad:FindFirstChild("NoHack") then return hackKeyPad end
        return nil
    end
    local function ActivateHackKeyPad()
        pcall(function()
            repeat
                local hackKeyPad = getHackKeyPad()
                if hackKeyPad then
                    ChooseTeleport(hackKeyPad)
                    local hackKeyPadEvent = getevent(hackKeyPad)
                    if hackKeyPadEvent then
                        for i = 1, 5 do hackKeyPadEvent:FireServer() end
                        task.wait(WAIT_AFTER_EVENT)
                    else
                        warn(string.format("ActivateHackKeyPad: RemoteEvent non trouvé pour le KeyPad '%s'.", hackKeyPad and hackKeyPad.Name or "nil"))
                        break
                    end
                else
                    task.wait(0.5)
                end
                ClubStatus = CheckHeistStatus("Club")
                if ClubStatus.Locked then break end
            until getHackKeyPad() == nil or ClubStatus.Locked
        end)
    end
    ActivateHackKeyPad()
    task.wait(1)

    -- Fonction pour trouver et voler les objets du club.
    local function getClubStealable(): Instance
        local closestStealable = nil
        local minDistance = math.huge
        if not HumanoidRootPart then warn("getClubStealable: HumanoidRootPart non disponible."); return nil end

        for _, v in next, Workspace.ObjectSelection:GetChildren() do
            if table.find(ColecteblesRobs["Club"], v.Name) then
                local IsOpen = v:FindFirstChild("Open")
                if IsOpen and IsOpen.Value then continue end
                if getevent(v) then
                    local distance = GetMagnitude(HumanoidRootPart, v)
                    if distance < minDistance then
                        minDistance = distance
                        closestStealable = v
                    end
                end
            end
        end
        return closestStealable
    end

    local function StealClubItems()
        pcall(function()
            repeat
                local item = getClubStealable()
                if item then
                    ChooseTeleport(item)
                    for i = 1, 5 do
                        local itemEvent = getevent(item)
                        if itemEvent then itemEvent:FireServer() else break end
                        task.wait(WAIT_AFTER_EVENT)
                    end
                    task.wait(WAIT_AFTER_ROBING)
                else
                    task.wait(1)
                end
                ClubStatus = CheckHeistStatus("Club")
                local currentCashAmount = LocalPlayer.PlayerGui.MainGUI.StatsHUD.CashBagHUD.Cash.Amount.Text
            until (currentCashAmount == "$6000") or ClubStatus.Locked
        end)
    end
    StealClubItems()

    DepositMoney()
end

-- **RobJewel**: Gère le braquage de la Bijouterie (Jewel).
local function RobJewel()
    local JewelStatus = CheckHeistStatus("Jewel")
    if JewelStatus.Locked then return end

    ChooseTeleport(Workspace.Heists.JewelryStore.EssentialParts.JewelryVent.Vent)
    task.wait(1)

    -- Fonction pour trouver et briser les boîtes à bijoux.
    local function getJewelBox(): Instance
        local closestBox = nil
        local minDistance = math.huge
        if not HumanoidRootPart then warn("getJewelBox: HumanoidRootPart non disponible."); return nil end

        for _, v in pairs(Workspace.Heists.JewelryStore.EssentialParts.JewelryBoxes:GetChildren()) do
            if v.Name == "JewelryManager" then continue end
            local HP = v:FindFirstChild("HP")
            if HP and HP.Value == 0 then continue end

            local distance = GetMagnitude(HumanoidRootPart, v)
            if distance < minDistance then
                minDistance = distance
                closestBox = v
            end
        end
        return closestBox
    end

    local function StealJewelBoxes()
        pcall(function()
            repeat
                local jewelBox = getJewelBox()
                if jewelBox then
                    ChooseTeleport(jewelBox)
                    for i = 1, 5 do
                        local success, err = pcall(function()
                            Workspace.Heists.JewelryStore.EssentialParts.JewelryBoxes.JewelryManager.Event:FireServer(jewelBox)
                        end)
                        if not success then
                            warn(string.format("StealJewelBoxes: Erreur lors de l'envoi au JewelryManager pour '%s': %s", jewelBox.Name, err))
                            break
                        end
                        task.wait(WAIT_AFTER_EVENT)
                    end
                    task.wait(WAIT_AFTER_ROBING)
                else
                    task.wait(1)
                end
                JewelStatus = CheckHeistStatus("Jewel")
                local currentCashAmount = LocalPlayer.PlayerGui.MainGUI.StatsHUD.CashBagHUD.Cash.Amount.Text
            until (currentCashAmount == "30") or JewelStatus.Locked
        end)
    end

    StealJewelBoxes()

    DepositMoney()
end

-- **RobMall**: Gère le braquage du Centre Commercial (Mall).
local function RobMall()
    local MallStatus = CheckHeistStatus("Mall")
    if MallStatus.Locked then return end

    ChooseTeleport(Workspace.MaskTriggers.MallTrigger2)
    task.wait(0.25)

    for _, storeFolder in pairs(Workspace.Heists.Mall.Stores:GetChildren()) do
        local innerStoreFolder = storeFolder:FindFirstChild(storeFolder.Name)
        if not innerStoreFolder or not innerStoreFolder:FindFirstChild("Loot") then
            warn(string.format("RobMall: Le dossier interne de la boutique '%s' ou son dossier 'Loot' est introuvable. Sauter cette boutique.", storeFolder.Name))
            continue
        end
        local lootContainer = innerStoreFolder.Loot

        -- Fonction pour trouver le collectible du Mall le plus proche dans la boutique actuelle.
        local function getMallCollectible(): Instance
            local closestCollectible = nil
            local minDistance = math.huge
            if not HumanoidRootPart then warn("getMallCollectible: HumanoidRootPart non disponible."); return nil end

            for _, collectible in pairs(lootContainer:GetChildren()) do
                if collectible:FindFirstChild("JewelBox") or collectible:FindFirstChild("JewerlyManager") or collectible:FindFirstChild("Nope") or collectible:FindFirstChild("NoMallClothing") or collectible:FindFirstChild("NoMallClothingRack") or collectible:FindFirstChild("NoMallLaptop") or collectible:FindFirstChild("NoMallPhone") then
                    continue
                end
                if getevent(collectible) then
                    local distance = GetMagnitude(HumanoidRootPart, collectible)
                    if distance < minDistance then
                        minDistance = distance
                        closestCollectible = collectible
                    end
                end
            end
            return closestCollectible
        end

        local function StealMallItemsInStore()
            pcall(function()
                repeat
                    local mallCollectible = getMallCollectible()
                    if mallCollectible then
                        ChooseTeleport(mallCollectible)
                        for i = 1, 5 do
                            local collectibleEvent = getevent(mallCollectible)
                            if collectibleEvent then
                                local success, err = pcall(function() collectibleEvent:FireServer() end)
                                if not success then warn(string.format("StealMallItemsInStore: Erreur lors de l'envoi au serveur pour '%s': %s", mallCollectible.Name, err)); break end
                            else
                                warn(string.format("StealMallItemsInStore: RemoteEvent non trouvé pour l'objet '%s'.", mallCollectible.Name)); break
                            end
                            task.wait(WAIT_AFTER_EVENT)
                        end
                        task.wait(WAIT_AFTER_ROBING)
                    else
                        task.wait(1); break
                    end
                    MallStatus = CheckHeistStatus("Mall")
                    local currentCashAmount = LocalPlayer.PlayerGui.MainGUI.StatsHUD.CashBagHUD.Cash.Amount.Text
                until (currentCashAmount == "$10000") or MallStatus.Locked
            end)
        end

        StealMallItemsInStore()
        if MallStatus.Locked then break end
    end

    DepositMoney()
end

-- **RobPyramid**: Gère le braquage de la Pyramide.
local function RobPyramid()
    local PyramidStatus = CheckHeistStatus("Pyramid")
    if PyramidStatus.Locked then return end

    local function TeleportPyramid()
        repeat
            QuickTeleport(Workspace.Pyramid.TouchStart)
            task.wait(0.1)
        until PyramidStatus.Robbing
    
        task.wait(3)
    
        local success, result = pcall(function()
            Event:FireServer("SpawnHome", "Basic Home", "OFF", "DEFAULT")
        end)
    
        if success then
            print("L'événement 'SpawnHome' a été déclenché avec succès.")
        else
            warn("Une erreur est survenue lors du déclenchement de l'événement 'SpawnHome' :", result)
        end
    
        task.wait(3)
    
        ChooseTeleport(Workspace.Pyramid.Chest)
    
        task.wait(1)
    end
    TeleportPyramid()
    -- Fonction pour trouver et voler les objets de la pyramide.
    local function getPyramidStealable(): Instance
        local closestStealable = nil
        local minDistance = math.huge
        if not HumanoidRootPart then warn("getPyramidStealable: HumanoidRootPart non disponible."); return nil end

        for _, v in next, Workspace.ObjectSelection:GetChildren() do
            if table.find(ColecteblesRobs["Pyramid"], v.Name) then
                local IsOpen = v:FindFirstChild("Open")
                if IsOpen and IsOpen.Value then continue end
                if getevent(v) then
                    local distance = GetMagnitude(HumanoidRootPart, v)
                    if distance < minDistance then
                        minDistance = distance
                        closestStealable = v
                    end
                end
            end
        end
        return closestStealable
    end

    local function StealPyramidItems()
        pcall(function()
            repeat
                local item = getPyramidStealable()
                if item then
                    ChooseTeleport(item)
                    for i = 1, 5 do
                        local itemEvent = getevent(item)
                        if itemEvent then itemEvent:FireServer() else break end
                        task.wait(WAIT_AFTER_EVENT)
                    end
                    task.wait(WAIT_AFTER_ROBING)
                else
                    task.wait(1)
                end
                PyramidStatus = CheckHeistStatus("Pyramid")
                local currentCashAmount = LocalPlayer.PlayerGui.MainGUI.StatsHUD.CashBagHUD.Cash.Amount.Text
            until (currentCashAmount == "15") or PyramidStatus.Locked
        end)
    end
    StealPyramidItems()

    DepositMoney()
end

-- **RobMetro**: Gère le braquage du Métro (train).
local function RobMetro()
    if Workspace:FindFirstChild("FakeTrain") then return end

    ChooseTeleport(Workspace.Train)

    pcall(function()
        repeat
            RemoteEvent:FireServer("GoldTrain")
            task.wait(0.1)
            local currentCashAmount = LocalPlayer.PlayerGui.MainGUI.StatsHUD.CashBagHUD.Cash.Amount.Text
        until (currentCashAmount == "$11000") or Workspace:FindFirstChild("FakeTrain")
    end)

    DepositMoney()
end

---===================================================================================================---
---                                    FONCTIONS DE SAUT DE SERVEUR                                   ---
---===================================================================================================---

local serverHops = {
    ["MostEmptyServer"] = function()
        local PlaceID = game.PlaceId
        local AllIDs = {}
        local foundAnything = ""
        local actualHour = os.date("!*t").hour
        local last = math.huge -- Initialise 'last' avec une grande valeur pour trouver le serveur le moins rempli.

        local File = pcall(function()
            AllIDs = HttpService:JSONDecode(readfile("NotSameServers.json"))
        end)
        if not File then
            table.insert(AllIDs, actualHour)
            writefile("NotSameServers.json", HttpService:JSONEncode(AllIDs))
        end

        local function TPReturner()
            local Site;
            if foundAnything == "" then
                Site = HttpService:JSONDecode(game:HttpGet('https://games.roblox.com/v1/games/' .. PlaceID .. '/servers/Public?sortOrder=Asc&limit=100'))
            else
                Site = HttpService:JSONDecode(game:HttpGet('https://games.roblox.com/v1/games/' .. PlaceID .. '/servers/Public?sortOrder=Asc&limit=100&cursor=' .. foundAnything))
            end
            local ID = ""
            if Site.nextPageCursor and Site.nextPageCursor ~= "null" and Site.nextPageCursor ~= nil then
                foundAnything = Site.nextPageCursor
            end
            local num = 0;
            local extranum = 0
            for i, v in pairs(Site.data) do
                extranum += 1
                local Possible = true
                ID = tostring(v.id)
                if tonumber(v.maxPlayers) > tonumber(v.playing) then
                    if extranum ~= 1 and tonumber(v.playing) < last or extranum == 1 then
                        last = tonumber(v.playing)
                    elseif extranum ~= 1 then
                        continue
                    end
                    for _, Existing in pairs(AllIDs) do
                        if num ~= 0 then
                            if ID == tostring(Existing) then
                                Possible = false
                            end
                        else
                            if tonumber(actualHour) ~= tonumber(Existing) then
                                local delFile = pcall(function()
                                    delfile("NotSameServers.json")
                                    AllIDs = {}
                                    table.insert(AllIDs, actualHour)
                                end)
                            end
                        end
                        num = num + 1
                    end
                    if Possible == true then
                        table.insert(AllIDs, ID)
                        task.wait()
                        pcall(function()
                            writefile("NotSameServers.json", HttpService:JSONEncode(AllIDs))
                            task.wait()
                            TeleportService:TeleportToPlaceInstance(PlaceID, ID, LocalPlayer)
                        end)
                        task.wait(4)
                    end
                end
            end
        end
        local function Teleport()
            while task.wait() do
                pcall(function()
                    TPReturner()
                    if foundAnything ~= "" then
                        TPReturner()
                    end
                end)
            end
        end
        Teleport()
    end,
    ["RandomServer"] = function()
        local a, b = pcall(function()
            local servers = {}
            local req = request({
                Url = "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Desc&limit=100&excludeFullGames=true"
            })
            local body = HttpService:JSONDecode(req.Body)
            if body and body.data then
                for i, v in next, body.data do
                    if type(v) == "table" and tonumber(v.playing) and tonumber(v.maxPlayers) and v.playing < v.maxPlayers and v.id ~= game.JobId then
                        table.insert(servers, 1, v.id)
                    end
                end
            end
            if #servers > 0 then
                TeleportService:TeleportToPlaceInstance(game.PlaceId, servers[math.random(1, #servers)], LocalPlayer)
            else
                if #Players:GetChildren() <= 1 then
                    LocalPlayer:Kick("\nRejoining...")
                    task.wait()
                    TeleportService:Teleport(game.PlaceId, LocalPlayer)
                else
                    TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
                end
            end
        end)
        if not a then
            -- shop()
        end
        task.spawn(function()
            while task.wait(5) do
                -- shop()
            end
        end)
    end
}

---===================================================================================================---
---                                    DETECTION DE KICK DU SERVER                                   ---
---===================================================================================================---

if not hookmetamethod then
    return warn('Exploit Incompatible', 'Votre exploit ne supporte pas cette commande (hookmetamethod manquant)')
end
local oldhmmi -- Variable pour stocker l'ancienne fonction __index hookée.
local oldhmmnc -- Variable pour stocker l'ancienne fonction __namecall hookée.
local oldKickFunction -- Variable pour stocker l'ancienne fonction Kick hookée (si hookfunction est disponible).

-- Tente de hooker directement la fonction Kick si hookfunction est disponible.
-- Cela remplace la fonction Kick de LocalPlayer par une fonction vide.
if hookfunction then
	oldKickFunction = hookfunction(LocalPlayer.Kick, function()
        print("Clien tried to kick")
        serverHops[serverhoptype]()
     end)
end

-- Hooke le metamethod __index du 'game' object.
-- Le metamethod __index est appelé lorsque l'on tente d'accéder à une propriété non existante.
oldhmmi = hookmetamethod(game, "__index", function(self, method)
    if self == LocalPlayer and method:lower() == "kick" then
        return error("Expected ':' not '.' calling member function Kick", 2)
    end
    return oldhmmi(self, method)
end)

-- Hooke le metamethod __namecall du 'game' object.
-- Le metamethod __namecall est appelé lorsque l'on invoque une méthode sur un objet (ex: LocalPlayer:Kick()).
oldhmmnc = hookmetamethod(game, "__namecall", function(self, ...)
    if self == LocalPlayer and getnamecallmethod():lower() == "kick" then
        return
    end
    return oldhmmnc(self, ...)
end)


---===================================================================================================---
---                                        SYSTÈME D'AUTO-BRAQUAGE                                    ---
---===================================================================================================---

-- Fonction principale pour exécuter les gros braquages en séquence.
local function RobBigHeists()
    SendMessage( "<Color=Red>Auto Rob<Color=/> Big Heist" , 1)
    task.wait(1)

    -- Liste de tous les braquages majeurs avec leurs propriétés.
    -- L'ordre dans cette table détermine l'ordre d'exécution.
    local AllHeistsData = {
        { name = "Bank", func = RobBank, color = "Green", enabledFlag = bank },
        { name = "Casino", func = RobCasino, color = "Purple", enabledFlag = casino },
        { name = "Club", func = RobClub, color = "Purple", enabledFlag = club },
        { name = "Jewel", func = RobJewel, color = "Cyan", enabledFlag = jewel },
        { name = "Mall", func = RobMall, color = "Purple", enabledFlag = mall },
        { name = "Pyramid", func = RobPyramid, color = "Yellow", enabledFlag = pyramid },
        { name = "Metro", func = RobMetro, color = "Orange", enabledFlag = metro }
    }

    for _, heistInfo in ipairs(AllHeistsData) do
        local isEnabled = heistInfo.enabledFlag
        local heistName = heistInfo.name
        local RobFunction = heistInfo.func
        local HeistColor = heistInfo.color

        if isEnabled and type(RobFunction) == "function" then
            local status = CheckHeistStatus(heistName)
            if not status.Locked or heistName == "Metro" then
                SendMessage("Start Robbing <Color="..HeistColor..">".. heistName .."<Color=/>" , 1)
                task.wait(1)
                RobFunction()
                SendMessage("End Robbing <Color="..HeistColor..">".. heistName .."<Color=/>" , 1)
                task.wait(8)
            else
                SendMessage("<Color=Yellow>".. heistName .. " is Locked<Color=/>", 1)
                task.wait(1)
            end
        elseif not isEnabled then
            task.wait(0.5)
        else
            warn("Function for '" .. heistName .. "' is not defined. Skipping.")
            task.wait(0.5)
        end
    end
end

-- Fonction pour gérer les mini-braquages.
local function RobMiniRobberies()
    SendMessage( "<Color=Red>Auto Rob<Color=/> Mini Heist" , 1)
    task.wait(1)
    robMiniRobberies()
end

-- Fonction principale qui orchestre les braquages.
local function AutoRob()
    if robbigheist then RobBigHeists() end
    task.wait(1)

    if robminirobberies then RobMiniRobberies() end
    task.wait(1)

    -- Calcule et affiche le gain d'argent net.
    local currentCashAmount = cleanCashString(LocalPlayer.PlayerGui.MainGUI.StatsHUD.CashHUD.Cash.Amount.Text)
    local cashMadded = (currentCashAmount - StartCashAmount)


    local endTimer = os.time()
    local timeSpendSeconds = (endTimer - startTimer)

    local timeString = ""
    if timeSpendSeconds < 60 then
        timeString = string.format("%.1f secondes", timeSpendSeconds) -- Affiche en secondes si moins d'une minute
    else
        local timeSpendMinutes = timeSpendSeconds / 60
        timeString = string.format("%.1f minutes", timeSpendMinutes) -- Affiche en minutes
    end

    SendMessage("The script madded: $<Color=Green>".. cashMadded .. "<Color=/> cash in " .. timeString, 1)

    task.wait(2)
    serverHops[serverhoptype]() -- Décommenter si la logique de saut de serveur est définie.
end

---===================================================================================================---
---                                       EXÉCUTION DU SCRIPT                                       ---
---===================================================================================================---

print([[ 
█████╗  ██╗   ██╗████████╗ ██████╗         
██╔══██╗██║   ██║╚══██╔══╝██╔═══██╗        
███████║██║   ██║   ██║   ██║   ██║        
██╔══██║██║   ██║   ██║   ██║   ██║        
██║  ██║╚██████╔╝   ██║   ╚██████╔╝        
╚═╝  ╚═╝ ╚═════╝    ╚═╝    ╚═════╝         
██████╗  ██████╗ ██████╗ 
██╔══██╗██╔═══██╗██╔══██╗
██████╔╝██║   ██║██████╔╝
██╔══██╗██║   ██║██╔══██╗
██║  ██║╚██████╔╝██████╔╝
╚═╝  ╚═╝ ╚═════╝ ╚═════╝ 
███████╗██╗  ██╗███████╗ ██████╗██╗   ██╗████████╗███████╗██████╗ 
██╔════╝╚██╗██╔╝██╔════╝██╔════╝██║   ██║╚══██╔══╝██╔════╝██╔══██╗
█████╗   ╚███╔╝ █████╗  ██║     ██║   ██║   ██║   █████╗  ██║  ██║
██╔══╝   ██╔██╗ ██╔══╝  ██║     ██║   ██║   ██║   ██╔══╝  ██║  ██║
███████╗██╔╝ ██╗███████╗╚██████╗╚██████╔╝   ██║   ███████╗██████╔╝
╚══════╝╚═╝  ╚═╝╚══════╝ ╚═════╝ ╚═════╝    ╚═╝   ╚══════╝╚═════╝                                                                         
]])

SendMessage("<Color=Yellow>Auto Robbing Script Loaded!<Color=Green> Player: " .. LocalPlayer.Name, 2)
task.wait(2)
DisableSpawnMenu()
DestroySpecificElements()
NoclipPlayer()

AutoRob()
---------------------------------------------------------------------------------------------Fin--------------------------------------
-- Exécute les fonctions principales au démarrage du script.
-- DestroySpecificElements() -- Nettoie l'environnement (décommenter si nécessaire).
-- NoclipPlayer()

-- Décommentez la fonction principale pour démarrer le processus d'auto-braquage.
-- AutoRob()
