SwitchedMode := 1
CurrentMode := 1
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
SetTimer, MouseWheel, 40
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
	GetKeyState, Joy2X, %JoystickNumber%JoyR
	if Joy2X > %JoyThresholdUpper%
		Send {WheelDown}
	else if Joy2X < %JoyThresholdLower%
		Send {WheelUp}
	GetKeyState, Joy2Y, %JoystickNumber%JoyU
	if Joy2Y > %JoyThresholdUpper%
		Send {WheelRight}
	else if Joy2Y < %JoyThresholdLower%
		Send {WheelLeft}
	return

CheckMode:
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