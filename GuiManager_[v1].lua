--!strict
local tweenService = game:GetService("TweenService")
local runService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")

local defaultInfo = TweenInfo.new(1, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)

local draggingBegan = Instance.new("BindableEvent")
local draggingChanged = Instance.new("BindableEvent")
local draggingEnded = Instance.new("BindableEvent")
local rotatingBegan = Instance.new("BindableEvent")
local rotatingChanged = Instance.new("BindableEvent")
local rotatingEnded = Instance.new("BindableEvent")

type tbl = {[any] : any?}
type array = {[number] : any?}

type clamp = {
	X : Vector2?,
	Y : Vector2?,
	OnlyOnEnded : boolean?
}
type grid = {
	X : number?,
	Y : number?,
	OnlyOnEnded : boolean?
}

local Settings = {
	DisableGlobalEvents = false,
	DisableLocalEvents = false
}

local Gui = {}
Gui.__index = Gui
Gui.__type = "Gui"

Gui.DraggingBegan = draggingBegan.Event
Gui.DraggingChanged = draggingChanged.Event
Gui.DraggingEnded = draggingEnded.Event
Gui.RotatingBegan = rotatingBegan.Event
Gui.RotatingChanged = rotatingChanged.Event
Gui.RotatingEnded = rotatingEnded.Event

local function round(num : number, bound : number) : number	
	return math.round(num / bound) * bound
end

function Gui.new(name : string, props : tbl) : any
	assert(type(name) == "string", "name must be a string")
	
	local ui = Instance.new(name)
	local parent = nil
	
	for prop, value in pairs(props) do
		if (prop == "Parent") then parent = value continue end
		ui[prop] = value
	end
	
	ui.Parent = parent
	
	local events = {
		draggingBegan = Instance.new("BindableEvent"),
		draggingChanged = Instance.new("BindableEvent"),
		draggingEnded = Instance.new("BindableEvent"),
		rotatingBegan = Instance.new("BindableEvent"),
		rotatingChanged = Instance.new("BindableEvent"),
		rotatingEnded = Instance.new("BindableEvent")
	}
	local tbl = {
		["Ui"] = ui,
		["Connections"] = {},
		["BindableEvents"] = table.freeze(events),
		["ScreenGui"] = ui:FindFirstAncestorWhichIsA("ScreenGui"),

		["DraggingBegan"] =  events.draggingBegan.Event,
		["DraggingChanged"] = events.draggingChanged.Event,
		["DraggingEnded"] = events.draggingEnded.Event,
		["RotatingBegan"] = events.rotatingBegan.Event,
		["RotatingChanged"] = events.rotatingChanged.Event,
		["RotatingEnded"] = events.rotatingEnded.Event
	}
	
	assert(tbl.ScreenGui, "The ui must have a ScreenGui as an Ancestor")
	
	return setmetatable(tbl, Gui)
end

function Gui.setup(ui : Instance) : any
	assert(typeof(ui) == "Instance", "ui must be an Instance")
	
	local events = {
		draggingBegan = Instance.new("BindableEvent"),
		draggingChanged = Instance.new("BindableEvent"),
		draggingEnded = Instance.new("BindableEvent"),
		rotatingBegan = Instance.new("BindableEvent"),
		rotatingChanged = Instance.new("BindableEvent"),
		rotatingEnded = Instance.new("BindableEvent")
	}
	local tbl = {
		["Ui"] = ui,
		["Connections"] = {},
		["BindableEvents"] = table.freeze(events),
		["ScreenGui"] = ui:FindFirstAncestorWhichIsA("ScreenGui"),

		["DraggingBegan"] =  events.draggingBegan.Event,
		["DraggingChanged"] = events.draggingChanged.Event,
		["DraggingEnded"] = events.draggingEnded.Event,
		["RotatingBegan"] = events.rotatingBegan.Event,
		["RotatingChanged"] = events.rotatingChanged.Event,
		["RotatingEnded"] = events.rotatingEnded.Event
	}
	
	assert(tbl.ScreenGui, "The ui must have a ScreenGui as an Ancestor")
	
	return setmetatable(tbl, Gui)
end

function Gui.updateSettings(setting : string, value : any)
	Settings[setting] = value
end

