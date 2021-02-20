local L = LibStub("AceLocale-3.0"):NewLocale("AVR", "frFR", false)

if not L then return end

-- common
L["addon_name"] = "AVR"
L["Yes"] = "Oui"
L["No"] = "Non"
L["scene"] = "sc\195\168ne"
L["raid"] = "raid"
L["party"] = "groupe"
L["guild"] = "guilde"
L["battleground"] = "champ de bataille"
L["whisper"] = "en wisp"
L["Scene"] = "Sc\195\168ne"
L["Mesh"] = "Objet"
L["Raid"] = "Raid"
L["Party"] = "Groupe"
L["Guild"] = "Guilde"
L["Battleground"] = "Champ de bataille"
L["Whisper"] = "En wisp"

-- common options
L["Name"] = "Nom"
L["Select"] = "S\195\169lection"
L["Remove"] = "Supprimer"
L["Visible"] = "Visible"

-- Core
L["Received AVR scene from %s"] = "Sc\195\168ne AVR re\195\167u de %s"
L["Couldn't deserialized AVR addon message from %s %s"] = true
L["Can't send a scene from someone else. Make own copy first."] = true
L["Sending scene to %s"] = true
L["Import scene"] = "Importer une sc\195\168ne"
L["Import scene desc"] = "Importer une sc\195\168ne pr\195\169c\195\169dament export\195\169e"
L["Export scene"] = "Exporter une sc\195\168ne"
L["Copy this to clipboard"] = "Copier ceci dans le presse-papiers"
L["Paste exported scene here"] = "Coller la sc\195\168ne export\195\169e ici"
L["Couldn't deserialized imported scene"] = true
L["Version check"] = "V\195\169rifier les Versions"
L["Sending version check"] = "Lancement de la v\195\169rification de version"
L["Version check finished. Got %s replies."] = "V\195\169rification de version fini. Vous avez %s r\195\169ponses"
L["Version check available only in raids"] = "V\195\169rification de version possible que en raid"

-- SceneManager
L["Loaded scene had invalid scene id, reassigning"] = true
L["Trying to unpack scene, unknown class %s"] = true
L["Received scene with class %s but that class is not receivable"] = true

-- Scene
L["Trying to unpack mesh, unknown class %s"] = true
L["Received mesh with class %s but that class is not receivable"] = true
L["Normal scene"] = true
L["UNKNOWN SCENE"] = "C'est une sc\195\168ne de type \"%s\". "..
"AVR could not recognize this type and thus cannot display or otherwise handle this scene. "..
"This is most likely caused by an outdated version of AVR or a missing plugin."

-- mesh
L["unnamed"] = "Pas de nom"
L["Compass"] = "Boussole"
L["Circle"] = "Cercle"
L["Filled circle"] = "Cercle plein"
L["Cone"] = "C\195\180ne"
L["Player marker"] = "Marqueur de joueur"
L["Vargoth"] = true
L["Blink"] = "Clignotement"
L["Position Crosshair"] = "Position de la croix"
L["Target marker"] = "Marqueur de la cible"
L["Yard stick"] = "Echelle gradu\195\169"
L["Draw line"] = "Dessiner"
L["Draw line desc"] = "D\195\169ssiner une ligne du joueur au marqueur cibl\195\169"
L["Arrow"] = "Fl\195\170che"
L["Timer circle"] = true

L["UNKNOWN MESH"] = "C'est un objet de type \"%s\". "..
"AVR could not recognize this type and thus cannot display or otherwise handle this mesh. "..
"This is most likely caused by an outdated version of AVR or a missing plugin."

-- options de sc\195\169nario
L["Color"] = "Couleur"
L["Radius"] = "Rayon"
L["Range"] = "Port\195\169e"
L["Angle"] = "Angle"
L["Line width"] = "Largeur de ligne"
L["Follow behavior"] = "Suivre le comportement"
L["Follow unit"] = "Suivre l'unit\195\169"
L["Follow unit desc"] = "Faire suivre l'unit\195\169 par l'objet. Cela ne fonctionne qu'avec les personnes de votre groupe ou de votre raid. Vous pouvez sp\195\169cifier la cible ou le focus etc mais ceci ne fonctionnera que ci c'est un personnage joueur du raid. Les curseurs de position ci-dessous doivent \195\170tre \195\160 0 au centre de l'objet sur la cible."
L["Attach"] = "Attacher"
L["Attach desc"] = "Faire suivre le joueur par l'objet et ajuste automatiquement sa position de mani\195\168re \195\160 ce qu'elle conserve sa position actuelle par rapport au joueur."
L["Detach"] = "D\195\169tacher" 
L["Detach desc"] = "Arr\195\169ter de faire suivre le joueur par l'objet et ajuster automatiquement sa position afin qu'il conserve sa position actuelle par rapport au joueur."
L["Attach rotation"] = "Attacher une rotation"
L["Detach rotation"] = "D\195\169tacher une rotation"
L["Mesh deform"] = "D\195\169former l'objet"
L["Drag"] = "D\195\169placer"
L["Drag desc"] = "D\195\169placer l'objet en le faisant glisser dans la zone 3D. Arr\195\169ter le d\195\169placement avec un clique droit."
L["X Position"] = true
L["Y Position"] = true
L["Z Position"] = true
L["X Scale"] = "Echelle de X"
L["Y Scale"] = "Echelle de Y"
L["Z Scale"] = "Echelle de Z"
L["Z Rotate"] = "Rotation sur Z"

