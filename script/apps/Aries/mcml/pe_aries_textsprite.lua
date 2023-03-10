--[[
Title: text sprite
Author(s): WangTian
Date: 2011/12/24
Desc: 
use the lib:
-------------------------------------------------------
NPL.load("(gl)script/apps/Aries/mcml/pe_aries_textsprite.lua");

---++ aries:textsprite
| fontsize | iamge font size(height) |
| default_fontsize | font size when no image sprite is available for the text |
| color | "255 255 255 255" or "255 255 255",  rgb(a) |
| text | utf8 text |
| tooltip | tooltip |
-------------------------------------------------------
]]
----------------------------------------------------------------------
-- aries:textsprite: handles MCML tag <aries:textsprite>
----------------------------------------------------------------------
NPL.load("(gl)script/ide/TextSprite.lua");

local aries_textsprite = commonlib.gettable("MyCompany.Aries.mcml_controls.aries_textsprite");

aries_textsprite.Images = {["default"] = "Texture/16number.png",
						   ["DragonLevel"] = "Texture/Aries/Common/10numbers_purple_26_32bits.png",
						   ["SpellName"] = "Texture/Aries/Common/SpellName_series_high.png",
						   ["CombatDigits"] = "Texture/Aries/Common/CombatDigits_sprites.png",
						   ["MapRegionName"] = "Texture/Aries/Common/MapRegionName_sprites.png",
						   ["MapRegionLevel"] = "Texture/Aries/Common/MapRegionLevel_sprites.png",
						   };
aries_textsprite.Sprites = {
	["default"] = {
		["1"] = {rect = "0 0 20 31", width = 20, height = 32},
		["2"] = {rect = "32 0 19 31", width = 19, height = 32},
		["3"] = {rect = "64 0 19 31", width = 19, height = 32},
		["4"] = {rect = "96 0 19 31", width = 19, height = 32},
		["5"] = {rect = "0 32 20 31", width = 20, height = 32},
		["6"] = {rect = "32 32 19 32", width = 19, height = 32},
		["7"] = {rect = "64 32 19 31", width = 19, height = 32},
		["8"] = {rect = "96 32 19 31", width = 19, height = 32},
		["9"] = {rect = "0 64 19 31", width = 19, height = 32},
		["0"] = {rect = "32 64 19 31", width = 19, height = 32},
		["A"] = {rect = "64 64 22 31", width = 22, height = 32},
		["B"] = {rect = "96 64 20 31", width = 20, height = 32},
		["C"] = {rect = "0 96 19 31", width = 19, height = 32},
		["D"] = {rect = "32 96 19 31", width = 19, height = 32},
		["E"] = {rect = "64 96 19 31", width = 19, height = 32},
		["F"] = {rect = "96 96 19 31", width = 19, height = 32},
	},
	["DragonLevel"] = {
		["1"] = {rect = "0 0 18 26", width = 15, height = 26},
		["2"] = {rect = "18 0 18 26", width = 16, height = 26},
		["3"] = {rect = "36 0 18 26", width = 16, height = 26},
		["4"] = {rect = "54 0 18 26", width = 17, height = 26},
		["5"] = {rect = "72 0 18 26", width = 16, height = 26},
		["6"] = {rect = "0 26 18 26", width = 16, height = 26},
		["7"] = {rect = "18 26 18 26", width = 16, height = 26},
		["8"] = {rect = "36 26 18 26", width = 17, height = 26},
		["9"] = {rect = "54 26 18 26", width = 17, height = 26},
		["0"] = {rect = "72 26 18 26", width = 16, height = 26},
	},
	["SpellName"] = {
		["???"] = {rect = "0 0 18 26", width = 15, height = 26},
	},
	["MapRegionName"] = {
		["???"] = {rect = "0 0 18 26", width = 15, height = 26},
	},
	["CombatDigits"] = {
		["0"] = {rect = "0 0 29 38", width = 29, height = 38},
		["1"] = {rect = "35 0 20 38", width = 20, height = 38}, -- making 1 thinner
		["2"] = {rect = "60 0 29 38", width = 29, height = 38},
		["3"] = {rect = "90 0 29 38", width = 29, height = 38},
		["4"] = {rect = "120 0 29 38", width = 29, height = 38},
		["5"] = {rect = "0 38 29 38", width = 29, height = 38},
		["6"] = {rect = "30 38 29 38", width = 29, height = 38},
		["7"] = {rect = "60 38 29 38", width = 29, height = 38},
		["8"] = {rect = "90 38 29 38", width = 29, height = 38},
		["9"] = {rect = "120 38 29 38", width = 29, height = 38},
		["-"] = {rect = "150 0 29 38", width = 29, height = 38},
		["+"] = {rect = "150 38 29 38", width = 29, height = 38},
	},
	["MapRegionLevel"] = {
		["0"] = {rect = "0 0 22 24", width = 22, height = 24},
		["1"] = {rect = "23 0 20 24", width = 20, height = 24}, -- making 1 thinner
		["2"] = {rect = "44 0 22 24", width = 22, height = 24},
		["3"] = {rect = "66 0 22 24", width = 22, height = 24},
		["4"] = {rect = "88 0 22 24", width = 22, height = 24},
		["~"] = {rect = "110 0 22 24", width = 22, height = 24},

		["5"] = {rect = "0 24 22 24", width = 22, height = 24},
		["6"] = {rect = "22 24 22 24", width = 22, height = 24},
		["7"] = {rect = "44 24 22 24", width = 22, height = 24},
		["8"] = {rect = "66 24 22 24", width = 22, height = 24},
		["9"] = {rect = "88 24 22 24", width = 22, height = 24},
		["???"] = {rect = "110 24 22 24", width = 22, height = 24},
	},
};

