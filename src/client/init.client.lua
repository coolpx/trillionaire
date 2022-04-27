local sg = game:GetService("StarterGui")
local plrs = game:GetService("Players")

sg:SetCoreGuiEnabled(Enum.CoreGuiType.All, false)
sg:SetCoreGuiEnabled(Enum.CoreGuiType.Chat, true)
sg:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, true)

local plr = plrs.LocalPlayer

local bgGui = Instance.new("ScreenGui", plr.PlayerGui)
bgGui.Name = "Background"
bgGui.IgnoreGuiInset = true
bgGui.DisplayOrder = -1

local bgFrame = Instance.new("Frame", bgGui)
bgFrame.Name = "Background"
bgFrame.BackgroundColor3 = Color3.fromRGB(36, 36, 36)
bgFrame.Size = UDim2.new(1, 0, 1, 0)

local gui = Instance.new("ScreenGui", plr.PlayerGui)
gui.Name = "MainGui"

local mainFrame = Instance.new("Frame", gui)
mainFrame.BackgroundColor3 = Color3.fromRGB(36, 36, 36)
mainFrame.BorderSizePixel = 0
mainFrame.Size = UDim2.new(1, 0, 1, 0)
mainFrame.Name = "MainFrame"

local purchaseList = Instance.new("ScrollingFrame", mainFrame)
purchaseList.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
purchaseList.Size = UDim2.new(.3, -12, 1, -16)
purchaseList.Position = UDim2.new(.7, 4, 0, 8)
purchaseList.BorderColor3 = Color3.fromRGB(160, 160, 160)

local list = Instance.new("UIListLayout", purchaseList)
list.Padding = UDim.new(0, 8)

local cashDisplay = Instance.new("TextLabel", mainFrame)
cashDisplay.Name = "CashLabel"
cashDisplay.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
cashDisplay.Size = UDim2.new(.4, -8, .2, -16)
cashDisplay.Position = UDim2.new(.5, 0, 0, 8)
cashDisplay.AnchorPoint = Vector2.new(.5, 0)
cashDisplay.BorderColor3 = Color3.fromRGB(160, 160, 160)
cashDisplay.TextScaled = true

local locationDisplay = Instance.new("TextLabel", mainFrame)
locationDisplay.Text = [[0 Locations]]
locationDisplay.Name = "LocationLabel"
locationDisplay.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
locationDisplay.Size = UDim2.new(.4, -8, .2, -8)
locationDisplay.Position = UDim2.new(.5, 0, .2, 0)
locationDisplay.AnchorPoint = Vector2.new(.5, 0)
locationDisplay.BorderColor3 = Color3.fromRGB(160, 160, 160)
locationDisplay.TextScaled = true
locationDisplay.Visible = false

local franchiseDisplay = Instance.new("TextLabel", mainFrame)
franchiseDisplay.Text = [[0 Franchises]]
franchiseDisplay.Name = "FranchiseLabel"
franchiseDisplay.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
franchiseDisplay.Size = UDim2.new(.4, -8, .2, -8)
franchiseDisplay.Position = UDim2.new(.5, 0, .4, 0)
franchiseDisplay.AnchorPoint = Vector2.new(.5, 0)
franchiseDisplay.BorderColor3 = Color3.fromRGB(160, 160, 160)
franchiseDisplay.TextScaled = true
franchiseDisplay.Visible = false

local bankDisplay = Instance.new("TextLabel", mainFrame)
bankDisplay.Text = "$0"
bankDisplay.Name = "FranchiseLabel"
bankDisplay.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
bankDisplay.Size = UDim2.new(.4, -8, .2, -8)
bankDisplay.Position = UDim2.new(.5, 0, .6, 0)
bankDisplay.AnchorPoint = Vector2.new(.5, 0)
bankDisplay.BorderColor3 = Color3.fromRGB(160, 160, 160)
bankDisplay.TextScaled = true
bankDisplay.Visible = false

local bankAdd = Instance.new("TextButton", mainFrame)
bankAdd.Name = "BankAdd"
bankAdd.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
bankAdd.Size = UDim2.new(.2, -8, .2, -8)
bankAdd.Position = UDim2.new(.4, 0, .8, 0)
bankAdd.AnchorPoint = Vector2.new(.5, 0)
bankAdd.BorderColor3 = Color3.fromRGB(160, 160, 160)
bankAdd.TextScaled = true
bankAdd.Text = "+"
bankAdd.Visible = false

