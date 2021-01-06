local L = LibStub("AceLocale-3.0"):NewLocale("AVR", "enUS", true)

if not L then return end

-- common
L["addon_name"] = "AVR"
L["Yes"] = "Yes"
L["No"] = "No"
L["scene"] = true
L["raid"] = true
L["party"] = true
L["guild"] = true
L["battleground"] = true
L["whisper"] = true
L["Scene"] = true
L["Mesh"] = true
L["Raid"] = true
L["Party"] = true
L["Guild"] = true
L["Battleground"] = true
L["Whisper"] = true

-- common options
L["Name"] = true
L["Select"] = true
L["Remove"] = true
L["Visible"] = true

-- Core
L["Received AVR scene from %s"] = true
L["Couldn't deserialized AVR addon message from %s %s"] = true
L["Can't send a scene from someone else. Make own copy first."] = true
L["Sending scene to %s"] = true
L["Import scene"] = true
L["Import scene desc"] = "Import a previously exported scene"
L["Export scene"] = true
L["Copy this to clipboard"] = true
L["Paste exported scene here"] = true
L["Couldn't deserialized imported scene"] = true
L["Version check"] = true
L["Sending version check"] = true
L["Version check finished. Got %s replies."] = true
L["Version check available only in raids"] = true

-- SceneManager
L["Loaded scene had invalid scene id, reassigning"] = true
L["Trying to unpack scene, unknown class %s"] = true
L["Received scene with class %s but that class is not receivable"] = true

-- Scene
L["Trying to unpack mesh, unknown class %s"] = true
L["Received mesh with class %s but that class is not receivable"] = true
L["Normal scene"] = true
L["UNKNOWN SCENE"] = "This is a scene of type \"%s\". "..
"AVR could not recognize this type and thus cannot display or otherwise handle this scene. "..
"This is most likely caused by an outdated version of AVR or a missing plugin."

-- mesh
L["unnamed"] = true
L["Compass"] = true
L["Circle"] = true
L["Filled circle"] = true
L["Cone"] = true
L["Player marker"] = true
L["Vargoth"] = true
L["Blink"] = true
L["Position Crosshair"] = true
L["Target marker"] = true
L["Yard stick"] = true
L["Draw line"] = true
L["Draw line desc"] = "Draws a line from the player to the marker target"
L["Arrow"] = true
L["Timer circle"] = true

L["UNKNOWN MESH"] = "This is a mesh of type \"%s\". "..
"AVR could not recognize this type and thus cannot display or otherwise handle this mesh. "..
"This is most likely caused by an outdated version of AVR or a missing plugin."

-- mesh options
L["Color"] = true
L["Radius"] = true
L["Range"] = true
L["Angle"] = true
L["Line width"] = true
L["Follow behavior"] = true
L["Follow unit"] = true
L["Follow unit desc"] = "Makes the mesh follow the specified unit. This only works for people in your group or raid. You can specify 'target' or 'focus' etc but it will only work if that unit is a player character in your raid. The position sliders below should be at 0 to center the mesh on the target."
L["Attach"] = true
L["Attach desc"] = "Makes the mesh follow the player and automatically adjusts its position so that it keeps its current relative position to the player."
L["Detach"] = true 
L["Detach desc"] = "Stops the mesh from follow the player and automatically adjusts its position so that it keeps its current relative position to the player."
L["Attach rotation"] = true
L["Detach rotation"] = true
L["Mesh deform"] = true
L["Drag"] = true
L["Drag desc"] = "Move the mesh by dragging it in the 3d world. Stop dragging with right mouse button"
L["X Position"] = true
L["Y Position"] = true
L["Z Position"] = true
L["X Scale"] = true
L["Y Scale"] = true
L["Z Scale"] = true
L["Z Rotate"] = true

L["Circle properties"] = true
L["Segments"] = true
L["Dashed"] = true
L["Cone properties"] = true

L["Yard stick properties"] = true
L["Min"] = true
L["Max"] = true
L["Vertical"] = true
L["Divisions"] = true

L["Marker properties"] = true
L["Class color"] = true
L["Spokes"] = true

L["Raid icon"] = true
L["Raid icon properties"] = true
L["Use default color"] = true
L["Size"] = true
L["Star"] = true
L["Circle"] = true
L["Diamond"] = true
L["Triangle"] = true
L["Moon"] = true
L["Square"] = true
L["Cross"] = true
L["Skull"] = true

L["Arrow properties"] = true
L["Length"] = true
L["Width"] = true
L["Head size"] = true

L["Data mesh properties"] = true
L["Line width"] = true

-- edit
L["Remove mesh"] = true
L["Remove mesh desc"] = "Removes the mesh from scene"
L["Edit mesh"] = true
L["Rotate"] = true
L["Scale X"] = true
L["Add mesh"] = true
L["Main menu"] = true
L["Mesh name desc"] = "Mesh name"
L["Scene name desc"] = "Scene name"
L["Select scene desc"] = "Select the scene you want to edit"
L["Select mesh desc"] = "Select the mesh you want to edit. You can also click on it in the 3d world."


-- RangeWarning
L["Range Warning"] = true
L["Draw circle"] = true
L["Draw circle desc"] = "Adds a range circle at warning range."
L["Range range desc"] = "Range inside which markers are visible"
L["Range radius desc"] = "Radius of the markers"

-- ZoneInfo
L["The Frozen Throne"] = true -- Minimap zone text in Icecrown raid

-- MeshEdit
L["Mesh edit"] = true
L["Start edit"] = true
L["Stop edit"] = true
L["Add vertices"] = true
L["Delete vertices"] = true
L["Add triangle"] = true
L["Remove triangle"] = true
L["New mesh"] = true