L["Circle properties"] = "propri\195\169t\195\169s du cercle"
L["Segments"] = "Segments"
L["Dashed"] = "Pointill\195\169s"
L["Cone properties"] = "Propri\195\169t\195\169s du c\195\180ne"

L["Yard stick properties"] = "Propri\195\169t\195\169s de ???"
L["Min"] = "Minimum"
L["Max"] = "Maximum"
L["Vertical"] = "Vertical"
L["Divisions"] = "Divisions"

L["Marker properties"] = "Propri\195\169t\195\169s des marqueurs"
L["Class color"] = "Couleur des classes"
L["Spokes"] = "Rayons"

L["Raid icon"] = "Icone de raid"
L["Raid icon properties"] = "Propri\195\169t\195\169s des icones de raid"
L["Use default color"] = "Utiliser la couleur par d\195\169faut"
L["Size"] = "Taille"
L["Star"] = "Etoile"
L["Circle"] = "Cercle"
L["Diamond"] = "Diamand"
L["Triangle"] = "Triangle"
L["Moon"] = "Lune"
L["Square"] = "Carr\195\169"
L["Cross"] = "Croix"
L["Skull"] = "cr\195\162ne"

L["Arrow properties"] = "Propri\195\169t\195\169s de la fl\195\170che"
L["Length"] = "Longueur"
L["Width"] = "Largeur"
L["Head size"] = "Taille de la pointe"

L["Data mesh properties"] = "Propri\195\169t\195\169s des donn\195\169es du sc\195\169nario"
L["Line width"] = "Largeur de la ligne"

-- edition
L["Remove mesh"] = "Supprimer l'objet"
L["Remove mesh desc"] = "Supprimer l'objet de la sc\195\168ne"
L["Edit mesh"] = "Editer l'objet"
L["Rotate"] = "Rotation"
L["Scale X"] = "Elargir"
L["Add mesh"] = "Ajouter un objet"
L["Main menu"] = "Menu principal"
L["Mesh name desc"] = "Nommer l'objet"
L["Scene name desc"] = "Nommer la sc\195\168ne"
L["Select scene desc"] = "S\195\169lectionnez la sc\195\168ne \195\160 \195\169diter"
L["Select mesh desc"] = "S\195\169l\195\168ctionner l'objet \195\160 \195\169diter. Vosu pouvez aussi cliquer dessus dans la zone 3D."


-- RangeWarning
L["Range Warning"] = "Distance d'alerte"
L["Draw circle"] = "Dessiner un cercle"
L["Draw circle desc"] = "Ajouter un cercle de port\195\169e \195\160 port\195\169e de danger."
L["Range range desc"] = "Port\195\169e \195\160 l'int\195\169rieur duquel les marqueurs sont visibles"
L["Range radius desc"] = "Rayon du marqueur"

-- ZoneInfo
L["The Frozen Throne"] = true -- Minimap zone text in Icecrown raid

-- MeshEdit
L["Mesh edit"] = "Edition d'objet"
L["Start edit"] = "Commencer l'\195\169dition"
L["Stop edit"] = "Stopper l'\195\169dition"
L["Add vertices"] = "Ajouter un sommet"
L["Delete vertices"] = "Supprimer le sommet"
L["Add triangle"] = "Ajouter un triangle"
L["Remove triangle"] = "Supprimer le triangle"
L["New mesh"] = "Nouvel objet"

-- Options

