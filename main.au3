#cs ----------------------------------------------------------------------------

 AutoIt Version: 3.3.16.1
 Author:         TheAlienDoctor

 Script Function:
	A profile switcher for Minecraft Bedrock. Compatible with 1.21.120+.

#ce ----------------------------------------------------------------------------

#include "functions.au3"
#RequireAdmin

; Variables
Global $gui_title = "Alien's MCBE Profile Switcher"

Global $profileFolder = @ScriptDir & "\Profiles"
Global $loadedProfile = IniRead(@ScriptDir & "\data.ini", "data", "loadedProfile", "")
Global $loadedProfileDir = IniRead(@ScriptDir & "\data.ini", "data", "loadedProfileDir", "")

Global $comMojang_packs = @AppDataDir & "\Minecraft Bedrock\Users\Shared\games"
Global $comMojang = getComMojangDir()

; GUI
#Region ### START Koda GUI section ### Form=d:\06 code\profile-switcher-mcbe\gui.kxf
Global $gui = GUICreate("" & $gui_title & "", 373, 110, 1044, 660)
Global $gui_profileList = GUICtrlCreateCombo("", 16, 24, 337, 25, BitOR($CBS_DROPDOWN,$CBS_AUTOHSCROLL))
Global $gui_selectProfileBtn = GUICtrlCreateButton("Select Profile", 16, 64, 75, 25)
Global $gui_launchMc = GUICtrlCreateButton("Launch Minecraft", 96, 64, 91, 25)
GUISetState(@SW_SHOW)
#EndRegion ### END Koda GUI section ###

; Script Start

getProfiles()

While 1
	$nMsg = GUIGetMsg()
	Switch $nMsg

		Case $gui_selectProfileBtn
			loadProfile()

		Case $GUI_EVENT_CLOSE
			Exit
	EndSwitch
WEnd
