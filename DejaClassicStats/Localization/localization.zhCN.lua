local ADDON_NAME, namespace = ... 	--localization
local L = namespace.L 				--localization

--local LOCALE = GetLocale()

if namespace.locale == "zhCN" then
	-- The EU English game client also
	-- uses the US English locale code.

-- #######################################################################################################################################################
-- ##	简体中文 (Simplified Chinese) translations provided by C_Reus(Azpilicuet@主宰之剑), alvisjiang, aenerv7, xlfd2008, and y123ao6 on Curseforge.	##
-- ##   简体中文 (Simplified Chinese) fixed by 玉素奴香@哈霍兰CN based on 1401r001 version.
-- #######################################################################################################################################################

L["  /dcstats config: Opens the DejaClassicStats addon config menu."] = "/dcstats config: 开启DejaClassicStats插件设置选项。"
L["  /dcstats reset:  Resets DejaClassicStats options to default."] = "/dcstats reset: 重置DejaClassicStats选项回预设。"
L["%s of %s increases %s by %.2f%%"] = "%s当%s 增加%s为%.2f%%"
L["About DCS"] = "关于DCS"
L["All Stats"] = "所有属性"
L["Attack"] = "攻击"
L["Average Durability"] = "平均耐久度"
L["Average equipped item durability percentage."] = "已装备的物品耐久度平均百分比"
L["Average Item Level:"] = "平均物品等级："
L["Avoidance Rating"] = "闪躲百分比值"
L["Blizzard's Hide At Zero"] = "以暴雪的方式隐藏 0 值"
L["Character Stats:"] = "角色属性："
L["Class Colors"] = "职业颜色"
L["Class Crest Background"] = "职业纹章背景"
L["Critical Strike Rating"] = "爆击百分比值"
L["DCS's Hide At Zero"] = "以 DCS 的方式隐藏 0 值"
L["Decimals"] = "小数点"
L["Defense"] = "防御"
L["Dejablue's improved character stats panel view."] = "Dejablue的角色属性统计面板增强。"
L["DejaClassicStats Slash commands (/dcstats):"] = "DejaClassicStats 命令(/dcsstats)"
L["Displays a durability bar next to each item."] = "在装备图标旁显示耐久条"
L["Displays average item durability on the character shirt slot and durability frames."] = "在角色界面衬衫栏与耐久度框架显示平均物品耐久度。"
L["Displays average item level to one decimal place."] = "显示平均装等小数点后一位"
L["Displays average item level to two decimal places."] = "显示平均装等小数点后两位"
L["Displays average item level with class colors."] = "以职业颜色显示平均物品等级。"
L["Displays each equipped item's durability."] = "显示每件装备的耐久度"
L["Displays each equipped item's repair cost."] = "显示每件装备的维修费用"
L["Displays 'Enhancements' category stats to two decimal places."] = "显示'强化'栏位的属性到两个小数点。"
L["Displays Equipped/Available item levels unless equal."] = "显示已装备/可用的物品等级除非相等。"
L["Displays the class crest background."] = "显示职业特色背景。"
L["Displays the DCS scrollbar."] = "显示属性统计板的滚动条"
L["Displays the Expand button for the character stats frame."] = "显示打开角色属性统计板按钮，默认位于下饰品下方的。"
L["Displays the item level of each equipped item."] = "显示已装备物品等级。"
L["Dodge Rating"] = "躲闪值"
L["Durability"] = "耐久度"
L["Durability Bars"] = "耐久度条"
L["Equipped/Available"] = "已装备/可用"
L["Expand"] = "属性统计板展开按钮"
L["General"] = "综合"
L["General global cooldown refresh time."] = "公共冷却刷新时间。"
L["Global Cooldown"] = "公共冷却"
L["Haste Rating"] = "急速值"
L["Hide Character Stats"] = "隐藏人物属性"
L["Hide low level mastery"] = "隐藏低等级精通"
L["Hides 'Enhancements' stats if their displayed value would be zero. Checking 'Decimals' changes the displayed value."] = "如果'强化'属性值为零则隐藏，开启'小数点'选项则显示。"
L["Hides 'Enhancements' stats only if their numerical value is exactly zero. For example, if stat value is 0.001%, then it would be displayed as 0%."] = "当'强化'属性值为零时隐藏，例：某属性值为0.001%，显示为0%"
L["Hides Mastery stat until the character starts to have benefit from it. Hiding Mastery with Select-A-Stat™ in the character panel has priority over this setting."] = "在角色从中受益之前，隐藏精通属性。(如果通过Select-A-Stat™在角色面板中隐藏精通，会优先于此设置。)"
L["Item Durability"] = "物品耐久度"
L["Item Level"] = "物品等级"
L["Item Repair Cost"] = "物品修理费"
L["Item Slots:"] = "物品栏位："
L["Leech Rating"] = "吸血值"
L["Lock DCS"] = "锁定DCS"
L["Main Hand"] = "主手"
L["Mastery Rating"] = "精通值"
L["Miscellaneous:"] = "其他选项："
L["Movement Speed"] = "移动速度"
L["Off Hand"] = "副手"
L["Offense"] = "设置"
L["One Decimal Place"] = "小数点后一位"
L["Parry Rating"] = "招架值"
L["Ratings"] = "等级"
L["Relevant Stats"] = "相应属性"
L["Repair Total"] = "总修理费"
L["Requires Level "] = "需求等级"
L["Reset Stats"] = "重置属性"
L["Reset to Default"] = "恢复至默认配置"
L["Resets order of stats."] = "重置属性顺序。"
L["Scrollbar"] = "属性统计板显示滚动条"
L["Show all stats."] = "显示全部属性"
L["Show Character Stats"] = "显示角色属性"
L["Show only stats relevant to your class spec."] = "只显示你职业专精相关的属性。"
L["Total equipped item repair cost before discounts."] = "折扣前的已装备物品修理费"
L["Two Decimal Places"] = "小数点后两位"
L["Unlock DCS"] = "解锁DCS"
L["Versatility Rating"] = "全能百分比值"
L["weapon auto attack (white) DPS."] = "武器自动攻击(白字)每秒伤害。"
L["Weapon DPS"] = "武器伤害"

