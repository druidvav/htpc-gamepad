/*
 GamepadReady:
  1: Gamepad connected and available
  0: Gamepad is not available
  -1: Not initialized yet
*/
GamepadReady := -1

LEVEL_EVERYTHING = 10
LEVEL_MOUSE      = 5
LEVEL_NOTHING    = 0
CurrentLevel  := LEVEL_NOTHING
ExpectedLevel := LEVEL_EVERYTHING
BlockingEnabled  = 0
EmergencyEnabled = 0

JoyThresholdUpper := 50 + JoyThreshold
JoyThresholdLower := 50 - JoyThreshold
if InvertYAxis
    YAxisMultiplier = -1
else
    YAxisMultiplier = 1

JoystickPrefix = %JoystickNumber%Joy
SetTimer, CheckMode, 10
Hotkey, %JoystickPrefix%%MouseButtonLeft%, MouseButtonLeft
Hotkey, %JoystickPrefix%%MouseButtonRight%, MouseButtonRight
Hotkey, %JoystickPrefix%%BackspaceButton%, BackspaceButton
Hotkey, %JoystickPrefix%%EnterButton%, EnterButton
Hotkey, %JoystickPrefix%%KeyboardButton%, KeyboardButton
Hotkey, %JoystickPrefix%%AltF4Button%, AltF4Button
SetTimer, MouseMove, 10
SetTimer, MouseWheel, 70
SetTimer, KeyboardDirections, 150
SetTimer, SpecialButtons, 50
SetTimer, EmergencyCombo, 50
return

BackspaceButton:
	if (CurrentLevel < LEVEL_EVERYTHING) {
		return
	}
	Send, {Backspace}
	SetTimer, WaitBackspaceButtonUp, %KeyboardRepeatTimeout%
	return

WaitBackspaceButtonUp:
	if GetKeyState(JoystickPrefix . BackspaceButton)
	{
		Send, {Backspace}
		SetTimer, WaitBackspaceButtonUp, %KeyboardRepeatRate%
	}
	else
		SetTimer, WaitBackspaceButtonUp, off
	return
	
EnterButton:
	if (CurrentLevel < LEVEL_EVERYTHING) {
		return
	}
	Send, {Enter}
	SetTimer, WaitEnterButtonUp, %KeyboardRepeatTimeout%
	return

WaitEnterButtonUp:
	if GetKeyState(JoystickPrefix . EnterButton)
	{
		Send, {Enter}
		SetTimer, WaitBackspaceButtonUp, %KeyboardRepeatRate%
	}
	else
		SetTimer, WaitBackspaceButtonUp, off
	return

KeyboardButton:
	if (CurrentLevel < LEVEL_EVERYTHING) {
		return
	}
	Send, ^!+-
	Sleep 600
	return
	
AltF4Button:
	if (CurrentLevel < LEVEL_EVERYTHING) {
		return
	}
	Send, !{F4}
	Sleep 600
	return

MouseButtonLeft:
	if (CurrentLevel < LEVEL_MOUSE) {
		return
	}
	SetMouseDelay, -1
	MouseClick, left,,, 1, 0, D
	SetTimer, WaitForLeftButtonUp, 10
	return

WaitForLeftButtonUp:
	if GetKeyState(JoystickPrefix . MouseButtonLeft)
		return
	SetTimer, WaitForLeftButtonUp, off
	SetMouseDelay, -1
	MouseClick, left,,, 1, 0, U
	return

MouseButtonRight:
	if (CurrentLevel < LEVEL_MOUSE) {
		return
	}
	SetMouseDelay, -1
	MouseClick, right,,, 1, 0, D
	SetTimer, WaitForRightButtonUp, 10
	return

WaitForRightButtonUp:
	if GetKeyState(JoystickPrefix . MouseButtonRight)
		return
	SetTimer, WaitForRightButtonUp, off
	SetMouseDelay, -1
	MouseClick, right,,, 1, 0, U
	return

