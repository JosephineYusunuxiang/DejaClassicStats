local ADDON_NAME, namespace = ... 	--localization
local L = namespace.L 				--localization

--local LOCALE = GetLocale()

if namespace.locale == "enUS" then
	-- The EU English game client also
	-- uses the US English locale code.

--L["  /dcstats config: Opens the DejaClassicStats addon config menu."] = "/dcstats config: Open the DejaClassicStats addon config menu."
--L["  /dcstats reset:  Resets DejaClassicStats options to default."] = "/dcstats reset:  Resets DejaClassicStats options to default."
--L["%s of %s increases %s by %.2f%%"] = "%s of %s increases %s by %.2f%%"
--L["About DCS"] = "About DCS"
--L["All Stats"] = "All Stats"
--L["Attack"] = "Attack"
--L["Average Durability"] = "Average Durability"
--L["Average equipped item durability percentage."] = "Average equipped item durability percentage."
--L["Average Item Level:"] = "Average Item Level:"
--L["Avoidance Rating"] = "Avoidance Rating"
--L["Blizzard's Hide At Zero"] = "Blizzard's Hide At Zero"
--L["Character Stats:"] = "Character Stats:"
--L["Class Colors"] = "Class Colors"
--L["Class Crest Background"] = "Class Crest Background"
--L["Critical Strike Rating"] = "Critical Strike Rating"
--L["DCS's Hide At Zero"] = "DCS's Hide At Zero"
--L["Decimals"] = "Decimals"
--L["Defense"] = "Defense"
--L["Dejablue's improved character stats panel view."] = "Dejablue's improved character stats panel view."
--L["DejaClassicStats Slash commands (/dcstats):"] = "DejaClassicStats Slash commands (/dcstats):"
--L["Displays a durability bar next to each item."] = "Displays a durability bar next to each item."
--L["Displays average item durability on the character shirt slot and durability frames."] = "Displays average item durability on the character shirt slot and durability frames."
--L["Displays average item level to one decimal place."] = "Displays average item level to one decimal place."
--L["Displays average item level to two decimal places."] = "Displays average item level to two decimal places."
--L["Displays average item level with class colors."] = "Displays average item level with class colors."
--L["Displays each equipped item's durability."] = "Displays each equipped item's durability."
--L["Displays each equipped item's repair cost."] = "Displays each equipped item's repair cost."
--L["Displays 'Enhancements' category stats to two decimal places."] = "Displays 'Enhancements' category stats to two decimal places."
--L["Displays Equipped/Available item levels unless equal."] = "Displays Equipped/Available item levels unless equal."
--L["Displays the class crest background."] = "Displays the class crest background."
--L["Displays the DCS scrollbar."] = "Displays the DCS scrollbar."
--L["Displays the Expand button for the character stats frame."] = "Displays the Expand button for the character stats frame."
--L["Displays the item level of each equipped item."] = "Displays the item level of each equipped item."
--L["Dodge Rating"] = "Dodge Rating"
--L["Durability"] = "Durability"
--L["Durability Bars"] = "Durability Bars"
--L["Equipped/Available"] = "Equipped/Available"
--L["Expand"] = "Expand"
--L["General"] = "General"
--L["General global cooldown refresh time."] = "General global cooldown refresh time."
--L["Global Cooldown"] = "Global Cooldown"
--L["Haste Rating"] = "Haste Rating"
--L["Hide Character Stats"] = "Hide Character Stats"
--L["Hide low level mastery"] = "Hide low level mastery"
--L["Hides 'Enhancements' stats if their displayed value would be zero. Checking 'Decimals' changes the displayed value."] = "Hides 'Enhancements' stats if their displayed value would be zero. Checking 'Decimals' changes the displayed value."
--L["Hides 'Enhancements' stats only if their numerical value is exactly zero. For example, if stat value is 0.001%, then it would be displayed as 0%."] = "Hides 'Enhancements' stats only if their numerical value is exactly zero. For example, if stat value is 0.001%, then it would be displayed as 0%."
--L["Hides Mastery stat until the character starts to have benefit from it. Hiding Mastery with Select-A-Stat™ in the character panel has priority over this setting."] = "Hides Mastery stat until the character starts to have benefit from it. Hiding Mastery with Select-A-Stat™ in the character panel has priority over this setting."
--L["Item Durability"] = "Item Durability"
--L["Item Level"] = "Item Level"
--L["Item Repair Cost"] = "Item Repair Cost"
--L["Item Slots:"] = "Item Slots:"
--L["Leech Rating"] = "Leech Rating"
--L["Lock DCS"] = "Lock DCS"
--L["Main Hand"] = "Main Hand"
--L["Mastery Rating"] = "Mastery Rating"
--L["Miscellaneous:"] = "Miscellaneous:"
--L["Movement Speed"] = "Movement Speed"
--L["Off Hand"] = "Off Hand"
--L["Offense"] = "Offense"
--L["One Decimal Place"] = "One Decimal Place"
--L["Parry Rating"] = "Parry Rating"
--L["Ratings"] = "Ratings"
--L["Relevant Stats"] = "Relevant Stats"
--L["Repair Total"] = "Repair Total"
--L["Requires Level "] = "Requires Level "
--L["Reset Stats"] = "Reset Stats"
--L["Reset to Default"] = "Reset to Default"
--L["Resets order of stats."] = "Resets order of stats."
--L["Scrollbar"] = "Scrollbar"
--L["Show all stats."] = "Show all stats."
--L["Show Character Stats"] = "Show Character Stats"
--L["Show only stats relevant to your class spec."] = "Show only stats relevant to your class spec."
--L["Total equipped item repair cost before discounts."] = "Total equipped item repair cost before discounts."
--L["Two Decimal Places"] = "Two Decimal Places"
--L["Unlock DCS"] = "Unlock DCS"
--L["Versatility Rating"] = "Versatility Rating"
--L["weapon auto attack (white) DPS."] = "weapon auto attack (white) DPS. "
--L["Weapon DPS"] = "Weapon DPS"