-- Options

L["New %s"] = true
L["Clear scene"] = true
L["Clear scene desc"] = "Removes all meshes from the scene"
L["Remove scene"] = true
L["Remove scene desc"] = "Completely removes the scene and all meshes it contains"
L["Zone"] = true
L["Zone desc"] = "The zone where this scene is visible. Leave blank to have the scene visible in all zones."
L["Current zone"] = true
L["Current zone desc"] = "Sets zone to current zone."
L["Share"] = true
L["Channel"] = true
L["Channel desc"] = "Addon channel where the scene is sent. These aren't same as normal chat channels."
L["Whisper target"] = true
L["Whisper target desc"] = "Target player name if channel is set to whisper"
L["Send"] = true
L["Import"] = true
L["Export to clipboard"] = true
L["Scene id"] = true
L["Owner"] = true
L["Make own copy"] = true
L["Make own copy desc"] = "Makes a copy of the scene with you as the owner. This is for scenes you've received from others."
L["Paint"] = true
L["Follow player"] = true
L["Follow player desc"] = "Makes the mesh follow player. The position sliders should be set to 0 to center the mesh on player or to a small offset. You can also use the Attach button."
L["Follow rotation"] = true
L["Follow rotation desc"] = "Makes the mesh rotate with player. This shouldn't be used with follow player or follow unit."
L["Detail level"] = true
L["Start"] = true
L["Meshes"] = true
L["Meshes desc"] = "All the meshes contained in this scene"
L["Add new mesh"] = true
L["Add"] = true
L["Archmage Vargoth spawn point"] = true
L["Blink location"] = true
L["Crosshair"] = true
L["Unit marker"] = true
L["Unit"] = true
L["Range warning"] = true
L["New scene"] = true
L["Menu"] = true
L["General"] = true
L["Enable"] = true
L["Enable desc"] = "Enable or disable addon"
L["Hide all"] = true
L["Hide all desc"] = "Hide all 3d objects but otherwise keep the addon running"
L["Open scene editor"] = true
L["Open scene editor desc"] = "Opens a small scene editor window which is easier to use for common tasks than this full options dialog."
L["Sharing"] = true
L["Accept incoming scenes from"] = true
L["Receive own scenes"] = true
L["Receive own scenes desc"] = "How should scenes from yourself be received. 'Yes' accepts them as any other scene and you will end up with two identical scenes. 'No' discards the incoming scene. 'As hidden' accepts the scene but makes it invisible."
L["As hidden"] = true
L["Scenes"] = true
L["Raid leader"] = true
L["Raid assist"] = true
L["Raid others"] = true
L["Party leader"] = true
L["Party others"] = true
L["Use texture"] = true
L["Use texture desc"] = "Draw the mesh with a single texture instead of a polygon mesh. This is faster but may cause some visual artifacts for big meshes or when zooming close."
L["Use texture desc marker"] = "Draw the mesh with a single texture instead of a polygon mesh. This is faster but may cause some visual artifacts for big meshes or when zooming close. Spokes setting does not work with this."
L["Blacklist"] = true
L["Blacklist desc"] = "Scenes will not be accepted from these regardless of all other options"


L["About"] = true
L["Version"] = "AVR version "..GetAddOnMetadata("AVR","Version")
L["Copyright"] =
"Copyright 2010 Olog (contact through http://www.wowace.com/profiles/Olog/).\n"

L["License"] =
"This program is free software: you can redistribute it and/or modify "..
"it under the terms of the GNU General Public License as published by "..
"the Free Software Foundation, either version 3 of the License, or "..
"(at your option) any later version.\n"..
"\n"..
"This program is distributed in the hope that it will be useful, "..
"but WITHOUT ANY WARRANTY; without even the implied warranty of "..
"MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the "..
"GNU General Public License for more details.\n"..
"\n"..
"You should have received a copy of the GNU General Public License "..
"long with this program. If not, see <http://www.gnu.org/licenses/>."

L["PluginsLicense"] =
"Any 3rd party plugins are copyright of their respective authors and may be "..
"distributed under a different license."

L["LibCompressLicense"] =
"LibCompress Copyright Galmok, Allara, Jjsheets. Distributed under GNU Lesser General Public License."

L["LibBase64License"] =
"LibBase64 Copyright ckknight. Distributed under MIT License."

L["AceLicense"] =
"Ace3 framework License:\n"..
"\n"..
"Copyright (c) 2007, Ace3 Development Team\n"..
"\n"..
"All rights reserved.\n"..
"\n"..
"Redistribution and use in source and binary forms, with or without "..
"modification, are permitted provided that the following conditions are met:\n"..
"\n"..
"* Redistributions of source code must retain the above copyright notice, "..
  "this list of conditions and the following disclaimer.\n"..
"* Redistributions in binary form must reproduce the above copyright notice, "..
  "this list of conditions and the following disclaimer in the documentation "..
  "and/or other materials provided with the distribution.\n"..
"* Redistribution of a stand alone version is strictly prohibited without "..
  "prior written authorization from the Lead of the Ace3 Development Team.\n"..
"* Neither the name of the Ace3 Development Team nor the names of its contributors "..
  "may be used to endorse or promote products derived from this software without "..
  "specific prior written permission.\n"..
"\n"..
"THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "..
"\"AS IS\" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT "..
"LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR "..
"A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR "..
"CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, "..
"EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, "..
"PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR "..
"PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF "..
"LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING "..
"NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS "..
"SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE."