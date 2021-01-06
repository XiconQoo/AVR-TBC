local L = LibStub("AceLocale-3.0"):NewLocale("AVR", "zhTW", false)

if not L then return end

-- common
L["addon_name"] = "AVR"
L["Yes"] = "是"
L["No"] = "否"
L["scene"] = "場景"
L["raid"] = "團隊"
L["party"] = "小隊"
L["guild"] = "公會"
L["battleground"] = "戰場"
L["whisper"] = "悄悄話"
L["Scene"] = "場景"
L["Mesh"] = "圖形"
L["Raid"] = "團隊"
L["Party"] = "小隊"
L["Guild"] = "公會"
L["Battleground"] = "戰場"
L["Whisper"] = "悄悄話"

-- common options
L["Name"] = "名稱"
L["Select"] = "選擇"
L["Remove"] = "移除"
L["Visible"] = "可見性"

-- Core
L["Received AVR scene from %s"] = "從%s接受到 AVR 場景"
L["Couldn't deserialized AVR addon message from %s %s"] = "不能從%s %s非序列化 AVR 插件信息"
L["Can't send a scene from someone else. Make own copy first."] = "不能發送其他人的場景。先製作自己的場景。"
L["Sending scene to %s"] = "發送場景到%s"
L["Import scene"] = "導入場景"
L["Import scene desc"] = "入以前已導出的場景"
L["Export scene"] = "導出場景"
L["Copy this to clipboard"] = "複製到剪切板"
L["Paste exported scene here"] = "粘帖導出到這裡"
L["Couldn't deserialized imported scene"] = "不能非序列化導入場景"
L["Version check"] = "版本檢測"
L["Sending version check"] = "發送版本檢測"
L["Version check finished. Got %s replies."] = "版本檢測結束。收到%s個回饋。"
L["Version check available only in raids"] = "版本檢測只在團隊時可用"

-- SceneManager
L["Loaded scene had invalid scene id, reassigning"] = "加載無效的場景編號，重新指定"
L["Trying to unpack scene, unknown class %s"] = "嘗試解開場景，未知%s職業"
L["Received scene with class %s but that class is not receivable"] = "已接收場景包含%s職業但此職業不可接收"

-- Scene
L["Trying to unpack mesh, unknown class %s"] = "嘗試解開圖形，未知%s職業"
L["Received mesh with class %s but that class is not receivable"] = "已接收圖形包含%s職業但此職業不可接收"
L["Normal scene"] = "普通場景"
L["UNKNOWN SCENE"] = "此場景類型 \"%s\"。"..
"AVR 不能識別這種類型，因此不能顯示或以其他方式處理這個場景。"..
"這很可能是由於 AVR 版本過時或一個缺少插件的引起的。"

-- mesh
L["unnamed"] = "未命名"
L["Compass"] = "半圓"
L["Circle"] = "圓圈"
L["Filled circle"] = "填充圓圈"
L["Cone"] = "複製"
L["Player marker"] = "玩家標記"
L["Vargoth"] = "瓦戈斯"
L["Blink"] = "閃爍"
L["Position Crosshair"] = "十字線位置"
L["Target marker"] = "目標標記"
L["Yard stick"] = "碼尺"
L["Draw line"] = "畫線"
L["Draw line desc"] = "從玩家到目標標記畫一條線"
L["Arrow"] = "箭頭"
L["Timer circle"] = "計時圓圈"

L["UNKNOWN MESH"] = "此圖形類型 \"%s\"。"..
"AVR 不能識別這種類型，因此不能顯示或以其他方式處理這個圖形。"..
"這很可能是由於 AVR 版本過時或一個缺少插件的引起的。"