local bankSub = Instance.new("TextButton", mainFrame)
bankSub.Name = "BankSub"
bankSub.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
bankSub.Size = UDim2.new(.2, -8, .2, -8)
bankSub.Position = UDim2.new(.6, 0, .8, 0)
bankSub.AnchorPoint = Vector2.new(.5, 0)
bankSub.BorderColor3 = Color3.fromRGB(160, 160, 160)
bankSub.TextScaled = true
bankSub.Text = "-"
bankSub.Visible = false

local day = 0
local interest = 0.08
local gameSpeed = 1.5
local franchiseChance = .2

local locations = 0
local franchises = 0
local cash = 300000
local incomePerLocation = 150
local banked = 0

local franchisesEnabled = false
local bankingEnabled = false

local function activationListener(item: GuiButton, func)
    item.MouseButton1Click:Connect(func)
    item.TouchTap:Connect(func)
end
local function isForSale(item: string)
    return not purchased[item]
end

purchases = {
    {
        Name = "First Location",
        Price = 3000,
        Description = "Your very first store. Generates $150 per day.",
        Action = function()
            locations += 1
            locationDisplay.Text = [[1 Location]]
            locationDisplay.Visible = true
        end
    },
    {
        DoNotDelete = true,
        Dependency = "First Location",
        Name = "Another Location",
        Price = 1500,
        Description = "Get another store to increase profits.",
        Action = function()
            locations += 1
            locationDisplay.Text = tostring(locations) .. " Locations"
        end
    },
    {
        Dependency = "First Location",
        Name = "Franchise",
        Price = 15000,
        Description = "Franchise your store so other people can create more locations. You will only get half of regular revenue from franchised stores, however.",
        Action = function()
            franchisesEnabled = true
            franchiseDisplay.Visible = true
        end
    },
    {
        Dependency = "First Location",
        Name = "Savings Account",
        Price = 1500,
        Description = "Get a savings account to earn interest on your cash over time.",
        Action = function()
            bankingEnabled = true
            bankDisplay.Visible = true
            bankAdd.Visible = true
            bankSub.Visible = true
        end
    },
    {
        Dependency = "Franchise",
        Name = "Marketing I",
        Price = 10000,
        Description = "Run an ad campaign to increase income and speed of franchising.",
        Action = function()
            incomePerLocation += 50
            franchiseChance += .1
        end
    },
    {
        Dependency = "Marketing I",
        Name = "Marketing II",
        Price = 20000,
        Description = "Run another ad campaign to increase income and speed of franchising.",
        Action = function()
            incomePerLocation += 100
            franchiseChance += .2
        end
    },
    {
        Dependency = "Marketing II",
        Name = "Marketing III",
        Price = 25000,
        Description = "Run another ad campaign to increase income and speed of franchising.",
        Action = function()
            incomePerLocation += 100
            franchiseChance += .2
        end
    },
    {
        Dependency = "Marketing III",
        Name = "Large Business",
        Price = 50000,
        Description = "Become a large business, slightly decreasing income but increasing franchise chance and speed greatly.",
        Action = function()
            incomePerLocation -= 50
            franchiseChance += 1.3
            gameSpeed = 1
        end
    },
    {
        Dependency = "Large Business",
        Name = "Go International",
        Price = 100000,
        Description = "Become a global business, increasing income and franchise speed greatly. Another Location now buys 50 locations.",
        Action = function()
            incomePerLocation += 100
            franchiseChance += 1.3
            gameSpeed = 1
            purchaseList["Another Location"]:Destroy()
            table.remove(purchaseList, 2)
        end
    },
    {
        Dependency = "Go International",
        Name = "Another Location",
        Price = 75000,
        Description = "Get another store to increase profits.",
        Action = function()
            locations += 50
            locationDisplay.Text = tostring(locations) .. " Locations"
        end
    }
}
purchased = {}

local baseButton = Instance.new("TextButton")
baseButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
baseButton.Text = ""

