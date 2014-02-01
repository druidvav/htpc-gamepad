GamepadReady := -1
SwitchedMode := 1
CurrentMode := 2
MaxMode := 2

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
return

KeyboardButton:
	if CurrentMode > 1
		return
	Send, {Ctrl}{Alt}{Shift}-
	return
	
AltF4Button:
	if CurrentMode > 1
		return
	Send, {Alt}{F4}
	return

MouseButtonLeft:
	if CurrentMode > 1
		return
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
	if CurrentMode > 1
		return
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

BackspaceButton:
	if CurrentMode > 1
		return
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
	if CurrentMode > 1
		return
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

MouseMove:
	if CurrentMode > 1
		return
	MouseNeedsToBeMoved := false
	SetFormat, float, 03
	CurrentJoyMultiplier := JoyMultiplier
	if State := XInput_GetState(0)
	{		
		if State.bLeftTrigger > TriggerThreshold
		{
			CurrentJoyMultiplier := JoyMultiplierSlower
		}
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
	if CurrentMode > 1
		return
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
	if CurrentMode > 1
		return
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

CheckMode:
	if State := XInput_GetState(0)
	{
		if GamepadReady <> 1
		{
			TrayTip,Status,Gamepad ready,1,1
			CurrentMode := SwitchedMode
		}
		GamepadReady := 1
	}
	else
	{
		if GamepadReady <> 0
			TrayTip,Status,Gamepad disconnected,1,1
		GamepadReady := 0
		CurrentMode := 2
		return
	}
		
	if GamepadReady <> 1
	{
		return
	}

	ifWinExist Steam ahk_class CUIEngineWin32
	{
		CurrentMode := 2
		return
	}
	ifWinActive XBMC
	{
		CurrentMode := 2
		return
	}
	if State := XInput_GetState(0)
	{
		LT := State.bLeftTrigger
		RT := State.bRightTrigger
		if (RT > TriggerThreshold && LT > TriggerThreshold)
		{
			CurrentMode := CurrentMode + 1
			if CurrentMode > %MaxMode%
			{
				CurrentMode := 1
			}
			SwitchedMode := CurrentMode
			if CurrentMode = 2
				TrayTip,Mode changed,Gamepad is DISABLED,1,1
			else
				TrayTip,Mode changed,Gamepad is ENABLED,1,1
			Sleep 1000
			return
		}
	}
	if CurrentMode = 2
	{
		return
	}
	return