MouseMove:
	if (CurrentLevel < LEVEL_MOUSE) {
		return
	}
	SetFormat, float, 03
	MouseNeedsToBeMoved := false
	CurrentJoyMultiplier := JoyMultiplier
	State := XInput_GetState(%JoystickNumber%-1)
	if State.bLeftTrigger > TriggerThreshold
	{
		CurrentJoyMultiplier := JoyMultiplierSlower
	}
	GetKeyState, JoyX, %JoystickNumber%JoyX
	if JoyX > %JoyThresholdUpper%
	{
		MouseNeedsToBeMoved := true
		DeltaX := JoyX - JoyThresholdUpper
	}
	else if JoyX < %JoyThresholdLower%
	{
		MouseNeedsToBeMoved := true
		DeltaX := JoyX - JoyThresholdLower
	}
	else
	{
		DeltaX = 0
	}
	GetKeyState, JoyY, %JoystickNumber%JoyY
	if JoyY > %JoyThresholdUpper%
	{
		MouseNeedsToBeMoved := true
		DeltaY := JoyY - JoyThresholdUpper
	}
	else if JoyY < %JoyThresholdLower%
	{
		MouseNeedsToBeMoved := true
		DeltaY := JoyY - JoyThresholdLower
	}
	else
	{
		DeltaY = 0
	}
	if MouseNeedsToBeMoved
	{
		SetMouseDelay, -1  ; Makes movement smoother.
		MouseMove, DeltaX * CurrentJoyMultiplier, DeltaY * CurrentJoyMultiplier * YAxisMultiplier, 0, R
	}
	return

MouseWheel:
	if (CurrentLevel < LEVEL_EVERYTHING) {
		return
	}
	GetKeyState, Joy2Y, %JoystickNumber%JoyR
	if Joy2Y > %JoyThresholdUpper%
		Send {WheelDown}
	else if Joy2Y < %JoyThresholdLower%
		Send {WheelUp}
	GetKeyState, Joy2X, %JoystickNumber%JoyU
	if Joy2X > %JoyThresholdUpper%
		Send {WheelRight}
	else if Joy2X < %JoyThresholdLower%
		Send {WheelLeft}
	return
	
KeyboardDirections:
	if (CurrentLevel < LEVEL_EVERYTHING) {
		return
	}
	GetKeyState, JoyPOV, %JoystickNumber%JoyPOV
	if JoyPOV = -1
		return
	JoyPOV := JoyPOV / 4500
	if JoyPOV = 0
		send {Up}
	else if JoyPOV = 1
		send {Up}{Right}
	else if JoyPOV = 2
		send {Right}
	else if JoyPOV = 3
		send {Down}{Right}
	else if JoyPOV = 4
		send {Down}
	else if JoyPOV = 5
		send {Down}{Left}
	else if JoyPOV = 6
		send {Left}
	else
		send {Up}{Left}
	return
	
SpecialButtons:
	if (CurrentLevel < LEVEL_EVERYTHING) {
		return
	}
	State := XInput_GetState(%JoystickNumber%-1)
	if (State.wButtons = ToDesktopCombo)
	{
		Send #d
		Sleep 600
	}
	return
	
EmergencyCombo:
	if ((GamepadReady <> 1) || (BlockingEnabled <> 1)) {
		return
	}
	State := XInput_GetState(%JoystickNumber%-1)
	if (State.wButtons = EmergencyCombo)
	{
		if (EmergencyEnabled = 0)
		{
			NotifyUser("Emergency ON", "Mode activated")
			EmergencyEnabled := 1
		}
		else
		{
			NotifyUser("Emergency OFF", "Mode deactivated")
			EmergencyEnabled := 0
		}
		Sleep 600
		return
	}
	return
	
CheckMode:
	if State := XInput_GetState(%JoystickNumber%-1)
	{
		if GamepadReady <> 1
		{
			NotifyUser("Gamepad", "Ready")
			CurrentLevel := ExpectedLevel
		}
		GamepadReady := 1
	}
	else
	{
		if GamepadReady <> 0
		{
			NotifyUser("Gamepad", "Disconnected")
		}
		GamepadReady := 0
		CurrentLevel := LEVEL_NOTHING
		return
	}
	if GamepadReady <> 1
	{
		CurrentLevel := LEVEL_NOTHING
		return
	}
	if DetectBlockingApplication()
	{
		BlockingEnabled := 1
		if EmergencyEnabled
		{
			CurrentLevel := LEVEL_MOUSE
		}
		else
		{
			CurrentLevel := LEVEL_NOTHING
		}
		return
	}
	else
	{
		if (EmergencyEnabled = 1) {
			NotifyUser("Emergency OFF", "Mouse deactivated")
			EmergencyEnabled := 0
		}
		BlockingEnabled := 0
		CurrentLevel := ExpectedLevel
	}
	LT := State.bLeftTrigger
	RT := State.bRightTrigger
	if (RT > TriggerThreshold && LT > TriggerThreshold)
	{
		if (ExpectedLevel = LEVEL_NOTHING) {
			ExpectedLevel := LEVEL_EVERYTHING
			NotifyUser("Status", "Gamepad ENABLED")
		} else {
			ExpectedLevel := LEVEL_NOTHING
			NotifyUser("Status", "Gamepad DISABLED")
		}
		CurrentLevel := ExpectedLevel
		Sleep 1000
		return
	}
	return