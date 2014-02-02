iMON_Init()
{
	global
	myHwnd := A_ScriptHwnd
	uMsg   := 0x8000+0x1001
	iMONhModule := DllCall("LoadLibrary","str","iMONDisplay")
	if !iMONhModule
	{
		MsgBox, Failed to initialize: dll not found.
	}
	return
}

iMON_VFD_Message(Line1, Line2, Timeout)
{
	global
	iMON_VFD_Message_Line1 := Line1
	iMON_VFD_Message_Line2 := Line2
	iMON_VFD_Message_Timeout := Timeout

	Result := DllCall("iMONDisplay\IMON_Display_Init","ptr",myHwnd,"UInt",uMsg)
	;TrayTip,,Init: %Result%,1,1
	SetTimer, iMON_VFD_Message_WaitInit, 200
	return
	
	iMON_VFD_Message_WaitInit: 
		SetTimer, iMON_VFD_Message_WaitInit, off
		Result := DllCall("iMONDisplay\IMON_Display_SetVfdText", "Str", iMON_VFD_Message_Line1, "Str", iMON_VFD_Message_Line2)
		;TrayTip,,SetVfdText: %Result% %iMON_VFD_Message_Line1% %iMON_VFD_Message_Line2% %iMON_VFD_Message_Timeout%,1,1
		SetTimer, iMON_VFD_Message_WaitTimeout, %iMON_VFD_Message_Timeout%
		return

	iMON_VFD_Message_WaitTimeout: 
		iMON_VFD_Message_Line1 := ""
		iMON_VFD_Message_Line2 := ""
		SetTimer, iMON_VFD_Message_WaitTimeout, off
		Result := DllCall("iMONDisplay\IMON_Display_Uninit")
		;TrayTip,,Uninit: %Result%,1,1
		return
}
