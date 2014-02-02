#SingleInstance
#Include Library\KillXboxStat.ahk
#Include Library\KillTeamviewerPopup.ahk
#Include Library\XInput.ahk
XInput_Init()

; START OF CONFIG SECTION
JoyMultiplier = 0.30
JoyMultiplierSlower = 0.05
JoyThreshold = 10
TriggerThreshold = 100
InvertYAxis = 0
KeyboardRepeatTimeout = 600
KeyboardRepeatRate = 40
; Button mapping
JoystickNumber = 1
MouseButtonLeft = 1   ; A
MouseButtonRight = 2  ; B
KeyboardButton = 4    ; Y
BackspaceButton = 5   ; LB
EnterButton = 6       ; RB
AltF4Button = 7       ; Back
ToDesktopCombo := XINPUT_GAMEPAD_GUIDE + XINPUT_GAMEPAD_X
EmergencyCombo := XINPUT_GAMEPAD_GUIDE + XINPUT_GAMEPAD_Y
; END OF CONFIG SECTION

DetectBlockingApplication()
{
	ifWinExist Steam ahk_class CUIEngineWin32
	{ ; Steam big picture
		return 1
	}
	ifWinActive XBMC
	{
		return 1
	}
	return 0
}

#Include Library\Main.ahk