-- mesh options
L["Color"] = "顏色"
L["Radius"] = "半徑"
L["Range"] = "範圍"
L["Angle"] = "角度"
L["Line width"] = "線寬"
L["Follow behavior"] = "後續行為"
L["Follow unit"] = "後續單位"
L["Follow unit desc"] = "製作圖形跟隨特定單位。只在玩家位於小隊或團隊時可用。可以指定“目標”或“焦點”等，但是它只在玩家位於團隊時可用。滑塊位置應設置為0到中央圖形位於目標。"
L["Attach"] = "附加"
L["Attach desc"] = "製作圖形跟隨玩家並自動調整自身位置因此它繼續保持玩家相對位置。"
L["Detach"] = "分離"
L["Detach desc"] = "停止圖形跟隨玩家玩家並自動調整自身位置因此它繼續保持玩家相對位置。"
L["Attach rotation"] = "附加旋轉"
L["Detach rotation"] = "分離旋轉"
L["Mesh deform"] = ""
L["Drag"] = "拖拽"
L["Drag desc"] = "拖拽移動圖形到 3D 遊戲世界。鼠標右鍵停止拖拽"
L["X Position"] = "X 位置"
L["Y Position"] = "Y 位置"
L["Z Position"] = "Z 位置"
L["X Scale"] = "X 縮放"
L["Y Scale"] = "Y 縮放"
L["Z Scale"] = "Z 縮放"
L["Z Rotate"] = "Z 旋轉"

L["Circle properties"] = "圓圈屬性"
L["Segments"] = "線段"
L["Dashed"] = "虛線"
L["Cone properties"] = "複製屬性"

L["Yard stick properties"] = "碼尺屬性"
L["Min"] = "最小"
L["Max"] = "最大"
L["Vertical"] = "垂直"
L["Divisions"] = "分隔"

L["Marker properties"] = "標記屬性"
L["Class color"] = "職業顏色"
L["Spokes"] = "幅度"

L["Raid icon"] = "團隊標記"
L["Raid icon properties"] = "團隊標記屬性"
L["Use default color"] = "使用預設顏色"
L["Size"] = "大小"
L["Star"] = "星星"
L["Circle"] = "圈圈"
L["Diamond"] = "鑽石"
L["Triangle"] = "三角"
L["Moon"] = "月亮"
L["Square"] = "方形"
L["Cross"] = "十字"
L["Skull"] = "頭顱"

L["Arrow properties"] = "箭頭屬性"
L["Length"] = "長度"
L["Width"] = "寬度"
L["Head size"] = "頭部大小"

L["Data mesh properties"] = "數據圖形屬性"
L["Line width"] = "畫線長度"

-- edit
L["Remove mesh"] = "移除圖形"
L["Remove mesh desc"] = "從場景移除圖形"
L["Edit mesh"] = "編輯圖形"
L["Rotate"] = "旋轉"
L["Scale X"] = "X 縮放"
L["Add mesh"] = "添加圖形"
L["Main menu"] = "主目錄"
L["Mesh name desc"] = "圖形名稱描述"
L["Scene name desc"] = "場景名稱描述"
L["Select scene desc"] = "選擇需要編輯的場景"
L["Select mesh desc"] = "選擇需要編輯的圖形。也可在 3D 遊戲時間內點擊。"


-- RangeWarning
L["Range Warning"] = "範圍警報"
L["Draw circle"] = "畫圓圈"
L["Draw circle desc"] = "為警報範圍添加一個圓圈範圍。"
L["Range range desc"] = "範圍內標記為可見"
L["Range radius desc"] = "標記半徑"

-- ZoneInfo
L["The Frozen Throne"] = "冰封王座" -- Minimap zone text in Icecrown raid

-- MeshEdit
L["Mesh edit"] = "編輯圖形"
L["Start edit"] = "開始編輯"
L["Stop edit"] = "結束編輯"
L["Add vertices"] = "添加頂點"
L["Delete vertices"] = "刪除頂點"
L["Add triangle"] = "添加三角形"
L["Remove triangle"] = "移除三角形"
L["New mesh"] = "新圖形"

-- Options