----------------------------------------------------
-- DejaClassicStats specific translation phrases. --
----------------------------------------------------
-- L["Primary"] = "Primary"
-- L["Melee Enhancements"] = "Melee Enhancements"
-- L["Spell Enhancements"] = "Spell Enhancements"
-- L["Movement Speed: "] = "Movement Speed: "
-- L["Durability: "] = "Durability: "
-- L["Repair Total: "] = "Repair Total: "
-- L["Melee Crit: "] = "Melee Crit: "
-- L["Melee Hit: "] = "Melee Hit: "
-- L["Ranged Crit: "] = "Ranged Crit: "	
-- L["Melee +Damage: "] = "Melee +Damage: "	
-- L["Physical Critical Strike: "] = "Physical Critical Strike: "	
-- L["Dodge: "] = "Dodge: "	
-- L["Defense: "] = "Defense: "	
-- L["Parry: "] = "Parry: "	
-- L["Block: "] = "Block: "	
-- L["Mana Regen Current: "] = "Mana Regen Current: "	
-- L["Mana Regen: "] = "Mana Regen: "	
-- L["MP5: "] = "MP5: "	
-- L["Spell Crit: "] = "Spell Crit: "	
-- L["Spell Hit: "] = "Spell Hit: "	
-- L["Spell +Damage: "] = "Spell +Damage: "	
-- L["+Healing: "] = "+Healing: "	

-- L["Darken Item Icons"] = "Darken Item Icons"	
-- L["Darken item icons to make text more visible."] = "Darken item icons to make text more visible."	
-- L["Black Item Icons"] = "Black Item Icons"
-- L["Black item icons to make text more visible."] = "Black item icons to make text more visible."
-- L["Display Info Beside Items"] = "Display Info Beside Items"
-- L["Displays the item's info beside each item's slot."] = "Displays the item's info beside each item's slot."
-- L["Enchants"] = "Enchants"
-- L["Displays each equipped item's enchantment."] = "Displays each equipped item's enchantment."
-- L["Background Art"] = "Background Art"
-- L["Displays the class talents background art."] = "Displays the class talents background art."
-- L["Monochrome Background Art"] = "Monochrome Background Art"
-- L["Displays black and white class talents background art."] = "Displays black and white class talents background art."
-- L["Alternate Expand"] = "Alternate Expand"
-- L["Displays the Expand button above the hands item slot."] = "Displays the Expand button above the hands item slot."

-- L["Base Defense including talents such as Warrior's Anticipation is "] = "Base Defense including talents such as Warrior's Anticipation is "
-- L["Bonus Defense from items and enhancements is "] = "Bonus Defense from items and enhancements is "
-- L["Total Defense is "] = "Total Defense is "
-- L[". Critical Hit immunity for a level 60 player against a raid boss occurs at 440 Defense and requires a defense skill of 140 from items and enhancements to achieve."] = ". Critical Hit immunity for a level 60 player against a raid boss occurs at 440 Defense and requires a defense skill of 140 from items and enhancements to achieve."

return end
