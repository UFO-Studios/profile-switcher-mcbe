#include <ButtonConstants.au3>
#include <ComboConstants.au3>
#include <GUIConstantsEx.au3>
#include <StaticConstants.au3>
#include <TabConstants.au3>
#include <WindowsConstants.au3>
#include <MsgBoxConstants.au3>
#include <File.au3>
#include <Array.au3>
#include <MsgBoxConstants.au3>
#include <SecurityConstants.au3>

#include "_GetReparseTarget.au3"

Func getProfiles()

	GUICtrlSetData($gui_profileList, $loadedProfile)

	Local $sSearch = FileFindFirstFile($profileFolder & "\*")
	If $sSearch = -1 Then Return SetError(2, 0, 0)

	Local $iCount = 0, $sFile
	While 1
		$sFile = FileFindNextFile($sSearch)
		If @error Then ExitLoop

		If @extended = 1 And $sFile <> "." And $sFile <> ".." Then
			GUICtrlSetData($gui_profileList, $sFile)
			$iCount += 1
		EndIf
	WEnd
EndFunc   ;==>getProfiles

Func getComMojangDir()
	Local $fileList = _FileListToArray(@AppDataDir & "\Minecraft Bedrock\Users")
	If $fileList[0] = 2 Then
	Else
		MsgBox(0, $gui_title, "Multiple Minecraft accounts found!" & @CRLF & "Please delete any files from left over profiles and try again. Multi-account support coming soon.")
		Return
	EndIf
	Return @AppDataDir & "\Minecraft Bedrock\Users\" & $fileList[1] & "\games"
EndFunc   ;==>getComMojangDir