local spellname_mapping_original = {
	{"???", "???", "???", "???", "???", "???", "???", "???", "???", "???", "???", "???", "???", "???", "???", "???"},
	{"???", "???", "???", "???", "???", "???", "???", "???", "???", "???", "???", "???", "???", "???", "???", "???"},
	{"???", "???", "???", "???", "???", "???", "???", "???", "???", "???", "???", "???", "???", "???", "???", "???"},
	{"???", "???", "???", "???", "???", "???", "???", "???", "???", "???", "???", "???", "???", "???", "???", "???"},
	{"???", "???", "???", "???", "???", "???", "???", "???", "???", "???", "???", "???", "???", "???", "???", "???"},
	{"???", "???", "???", "???", "???", "???", "???", "???", "???", "???", "???", "???", "???", "???", "???", "???"},
	{"???", "???", "???", "???", "???", "???", "???", "???", "???", "???", "???", "???", "???", "???", "???", "???"},
	{"???", "???", "???", "???", "???", "???", "???", "???", "???", "???", "???", "???", "???", "???", "???", "???"},
	{"???", "???", "???", "???", "???", "???", "???", "???", "???", "???", "???", "???", "???", "???", "???", "???"}, 
	{"???", "???", "???", "???", "???", "???", "???", "???", "???", "???", "???", "???", "???", "???", "???", "???"},
	{"???", "???", "???", "???", "???", "???", "???", "???", "???", "???", "???", "???", "???", "???", "???", "???"},
	{"???", "???", "???", "???", "???", "???", "???", "???", "???", "???", "???", "???", "???", "???", "???", "???"},
	{"???", "???", "???", "???", "???", "???", "???", "???", "???", "???", "???", "???", "???", "???", "???", "???"},
	{"???", "???", "???", "???", "???", "???", "???", "???", "???", "???", "???", "???", "???", "???", "???", "???"},
	{"???", "???", "???", "???", "[",  "]", "???", "???", "???", "???", "???", "???", "???", "???", "???", "???"},
	{"???", "???", "???", "???", "???", "???", "???", "???", "???", "???", "???", "???", "???", "???", "???", "???"},
	{"???", "???", "???", "???", "???", "???", "???", "???", "???", "???", "???", "???", "???", "???", "???", "???"},
	{"???", "???", "???", "???", "???", "???", "???", "???", "???", "???", "???", "???", "???", "???", "???", "???"},
	{"???", "???", "???", "???", "???", "???", "???", "???", "???", "???", "???", "???", "???", "???", "???", "???"},
	{"???", "???", "???", "???", "???", "???", "???", "???", "???", "???", "???", "???", "???", "???", "???", "???"},
	{"???", "???", "???", "???", "???", "???", "???", "???", "???", "???", "???", "???", "???", "???", "???", "???"},
	{"???", "???", "???", "???", "???", "???", "???", "???", "???", "???", "???", "???", "???", "???", "???", "???"},
	{"???", "???", "???", "???", "???", "???", "???", "???", "???", "???", "???", "???", "???", "???", "???", "???"},
	{"???", "???", "???", "???", "???", "???", "???", "???", "???", "???", "???", "???", "???", "???", "???", "???"},
	{"???", "???", "???", "???", "???", "???", "???", "???", "???", "???", "???", "???", "???"},
};


