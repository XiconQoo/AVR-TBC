local L = LibStub("AceLocale-3.0"):NewLocale("AVR", "zhCN", false)

if not L then return end

-- common
L["addon_name"] = "AVR"
L["Yes"] = "是"
L["No"] = "否"
L["scene"] = "场景"
L["raid"] = "团队"
L["party"] = "小队"
L["guild"] = "公会"
L["battleground"] = "战场"
L["whisper"] = "悄悄话"
L["Scene"] = "场景"
L["Mesh"] = "图形"
L["Raid"] = "团队"
L["Party"] = "小队"
L["Guild"] = "公会"
L["Battleground"] = "战场"
L["Whisper"] = "悄悄话"

-- common options
L["Name"] = "名称"
L["Select"] = "选择"
L["Remove"] = "移除"
L["Visible"] = "可见性"

-- Core
L["Received AVR scene from %s"] = "从%s接受到 AVR 场景"
L["Couldn't deserialized AVR addon message from %s %s"] = "不能从%s %s非序列化 AVR 插件信息"
L["Can't send a scene from someone else. Make own copy first."] = "不能发送其他人的场景。先制作自己的场景。"
L["Sending scene to %s"] = "发送场景到%s"
L["Import scene"] = "导入场景"
L["Import scene desc"] = "入以前已导出的场景"
L["Export scene"] = "导出场景"
L["Copy this to clipboard"] = "复制到剪切板"
L["Paste exported scene here"] = "粘帖导出到这里"
L["Couldn't deserialized imported scene"] = "不能非序列化导入场景"
L["Version check"] = "版本检测"
L["Sending version check"] = "发送版本检测"
L["Version check finished. Got %s replies."] = "版本检测结束。收到%s个回馈。"
L["Version check available only in raids"] = "版本检测只在团队时可用"

-- SceneManager
L["Loaded scene had invalid scene id, reassigning"] = "加载无效的场景编号，重新指定"
L["Trying to unpack scene, unknown class %s"] = "尝试解开场景，未知%s职业"
L["Received scene with class %s but that class is not receivable"] = "已接收场景包含%s职业但此职业不可接收"

-- Scene
L["Trying to unpack mesh, unknown class %s"] = "尝试揭开图形，未知%s职业"
L["Received mesh with class %s but that class is not receivable"] = "已接收图形包含%s职业但此职业不可接收"
L["Normal scene"] = "普通场景"
L["UNKNOWN SCENE"] = "此场景类型 \"%s\"。"..
"AVR 不能识别这种类型，因此不能显示或以其他方式处理这个场景。"..
"这很可能是由于 AVR 版本过时或一个缺少插件的引起的。"

-- mesh
L["unnamed"] = "未命名"
L["Compass"] = "半圆"
L["Circle"] = "圆圈"
L["Filled circle"] = "填充圆圈"
L["Cone"] = "复制"
L["Player marker"] = "玩家标记"
L["Vargoth"] = "瓦格斯"
L["Blink"] = "闪烁"
L["Position Crosshair"] = "十字线位置"
L["Target marker"] = "目标标记"
L["Yard stick"] = "码尺"
L["Draw line"] = "画线"
L["Draw line desc"] = "从玩家到目标标记画一条线"
L["Arrow"] = "箭头"
L["Timer circle"] = "计时圆圈"

L["UNKNOWN MESH"] = "此图形类型 \"%s\"。"..
"AVR 不能识别这种类型，因此不能显示或以其他方式处理这个图形。"..
"这很可能是由于 AVR 版本过时或一个缺少插件的引起的。"

-- mesh options
L["Color"] = "颜色"
L["Radius"] = "半径"
L["Range"] = "范围"
L["Angle"] = "角度"
L["Line width"] = "线宽"
L["Follow behavior"] = "后续行为"
L["Follow unit"] = "后续单位"
L["Follow unit desc"] = "制作图形跟随特定单位。只在玩家位于小队或团队时可用。可以指定“目标”或“焦点”等，但是它只在玩家位于团队时可用。滑块位置应设置为0到中央图形位于目标。"
L["Attach"] = "附加"
L["Attach desc"] = "制作图形跟随玩家并自动调整自身位置因此它继续保持玩家相对位置。"
L["Detach"] = "分离" 
L["Detach desc"] = "停止图形跟随玩家玩家并自动调整自身位置因此它继续保持玩家相对位置。"
L["Attach rotation"] = "附加旋转"
L["Detach rotation"] = "分离旋转"
L["Mesh deform"] = ""
L["Drag"] = "拖拽"
L["Drag desc"] = "拖拽移动图形到 3D 游戏世界。鼠标右键停止拖拽"
L["X Position"] = "X 位置"
L["Y Position"] = "Y 位置"
L["Z Position"] = "Z 位置"
L["X Scale"] = "X 缩放"
L["Y Scale"] = "Y 缩放"
L["Z Scale"] = "Z 缩放"
L["Z Rotate"] = "Z 旋转"

L["Circle properties"] = "圆圈属性"
L["Segments"] = "线段"
L["Dashed"] = "虚线"
L["Cone properties"] = "复制属性"

L["Yard stick properties"] = "码尺属性"
L["Min"] = "最小"
L["Max"] = "最大"
L["Vertical"] = "垂直"
L["Divisions"] = "分隔"

L["Marker properties"] = "标记属性"
L["Class color"] = "职业颜色"
L["Spokes"] = "幅度"

L["Raid icon"] = "团队标记"
L["Raid icon properties"] = "团队标记属性"
L["Use default color"] = "使用默认颜色"
L["Size"] = "大小"
L["Star"] = "星星"
L["Circle"] = "圆形"
L["Diamond"] = "菱形"
L["Triangle"] = "三角"
L["Moon"] = "月亮"
L["Square"] = "方块"
L["Cross"] = "十字"
L["Skull"] = "骷髅"

