if not game:IsLoaded() then
game.Loaded:Wait()
end
_G.AllowedRarities = {
["COMMON"]                  = true,
["UNCOMMON"]                = true,
["RARE"]                    = true,
["EPIC"]                    = true,
["LEGENDARY"]               = true,
["MYTHIC"]                  = true,
["SECRET/DIVINE/SOVEREIGN"] = true
}
_G.AllowedAreas = {}
for i = 1, 15 do
_G.AllowedAreas["Area" .. i] = true
end
_G.AutoWalkFarm = false
_G.FarmV2Enabled = false
_G.BatAuraEnabled = false
_G.BoxEspEnabled = false
_G.PlayerEspEnabled = false
_G.DecorationsCleared = false
local TreadmillPosition = Vector3.new(137, 2.92, -114)
local IgnoredBoxes = {}
local DecorativeObjects = {}
local EspContainer = {}
local PlayerEspContainer = {}
local InternalCarryState = false
local LastSwingTime = os.clock()
local LastPosition = Vector3.new(0, 0, 0)
local LastMoveTime = os.clock()
local FaceDatabase = {
["139657139910728"] = "COMMON",
["98602631774718"]  = "UNCOMMON",
["93383697407654"]  = "RARE",
["114035647231925"] = "EPIC",
["133434398242702"] = "LEGENDARY",
["131715145031077"] = "MYTHIC",
["108908582036844"] = "SECRET/DIVINE/SOVEREIGN"
}
local RarityColors = {
["COMMON"]                  = Color3.fromRGB(150, 150, 160),
["UNCOMMON"]                = Color3.fromRGB(50, 200, 50),
["RARE"]                    = Color3.fromRGB(50, 150, 255),
["EPIC"]                    = Color3.fromRGB(0, 50, 200),
["LEGENDARY"]               = Color3.fromRGB(150, 0, 255),
["MYTHIC"]                  = Color3.fromRGB(255, 0, 50),
["SECRET/DIVINE/SOVEREIGN"] = Color3.fromRGB(255, 200, 0)
}
local AreaCenters = {}
local AreasFolder = game:GetService("Workspace"):FindFirstChild("Areas")
if AreasFolder then
for _, area in pairs(AreasFolder:GetChildren()) do
if area.Name:sub(1, 4) == "Area" then
local boxesFolder = area:FindFirstChild("Boxes")
if boxesFolder and #boxesFolder:GetChildren() > 0 then
local totalPos = Vector3.new(0, 0, 0)
local count = 0
for _, spawnPoint in pairs(boxesFolder:GetChildren()) do
if spawnPoint:IsA("BasePart") then
totalPos = totalPos + spawnPoint.Position
count = count + 1
end
end
if count > 0 then
AreaCenters[area.Name] = totalPos / count
end
end
if not AreaCenters[area.Name] then
local firstPart = area:FindFirstChildWhichIsA("BasePart", true)
if firstPart then
AreaCenters[area.Name] = firstPart.Position
end
end
end
end
end
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "MasterHubGui"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = game:GetService("CoreGui")
local Frame = Instance.new("Frame")
Frame.Name = "MainFrame"
Frame.Size = UDim2.new(0, 340, 0, 520)
Frame.Position = UDim2.new(0.05, 0, 0.15, 0)
Frame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
Frame.BorderSizePixel = 0
Frame.Active = true
Frame.Draggable = true
Frame.Parent = ScreenGui
local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 8)
UICorner.Parent = Frame
local Title = Instance.new("TextLabel")
Title.Name = "TitleLabel"
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
Title.Text = "  Master Hub - Final Architecture"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 18
Title.Parent = Frame
local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 8)
TitleCorner.Parent = Title
local MinimizeButton = Instance.new("TextButton")
MinimizeButton.Name = "MinimizeButton"
MinimizeButton.Size = UDim2.new(0, 30, 0, 30)
MinimizeButton.Position = UDim2.new(1, -65, 0, 5)
MinimizeButton.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
MinimizeButton.Text = "_"
MinimizeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
MinimizeButton.Font = Enum.Font.SourceSansBold
MinimizeButton.TextSize = 16
MinimizeButton.Parent = Frame
local MinCorner = Instance.new("UICorner")
MinCorner.CornerRadius = UDim.new(0, 6)
MinCorner.Parent = MinimizeButton
local PlayButton = Instance.new("TextButton")
PlayButton.Name = "ServerHopButton"
PlayButton.Size = UDim2.new(0, 30, 0, 30)
PlayButton.Position = UDim2.new(1, -35, 0, 5)
PlayButton.BackgroundColor3 = Color3.fromRGB(130, 50, 160)
PlayButton.Text = ">"
PlayButton.TextColor3 = Color3.fromRGB(255, 255, 255)
PlayButton.Font = Enum.Font.SourceSansBold
PlayButton.TextSize = 14
PlayButton.Parent = Frame
local HopCorner = Instance.new("UICorner")
HopCorner.CornerRadius = UDim.new(0, 6)
HopCorner.Parent = PlayButton
local ToggleButton = Instance.new("TextButton")
ToggleButton.Name = "ToggleFarmButton"
ToggleButton.Size = UDim2.new(0.3, 0, 0, 30)
ToggleButton.Position = UDim2.new(0.03, 0, 0, 50)
ToggleButton.BackgroundColor3 = Color3.fromRGB(170, 50, 50)
ToggleButton.Text = "Farm V1"
ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleButton.Font = Enum.Font.SourceSansBold
ToggleButton.TextSize = 11
ToggleButton.Parent = Frame
local ButtonCorner = Instance.new("UICorner")
ButtonCorner.CornerRadius = UDim.new(0, 6)
ButtonCorner.Parent = ToggleButton
local Farm2Button = Instance.new("TextButton")
Farm2Button.Name = "ToggleFarm2Button"
Farm2Button.Size = UDim2.new(0.3, 0, 0, 30)
Farm2Button.Position = UDim2.new(0.35, 0, 0, 50)
Farm2Button.BackgroundColor3 = Color3.fromRGB(170, 50, 50)
Farm2Button.Text = "Farm V2"
Farm2Button.TextColor3 = Color3.fromRGB(255, 255, 255)
Farm2Button.Font = Enum.Font.SourceSansBold
Farm2Button.TextSize = 11
Farm2Button.Parent = Frame
local Farm2Corner = Instance.new("UICorner")
Farm2Corner.CornerRadius = UDim.new(0, 6)
Farm2Corner.Parent = Farm2Button
local BatButton = Instance.new("TextButton")
BatButton.Name = "ToggleBatButton"
BatButton.Size = UDim2.new(0.3, 0, 0, 30)
BatButton.Position = UDim2.new(0.67, 0, 0, 50)
BatButton.BackgroundColor3 = Color3.fromRGB(80, 80, 85)
BatButton.Text = "Bat Aura"
BatButton.TextColor3 = Color3.fromRGB(255, 255, 255)
BatButton.Font = Enum.Font.SourceSansBold
BatButton.TextSize = 11
BatButton.Parent = Frame
local BatCorner = Instance.new("UICorner")
BatCorner.CornerRadius = UDim.new(0, 6)
BatCorner.Parent = BatButton
local EspButton = Instance.new("TextButton")
EspButton.Name = "ToggleEspButton"
EspButton.Size = UDim2.new(0.3, 0, 0, 30)
EspButton.Position = UDim2.new(0.03, 0, 0, 86)
EspButton.BackgroundColor3 = Color3.fromRGB(80, 80, 85)
EspButton.Text = "Box ESP"
EspButton.TextColor3 = Color3.fromRGB(255, 255, 255)
EspButton.Font = Enum.Font.SourceSansBold
EspButton.TextSize = 11
EspButton.Parent = Frame
local EspCorner = Instance.new("UICorner")
EspCorner.CornerRadius = UDim.new(0, 6)
EspCorner.Parent = EspButton
local PEspButton = Instance.new("TextButton")
PEspButton.Name = "TogglePlayerEspButton"
PEspButton.Size = UDim2.new(0.3, 0, 0, 30)
PEspButton.Position = UDim2.new(0.35, 0, 0, 86)
PEspButton.BackgroundColor3 = Color3.fromRGB(80, 80, 85)
PEspButton.Text = "Ply ESP"
PEspButton.TextColor3 = Color3.fromRGB(255, 255, 255)
PEspButton.Font = Enum.Font.SourceSansBold
PEspButton.TextSize = 11
PEspButton.Parent = Frame
local PEspCorner = Instance.new("UICorner")
PEspCorner.CornerRadius = UDim.new(0, 6)
PEspCorner.Parent = PEspButton
local HideDecoButton = Instance.new("TextButton")
HideDecoButton.Name = "DecoHideButton"
HideDecoButton.Size = UDim2.new(0.3, 0, 0, 30)
HideDecoButton.Position = UDim2.new(0.67, 0, 0, 86)
HideDecoButton.BackgroundColor3 = Color3.fromRGB(150, 80, 0)
HideDecoButton.Text = "Deco: ON"
HideDecoButton.TextColor3 = Color3.fromRGB(255, 255, 255)
HideDecoButton.Font = Enum.Font.SourceSansBold
HideDecoButton.TextSize = 11
HideDecoButton.Parent = Frame
local HideDecoCorner = Instance.new("UICorner")
HideDecoCorner.CornerRadius = UDim.new(0, 6)
HideDecoCorner.Parent = HideDecoButton
local PermanentDecoButton = Instance.new("TextButton")
PermanentDecoButton.Name = "DecoDeleteButton"
PermanentDecoButton.Size = UDim2.new(0.94, 0, 0, 30)
PermanentDecoButton.Position = UDim2.new(0.03, 0, 0, 122)
PermanentDecoButton.BackgroundColor3 = Color3.fromRGB(180, 30, 30)
PermanentDecoButton.Text = "DelDec (Permanent Destroy)"
PermanentDecoButton.TextColor3 = Color3.fromRGB(255, 255, 255)
PermanentDecoButton.Font = Enum.Font.SourceSansBold
PermanentDecoButton.TextSize = 11
PermanentDecoButton.Parent = Frame
local PermCorner = Instance.new("UICorner")
PermCorner.CornerRadius = UDim.new(0, 6)
PermCorner.Parent = PermanentDecoButton
local Scroll = Instance.new("ScrollingFrame")
Scroll.Name = "MainSettingsScroll"
Scroll.Size = UDim2.new(0.94, 0, 0, 320)
Scroll.Position = UDim2.new(0.03, 0, 0, 160)
Scroll.BackgroundTransparency = 1
Scroll.BorderSizePixel = 0
Scroll.CanvasSize = UDim2.new(0, 0, 0, 960)
Scroll.ScrollBarThickness = 4
Scroll.Parent = Frame
local UIList = Instance.new("UIListLayout")
UIList.Padding = UDim.new(0, 6)
UIList.SortOrder = Enum.SortOrder.LayoutOrder
UIList.Parent = Scroll
local function removeAllBoxEsp()
for box, esp in pairs(EspContainer) do
if esp.Highlight then esp.Highlight:Destroy() end
if esp.Billboard then esp.Billboard:Destroy() end
end
table.clear(EspContainer)
end
local function removeAllPlayerEsp()
for player, esp in pairs(PlayerEspContainer) do
if esp.Highlight then esp.Highlight:Destroy() end
if esp.Billboard then esp.Billboard:Destroy() end
end
table.clear(PlayerEspContainer)
end
local isMinimized = false
MinimizeButton.MouseButton1Click:Connect(function()
isMinimized = not isMinimized
if isMinimized then
Frame.Size = UDim2.new(0, 340, 0, 40)
Scroll.Visible = false
ToggleButton.Visible = false
Farm2Button.Visible = false
BatButton.Visible = false
EspButton.Visible = false
PEspButton.Visible = false
HideDecoButton.Visible = false
PermanentDecoButton.Visible = false
MinimizeButton.Text = "+"
else
Frame.Size = UDim2.new(0, 340, 0, 520)
Scroll.Visible = true
ToggleButton.Visible = true
Farm2Button.Visible = true
BatButton.Visible = true
EspButton.Visible = true
PEspButton.Visible = true
HideDecoButton.Visible = true
PermanentDecoButton.Visible = true
MinimizeButton.Text = "_"
end
end)
ToggleButton.MouseButton1Click:Connect(function()
_G.AutoWalkFarm = not _G.AutoWalkFarm
_G.FarmV2Enabled = false
Farm2Button.BackgroundColor3 = Color3.fromRGB(170, 50, 50)
Farm2Button.Text = "Farm V2"
if _G.AutoWalkFarm then
ToggleButton.BackgroundColor3 = Color3.fromRGB(0, 170, 100)
ToggleButton.Text = "Farm V1: ON"
else
ToggleButton.BackgroundColor3 = Color3.fromRGB(170, 50, 50)
ToggleButton.Text = "Farm V1"
end
end)
Farm2Button.MouseButton1Click:Connect(function()
_G.FarmV2Enabled = not _G.FarmV2Enabled
_G.AutoWalkFarm = false
ToggleButton.BackgroundColor3 = Color3.fromRGB(170, 50, 50)
ToggleButton.Text = "Farm V1"
if _G.FarmV2Enabled then
Farm2Button.BackgroundColor3 = Color3.fromRGB(0, 170, 100)
Farm2Button.Text = "Farm V2: ON"
else
Farm2Button.BackgroundColor3 = Color3.fromRGB(170, 50, 50)
Farm2Button.Text = "Farm V2"
end
end)
BatButton.MouseButton1Click:Connect(function()
_G.BatAuraEnabled = not _G.BatAuraEnabled
if _G.BatAuraEnabled then
BatButton.BackgroundColor3 = Color3.fromRGB(0, 120, 170)
else
BatButton.BackgroundColor3 = Color3.fromRGB(80, 80, 85)
end
end)
EspButton.MouseButton1Click:Connect(function()
_G.BoxEspEnabled = not _G.BoxEspEnabled
if _G.BoxEspEnabled then
EspButton.BackgroundColor3 = Color3.fromRGB(0, 140, 90)
else
EspButton.BackgroundColor3 = Color3.fromRGB(80, 80, 85)
removeAllBoxEsp()
end
end)
PEspButton.MouseButton1Click:Connect(function()
_G.PlayerEspEnabled = not _G.PlayerEspEnabled
if _G.PlayerEspEnabled then
PEspButton.BackgroundColor3 = Color3.fromRGB(0, 140, 90)
else
PEspButton.BackgroundColor3 = Color3.fromRGB(80, 80, 85)
removeAllPlayerEsp()
end
end)
HideDecoButton.MouseButton1Click:Connect(function()
_G.DecorationsCleared = not _G.DecorationsCleared
local folder = game:GetService("Workspace"):FindFirstChild("Decorations")
if folder then
if _G.DecorationsCleared then
HideDecoButton.BackgroundColor3 = Color3.fromRGB(50, 120, 170)
HideDecoButton.Text = "Deco: OFF"
for _, obj in pairs(folder:GetDescendants()) do
if obj:IsA("BasePart") then
DecorativeObjects[obj] = obj.CFrame
obj.CFrame = obj.CFrame - Vector3.new(0, 300, 0)
end
end
else
HideDecoButton.BackgroundColor3 = Color3.fromRGB(150, 80, 0)
HideDecoButton.Text = "Deco: ON"
for obj, originalCFrame in pairs(DecorativeObjects) do
if obj and obj.Parent then
obj.CFrame = originalCFrame
end
end
table.clear(DecorativeObjects)
end
end
end)
PermanentDecoButton.MouseButton1Click:Connect(function()
local folder = game:GetService("Workspace"):FindFirstChild("Decorations")
if folder then
folder:Destroy()
PermanentDecoButton.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
PermanentDecoButton.Text = "Decorations Permanently Destroyed"
PermanentDecoButton.Active = false
end
end)
PlayButton.MouseButton1Click:Connect(function()
loadstring(game:HttpGet("https://scriptblox.com/raw/Universal-Script-Universal-server-hop-script-130449"))()
end)
game:GetService("UserInputService").InputBegan:Connect(function(input, processed)
if not processed and input.KeyCode == Enum.KeyCode.Insert then
Frame.Visible = not Frame.Visible
end
end)
local function createToggle(name, initialValue, callback, layoutOrder)
local Button = Instance.new("TextButton")
Button.Size = UDim2.new(1, -5, 0, 30)
Button.LayoutOrder = layoutOrder
if initialValue then
Button.BackgroundColor3 = Color3.fromRGB(45, 65, 95)
Button.Text = name .. " : ENABLED"
else
Button.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
Button.Text = name .. " : DISABLED"
end
Button.TextColor3 = Color3.fromRGB(230, 230, 230)
Button.Font = Enum.Font.SourceSans
Button.TextSize = 14
Button.Parent = Scroll
local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(0, 4)
Corner.Parent = Button
Button.MouseButton1Click:Connect(function()
local newValue = callback()
if newValue then
Button.BackgroundColor3 = Color3.fromRGB(45, 65, 95)
Button.Text = name .. " : ENABLED"
else
Button.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
Button.Text = name .. " : DISABLED"
end
end)
end
local currentLayout = 1
local RarityHeader = Instance.new("TextLabel")
RarityHeader.Size = UDim2.new(1, 0, 0, 20)
RarityHeader.BackgroundTransparency = 1
RarityHeader.Text = "--- RARITIES FILTER ---"
RarityHeader.TextColor3 = Color3.fromRGB(150, 150, 160)
RarityHeader.Font = Enum.Font.SourceSansBold
RarityHeader.TextSize = 12
RarityHeader.LayoutOrder = currentLayout
RarityHeader.Parent = Scroll
currentLayout = currentLayout + 1
local orderedRarities = {"COMMON", "UNCOMMON", "RARE", "EPIC", "LEGENDARY", "MYTHIC", "SECRET/DIVINE/SOVEREIGN"}
for _, rarityName in ipairs(orderedRarities) do
createToggle(rarityName, _G.AllowedRarities[rarityName], function()
_G.AllowedRarities[rarityName] = not _G.AllowedRarities[rarityName]
return _G.AllowedRarities[rarityName]
end, currentLayout)
currentLayout = currentLayout + 1
end
local AreaHeader = Instance.new("TextLabel")
AreaHeader.Size = UDim2.new(1, 0, 0, 20)
AreaHeader.BackgroundTransparency = 1
AreaHeader.Text = "--- AREAS FILTER ---"
AreaHeader.TextColor3 = Color3.fromRGB(150, 150, 160)
AreaHeader.Font = Enum.Font.SourceSansBold
AreaHeader.TextSize = 12
AreaHeader.LayoutOrder = currentLayout
AreaHeader.Parent = Scroll
currentLayout = currentLayout + 1
for i = 1, 15 do
local areaKey = "Area" .. i
createToggle(areaKey, _G.AllowedAreas[areaKey], function()
_G.AllowedAreas["Area" .. i] = not _G.AllowedAreas["Area" .. i]
return _G.AllowedAreas["Area" .. i]
end, currentLayout)
currentLayout = currentLayout + 1
end
local function getBoxRarity(boxModel)
local foundid = nil
for _, child in pairs(boxModel:GetDescendants()) do
if child:IsA("Decal") or child:IsA("Texture") then
if child.Texture ~= "" then
local id = child.Texture:match("%d+")
if id then foundid = id; break; end
end
elseif child:IsA("ImageLabel") then
if child.Image ~= "" then
local id = child.Image:match("%d+")
if id then foundid = id; break; end
end
end
end
local name = boxModel.Name:lower()
if foundid and FaceDatabase[foundid] then return FaceDatabase[foundid] end
if name:match("king") or name:match("sovereign") or name:match("true") or name:match("secret") or name:match("divine") then
return "SECRET/DIVINE/SOVEREIGN"
end
return "COMMON"
end
local function createBoxEsp(boxModel, rarity)
if not _G.BoxEspEnabled then return end
if EspContainer[boxModel] then return end
local color = RarityColors[rarity] or Color3.fromRGB(255, 255, 255)
local areaName = boxModel:GetAttribute("AssignedArea") or "Area1"
local highlight = Instance.new("Highlight")
highlight.FillColor = color
highlight.FillTransparency = 0.5
highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
highlight.Adornee = boxModel
highlight.Parent = ScreenGui
local billboard = Instance.new("BillboardGui")
billboard.Size = UDim2.new(0, 160, 0, 45)
billboard.AlwaysOnTop = true
billboard.ExtentsOffset = Vector3.new(0, 2.5, 0)
local targetPart = boxModel:IsA("Model") and (boxModel.PrimaryPart or boxModel:FindFirstChildWhichIsA("BasePart", true)) or boxModel
if not targetPart then return end
billboard.Adornee = targetPart
billboard.Parent = ScreenGui
local label = Instance.new("TextLabel")
label.Size = UDim2.new(1, 0, 1, 0)
label.BackgroundTransparency = 1
label.TextColor3 = color
label.TextStrokeTransparency = 0
label.Font = Enum.Font.SourceSansBold
label.TextSize = 13
label.Text = rarity .. " [" .. areaName .. "]"
label.Parent = billboard
EspContainer[boxModel] = {Highlight = highlight, Billboard = billboard, Label = label}
end
local function createPlayerEsp(player)
if not _G.PlayerEspEnabled then return end
if player == game:GetService("Players").LocalPlayer then return end
if PlayerEspContainer[player] then return end
local char = player.Character
local root = char and char:FindFirstChild("HumanoidRootPart")
if not root then return end
local highlight = Instance.new("Highlight")
highlight.FillColor = Color3.fromRGB(0, 255, 200)
highlight.FillTransparency = 0.6
highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
highlight.Adornee = char
highlight.Parent = ScreenGui
local billboard = Instance.new("BillboardGui")
billboard.Size = UDim2.new(0, 140, 0, 40)
billboard.AlwaysOnTop = true
billboard.ExtentsOffset = Vector3.new(0, 3.5, 0)
billboard.Adornee = root
billboard.Parent = ScreenGui
local label = Instance.new("TextLabel")
label.Size = UDim2.new(1, 0, 1, 0)
label.BackgroundTransparency = 1
label.TextColor3 = Color3.fromRGB(0, 255, 200)
label.TextStrokeTransparency = 0
label.Font = Enum.Font.SourceSansBold
label.TextSize = 12
label.Text = player.Name
label.Parent = billboard
PlayerEspContainer[player] = {Highlight = highlight, Billboard = billboard, Label = label}
end
local function updateAllEsp(root)
if _G.BoxEspEnabled then
for box, esp in pairs(EspContainer) do
if box and box.Parent then
local boxPos = box:IsA("Model") and box:GetPivot().Position or box.Position
local dist = math.floor((root.Position - boxPos).Magnitude)
local rarity = getBoxRarity(box)
local areaName = box:GetAttribute("AssignedArea") or "Area1"
esp.Label.Text = rarity .. " [" .. areaName .. "]\n[" .. dist .. "m]"
else
if esp.Highlight then esp.Highlight:Destroy() end
if esp.Billboard then esp.Billboard:Destroy() end
EspContainer[box] = nil
end
end
end
if _G.PlayerEspEnabled then
for player, esp in pairs(PlayerEspContainer) do
local char = player.Character
local pRoot = char and char:FindFirstChild("HumanoidRootPart")
if player and player.Parent and char and pRoot then
local dist = math.floor((root.Position - pRoot.Position).Magnitude)
esp.Label.Text = player.Name .. "\n[" .. dist .. "m]"
else
if esp.Highlight then esp.Highlight:Destroy() end
if esp.Billboard then esp.Billboard:Destroy() end
PlayerEspContainer[player] = nil
end
end
for _, p in pairs(game:GetService("Players"):GetPlayers()) do
if p ~= game:GetService("Players").LocalPlayer and not PlayerEspContainer[p] and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
createPlayerEsp(p)
end
end
end
end
local function assignBoxAreaPermanently(boxModel)
if boxModel:GetAttribute("AssignedArea") then return end
local boxPos = boxModel:IsA("Model") and boxModel:GetPivot().Position or boxModel.Position
local closestArea = "Area1"
local shortestDist = math.huge
for areaName, centerPos in pairs(AreaCenters) do
local dist = (boxPos - centerPos).Magnitude
if dist < shortestDist then
shortestDist = dist
closestArea = areaName
end
end
boxModel:SetAttribute("AssignedArea", closestArea)
local rarity = getBoxRarity(boxModel)
if _G.BoxEspEnabled then createBoxEsp(boxModel, rarity) end
end
local BoxRuntime = game:GetService("Workspace"):FindFirstChild("BoxRuntime")
if BoxRuntime then
for _, box in pairs(BoxRuntime:GetChildren()) do assignBoxAreaPermanently(box); end
BoxRuntime.ChildAdded:Connect(function(child)
task.wait(0.1)
if child:IsDescendantOf(game:GetService("Workspace")) then assignBoxAreaPermanently(child); end
end)
end
local function getBestBoxChoice()
local character = game:GetService("Players").LocalPlayer.Character
local root = character and character:FindFirstChild("HumanoidRootPart")
if not root or not BoxRuntime then return nil end
local bestBox = nil
local shortestDistance = math.huge
for _, obj in pairs(BoxRuntime:GetChildren()) do
if not IgnoredBoxes[obj] then
assignBoxAreaPermanently(obj)
local assignedArea = obj:GetAttribute("AssignedArea") or "Area1"
if _G.AllowedAreas[assignedArea] then
local prompt = obj:FindFirstChild("Steal", true) or obj:FindFirstChildOfClass("ProximityPrompt")
if prompt then
local rarity = getBoxRarity(obj)
if _G.AllowedRarities[rarity] then
local targetPos = obj:IsA("Model") and obj:GetPivot().Position or obj.Position
local distance = (root.Position - targetPos).Magnitude
if distance < shortestDistance then
shortestDistance = distance
bestBox = obj
end
end
end
end
end
end
return bestBox
end
local function isCarryingBox()
if game:GetService("Workspace"):FindFirstChild("BoxRuntime") then
for _, box in pairs(game:GetService("Workspace").BoxRuntime:GetChildren()) do
if box:FindFirstChild("CarryWeld", true) then return true; end
end
end
local character = game:GetService("Players").LocalPlayer.Character
if character then
for _, child in pairs(character:GetChildren()) do
if child.Name == "CarryWeld" or child:IsA("WeldConstraint") and child.Name:match("Carry") then return true; end
end
end
return false
end
local function performBatAuraTick(root)
if not _G.BatAuraEnabled then return end
if os.clock() - LastSwingTime < 0.45 then return end
local pPlayer = game:GetService("Players").LocalPlayer
local currentBat = nil
if pPlayer.Character and pPlayer.Character:FindFirstChildWhichIsA("Tool") then
local tool = pPlayer.Character:FindFirstChildWhichIsA("Tool")
if tool.Name:lower():match("bat") then currentBat = tool; end
end
if not currentBat and pPlayer:FindFirstChild("Backpack") then
for _, tool in pairs(pPlayer.Backpack:GetChildren()) do
if tool:IsA("Tool") and tool.Name:lower():match("bat") then
tool.Parent = pPlayer.Character
currentBat = tool
break
end
end
end
if not currentBat then return end
local attackRadius = 12.0
local batName = currentBat.Name:lower()
if batName:match("orange") or batName:match("dungeon") or batName:match("coral") or batName:match("void") then attackRadius = 15.0;
elseif batName:match("marble") or batName:match("shard") or batName:match("lava") or batName:match("sakura") then attackRadius = 18.0;
elseif batName:match("galaxy") or batName:match("candy") or batName:match("moon") or batName:match("prism") then attackRadius = 21.0; end
local isPlayerNearby = false
for _, player in pairs(game:GetService("Players"):GetPlayers()) do
if player ~= pPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
local dist = (root.Position - player.Character.HumanoidRootPart.Position).Magnitude
if dist <= attackRadius then isPlayerNearby = true; break; end
end
end
if isPlayerNearby then currentBat:Activate(); LastSwingTime = os.clock(); end
end
local function getSteeringAdjustedPosition(currentPos, targetPos, currentSpeed, forceZ)
local finalTarget = targetPos
if forceZ then
finalTarget = Vector3.new(targetPos.X, targetPos.Y, -114)
end
local desiredDirection = (finalTarget - currentPos).Unit
local avoidanceForce = Vector3.new(0, 0, 0)
local hazardsFolder = game:GetService("Workspace"):FindFirstChild("Hazards")
if hazardsFolder then
for _, hazardChild in pairs(hazardsFolder:GetChildren()) do
for _, part in pairs(hazardChild:GetDescendants()) do
if part:IsA("BasePart") then
local distance = (currentPos - part.Position).Magnitude
local detectionRadius = (part.Size.Magnitude * 0.45) + 3.5
if distance < detectionRadius then
avoidanceForce = avoidanceForce + ((currentPos - part.Position).Unit * ((detectionRadius - distance) / detectionRadius) * 5.8)
end
end
end
end
end
local mineFolder = game:GetService("Workspace"):FindFirstChild("LandmineRuntime")
if mineFolder then
for _, part in pairs(mineFolder:GetDescendants()) do
if part:IsA("BasePart") then
local distance = (currentPos - part.Position).Magnitude
local detectionRadius = 10.0
if distance < detectionRadius then
avoidanceForce = avoidanceForce + ((currentPos - part.Position).Unit * ((detectionRadius - distance) / detectionRadius) * 6.5)
end
end
end
end
local activeArea = game:GetService("Workspace"):FindFirstChild("Areas")
if activeArea then
for _, area in pairs(activeArea:GetChildren()) do
local walls = area:FindFirstChild("Walls")
if walls then
for _, part in pairs(walls:GetDescendants()) do
if part:IsA("BasePart") and part.CanCollide then
local distance = (currentPos - part.Position).Magnitude
local detectionRadius = 6.0
if distance < detectionRadius then
avoidanceForce = avoidanceForce + ((currentPos - part.Position).Unit * ((detectionRadius - distance) / detectionRadius) * 5.0)
end
end
end
end
end
end
local finalDirection = (desiredDirection + avoidanceForce).Unit
local stepMultiplier = math.max(currentSpeed * 0.45, 14.0)
return currentPos + (finalDirection * stepMultiplier)
end
task.spawn(function()
while true do
task.wait(0.03)
if game:GetService("Players").LocalPlayer.Character then
local character = game:GetService("Players").LocalPlayer.Character
local root = character and character:FindFirstChild("HumanoidRootPart")
local humanoid = character and character:FindFirstChildOfClass("Humanoid")
if root and humanoid and humanoid.Health > 0 then
local currentlyCarrying = isCarryingBox()
local currentSpeed = humanoid.WalkSpeed
performBatAuraTick(root)
updateAllEsp(root)
if (root.Position - LastPosition).Magnitude > 0.5 then
LastPosition = root.Position
LastMoveTime = os.clock()
else
if (_G.AutoWalkFarm or _G.FarmV2Enabled) and (os.clock() - LastMoveTime > 5.0) then
humanoid.Jump = true
LastMoveTime = os.clock()
end
end
if _G.BoxEspEnabled then
for _, box in pairs(BoxRuntime:GetChildren()) do if not EspContainer[box] then createBoxEsp(box, getBoxRarity(box)); end; end
end
if _G.AutoWalkFarm or _G.FarmV2Enabled then
if InternalCarryState == true and currentlyCarrying == false then
if (root.Position - TreadmillPosition).Magnitude > 10.0 then table.clear(IgnoredBoxes); end
end
InternalCarryState = currentlyCarrying
if currentlyCarrying then
local dist = (root.Position - TreadmillPosition).Magnitude
if dist <= 6.0 then
root.AssemblyLinearVelocity = Vector3.new(0, 0, 0); root.Anchored = true; task.wait(0.5); root.Anchored = false; table.clear(IgnoredBoxes);
else
local targetPosForReturn = TreadmillPosition
if _G.FarmV2Enabled then
targetPosForReturn = Vector3.new(TreadmillPosition.X, TreadmillPosition.Y, -114)
root.CFrame = CFrame.new(root.Position.X, root.Position.Y, -114) * (root.CFrame - root.Position)
end
local adjustedPos = getSteeringAdjustedPosition(root.Position, targetPosForReturn, currentSpeed, _G.FarmV2Enabled)
humanoid:MoveTo(adjustedPos)
end
else
local targetBox = getBestBoxChoice()
if not targetBox then
if (root.Position - TreadmillPosition).Magnitude > 6 then
local adjustedPos = getSteeringAdjustedPosition(root.Position, TreadmillPosition, currentSpeed, false)
humanoid:MoveTo(adjustedPos)
end
else
local prompt = targetBox:FindFirstChild("Steal", true) or targetBox:FindFirstChildOfClass("ProximityPrompt")
local targetPos = targetBox:IsA("Model") and targetBox:GetPivot().Position or targetBox.Position
if (root.Position - targetPos).Magnitude <= 5.0 then
IgnoredBoxes[targetBox] = true; root.AssemblyLinearVelocity = Vector3.new(0, 0, 0); root.Anchored = true;
if prompt then fireproximityprompt(prompt); end
task.wait(1.0); root.Anchored = false;
if isCarryingBox() then
local targetPosForReturn = TreadmillPosition
if _G.FarmV2Enabled then
targetPosForReturn = Vector3.new(TreadmillPosition.X, TreadmillPosition.Y, -114)
root.CFrame = CFrame.new(root.Position.X, root.Position.Y, -114) * (root.CFrame - root.Position)
end
humanoid:MoveTo(getSteeringAdjustedPosition(root.Position, targetPosForReturn, currentSpeed, _G.FarmV2Enabled))
else
table.clear(IgnoredBoxes)
end
else
humanoid:MoveTo(getSteeringAdjustedPosition(root.Position, targetPos, currentSpeed, false))
end
end
end
end
end
end
end
end)
print("[Master Hub]: Кнопка тотального удаления DelDec успешно интегрирована в интерфейс!")
