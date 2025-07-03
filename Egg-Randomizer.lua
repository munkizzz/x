-- Visual pet hatch simulator - countdown + filter to player's garden only
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local player = Players.LocalPlayer

-- 🐣 Egg → Pet mapping (cleaned + updated from IGN wiki)
local petTable = {
    ["Common Egg"] = { "Dog", "Bunny", "Golden Lab" },
    ["Uncommon Egg"] = { "Chicken", "Black Bunny", "Cat", "Deer" },
    ["Rare Egg"] = { "Pig", "Monkey", "Rooster", "Orange Tabby", "Spotted Deer" },
    ["Legendary Egg"] = { "Cow", "Polar Bear", "Sea Otter", "Turtle", "Silver Monkey" },
    ["Mythical Egg"] = { "Grey Mouse", "Brown Mouse", "Squirrel", "Red Giant Ant" },
    ["Bug Egg"] = { "Snail", "Caterpillar", "Dragonfly", "Giant Ant", "Praying Mantis" },
    ["Night Egg"] = { "Frog", "Hedgehog", "Mole", "Echo Frog", "Night Owl" },
    ["Bee Egg"] = { "Bee", "Honey Bee", "Bear Bee", "Petal Bee" },
    ["AntiBee Egg"] = { "Wasp", "Moth", "Tarantula Hawk" },
}

-- 🏷️ Show label above egg
local function showEggPetLabel(eggModel, petName)
    local existing = eggModel:FindFirstChild("PetBillboard")
    if existing then existing:Destroy() end

    local billboard = Instance.new("BillboardGui")
    billboard.Name = "PetBillboard"
    billboard.Size = UDim2.new(0, 250, 0, 50)
    billboard.StudsOffset = Vector3.new(0, 4.5, 0)
    billboard.AlwaysOnTop = true
    billboard.MaxDistance = 500
    billboard.Parent = eggModel

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = eggModel.Name .. " | " .. petName
    label.TextColor3 = Color3.new(1, 1, 1)
    label.TextStrokeTransparency = 0
    label.TextScaled = true
    label.Font = Enum.Font.FredokaOne
    label.Parent = billboard
end

-- ✅ Only find eggs near the player (to avoid shop eggs)
local function getPlayerGardenEggs(radius)
    local eggs = {}
    local char = player.Character or player.CharacterAdded:Wait()
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return eggs end

    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("Model") and petTable[obj.Name] then
            local eggPos = obj:GetModelCFrame().Position
            local dist = (eggPos - root.Position).Magnitude
            if dist <= (radius or 60) then
                table.insert(eggs, obj)
            end
        end
    end
    return eggs
end

-- 🎯 Randomize all nearby eggs
local function randomizeNearbyEggs()
    local eggs = getPlayerGardenEggs(60)
    for _, egg in ipairs(eggs) do
        local pets = petTable[egg.Name]
        local chosen = pets[math.random(1, #pets)]
        showEggPetLabel(egg, chosen)
    end
    print("Randomized", #eggs, "eggs near player.")
end

-- ⏱ Countdown before randomizing
local function countdownAndRandomize(button)
    for i = 10, 1, -1 do
        button.Text = "Randomizing in: " .. i
        wait(1)
    end
    randomizeNearbyEggs()
    button.Text = "Randomize ALL Pets"
end

-- 🟩 GUI Button
local screenGui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
screenGui.Name = "PetHatchGui"

local button = Instance.new("TextButton", screenGui)
button.Size = UDim2.new(0, 200, 0, 50)
button.Position = UDim2.new(0, 20, 0, 100)
button.BackgroundColor3 = Color3.fromRGB(255, 140, 0)
button.Text = "Randomize ALL Pets"
button.TextSize = 20
button.Font = Enum.Font.FredokaOne
button.TextColor3 = Color3.new(1, 1, 1)

-- Click to start countdown and randomize
button.MouseButton1Click:Connect(function()
    countdownAndRandomize(button)
end)
