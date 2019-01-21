--[[
Title: edit static properties in ActorNPC
Author(s): LiXizhi
Date: 2019/1/21
Desc: 
use the lib:
-------------------------------------------------------
NPL.load("(gl)script/apps/Aries/Creator/Game/Movie/EditStaticPropertyPage.lua");
local EditStaticPropertyPage = commonlib.gettable("MyCompany.Aries.Game.Movie.EditStaticPropertyPage");
EditStaticPropertyPage.ShowPage(function(values)
	echo(values);
end, {name="string", isAgent=true})
-------------------------------------------------------
]]

local EditStaticPropertyPage = commonlib.gettable("MyCompany.Aries.Game.Movie.EditStaticPropertyPage");

local page;
function EditStaticPropertyPage.OnInit()
	page = document:GetPageCtrl();
end

-- @param OnOK: function(values) end 
-- @param old_value: {name="ximi", isAgent=true}
function EditStaticPropertyPage.ShowPage(OnOK, old_value)
	EditStaticPropertyPage.result = nil;
	EditStaticPropertyPage.last_values = old_value;
	
	local params = {
		url = "script/apps/Aries/Creator/Game/Movie/EditStaticPropertyPage.html", 
		name = "EditStaticPropertyPage.ShowPage", 
		isShowTitleBar = false,
		DestroyOnClose = true,
		bToggleShowHide=false, 
		style = CommonCtrl.WindowFrame.ContainerStyle,
		allowDrag = true,
		click_through = false, 
		enable_esc_key = true,
		bShow = true,
		isTopLevel = true,
		app_key = MyCompany.Aries.Creator.Game.Desktop.App.app_key, 
		directPosition = true,
			align = "_ct",
			x = -256,
			y = -200,
			width = 512,
			height = 400,
		};
	System.App.Commands.Call("File.MCMLWindowFrame", params);
	params._page.OnClose = function()
		if(EditStaticPropertyPage.result == "OK") then
			OnOK(EditStaticPropertyPage.last_values);
		end
	end

	EditStaticPropertyPage.OnReset();
end

function EditStaticPropertyPage.OnReset()
	EditStaticPropertyPage.UpdateUIFromValue(EditStaticPropertyPage.last_values);
end

function EditStaticPropertyPage.UpdateUIFromValue(values)
	if(page and values) then
		page:SetValue("name", values.name or "");
		page:SetValue("isAgent", values.isAgent);
	end
end

function EditStaticPropertyPage.OnOK()
	if(page) then
		local v = {};
		local name = page:GetUIValue("name") or "";
		v.name = name;
		local isAgent = page:GetUIValue("isAgent");
		if(isAgent) then
			v.isAgent = true;
		end
		EditStaticPropertyPage.last_values = v;
		EditStaticPropertyPage.result = "OK";
		page:CloseWindow();
	end
end

function EditStaticPropertyPage.OnClose()
	page:CloseWindow();
end
