-- ==========================================
-- INTERFACE D'INJECTION INITIALE (FK)
-- ==========================================
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Nettoyage de l'ancienne interface si elle existe
if playerGui:FindFirstChild("CustomInjectGui") then
    playerGui.CustomInjectGui:Destroy()
end

-- Création du ScreenGui d'injection
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "CustomInjectGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

-- Fenêtre principale (Fond rouge foncé, déplaçable)
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 320, 0, 360)
mainFrame.Position = UDim2.new(0.5, -160, 0.5, -180)
mainFrame.BackgroundColor3 = Color3.fromRGB(80, 10, 10)
mainFrame.BorderSizePixel = 0
mainFrame.ZIndex = 1
mainFrame.Parent = screenGui

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 12)
mainCorner.Parent = mainFrame

-- Système pour rendre la fenêtre déplaçable (Draggable)
local dragging, dragInput, dragStart, startPos

mainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = mainFrame.Position
        
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

game:GetService("RunService").RenderStepped:Connect(function()
    if dragging and dragInput then
        local delta = dragInput.Position - dragStart
        mainFrame.Position = UDim2.new(
            startPos.X.Scale, 
            startPos.X.Offset + delta.X, 
            startPos.Y.Scale, 
            startPos.Y.Offset + delta.Y
        )
    end
end)

-- Texte "FK" sans carré autour, avec effet de contour lumineux sur les lettres
local fkLabel = Instance.new("TextLabel")
fkLabel.Size = UDim2.new(0, 200, 0, 120)
fkLabel.Position = UDim2.new(0.5, -100, 0, 45)
fkLabel.BackgroundTransparency = 1
fkLabel.Text = "FK"
fkLabel.TextColor3 = Color3.fromRGB(255, 30, 30) -- Rouge vif éclatant
fkLabel.TextSize = 80
fkLabel.Font = Enum.Font.FredokaOne
fkLabel.ZIndex = 2
fkLabel.Parent = mainFrame

local fkStroke = Instance.new("UIStroke")
fkStroke.Color = Color3.fromRGB(255, 120, 120) -- Contour lumineux autour des lettres
fkStroke.Thickness = 3
fkStroke.Parent = fkLabel

-- Bouton "Injecter"
local injectButton = Instance.new("TextButton")
injectButton.Size = UDim2.new(0.85, 0, 0, 48)
injectButton.Position = UDim2.new(0.075, 0, 0.75, 0)
injectButton.BackgroundColor3 = Color3.fromRGB(100, 20, 20)
injectButton.TextColor3 = Color3.fromRGB(255, 255, 255)
injectButton.Text = "Injecter"
injectButton.TextSize = 16
injectButton.Font = Enum.Font.GothamMedium
injectButton.BorderSizePixel = 0
injectButton.ZIndex = 2
injectButton.Parent = mainFrame

local btnCorner = Instance.new("UICorner")
btnCorner.CornerRadius = UDim.new(0, 8)
btnCorner.Parent = injectButton

