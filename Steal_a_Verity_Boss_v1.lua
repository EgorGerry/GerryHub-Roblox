if not game:IsLoaded() then
game.Loaded:Wait()
end
_G.BossFarmEnabled = false
_G.BossAuraEnabled = false
_G.BossBoxEspEnabled = false
_G.BossPlayerDamageEnabled = false
local TargetRaritiesOrder = {"SOVEREIGN", "DIVINE", "SECRET", "MYTHIC", "LEGENDARY", "EPIC", "RARE", "UNCOMMON", "COMMON"}
local SafeBossDropPosition = Vector3.new(-15, 3, -12)
local LastSwingTime = os.clock()
local IsStealingBossMode = false
local EspContainer = {}
local FaceDatabase = {
["139657139910728"] = "COMMON",
["98602631774718"]  = "UNCOMMON",
["93383697407654"]  = "RARE",
["114035647231925"] = "EPIC",
["133434398242702"] = "LEGENDARY",
["131715145031077"] = "MYTHIC",
["108908582036844"] = "SECRET"
}
local RarityColors = {
["COMMON"]    = Color3.fromRGB(150, 150, 160),
["UNCOMMON"]  = Color3.fromRGB(50, 200, 50),
["RARE"]      = Color3.fromRGB(50, 150, 255),
["EPIC"]      = Color3.fromRGB(0, 50, 200),
["LEGENDARY"] = Color3.fromRGB(150, 0, 255),
["MYTHIC"]    = Color3.fromRGB(255, 0, 50),
["SECRET"]    = Color3.fromRGB(255, 0, 150),
["DIVINE"]    = Color3.fromRGB(255, 200, 75),
["SOVEREIGN"] = Color3.fromRGB(0, 190, 230)
}
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "BossHubGui"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = game:GetService("CoreGui")
local Frame = Instance.new("Frame")
Frame.Name = "MainFrame"
Frame.Size = UDim2.new(0, 320, 0, 330)
Frame.Position = UDim2.new(0.05, 0, 0.2, 0)
Frame.BackgroundColor3 = Color3.fromRGB(30, 20, 35)
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
Title.BackgroundColor3 = Color3.fromRGB(45, 30, 55)
Title.Text = "  GerryHub | Boss Event Edition"
Title.TextColor3 = Color3.fromRGB(255, 230, 255)
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
MinimizeButton.BackgroundColor3 = Color3.fromRGB(60, 40, 75)
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
PlayButton.BackgroundColor3 = Color3.fromRGB(150, 50, 120)
PlayButton.Text = ">"
PlayButton.TextColor3 = Color3.fromRGB(255, 255, 255)
PlayButton.Font = Enum.Font.SourceSansBold
PlayButton.TextSize = 14
PlayButton.Parent = Frame
local HopCorner = Instance.new("UICorner")
HopCorner.CornerRadius = UDim.new(0, 6)
HopCorner.Parent = PlayButton
local Scroll = Instance.new("ScrollingFrame")
Scroll.Name = "SettingsScroll"
Scroll.Size = UDim2.new(0.94, 0, 0, 270)
Scroll.Position = UDim2.new(0.03, 0, 0, 50)
Scroll.BackgroundTransparency = 1
Scroll.BorderSizePixel = 0
Scroll.CanvasSize = UDim2.new(0, 0, 0, 320)
Scroll.ScrollBarThickness = 4
Scroll.Parent = Frame
local UIList = Instance.new("UIListLayout")
UIList.Padding = UDim.new(0, 6)
UIList.SortOrder = Enum.SortOrder.LayoutOrder
UIList.Parent = Scroll
local isMinimized = false
MinimizeButton.MouseButton1Click:Connect(function()
isMinimized = not isMinimized
if isMinimized then
Frame.Size = UDim2.new(0, 320, 0, 40)
Scroll.Visible = false
MinimizeButton.Text = "+"
else
Frame.Size = UDim2.new(0, 320, 0, 330)
Scroll.Visible = true
MinimizeButton.Text = "_"
end
end)
PlayButton.MouseButton1Click:Connect(function()
loadstring(game:HttpGet("https://scriptblox.com/raw/Universal-Script-Universal-server-hop-script-130449"))()
end)
local function updateButtonVisual(button, name, state)
if state then
button.BackgroundColor3 = Color3.fromRGB(90, 45, 120)
button.Text = name .. " : ON"
else
button.BackgroundColor3 = Color3.fromRGB(45, 35, 50)
button.Text = name .. " : OFF"
end
end
local ToggleBoxFarmBtn
local ToggleBossAuraBtn
local TogglePlayerAuraBtn
local function createToggle(name, initialValue, callback, layoutOrder)
local Button = Instance.new("TextButton")
Button.Size = UDim2.new(1, -5, 0, 35)
Button.LayoutOrder = layoutOrder
updateButtonVisual(Button, name, initialValue)
Button.TextColor3 = Color3.fromRGB(240, 220, 250)
Button.Font = Enum.Font.SourceSansBold
Button.TextSize = 14
Button.Parent = Scroll
local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(0, 5)
Corner.Parent = Button
Button.MouseButton1Click:Connect(function()
local newValue = callback()
updateButtonVisual(Button, name, newValue)
end)
return Button
end
local currentLayout = 1
ToggleBoxFarmBtn = createToggle("Boss Fast Farm (TP Steal)", _G.BossFarmEnabled, function()
_G.BossFarmEnabled = not _G.BossFarmEnabled
return _G.BossFarmEnabled
end, currentLayout)
currentLayout = currentLayout + 1
ToggleBossAuraBtn = createToggle("Boss Hitbox Aura", _G.BossAuraEnabled, function()
_G.BossAuraEnabled = not _G.BossAuraEnabled
return _G.BossAuraEnabled
end, currentLayout)
currentLayout = currentLayout + 1
TogglePlayerAuraBtn = createToggle("Bat Aura (Anti-Players)", _G.BossPlayerDamageEnabled, function()
_G.BossPlayerDamageEnabled = not _G.BossPlayerDamageEnabled
return _G.BossPlayerDamageEnabled
end, currentLayout)
currentLayout = currentLayout + 1
createToggle("Box ESP Mod", _G.BossBoxEspEnabled, function()
_G.BossBoxEspEnabled = not _G.BossBoxEspEnabled
if not _G.BossBoxEspEnabled then
for box, esp in pairs(EspContainer) do
if esp.Highlight then esp.Highlight:Destroy() end
if esp.Billboard then esp.Billboard:Destroy() end
end
table.clear(EspContainer)
end
return _G.BossBoxEspEnabled
end, currentLayout)
currentLayout = currentLayout + 1
local DecoButton = Instance.new("TextButton")
DecoButton.Size = UDim2.new(1, -5, 0, 35)
DecoButton.LayoutOrder = currentLayout
DecoButton.BackgroundColor3 = Color3.fromRGB(150, 40, 40)
DecoButton.Text = "DelDec (Permanent Destroy)"
DecoButton.TextColor3 = Color3.fromRGB(255, 255, 255)
DecoButton.Font = Enum.Font.SourceSansBold
DecoButton.TextSize = 13
DecoButton.Parent = Scroll
local DecoCorner = Instance.new("UICorner")
DecoCorner.CornerRadius = UDim.new(0, 5)
DecoCorner.Parent = DecoButton
DecoButton.MouseButton1Click:Connect(function()
local dec = game:GetService("Workspace"):FindFirstChild("Decorations")
if dec then dec:Destroy() end
DecoButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
DecoButton.Text = "Decorations Purged"
DecoButton.Active = false
end)
currentLayout = currentLayout + 1
local ExitBossButton = Instance.new("TextButton")
ExitBossButton.Size = UDim2.new(1, -5, 0, 35)
ExitBossButton.LayoutOrder = currentLayout
ExitBossButton.BackgroundColor3 = Color3.fromRGB(50, 130, 80)
ExitBossButton.Text = "Exit Boss Room"
ExitBossButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ExitBossButton.Font = Enum.Font.SourceSansBold
ExitBossButton.TextSize = 13
ExitBossButton.Parent = Scroll
local ExitCorner = Instance.new("UICorner")
ExitCorner.CornerRadius = UDim.new(0, 5)
ExitCorner.Parent = ExitBossButton
ExitBossButton.MouseButton1Click:Connect(function()
_G.BossFarmEnabled = false
_G.BossAuraEnabled = false
_G.BossBoxEspEnabled = false
_G.BossPlayerDamageEnabled = false
updateButtonVisual(ToggleBoxFarmBtn, "Boss Fast Farm (TP Steal)", false)
updateButtonVisual(ToggleBossAuraBtn, "Boss Hitbox Aura", false)
updateButtonVisual(TogglePlayerAuraBtn, "Bat Aura (Anti-Players)", false)
for box, esp in pairs(EspContainer) do
if esp.Highlight then esp.Highlight:Destroy() end
if esp.Billboard then esp.Billboard:Destroy() end
end
table.clear(EspContainer)
local character = game:GetService("Players").LocalPlayer.Character
local root = character and character:FindFirstChild("HumanoidRootPart")
if root then
root.AssemblyLinearVelocity = Vector3.zero
root.CFrame = CFrame.new(SafeBossDropPosition)
end
local exitRemote = game:GetService("ReplicatedStorage"):FindFirstChild("Remotes") and game:GetService("ReplicatedStorage").Remotes:FindFirstChild("NewBoss_Roblox")
if exitRemote and exitRemote:IsA("RemoteEvent") then
exitRemote:FireServer()
print("GerryHub | Exit Boss Room Triggered.")
end
end)
local function getBoxRarity(boxModel)
if boxModel:FindFirstChild("Ornament", true) or boxModel.Name:lower():match("king") then return "SOVEREIGN" end
if boxModel:FindFirstChild("Wings", true) then return "DIVINE" end
local foundid = nil
for _, child in pairs(boxModel:GetDescendants()) do
if child:IsA("Decal") or child:IsA("Texture") then
if child.Texture ~= "" then local id = child.Texture:match("%d+"); if id then foundid = id; break end end
elseif child:IsA("ImageLabel") then
if child.Image ~= "" then local id = child.Image:match("%d+"); if id then foundid = id; break end end
end
end
if foundid and FaceDatabase[tostring(foundid)] then return FaceDatabase[tostring(foundid)] end
local name = boxModel.Name:lower()
if name:match("divine") then return "DIVINE" end
if name:match("mythic") then return "MYTHIC" end
return "SECRET"
end
local function createBoxEsp(boxModel, rarity)
if not _G.BossBoxEspEnabled or EspContainer[boxModel] then return end
local color = RarityColors[rarity] or Color3.fromRGB(255, 255, 255)
local highlight = Instance.new("Highlight")
highlight.FillColor = color
highlight.FillTransparency = 0.5
highlight.Adornee = boxModel
highlight.Parent = ScreenGui
local billboard = Instance.new("BillboardGui")
billboard.Size = UDim2.new(0, 120, 0, 30)
billboard.AlwaysOnTop = true
billboard.ExtentsOffset = Vector3.new(0, 2.0, 0)
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
label.TextSize = 12
label.Text = rarity
label.Parent = billboard
EspContainer[boxModel] = {Highlight = highlight, Billboard = billboard}
end
local function isCarryingBox()
local character = game:GetService("Players").LocalPlayer.Character
if character then
for _, child in pairs(character:GetChildren()) do
if child.Name == "CarryWeld" or (child:IsA("WeldConstraint") or child:IsA("Weld")) and child.Name:match("Carry") then return true end
end
end
local BoxRuntime = game:GetService("Workspace"):FindFirstChild("BoxRuntime")
if BoxRuntime then
for _, box in pairs(BoxRuntime:GetChildren()) do
if box:FindFirstChild("CarryWeld", true) then
local weld = box:FindFirstChild("CarryWeld", true)
local char = game:GetService("Players").LocalPlayer.Character
if char and (weld.Part0 and weld.Part0:IsDescendantOf(char) or weld.Part1 and weld.Part1:IsDescendantOf(char)) then return true end
end
end
end
return false
end
local function getBestBoxOnArenaWithVolume()
local BoxRuntime = game:GetService("Workspace"):FindFirstChild("BoxRuntime")
if not BoxRuntime then return nil, nil end
local sortedLists = {}
for _, r in ipairs(TargetRaritiesOrder) do sortedLists[r] = {} end
for _, box in pairs(BoxRuntime:GetChildren()) do
local unboxPrompt = box:FindFirstChild("Unbox", true)
if not unboxPrompt then
local r = getBoxRarity(box)
if _G.BossBoxEspEnabled and not EspContainer[box] then createBoxEsp(box, r) end
if sortedLists[r] then
local bPart = box:IsA("Model") and (box.PrimaryPart or box:FindFirstChildWhichIsA("BasePart", true)) or box
local volume = 0
if bPart and bPart:IsA("BasePart") then volume = bPart.Size.X * bPart.Size.Y * bPart.Size.Z end
table.insert(sortedLists[r], {Box = box, Part = bPart, Vol = volume})
end
end
end
for box, esp in pairs(EspContainer) do
if not box.Parent then
if esp.Highlight then esp.Highlight:Destroy() end
if esp.Billboard then esp.Billboard:Destroy() end
EspContainer[box] = nil
end
end
for _, r in ipairs(TargetRaritiesOrder) do
local items = sortedLists[r]
if #items > 0 then
table.sort(items, function(a, b) return a.Vol > b.Vol end)
return items.Box, items.Part
end
end
return nil, nil
end
task.spawn(function()
while true do
task.wait(0.01)
local character = game:GetService("Players").LocalPlayer.Character
local root = character and character:FindFirstChild("HumanoidRootPart")
if root then
local tool = character:FindFirstChildWhichIsA("Tool")
if tool and tool.Name:lower():match("bat") and os.clock() - LastSwingTime > 0.1 then
local activated = false
if _G.BossAuraEnabled then
local bossFolder = game:GetService("Workspace"):FindFirstChild("Boss")
local targetHitbox = bossFolder and (bossFolder:FindFirstChild("VerityBall_Master") or bossFolder:FindFirstChild("VerityBall_Master_B"))
if targetHitbox and targetHitbox:IsA("BasePart") and (root.Position - targetHitbox.Position).Magnitude <= 32.0 then
tool:Activate()
LastSwingTime = os.clock()
activated = true
end
end
if not activated and _G.BossPlayerDamageEnabled then
for _, player in pairs(game:GetService("Players"):GetPlayers()) do
if player ~= game:GetService("Players").LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
if (root.Position - player.Character.HumanoidRootPart.Position).Magnitude <= 15.0 then
tool:Activate()
LastSwingTime = os.clock()
break
end
end
end
end
end
end
end
end)
task.spawn(function()
while true do
task.wait(0.02)
if _G.BossFarmEnabled then
local character = game:GetService("Players").LocalPlayer.Character
local root = character and character:FindFirstChild("HumanoidRootPart")
if root and not IsStealingBossMode then
if isCarryingBox() then
root.AssemblyLinearVelocity = Vector3.zero
root.CFrame = CFrame.new(SafeBossDropPosition)
task.wait(0.3)
else
local targetBox, boxPart = getBestBoxOnArenaWithVolume()
if targetBox and boxPart then
local prompt = targetBox:FindFirstChild("Steal", true) or targetBox:FindFirstChildOfClass("ProximityPrompt")
if prompt then
IsStealingBossMode = true
root.AssemblyLinearVelocity = Vector3.zero
local tpTimeStart = os.clock()
while not isCarryingBox() and (os.clock() - tpTimeStart < 1.2) and _G.BossFarmEnabled do
local halfY = (boxPart.Size and boxPart.Size.Y / 2) or 1.5
root.AssemblyLinearVelocity = Vector3.zero
root.CFrame = CFrame.new(boxPart.Position + Vector3.new(0, halfY + 4.5, 0))
fireproximityprompt(prompt)
task.wait(0.05)
end
if isCarryingBox() then
root.AssemblyLinearVelocity = Vector3.zero
root.CFrame = CFrame.new(SafeBossDropPosition)
task.wait(0.4)
end
IsStealingBossMode = false
end
end
end
end
end
end
end)
print("GerryHub | Boss Engine Initialized.")
