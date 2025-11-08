#cs ----------------------------------------------------------------------------

 AutoIt Version: 3.3.16.1
 Author:         TheAlienDoctor

 Script Function:
	A profile switcher for Minecraft Bedrock. Compatible with 1.21.120+.

#ce ----------------------------------------------------------------------------

#RequireAdmin
#include "functions.au3"

; Compile Settings
#pragma compile(Compatibility, XP, vista, win7, win8, win81, win10, win11)
#pragma compile(FileDescription, A profile switcher for Minecraft Bedrock. Compatible with 1.21.120+)
#pragma compile(ProductName, Alien's Profile Switcher for Minecraft Bedrock)
#pragma compile(ProductVersion, 0.1.0)
#pragma compile(FileVersion, 0.1.0)
#pragma compile(LegalCopyright, ©UFO Studios)
#pragma compile(CompanyName, UFO Studios)
#pragma compile(OriginalFilename, ProfileSwitcher-B0.1.0.exe)

; Variables
Global $versionNum = "B0.1.0"
Global $copyright = "© UFO Studios 2025"
Global $gui_title = "Alien's MCBE Profile Switcher - " & $versionNum

Global $profileFolder = @ScriptDir & "\Profiles"
Global $loadedProfile = IniRead(@ScriptDir & "\data.ini", "data", "loadedProfile", "")
Global $loadedProfileDir = IniRead(@ScriptDir & "\data.ini", "data", "loadedProfileDir", "")

Global $comMojang_packs = @AppDataDir & "\Minecraft Bedrock\Users\Shared\games"
Global $comMojang = getComMojangDir()

; GUI
; Copy paste below so GUI starts centered, because Koda doesn't let us do it automatically :(
; Global $gui = GUICreate("" & $gui_title & "", 370, 138)
#Region ### START Koda GUI section ### Form=d:\06 code\profile-switcher-mcbe\gui.kxf
Global $gui = GUICreate("" & $gui_title & "", 370, 138)
Global $gui_profileList = GUICtrlCreateCombo("", 16, 32, 337, 25, BitOR($CBS_DROPDOWNLIST, $CBS_AUTOHSCROLL))
Global $gui_selectProfileBtn = GUICtrlCreateButton("Select Profile", 16, 72, 75, 25)
Global $gui_launchMinecraftBtn = GUICtrlCreateButton("Launch Minecraft", 264, 72, 91, 25)
Global $gui_importDefaultProfile = GUICtrlCreateButton("Import Default Profile", 96, 72, 107, 25)
Global $gui_VersionNumLabel = GUICtrlCreateLabel("Version: " & $versionNum & "", 216, 112, 141, 17, $SS_RIGHT)
Global $gui_copyright = GUICtrlCreateLabel("" & $copyright & "", 16, 112, 119, 17)
Global $gui_loadedProfileLabel = GUICtrlCreateLabel("Loaded Profile: " & $loadedProfile & "", 16, 8, 179, 17)
GUISetState(@SW_SHOW)
#EndRegion ### END Koda GUI section ###

; Script Start

getProfiles()

While 1
	$nMsg = GUIGetMsg()
	Switch $nMsg

		Case $gui_selectProfileBtn
			loadProfile()

		Case $gui_importDefaultProfile
			importProfile()

		Case $gui_launchMinecraftBtn
			launchMinecraft()

		Case $GUI_EVENT_CLOSE
			Exit
	EndSwitch
WEnd