L["New %s"] = "新%s"
L["Clear scene"] = "清除場景"
L["Clear scene desc"] = "從場景移除所有圖形"
L["Remove scene"] = "移除場景"
L["Remove scene desc"] = "移除全部場景和所有包含的圖形"
L["Zone"] = "區域"
L["Zone desc"] = "場景內可見區域。留空所有區域場景可見。"
L["Current zone"] = "當前區域"
L["Current zone desc"] = "設置當前區域到區域。"
L["Share"] = "共享"
L["Channel"] = "取消"
L["Channel desc"] = "場景通過插件頻道已經發送。此與普通聊天頻道不同。"
L["Whisper target"] = "悄悄話目標"
L["Whisper target desc"] = "設置悄悄話頻道為目標玩家名稱"
L["Send"] = "發送"
L["Import"] = "導入"
L["Export to clipboard"] = "導出到剪切板"
L["Scene id"] = "場景編號"
L["Owner"] = "所屬人"
L["Make own copy"] = "製作自己的複制"
L["Make own copy desc"] = "製作一個屬於你自己的場景。此場景是從其他玩家出接收的。"
L["Paint"] = "繪製"
L["Follow player"] = "跟隨玩家"
L["Follow player desc"] = "製作圖形跟隨玩家。滑塊位置應設置為0到中央圖形位於玩家或進行微小偏移。也可使用附加按鈕。"
L["Follow rotation"] = "跟隨旋轉"
L["Follow rotation desc"] = "製作旋轉玩家。此不能用於跟隨玩家或跟隨單位。"
L["Detail level"] = "詳細等級"
L["Start"] = "開始"
L["Meshes"] = "圖形"
L["Meshes desc"] = "所有圖形位於此場景"
L["Add new mesh"] = "添加新的圖形"
L["Add"] = "添加"
L["Archmage Vargoth spawn point"] = "大法師瓦戈斯出現地點"
L["Blink location"] = "閃爍位置"
L["Crosshair"] = "十字"
L["Unit marker"] = "單位標記"
L["Unit"] = "單位"
L["Range warning"] = "範圍警報"
L["New scene"] = "新場景"
L["Menu"] = "目錄"
L["General"] = "常用"
L["Enable"] = "啟用"
L["Enable desc"] = "啟用或禁用插件"
L["Hide all"] = "隱藏全部"
L["Hide all desc"] = "隱藏全部 3D 圖形但保持插件運行"
L["Open scene editor"] = "打開場景編輯器"
L["Open scene editor desc"] = "打開一個小型場景編輯器窗口用來更容易編輯常規任務而使用全選項對話。"
L["Sharing"] = "共享"
L["Accept incoming scenes from"] = "接收場景，來自"
L["Receive own scenes"] = "接收自製場景"
L["Receive own scenes desc"] = "應該如何從自己接收場景。“是”接受他們的任何其他場景，你會接收兩個相同的場景。“否”丟棄傳入的場景。“隱藏”接受場景，但其使不可見。"
L["As hidden"] = "隱藏"
L["Scenes"] = "場景"
L["Raid leader"] = "團隊領袖"
L["Raid assist"] = "團隊助理"
L["Raid others"] = "團隊其他"
L["Party leader"] = "小隊領袖"
L["Party others"] = "小隊其他"
L["Use texture"] = "使用材質"
L["Use texture desc"] = "使用單一材質而不是多重材質描繪圖形。速度快但是可能會導致一些較大的圖形視覺效果或縮放時出現問題。"
L["Use texture desc marker"] = "使用單一材質而不是多重材質描繪圖形。這速度快但是可能會導致一些較大的圖形視覺效果變大或縮放時出現問題。幅度設置在此不可用。"
L["Blacklist"] = "黑名單"
L["Blacklist desc"] = "其它全部選項將不會被接受這些被拒絕的場景"


L["About"] = "關於"
L["Version"] = "AVR 版本 "..GetAddOnMetadata("AVR","Version")
L["Copyright"] =
"2010 Olog 版權所有（通過 http://www.wowace.com/profiles/Olog/ 聯繫）。\n"

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