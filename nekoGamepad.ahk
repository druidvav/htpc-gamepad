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
MouseButtonLeft = 1
MouseButtonRight = 2
KeyboardButton = 4
BackspaceButton = 5
EnterButton = 6
AltF4Button = 7
; END OF CONFIG SECTION

#SingleInstance
#Include XInput.ahk
XInput_Init()
#Include Library.ahk