function Gui.BulkSetup(uis : array) : array
	local setups = {}
	
	for _, ui in ipairs(uis) do
		assert(typeof(ui) == "Instance", "ui must be an Instance")
		
		local events = {
			draggingBegan = Instance.new("BindableEvent"),
			draggingChanged = Instance.new("BindableEvent"),
			draggingEnded = Instance.new("BindableEvent"),
			rotatingBegan = Instance.new("BindableEvent"),
			rotatingChanged = Instance.new("BindableEvent"),
			rotatingEnded = Instance.new("BindableEvent")
		}
		local tbl = {
			["Ui"] = ui,
			["Connections"] = {},
			["BindableEvents"] = table.freeze(events),
			["ScreenGui"] = ui:FindFirstAncestorWhichIsA("ScreenGui"),
			
			["DraggingBegan"] =  events.draggingBegan.Event,
			["DraggingChanged"] = events.draggingChanged.Event,
			["DraggingEnded"] = events.draggingEnded.Event,
			["RotatingBegan"] = events.rotatingBegan.Event,
			["RotatingChanged"] = events.rotatingChanged.Event,
			["RotatingEnded"] = events.rotatingEnded.Event
		}
		
		assert(tbl.ScreenGui, "The ui must have a ScreenGui as an Ancestor")
		
		table.insert(setups, setmetatable(tbl, Gui))
	end
	
	return setups
end

function Gui.BulkTween(uis : array, goal : tbl, tweenInfo : TweenInfo?)
	assert(type(uis) == "table" and uis[1], "uis must be an array")
	assert(type(goal) == "table", "goal must be a table")
	tweenInfo = (tweenInfo or defaultInfo)
	
	for _, ui in ipairs(uis) do
		tweenService:Create(ui, tweenInfo, goal):Play()
	end
end

function Gui.BulkChange(uis : array, goal : tbl)
	assert(type(uis) == "table" and uis[1], "uis must be an array")
	assert(type(goal) == "table", "goal must be a table")
	
	for _, ui : any in ipairs(uis) do
		for prop, value in pairs(goal) do
			ui[prop] = value
		end
	end
end

function Gui:Tween(goal : tbl, tweenInfo : TweenInfo?)
	assert(type(goal) == "table", "goal must be a table")
	tweenInfo = (tweenInfo or defaultInfo)
	
	tweenService:Create(self.Ui, tweenInfo, goal):Play()
end

function Gui:TweenChildren(goal : tbl, tweenInfo : TweenInfo?, recursive : boolean?)
	local uis = if recursive then self.Ui:GetDescendants() else self.Ui:GetChildren()
	table.insert(uis, self.Ui)
	
	for _, ui in ipairs(uis) do
		tweenService:Create(ui, tweenInfo, goal):Play()
	end
end

function Gui:Change(goal : tbl)
	assert(type(goal) == "table", "goal must be a table")
	
	for prop, value in pairs(goal) do
		self.Ui[prop] = value
	end
end

function Gui:ChangeChildren(goal : tbl, recursive : boolean?)
	local uis = if recursive then self.Ui:GetDescendants() else self.Ui:GetChildren()
	table.insert(uis, self.Ui)

	for _, ui in ipairs(uis) do
		for prop, value in pairs(goal) do
			ui[prop] = value
		end
	end
end

function Gui:Destroy()
	self.Ui:Destroy()
	table.clear(self)
end

function Gui:Remove() : Instance
	local ui = self.Ui
	ui:Remove()
	
	table.clear(self)
	return ui
end

function Gui:Clear() : Instance
	local ui = self.Ui
	
	table.clear(self)
	return ui
end