-- Événement d'injection : c'est au clic que le vrai script du cheat s'exécute
injectButton.MouseButton1Click:Connect(function()
    injectButton.Active = false
    
    -- Étape 1 : Téléchargement
    injectButton.BackgroundColor3 = Color3.fromRGB(60, 15, 15)
    injectButton.TextColor3 = Color3.fromRGB(200, 200, 200)
    injectButton.Text = "⏳ Downloading payload..."
    
    task.wait(2.5)
    
    -- Étape 2 : Succès
    injectButton.BackgroundColor3 = Color3.fromRGB(20, 60, 35)
    injectButton.TextColor3 = Color3.fromRGB(80, 230, 120)
    injectButton.Text = "✓ Injected successfully"
    
    task.wait(1.5)
    
    -- Suppression de l'interface d'injection
    screenGui:Destroy()

    -- =========================================================================
    -- LANCEMENT DU SCRIPT PRINCIPAL APRÈS INJECTION[cite: 1]
    -- =========================================================================
    task.spawn(function()
        local Players = game:GetService("Players")
        local ReplicatedStorage = game:GetService("ReplicatedStorage")
        local HttpService = game:GetService("HttpService")
        local RunService = game:GetService("RunService")
        local UserInputService = game:GetService("UserInputService")
        local Lighting = game:GetService("Lighting")
        local LocalPlayer = Players.LocalPlayer
        local Camera = workspace.CurrentCamera

        local targetParent = LocalPlayer:WaitForChild("PlayerGui")
        if gethui then
            targetParent = gethui()
        elseif pcall(function() return game:GetService("CoreGui") end) then
            targetParent = game:GetService("CoreGui")
        end

        -- ==========================================
        -- 2. SYSTÈMES DE LICENCES & CLÉS (TEMPS RÉEL)
        -- ==========================================
        local LICENSE_FILE = "FK_License_Data.json"
        local DB_FILE = "FK_KeysDatabase.json"

        local function loadKeysDB()
            if readfile and isfile and isfile(DB_FILE) then
                local success, data = pcall(function()
                    return HttpService:JSONDecode(readfile(DB_FILE))
                end)
                if success and type(data) == "table" then return data end
            end
            return {}
        end

        local function loadLicenseData()
            if readfile and isfile and isfile(LICENSE_FILE) then
                local success, data = pcall(function()
                    return HttpService:JSONDecode(readfile(LICENSE_FILE))
                end)
                if success and data then return data end
            end
            return { active = false, expiry = 0, type = "Aucune", keyStr = "" }
        end

        local function saveLicenseData(data)
            if writefile then
                pcall(function()
                    writefile(LICENSE_FILE, HttpService:JSONEncode(data))
                end)
            end
        end

        local currentLicense = loadLicenseData()

        local function isLicenseValid()
            if not currentLicense.active then return false end
            if currentLicense.expiry == -1 then return true end
            
            if os.time() < currentLicense.expiry then
                return true
            else
                currentLicense.active = false
                saveLicenseData(currentLicense)
                return false
            end
        end

        -- ==========================================
        -- 3. AC BYPASS & UNLOCK ALL (RIVALS)
        -- ==========================================
        local _stbl; _stbl = hookfunction(getrenv().setmetatable, newcclosure(function(tbl, mt)
            if mt and typeof(mt) == "table" and rawget(mt, "__mode") == "kv" then
                local tr = debug.traceback()
                if tr:find("MiscellaneousController") then
                    return _stbl({1,2,3}, {})
                end
            end
            return _stbl(tbl, mt)
        end))

        coroutine.wrap(function()
            pcall(function()
                local function _proc(o)
                    pcall(function()
                        if o:IsA("LocalScript") or o:IsA("ModuleScript") then
                            local _s, nm = pcall(function() return o.Name:lower() end)
                            if not _s or not nm then return end
                            local _tags = {"anticheat","ac","detection","ban","kick","security","moderation"}
                            for _i = 1, #_tags do
                                if nm:find(_tags[_i]) then
                                    pcall(function() o.Disabled = true end)
                                    break
                                end
                            end
                        end
                    end)
                end
                pcall(function()
                    local _desc = game:GetDescendants()
                    for _i = 1, #_desc do _proc(_desc[_i]) end
                end)
                pcall(function() game.DescendantAdded:Connect(_proc) end)
            end)
            pcall(function()
                local _nc = game:GetService("NetworkClient")
                if not _nc then return end
                _nc.ChildAdded:Connect(function(ch)
                    pcall(function()
                        local _ok, _n = pcall(function() return ch.Name:lower() end)
                        if _ok and _n then
                            if _n:find("anticheat") or _n:find("detection") then
                                pcall(function() ch:Destroy() end)
                            end
                        end
                    end)
                end)
            end)
        end)()

        local _fakeEv
        pcall(function()
            _fakeEv = Instance.new("RemoteEvent")
            _fakeEv.Name = "ClientAlert"
            _fakeEv.Parent = LocalPlayer
        end)

        pcall(function()
            local _rf = game:GetService("ReplicatedFirst")
            local _tgt = _rf:WaitForChild("LocalScript3", 10)
            local _ct = 0
            local _gc = getgc(false)
            for _i = 1, #_gc do
                local _fn = _gc[_i]
                if type(_fn) ~= "function" then continue end
                local _ok1, _env = pcall(getfenv, _fn)
                if not _ok1 or type(_env) ~= "table" then continue end
                local _ok2, _scr = pcall(function() return rawget(_env, "script") end)
                if not _ok2 or not _scr or typeof(_scr) ~= "Instance" then continue end
                local _ok3, _ss = pcall(tostring, _scr)
                if not _ok3 then continue end
                if not (_scr == _tgt or (type(_ss) == "string" and _ss:find("LoadingScreen"))) then continue end
                local _ok4, _consts = pcall(debug.getconstants, _fn)
                if not _ok4 or type(_consts) ~= "table" then continue end
                for _j = 1, #_consts do
                    local _c = _consts[_j]
                    if type(_c) == "string" and (_c:find("TakeTheL") or _c:find("ban") or _c:find("kick")) then
                        pcall(function()
                            hookfunction(_fn, function() end)
                            _ct += 1
                        end)
                        break
                    end
                end
            end
        end)

        task.wait(4)

        aimbotEnabled = false
        espEnabled = false
        fpsEnabled = true
        stretchEnabled = false    
        unlockAllEnabled = false

        local _rs     = game:GetService("ReplicatedStorage")
        local _mods   = _rs:WaitForChild("Modules", 10)

        local _enumLib = require(_mods:WaitForChild("EnumLibrary", 10))
        if _enumLib then pcall(function() _enumLib:WaitForEnumBuilder() end) end

        local _cosLib  = require(_mods:WaitForChild("CosmeticLibrary", 10))
        local _itmLib  = require(_mods:WaitForChild("ItemLibrary", 10))
        local _ctrl    = LocalPlayer.PlayerScripts:WaitForChild("Controllers", 10)
        local _datCtrl = require(_ctrl:WaitForChild("PlayerDataController", 10))

        local _eq, _favs = {}, {}
        local _buildingWep = nil
        local _lastWep = nil
        local _cosTypes = {"Skin","Wrap","Charm","Dance","Emote"}

        local function _isCosType(cosObj)
            if not cosObj then return false end
            for _, t in ipairs(_cosTypes) do
                if cosObj.Type == t then return true end
            end
            return false
        end

        local function _mkCosmetic(nm, ctype, opts)
            local _base = _cosLib.Cosmetics[nm]
            if not _base then return nil end
            local _d = {}
            for k, v in pairs(_base) do _d[k] = v end
            _d.Name = nm
            _d.Type = _d.Type or ctype
            _d.Seed = _d.Seed or math.random(1, 1000000)
            if _enumLib then
                local _s, _eid = pcall(_enumLib.ToEnum, _enumLib, nm)
                if _s and _eid then
                    _d.Enum = _eid
                    _d.ObjectID = _d.ObjectID or _eid
                end
            end
            if opts then
                if opts.inverted ~= nil then _d.Inverted = opts.inverted end
                if opts.favoritesOnly ~= nil then _d.OnlyUseFavorites = opts.favoritesOnly end
            end
            return _d
        end

        local _cfgFile = "rivals_unlocker_config.json"
        local _saveLock = false

        local function _stripForSave()
            local _out = {}
            for wn, cos in pairs(_eq) do
                _out[wn] = {}
                for ct, cd in pairs(cos) do
                    if cd and cd.Name then
                        _out[wn][ct] = {
                            Name = cd.Name,
                            Inverted = cd.Inverted,
                            OnlyUseFavorites = cd.OnlyUseFavorites
                        }
                    end
                end
            end
            return { equipped = _out, favorites = _favs }
        end

        local function _loadCfg()
            if not isfile or not readfile then return end
            local _ok1, _ex = pcall(isfile, _cfgFile)
            if not _ok1 or not _ex then return end
            local _ok2, _raw = pcall(readfile, _cfgFile)
            if not _ok2 or not _raw or _raw == "" then return end
            local _ok3, _dec = pcall(HttpService.JSONDecode, HttpService, _raw)
            if not _ok3 or not _dec then return end
            if _dec.favorites then _favs = _dec.favorites end
            if _dec.equipped then
                _eq = {}
                for wn, cos in pairs(_dec.equipped) do
                    _eq[wn] = {}
                    for ct, sd in pairs(cos) do
                        if sd and sd.Name then
                            if _cosLib.Cosmetics[sd.Name] then
                                local _cloned = _mkCosmetic(sd.Name, ct, {
                                    inverted = sd.Inverted,
                                    favoritesOnly = sd.OnlyUseFavorites
                                })
                                if _cloned then _eq[wn][ct] = _cloned end
                            end
                        end
                    end
                    if not next(_eq[wn]) then _eq[wn] = nil end
                end
            end
        end

        local function _saveCfg()
            if not writefile or _saveLock then return end
            _saveLock = true
            task.spawn(function()
                task.wait(1)
                local _payload = _stripForSave()
                local _ok, _enc = pcall(HttpService.JSONEncode, HttpService, _payload)
                if _ok then pcall(writefile, _cfgFile, _enc) end
                _saveLock = false
            end)
        end

        _loadCfg()

        _cosLib.OwnsCosmeticNormally = function(self, inv, nm, wep)
            if not unlockAllEnabled then return false end
            local c = _cosLib.Cosmetics[nm]
            if c and _isCosType(c) then return true end
            return false
        end
        _cosLib.OwnsCosmeticUniversally = function(self, inv, nm, wep)
            if not unlockAllEnabled then return false end
            local c = _cosLib.Cosmetics[nm]
            if c and _isCosType(c) then return true end
            return false
        end
        _cosLib.OwnsCosmeticForWeapon = function(self, inv, nm, wep)
            if not unlockAllEnabled then return false end
            local c = _cosLib.Cosmetics[nm]
            if c and _isCosType(c) then return true end
            return false
        end

        local _origOwns = _cosLib.OwnsCosmetic
        _cosLib.OwnsCosmetic = function(self, inv, nm, wep)
            if not unlockAllEnabled then return _origOwns(self, inv, nm, wep) end
            if nm:find("MISSING_") or nm == "Bubble Gun" then return _origOwns(self, inv, nm, wep) end
            local c = _cosLib.Cosmetics[nm]
            if c and _isCosType(c) then return true end
            return _origOwns(self, inv, nm, wep)
        end

        local _origGet = _datCtrl.Get
        _datCtrl.Get = function(self, key)
            local _val = _origGet(self, key)
            if not unlockAllEnabled then return _val end
            if key == "CosmeticInventory" then
                local _prx = {}
                if _val then
                    for k, v in pairs(_val) do
                        local c = _cosLib.Cosmetics[k]
                        if c and _isCosType(c) then _prx[k] = v end
                    end
                end
                return setmetatable(_prx, {
                    __index = function(t, k)
                        local c = _cosLib.Cosmetics[k]
                        if c and _isCosType(c) then return true end
                        return nil
                    end
                })
            end
            if key == "FavoritedCosmetics" then
                local _res = _val and table.clone(_val) or {}
                for wep, fv in pairs(_favs) do
                    _res[wep] = _res[wep] or {}
                    for nm, isFav in pairs(fv) do
                        local c = _cosLib.Cosmetics[nm]
                        if c and _isCosType(c) then _res[wep][nm] = isFav end
                    end
                end
                return _res
            end
            return _val
        end

        local _origGetWep = _datCtrl.GetWeaponData
        _datCtrl.GetWeaponData = function(self, wn)
            local _d = _origGetWep(self, wn)
            if not _d or not unlockAllEnabled then return _d end
            local _m = {}
            for k, v in pairs(_d) do _m[k] = v end
            _m.Name = wn
            if _eq[wn] then
                for ct, cd in pairs(_eq[wn]) do _m[ct] = cd end
            end
            return _m
        end

        local _fightCtrl
        pcall(function() _fightCtrl = require(_ctrl:WaitForChild("FighterController", 10)) end)

        if hookmetamethod then
            local _remotes   = _rs:FindFirstChild("Remotes")
            local _dataRem   = _remotes and _remotes:FindFirstChild("Data")
            local _equipRem  = _dataRem and _dataRem:FindFirstChild("EquipCosmetic")
            local _favRem    = _dataRem and _dataRem:FindFirstChild("FavoriteCosmetic")
            local _repRem    = _remotes and _remotes:FindFirstChild("Replication")
            local _fightRem  = _repRem and _repRem:FindFirstChild("Fighter")
            local _useItmRem = _fightRem and _fightRem:FindFirstChild("UseItem")

            if _equipRem then
                local _onc
                _onc = hookmetamethod(game, "__namecall", function(self, ...)
                    if getnamecallmethod() ~= "FireServer" then return _onc(self, ...) end
                    local _a = {...}

                    if _useItmRem and self == _useItmRem then
                        local _oid = _a[1]
                        if _fightCtrl then
                            pcall(function()
                                local _f = _fightCtrl:GetFighter(LocalPlayer)
                                if _f and _f.Items then
                                    for _, itm in pairs(_f.Items) do
                                        if itm:Get("ObjectID") == _oid then
                                            _lastWep = itm.Name
                                            break
                                        end
                                    end
                                end
                            end)
                        end
                    end

                    if self == _equipRem then
                        local _wn   = _a[1]
                        local _ct   = _a[2]
                        local _cn   = _a[3]
                        local _opts = _a[4] or {}
                        if _cn and _cn ~= "None" and _cn ~= "" then
                            local _inv = _datCtrl:Get("CosmeticInventory")
                            if _inv and rawget(_inv, _cn) then return _onc(self, ...) end
                        end
                        _eq[_wn] = _eq[_wn] or {}
                        if not _cn or _cn == "None" or _cn == "" then
                            _eq[_wn][_ct] = nil
                            if not next(_eq[_wn]) then _eq[_wn] = nil end
                        else
                            local _cloned = _mkCosmetic(_cn, _ct, {
                                inverted = _opts.IsInverted,
                                favoritesOnly = _opts.OnlyUseFavorites
                            })
                            if _cloned then _eq[_wn][_ct] = _cloned end
                        end
                        task.defer(function()
                            pcall(function() _datCtrl.CurrentData:Replicate("WeaponInventory") end)
                        end)
                        _saveCfg()
                        return
                    end

                    if self == _favRem then
                        local _cos = _cosLib.Cosmetics[_a[2]]
                        if _cos then
                            _favs[_a[1]] = _favs[_a[1]] or {}
                            _favs[_a[1]][_a[2]] = _a[3] or nil
                            task.spawn(function()
                                pcall(function() _datCtrl.CurrentData:Replicate("FavoritedCosmetics") end)
                            end)
                            _saveCfg()
                        end
                        return
                    end

                    return _onc(self, ...)
                end)
            end
        end

        local _cliItem
        pcall(function()
            _cliItem = require(LocalPlayer.PlayerScripts.Modules.ClientReplicatedClasses.ClientFighter.ClientItem)
        end)

        if _cliItem and _cliItem._CreateViewModel then
            local _origCVM = _cliItem._CreateViewModel
            _cliItem._CreateViewModel = function(self, vmRef)
                local _wn  = self.Name
                local _wp  = self.ClientFighter and self.ClientFighter.Player
                _buildingWep = (_wp == LocalPlayer) and _wn or nil
                if unlockAllEnabled and _wp == LocalPlayer and _eq[_wn] then
                    local _dk = self:ToEnum("Data")
                    if vmRef[_dk] then
                        if _eq[_wn].Skin then
                            vmRef[_dk][self:ToEnum("Skin")] = _eq[_wn].Skin
                            vmRef[_dk][self:ToEnum("Name")] = _eq[_wn].Skin.Name
                        end
                        if _eq[_wn].Charm then vmRef[_dk][self:ToEnum("Charm")] = _eq[_wn].Charm end
                        if _eq[_wn].Wrap  then vmRef[_dk][self:ToEnum("Wrap")]  = _eq[_wn].Wrap  end
                    elseif vmRef.Data then
                        if _eq[_wn].Skin  then vmRef.Data.Skin  = _eq[_wn].Skin; vmRef.Data.Name = _eq[_wn].Skin.Name end
                        if _eq[_wn].Charm then vmRef.Data.Charm = _eq[_wn].Charm end
                        if _eq[_wn].Wrap  then vmRef.Data.Wrap  = _eq[_wn].Wrap  end
                    end
                end
                local _r = _origCVM(self, vmRef)
                _buildingWep = nil
                return _r
            end
        end

        local _vmMod = LocalPlayer.PlayerScripts.Modules.ClientReplicatedClasses.ClientFighter.ClientItem:FindFirstChild("ClientViewModel")
        if _vmMod then
            local _CVM = require(_vmMod)
            local _origNew = _CVM.new
            _CVM.new = function(repData, cliItm)
                local _wp  = cliItm.ClientFighter and cliItm.ClientFighter.Player
                local _wn  = _buildingWep or cliItm.Name
                if unlockAllEnabled and _wp == LocalPlayer and _eq[_wn] then
                    local _RC  = require(_rs.Modules.ReplicatedClass)
                    local _dk  = _RC:ToEnum("Data")
                    repData[_dk] = repData[_dk] or {}
                    local _cos = _eq[_wn]
                    if _cos.Skin  then repData[_dk][_RC:ToEnum("Skin")]  = _cos.Skin  end
                    if _cos.Charm then repData[_dk][_RC:ToEnum("Charm")] = _cos.Charm end
                    if _cos.Wrap  then repData[_dk][_RC:ToEnum("Wrap")]  = _cos.Wrap  end
                end
                return _origNew(repData, cliItm)
            end
        end

        -- ==========================================
        -- 4. INTERFACE 1 : PAGE CLÉ (LOGIN)
        -- ==========================================
        if targetParent:FindFirstChild("FK_KeyLogin_Gui") then
            targetParent.FK_KeyLogin_Gui:Destroy()
        end

        local keyLoginGui = Instance.new("ScreenGui")
        keyLoginGui.Name = "FK_KeyLogin_Gui"
        keyLoginGui.ResetOnSpawn = false
        keyLoginGui.Enabled = not isLicenseValid()
        keyLoginGui.Parent = targetParent

        local loginFrame = Instance.new("Frame", keyLoginGui)
        loginFrame.Size = UDim2.new(0, 320, 0, 245)
        loginFrame.Position = UDim2.new(0.5, -160, 0.5, -122)
        loginFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 25)
        loginFrame.BorderSizePixel = 0
        loginFrame.Active = true
        loginFrame.Draggable = true
        Instance.new("UICorner", loginFrame).CornerRadius = UDim.new(0, 10)
        local loginStroke = Instance.new("UIStroke", loginFrame)
        loginStroke.Color = Color3.fromRGB(100, 100, 200)
        loginStroke.Thickness = 1.5

        local loginTitle = Instance.new("TextLabel", loginFrame)
        loginTitle.Size = UDim2.new(1, 0, 0, 35)
        loginTitle.BackgroundTransparency = 1
        loginTitle.Font = Enum.Font.GothamBold
        loginTitle.Text = "FK PANEL - Connexion"
        loginTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
        loginTitle.TextSize = 14

        local loginStatus = Instance.new("TextLabel", loginFrame)
        loginStatus.Size = UDim2.new(1, -20, 0, 25)
        loginStatus.Position = UDim2.new(0, 10, 0.18, 0)
        loginStatus.BackgroundTransparency = 1
        loginStatus.Font = Enum.Font.GothamMedium
        loginStatus.TextColor3 = Color3.fromRGB(200, 200, 200)
        loginStatus.TextSize = 11
        loginStatus.Text = "Entrez votre clé valide (F3 pour l'Admin / RightShift pour le Panel)"

        local keyInput = Instance.new("TextBox", loginFrame)
        keyInput.Size = UDim2.new(0.9, 0, 0, 35)
        keyInput.Position = UDim2.new(0.05, 0, 0.35, 0)
        keyInput.BackgroundColor3 = Color3.fromRGB(28, 28, 38)
        keyInput.Font = Enum.Font.GothamMedium
        keyInput.PlaceholderText = "Entrez votre clé..."
        keyInput.PlaceholderColor3 = Color3.fromRGB(120, 120, 140)
        keyInput.Text = ""
        keyInput.TextColor3 = Color3.fromRGB(255, 255, 255)
        keyInput.TextSize = 12
        Instance.new("UICorner", keyInput).CornerRadius = UDim.new(0, 6)

        local submitBtn = Instance.new("TextButton", loginFrame)
        submitBtn.Size = UDim2.new(0.9, 0, 0, 35)
        submitBtn.Position = UDim2.new(0.05, 0, 0.55, 0)
        submitBtn.BackgroundColor3 = Color3.fromRGB(60, 120, 70)
        submitBtn.Font = Enum.Font.GothamBold
        submitBtn.Text = "Valider la Clé"
        submitBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        submitBtn.TextSize = 12
        Instance.new("UICorner", submitBtn).CornerRadius = UDim.new(0, 6)

        local buyBtn = Instance.new("TextButton", loginFrame)
        buyBtn.Size = UDim2.new(0.9, 0, 0, 35)
        buyBtn.Position = UDim2.new(0.05, 0, 0.75, 0)
        buyBtn.BackgroundColor3 = Color3.fromRGB(88, 101, 242)
        buyBtn.Font = Enum.Font.GothamBold
        buyBtn.Text = "Acheter une clé (Discord)"
        buyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        buyBtn.TextSize = 10
        Instance.new("UICorner", buyBtn).CornerRadius = UDim.new(0, 6)

        buyBtn.MouseButton1Click:Connect(function()
            local discordLink = "https://discord.gg/KE7pfAVuU"
            if setclipboard then
                setclipboard(discordLink)
                buyBtn.Text = "Lien copié !"
                task.wait(2.5)
                buyBtn.Text = "Acheter une clé (Discord)"
            end
        end)

        -- ==========================================
        -- 5. FK PANEL UI & MODULES PRINCIPAUX
        -- ==========================================
        if targetParent:FindFirstChild("CustomCheatPanel") then
            targetParent.CustomCheatPanel:Destroy()
        end

        local cheatGui = Instance.new("ScreenGui")
        cheatGui.Name = "CustomCheatPanel"
        cheatGui.ResetOnSpawn = false
        cheatGui.Parent = targetParent

        local cheatMain = Instance.new("Frame", cheatGui)
        cheatMain.Name = "MainFrame"
        cheatMain.Size = UDim2.new(0, 240, 0, 460)
        cheatMain.Position = UDim2.new(0.1, 0, 0.2, 0)
        cheatMain.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
        cheatMain.BorderSizePixel = 0
        cheatMain.Active = true
        cheatMain.Draggable = true
        cheatMain.Visible = isLicenseValid()
        Instance.new("UICorner", cheatMain).CornerRadius = UDim.new(0, 8)
        local cheatStroke = Instance.new("UIStroke", cheatMain)
        cheatStroke.Color = Color3.fromRGB(60, 60, 75)
        cheatStroke.Thickness = 2

        local cheatTitle = Instance.new("TextLabel", cheatMain)
        cheatTitle.Size = UDim2.new(1, 0, 0, 35)
        cheatTitle.BackgroundTransparency = 1
        cheatTitle.Font = Enum.Font.GothamBold
        cheatTitle.Text = "FK PANEL [RightShift]"
        cheatTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
        cheatTitle.TextSize = 13

        local cheatScroll = Instance.new("ScrollingFrame", cheatMain)
        cheatScroll.Size = UDim2.new(1, -10, 1, -45)
        cheatScroll.Position = UDim2.new(0, 5, 0, 38)
        cheatScroll.BackgroundTransparency = 1
        cheatScroll.CanvasSize = UDim2.new(0, 0, 0, 500)
        cheatScroll.ScrollBarThickness = 4

        local cheatList = Instance.new("UIListLayout", cheatScroll)
        cheatList.SortOrder = Enum.SortOrder.LayoutOrder
        cheatList.Padding = UDim.new(0, 8)

        local timeBtn = Instance.new("TextButton", cheatScroll)
        timeBtn.Size = UDim2.new(1, -10, 0, 35)
        timeBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
        timeBtn.Font = Enum.Font.GothamBold
        timeBtn.Text = "Temps : Chargement..."
        timeBtn.TextColor3 = Color3.fromRGB(200, 200, 255)
        timeBtn.TextSize = 10
        timeBtn.BorderSizePixel = 0
        Instance.new("UICorner", timeBtn).CornerRadius = UDim.new(0, 6)

        task.spawn(function()
            while task.wait(1) do
                if currentLicense.active then
                    if not isLicenseValid() then
                        cheatMain.Visible = false
                        keyLoginGui.Enabled = true
                        loginStatus.Text = "Votre clé a expiré !"
                        loginStatus.TextColor3 = Color3.fromRGB(255, 80, 80)
                    else
                        if currentLicense.expiry == -1 then
                            timeBtn.Text = "Temps : À vie (Illimité)"
                        else
                            local timeLeft = currentLicense.expiry - os.time()
                            if timeLeft > 0 then
                                local days = math.floor(timeLeft / 86400)
                                local hours = math.floor((timeLeft % 86400) / 3600)
                                local mins = math.floor((timeLeft % 3600) / 60)
                                local secs = timeLeft % 60
                                if days > 0 then
                                    timeBtn.Text = string.format("Expire : %dj %dh %dm", days, hours, mins)
                                else
                                    timeBtn.Text = string.format("Expire : %02dh %02dm %02ds", hours, mins, secs)
                                end
                            else
                                timeBtn.Text = "Temps : Expiré"
                            end
                        end
                    end
                end
            end
        end)

        local resetBtn = Instance.new("TextButton", cheatScroll)
        resetBtn.Size = UDim2.new(1, -10, 0, 35)
        resetBtn.BackgroundColor3 = Color3.fromRGB(70, 35, 35)
        resetBtn.Font = Enum.Font.GothamBold
        resetBtn.Text = "Changer de clé (Reset)"
        resetBtn.TextColor3 = Color3.fromRGB(255, 120, 120)
        resetBtn.TextSize = 11
        resetBtn.BorderSizePixel = 0
        Instance.new("UICorner", resetBtn).CornerRadius = UDim.new(0, 6)

        resetBtn.MouseButton1Click:Connect(function()
            if isfile and isfile(LICENSE_FILE) then pcall(function() delfile(LICENSE_FILE) end) end
            currentLicense = { active = false, expiry = 0, type = "Aucune" }
            cheatMain.Visible = false
            keyLoginGui.Enabled = true
            keyInput.Text = ""
        end)

        local function createRedCheatBtn(defaultText)
            local btn = Instance.new("TextButton", cheatScroll)
            btn.Size = UDim2.new(1, -10, 0, 35)
            btn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
            btn.Font = Enum.Font.GothamBold
            btn.Text = defaultText
            btn.TextColor3 = Color3.fromRGB(255, 100, 100)
            btn.TextSize, btn.BorderSizePixel = 11, 0
            Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
            return btn
        end

        local aimBtn = createRedCheatBtn("Aimbot: OFF")
        local espBtn = createRedCheatBtn("ESP Skeleton RGB: OFF")
        local fpsToggleBtn = createRedCheatBtn("Compteur FPS: ON")

        local skinBtn = Instance.new("TextButton", cheatScroll)
        skinBtn.Size = UDim2.new(1, -10, 0, 35)
        skinBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
        skinBtn.Font = Enum.Font.GothamBold
        skinBtn.Text = "Unlock All Skins: OFF"
        skinBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
        skinBtn.TextSize, skinBtn.BorderSizePixel = 11, 0
        Instance.new("UICorner", skinBtn).CornerRadius = UDim.new(0, 6)

        local stretchBtn = Instance.new("TextButton", cheatScroll)
        stretchBtn.Size = UDim2.new(1, -10, 0, 35)
        stretchBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
        stretchBtn.Font = Enum.Font.GothamBold
        stretchBtn.Text = "Résolution Étirée: OFF"
        stretchBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
        stretchBtn.TextSize, stretchBtn.BorderSizePixel = 11, 0
        Instance.new("UICorner", stretchBtn).CornerRadius = UDim.new(0, 6)

        local function toggleState(btn, stateVar, textOn, textOff)
            stateVar = not stateVar
            if stateVar then
                btn.Text = textOn
                btn.TextColor3 = Color3.fromRGB(100, 255, 100)
                btn.BackgroundColor3 = Color3.fromRGB(30, 70, 40)
            else
                btn.Text = textOff
                btn.TextColor3 = Color3.fromRGB(255, 100, 100)
                btn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
            end
            return stateVar
        end

        aimBtn.MouseButton1Click:Connect(function() aimbotEnabled = toggleState(aimBtn, aimbotEnabled, "Aimbot: ON", "Aimbot: OFF") end)
        espBtn.MouseButton1Click:Connect(function() espEnabled = toggleState(espBtn, espEnabled, "ESP Skeleton RGB: ON", "ESP Skeleton RGB: OFF") end)

        fpsToggleBtn.MouseButton1Click:Connect(function() 
            fpsEnabled = toggleState(fpsToggleBtn, fpsEnabled, "Compteur FPS: ON", "Compteur FPS: OFF")
            if FK_FPS_GUI_Instance then FK_FPS_GUI_Instance.Enabled = fpsEnabled end
        end)

        skinBtn.MouseButton1Click:Connect(function()
            if not unlockAllEnabled then
                unlockAllEnabled = true
                skinBtn.Text = "Unlock All Skins: ACTIF (Bloqué)"
                skinBtn.TextColor3 = Color3.fromRGB(100, 255, 100)
                skinBtn.BackgroundColor3 = Color3.fromRGB(30, 70, 40)
            else
                skinBtn.Text = "Unlock All Skins: DÉJÀ ACTIF (Bloqué)"
                task.delay(1, function()
                    if skinBtn and skinBtn.Parent then
                        skinBtn.Text = "Unlock All Skins: ACTIF (Bloqué)"
                    end
                end)
            end
        end)

        stretchBtn.MouseButton1Click:Connect(function()
            stretchEnabled = not stretchEnabled
            if stretchEnabled then
                stretchBtn.Text = "Résolution Étirée: ACTIF"
                stretchBtn.TextColor3 = Color3.fromRGB(100, 255, 100)
                stretchBtn.BackgroundColor3 = Color3.fromRGB(30, 70, 40)
            else
                stretchBtn.Text = "Résolution Étirée: OFF"
                stretchBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
                stretchBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
            end
        end)

        submitBtn.MouseButton1Click:Connect(function()
            local enteredKey = keyInput.Text:gsub("%s+", "")
            local adminDB = loadKeysDB()
            
            if adminDB[enteredKey] then
                local kData = adminDB[enteredKey]
                if kData.expiresAt ~= -1 and os.time() > kData.expiresAt then
                    loginStatus.Text = "Cette clé a expiré !"
                    loginStatus.TextColor3 = Color3.fromRGB(255, 80, 80)
                    return
                end
                currentLicense = { active = true, expiry = kData.expiresAt, type = kData.name or "Key", keyStr = enteredKey }
                saveLicenseData(currentLicense)

                loginStatus.Text = "Succès ! Accès autorisé."
                loginStatus.TextColor3 = Color3.fromRGB(100, 255, 100)
                task.wait(1)
                keyLoginGui.Enabled = false
                cheatMain.Visible = true
            else
                loginStatus.Text = "Clé invalide ou introuvable !"
                loginStatus.TextColor3 = Color3.fromRGB(255, 80, 80)
            end
        end)

        UserInputService.InputBegan:Connect(function(input, processed)
            if input.KeyCode == Enum.KeyCode.RightShift then
                if isLicenseValid() then
                    cheatMain.Visible = not cheatMain.Visible
                end
            end
        end)

        -- ==========================================
        -- 6. AIMBOT SYSTEM
        -- ==========================================
        RunService.RenderStepped:Connect(function()
            if aimbotEnabled and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
                local closestPlayer = nil
                local shortestDistance = math.huge
                local mousePos = UserInputService:GetMouseLocation()

                for _, player in ipairs(Players:GetPlayers()) do
                    if player ~= LocalPlayer and player.Character then
                        local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
                        local head = player.Character:FindFirstChild("Head")
                        if humanoid and humanoid.Health > 0 and head then
                            local vector, onScreen = Camera:WorldToViewportPoint(head.Position)
                            if onScreen then
                                local distance = (Vector2.new(vector.X, vector.Y) - mousePos).Magnitude
                                if distance < shortestDistance then
                                    shortestDistance = distance
                                    closestPlayer = player
                                end
                            end
                        end
                    end
                end

                if closestPlayer and closestPlayer.Character then
                    local head = closestPlayer.Character:FindFirstChild("Head")
                    if head then
                        Camera.CFrame = CFrame.new(Camera.CFrame.Position, head.Position)
                    end
                end
            end
        end)

        -- ==========================================
        -- 7. ESP SYSTEM (SKELETON RGB)
        -- ==========================================
        local espCache = {}
        local bonePairs = {
            {"Head", "UpperTorso"}, {"UpperTorso", "LowerTorso"},
            {"UpperTorso", "LeftUpperArm"}, {"LeftUpperArm", "LeftLowerArm"}, {"LeftLowerArm", "LeftHand"},
            {"UpperTorso", "RightUpperArm"}, {"RightUpperArm", "RightLowerArm"}, {"RightLowerArm", "RightHand"},
            {"LowerTorso", "LeftUpperLeg"}, {"LeftUpperLeg", "LeftLowerLeg"}, {"LeftLowerLeg", "LeftFoot"},
            {"LowerTorso", "RightUpperLeg"}, {"RightUpperLeg", "RightLowerLeg"}, {"RightLowerLeg", "RightFoot"}
        }

        local function createESP(player)
            local drawings = {}
            drawings.Lines = {}
            for i = 1, #bonePairs do
                local line = Drawing.new("Line")
                line.Visible = false
                line.Color = Color3.fromRGB(255, 255, 255)
                line.Thickness = 1.5
                table.insert(drawings.Lines, line)
            end
            drawings.HealthBarBg = Drawing.new("Square")
            drawings.HealthBarBg.Visible = false
            drawings.HealthBarBg.Color = Color3.fromRGB(0, 0, 0)
            drawings.HealthBarBg.Filled = true
            
            drawings.HealthBar = Drawing.new("Square")
            drawings.HealthBar.Visible = false
            drawings.HealthBar.Filled = true
            
            drawings.WeaponText = Drawing.new("Text")
            drawings.WeaponText.Visible = false
            drawings.WeaponText.Color = Color3.fromRGB(150, 200, 255)
            drawings.WeaponText.Size = 11
            drawings.WeaponText.Center = true
            drawings.WeaponText.Outline = true

            espCache[player] = drawings
        end

        local function removeESP(player)
            if espCache[player] then
                for _, line in ipairs(espCache[player].Lines) do pcall(function() line:Remove() end) end
                pcall(function() espCache[player].HealthBarBg:Remove() end)
                pcall(function() espCache[player].HealthBar:Remove() end)
                pcall(function() espCache[player].WeaponText:Remove() end)
                espCache[player] = nil
            end
        end

        for _, p in ipairs(Players:GetPlayers()) do if p ~= LocalPlayer then createESP(p) end end
        Players.PlayerAdded:Connect(createESP)
        Players.PlayerRemoving:Connect(removeESP)

        RunService.RenderStepped:Connect(function()
            local rgbSkeletonColor = Color3.fromHSV((tick() * 0.3) % 1, 1, 1)
            if not espEnabled then
                for _, drawings in pairs(espCache) do
                    for _, line in ipairs(drawings.Lines) do line.Visible = false end
                    drawings.HealthBarBg.Visible = false
                    drawings.HealthBar.Visible = false
                    drawings.WeaponText.Visible = false
                end
                return
            end

            for player, drawings in pairs(espCache) do
                local character = player.Character
                local humanoid = character and character:FindFirstChildOfClass("Humanoid")
                local rootPart = character and character:FindFirstChild("HumanoidRootPart")

                if character and humanoid and rootPart and humanoid.Health > 0 then
                    local vector, onScreen = Camera:WorldToViewportPoint(rootPart.Position)
                    if onScreen then
                        local lineIdx = 1
                        for _, pair in ipairs(bonePairs) do
                            local p1 = character:FindFirstChild(pair[1])
                            local p2 = character:FindFirstChild(pair[2])
                            local lineObj = drawings.Lines[lineIdx]
                            if p1 and p2 and lineObj then
                                local v1, s1 = Camera:WorldToViewportPoint(p1.Position)
                                local v2, s2 = Camera:WorldToViewportPoint(p2.Position)
                                if s1 and s2 then
                                    lineObj.From = Vector2.new(v1.X, v1.Y)
                                    lineObj.To = Vector2.new(v2.X, v2.Y)
                                    lineObj.Color = rgbSkeletonColor
                                    lineObj.Visible = true
                                else
                                    lineObj.Visible = false
                                end
                            elseif lineObj then
                                lineObj.Visible = false
                            end
                            lineIdx = lineIdx + 1
                        end

                        local head = character:FindFirstChild("Head")
                        local headVector = head and Camera:WorldToViewportPoint(head.Position + Vector3.new(0, 0.5, 0)) or vector
                        local legVector = Camera:WorldToViewportPoint(rootPart.Position - Vector3.new(0, 3, 0))
                        local height = math.abs(headVector.Y - legVector.Y)
                        local width = height / 2
                        local pos = Vector2.new(vector.X - width / 2, headVector.Y)

                        local healthPercent = math.clamp(humanoid.Health / humanoid.MaxHealth, 0, 1)
                        local barHeight = height * healthPercent
                        
                        drawings.HealthBarBg.Size = Vector2.new(4, height + 2)
                        drawings.HealthBarBg.Position = Vector2.new(pos.X - 7, pos.Y - 1)
                        drawings.HealthBarBg.Visible = true

                        drawings.HealthBar.Size = Vector2.new(2, barHeight)
                        drawings.HealthBar.Position = Vector2.new(pos.X - 6, pos.Y + (height - barHeight))
                        drawings.HealthBar.Color = Color3.fromRGB(255 - (healthPercent * 255), healthPercent * 255, 0)
                        drawings.HealthBar.Visible = true

                        local weaponName = "Mains"
                        local tool = character:FindFirstChildOfClass("Tool")
                        if tool then weaponName = tool.Name end

                        drawings.WeaponText.Text = "[" .. weaponName .. "]"
                        drawings.WeaponText.Position = Vector2.new(pos.X + width / 2, pos.Y + height + 2)
                        drawings.WeaponText.Visible = true
                    else
                        for _, line in ipairs(drawings.Lines) do line.Visible = false end
                        drawings.HealthBarBg.Visible = false
                        drawings.HealthBar.Visible = false
                        drawings.WeaponText.Visible = false
                    end
                else
                    for _, line in ipairs(drawings.Lines) do line.Visible = false end
                    drawings.HealthBarBg.Visible = false
                    drawings.HealthBar.Visible = false
                    drawings.WeaponText.Visible = false
                end
            end
        end)

        -- ==========================================
        -- 8. STRETCH & FPS COUNTER
        -- ==========================================
        getgenv().Stretch = 0.6
        if not getgenv().StretchedActive then
            getgenv().StretchedActive = true
            RunService.RenderStepped:Connect(function()
                if stretchEnabled then
                    Camera.CFrame = Camera.CFrame * CFrame.new(0, 0, 0, 1, 0, 0, 0, getgenv().Stretch, 0, 0, 0, 1)
                end
            end)
        end

        if targetParent:FindFirstChild("FK_FPS_GUI") then targetParent.FK_FPS_GUI:Destroy() end

        local fpsGui = Instance.new("ScreenGui")
        fpsGui.Name = "FK_FPS_GUI"
        fpsGui.ResetOnSpawn = false
        fpsGui.Enabled = fpsEnabled
        fpsGui.Parent = targetParent
        FK_FPS_GUI_Instance = fpsGui

        local mainBtn = Instance.new("TextButton")
        mainBtn.Size = UDim2.new(0, 160, 0, 35)
        mainBtn.Position = UDim2.new(1, -180, 0, 20)
        mainBtn.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
        mainBtn.BackgroundTransparency = 0.3
        mainBtn.Text = ""
        mainBtn.AutoButtonColor = false
        mainBtn.Active = true
        mainBtn.Parent = fpsGui
        Instance.new("UICorner", mainBtn).CornerRadius = UDim.new(0, 8)
        local mainStroke = Instance.new("UIStroke", mainBtn)
        mainStroke.Color = Color3.fromRGB(200, 200, 200)
        mainStroke.Thickness = 1.5

        local fpsText = Instance.new("TextLabel", mainBtn)
        fpsText.Size = UDim2.new(1, 0, 1, 0)
        fpsText.BackgroundTransparency = 1
        fpsText.Font = Enum.Font.GothamBold
        fpsText.TextColor3 = Color3.fromRGB(255, 255, 255)
        fpsText.TextSize = 14
        fpsText.Text = "FPS: ... | (by FK)"

        local panel = Instance.new("Frame", fpsGui)
        panel.Size = UDim2.new(0, 180, 0, 200)
        panel.Position = UDim2.new(1, -200, 0, 65)
        panel.BackgroundColor3 = Color3.fromRGB(20, 20, 28)
        panel.BackgroundTransparency = 0.1
        panel.Visible = false
        Instance.new("UICorner", panel).CornerRadius = UDim.new(0, 10)
        local panelStroke = Instance.new("UIStroke", panel)
        panelStroke.Color = Color3.fromRGB(100, 100, 255)
        panelStroke.Thickness = 1.5

        local title = Instance.new("TextLabel", panel)
        title.Size = UDim2.new(1, 0, 0, 30)
        title.BackgroundTransparency = 1
        title.Font = Enum.Font.GothamBold
        title.TextColor3 = Color3.fromRGB(255, 255, 255)
        title.TextSize = 12
        title.Text = "Paramètres (by FK)"

        local fakeBtn = Instance.new("TextButton", panel)
        fakeBtn.Size = UDim2.new(0.9, 0, 0, 30)
        fakeBtn.Position = UDim2.new(0.05, 0, 0.18, 0)
        fakeBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
        fakeBtn.Font = Enum.Font.GothamSemibold
        fakeBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
        fakeBtn.TextSize = 11
        fakeBtn.Text = "Faux FPS (500) : OFF"
        Instance.new("UICorner", fakeBtn).CornerRadius = UDim.new(0, 6)

        local colorGrid = Instance.new("Frame", panel)
        colorGrid.Size = UDim2.new(0.9, 0, 0, 80)
        colorGrid.Position = UDim2.new(0.05, 0, 0.50, 0)
        colorGrid.BackgroundTransparency = 1

        local layout = Instance.new("UIGridLayout", colorGrid)
        layout.CellSize = UDim2.new(0, 36, 0, 32)
        layout.CellPadding = UDim2.new(0, 6, 0, 6)

        local colors = {
            Color3.fromRGB(100, 255, 100), Color3.fromRGB(80, 180, 255),
            Color3.fromRGB(200, 100, 255), Color3.fromRGB(255, 80, 80),
            Color3.fromRGB(255, 220, 80), Color3.fromRGB(80, 255, 230),
            Color3.fromRGB(255, 120, 200), Color3.fromRGB(255, 255, 255)
        }

        for _, col in ipairs(colors) do
            local cBtn = Instance.new("TextButton", colorGrid)
            cBtn.Text = ""
            cBtn.BackgroundColor3 = col
            Instance.new("UICorner", cBtn).CornerRadius = UDim.new(0, 6)
            cBtn.MouseButton1Click:Connect(function()
                mainStroke.Color = col
                panelStroke.Color = col
                fpsText.TextColor3 = col
            end)
        end

        local isFakeFPS = false
        fakeBtn.MouseButton1Click:Connect(function()
            isFakeFPS = not isFakeFPS
            if isFakeFPS then
                fakeBtn.Text = "Faux FPS (500) : ON"
                fakeBtn.TextColor3 = Color3.fromRGB(100, 255, 100)
            else
                fakeBtn.Text = "Faux FPS (500) : OFF"
                fakeBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
            end
        end)

        mainBtn.MouseButton1Click:Connect(function() panel.Visible = not panel.Visible end)

        local frames = 0
        local lastTime = os.clock()
        RunService.RenderStepped:Connect(function()
            frames = frames + 1
            local currentTime = os.clock()
            if currentTime - lastTime >= 1 then
                local displayFPS = isFakeFPS and 500 or frames
                fpsText.Text = "FPS: " .. displayFPS .. " | (by FK)"
                frames = 0
                lastTime = currentTime
            end
        end)

        -- ==========================================
        -- 9. INTERFACE ADMIN : GÉNÉRATEUR DE CLÉS (F3)
        -- ==========================================
        local adminGui = Instance.new("ScreenGui", targetParent)
        adminGui.Name = "FK_Admin_Gui"
        adminGui.ResetOnSpawn = false

        local pinFrame = Instance.new("Frame", adminGui)
        pinFrame.Size = UDim2.new(0, 200, 0, 120)
        pinFrame.Position = UDim2.new(0.5, -100, 0.4, -60)
        pinFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 15)
        pinFrame.Visible = false
        Instance.new("UICorner", pinFrame).CornerRadius = UDim.new(0, 8)
        Instance.new("UIStroke", pinFrame).Color = Color3.fromRGB(255, 50, 50)

        local pinInput = Instance.new("TextBox", pinFrame)
        pinInput.Size = UDim2.new(0.9, 0, 0, 30)
        pinInput.Position = UDim2.new(0.05, 0, 0.3, 0)
        pinInput.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
        pinInput.PlaceholderText = "Code PIN Admin..."
        pinInput.Text = ""
        pinInput.TextColor3 = Color3.fromRGB(255, 255, 255)
        Instance.new("UICorner", pinInput).CornerRadius = UDim.new(0, 4)

        local pinBtn = Instance.new("TextButton", pinFrame)
        pinBtn.Size = UDim2.new(0.9, 0, 0, 30)
        pinBtn.Position = UDim2.new(0.05, 0, 0.65, 0)
        pinBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        pinBtn.Text = "Entrer"
        pinBtn.TextColor3 = Color3.fromRGB(255,255,255)
        pinBtn.Font = Enum.Font.GothamBold
        Instance.new("UICorner", pinBtn).CornerRadius = UDim.new(0, 4)

        local adminMain = Instance.new("Frame", adminGui)
        adminMain.Size = UDim2.new(0, 420, 0, 420)
        adminMain.Position = UDim2.new(0.5, -210, 0.5, -210)
        adminMain.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
        adminMain.Active = true
        adminMain.Draggable = true
        adminMain.Visible = false
        Instance.new("UICorner", adminMain).CornerRadius = UDim.new(0, 10)
        Instance.new("UIStroke", adminMain).Color = Color3.fromRGB(255, 80, 80)

        local adminTitle = Instance.new("TextLabel", adminMain)
        adminTitle.Size = UDim2.new(1, 0, 0, 30)
        adminTitle.BackgroundTransparency = 1
        adminTitle.Font = Enum.Font.GothamBold
        adminTitle.Text = "🛠️ FK PANEL - ADMINISTRATION DES CLÉS"
        adminTitle.TextColor3 = Color3.fromRGB(255, 80, 80)
        adminTitle.TextSize = 12

        local nameInput = Instance.new("TextBox", adminMain)
        nameInput.Size = UDim2.new(0.9, 0, 0, 30)
        nameInput.Position = UDim2.new(0.05, 0, 0.08, 0)
        nameInput.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
        nameInput.PlaceholderText = "Nom de la clé (ex: VIP_Kylian)..."
        nameInput.TextColor3 = Color3.fromRGB(255,255,255)
        nameInput.TextSize = 11
        Instance.new("UICorner", nameInput).CornerRadius = UDim.new(0, 4)

        local numInput = Instance.new("TextBox", adminMain)
        numInput.Size = UDim2.new(0.43, 0, 0, 30)
        numInput.Position = UDim2.new(0.05, 0, 0.17, 0)
        numInput.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
        numInput.PlaceholderText = "Quantité (ex: 7, 30...)"
        numInput.Text = "1"
        numInput.TextColor3 = Color3.fromRGB(255,255,255)
        numInput.TextSize = 11
        Instance.new("UICorner", numInput).CornerRadius = UDim.new(0, 4)

        local unitDropdown = Instance.new("TextButton", adminMain)
        unitDropdown.Size = UDim2.new(0.43, 0, 0, 30)
        unitDropdown.Position = UDim2.new(0.52, 0, 0.17, 0)
        unitDropdown.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
        unitDropdown.Text = "Unité : Jours ▾"
        unitDropdown.TextColor3 = Color3.fromRGB(255,255,255)
        unitDropdown.Font = Enum.Font.GothamBold
        unitDropdown.TextSize = 11
        Instance.new("UICorner", unitDropdown).CornerRadius = UDim.new(0, 4)

        local currentUnit = "days"
        unitDropdown.MouseButton1Click:Connect(function()
            if currentUnit == "days" then
                currentUnit = "months"
                unitDropdown.Text = "Unité : Mois ▾"
            elseif currentUnit == "months" then
                currentUnit = "years"
                unitDropdown.Text = "Unité : Années ▾"
            elseif currentUnit == "years" then
                currentUnit = "lifetime"
                unitDropdown.Text = "Unité : À vie ∞"
            else
                currentUnit = "days"
                unitDropdown.Text = "Unité : Jours ▾"
            end
        end)

        local genBtn = Instance.new("TextButton", adminMain)
        genBtn.Size = UDim2.new(0.9, 0, 0, 35)
        genBtn.Position = UDim2.new(0.05, 0, 0.27, 0)
        genBtn.BackgroundColor3 = Color3.fromRGB(80, 100, 255)
        genBtn.Text = "GÉNÉRER LA CLÉ SUR MESURE"
        genBtn.TextColor3 = Color3.fromRGB(255,255,255)
        genBtn.Font = Enum.Font.GothamBold
        genBtn.TextSize = 11
        Instance.new("UICorner", genBtn).CornerRadius = UDim.new(0, 4)

        local keyListScroll = Instance.new("ScrollingFrame", adminMain)
        keyListScroll.Size = UDim2.new(0.9, 0, 0, 230)
        keyListScroll.Position = UDim2.new(0.05, 0, 0.39, 0)
        keyListScroll.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
        keyListScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
        keyListScroll.BorderSizePixel = 0
        keyListScroll.ScrollBarThickness = 4
        local listLayout = Instance.new("UIListLayout", keyListScroll)
        listLayout.Padding = UDim.new(0, 5)
        listLayout.SortOrder = Enum.SortOrder.LayoutOrder
        Instance.new("UICorner", keyListScroll).CornerRadius = UDim.new(0, 4)

        local function refreshKeyList()
            for _, child in ipairs(keyListScroll:GetChildren()) do
                if child:IsA("Frame") then child:Destroy() end
            end
            
            local keysDB = loadKeysDB()
            local ySize = 0
            
            for keyStr, data in pairs(keysDB) do
                local kFrame = Instance.new("Frame", keyListScroll)
                kFrame.Size = UDim2.new(1, -6, 0, 45)
                kFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
                Instance.new("UICorner", kFrame).CornerRadius = UDim.new(0, 4)
                
                local infoTxt = Instance.new("TextLabel", kFrame)
                infoTxt.Size = UDim2.new(0.65, 0, 1, 0)
                infoTxt.Position = UDim2.new(0, 8, 0, 0)
                infoTxt.BackgroundTransparency = 1
                infoTxt.TextXAlignment = Enum.TextXAlignment.Left
                infoTxt.TextColor3 = Color3.fromRGB(200, 200, 200)
                infoTxt.Font = Enum.Font.Gotham
                infoTxt.TextSize = 10
                
                local status = ""
                if data.expiresAt == -1 then
                    status = "Statut : À vie"
                elseif os.time() > data.expiresAt then
                    status = "Statut : 🔴 Expirée"
                else
                    local left = data.expiresAt - os.time()
                    local d = math.floor(left / 86400)
                    local h = math.floor((left % 86400) / 3600)
                    status = string.format("Reste : %dj %dh", d, h)
                end
                
                infoTxt.Text = "Nom: " .. (data.name or "Key") .. "\nClé: " .. keyStr .. "\n[" .. status .. "]"
                
                local copyBtn = Instance.new("TextButton", kFrame)
                copyBtn.Size = UDim2.new(0.15, 0, 0.7, 0)
                copyBtn.Position = UDim2.new(0.67, 0, 0.15, 0)
                copyBtn.BackgroundColor3 = Color3.fromRGB(80, 150, 80)
                copyBtn.Text = "Copier"
                copyBtn.TextColor3 = Color3.fromRGB(255,255,255)
                copyBtn.TextSize = 10
                Instance.new("UICorner", copyBtn).CornerRadius = UDim.new(0, 4)
                
                copyBtn.MouseButton1Click:Connect(function()
                    if setclipboard then setclipboard(keyStr) copyBtn.Text = "Copié!" task.wait(1) copyBtn.Text = "Copier" end
                end)
                
                local delBtn = Instance.new("TextButton", kFrame)
                delBtn.Size = UDim2.new(0.14, 0, 0.7, 0)
                delBtn.Position = UDim2.new(0.84, 0, 0.15, 0)
                delBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
                delBtn.Text = "Suppr"
                delBtn.TextColor3 = Color3.fromRGB(255,255,255)
                delBtn.TextSize = 10
                Instance.new("UICorner", delBtn).CornerRadius = UDim.new(0, 4)
                
                delBtn.MouseButton1Click:Connect(function()
                    local db = loadKeysDB()
                    db[keyStr] = nil
                    if writefile then pcall(function() writefile(DB_FILE, HttpService:JSONEncode(db)) end) end
                    refreshKeyList()
                end)
                
                ySize = ySize + 50
            end
            keyListScroll.CanvasSize = UDim2.new(0, 0, 0, ySize)
        end

        genBtn.MouseButton1Click:Connect(function()
            local name = nameInput.Text
            if name == "" then name = "User_" .. math.random(1000,9999) end
            
            local amount = tonumber(numInput.Text) or 1
            local exp = 0
            
            if currentUnit == "days" then
                exp = os.time() + (amount * 86400)
            elseif currentUnit == "months" then
                exp = os.time() + (amount * 30 * 86400)
            elseif currentUnit == "years" then
                exp = os.time() + (amount * 365 * 86400)
            elseif currentUnit == "lifetime" then
                exp = -1
            end
            
            local newKey = "FK-" .. HttpService:GenerateGUID(false):sub(1,13):upper()
            local db = loadKeysDB()
            db[newKey] = {
                name = name,
                expiresAt = exp
            }
            
            if writefile then pcall(function() writefile(DB_FILE, HttpService:JSONEncode(db)) end) end
            if setclipboard then setclipboard(newKey) end
            
            genBtn.Text = "CLÉ CRÉÉE ET COPIÉE !"
            genBtn.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
            refreshKeyList()
            task.wait(1.5)
            genBtn.Text = "GÉNÉRER LA CLÉ SUR MESURE"
            genBtn.BackgroundColor3 = Color3.fromRGB(80, 100, 255)
        end)

        UserInputService.InputBegan:Connect(function(input, processed)
            if not processed and input.KeyCode == Enum.KeyCode.F3 then
                if adminMain.Visible then
                    adminMain.Visible = false
                else
                    pinFrame.Visible = not pinFrame.Visible
                end
            end
        end)

        pinBtn.MouseButton1Click:Connect(function()
            if pinInput.Text == "1455" then
                pinFrame.Visible = false
                pinInput.Text = ""
                adminMain.Visible = true
                refreshKeyList()
            else
                pinInput.Text = ""
                pinInput.PlaceholderText = "Code Faux !"
                task.wait(1)
                pinInput.PlaceholderText = "Code PIN Admin..."
            end
        end)
    end)
end)
