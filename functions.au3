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

	Local $defaultComMojang_packs = FileGetAttrib($comMojang_packs & "\com.mojang")
	If $defaultComMojang_packs = "D" Then ; Default com.mojang folder still exists
		DirMove($comMojang_packs & "\com.mojang", $comMojang_packs & "\com.mojang_default")
	EndIf

	Local $defaultComMojang = FileGetAttrib($comMojang & "\com.mojang")
	If $defaultComMojang = "D" Then ; Default com.mojang folder still exists
		DirMove($comMojang & "\com.mojang", $comMojang & "\com.mojang_default")
	EndIf

	Local $selectedProfile = GUICtrlRead($gui_profileList)

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
EndFunc   ;==>loadProfile

Func launchMinecraft()

EndFunc

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