local title = Instance.new("TextLabel", baseButton)
title.BackgroundTransparency = 1
title.Name = "Title"
title.Size = UDim2.new(1, -8, .3, -8)
title.Position = UDim2.new(0, 4, 0, 4)
title.TextScaled = true

local price = Instance.new("TextLabel", baseButton)
price.BackgroundTransparency = 1
price.Name = "Price"
price.Size = UDim2.new(1, -8, .3, -8)
price.Position = UDim2.new(0, 4, .25, 4)
price.TextScaled = true

local description = Instance.new("TextLabel", baseButton)
description.TextXAlignment = Enum.TextXAlignment.Left
description.TextYAlignment = Enum.TextYAlignment.Top
description.TextWrapped = true
description.BackgroundTransparency = 1
description.Name = "Description"
description.Size = UDim2.new(1, -8, .45, -8)
description.Position = UDim2.new(0, 4, .55, 4)

local uiStroke = Instance.new("UIStroke", baseButton)
uiStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
uiStroke.Color = Color3.fromRGB(160, 160, 160)

for i, purchase in pairs(purchases) do
    if purchase["Dependency"] then
        task.spawn(function()
            repeat task.wait() until not isForSale(purchase["Dependency"])

            local button = baseButton:Clone()
            button.Name = purchase.Name
            button.Size = UDim2.new(1, -12, .1, -4)
            button.Position = UDim2.new(0, 4, 0, 4)
            button.Title.Text = purchase.Name
            button.Description.Text = purchase.Description
            button.Price.Text = tostring("$" .. tostring(purchase.Price))
            button.Parent = purchaseList
        
            activationListener(button, function()
                if cash >= purchase.Price then
                    if not purchase["DoNotDelete"] then
                        button:Destroy()
                        purchased[purchase.Name] = true
                        table.remove(purchases, i)
                    end
                    cash = cash - purchase.Price
                    purchase.Action()
                    cashDisplay.Text = "$" .. tostring(cash)
                end
            end)
        end)
    else
        local button = baseButton:Clone()
        button.Size = UDim2.new(1, -12, .1, -4)
        button.Position = UDim2.new(0, 4, 0, 4)
        button.Title.Text = purchase.Name
        button.Description.Text = purchase.Description
        button.Price.Text = tostring("$" .. tostring(purchase.Price))
        button.Parent = purchaseList
    
        activationListener(button, function()
            if cash >= purchase.Price then
                if not purchase["DoNotDelete"] then
                    button:Destroy()
                    purchased[purchase.Name] = true
                    table.remove(purchases, i)
                end
                cash = cash - purchase.Price
                purchase.Action()
                cashDisplay.Text = "$" .. tostring(cash)
            end
        end)
    end
end

activationListener(bankAdd, function()
    if bankingEnabled then
        local toAdd = math.round(cash/5)
        cash -= toAdd
        banked += toAdd
        cashDisplay.Text = "$" .. tostring(cash)
        bankDisplay.Text = "$" .. tostring(banked)
    end
end)
activationListener(bankSub, function()
    if bankingEnabled then
        local toRemove = math.round(banked/5)
        banked -= toRemove
        cash += toRemove
        cashDisplay.Text = "$" .. tostring(cash)
        bankDisplay.Text = "$" .. tostring(banked)
    end
end)

cashDisplay.Text = "$" .. tostring(cash)

while true do
    task.wait(gameSpeed)

    day += 1
    cash += locations * incomePerLocation
    cashDisplay.Text = "$" .. tostring(cash)

    if franchisesEnabled then
        if franchiseChance <= 1 then
            if math.random() > (1 - franchiseChance) then
                franchises += 1
                if franchises ~= 1 then
                    franchiseDisplay.Text = tostring(franchises) .. " Franchises"
                else
                    franchiseDisplay.Text = [[1 Franchise]]
                end
            end
        else
            local newFranchises = math.random(1, math.round(franchiseChance))
            franchises += newFranchises
            franchiseDisplay.Text = tostring(franchises) .. " Franchises"
        end
        cash += franchises * (incomePerLocation / 2)
    end
    if bankingEnabled then
        banked *= 1 + (interest / 365)
        banked = math.round(banked)
        bankDisplay.Text = "$" .. tostring(banked)
    end
end