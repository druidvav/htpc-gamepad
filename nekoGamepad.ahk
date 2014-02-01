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
; END OF CONFIG SECTION

#SingleInstance
#Include XInput.ahk
XInput_Init()
#Include Library.ahk