function Gui:Draggable(clamps : clamp?, grids : grid?)	
	assert(typeof(self.Ui.Parent) == "Instance" and self.Ui.Parent:IsA("GuiBase2d"), "The Ui's parent must be a GuiBase2d")
	assert(self.Connections.Rotating == nil, "Rotation must be disabled before Dragging can be enabled")
	
	local dragging = self.Connections.Dragging
	
	if dragging then
		if (self.Connections.DraggingBegan and self.Connections.DraggingBegan.Connected) then self.Connections.DraggingBegan:Disconnect() end
		if (self.Connections.DraggingEnded and self.Connections.DraggingEnded.Connected) then self.Connections.DraggingEnded:Disconnect() end
		if (self.Connections.Dragging and self.Connections.Dragging.Connected) then self.Connections.Dragging:Disconnect() end
		
		self.Connections.DraggingBegan = nil
		self.Connections.DraggingEnded = nil
		self.Connections.Dragging = nil
	else
		self.Connections.DraggingBegan = self.Ui.InputBegan:Connect(function(input : InputObject, gp : boolean)
			if not gp and (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
				self.Ui:SetAttribute("Dragging", true)
				
				if not Settings.DisableGlobalEvents then draggingBegan:Fire(self) end
				if not Settings.DisableLocalEvents then self.BindableEvents.draggingBegan:Fire(self) end
			end
		end)
		
		self.Connections.DraggingEnded = self.Ui.InputEnded:Connect(function(input : InputObject, gp : boolean)
			if not gp and (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
				
				local absolutePos = self.Ui.Parent.AbsolutePosition
				local mousePos = Vector2.new(input.Position.X - absolutePos.X, input.Position.Y - absolutePos.Y)
				
				local unit = (mousePos / self.Ui.Parent.AbsoluteSize)
				local scale = UDim2.fromScale(math.clamp(unit.X, 0, 1), math.clamp(unit.Y, 0, 1))
				
				local roundX = if (grids and grids.X) then round(scale.X.Scale, grids.X) else scale.X.Scale
				local roundY = if (grids and grids.Y) then round(scale.Y.Scale, grids.Y) else scale.Y.Scale
				scale = if grids then UDim2.fromScale(roundX, roundY) else scale

				local clampX = if (clamps and clamps.X) then math.clamp(scale.X.Scale, clamps.X.X, clamps.X.Y) else scale.X.Scale
				local clampY = if (clamps and clamps.Y) then math.clamp(scale.Y.Scale, clamps.Y.X, clamps.Y.Y) else scale.Y.Scale
				scale = if clamps then UDim2.fromScale(clampX, clampY) else scale
				
				self.Ui.Position = scale
				self.Ui:SetAttribute("Dragging", false)
				
				if not Settings.DisableGlobalEvents then draggingEnded:Fire(self) end
				if not Settings.DisableLocalEvents then self.BindableEvents.draggingEnded:Fire(self) end
			end
		end)
		
		self.Connections.Dragging = UIS.InputChanged:Connect(function(input : InputObject, gp : boolean)
			if not gp and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
				if not self.Ui:GetAttribute("Dragging") then return end
				
				local absolutePos = self.Ui.Parent.AbsolutePosition
				local mousePos = Vector2.new(input.Position.X - absolutePos.X, input.Position.Y - absolutePos.Y)
				
				local unit = (mousePos / self.Ui.Parent.AbsoluteSize)
				local scale = UDim2.fromScale(math.clamp(unit.X, 0, 1), math.clamp(unit.Y, 0, 1))
				
				local roundX = if (grids and grids.X) then round(scale.X.Scale, grids.X) else scale.X.Scale
				local roundY = if (grids and grids.Y) then round(scale.Y.Scale, grids.Y) else scale.Y.Scale
				scale = if (grids and not grids.OnlyOnEnded) then UDim2.fromScale(roundX, roundY) else scale
				
				local clampX = if (clamps and clamps.X) then math.clamp(scale.X.Scale, clamps.X.X, clamps.X.Y) else scale.X.Scale
				local clampY = if (clamps and clamps.Y) then math.clamp(scale.Y.Scale, clamps.Y.X, clamps.Y.Y) else scale.Y.Scale
				scale = if (clamps and not clamps.OnlyOnEnded) then UDim2.fromScale(clampX, clampY) else scale
				
				self.Ui.Position = scale
				
				if not Settings.DisableGlobalEvents then draggingChanged:Fire(self) end
				if not Settings.DisableLocalEvents then self.BindableEvents.draggingChanged:Fire(self) end
			end
		end)
	end
end

function Gui:Rotatable(clamp : Vector2?, segment : number?, OnlyOnEnded : boolean?)
	assert(typeof(self.Ui.Parent) == "Instance" and self.Ui.Parent:IsA("GuiBase2d"), "The Ui's parent must be a GuiBase2d")
	assert(self.Connections.Dragging == nil, "Dragging must be disabled before Rotation can be enabled")
	
	local rotating = self.Connections.Rotating
	
	if rotating then
		if (self.Connections.RotatingBegan and self.Connections.RotatingBegan.Connected) then self.Connections.RotatingBegan:Disconnect() end
		if (self.Connections.RotatingEnded and self.Connections.RotatingEnded.Connected) then self.Connections.RotatingEnded:Disconnect() end
		if (self.Connections.Rotating and self.Connections.Rotating.Connected) then self.Connections.Rotating:Disconnect() end

		self.Connections.RotatingBegan = nil
		self.Connections.RotatingEnded = nil
		self.Connections.Rotating = nil
	else
		self.Connections.RotatingBegan = self.Ui.InputBegan:Connect(function(input : InputObject, gp : boolean)
			if not gp and (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
				self.Ui:SetAttribute("Rotating", true)
				
				if not Settings.DisableGlobalEvents then rotatingBegan:Fire(self) end
				if not Settings.DisableLocalEvents then self.BindableEvents.rotatingBegan:Fire(self) end
			end
		end)
		
		self.Connections.RotatingEnded = self.Ui.InputEnded:Connect(function(input : InputObject, gp : boolean)
			if not gp and (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
				self.Ui:SetAttribute("Rotating", false)
				
				local absolutePos = self.ScreenGui.AbsolutePosition
				local mousePos = Vector2.new(input.Position.X - absolutePos.X, input.Position.Y - absolutePos.Y)
				
				local center = self.Ui.AbsolutePosition + (self.Ui.AbsoluteSize / 2)
				local rotation = math.deg(math.atan2(mousePos.Y - center.Y, mousePos.X - center.X))
				
				rotation = if segment then round(rotation, segment) else rotation
				rotation = if clamp then math.clamp(rotation, clamp.X, clamp.Y) else rotation
				
				self.Ui.Rotation =  rotation
				
				if not Settings.DisableGlobalEvents then rotatingEnded:Fire(self) end
				if not Settings.DisableLocalEvents then self.BindableEvents.rotatingEnded:Fire(self) end
			end
		end)
		
		self.Connections.Rotating = UIS.InputChanged:Connect(function(input : InputObject, gp : boolean)
			if not gp and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
				if not self.Ui:GetAttribute("Rotating") then return end
				
				local absolutePos = self.ScreenGui.AbsolutePosition
				local mousePos = Vector2.new(input.Position.X - absolutePos.X, input.Position.Y - absolutePos.Y)
				
				local center = self.Ui.AbsolutePosition + (self.Ui.AbsoluteSize / 2)
				local rotation = math.deg(math.atan2(mousePos.Y - center.Y, mousePos.X - center.X))
				
				rotation = if (segment and not OnlyOnEnded) then round(rotation, segment) else rotation
				rotation = if (clamp and not OnlyOnEnded) then math.clamp(rotation, clamp.X, clamp.Y) else rotation
				
				self.Ui.Rotation =  rotation
				
				if not Settings.DisableGlobalEvents then rotatingChanged:Fire(self) end
				if not Settings.DisableLocalEvents then self.BindableEvents.rotatingChanged:Fire(self) end
			end
		end)
	end
end

return Gui

--[[
Made by M_dgettMann (shadowflame63)

GuiManager [v1] (Testing versions)
                                    
How to use each basic function:
	Gui.new(name, props, parent) -- Creates the named ui, sets it properties and sets up the metatable
	Gui.setup(ui) -- Sets up a metatable so all these functions can be used on the passed ui Instance
	Gui.updateSettings(setting, value) -- Sets the passed setting to the passed value
	
	Gui.BulkSetup(uis) -- Sets up all the passed ui Instances in a for loop, returns a table of the setup ui
	Gui.BulkTween(uis, goal, tweenInfo) -- Tweens multiple ui instances with the given properties and values inside goal
	Gui.BulkChange(uis, goal) -- Sets ui instances properties with the given properties and values inside goal, without tweening

	Gui:Tween(goal, tweenInfo) -- Tween the values of the given properties inside goal
	Gui:TweenChildren(goal, tweenInfo, recursive) -- Same as Tween, but includes children (or descendants if recursive is true)
	Gui:Change(goal) -- Sets the values of the given properties inside goal, without tweening
	Gui:ChangeChildren(goal, recursive) -- Same as Set, but includes children (or descendants if recursive is true)
	
	Gui:Destroy() -- Destroys the ui and clears the table
	Gui:Remove() -- Removes the ui and clears the table, returns ui Instance
	Gui:Clear() -- Clears the table, without destroying or removing the ui, returns ui Instance
	
How to use the global events:
	Gui.DraggingBegan:Connect(function(ui) -- All ui fire this event, useful for knowing everything that is active in one go
		print(ui) -- Prints the table that contains the Ui, it's active Connections and ScreenGui that it's under
	end)
	
	> This example applies for DraggingBegan, DraggingChanged, DraggingEnded, RotatingBegan, RotatingChanged and RotatingEnded
	> These events can be disabled by setting 'Gui.DisableGlobalEvents' to true
	
How to use the local events:
	ui.DraggingBegan:Connect(function() -- Only the ui that was used to call the event fires it, doesn't have any parameters
		-- Code goes here
	end)
	
	> This example applies for DraggingBegan, DraggingChanged, DraggingEnded, RotatingBegan, RotatingChanged and RotatingEnded
	> These events can be disabled by setting 'Gui.DisableLocalEvents' to true
	
How to use each advanced function:
	Gui:Draggable(clamps -> { -- Allows ui to be draggable, clamps and grids can be setup to make things like sliders and inventories
			X = Vector2.new(min, max),
			Y = Vector2.new(min, max)
		},
		grids -> {
			X = number,
			Y = number,
			OnlyOnEnded = boolean
		})
	
	Gui:Rotatable(clamp -> Vector2.new(min, max),  -- Allows ui to be rotated via dragging, a clamp and segment can be setup
			segment -> number,
			OnlyOnEnded -> boolean
		)
]]