Func loadProfile()
	Local $selectedProfile = GUICtrlRead($gui_profileList)

	If $selectedProfile = $loadedProfile Then ; Check if profile is already loaded
		$confirm = MsgBox(1, $gui_title, "That profile is already loaded. Would you like to reload it?")
		If $confirm = 2 Then
			Return
		EndIf
	EndIf

	disableGUI()

	Local $defaultComMojang_packs = FileGetAttrib($comMojang_packs & "\com.mojang")
	If $defaultComMojang_packs = "D" Then ; Default com.mojang folder still exists
		DirMove($comMojang_packs & "\com.mojang", $comMojang_packs & "\com.mojang_default")
	EndIf

	Local $defaultComMojang = FileGetAttrib($comMojang & "\com.mojang")
	If $defaultComMojang = "D" Then ; Default com.mojang folder still exists
		DirMove($comMojang & "\com.mojang", $comMojang & "\com.mojang_default")
	EndIf

	If checkSymLink($comMojang & "\com.mojang") = True Then ; Update SymLink
		DirRemove($comMojang & "\com.mojang") ; Delete symlink so we can recreate it
	EndIf

	If checkSymLink($comMojang_packs & "\com.mojang") = True Then ; Update SymLink
		DirRemove($comMojang_packs & "\com.mojang") ; Delete symlink so we can recreate it
	EndIf

	createSymLink($comMojang_packs & "\com.mojang", @ScriptDir & "\Profiles\" & $selectedProfile, 1)
	createSymLink($comMojang & "\com.mojang", @ScriptDir & "\Profiles\" & $selectedProfile, 1)

	$loadedProfile = $selectedProfile
	$loadedProfileDir = _GetReparseTarget($comMojang & "\com.mojang")
	IniWrite("data.ini", "Data", "loadedProfile", $loadedProfile)
	IniWrite("data.ini", "Data", "loadedProfileDir", $loadedProfileDir)

	enableGUI()
	GUICtrlSetData($gui_loadedProfileLabel, "Loaded Profile: " & $loadedProfile)
EndFunc   ;==>loadProfile

Func importProfile()
	disableGUI()
	Local $imported = 0 ; Not yet imported
	Local $imported_packs = 0 ; Not yet imported packs

	If FileExists($comMojang & "\com.mojang_default") = True Then ; Symlink has already been created and default folder renamed
		DirCopy($comMojang & "\com.mojang_default", $profileFolder & "\com.mojang_default", 1) ; Move to profiles folder
		$imported = 1
	EndIf
	If FileExists($comMojang_packs & "\com.mojang_default") = True Then ; Symlink has already been created and default folder renamed
		DirCopy($comMojang_packs & "\com.mojang_default", $profileFolder & "\com.mojang_default", 1) ; Move to profiles folder
		$imported_packs = 1
	EndIf

	If FileExists($comMojang & "\com.mojang") Then
		If checkSymLink($comMojang & "\com.mojang") = False Then ; Symlink has not been created
			DirCopy($comMojang & "\com.mojang", $profileFolder & "\com.mojang", 1)
			$imported = 1
		EndIf
	EndIf

		If FileExists($comMojang_packs & "\com.mojang") Then
		If checkSymLink($comMojang_packs & "\com.mojang") = False Then ; Symlink has not been created
			DirCopy($comMojang_packs & "\com.mojang", $profileFolder & "\com.mojang", 1)
			$imported = 1
		EndIf
	EndIf
	enableGUI()
EndFunc   ;==>importProfile

Func checkLoadedProfile() ; Not working yet. Doesn't seem to be disabling the GUI when running in AdLib.
	$selectedProfile = GUICtrlRead($gui_profileList)
	$loadedProfile = IniRead(@ScriptDir & "\data.ini", "data", "loadedProfile", "")

	If $loadedProfile = $selectedProfile Then
		GUISetState($gui_selectProfileBtn, $GUI_DISABLE)
	Else
		GUISetState($gui_selectProfileBtn, $GUI_ENABLE)
	EndIf
EndFunc   ;==>checkLoadedProfile

Func launchMinecraft()
	disableGUI()
	Run(getMinecraftFilePath(0))
	Sleep(5000)
	enableGUI()
EndFunc   ;==>launchMinecraft

Func getMinecraftFilePath($preview) ; Search all the drives to find Minecraft installation
	Local $filePath = ""

	If $preview = 1 Then
		$filePath = "XboxGames\Minecraft for Windows\Content\Minecraft.Windows.exe"
	ElseIf $preview = 0 Then
		$filePath = "XboxGames\Minecraft for Windows\Content\Minecraft.Windows.exe"
	EndIf
	Local $drives = DriveGetDrive("ALL")

	; Loop through each drive
	For $i = 1 To $drives[0]
		Local $drive = $drives[$i]

		; Check if drive is ready (avoid empty CD or network drive delays)
		If DriveStatus($drive) = "READY" Then
			Local $fullPath = $drive & "\" & $filePath
			If FileExists($fullPath) Then
				Return $fullPath
			EndIf
		EndIf
	Next

	; Not found
	MsgBox(0, $gui_title, "Could not find Minecraft installed.")
	Return ""
EndFunc   ;==>getMinecraftFilePath

Func disableGUI()
	GUICtrlSetState($gui_profileList, $GUI_DISABLE)
	GUICtrlSetState($gui_selectProfileBtn, $GUI_DISABLE)
	GUICtrlSetState($gui_launchMinecraftBtn, $GUI_DISABLE)
	GUICtrlSetState($gui_importDefaultProfile, $GUI_DISABLE)
EndFunc   ;==>disableGUI

Func enableGUI()
	GUICtrlSetState($gui_profileList, $GUI_ENABLE)
	GUICtrlSetState($gui_selectProfileBtn, $GUI_ENABLE)
	GUICtrlSetState($gui_launchMinecraftBtn, $GUI_ENABLE)
	GUICtrlSetState($gui_importDefaultProfile, $GUI_ENABLE)
EndFunc   ;==>enableGUI

; Parameter(s):     $qLink              = The file or directory you want to create.
;                   $qTarget            = The location $qLink should link to.
;                   $qIsDirectoryLink   = 0 for a FILE symlink (default).
;                                         1 for a DIRECTORY symlink.
Func createSymLink($qLink, $qTarget, $qIsDirectoryLink = 0)

	If FileExists($qLink) Then
		SetError(2)
		Return 0
	EndIf

	DllCall("kernel32.dll", "BOOLEAN", "CreateSymbolicLink", "str", $qLink, "str", $qTarget, "DWORD", Hex($qIsDirectoryLink))
	If @error Then
		SetError(1, @extended, 0)
		Return
	EndIf

	Return $qLink

EndFunc   ;==>createSymLink

Func checkSymLink($string)
	Local $FILE_ATTRIBUTE_REPARSE_POINT = 0x400
	If Not FileExists($string) Then
		Return SetError(1, 0, '')
	EndIf
	$rc = DllCall('kernel32.dll', 'Int', 'GetFileAttributes', 'str', $string)
	If IsArray($rc) Then
		If BitAND($rc[0], $FILE_ATTRIBUTE_REPARSE_POINT) = $FILE_ATTRIBUTE_REPARSE_POINT Then
			Return True
		EndIf
	EndIf
	Return False
EndFunc   ;==>checkSymLink
