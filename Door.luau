local TweenService = game:GetService("TweenService")

local door = script.Parent

local prompt = Instance.new("ProximityPrompt")
prompt.ActionText = "Open"
prompt.ObjectText = "Door"
prompt.KeyboardKeyCode = Enum.KeyCode.E
prompt.HoldDuration = 0.3
prompt.MaxActivationDistance = 10
prompt.Parent = door

local OPEN_DISTANCE = 6
local AUTO_CLOSE_TIME = 3
local TWEEN_TIME = 0.6

local closedPosition = door.Position
local openPosition = closedPosition + Vector3.new(0, OPEN_DISTANCE, 0)

local isOpen = false
local busy = false
local doorVersion = 0

local tweenInfo = TweenInfo.new(
	TWEEN_TIME,
	Enum.EasingStyle.Quad,
	Enum.EasingDirection.InOut
)

local function moveDoor(targetPosition: Vector3)
	local tween = TweenService:Create(
		door,
		tweenInfo,
		{ Position = targetPosition }
	)

	tween:Play()
	tween.Completed:Wait()
end

local function closeDoor()
	if not isOpen or busy then
		return
	end

	busy = true
	doorVersion += 1

	moveDoor(closedPosition)

	isOpen = false
	prompt.ActionText = "Open"
	busy = false
end

local function openDoor()
	if isOpen or busy then
		return
	end

	busy = true
	doorVersion += 1

	local currentVersion = doorVersion

	moveDoor(openPosition)

	isOpen = true
	prompt.ActionText = "Close"
	busy = false

	task.delay(AUTO_CLOSE_TIME, function()
		if isOpen and doorVersion == currentVersion then
			closeDoor()
		end
	end)
end

prompt.Triggered:Connect(function(player: Player)
	print(player.Name .. " interacted with the door")

	if isOpen then
		closeDoor()
	else
		openDoor()
	end
end)
