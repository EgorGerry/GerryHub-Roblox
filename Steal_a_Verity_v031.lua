if not game:IsLoaded() then
game.Loaded:Wait()
end
_G.AllowedRarities = {
["COMMON"]    = false,
["UNCOMMON"]  = false,
["RARE"]      = false,
["EPIC"]      = false,
["LEGENDARY"] = false,
["MYTHIC"]    = false,
["SECRET"]    = false,
["DIVINE"]    = false,
["SOVEREIGN"] = false
}
_G.AllowedAreas = {}
for i = 1, 15 do
_G.AllowedAreas["Area" .. i] = false
end
_G.AutoWalkFarm = false
_G.FarmV2Enabled = false
_G.BatAuraEnabled = false
_G.BoxEspEnabled = false
_G.PlayerEspEnabled = false
_G.DecorationsCleared = false
_G.AntiAfkEnabled = false
_G.AutoGiftEnabled = false
_G.BatRangeCircleEnabled = false
_G.EquipBatAlways = false
_G.V2EvadeHeight = 18
_G.V2EvadeRadius = 24
local TreadmillPosition = Vector3.new(137, 2.92, -24)
local SpawnFolder = game:GetService("Workspace"):FindFirstChild("Spawn")
if SpawnFolder then
local Floor = SpawnFolder:FindFirstChild("Spawn") or SpawnFolder:FindFirstChildWhichIsA("BasePart", true)
if Floor then
TreadmillPosition = Vector3.new(Floor.Position.X, Floor.Position.Y, -24)
end
end
local IgnoredBoxes = {}
local EspContainer = {}
local PlayerEspContainer = {}
local HazardHighlights = {}
local InternalCarryState = false
local LastSwingTime = os.clock()
local LastGiftCheck = os.clock()
local LastCheckPosition = Vector3.new(0, 0, 0)
local AdminStuckCounter = 0
local CurrentActiveTargetBox = nil
local CurrentActiveTargetPlayer = nil
local TargetLockTime = 0
local LastTargetObject = nil
local TargetTracer = Drawing.new("Line")
TargetTracer.Visible = false
TargetTracer.Color = Color3.fromRGB(0, 255, 100)
TargetTracer.Thickness = 2.0
TargetTracer.Transparency = 0.95
local AuraCirclePoints = {}
local MaxCirclePoints = 64
for i = 1, MaxCirclePoints do
local line = Drawing.new("Line")
line.Visible = false
line.Color = Color3.fromRGB(255, 50, 50)
line.Thickness = 2.0
line.Transparency = 0.85
table.insert(AuraCirclePoints, line)
end
local FaceDatabase = {
["139657139910728"] = "COMMON",
["98602631774718"]  = "UNCOMMON",
["93383697407654"]  = "RARE",
["114035647231925"] = "EPIC",
["133434398242702"] = "LEGENDARY",
["131715145031077"] = "MYTHIC",
["108908582036844"] = "SECRET"
}
local BatRadiusTable = {
["wooden"] = 12, ["gold"] = 12, ["teal"] = 12, ["lime 1"] = 12, ["lime"] = 12,
["orange"] = 15, ["red"] = 15, ["cobalt"] = 15, ["violet"] = 15,
["sky"] = 18, ["obsidian"] = 18, ["emerald"] = 18, ["magenta"] = 18,
["blossom"] = 21, ["peach"] = 21, ["lilac"] = 21, ["aqua"] = 21, ["prism"] = 21
}
local RarityColors = {
["COMMON"]    = Color3.fromRGB(150, 150, 160),
["UNCOMMON"]  = Color3.fromRGB(50, 200, 50),
["RARE"]      = Color3.fromRGB(50, 150, 255),
["EPIC"]      = Color3.fromRGB(0, 50, 200),
["LEGENDARY"] = Color3.fromRGB(150, 0, 255),
["MYTHIC"]    = Color3.fromRGB(255, 0, 50),
["SECRET"]    = Color3.fromRGB(255, 0, 150),
["DIVINE"]    = Color3.fromRGB(0, 255, 230),
["SOVEREIGN"] = Color3.fromRGB(255, 200, 0)
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
Frame.Size = UDim2.new(0, 340, 0, 440)
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
Title.Text = "  GerryHub | Steal a Verity"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 16
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
MinimizeButton.Parent = Frame
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
ToggleButton.Size = UDim2.new(0.45, 0, 0, 32)
ToggleButton.Position = UDim2.new(0.03, 0, 0, 50)
ToggleButton.BackgroundColor3 = Color3.fromRGB(170, 50, 50)
ToggleButton.Text = "Farm V1"
ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleButton.Font = Enum.Font.SourceSansBold
ToggleButton.TextSize = 12
ToggleButton.Parent = Frame
local ButtonCorner = Instance.new("UICorner")
ButtonCorner.CornerRadius = UDim.new(0, 6)
ButtonCorner.Parent = ToggleButton
local Farm2Button = Instance.new("TextButton")
Farm2Button.Name = "ToggleFarm2Button"
Farm2Button.Size = UDim2.new(0.46, 0, 0, 32)
Farm2Button.Position = UDim2.new(0.51, 0, 0, 50)
Farm2Button.BackgroundColor3 = Color3.fromRGB(170, 50, 50)
Farm2Button.Text = "Farm V2"
Farm2Button.TextColor3 = Color3.fromRGB(255, 255, 255)
Farm2Button.Font = Enum.Font.SourceSansBold
Farm2Button.TextSize = 12
Farm2Button.Parent = Frame
local Farm2Corner = Instance.new("UICorner")
Farm2Corner.CornerRadius = UDim.new(0, 6)
Farm2Corner.Parent = Farm2Button
local BatButton = Instance.new("TextButton")
BatButton.Name = "ToggleBatButton"
BatButton.Size = UDim2.new(0.3, 0, 0, 32)
BatButton.Position = UDim2.new(0.03, 0, 0, 88)
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
EspButton.Size = UDim2.new(0.3, 0, 0, 32)
EspButton.Position = UDim2.new(0.35, 0, 0, 88)
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
PEspButton.Size = UDim2.new(0.3, 0, 0, 32)
PEspButton.Position = UDim2.new(0.67, 0, 0, 88)
PEspButton.BackgroundColor3 = Color3.fromRGB(80, 80, 85)
PEspButton.Text = "Ply ESP"
PEspButton.TextColor3 = Color3.fromRGB(255, 255, 255)
PEspButton.Font = Enum.Font.SourceSansBold
PEspButton.TextSize = 11
PEspButton.Parent = Frame
local PEspCorner = Instance.new("UICorner")
PEspCorner.CornerRadius = UDim.new(0, 6)
PEspCorner.Parent = PEspButton
local RectangleCutButton = Instance.new("TextButton")
RectangleCutButton.Name = "DecoDeleteButton"
RectangleCutButton.Size = UDim2.new(0.94, 0, 0, 32)
RectangleCutButton.Position = UDim2.new(0.03, 0, 0, 126)
RectangleCutButton.BackgroundColor3 = Color3.fromRGB(180, 30, 30)
RectangleCutButton.Text = "DelDec (Permanent Destroy)"
RectangleCutButton.TextColor3 = Color3.fromRGB(255, 255, 255)
RectangleCutButton.Font = Enum.Font.SourceSansBold
RectangleCutButton.TextSize = 12
RectangleCutButton.Parent = Frame
local PermanentDecoCorner = Instance.new("UICorner")
PermanentDecoCorner.CornerRadius = UDim.new(0, 6)
PermanentDecoCorner.Parent = RectangleCutButton
local Scroll = Instance.new("ScrollingFrame")
Scroll.Name = "MainSettingsScroll"
Scroll.Size = UDim2.new(0.94, 0, 0, 240)
Scroll.Position = UDim2.new(0.03, 0, 0, 165)
Scroll.BackgroundTransparency = 1
Scroll.BorderSizePixel = 0
Scroll.CanvasSize = UDim2.new(0, 0, 0, 1220)
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
if esp.Line then esp.Line:Destroy() end
end
table.clear(PlayerEspContainer)
end
local function resetAllFarmButtons()
ToggleButton.BackgroundColor3 = Color3.fromRGB(170, 50, 50)
ToggleButton.Text = "Farm V1"
Farm2Button.BackgroundColor3 = Color3.fromRGB(170, 50, 50)
Farm2Button.Text = "Farm V2"
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
RectangleCutButton.Visible = false
MinimizeButton.Text = "+"
else
Frame.Size = UDim2.new(0, 340, 0, 440)
Scroll.Visible = true
ToggleButton.Visible = true
Farm2Button.Visible = true
BatButton.Visible = true
EspButton.Visible = true
PEspButton.Visible = true
RectangleCutButton.Visible = true
MinimizeButton.Text = "_"
end
end)
ToggleButton.MouseButton1Click:Connect(function()
_G.AutoWalkFarm = not _G.AutoWalkFarm
_G.FarmV2Enabled = false
resetAllFarmButtons()
if _G.AutoWalkFarm then
ToggleButton.BackgroundColor3 = Color3.fromRGB(0, 170, 100)
ToggleButton.Text = "Farm V1: ON"
end
end)
Farm2Button.MouseButton1Click:Connect(function()
_G.FarmV2Enabled = not _G.FarmV2Enabled
_G.AutoWalkFarm = false
resetAllFarmButtons()
if _G.FarmV2Enabled then
Farm2Button.BackgroundColor3 = Color3.fromRGB(0, 170, 100)
Farm2Button.Text = "Farm V2: ON"
local char = game:GetService("Players").LocalPlayer.Character
local root = char and char:FindFirstChild("HumanoidRootPart")
if root then
root.CFrame = CFrame.new(root.Position.X, root.Position.Y, -24)
end
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
RectangleCutButton.MouseButton1Click:Connect(function()
local targetFolder = game:GetService("Workspace"):FindFirstChild("Decorations")
if targetFolder then
targetFolder:Destroy()
end
RectangleCutButton.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
RectangleCutButton.Text = "Decorations Purged"
RectangleCutButton.Active = false
end)
PlayButton.MouseButton1Click:Connect(function()
-- СЮДА ВСТАВЛЯТЬ ВАШ КАСТОМНЫЙ СКРИПТ ХОПА (Строка 278)
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
local function createSlider(name, minVal, maxVal, defaultVal, callback, layoutOrder)
local SliderFrame = Instance.new("Frame")
SliderFrame.Size = UDim2.new(1, -5, 0, 45)
SliderFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
SliderFrame.LayoutOrder = layoutOrder
SliderFrame.Parent = Scroll
local SliderCorner = Instance.new("UICorner")
SliderCorner.CornerRadius = UDim.new(0, 4)
SliderCorner.Parent = SliderFrame
local Label = Instance.new("TextLabel")
Label.Size = UDim2.new(1, 0, 0, 20)
Label.BackgroundTransparency = 1
Label.Text = "  " .. name .. ": " .. defaultVal
Label.TextColor3 = Color3.fromRGB(220, 220, 220)
Label.Font = Enum.Font.SourceSansBold
Label.TextSize = 13
Label.TextXAlignment = Enum.TextXAlignment.Left
Label.Parent = SliderFrame
local BarBackground = Instance.new("Frame")
BarBackground.Size = UDim2.new(0.92, 0, 0, 6)
BarBackground.Position = UDim2.new(0.04, 0, 0, 26)
BarBackground.BackgroundColor3 = Color3.fromRGB(60, 60, 65)
BarBackground.BorderSizePixel = 0
BarBackground.Parent = SliderFrame
local BarCorner = Instance.new("UICorner")
BarCorner.CornerRadius = UDim.new(0, 3)
BarCorner.Parent = BarBackground
local BarFill = Instance.new("Frame")
local pct = (defaultVal - minVal) / (maxVal - minVal)
BarFill.Size = UDim2.new(pct, 0, 1, 0)
BarFill.BackgroundColor3 = Color3.fromRGB(130, 50, 160)
BarFill.BorderSizePixel = 0
BarFill.Parent = BarBackground
local FillCorner = Instance.new("UICorner")
FillCorner.CornerRadius = UDim.new(0, 3)
FillCorner.Parent = BarFill
local UserInputService = game:GetService("UserInputService")
local dragging = false
local function updateSlider(input)
local posX = input.Position.X - BarBackground.AbsolutePosition.X
local width = BarBackground.AbsoluteSize.X
local ratio = math.clamp(posX / width, 0, 1)
BarFill.Size = UDim2.new(ratio, 0, 1, 0)
local finalVal = math.floor(minVal + (ratio * (maxVal - minVal)))
Label.Text = "  " .. name .. ": " .. finalVal
callback(finalVal)
end
BarBackground.InputBegan:Connect(function(input)
if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
dragging = true
updateSlider(input)
end
end)
UserInputService.InputChanged:Connect(function(input)
if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
updateSlider(input)
end
end)
UserInputService.InputEnded:Connect(function(input)
if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
dragging = false
end
end)
end
local currentLayout = 1
local AutomationHeader = Instance.new("TextLabel")
AutomationHeader.Size = UDim2.new(1, 0, 0, 20)
AutomationHeader.BackgroundTransparency = 1
AutomationHeader.Text = "--- UTILITIES ---"
AutomationHeader.TextColor3 = Color3.fromRGB(150, 150, 160)
AutomationHeader.Font = Enum.Font.SourceSansBold
AutomationHeader.TextSize = 12
AutomationHeader.LayoutOrder = currentLayout
AutomationHeader.Parent = Scroll
currentLayout = currentLayout + 1
createToggle("Anti-AFK System", _G.AntiAfkEnabled, function()
_G.AntiAfkEnabled = not _G.AntiAfkEnabled
return _G.AntiAfkEnabled
end, currentLayout)
currentLayout = currentLayout + 1
createToggle("Auto Claim Free Gift", _G.AutoGiftEnabled, function()
_G.AutoGiftEnabled = not _G.AutoGiftEnabled
return _G.AutoGiftEnabled
end, currentLayout)
currentLayout = currentLayout + 1
createToggle("Bat Range Circle", _G.BatRangeCircleEnabled, function()
_G.BatRangeCircleEnabled = not _G.BatRangeCircleEnabled
return _G.BatRangeCircleEnabled
end, currentLayout)
currentLayout = currentLayout + 1
createToggle("Equip Bat Always", _G.EquipBatAlways, function()
_G.EquipBatAlways = not _G.EquipBatAlways
return _G.EquipBatAlways
end, currentLayout)
currentLayout = currentLayout + 1
createSlider("V2 Evade Jump Height", 10, 40, _G.V2EvadeHeight, function(val)
_G.V2EvadeHeight = val
end, currentLayout)
currentLayout = currentLayout + 1
createSlider("V2 Evade Detection Radius", 10, 45, _G.V2EvadeRadius, function(val)
_G.V2EvadeRadius = val
end, currentLayout)
currentLayout = currentLayout + 1
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
local orderedRarities = {"COMMON", "UNCOMMON", "RARE", "EPIC", "LEGENDARY", "MYTHIC", "SECRET", "DIVINE", "SOVEREIGN"}
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
if boxModel:FindFirstChild("Ornament", true) or boxModel.Name:lower():match("king") then
return "SOVEREIGN"
end
if boxModel:FindFirstChild("Wings", true) then
return "DIVINE"
end
local foundid = nil
for _, child in pairs(boxModel:GetDescendants()) do
if child:IsA("Decal") or child:IsA("Texture") then
if child.Texture ~= "" then
local id = child.Texture:match("%d+")
if id then foundid = id; break end
end
elseif child:IsA("ImageLabel") then
if child.Image ~= "" then
local id = child.Image:match("%d+")
if id then foundid = id; break end
end
end
end
if foundid and FaceDatabase and FaceDatabase[tostring(foundid)] then
return FaceDatabase[tostring(foundid)]
end
local name = boxModel.Name:lower()
if name:match("divine") then return "DIVINE" end
if name:match("mythic") then return "MYTHIC" end
return "SECRET"
end
local function createBoxEsp(boxModel, rarity)
if not _G.BoxEspEnabled then return end
if EspContainer[boxModel] then return end
local color = RarityColors[rarity] or Color3.fromRGB(255, 255, 255)
local areaName = boxModel:GetAttribute("AssignedArea") or "Spawn"
local highlight = Instance.new("Highlight")
highlight.FillColor = color
highlight.FillTransparency = 0.5
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
local camera = game:GetService("Workspace").CurrentCamera
local tracer = Drawing.new("Line")
tracer.Visible = false
tracer.Color = Color3.fromRGB(0, 255, 200)
tracer.Thickness = 1.5
tracer.Transparency = 0.8
PlayerEspContainer[player] = {Highlight = highlight, Billboard = billboard, Label = label, Line = tracer}
end
local function updateAllEsp(root)
local camera = game:GetService("Workspace").CurrentCamera
if _G.BoxEspEnabled then
for box, esp in pairs(EspContainer) do
if box and box.Parent then
local boxPos = box:IsA("Model") and box:GetPivot().Position or box.Position
local dist = math.floor((root.Position - boxPos).Magnitude)
local rarity = getBoxRarity(box)
local areaName = box:GetAttribute("AssignedArea") or "Spawn"
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
local screenPos, onScreen = camera:WorldToViewportPoint(pRoot.Position)
if onScreen then
esp.Line.From = Vector2.new(camera.ViewportSize.X / 2, 0)
esp.Line.To = Vector2.new(screenPos.X, screenPos.Y)
esp.Line.Visible = true
else
esp.Line.Visible = false
end
else
if esp.Highlight then esp.Highlight:Destroy() end
if esp.Billboard then esp.Billboard:Destroy() end
if esp.Line then esp.Line:Destroy() end
PlayerEspContainer[player] = nil
end
end
for _, p in pairs(game:GetService("Players"):GetPlayers()) do
if p ~= game:GetService("Players").LocalPlayer and not PlayerEspContainer[p] and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
createPlayerEsp(p)
end
end
else
for _, esp in pairs(PlayerEspContainer) do
if esp.Line then esp.Line.Visible = false end
end
end
end
local function getActiveBatRadius()
local pPlayer = game:GetService("Players").LocalPlayer
local currentBat = pPlayer.Character and pPlayer.Character:FindFirstChildWhichIsA("Tool")
if currentBat and currentBat.Name:lower():match("bat") then
local batId = currentBat:GetAttribute("BatId") or currentBat.Name:lower()
if BatRadiusTable[batId] then return BatRadiusTable[batId] end
end
return 15.0
end
local function checkIsToolActiveInHand()
local pPlayer = game:GetService("Players").LocalPlayer
local tool = pPlayer.Character and pPlayer.Character:FindFirstChildWhichIsA("Tool")
if tool and tool.Name:lower():match("bat") then
return true
end
return false
end
local function drawBatAuraRing3D(root, camera)
if not _G.BatRangeCircleEnabled or not checkIsToolActiveInHand() then
for _, line in pairs(AuraCirclePoints) do line.Visible = false end
return
end
local radius = getActiveBatRadius()
local center = root.Position - Vector3.new(0, 2.5, 0)
local screenPoints = {}
local isPlayerInside = false
local pPlayer = game:GetService("Players").LocalPlayer
for _, player in pairs(game:GetService("Players"):GetPlayers()) do
if player ~= pPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
local dist = (root.Position - player.Character.HumanoidRootPart.Position).Magnitude
if dist <= radius then
isPlayerInside = true
break
end
end
end
local ringColor = isPlayerInside and Color3.fromRGB(120, 255, 120) or Color3.fromRGB(255, 50, 50)
for i = 1, MaxCirclePoints do
local angle = ((i - 1) / MaxCirclePoints) * math.pi * 2
local worldPoint = center + Vector3.new(math.cos(angle) * radius, 0, math.sin(angle) * radius)
local screenPos, onScreen = camera:WorldToViewportPoint(worldPoint)
table.insert(screenPoints, {Pos = Vector2.new(screenPos.X, screenPos.Y), OnScreen = onScreen})
end
for i = 1, MaxCirclePoints do
local p1 = screenPoints[i]
local p2 = screenPoints[(i % MaxCirclePoints) + 1]
local line = AuraCirclePoints[i]
if p1.OnScreen and p2.OnScreen then
line.From = p1.Pos
line.To = p2.Pos
line.Color = ringColor
line.Visible = true
else
line.Visible = false
end
end
end
local function forceEquipBatProcess()
local pPlayer = game:GetService("Players").LocalPlayer
if not pPlayer.Character then return end
local holdingTool = pPlayer.Character:FindFirstChildWhichIsA("Tool")
if holdingTool and holdingTool.Name:lower():match("bat") then return end
local targetBat = nil
if pPlayer:FindFirstChild("Backpack") then
for _, tool in pairs(pPlayer.Backpack:GetChildren()) do
if tool:IsA("Tool") and tool.Name:lower():match("bat") then
targetBat = tool
break
end
end
end
if targetBat then
targetBat.Parent = pPlayer.Character
end
end
local function assignBoxAreaPermanently(boxModel)
if boxModel:GetAttribute("AssignedArea") then return end
local unboxPrompt = boxModel:FindFirstChild("Unbox", true)
if unboxPrompt and unboxPrompt:IsA("ProximityPrompt") then
boxModel:SetAttribute("AssignedArea", "Spawn")
return
end
local boxPos = boxModel:IsA("Model") and boxModel:GetPivot().Position or boxModel.Position
local closestArea = "Spawn"
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
for _, box in pairs(BoxRuntime:GetChildren()) do assignBoxAreaPermanently(box) end
BoxRuntime.ChildAdded:Connect(function(child)
task.wait(0.1)
if child:IsDescendantOf(game:GetService("Workspace")) then assignBoxAreaPermanently(child) end
end)
end
local function processPlayerStealLogic()
if not BoxRuntime then return nil end
local localPlayer = game:GetService("Players").LocalPlayer
for _, player in pairs(game:GetService("Players"):GetPlayers()) do
if player ~= localPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
local char = player.Character
local isCarrying = false
for _, child in pairs(char:GetChildren()) do
if child.Name == "CarryWeld" or (child:IsA("Weld") or child:IsA("WeldConstraint")) and child.Name:match("Carry") then
isCarrying = true
break
end
end
if isCarrying then
local foundTargetBox = nil
local shortestD = math.huge
for _, box in pairs(BoxRuntime:GetChildren()) do
local boxPos = box:IsA("Model") and box:GetPivot().Position or box.Position
local distanceToPlayer = (char.HumanoidRootPart.Position - boxPos).Magnitude
if distanceToPlayer < shortestD and distanceToPlayer <= 10.0 then
shortestD = distanceToPlayer
foundTargetBox = box
end
end
if foundTargetBox then
local unboxPrompt = foundTargetBox:FindFirstChild("Unbox", true)
if not unboxPrompt then
local rarity = getBoxRarity(foundTargetBox)
if _G.AllowedRarities[rarity] then
if not IgnoredBoxes[foundTargetBox] then
return char.HumanoidRootPart, foundTargetBox
end
end
end
end
end
end
end
return nil, nil
end
local function getBestBoxChoice()
local localPlayer = game:GetService("Players").LocalPlayer
local character = localPlayer.Character
local root = character and character:FindFirstChild("HumanoidRootPart")
if not root or not BoxRuntime then return nil end
local currentActiveTarget = nil
local rootTarget, connectedBox = processPlayerStealLogic()
if rootTarget and connectedBox then
currentActiveTarget = connectedBox
CurrentActiveTargetPlayer = rootTarget
CurrentActiveTargetBox = nil
end
if not currentActiveTarget then
CurrentActiveTargetPlayer = nil
if CurrentActiveTargetBox and CurrentActiveTargetBox.Parent and not IgnoredBoxes[CurrentActiveTargetBox] then
local unboxCheck = CurrentActiveTargetBox:FindFirstChild("Unbox", true)
if not unboxCheck then
currentActiveTarget = CurrentActiveTargetBox
end
end
end
if not currentActiveTarget then
local bestBox = nil
local shortestDistance = math.huge
for _, obj in pairs(BoxRuntime:GetChildren()) do
if not IgnoredBoxes[obj] then
local unboxPrompt = obj:FindFirstChild("Unbox", true)
if not unboxPrompt then
assignBoxAreaPermanently(obj)
local assignedArea = obj:GetAttribute("AssignedArea") or "Spawn"
if assignedArea ~= "Spawn" and _G.AllowedAreas[assignedArea] then
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
CurrentActiveTargetBox = bestBox
currentActiveTarget = bestBox
end
if currentActiveTarget then
if currentActiveTarget ~= LastTargetObject then
LastTargetObject = currentActiveTarget
TargetLockTime = os.clock()
else
if os.clock() - TargetLockTime >= 30.0 then
IgnoredBoxes[currentActiveTarget] = true
CurrentActiveTargetBox = nil
CurrentActiveTargetPlayer = nil
LastTargetObject = nil
return nil
end
end
else
LastTargetObject = nil
end
return CurrentActiveTargetPlayer or currentActiveTarget
end
local function isCarryingBox()
if game:GetService("Workspace"):FindFirstChild("BoxRuntime") then
for _, box in pairs(game:GetService("Workspace").BoxRuntime:GetChildren()) do
if box:FindFirstChild("CarryWeld", true) then
local weld = box:FindFirstChild("CarryWeld", true)
local char = game:GetService("Players").LocalPlayer.Character
if char and (weld.Part0 and weld.Part0:IsDescendantOf(char) or weld.Part1 and weld.Part1:IsDescendantOf(char)) then
return true
end
end
end
end
local character = game:GetService("Players").LocalPlayer.Character
if character then
for _, child in pairs(character:GetChildren()) do
if child.Name == "CarryWeld" or (child:IsA("WeldConstraint") or child:IsA("Weld")) and child.Name:match("Carry") then
return true
end
end
end
return false
end
local function performBatAuraTick(root)
if not _G.BatAuraEnabled then return end
if os.clock() - LastSwingTime < 1.45 then return end
local pPlayer = game:GetService("Players").LocalPlayer
local currentBat = nil
if pPlayer.Character and pPlayer.Character:FindFirstChildWhichIsA("Tool") then
local tool = pPlayer.Character:FindFirstChildWhichIsA("Tool")
if tool and tool.Name:lower():match("bat") then currentBat = tool end
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
local attackRadius = getActiveBatRadius()
local isPlayerNearby = false
for _, player in pairs(game:GetService("Players"):GetPlayers()) do
if player ~= pPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
local dist = (root.Position - player.Character.HumanoidRootPart.Position).Magnitude
if dist <= attackRadius then isPlayerNearby = true; break end
end
end
if isPlayerNearby then
currentBat:Activate()
LastSwingTime = os.clock()
end
end
local function getSteeringAdjustedPosition(currentPos, targetPos, currentSpeed, forceZ)
local finalTarget = targetPos
if forceZ then
finalTarget = Vector3.new(targetPos.X, targetPos.Y, -24)
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
local finalDirection = (desiredDirection + avoidanceForce).Unit
local stepMultiplier = math.max(currentSpeed * 0.45, 14.0)
return currentPos + (finalDirection * stepMultiplier)
end
local function clearAllHazardOutlines()
for obj, highlight in pairs(HazardHighlights) do
if highlight then highlight:Destroy() end
end
table.clear(HazardHighlights)
end
local function outlineHazardObject(instance)
if HazardHighlights[instance] then return end
local highlight = Instance.new("Highlight")
highlight.FillTransparency = 1
highlight.OutlineColor = Color3.fromRGB(255, 30, 30)
highlight.OutlineTransparency = 0.2
highlight.Adornee = instance
highlight.Parent = ScreenGui
HazardHighlights[instance] = highlight
end
task.spawn(function()
local LocalPlayer = game:GetService("Players").LocalPlayer
LocalPlayer.Idled:Connect(function()
if _G.AntiAfkEnabled then
local virtualUser = game:GetService("VirtualUser")
virtualUser:CaptureController()
virtualUser:ClickButton2(Vector2.new(0,0))
end
end)
end)
task.spawn(function()
while true do
task.wait(1.0)
if game:GetService("Players").LocalPlayer.Character then
local character = game:GetService("Players").LocalPlayer.Character
local root = character and character:FindFirstChild("HumanoidRootPart")
if root and (_G.AutoWalkFarm or _G.FarmV2Enabled) then
local diffX = math.abs(root.Position.X - LastCheckPosition.X)
local diffZ = math.abs(root.Position.Z - LastCheckPosition.Z)
if diffX < 0.5 and diffZ < 0.5 then
AdminStuckCounter = AdminStuckCounter + 1
if AdminStuckCounter >= 5 then
if _G.FarmV2Enabled or _G.AutoWalkFarm then
root.CFrame = CFrame.new(root.Position.X, root.Position.Y + 1.0, -24)
else
if math.abs(root.Position.X - TreadmillPosition.X) <= 60.0 then
root.CFrame = root.CFrame * CFrame.new(0, 0, 12.0)
end
end
AdminStuckCounter = 0
end
else
AdminStuckCounter = 0
end
LastCheckPosition = root.Position
end
end
end
end)
task.spawn(function()
local Camera = game:GetService("Workspace").CurrentCamera
while true do
task.wait(0.03)
if game:GetService("Players").LocalPlayer.Character then
local character = game:GetService("Players").LocalPlayer.Character
local root = character and character:FindFirstChild("HumanoidRootPart")
local humanoid = character and character:FindFirstChildOfClass("Humanoid")
if root and humanoid and humanoid.Health > 0 then
local currentlyCarrying = isCarryingBox()
local currentSpeed = humanoid.WalkSpeed
if _G.EquipBatAlways then
forceEquipBatProcess()
end
performBatAuraTick(root)
updateAllEsp(root)
drawBatAuraRing3D(root, Camera)
if (_G.AutoWalkFarm or _G.FarmV2Enabled) then
local shouldEvade = false
clearAllHazardOutlines()
local hazardsFolder = game:GetService("Workspace"):FindFirstChild("Hazards")
if hazardsFolder and hazardsFolder:FindFirstChild("Lava") then
for _, lavaChild in pairs(hazardsFolder.Lava:GetChildren()) do
if lavaChild:IsA("BasePart") then
local flatLavaPos = Vector3.new(lavaChild.Position.X, root.Position.Y, lavaChild.Position.Z)
local dist = (root.Position - flatLavaPos).Magnitude
if dist <= _G.V2EvadeRadius then
outlineHazardObject(lavaChild)
if dist <= (_G.V2EvadeRadius * 0.8) then shouldEvade = true end
end
end
end
end
local landmineFolder = game:GetService("Workspace"):FindFirstChild("LandmineRuntime")
if landmineFolder then
for _, mineChild in pairs(landmineFolder:GetChildren()) do
if mineChild:IsA("BasePart") or mineChild:IsA("Model") then
local minePos = mineChild:IsA("Model") and mineChild:GetPivot().Position or mineChild.Position
local flatMinePos = Vector3.new(minePos.X, root.Position.Y, minePos.Z)
local dist = (root.Position - flatMinePos).Magnitude
if dist <= _G.V2EvadeRadius then
outlineHazardObject(mineChild)
if dist <= (_G.V2EvadeRadius * 0.8) then shouldEvade = true end
end
end
end
end
if shouldEvade then
root.CFrame = root.CFrame * CFrame.new(0, _G.V2EvadeHeight, 0)
task.wait(0.20)
end
else
clearAllHazardOutlines()
end
if _G.AutoGiftEnabled and (os.clock() - LastGiftCheck >= 15.0) then
LastGiftCheck = os.clock()
local remotes = game:GetService("ReplicatedStorage"):FindFirstChild("Remotes")
if remotes and remotes:FindFirstChild("ClaimFreeGift") then
remotes.ClaimFreeGift:FireServer()
end
end
if _G.BoxEspEnabled then
for _, box in pairs(BoxRuntime:GetChildren()) do if not EspContainer[box] then createBoxEsp(box, getBoxRarity(box)) end end
end
if _G.AutoWalkFarm or _G.FarmV2Enabled then
if InternalCarryState == true and currentlyCarrying == false then
root.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
table.clear(IgnoredBoxes)
CurrentActiveTargetBox = nil
end
InternalCarryState = currentlyCarrying
if currentlyCarrying then
TargetTracer.Visible = false
local baseTarget = TreadmillPosition
if _G.FarmV2Enabled then
baseTarget = Vector3.new(TreadmillPosition.X, TreadmillPosition.Y, -24)
root.CFrame = CFrame.new(root.Position.X, root.Position.Y, -24) * (root.CFrame - root.Position)
end
if math.abs(root.Position.X - TreadmillPosition.X) <= 8.0 then
humanoid:MoveTo(root.Position)
root.AssemblyLinearVelocity = Vector3.zero
root.Anchored = true
task.wait(0.6)
root.Anchored = false
table.clear(IgnoredBoxes)
CurrentActiveTargetBox = nil
else
local adjustedPos = getSteeringAdjustedPosition(root.Position, baseTarget, currentSpeed, _G.FarmV2Enabled)
humanoid:MoveTo(adjustedPos)
end
else
local targetChoice = getBestBoxChoice()
if not targetChoice then
TargetTracer.Visible = false
if (root.Position - TreadmillPosition).Magnitude > 6 then
local adjustedPos = getSteeringAdjustedPosition(root.Position, TreadmillPosition, currentSpeed, false)
humanoid:MoveTo(adjustedPos)
end
else
local targetPos = targetChoice:IsA("Model") and targetChoice:GetPivot().Position or targetChoice.Position
if _G.FarmV2Enabled then
local screenStart, onScreenStart = Camera:WorldToViewportPoint(root.Position)
local screenEnd, onScreenEnd = Camera:WorldToViewportPoint(targetPos)
if onScreenStart and onScreenEnd then
TargetTracer.From = Vector2.new(screenStart.X, screenStart.Y)
TargetTracer.To = Vector2.new(screenEnd.X, screenEnd.Y)
TargetTracer.Visible = true
else
TargetTracer.Visible = false
end
else
TargetTracer.Visible = false
end
if CurrentActiveTargetPlayer then
humanoid:MoveTo(getSteeringAdjustedPosition(root.Position, targetPos, currentSpeed, false))
else
local prompt = targetChoice:FindFirstChild("Steal", true) or targetChoice:FindFirstChildOfClass("ProximityPrompt")
if prompt then
if (root.Position - targetPos).Magnitude <= 14.0 then
TargetTracer.Visible = false
IgnoredBoxes[targetChoice] = true
local lastPressedBox = targetChoice
root.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
root.Anchored = true
local activeCheckStart = os.clock()
while not isCarryingBox() and (os.clock() - activeCheckStart < 1.5) and (_G.AutoWalkFarm or _G.FarmV2Enabled) do
fireproximityprompt(prompt)
task.wait(0.05)
end
root.Anchored = false
CurrentActiveTargetBox = nil
task.spawn(function()
task.wait(0.8)
if lastPressedBox and IgnoredBoxes[lastPressedBox] then
IgnoredBoxes[lastPressedBox] = nil
end
end)
if isCarryingBox() then
local returnTarget = TreadmillPosition
if _G.FarmV2Enabled then
returnTarget = Vector3.new(TreadmillPosition.X, TreadmillPosition.Y, -24)
root.CFrame = CFrame.new(root.Position.X, root.Position.Y, -24) * (root.CFrame - root.Position)
end
humanoid:MoveTo(getSteeringAdjustedPosition(root.Position, returnTarget, currentSpeed, false))
else
task.wait(0.1)
end
else
humanoid:MoveTo(getSteeringAdjustedPosition(root.Position, targetPos, currentSpeed, false))
end
else
humanoid:MoveTo(getSteeringAdjustedPosition(root.Position, targetPos, currentSpeed, false))
end
end
end
end
else
TargetTracer.Visible = false
clearAllHazardOutlines()
end
end
end
end
end)
print("Gerry Hub - Ground Engine Loaded.")
