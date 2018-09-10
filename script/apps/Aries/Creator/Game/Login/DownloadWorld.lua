--[[
Title: DownloadWorld.html code-behind script
Author(s): LiXizhi
Date: 2018/4/9
Desc: download world
use the lib:
-------------------------------------------------------
NPL.load("(gl)script/apps/Aries/Creator/Game/Login/DownloadWorld.lua");
local DownloadWorld = commonlib.gettable("MyCompany.Aries.Game.MainLogin.DownloadWorld")
DownloadWorld.ShowPage(url)
DownloadWorld.Close();
-------------------------------------------------------
]]
NPL.load("(gl)script/apps/Aries/Creator/WorldCommon.lua");
NPL.load("(gl)script/apps/Aries/Creator/Game/Login/LocalLoadWorld.lua");
local LocalLoadWorld = commonlib.gettable("MyCompany.Aries.Game.MainLogin.LocalLoadWorld")
local WorldCommon = commonlib.gettable("MyCompany.Aries.Creator.WorldCommon")

local DownloadWorld = commonlib.gettable("MyCompany.Aries.Game.MainLogin.DownloadWorld")

local page;
-- init function. page script fresh is set to false.
function DownloadWorld.OnInit()
	page = document:GetPageCtrl();
	page:SetValue("url", DownloadWorld.url);
end

-- show page
function DownloadWorld.ShowPage(url)
	NPL.load("(gl)script/apps/Aries/Creator/Game/game_logic.lua");
	local GameLogic = commonlib.gettable("MyCompany.Aries.Game.GameLogic")
	local isCustomShow = GameLogic.GetFilters():apply_filters("show_custom_download_world", "show", url);
	if(isCustomShow == "show") then
		LOG.std(nil, "debug", "DownloadWorld", "show for url: %s", url);
		DownloadWorld.url = url;
		local width, height=512, 300;
		System.App.Commands.Call("File.MCMLWindowFrame", {
			url = "script/apps/Aries/Creator/Game/Login/DownloadWorld.html", 
			name = "paracraft.DownloadWorld", 
			isShowTitleBar = false,
			DestroyOnClose = true, 
			style = CommonCtrl.WindowFrame.ContainerStyle,
			zorder = 10,
			allowDrag = true,
			isTopLevel = true,
			directPosition = true,
				align = "_ct",
				x = -width/2,
				y = -height/2,
				width = width,
				height = height,
			cancelShowAnimation = true,
		});
	end
end

function DownloadWorld.UpdateProgressText(text)
	if(page) then
		page:SetValue("progressText", text)
	end
end


function DownloadWorld.Close()
	local isCustomShow = GameLogic.GetFilters():apply_filters("show_custom_download_world", "close");
	if(isCustomShow == "close") then
		if(page) then
			page:CloseWindow();
			page = nil;
		end
	end
end