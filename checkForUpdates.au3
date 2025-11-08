Func checkForUpdates($outputMsg)
	Local $ping = Ping("TheAlienDoctor.com")
	Local $noInternetMsgBox = 0

	If $ping > 0 Then
		DirCreate(@ScriptDir & "\temp\")
		InetGet("https://updates.thealiendoctor.com/profile-switcher.ini", @ScriptDir & "\temp\versions.ini", 1)
		Local $latestNum = IniRead(@ScriptDir & "\temp\versions.ini", "latest", "latest-version-num", "0")

		If $latestNum > $updateNum Then
			Local $updateMsg = IniRead(@ScriptDir & "\temp\versions.ini", $latestNum, "update-message", "")
			Local $updateMsgBox = MsgBox(4, $gui_title, "There is a new update out now!" & @CRLF & $updateMsg & @CRLF & @CRLF & "Would you like to download it?")

			If $updateMsgBox = 6 Then
				ShellExecute("https://www.thealiendoctor.com/downloads/profile-switcher")
				Exit
			EndIf
		Else
			If $outputMsg = 1 Then
				MsgBox(0, $gui_title, "No new updates found." & @CRLF & "You're up-to-date!")
			EndIf
		EndIf

	Else ;If ping is below 0 then update server is down, or user is not connected to the internet
		$noInternetMsgBox = MsgBox(6, $gui_title, "Warning: You are not connected to the internet or TheAlienDoctor.com is unavailable. This means the update checker could not run. Continue?")
	EndIf

	If $noInternetMsgBox = 2 Then ;Cancel
		Exit

	ElseIf $noInternetMsgBox = 10 Then ;Try again
		checkForUpdates(1)

	ElseIf $noInternetMsgBox = 11 Then ;Continue
	EndIf

	DirRemove(@ScriptDir & "\temp\", 1)
EndFunc   ;==>checkForUpdates