----------------------------------------------------
-- DejaClassicStats specific translation phrases. --
----------------------------------------------------
L[" melee and ranged damage."] = "近战和远程伤害"
L[". Critical Hit immunity for a level 60 player against a raid boss occurs at 440 Defense and requires a defense skill of 140 from items and enhancements to achieve."] = "。60级玩家总共需要440点防御等级才能防止被团队副本BOSS爆击，也就是说需要通过装备和附魔等途径额外获得140点防御等级才能达成这一目标。"
L["+ Arcane: "] = "+ 奥术:"
L["+ Fire: "] = "+ 火焰:"
L["+ Frost: "] = "+ 冰霜:"
L["+ Healing: "] = "+ 治疗: "
L["+ Holy: "] = "+ 神圣:"
L["+ Nature: "] = "+ 自然:"
L["+ Shadow: "] = "+ 暗影:"
L["Abbreviated Enchant Labels"] = "缩写的附魔标签（实为中/英）"
L["Agility: "] = "敏捷:"
L["Alternate Expand"] = "变更展开按钮位置"
L["Armor: "] = "护甲:"
L["Attack Speed (seconds): "] = "攻击速度 (秒):"
L["Background Art"] = "属性统计板背景图片"
L["Base Defense including talents such as Warrior's Anticipation is "] = "基础防御等级（含天赋加成，如战士的预知）为"
L["Black Item Icons"] = "装备图标变黑"
L["Black item icons to make text more visible."] = "将装备图标彻底变黑来让文字更能被看清。"
L["Block: "] = "格挡: "
L["Block Value: "] = "格挡值: "
L["Bonus Defense from items and enhancements is "] = "由装备和附魔提供的额外防御等级为"
L["Categories:"] = "类别:"
L["Damage per Second: "] = "每秒伤害:"
L["Damage: "] = "伤害:"
L["Darken Item Icons"] = "装备图标变暗"
L["Darken item icons to make text more visible."] = "将装备图标变暗来让文字更能被看清。"
L["Default Resistances"] = "默认抗性"
L["Default Stats"] = "默认状态"
L["Defense: "] = "防御: "
L["Display Info Beside Items"] = "物品栏旁边显示信息"
L["Displays a colored border around each item's slot indicating its quality."] = "在每个物品的槽周围显示一个彩色边框，指示其品质。"
L["Displays an abbreviated label of each equipped item's enchantment."] = "显示每个装备物品附魔的缩写标签。（选中为中文，不选中为英文。除了常用的高级附魔，中文数据库尚未逐条仔细核对。）"
L["Displays black and white class talents background art."] = "显示黑白色的属性统计面板背景图片。"
L["Displays each equipped item's enchantment."] = "显示每个被穿上的装备的附魔（附了魔的）。"
L["Displays the Character Model Rotation buttons."] = "为旋转按钮复选框显示悬停鼠标提示"
L["Displays the class talents background art."] = "显示属性统计面板背景图片。"
L["Displays the default resistance frames."] = "显示默认的抗性框架"
L["Displays the default stat frames."] = "显示默认的状态框架"
L["Displays the Expand button above the hands item slot."] = "在手套装备栏上方显示展开按钮。"
L["Displays the item level of each equipped item. Caveat; Item level is relatively meaningless in Classic."] = "显示每个物品的物品等级。警告：在怀旧服中，物品等级相对没有意义"
L["Displays the item's info beside each item's slot."] = "在装备栏旁边显示耐久百分比和修理费用信息，而不是在图标上。"
L["Dodge: "] = "躲闪: "
L["Durability: "] = "耐久: "
L["Enchants"] = "附魔"
L["Gives a chance to block enemy melee and ranged attacks."] = "格挡敌人的近战和远程攻击的几率"
L["Gives a chance to critically strike with melee attacks, increasing the damage dealt by 100%."] = "给予近战攻击致命一击的几率，增加100%的伤害。"
L["Gives a chance to critically strike with spells, increasing the damage dealt by 50%."] = "使用法术进行爆击的几率，增加50%的伤害。"
L["Gives a chance to dodge enemy melee attacks."] = "躲闪敌人的近战攻击的几率"
L["Gives a chance to parry enemy melee attacks."] = "招架敌人的近战攻击的几率"
L["Hide Character Frame"] = "隐藏角色框架"
L["Intellect: "] = "智力:"
L["Item Quality Borders"] = "物品依据品质染色边框"
L["Item Quality Glow"] = "物品品质发光强度"
L["Main Hand Damage: "] = "主手伤害:"
L["Main Hand: "] = "主手:"
L["Mana points regenerated every five seconds while casting and inside the five second rule."] = "施法时每5秒回复一次法力值，在5秒规则内。"
L["Mana points regenerated every tick while casting and inside the five second rule."] = "在施法和五秒规则内，每刻度会产生的法力值。"
L["Mana Regen Current: "] = "当前回蓝："
L["Mana Regen: "] = "法力恢复："
L["Melee +Damage: "] = "近战攻击强度: "
L["Melee Crit: "] = "近战爆击: "
L["Melee Enhancements"] = "物理属性"
L["Melee Hit: "] = "近战命中: "
L["Monochrome Background Art"] = "属性统计板黑白背景图片"
L["Movement Speed: "] = "移动速度: "
L["MP5: "] = "5秒回蓝: "
L["Off Hand Damage: "] = "副手伤害:"
L["Off Hand: "] = "副手:"
L["Parry: "] = "招架: "
L["Physical Critical Strike: "] = "物理爆击："
L["Power: "] = "攻强:"
L["Primary"] = "基础属性"
L["Primary Stats"] = "基础属性"
L["Melee Stats"] = "近战属性"
L["Spell Stats"] = "远程属性"
L["Defense Stats"] = "防御属性"
L["Ranged Crit: "] = "远程爆击："
L["Ranged Damage: "] = "远程伤害:"
L["Ranged Hit: "] = "远程命中:"
L["Ranged: "] = "远程:"
L["Repair Total: "] = "维修总价："
L["Rotation Buttons"] = "旋转按钮"
L["Set the intensity (alpha) of your equipped items' quality colored border glow in increments or decrements of 5. Default is 75."] = "装备物品依据品质染色的彩色边框发光强度（alpha）设置为递增或递减0.05。默认值为0.75。"
L["Show Character Frame"] = "显示角色框架"
L["Show defense stats."] = "显示防御状态"
L["Show melee stats."] = "显示近战状态"
L["Show primary stats."] = "显示基础状态"
L["Show spell stats."] = "显示法术状态"
L["Spell +Damage: "] = "法术伤害增量："
L["Spell Crit: "] = "法术爆击: "
L["Spell Enhancements"] = "法术属性"
L["Spell Hit: "] = "法术命中："
L["Spirit: "] = "精神:"
L["Stamina: "] = "耐力:"
L["Strength: "] = "力量:"
L["The average durability of all equipped items."] = "所有装备的平均耐久度"
L["The total repair cost of all equipped items."] = "所有装备物品的总修理费用"
L["Total Defense is "] = "总计防御等级为"
L["Total Mana points regenerated per tick while not casting and outside the five second rule."] = "当不施法且在五秒规则之外时，每跳获得的法力值"
L["Your blocks mitigate "] = "你的格挡会减少你受到的"
L["Your current movement speed including items, buffs, enchants, forms, and mounts."] = "你当前的移动速度包括物品，Buff，附魔，形态和坐骑"

return end