L["New %s"] = "Nouveau"
L["Clear scene"] = "Nettoyer la sc\195\168ne"
L["Clear scene desc"] = "Supprimer tous les objets de la sc\195\168ne"
L["Remove scene"] = "Supprimer la sc\195\168ne"
L["Remove scene desc"] = "Supprimer compl\195\168tement la sc\195\168ne et tous les objets qu'elle contient"
L["Zone"] = "Zone"
L["Zone desc"] = "Zone dans laquelle la sc\195\168ne est visible. Laisser blanc pour que la sc\195\168ne soit visible dans toutes les zones."
L["Current zone"] = "Zone actuelle"
L["Current zone desc"] = "D\195\169finir la zone actuelle comme Zone."
L["Share"] = "Partager"
L["Channel"] = "Zone de discution"
L["Channel desc"] = "Zone de discution dans lequel l'addon discutera. Ce n'est pas la m\195\170me que les fen\195\170tres de discution normales."
L["Whisper target"] = "Cible du wisp"
L["Whisper target desc"] = "Nom du joueur cibl\195\169 si la zone de discution est d\195\169finit sir En Wisp"
L["Send"] = "Envoyer"
L["Import"] = "Importer"
L["Export to clipboard"] = "Exporter dans le presse-papiers"
L["Scene id"] = "ID de la sc\195\168ne"
L["Owner"] = "Propri\195\169taire"
L["Make own copy"] = "Faire une copie"
L["Make own copy desc"] = "Faire une copie de la sc\195\168ne en tant que propri\195\169taire. ceci est pour les sc\195\168nes que vosu avez re\195\167u des autres."
L["Paint"] = "Remplir"
L["Follow player"] = "Suivre un joueur"
L["Follow player desc"] = "Fait que l'objet suit le joueur. La position du curseur doit \195\170tre d\195\169finit \195\160 0 pour centrer l'objet sur le joueur ou avec un l\195\169ger d\195\169calage. Vous pouvez \195\169galement utiliser el bouton Attacher."
L["Follow rotation"] = "Suivre la rotation"
L["Follow rotation desc"] = "Fait que l'objet tourne avec le joueur. Cela ne doit pas \195\170tre utilis\195\169 avec Suivre un joueur ou Suivre une unit\195\169."
L["Detail level"] = "Niveau de d\195\169tail"
L["Start"] = "Commencer"
L["Meshes"] = "Objets"
L["Meshes desc"] = "Tous les objets contenus dans cette sc\195\168ne"
L["Add new mesh"] = "Ajouter un nouvel objet"
L["Add"] = "Ajouter"
L["Archmage Vargoth spawn point"] = true
L["Blink location"] = "Point clignottant"
L["Crosshair"] = "Croix"
L["Unit marker"] = "marqueur d'unit\195\169"
L["Unit"] = "Unit\195\169"
L["Range warning"] = "Alerte de distance"
L["New scene"] = "Nouvelle Sc\195\168ne"
L["Menu"] = "Menu"
L["General"] = "G\195\169n\195\169ral"
L["Enable"] = "Activer"
L["Enable desc"] = "Activer ou d\195\169sactiver l'addon"
L["Hide all"] = "Tous cacher"
L["Hide all desc"] = "Cacher tous les objets 3D mais laisser l'addon touner"
L["Open scene editor"] = "Ouvrir l'\195\169diteur de sc\195\168ne"
L["Open scene editor desc"] = "Ouvre une petite fen\195\170tre d'\195\169dition de sc\195\168ne qui facilite la cr\195\169ation des t\195\162ches quotidiennes."
L["Sharing"] = "Partager"
L["Accept incoming scenes from"] = "Acc\195\169pter les sc\195\168nes de:"
L["Receive own scenes"] = "Recever vos propres scn\195\168nes"
L["Receive own scenes desc"] = "Comment vos propres sc\195\168nes sont re\195\167u. 'Oui' acc\195\168pter les comme n'importe qu'elle autre sc\195\168ne et vous finirez avec 2 sc\195\168nes identiques. 'Non' supprimer les sc\195\168nes entrantes. 'Cach\195\169' acc\195\168pter les sc\195\168nes en les laissant invisibles."
L["As hidden"] = "Invisible"
L["Scenes"] = "Sc\195\168nes"
L["Raid leader"] = "Lead du raid"
L["Raid assist"] = "Assisstant du raid"
L["Raid others"] = "Membres du raid"
L["Party leader"] = "Lead du groupe"
L["Party others"] = "Membres du groupe"
L["Use texture"] = "Utiliser les textures"
L["Use texture desc"] = "Draw the mesh with a single texture instead of a polygon mesh. This is faster but may cause some visual artifacts for big meshes or when zooming close."
L["Use texture desc marker"] = "Draw the mesh with a single texture instead of a polygon mesh. This is faster but may cause some visual artifacts for big meshes or when zooming close. Spokes setting does not work with this."
L["Blacklist"] = true
L["Blacklist desc"] = "Scenes will not be accepted from these regardless of all other options"


L["About"] = "A propos"
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