L["Arrow properties"] = "箭头属性"
L["Length"] = "长度"
L["Width"] = "宽度"
L["Head size"] = "头部大小"

L["Data mesh properties"] = "数据图形属性"
L["Line width"] = "画线长度"

-- edit
L["Remove mesh"] = "移除图形"
L["Remove mesh desc"] = "从场景移除图形"
L["Edit mesh"] = "编辑图形"
L["Rotate"] = "旋转"
L["Scale X"] = "X 缩放"
L["Add mesh"] = "添加图形"
L["Main menu"] = "主目录"
L["Mesh name desc"] = "图形名称描述"
L["Scene name desc"] = "场景名称描述"
L["Select scene desc"] = "选择需要编辑的场景"
L["Select mesh desc"] = "选择需要编辑的图形。也可在 3D 游戏时间内点击。"


-- RangeWarning
L["Range Warning"] = "范围警报"
L["Draw circle"] = "画圆圈"
L["Draw circle desc"] = "为警报范围添加一个圆圈范围。"
L["Range range desc"] = "范围内标记为可见"
L["Range radius desc"] = "标记半径"

-- ZoneInfo
L["The Frozen Throne"] = "寒冰王座" -- Minimap zone text in Icecrown raid

-- MeshEdit
L["Mesh edit"] = "编辑图形"
L["Start edit"] = "开始编辑"
L["Stop edit"] = "结束编辑"
L["Add vertices"] = "添加顶点"
L["Delete vertices"] = "删除顶点"
L["Add triangle"] = "添加三角形"
L["Remove triangle"] = "移除三角形"
L["New mesh"] = "新图形"

-- Options

L["New %s"] = "新%s"
L["Clear scene"] = "清除场景"
L["Clear scene desc"] = "从场景移除所有图形"
L["Remove scene"] = "移除场景"
L["Remove scene desc"] = "移除全部场景和所有包含的图形"
L["Zone"] = "区域"
L["Zone desc"] = "场景内可见区域。留空所有区域场景可见。"
L["Current zone"] = "当前区域"
L["Current zone desc"] = "设置当前区域到区域。"
L["Share"] = "共享"
L["Channel"] = "取消"
L["Channel desc"] = "场景通过插件频道已经发送。此与普通聊天频道不同。"
L["Whisper target"] = "悄悄话目标"
L["Whisper target desc"] = "设置悄悄话频道为目标玩家名称"
L["Send"] = "发送"
L["Import"] = "导入"
L["Export to clipboard"] = "导出到剪切板"
L["Scene id"] = "场景编号"
L["Owner"] = "所属人"
L["Make own copy"] = "制作自己的复制"
L["Make own copy desc"] = "制作一个属于你自己的场景。此场景是从其他玩家出接收的。"
L["Paint"] = "绘制"
L["Follow player"] = "跟随玩家"
L["Follow player desc"] = "制作图形跟随玩家。滑块位置应设置为0到中央图形位于玩家或进行微小偏移。也可使用附加按钮。"
L["Follow rotation"] = "跟随旋转"
L["Follow rotation desc"] = "制作旋转玩家。此不能用于跟随玩家或跟随单位。"
L["Detail level"] = "详细等级"
L["Start"] = "开始"
L["Meshes"] = "图形"
L["Meshes desc"] = "所有图形位于此场景"
L["Add new mesh"] = "添加新的图形"
L["Add"] = "添加"
L["Archmage Vargoth spawn point"] = "大法师瓦格斯出现地点"
L["Blink location"] = "闪烁位置"
L["Crosshair"] = "十字"
L["Unit marker"] = "单位标记"
L["Unit"] = "单位"
L["Range warning"] = "范围警报"
L["New scene"] = "新场景"
L["Menu"] = "目录"
L["General"] = "常用"
L["Enable"] = "启用"
L["Enable desc"] = "启用或禁用插件"
L["Hide all"] = "隐藏全部"
L["Hide all desc"] = "隐藏全部 3D 图形但保持插件运行"
L["Open scene editor"] = "打开场景编辑器"
L["Open scene editor desc"] = "打开一个小型场景编辑器窗口用来更容易编辑常规任务而使用全选项对话。"
L["Sharing"] = "共享"
L["Accept incoming scenes from"] = "接收场景，来自"
L["Receive own scenes"] = "接收自制场景"
L["Receive own scenes desc"] = "应该如何从自己接收场景。“是”接受他们的任何其他场景，你会结束两个相同的场景。“否”丢弃传入的场景。“隐藏”接受场景，但其使不可见。"
L["As hidden"] = "隐藏"
L["Scenes"] = "场景"
L["Raid leader"] = "团队领袖"
L["Raid assist"] = "团队助理"
L["Raid others"] = "团队其他"
L["Party leader"] = "小队领袖"
L["Party others"] = "小队其他"
L["Use texture"] = "使用材质"
L["Use texture desc"] = "使用单一材质而不是多重材质描绘图形。速度快但是可能会导致一些比较大的图形视觉效果或缩放时出现问题。"
L["Use texture desc marker"] = "画图性使用单一材质而不是多重材质描绘图形。速度快但是可能会导致一些比较大的图形视觉效果或缩放时出现问题。幅度设置在此不可用。"
L["Blacklist"] = "黑名单"
L["Blacklist desc"] = "其它全部选项将不会被接受这些被拒绝的场景"


L["About"] = "关于"
L["Version"] = "AVR 版本 "..GetAddOnMetadata("AVR","Version")
L["Copyright"] =
"2010 Olog 版权所有（通过 http://www.wowace.com/profiles/Olog/ 联系）。\n"

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