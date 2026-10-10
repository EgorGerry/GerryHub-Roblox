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
_G.DecorationsCleared = false
_G.BatAuraEnabled = false
_G.BoxEspEnabled = false
local TreadmillPosition = Vector3.new(137, 2.92, -112)
local IgnoredBoxes = {}
local DecorativeObjects = {}
local EspContainer = {}
local InternalCarryState = false
local LastSwingTime = os.clock()
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
Frame.Size = UDim2.new(0, 340, 0, 460)
Frame.Position = UDim2.new(0.05, 0, 0.2, 0)
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
Title.Text = "  Master Hub - Full 15 Areas UI"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 18
Title.Parent = Frame
local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 8)
TitleCorner.Parent = Title
local ToggleButton = Instance.new("TextButton")
ToggleButton.Name = "ToggleFarmButton"
ToggleButton.Size = UDim2.new(0.18, 0, 0, 35)
ToggleButton.Position = UDim2.new(0.02, 0, 0, 50)
ToggleButton.BackgroundColor3 = Color3.fromRGB(170, 50, 50)
ToggleButton.Text = "Farm: OFF"
ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleButton.Font = Enum.Font.SourceSansBold
ToggleButton.TextSize = 11
ToggleButton.Parent = Frame
local ButtonCorner = Instance.new("UICorner")
ButtonCorner.CornerRadius = UDim.new(0, 6)
ButtonCorner.Parent = ToggleButton
local BatButton = Instance.new("TextButton")
BatButton.Name = "ToggleBatButton"
BatButton.Size = UDim2.new(0.22, 0, 0, 35)
BatButton.Position = UDim2.new(0.22, 0, 0, 50)
BatButton.BackgroundColor3 = Color3.fromRGB(80, 80, 85)
BatButton.Text = "Bat Aura: OFF"
BatButton.TextColor3 = Color3.fromRGB(255, 255, 255)
BatButton.Font = Enum.Font.SourceSansBold
BatButton.TextSize = 11
BatButton.Parent = Frame
local BatCorner = Instance.new("UICorner")
BatCorner.CornerRadius = UDim.new(0, 6)
BatCorner.Parent = BatButton
local EspButton = Instance.new("TextButton")
EspButton.Name = "ToggleEspButton"
EspButton.Size = UDim2.new(0.20, 0, 0, 35)
EspButton.Position = UDim2.new(0.46, 0, 0, 50)
EspButton.BackgroundColor3 = Color3.fromRGB(80, 80, 85)
EspButton.Text = "Box ESP: OFF"
EspButton.TextColor3 = Color3.fromRGB(255, 255, 255)
EspButton.Font = Enum.Font.SourceSansBold
EspButton.TextSize = 11
EspButton.Parent = Frame
local EspCorner = Instance.new("UICorner")
EspCorner.CornerRadius = UDim.new(0, 6)
EspCorner.Parent = EspButton
local DecoButton = Instance.new("TextButton")
DecoButton.Name = "DecoClearButton"
DecoButton.Size = UDim2.new(0.18, 0, 0, 35)
DecoButton.Position = UDim2.new(0.68, 0, 0, 50)
DecoButton.BackgroundColor3 = Color3.fromRGB(150, 80, 0)
DecoButton.Text = "Clear Deco"
DecoButton.TextColor3 = Color3.fromRGB(255, 255, 255)
DecoButton.Font = Enum.Font.SourceSansBold
DecoButton.TextSize = 11
DecoButton.Parent = Frame
local DecoCorner = Instance.new("UICorner")
DecoCorner.CornerRadius = UDim.new(0, 6)
DecoCorner.Parent = DecoButton
local PlayButton = Instance.new("TextButton")
PlayButton.Name = "ServerHopButton"
PlayButton.Size = UDim2.new(0.11, 0, 0, 35)
PlayButton.Position = UDim2.new(0.87, 0, 0, 50)
PlayButton.BackgroundColor3 = Color3.fromRGB(130, 50, 160)
PlayButton.Text = "Hop"
PlayButton.TextColor3 = Color3.fromRGB(255, 255, 255)
PlayButton.Font = Enum.Font.SourceSansBold
PlayButton.TextSize = 11
PlayButton.Parent = Frame
local HopCorner = Instance.new("UICorner")
HopCorner.CornerRadius = UDim.new(0, 6)
HopCorner.Parent = PlayButton
local Scroll = Instance.new("ScrollingFrame")
Scroll.Name = "SettingsScroll"
Scroll.Size = UDim2.new(0.92, 0, 0, 350)
Scroll.Position = UDim2.new(0.04, 0, 0, 95)
Scroll.BackgroundTransparency = 1
Scroll.BorderSizePixel = 0
Scroll.CanvasSize = UDim2.new(0, 0, 0, 820)
Scroll.ScrollBarThickness = 4
Scroll.Parent = Frame
local UIList = Instance.new("UIListLayout")
UIList.Padding = UDim.new(0, 6)
UIList.SortOrder = Enum.SortOrder.LayoutOrder
UIList.Parent = Scroll
local function removeAllBoxEsp()
for box, esp in pairs(EspContainer) do
if esp.Highlight then
esp.Highlight:Destroy()
end
if esp.Billboard then
esp.Billboard:Destroy()
end
end
table.clear(EspContainer)
end
ToggleButton.MouseButton1Click:Connect(function()
_G.AutoWalkFarm = not _G.AutoWalkFarm
if _G.AutoWalkFarm then
ToggleButton.BackgroundColor3 = Color3.fromRGB(0, 170, 100)
ToggleButton.Text = "Farm: ON"
else
ToggleButton.BackgroundColor3 = Color3.fromRGB(170, 50, 50)
ToggleButton.Text = "Farm: OFF"
end
end)
BatButton.MouseButton1Click:Connect(function()
_G.BatAuraEnabled = not _G.BatAuraEnabled
if _G.BatAuraEnabled then
BatButton.BackgroundColor3 = Color3.fromRGB(0, 120, 170)
BatButton.Text = "Bat Aura: ON"
else
BatButton.BackgroundColor3 = Color3.fromRGB(80, 80, 85)
BatButton.Text = "Bat Aura: OFF"
end
end)
EspButton.MouseButton1Click:Connect(function()
_G.BoxEspEnabled = not _G.BoxEspEnabled
if _G.BoxEspEnabled then
EspButton.BackgroundColor3 = Color3.fromRGB(0, 140, 90)
EspButton.Text = "Box ESP: ON"
else
EspButton.BackgroundColor3 = Color3.fromRGB(80, 80, 85)
EspButton.Text = "Box ESP: OFF"
removeAllBoxEsp()
end
end)
DecoButton.MouseButton1Click:Connect(function()
_G.DecorationsCleared = not _G.DecorationsCleared
local folder = game:GetService("Workspace"):FindFirstChild("Decorations")
if folder then
if _G.DecorationsCleared then
DecoButton.BackgroundColor3 = Color3.fromRGB(50, 120, 170)
DecoButton.Text = "Restore Deco"
for _, obj in pairs(folder:GetDescendants()) do
if obj:IsA("BasePart") then
DecorativeObjects[obj] = obj.CFrame
obj.CFrame = obj.CFrame - Vector3.new(0, 300, 0)
end
end
else
DecoButton.BackgroundColor3 = Color3.fromRGB(150, 80, 0)
DecoButton.Text = "Clear Deco"
for obj, originalCFrame in pairs(DecorativeObjects) do
if obj and obj.Parent then
obj.CFrame = originalCFrame
end
end
table.clear(DecorativeObjects)
end
end
end)
PlayButton.MouseButton1Click:Connect(function()
loadstring(game:HttpGet("scriptblox.com"))()
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
if id then
foundid = id
break
end
end
elseif child:IsA("ImageLabel") then
if child.Image ~= "" then
local id = child.Image:match("%d+")
if id then
foundid = id
break
end
end
end
end
local name = boxModel.Name:lower()
if foundid and FaceDatabase[foundid] then
return FaceDatabase[foundid]
end
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
highlight.Name = "BoxEspHighlight"
highlight.FillColor = color
highlight.FillTransparency = 0.5
highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
highlight.OutlineTransparency = 0.2
highlight.Adornee = boxModel
highlight.Parent = ScreenGui
local billboard = Instance.new("BillboardGui")
billboard.Name = "BoxEspBillboard"
billboard.Size = UDim2.new(0, 160, 0, 45)
billboard.AlwaysOnTop = true
billboard.ExtentsOffset = Vector3.new(0, 2.5, 0)
local targetPart = nil
if boxModel:IsA("Model") then
targetPart = boxModel.PrimaryPart or boxModel:FindFirstChildWhichIsA("BasePart", true)
else
targetPart = boxModel
end
if not targetPart then return end
billboard.Adornee = targetPart
billboard.Parent = ScreenGui
local label = Instance.new("TextLabel")
label.Size = UDim2.new(1, 0, 1, 0)
label.BackgroundTransparency = 1
label.TextColor3 = color
label.TextStrokeTransparency = 0
label.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
label.Font = Enum.Font.SourceSansBold
label.TextSize = 13
label.Text = rarity .. " [" .. areaName .. "]"
label.Parent = billboard
EspContainer[boxModel] = {Highlight = highlight, Billboard = billboard, Label = label}
end
local function updateEspDistances(root)
if not _G.BoxEspEnabled then return end
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
if _G.BoxEspEnabled then
createBoxEsp(boxModel, rarity)
end
end
local BoxRuntime = game:GetService("Workspace"):FindFirstChild("BoxRuntime")
if BoxRuntime then
for _, box in pairs(BoxRuntime:GetChildren()) do
assignBoxAreaPermanently(box)
end
BoxRuntime.ChildAdded:Connect(function(child)
task.wait(0.1)
if child:IsDescendantOf(game:GetService("Workspace")) then
assignBoxAreaPermanently(child)
end
end)
end
local function getBestBoxChoice()
local character = game:GetService("Players").LocalPlayer.Character
local root = character and character:FindFirstChild("HumanoidRootPart")
if not root or not BoxRuntime then
return nil
end
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
local carryWeld = box:FindFirstChild("CarryWeld", true)
if carryWeld then
return true
end
end
end
local character = game:GetService("Players").LocalPlayer.Character
if character then
for _, child in pairs(character:GetChildren()) do
if child.Name == "CarryWeld" or child:IsA("WeldConstraint") and child.Name:match("Carry") then
return true
end
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
if tool.Name:lower():match("bat") then
currentBat = tool
end
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
if batName:match("orange") or batName:match("dungeon") or batName:match("coral") or batName:match("void") then
attackRadius = 15.0
elseif batName:match("marble") or batName:match("shard") or batName:match("lava") or batName:match("sakura") then
attackRadius = 18.0
elseif batName:match("galaxy") or batName:match("candy") or batName:match("moon") or batName:match("prism") then
attackRadius = 21.0
end
local isPlayerNearby = false
for _, player in pairs(game:GetService("Players"):GetPlayers()) do
if player ~= pPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
local pRoot = player.Character.HumanoidRootPart
local dist = (root.Position - pRoot.Position).Magnitude
if dist <= attackRadius then
isPlayerNearby = true
break
end
end
end
if isPlayerNearby then
currentBat:Activate()
LastSwingTime = os.clock()
end
end
local function getSteeringAdjustedPosition(currentPos, targetPos, currentSpeed)
local desiredDirection = (targetPos - currentPos).Unit
local avoidanceForce = Vector3.new(0, 0, 0)
local hazardsFolder = game:GetService("Workspace"):FindFirstChild("Hazards")
if hazardsFolder then
for _, hazardChild in pairs(hazardsFolder:GetChildren()) do
for _, part in pairs(hazardChild:GetDescendants()) do
if part:IsA("BasePart") then
local partPos = part.Position
local distance = (currentPos - partPos).Magnitude
local detectionRadius = (part.Size.Magnitude * 0.45) + 3.5
if distance < detectionRadius then
local pushDirection = (currentPos - partPos).Unit
local forceIntensity = (detectionRadius - distance) / detectionRadius
avoidanceForce = avoidanceForce + (pushDirection * forceIntensity * 5.8)
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
if _G.BoxEspEnabled then
updateEspDistances(root)
for _, box in pairs(BoxRuntime:GetChildren()) do
if not EspContainer[box] then
local rarity = getBoxRarity(box)
createBoxEsp(box, rarity)
end
end
end
if _G.AutoWalkFarm then
if InternalCarryState == true and currentlyCarrying == false then
local distToTreadmill = (root.Position - TreadmillPosition).Magnitude
if distToTreadmill > 10.0 then
table.clear(IgnoredBoxes)
end
end
InternalCarryState = currentlyCarrying
if currentlyCarrying then
local dist = (root.Position - TreadmillPosition).Magnitude
if dist <= 6.0 then
root.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
root.Anchored = true
task.wait(0.5)
root.Anchored = false
table.clear(IgnoredBoxes)
else
local adjustedPos = getSteeringAdjustedPosition(root.Position, TreadmillPosition, currentSpeed)
humanoid:MoveTo(adjustedPos)
end
else
local targetBox = getBestBoxChoice()
if not targetBox then
if (root.Position - TreadmillPosition).Magnitude > 6 then
local adjustedPos = getSteeringAdjustedPosition(root.Position, TreadmillPosition, currentSpeed)
humanoid:MoveTo(adjustedPos)
end
else
local prompt = targetBox:FindFirstChild("Steal", true) or targetBox:FindFirstChildOfClass("ProximityPrompt")
local targetPos = targetBox:IsA("Model") and targetBox:GetPivot().Position or targetBox.Position
local distanceToBox = (root.Position - targetPos).Magnitude
if distanceToBox <= 5.0 then
IgnoredBoxes[targetBox] = true
root.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
root.Anchored = true
if prompt then
fireproximityprompt(prompt)
end
task.wait(1.0)
root.Anchored = false
if isCarryingBox() then
local adjustedPos = getSteeringAdjustedPosition(root.Position, TreadmillPosition, currentSpeed)
humanoid:MoveTo(adjustedPos)
else
table.clear(IgnoredBoxes)
end
else
local adjustedPos = getSteeringAdjustedPosition(root.Position, targetPos, currentSpeed)
humanoid:MoveTo(adjustedPos)
end
end
end
end
end
end
end
end)
print("[Master Hub]: Интеграция Area15 завершена успешно. Скрипт полностью готов!")