if(System.options.locale == "zhTW") then
	spellname_mapping_original = {
		{"???", "???", "???", "???", "???", "???", "???", "???", "???", "???", "???", "???", "???", "???", "???", "???"},
		{"???", "???", "???", "???", "???", "???", "???", "???", "???", "???", "???", "???", "???", "???", "???", "???"},
		{"???", "???", "???", "???", "???", "???", "???", "???", "???", "???", "???", "???", "???", "???", "???", "???"},
		{"???", "???", "???", "???", "???", "???", "???", "???", "???", "???", "???", "???", "???", "???", "???", "???"},
		{"???", "???", "???", "???", "???", "???", "???", "???", "???", "???", "???", "???", "???", "???", "???", "???"},
		{"???", "???", "???", "???", "???", "???", "???", "???", "???", "???", "???", "???", "???", "???", "???", "???"},
		{"???", "???", "???", "???", "???", "???", "???", "???", "???", "???", "???", "???", "???", "???", "???", "???"},
		{"???", "???", "???", "???", "???", "???", "???", "???", "???", "???", "???", "???", "???", "???", "???", "???"},
		{"???", "???", "???", "???", "???", "???", "???", "???", "???", "???", "???", "???", "???", "???", "???", "???"}, 
		{"???", "???", "???", "???", "???", "???", "???", "???", "???", "???", "???", "???", "???", "???", "???", "???"},
		{"???", "???", "???", "???", "???", "???", "???", "???", "???", "???", "???", "???", "???", "???", "???", "???"},
		{"???", "???", "???", "???", "???", "???", "???", "???", "???", "???", "???", "???", "???", "???", "???", "???"},
		{"???", "???", "???", "???", "???", "???", "???", "???", "???", "???", "???", "???", "???", "???", "???", "???"},
		{"???", "???", "???", "???", "???", "???", "???", "???", "???", "???", "???", "???", "???", "???", "???", "???"},
		{"???", "???", "???", "???", "[",  "]", "???", "???", "???", "???", "???", "???", "???", "???", "???", "???"},
		{"???", "???", "???", "???", "???", "???", "???", "???", "???", "???", "???", "???", "???", "???", "???", "???"},
		{"???", "???", "???", "???", "???", "???", "???", "???", "???", "???", "???", "???", "???", "???", "???", "???"},
		{"???", "???", "???", "???", "???", "???", "???", "???", "???", "???", "???", "???", "???", "???", "???", "???"},
		{"???", "???", "???", "???", "???", "???", "???", "???", "???", "???", "???", "???", "???", "???", "???", "???"},
		{"???", "???", "???", "???", "???", "???", "???", "???", "???", "???", "???", "???", "???", "???", "???", "???"},
		{"???", "???", "???", "???", "???", "???", "???", "???", "???", "???", "???", "???", "???", "???", "???", "???"},
		{"???", "???", "???", "???", "???", "???", "???", "???", "???", "???", "???", "???", "???", "???", "???", "???"},
		{"???", "???", "???", "???", "???", "???", "???", "???", "???", "???", "???", "???", "???", "???", "???", "???"},
		{"???", "???", "???", "???", "???", "???", "???", "???", "???", "???", "???", "???", "???", "???", "???", "???"},
		{"???", "???", "???", "???", "???", "???", "???", "???", "???", "???", "???", "???", "???"},
	};
elseif(System.options.locale == "thTH") then
	spellname_mapping_original = {{}};
elseif(System.options.locale == "jaJP") then
	spellname_mapping_original = {{}};
