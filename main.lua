-- help this took too long
-- if u call this ai i will kill you son
local url = "https://raw.githubusercontent.com/scripter1321/opscriptsgui/main/main.luau?nocache=" .. os.clock()
local guiLib = loadstring(game:HttpGet(url))()
guiLib.Loading()
guiLib.CreateTitle("OPSCRIPTS - Grow A Garden 2")

local Players = game:GetService("Players")
local player = Players.LocalPlayer
local listFrame

local function clearList()
	if not listFrame then
		return
	end

	for _, child in ipairs(listFrame:GetChildren()) do
		if child:IsA("Frame") and child.Name:find("HarvestItem") then
			child:Destroy()
		end
	end
end
local PacketEvent = game:GetService("ReplicatedStorage").SharedModules.Packet.RemoteEvent
local function SellAll()
    PacketEvent:FireServer( buffer.fromstring("\x9C\x00N"))
end
local function createHarvestList(page)

	local listFrame = Instance.new("ScrollingFrame")
	listFrame.Name = "HarvestList"
	listFrame.Size = UDim2.new(1, -20, 1, -120)
	listFrame.Position = UDim2.new(0, 10, 0, 110)
	listFrame.BackgroundTransparency = 1
	listFrame.ScrollBarThickness = 6
	listFrame.ScrollBarImageColor3 = Color3.fromRGB(99, 102, 241)

	listFrame.LayoutOrder = -999
    listFrame.Parent = page
    listFrame.Position = UDim2.new(0, 10, 0, 110)
    listFrame.LayoutOrder = -999
    listFrame:SetAttribute("IgnoreLayout", true)


	local y = 0

	local function updateCanvas()
		y = 0

		for _, child in ipairs(listFrame:GetChildren()) do
			if child:IsA("GuiObject") and child ~= listFrame then
				child.Position = UDim2.new(0,0,0,y)
				y += child.AbsoluteSize.Y + 6
			end
		end

		listFrame.CanvasSize = UDim2.fromOffset(0,y+20)
	end

	listFrame.ChildAdded:Connect(function()
		task.defer(updateCanvas)
	end)

	listFrame.ChildRemoved:Connect(updateCanvas)


	return listFrame, updateCanvas
end

local mainPage = guiLib.CreateTab("Harvesting")

local listFrame, updateCanvas = createHarvestList(mainPage)

local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(1, -20, 0, 30)
statusLabel.Position = UDim2.new(0, 10, 0, 70)
statusLabel.BackgroundTransparency = 1
statusLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
statusLabel.Text = "Ready"
statusLabel.Font = Enum.Font.Gotham
statusLabel.TextSize = 14
statusLabel.TextXAlignment = Enum.TextXAlignment.Left
statusLabel.Parent = mainPage

local function scanPrompts()
	clearList(mainPage)

	local found = {}

	for _, obj in ipairs(workspace:GetDescendants()) do
		if obj:IsA("ProximityPrompt") and obj.Name == "HarvestPrompt" then
			table.insert(found, obj)
		end
	end

	statusLabel.Text = "Found " .. #found .. " harvest prompts"
end
guiLib.CreateButton("Harvest All", "Harvesting", function()
	local character = player.Character or player.CharacterAdded:Wait()
	local hrp = character:WaitForChild("HumanoidRootPart")

	local prompts = {}

	for _, obj in ipairs(workspace:GetDescendants()) do
		if obj:IsA("ProximityPrompt") and obj.Name == "HarvestPrompt" then
			local target = obj.Parent

			if target:IsA("Attachment") then
				target = target.Parent
			end

			if target and target:IsA("BasePart") then
				table.insert(prompts, {
					prompt = obj,
					target = target
				})
			end
		end
	end

	table.sort(prompts, function(a, b)
		return (hrp.Position - a.target.Position).Magnitude <
			(hrp.Position - b.target.Position).Magnitude
	end)

	for _, data in ipairs(prompts) do
		if data.prompt and data.prompt.Parent and data.target and data.target.Parent then
			hrp.CFrame = data.target.CFrame * CFrame.new(0, 5, 0)

			task.wait(0.15)

			if data.prompt.Parent then
				fireproximityprompt(data.prompt)
			end

			task.wait(0.2)
		end
	end

	statusLabel.Text = "Harvest All completed"
end)
guiLib.CreateButton("Harvest All NO TP (close to garden)", "Harvesting", function()
	local prompts = {}

	for _, obj in ipairs(workspace:GetDescendants()) do
		if obj:IsA("ProximityPrompt") and obj.Name == "HarvestPrompt" then
			table.insert(prompts, obj)
		end
	end

	for _, prompt in ipairs(prompts) do
		if prompt and prompt.Parent then
			local oldDistance = prompt.MaxActivationDistance

			prompt.MaxActivationDistance = 9999999999
			fireproximityprompt(prompt)
			prompt.MaxActivationDistance = oldDistance

			task.wait(0.1)
		end
	end

	statusLabel.Text = "Harvest All completed"
end)
guiLib.CreateToggle("Loop Harvest All NO TP", "Harvesting", function(GetToggle)
	while GetToggle() do
		local prompts = {}

		for _, obj in ipairs(workspace:GetDescendants()) do
			if obj:IsA("ProximityPrompt") and obj.Name == "HarvestPrompt" then
				table.insert(prompts, obj)
			end
		end

		for _, prompt in ipairs(prompts) do
			if prompt and prompt.Parent then
				local oldDistance = prompt.MaxActivationDistance

				prompt.MaxActivationDistance = 9999999999
				fireproximityprompt(prompt)
				prompt.MaxActivationDistance = oldDistance

				task.wait(0.1)
			end
		end

		statusLabel.Text = "Harvest All completed"

		task.wait(5)
	end
end)
guiLib.CreateButton("Refresh", "Harvesting", scanPrompts)



task.spawn(function()
	while true do
		scanPrompts()
		task.wait(2)
	end
end)
local character = player.Character or player.CharacterAdded:Wait()
scanPrompts()
local ssprompt = workspace.NPCS.Sam.HumanoidRootPart.ProximityPrompt
local sellsprompt = workspace.NPCS.Steven.HumanoidRootPart.ProximityPrompt
guiLib.CreateButton("Open Seed Shop", "Other", function()
    character:PivotTo(CFrame.new(264, 147, -145))
    fireproximityprompt(ssprompt)
end)
guiLib.CreateButton("Open Seed Shop NO TP", "Other", function()
    ssprompt.MaxActivationDistance = 99999999999
    fireproximityprompt(ssprompt)
    ssprompt.MaxActivationDistance = 10
end)
guiLib.CreateButton("Open Sell", "Other", function()
    character:PivotTo(CFrame.new(273, 147, -126))
    fireproximityprompt(sellsprompt)
end)

guiLib.CreateButton("Sell All", "Other", SellAll)
guiLib.CreateToggle("Loop Sell All", "Other", function(GetToggle)
    while GetToggle() do
		SellAll()
		task.wait(1)
	end
end)