elseif(System.options.locale == "enUS") then
	spellname_mapping_original = {{}};
end

local i, j;
for i = 1, 32 do
	for j = 1, 16 do
		if(spellname_mapping_original[i] and spellname_mapping_original[i][j]) then
			aries_textsprite.Sprites["SpellName"][spellname_mapping_original[i][j]] = {
				rect = (j * 32 - 32).." "..(i * 32 - 32).." 32 32", 
				width = 32, 
				height = 32, 
			};
		end
	end
end

local mapregionname_mapping_original = {
	{"???", "???", "???", "???", "???", "???", "???", "???", "???", "???", "???", "???", "???", "???", "???", "???"},
	{"???", "???", "???", "???", "???", "???", "???", "???", "???", "???", "???", "???", "???", "???", "???", "???"},
	{"???", "???", "???", "???", "???", "???", "???", "???", "???", "???", "???", "???", "???", "???", "???", "???"},
	{"???", "???", "???", "???", "???", "???", "???", "???", "???", "???", "???", "???", "???", "???", "???", "???"},
	{"???", "???", "???", "???", "???", "???", "???", "???", "???", "???", "???", "???", "???", "???", "???", "???"},
	{"???", "???", "???", "???", "???", "???", "???", "???", "???", "???", "???", "???", "???", "???", "???", "???"},
	{"???", "???", "???", "???", "???", "???", "???", "???", "???", "???", "???", "???", "P", "V", "[", "]"},
	{"???", "???", "???", "???", "???", "???", "???", "???"},
};

local i, j;
for i = 1, 16 do
	for j = 1, 16 do
		if(mapregionname_mapping_original[i] and mapregionname_mapping_original[i][j]) then
			aries_textsprite.Sprites["MapRegionName"][mapregionname_mapping_original[i][j]] = {
				rect = (j * 32 - 32).." "..(i * 32 - 32).." 32 32", 
				width = 32, 
				height = 32, 
			};
		end
	end
end

-- aries_textsprite is just a wrapper of TextSprite
function aries_textsprite.create(rootName, mcmlNode, bindingContext, _parent, left, top, width, height, style, parentLayout)
	local spritestyle = mcmlNode:GetAttributeWithCode("spritestyle") or "default";
	local color = mcmlNode:GetAttributeWithCode("color") or "255 255 255 255";
	local fontsize = mcmlNode:GetNumber("fontsize") or 32;
	local text = mcmlNode:GetAttributeWithCode("text");
	
	if(not text) then
		log("error: nil text got in aries_textsprite.create\n");
		return;
	end
	
	local left, top, width, height = parentLayout:GetPreferredRect();
	
	-- TODO: each time we will rebuilt child nodes however, we can also reuse previously created ones. 
	mcmlNode:ClearAllChildren();
	
	local ctl = CommonCtrl.TextSprite:new{
		name = "mcml_text_sprite",
		alignment = "_lt",
		left = left,
		top = top,
		width = 2000,
		height = fontsize,
		parent = _parent,
		text = text,
		color = color,
		fontsize = fontsize,
		default_fontsize = mcmlNode:GetNumber("default_fontsize"),
		tooltip = mcmlNode:GetAttributeWithCode("tooltip"),
		image = aries_textsprite.Images[spritestyle],
		sprites = aries_textsprite.Sprites[spritestyle],
	};
	ctl:Show(true);
	mcmlNode.control = ctl;
	
	parentLayout:AddObject(ctl:GetUsedWidth(), fontsize);
end

-- get the UI value on the node
function aries_textsprite.GetUIValue(mcmlNode, pageInstName)
	local editBox = mcmlNode:GetControl(pageInstName);
	if(editBox) then
		if(type(editBox)=="table" and type(editBox.GetText) == "function") then
			return editBox:GetText();
		end	
	end
end

-- set the UI value on the node
function aries_textsprite.SetUIValue(mcmlNode, pageInstName, value)
	local editBox = mcmlNode:GetControl(pageInstName);
	if(editBox) then
		if(type(value) == "number") then
			value = tostring(value);
		elseif(type(value) == "table") then
			return
		end 
		if(type(editBox.SetText) == "function") then
			editBox:SetText(value);
		end	
	end
end