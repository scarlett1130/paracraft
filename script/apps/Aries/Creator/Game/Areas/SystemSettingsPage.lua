--[[
Title: code behind for page SystemSettingsPage.html
Author(s): LiXizhi
Date: 2009/10/18
Desc: script/apps/Aries/Creator/Game/Areas/SystemSettingsPage.html
Use Lib:
-------------------------------------------------------
NPL.load("(gl)script/apps/Aries/Creator/Game/Areas/SystemSettingsPage.lua");
MyCompany.Aries.Creator.Game.Desktop.SystemSettingsPage.AutoAdjustGraphicsSettings(true, function(bChanged) end)
local stats = MyCompany.Aries.Creator.Game.Desktop.SystemSettingsPage.GetPCStats()
MyCompany.Aries.Creator.Game.Desktop.SystemSettingsPage.DoCheckMinimumSystemRequirement();
-------------------------------------------------------

-------------------------------------------------------
NPL.load("(gl)script/apps/Aries/Creator/Game/Areas/SystemSettingsPage.lua");
local SystemSettingsPage = commonlib.gettable("MyCompany.Aries.Creator.Game.Desktop.SystemSettingsPage");
SystemSettingsPage.ShowPage()
-------------------------------------------------------
]]
NPL.load("(gl)script/apps/Aries/Creator/Game/Commands/CommandManager.lua");
NPL.load("(gl)script/apps/Aries/Scene/main.lua");
NPL.load("(gl)script/apps/Aries/Creator/Game/game_logic.lua");
NPL.load("(gl)script/ide/System/Windows/Screen.lua");
local KpChatChannel = NPL.load("(gl)script/apps/Aries/Creator/Game/Areas/ChatSystem/KpChatChannel.lua");
local Scene = commonlib.gettable("MyCompany.Aries.Scene");
local GameLogic = commonlib.gettable("MyCompany.Aries.Game.GameLogic");
local CommandManager = commonlib.gettable("MyCompany.Aries.Game.CommandManager");
local pe_gridview = commonlib.gettable("Map3DSystem.mcml_controls.pe_gridview");
local Screen = commonlib.gettable("System.Windows.Screen");
local SystemSettingsPage = commonlib.gettable("MyCompany.Aries.Creator.Game.Desktop.SystemSettingsPage");

local WorldCommon = commonlib.gettable("MyCompany.Aries.Creator.WorldCommon");

local recommended_resolution = {1020,595}
local recommended_resolution_web_browser = {960,560}
local recommended_resolution_teen = {1280,760}
local default_sound_container_posY = 0
local default_sound_device_container_posY = 0
SystemSettingsPage.category_ds_index = 1;
SystemSettingsPage.category_show = {
	{left_text=L"?????????",name="ScreenResolution",right_type=""},
	{left_text=L"????????????",name="graphic_quality",right_type=""},
	{left_text=L"?????????",},
	{left_text=L"OpenGL",name="",right_type="button"},
	{left_text=L"??????",name="checkBoxFullScreenMode",right_type="button",onclick="GameLogic.OnToggleViewBobbing"},
	{left_text=L"??????",name="",right_type="button"},
	{left_text=L"????????????",name="",right_type="button"},
	{left_text=L"????????????",name="",right_type="button"},
	{left_text=L"??????",name="",right_type="button"},
	{left_text=L"????????????",name="",right_type="button"},
	{left_text=L"????????????",name="",right_type="button"},
	{left_text=L"????????????",name="",right_type="button"},
}

SystemSettingsPage.category_game = {
		{left_text=L"????????????", name="checkBoxInverseMouse",right_type="button",onclick=""},
		{left_text=L"???????????????", name="",right_type="button",onclick=""},
		{left_text=L"???????????????", name="checkBoxLockCamera",right_type="button",onclick=""},
		{left_text=L"???????????????", name="",right_type="button",onclick=""},
		{left_text=L"??????????????????", name="checkboxLockMouseWheel",right_type="button",onclick=GameLogic.OnToggleLockMouseWheel},
		{left_text=L"UI????????????", name="",right_type="button",onclick=""},
		{left_text=L"????????????", name="",right_type="button",onclick=""},
		{left_text=L"????????????", name="",right_type="button",onclick=""},
		{left_text=L"??????", name="EnableSound",right_type="button",onclick=""},
		{left_text=L"??????", name="",right_type="button",onclick=""},
		{left_text=L"????????????", name="",right_type=""},
}

SystemSettingsPage.category_operation = {	
		
		--{left_text="???????????????", name="",right_type="button",onclick="GameLogic.OnToggleViewBobbing"},
		--{left_text="UI????????????", name="",right_type="button",onclick="GameLogic.OnToggleUIScaling"},
		--{left_text="??????????????????",name="",right_type="button",onclick="GameLogic.OnToggleLockMouseWheel"},	

		{left_text=L"????????????",name="mouse_left",right_type=""},
		{left_text=L"????????????",name="mouse_right",right_type=""},
		{left_text=L"????????????",name="mouse_mid",right_type=""},	
		{left_text=L"??????",name="",right_type="text",right_value="W"},	
		{left_text=L"??????",name="",right_type="text",right_value="A"},	
		{left_text=L"??????",name="",right_type="text",right_value="S"},	
		{left_text=L"??????",name="",right_type="text",right_value="D"},	
		{left_text=L"??????",name="",right_type="text",right_value="Space"},	
		{left_text=L"??????",name="",right_type="text",right_value="Shift"},	
		{left_text=L"??????",name="",right_type="text",right_value="F"},	
		{left_text=L"??????",name="",right_type="text",right_value="E"},	
		{left_text=L"??????",name="",right_type="text",right_value="F1"},	
		{left_text=L"??????????????????",name="",right_type="text",right_value="Ctrl + X"},	
		{left_text=L"??????????????????",name="",right_type="text",right_value="Ctrl + Y"},	   
}

SystemSettingsPage.mouse_select_list = {
	["DeleteBlock"] = "left",
	["CreateBlock"] = "right",
	["ChooseBlock"] = "middle",
}

local page;
-- purchase the item directly from global store
function SystemSettingsPage.OnInit()
	SystemSettingsPage.category_ds = {
		{text=L"??????", name="show"},
		{text=L"??????", name="audioparam"},
		{text=L"??????", name="operation"},
		{text=L"??????", name="others"},
		--{text=L"??????", name="world"},
	}

	SystemSettingsPage.sound_volume_list = {
		[L"???"] = {dist = 0.5, next = L"???"},
		[L"???"] = {dist = 1.5, next = L"???"},
		[L"???"] = {dist = 2.5, next = L"???"},
	}

	SystemSettingsPage.render_dist_list = {
		[L"???"] = {dist = 60, next = L"???"},
		[L"???"] = {dist = 120,next = L"???"},
		[L"???"] = {dist = 180,next = L"???"},		
	}

	SystemSettingsPage.shader_ds = {
		{value="1", text=L"??????"},
		{value="2", text=L"??????"},
		{value="3", text=L"HDR"},
		{value="4", text=L"Dof/HDR"},
	}

	page = document:GetPageCtrl();
	page.OnClose = SystemSettingsPage.OnClose;
	SystemSettingsPage.setting_ds = {};
	SystemSettingsPage.InitPageParams();

	--
	local nRenderMethod = ParaTerrain.GetBlockAttributeObject():GetField("BlockRenderMethod", 1);

	for i, item in ipairs(SystemSettingsPage.shader_ds) do
		if(i == nRenderMethod) then
			item.selected = true;
		else
			item.selected = nil;
		end
	end
	
	page:SetValue("comboShader",  tostring(math.min(math.max(1, nRenderMethod), 4)) );

	SystemSettingsPage.stereoMode_ds = {
		{value="0", text=L"Off"},
		{value="2", text=L"Left/Right"},
		{value="5", text=L"Red/Blue"},
	}
	
	local stereoMode = GameLogic.options:GetStereoMode() or 0
	for i,item in ipairs(SystemSettingsPage.stereoMode_ds) do
		if tonumber(item.value) == stereoMode then 
			item.selected = true;
		else
			item.selected = nil;
		end
	end
	page:SetValue("stereomode",  tostring(stereoMode) );

	Screen:Connect("sizeChanged", SystemSettingsPage, SystemSettingsPage.OnResize, "UniqueConnection")
end

local function GetRenderDistText(dist)
	local text = "";
	if(dist < 90) then
		text = L"???"
	elseif(dist < 150) then
		text = L"???"
	elseif(dist < 210) then
		text = L"???"
	end
	return text;
end

local function GetSoundVolumeText(value)
	local text = "";
	if(value < 1) then
		text = L"???"
	elseif(value < 2) then
		text = L"???"
	else
		text = L"???"
	end
	return text;
end


local CheckBoxText = {
	on = L"???",
	off = L"???",
}

local function GetCheckBoxText(value)
	if(value == true or value == "true") then
		return CheckBoxText.on;
	else
		return CheckBoxText.off;
	end
end

local function UpdateCheckBox(name, bChecked)
	local useDefaultStyle = GameLogic.GetFilters():apply_filters('SystemSettingsPage.CheckBoxBackground', page, name, bChecked);
	if(page) then
		bChecked = bChecked == true or bChecked == "true";
		if (useDefaultStyle or useDefaultStyle == nil) then
			page:CallMethod(name, "SetUIBackground", bChecked and "Texture/Aries/Creator/keepwork/setting/qiehuan1_108X29_32bits.png;0 0 108 29" or "Texture/Aries/Creator/keepwork/setting/qiehuan2_108X29_32bits.png;0 0 108 29");
		end
	end
end

local function UpdateSliderBarValue(name,value)
	if(page) then
		page:SetValue(name, value);
	end
end

function SystemSettingsPage:OnResize()
	local ds = SystemSettingsPage.setting_ds;
	local is_full_screen = SystemSettingsPage.IsFullScreenMode()
	if ds["is_full_screen"]~=is_full_screen or SystemSettingsPage.needRefreshWithResize then
		if page then
			page:Refresh(0)
		end
	end
	UpdateCheckBox("btn_FullScreenMode", is_full_screen)
	ds["is_full_screen"] = is_full_screen;
	SystemSettingsPage.needRefreshWithResize = nil
	if page then
		local ctl = page:FindControl("UI_Scaling")
		if ctl.max~=SystemSettingsPage.GetMaxUIScale() then
			GameLogic.options:SetUIScaling(nil)
			ctl.min = 0.6
			ctl.max = SystemSettingsPage.GetMaxUIScale()
			ctl.value = SystemSettingsPage.GetDefaultUiScale()
			ctl:UpdateUI()
		end

	end
end

function SystemSettingsPage.IsFullScreenMode()
	local IsWindowMaximized = ParaEngine.GetAttributeObject():GetField("IsWindowMaximized", false)
	return IsWindowMaximized
end

function SystemSettingsPage.GetDefaultUiScale()
	local ret = GameLogic.options:GetUIScaling()
	return ret;
end

function SystemSettingsPage.GetMaxUIScale()
	local ret = 2
	local frame_width, frame_height = Screen:GetWindowSolution()
	ret = frame_height/GameLogic.options.min_ui_height
	return ret;
end
--????????????
function SystemSettingsPage.IsRealShaderOn()
	local nRenderMethod = tonumber(WorldCommon.GetWorldInfo().rendermethod)
	if nRenderMethod then
		return nRenderMethod>1
	end
	return false
end

function SystemSettingsPage.OnToggleShader(name, value)
	local res = GameLogic.options:SetRenderMethod(value,true)
	if not res then
		Page:SetValue("comboShader", "1");
	else
		if page then
			if value=="1" then
				SystemSettingsPage.setting_ds["water_reflection"] = WorldCommon.GetWorldInfo().waterreflection~="true"
				SystemSettingsPage.setting_ds["sunlight_shadow"] = WorldCommon.GetWorldInfo().shadow~="true"
				SystemSettingsPage.OnClickEnableWaterReflection()
				SystemSettingsPage.OnClickEnableShadow()
			end
			page:Refresh(0)
		end
	end
end

function SystemSettingsPage.OnRenderDistChanged(value)
    GameLogic.options:SetRenderDist(value,true);
    
end

function SystemSettingsPage.GetDftRenderDist()
	local dist = tonumber(WorldCommon.GetWorldInfo().renderdist)
	return dist or GameLogic.options:GetRenderDist();
end

function SystemSettingsPage.OnSuperRenderDistChanged(value)
    GameLogic.options:SetSuperRenderDist(value,true);
    if(value and value > GameLogic.options:GetRenderDist() and value>64) then
        GameLogic.options:SetFogEnd(value - 64);
    end
end

function SystemSettingsPage.GetDftSuperRenderDist()
	local dist = tonumber(WorldCommon.GetWorldInfo().superrenderdist)
	return dist or GameLogic.options:GetSuperRenderDist();
end

function SystemSettingsPage.InitPageParams()
	local ds = SystemSettingsPage.setting_ds;
	-- load the current settings. 
	local att = ParaEngine.GetAttributeObject();
	-- ????????????
	local mouse_inverse = att:GetField("IsMouseInverse", false);
	UpdateCheckBox("btn_MouseInverse", mouse_inverse);
	ds["mouse_inverse"] = mouse_inverse;

	-- ????????????
	local view_bobbing = GameLogic.options.ViewBobbing;
	if view_bobbing ~= true then
		view_bobbing = false
	end
	UpdateCheckBox("btn_ViewBobbing", view_bobbing);
	ds["view_bobbing"] = view_bobbing;


	-- ??????
	if false then --?????????
		local is_full_screen = att:GetField("IsFullScreenMode", false);
		UpdateCheckBox("btn_FullScreenMode", is_full_screen)
		ds["is_full_screen"] = is_full_screen;
	else
		local is_full_screen = att:GetField("IsWindowMaximized", false);
		UpdateCheckBox("btn_FullScreenMode", is_full_screen)
		ds["is_full_screen"] = is_full_screen;
	end
	
	-- ????????????
	--local is_mouse_inverse = att:GetField("IsMouseInverse", false);
	--UpdateCheckBox("btn_MouseInverse", is_mouse_inverse)
	--ds["is_mouse_inverse"] = is_mouse_inverse;
	-- ?????????
	local screen_resolution =  string.format("%d ?? %d", att:GetDynamicField("ScreenWidth", 1020), att:GetDynamicField("ScreenHeight", 680))
	page:SetNodeValue("ScreenResolution", screen_resolution) -- ?????????	
	ds["screen_resolution"] = screen_resolution;

	-- stereo view mode
	local stereoMode = GameLogic.options:GetStereoMode();
	page:SetNodeValue("stereomode", tostring(stereoMode))
	ds["stereomode"] = tostring(stereomode);
	
	-- ????????????
	local open_sound = if_else(ParaAudio.GetVolume()>0,true,false)
	UpdateCheckBox("btn_EnableSound", open_sound)
	ds["open_sound"] = open_sound;

	-- ????????????
	--local sound_volume = ParaAudio.GetVolume();
	local sound_volume = Game.PlayerController:LoadLocalData("Paracraft_System_Sound_Volume",1,true);
	--local sound_volume_text = GetSoundVolumeText(sound_volume);
	--page:SetNodeValue("btn_SoundVolume", sound_volume_text);
	ds["sound_volume"] = sound_volume;


	-- ????????????
	local enable_deferred_shading = GameLogic.GetShaderManager():IsDeferredShading();
	UpdateCheckBox("btn_Shader", enable_deferred_shading);
	ds["enable_deferred_shading"] = enable_deferred_shading;

	-- disable shader command
	local bDisableShaderCmd = GameLogic.options:IsDisableShaderCommand();
	UpdateCheckBox("btn_DisableShaderCmd", bDisableShaderCmd);
	ds["disableShaderCmd"] = bDisableShaderCmd;

	
	-- ????????????
	local sunlight_shadow = if_else(ParaTerrain.GetBlockAttributeObject():GetField("UseSunlightShadowMap", false) == true,true,false);
	UpdateCheckBox("btn_Shadow", sunlight_shadow);
	ds["sunlight_shadow"] = sunlight_shadow;

	-- ????????????
	local water_reflection = if_else(ParaTerrain.GetBlockAttributeObject():GetField("UseWaterReflection", false) == true,true,false);
	UpdateCheckBox("btn_WaterReflection", water_reflection);
	ds["water_reflection"] = water_reflection;

	-- ????????????
	local show_mainplayer = if_else(GameLogic.options:IsShowMainPlayer() == true,true,false);
	UpdateCheckBox("btn_ShowPlayer", show_mainplayer);
	ds["show_mainplayer"] = show_mainplayer;

	-- ?????????, ??????30 - 90 ??????90 - 150 ??????150 - 210
	local render_dist = ParaTerrain.GetBlockAttributeObject():GetField("RenderDist", 100);
	local render_dist_text = GetRenderDistText(render_dist);
	page:SetNodeValue("btn_RenderDist", render_dist_text);
	ds["render_dist"] = render_dist_text;


	-- movie block aspect ratio 
	local bAspectRatio = GameLogic.options:IsMaintainMovieBlockAspectRatio();
	UpdateCheckBox("btn_MovieAspectRatio", bAspectRatio);
	ds["maintainMovieAspectRatio"] = bAspectRatio;

    -- bullet screen
    local bOpened = KpChatChannel.BulletScreenIsOpened()
	UpdateCheckBox("btn_BulletScreen", bOpened);

	-- FPS
	UpdateCheckBox("btn_AutoFPS", GameLogic.options:IsAutoMovieFPS());


	-- ????????????
	-- local profile = KeepWorkItemManager.GetProfile() or {}
	local mouse_select_list = Game.PlayerController:LoadRemoteData("SystemSettingsPage.mouse_select_list", nil)
	if mouse_select_list then
		SystemSettingsPage.mouse_select_list = mouse_select_list
	end
	-- for k, v in pairs(SystemSettingsPage.mouse_select_list) do
	-- 	page:SetNodeValue(k, v)	
	-- end
	local is_on = SystemSettingsPage.mouse_select_list["DeleteBlock"] == "right"
	-- UpdateCheckBox("btn_MouseChange", is_on);
	page:SetNodeValue("ChangeMouseLeftRight", is_on);
end

function SystemSettingsPage.OnClose()
	SystemSettingsPage.category_ds_index = 1
	Screen:Disconnect("sizeChanged", SystemSettingsPage, SystemSettingsPage.OnResize, "UniqueConnection")
end

function SystemSettingsPage.RefreshPage()
	if page then
		page:Refresh(0)
		if (SystemSettingsPage.category_ds_index == 2) then
			SystemSettingsPage.InitSoundDevice()
		end
	end
end

-- shader version
local function GetShaderVersion()
	local stats = SystemSettingsPage.GetPCStats();
	local ps_Version = stats.ps;
	local vs_Version = stats.vs;
	local shader_version = 0;
	if(vs_Version > ps_Version) then
		shader_version = ps_Version;
	else
		shader_version = vs_Version;
	end
	return shader_version;
end

local min_requirement_data = nil;

function SystemSettingsPage.onclickShowHeadOnDisplay(bChecked)
    ParaScene.GetAttributeObject():SetField("ShowHeadOnDisplay", bChecked);
end

function SystemSettingsPage.onclickFreeWindowSize(bChecked)
    ParaEngine.GetAttributeObject():SetField("IgnoreWindowSizeChange", not bChecked);
end

function SystemSettingsPage.checkBoxEnableTeamInvite(bChecked)
	GameLogic.GetPlayerController():SaveLocalData("SystemSettingsPage.checkBoxEnableTeamInvite", bChecked);
end

function SystemSettingsPage.checkBoxDisableFamilyChat(bChecked)
	-- GameLogic.GetPlayerController():SaveLocalData("SystemSettingsPage.checkBoxDisableFamilyChat", bChecked);
	NPL.load("(gl)script/apps/Aries/Chat/FamilyChatWnd.lua");
	local FamilyChatWnd = commonlib.gettable("MyCompany.Aries.Chat.FamilyChatWnd");
	FamilyChatWnd.BlockChat(bChecked);
end

function SystemSettingsPage.checkBoxAutoHPPotion(bChecked)
	GameLogic.GetPlayerController():SaveLocalData("SystemSettingsPage.checkBoxAutoHPPotion", bChecked);
end

function SystemSettingsPage.checkBoxEnableHeadonTextScaling(bChecked)
	GameLogic.GetPlayerController():SaveLocalData("SystemSettingsPage.checkBoxEnableHeadonTextScaling", bChecked);
	ParaScene.GetAttributeObject():SetField("HeadOn3DScalingEnabled", bChecked);
end

function SystemSettingsPage.checkBoxAllowAddFriend(bChecked)
	GameLogic.GetPlayerController():SaveLocalData("SystemSettingsPage.checkBoxAllowAddFriend", bChecked);
	System.options.isAllowAddFriend = bChecked;
end


function SystemSettingsPage.checkBoxEnableFriendTeleport(bChecked)
	System.options.EnableFriendTeleport = bChecked;
	GameLogic.GetPlayerController():SaveLocalData("SystemSettingsPage.EnableFriendTeleport", bChecked);
	ParaScene.GetAttributeObject():SetField("checkBoxEnableFriendTeleport", bChecked);
end

function SystemSettingsPage.checkBoxEnableAutoPickSingleTarget(bChecked)
	System.options.EnableAutoPickSingleTarget = bChecked;
	GameLogic.GetPlayerController():SaveLocalData("SystemSettingsPage.EnableAutoPickSingleTarget", bChecked);
	ParaScene.GetAttributeObject():SetField("checkBoxEnableAutoPickSingleTarget", bChecked);
end

function SystemSettingsPage.checkBoxEnableForceHideHead(bChecked)
	System.options.EnableForceHideHead = bChecked;
	GameLogic.GetPlayerController():SaveLocalData("SystemSettingsPage.EnableForceHideHead", bChecked);
	ParaScene.GetAttributeObject():SetField("checkBoxEnableForceHideHead", bChecked);
	-- force refresh avatar
	System.Item.ItemManager.RefreshMyself();
end

function SystemSettingsPage.checkBoxEnableForceHideBack(bChecked)
	System.options.EnableForceHideBack = bChecked;
	GameLogic.GetPlayerController():SaveLocalData("SystemSettingsPage.EnableForceHideBack", bChecked);
	ParaScene.GetAttributeObject():SetField("checkBoxEnableForceHideBack", bChecked);
	-- force refresh avatar
	System.Item.ItemManager.RefreshMyself();
end

function SystemSettingsPage.onclickLockCamera(bChecked)
    MyCompany.Aries.AutoCameraController:MakeEnable(bChecked); 
end

function SystemSettingsPage.checkBoxRightBottomTips(bChecked)
	NPL.load("(gl)script/apps/Aries/Desktop/Dock/LoopTips.lua");
	local LoopTips = commonlib.gettable("MyCompany.Aries.Desktop.LoopTips");
	LoopTips.OnCheckExpandBtn(bChecked)
end

-- check if minimum requirement is met to run the game. 
-- @param bShowUI: true to display UI when minimum requirement is not met. 
-- @param callbackFunc: the callback function (result, msg, bContinue)  end, in case bShowUI is true. the callback is called after user has clicked OK;
-- @return result, msg: There are three possible outcome: 1 user is qualified to run; 0 user is not fully qualified to run but can run in low resolution mode; -1 can not run no matter what. 
-- Text message is also shown to the user. 
function SystemSettingsPage.CheckMinimumSystemRequirement(bShowUI, callbackFunc)
	local result = 1;
	local sMsg = "";
	min_requirement_data = {};
	local function SetResult(res, msg)
		if(result>res) then
			result = res;
			min_requirement_data.result = res;
		end
		if(msg) then
			min_requirement_data.sMsg = sMsg.."<br/>"..msg;
			sMsg = sMsg.."\n"..msg;
		end
	end

	local stats = SystemSettingsPage.GetPCStats();
	if(stats.memory and stats.memory<500) then
		if(stats.memory<300) then
			SetResult(-1, "???????????????????????????");
		else
			SetResult(0, "???????????????????????????");
		end
	end
	
	if(stats.ps<2 or stats.vs < 2) then
		SetResult(0, "???????????????????????????");
	end

	if(bShowUI) then
		-- TODO: FOR testing, set result to 0 or -1
		-- SetResult(0, "???????????????????????????<br/>???????????????????????????");
		if(result<=0) then
			local params = {
				url = "script/apps/Aries/Desktop/AriesMinRequirementPage.html", 
				name = "AriesMinRequirementWnd", 
				isShowTitleBar = false,
				DestroyOnClose = true, -- prevent many ViewProfile pages staying in memory
				style = CommonCtrl.WindowFrame.ContainerStyle,
				zorder = 2,
				isTopLevel = true,
				directPosition = true,
					align = "_ct",
					x = -360/2,
					y = -530/2,
					width = 360,
					height = 530,
			}
			System.App.Commands.Call("File.MCMLWindowFrame", params);
			params._page.OnClose = function()
				if(callbackFunc) then
					callbackFunc(result, sMsg);
				end
			end
			return result, sMsg;
		end
	end
	if(callbackFunc) then
		callbackFunc(result, sMsg);
	end
	return result, sMsg;
end

local pc_stats;
-- get a table containing all kinds of stats for this computer. 
-- @return {videocard, os, memory, ps, vs}
function SystemSettingsPage.GetPCStats()
	if(not pc_stats) then
		pc_stats = {};
		pc_stats.videocard = ParaEngine.GetStats(0);
		pc_stats.os = ParaEngine.GetStats(1);
		
		local att = ParaEngine.GetAttributeObject();
		local sysInfoStr = att:GetField("SystemInfoString", "");
		local name, value, line;
		for line in sysInfoStr:gmatch("[^\r\n]+") do
			name,value = line:match("^(.*):(.*)$");
			if(name == "TotalPhysicalMemory") then
				value = tonumber(value)/1024;
				pc_stats.memory = value;
			else
				-- TODO: other OS settings
			end
		end
		pc_stats.ps = att:GetField("PixelShaderVersion", 0);
		pc_stats.vs = att:GetField("VertexShaderVersion", 0);

		-- uncomment to test low shader 
		--pc_stats.ps = 1;
		--pc_stats.memory = 300

		local att = ParaEngine.GetAttributeObject();
		pc_stats.IsFullScreenMode = att:GetField("IsFullScreenMode", false);
		pc_stats.IsWindowMaximized = att:GetField("IsWindowMaximized", false);
		pc_stats.resolution_x = tonumber(att:GetDynamicField("ScreenWidth", 1020)) or 1020;
		pc_stats.resolution_y = tonumber(att:GetDynamicField("ScreenHeight", 680)) or 680;
		pc_stats.IsWebBrowser = System.options.IsWebBrowser;
	end
	return pc_stats;
end

--return monitor resolution
--return width,height
function SystemSettingsPage.GetMonitorResolution()
	local att = ParaEngine.GetAttributeObject();
	local res = att:GetField("MonitorResolution",{1024,768})
	return res[1], res[2];
end

--return all supported display mode
--return value: { {width,height,refreshRate},{width,height,refreshRate}...}
function SystemSettingsPage.GetSupportDisplayMode()
	local att = ParaEngine.GetAttributeObject();
	local displayStr = att:GetField("DisplayMode","");
	if(displayStr == "")then
		return nil;
	end
	
	local result = {};
	local match;
	for match in string.gmatch(displayStr,"%d+ %d+ %d+") do
		local displayMode = {};
		displayMode.width,displayMode.height,displayMode.refreshRate = string.match(match,"(%d+) (%d+) (%d+)");
		table.insert(result,displayMode);
	end
	return result;
end

-- get a table containing {result, sMsg} as in CheckMinimumSystemRequirement;
function SystemSettingsPage.GetMinRequirementData()
	if(not min_requirement_data) then
		SystemSettingsPage.CheckMinimumSystemRequirement();
	end
	return min_requirement_data;
end

-- automatically adjust according to current graphics card shader version. 
-- @param bShowUI: true to display UI for user confirmation. 
-- @param callbackFunc: the callback function when settings have been adjusted. function(bChanged)  end
-- @param OnChangeCallback: nil or a callback function that is invoked before changes are applied. 
-- It gives the caller a chance to drop any changes made by returning false. e.g. in web edition, we can not modified changes directly,instead we need to invoke via IPC to change. 
function SystemSettingsPage.AutoAdjustGraphicsSettings(bShowUI, callbackFunc, OnChangeCallback)
	if(System.os.GetPlatform()~="win32") then
		-- skip this for non-win32 device
		if(type(callbackFunc) == "function") then
			callbackFunc(false);
		end
		return;
	end

	local att = ParaEngine.GetAttributeObject();
	local shader_version = GetShaderVersion();
	
	NPL.load("(gl)script/apps/Aries/Player/main.lua");
	local is_user_confirmed = Game.PlayerController:LoadLocalData("user_confirmed", false, true);
	
	local effect_level = att:GetField("Effect Level", 0);
	local screen_resolution = att:GetField("ScreenResolution", {800, 600}); 
	local new_screen_resolution;
	local new_effect_level;
	local use_terrain_normal;

	-- uncomment to test a given setting. 
	-- local new_screen_resolution = {400,300};
	-- local new_effect_level = 0;
	
	if(shader_version < 3) then
		-- for shader version smaller than 2, use 800*600 as default. 
		if(screen_resolution[1] > 800) then
			new_screen_resolution = {800, 533}
		end
		
		if(shader_version < 2) then
			if(effect_level ~= 1024) then
				new_effect_level = 1024;
			end
		elseif(shader_version < 3) then	
			if(effect_level > 0 and effect_level<100) then
				new_effect_level = 0;
			end
		end
		-- if video card is old, we will not use 32bits textures, which saves lots of video memory. 
		ParaEngine.GetAttributeObject():SetField("Is32bitsTextureEnabled", false)
		ParaScene.GetAttributeObjectOcean():SetField("IsAnimateFFT", false);
		use_terrain_normal = false;
	end

	local stats = SystemSettingsPage.GetPCStats();
	-- local test_low_memory = true; -- comment this at release time
	if(test_low_memory) then
		LOG.warn("this test line should be removed");
		stats.memory = 512;
	end
	
	local res_width, res_height = SystemSettingsPage.GetMonitorResolution();
	if(System.options.version=="teen") then
		NPL.load("(gl)script/apps/Aries/Player/main.lua");

		if(att:GetField("IsFullScreenMode",false) == false) then
			-- windowed mode
			recommended_resolution = recommended_resolution_teen;	
			if((res_width-60)<recommended_resolution[1]) then
				recommended_resolution[1] = res_width - 60;
			end
			if((res_height-80)<recommended_resolution[2]) then
				recommended_resolution[2] = res_height - 80;
			end
		end
	end
	recommended_resolution[1] = math.min(res_width, recommended_resolution[1]);
	recommended_resolution[2] = math.min(res_height, recommended_resolution[2]);

	if(System.options.IsWebBrowser) then
		recommended_resolution = recommended_resolution_web_browser;

		if(screen_resolution[1]>recommended_resolution[1] or screen_resolution[1] > recommended_resolution[2]) then
			-- for web version, the maximum resolution for web to start initially is this.  
			new_screen_resolution = recommended_resolution;
		end
	end

	if(shader_version >= 3 and effect_level == 0) then
		if(stats.memory and stats.memory>2000) then
			-- if shader version is high and physical memory is large, we will enable mesh reflection when effect level is high. 
			ParaScene.GetAttributeObjectOcean():SetField("EnableMeshReflection", true)
		end
	end
	
	-- if system memory is small, we will not use 32bits textures. 
	if(stats.memory and stats.memory < 600) then
		ParaEngine.GetAttributeObject():SetField("Is32bitsTextureEnabled", false);
		use_terrain_normal = false;
	end
	if(stats.memory and stats.memory < 2000) then
		-- we will assume memory over 2G is high end computer, so only animate FFT on it.  
		ParaScene.GetAttributeObjectOcean():SetField("IsAnimateFFT", false);
	end
	if(use_terrain_normal == false) then
		ParaTerrain.GetAttributeObject():SetField("UseNormals", false);
	end

	if(shader_version >= 3 and stats.memory>2000) then
		-- this allows us to change the resolution by dragging the window size. 
		ParaEngine.GetAttributeObject():SetField("IgnoreWindowSizeChange", false);
		-- only set when the computer is pretty cool. 
		
		if(not stats.IsFullScreenMode) then
			if(not System.options.IsWebBrowser) then
				if(screen_resolution[1]<recommended_resolution[1] or screen_resolution[1] < recommended_resolution[2]) then
					-- this is the recommended resolution for good computers with shader 3 and memory >2GB
					new_screen_resolution = recommended_resolution;
				end
			end
		end
		LOG.std(nil, "system", "settings", "enabled render resolution matching with window size, because your system is good enough.");
	end

	if(is_user_confirmed) then
		-- tricky: if the user has already confirmed changing the resolution, we will ignore auto modifications. 
		-- such that user can use a smaller or bigger resolution or effect regardless of its hardware. 
		new_effect_level =nil;
		if(not System.options.IsWebBrowser) then
			new_screen_resolution = nil;
		end
	end

	if(new_effect_level or new_screen_resolution) then
		local function ApplyChanges()
			local bApplyChange = true;
			if(OnChangeCallback) then
				local params = {
					shader_version = shader_version, -- number
					new_effect_level = new_effect_level, -- number
					new_screen_resolution = new_screen_resolution, -- nil or {x,y}
				}
				bApplyChange = (OnChangeCallback(params)~=false)
			end
			if(bApplyChange) then
				if(new_screen_resolution) then
					if(System.options.IsWebBrowser) then
						commonlib.app_ipc.ActivateHostApp("change_resolution", nil, new_screen_resolution[1], new_screen_resolution[2]);
					else	
						att:SetField("ScreenResolution", new_screen_resolution); 
					end	
				end	
				if(new_effect_level) then
					SystemSettingsPage.AdjustGraphicsSettingsByEffectLevel(new_effect_level)
					if(use_terrain_normal == false) then
						ParaEngine.GetAttributeObject():SetField("UseNormals", use_terrain_normal);
					end
				end
				if(new_screen_resolution) then
					att:CallField("UpdateScreenMode");
				end	
				ParaEngine.WriteConfigFile("config/config.txt");
				if(type(callbackFunc) == "function") then
					callbackFunc(true);
				end
			else
				callbackFunc(false);
			end	
		end
		
		if(bShowUI) then
			local text;
			if(new_effect_level == 1024) then
				_guihelper.MessageBox(L"???????????????????????????, ???????????????????????????3D???????????????????????????????????????????????????3D????????????", function(res)
					ApplyChanges();
				end, _guihelper.MessageBoxButtons.OK)
			else
				_guihelper.MessageBox(L"??????????????????????????????????????????, ???????????????????????????, ??????????????????????????????????????????????????????????????????", function(res)
					if(res and res == _guihelper.DialogResult.Yes) then
						ApplyChanges();
					else
						if(type(callbackFunc) == "function") then
							callbackFunc(false);
						end
					end	
				end, _guihelper.MessageBoxButtons.YesNo)
			end
			
		else
			ApplyChanges();
		end
	else
		if(type(callbackFunc) == "function") then
			callbackFunc(false);
		end
	end
end

-- set graphics settings by effect level.  This function can be called at the beginning. 
-- @param value: -1024, -1, 0,1,2
function SystemSettingsPage.AdjustGraphicsSettingsByEffectLevel(effect_level)
	local att = ParaEngine.GetAttributeObject();
	local att_ocean = ParaScene.GetAttributeObjectOcean();
	
	local FarPlane = 420;
	att:SetField("Effect Level", effect_level);
	
	local shader_version = GetShaderVersion();
	
	if(effect_level == 1024) then
		att:SetField("TextureLOD", 1);
		att:SetField("SetShadow", false);
		
		att_ocean:SetField("EnableTerrainReflection", false)
		att_ocean:SetField("EnableMeshReflection", false)
		att_ocean:SetField("EnablePlayerReflection", false)
		att_ocean:SetField("EnableCharacterReflection", false)
		
		FarPlane = 100;
				
	elseif(effect_level == -1) then
		att:SetField("TextureLOD", 1);
		att:SetField("SetShadow", false);
	
		att_ocean:SetField("EnableTerrainReflection", false)
		att_ocean:SetField("EnableMeshReflection", false)
		att_ocean:SetField("EnablePlayerReflection", false)
		att_ocean:SetField("EnableCharacterReflection", false)
		
		FarPlane = 120;
		
	elseif(effect_level == 0) then
		att:SetField("TextureLOD", 0);
		att:SetField("SetShadow", false);
	
		att_ocean:SetField("EnableTerrainReflection", false)
		att_ocean:SetField("EnableMeshReflection", false)
		att_ocean:SetField("EnablePlayerReflection", false)
		att_ocean:SetField("EnableCharacterReflection", false)
		
		if(shader_version > 2) then
			FarPlane = 420;
		else
			FarPlane = 220;
		end	
		
	elseif(effect_level == 1) then
		att:SetField("TextureLOD", 0);
		att:SetField("SetShadow", true);
	
		att_ocean:SetField("EnableTerrainReflection", true)
		att_ocean:SetField("EnableMeshReflection", true)
		att_ocean:SetField("EnablePlayerReflection", false)
		att_ocean:SetField("EnableCharacterReflection", false)
		
		FarPlane = 420;
		
	elseif(effect_level == 2) then
		att:SetField("TextureLOD", 0);
		att:SetField("SetShadow", true);
		
		att_ocean:SetField("EnableTerrainReflection", true)
		att_ocean:SetField("EnableMeshReflection", true)
		att_ocean:SetField("EnablePlayerReflection", true)
		att_ocean:SetField("EnableCharacterReflection", true)
		
		FarPlane = 420;
	end

	att:SetField("UseDropShadow", not att:GetField("SetShadow", false));
	
	if(FarPlane) then
		local FarPlane_range = {from=100,to=420}
		local FogStart_range = {from=50,to=80}
		local FogEnd_range	 = {from=70,to=130}
		
		value = (FarPlane-FarPlane_range.from) / (FarPlane_range.to- FarPlane_range.from);
		att:SetField("FogEnd", FogEnd_range.from + (FogEnd_range.to - FogEnd_range.from) * value);
		att:SetField("FogStart", FogStart_range.from + (FogStart_range.to - FogStart_range.from) * value);
		ParaCamera.GetAttributeObject():SetField("FarPlane", FarPlane);
	end	
end

function SystemSettingsPage.OnClickEnableSound()
	local cur_state = SystemSettingsPage.setting_ds["open_sound"];
	local next_state = not cur_state;
	SystemSettingsPage.setting_ds["open_sound"] = next_state;
	if(page)then
		if(next_state) then
			local key = "Paracraft_System_Sound_Volume"
			local sound_volume = Game.PlayerController:LoadLocalData(key,1,true);
			if sound_volume <= 0 then
				sound_volume = 1
			end
			ParaAudio.SetVolume(sound_volume);
		else
			ParaAudio.SetVolume(0);
		end
		SystemSettingsPage.RefreshPage()
	end
	local MapArea = commonlib.gettable("MyCompany.Aries.Desktop.MapArea");
	if(MapArea.EnableMusic) then
		MapArea.EnableMusic(next_state);
	end
	local key = "Paracraft_System_Sound_State";
	GameLogic.GetPlayerController():SaveLocalData(key,next_state,true);
end

function SystemSettingsPage.InitSoundDevice()
	local nodeDevice = ParaUI.GetUIObject("device_container")
	if nodeDevice and nodeDevice:IsValid() then
		nodeDevice.visible = false
	end
	if page then
		page:SetValue("AudioDevice", SystemSettingsPage.currentAudioDevice);
	end
	
	local cur_state = SystemSettingsPage.setting_ds["open_sound"];
	UpdateCheckBox("btn_EnableSound", cur_state)
end

function SystemSettingsPage.onClickShowDevice()
	local nodeDevice = ParaUI.GetUIObject("device_container")
	if nodeDevice and nodeDevice:IsValid() then
		nodeDevice.visible = not nodeDevice.visible
	end
end

function SystemSettingsPage.onDeviceClick(name)
	local index = tonumber(name)
	if index and index > 0 then
		local devices = SystemSettingsPage.GetAudioDevices()
		local curdevice = devices[index].value
		if (curdevice ~= SystemSettingsPage.currentAudioDevice) then
			AudioEngine.ResetAudioDevice(curdevice)
			SystemSettingsPage.currentAudioDevice = curdevice
			SystemSettingsPage.InitSoundDevice()
		end
	end
end

function SystemSettingsPage.OnClickResetAudioDevice()
	AudioEngine.ResetAudioDevice();
	SystemSettingsPage.currentAudioDevice = nil;
	SystemSettingsPage.RefreshPage()
end

function SystemSettingsPage.GetAudioDevices()
	local deviceList = {};
	local devices = ParaEngine.GetAttributeObject():GetField("AudioDeviceName", "");
	if (devices and devices ~= "") then
		local names = commonlib.split(devices, ";");
		for i = 1, #names do
			deviceList[#deviceList + 1] = {text = commonlib.Encoding.DefaultToUtf8(names[i]), value = names[i]};
		end
	end
	if (not SystemSettingsPage.currentAudioDevice and #deviceList > 0) then
		SystemSettingsPage.currentAudioDevice = deviceList[1].value;
	end
	return deviceList;
end

function SystemSettingsPage.OnClickEnableShader()
	local cur_state = SystemSettingsPage.setting_ds["enable_deferred_shading"];
	local next_state = not cur_state;
	if(not GameLogic.GetShaderManager():SetShaders(if_else(next_state, 2,1))) then
        if(next_state) then 
            page:SetValue("checkboxShader", false);
            _guihelper.MessageBox(L"?????????????????????????????????, ?????????????????????");
        end
    else
		UpdateCheckBox("btn_Shader", next_state);
		SystemSettingsPage.setting_ds["enable_deferred_shading"] = next_state;
		WorldCommon.GetWorldInfo().rendermethod = tostring(if_else(next_state, 2,1));
		local key = "Paracraft_use_deferred_shading";
		GameLogic.GetPlayerController():SaveLocalData(key,next_state,true);
		WorldCommon.SaveWorldTag()
    end
end

function SystemSettingsPage.OnClickDisableShaderCommand()
	local cur_state = SystemSettingsPage.setting_ds["disableShaderCmd"];
	local next_state = not cur_state;
	GameLogic.options:SetDisableShaderCommand(next_state);
	UpdateCheckBox("btn_DisableShaderCmd", next_state);
	SystemSettingsPage.setting_ds["disableShaderCmd"] = next_state;
end


function SystemSettingsPage.OnClickEnableShadow()
	local cur_state = SystemSettingsPage.setting_ds["sunlight_shadow"];
	local next_state = not cur_state;
	UpdateCheckBox("btn_Shadow", next_state);
    ParaTerrain.GetBlockAttributeObject():SetField("UseSunlightShadowMap", next_state);
	SystemSettingsPage.setting_ds["sunlight_shadow"] = next_state;
	WorldCommon.GetWorldInfo().shadow = tostring(next_state);
	WorldCommon.SaveWorldTag()
end

function SystemSettingsPage.OnClickEnableShowMainPlayer()
	local cur_state = SystemSettingsPage.setting_ds["show_mainplayer"];
	local next_state = not cur_state;
	UpdateCheckBox("btn_ShowPlayer", next_state);
	GameLogic.options:SetShowMainPlayer(next_state)
	SystemSettingsPage.setting_ds["show_mainplayer"] = next_state;
	WorldCommon.GetWorldInfo().hide_player = tostring(not next_state);
	WorldCommon.SaveWorldTag()
end

function SystemSettingsPage.OnClickEnableWaterReflection()
	local cur_state = SystemSettingsPage.setting_ds["water_reflection"];
	local next_state = not cur_state;
	UpdateCheckBox("btn_WaterReflection", next_state);
	ParaTerrain.GetBlockAttributeObject():SetField("UseWaterReflection", next_state)
	SystemSettingsPage.setting_ds["water_reflection"] = next_state;
	WorldCommon.GetWorldInfo().waterreflection = tostring(next_state);
	WorldCommon.SaveWorldTag()
end

function SystemSettingsPage.OnClickEnableMouseInverse()
	local cur_state = SystemSettingsPage.setting_ds["mouse_inverse"];
	local next_state = not cur_state;
	UpdateCheckBox("btn_MouseInverse", next_state);
	ParaEngine.GetAttributeObject():SetField("IsMouseInverse", next_state);
	--ParaTerrain.GetBlockAttributeObject():SetField("UseWaterReflection", not value)
	SystemSettingsPage.setting_ds["mouse_inverse"] = next_state;
	local key = "Paracraft_System_Mouse_Inverse";
	GameLogic.GetPlayerController():SaveLocalData(key,next_state,true);
end

function SystemSettingsPage.OnClickChangeRenderDist()
	local text = SystemSettingsPage.setting_ds["render_dist"];
	local new_text = SystemSettingsPage.render_dist_list[text]["next"];
	local next_dist = SystemSettingsPage.render_dist_list[new_text]["dist"];

	page:SetValue("btn_RenderDist", new_text);
	GameLogic.options:SetRenderDist(next_dist,true);
	SystemSettingsPage.setting_ds["render_dist"] = new_text;
	WorldCommon.GetWorldInfo().renderdist = tostring(next_dist);
	GameLogic.options:SetMaxViewDist(next_dist);
	WorldCommon.SaveWorldTag()
end

function SystemSettingsPage.OnClickChangeSoundVolume()
	local text = SystemSettingsPage.setting_ds["sound_volume"];
	local new_text = SystemSettingsPage.sound_volume_list[text]["next"];
	local next_volume = SystemSettingsPage.sound_volume_list[new_text]["dist"];

	page:SetValue("btn_SoundVolume", new_text);
	local sound_state = SystemSettingsPage.setting_ds["open_sound"];
	if(sound_state) then
		ParaAudio.SetVolume(next_volume);
	end
	SystemSettingsPage.setting_ds["sound_volume"] = new_text;
	local key = "Paracraft_System_Sound_Volume";
	GameLogic.GetPlayerController():SaveLocalData(key,next_volume,true);
end

function SystemSettingsPage.OnChangeSoundVolume(value)
	value = tonumber(value);
	local sound_state = SystemSettingsPage.setting_ds["open_sound"];
	if(value and sound_state) then
		local volume = value-- math.floor(value)
		if volume <= 0 then
			volume = 0.1
		end
		ParaAudio.SetVolume(volume);
		local key = "Paracraft_System_Sound_Volume";
		GameLogic.GetPlayerController():SaveLocalData(key,volume,true);
	end
end

function SystemSettingsPage.OnClickEnableBackgroundMusic(bChecked)
	GameLogic.GetPlayerController():SaveLocalData("SystemSettingsPage.EnableBackgroundMusic", bChecked, true)
	System.options.EnableBackgroundMusic = bChecked;
	if(bChecked) then
		Scene.ResumeRegionBGMusic()
	else
	    Scene.StopRegionBGMusic();
	end
end

function SystemSettingsPage.OnClick_hide_family_name(bChecked)
	GameLogic.GetPlayerController():SaveLocalData("SystemSettingsPage.hide_family_name", bChecked)
	System.options.hide_family_name = bChecked;

	MyCompany.Aries.Player.ShowHeadonTextForNID(tostring(System.User.nid));

	local nid, agent;
	for nid, agent in System.GSL_client:EachAgent() do
		if(agent:has_avatar()) then
			MyCompany.Aries.Player.ShowHeadonTextForNID(nid);
		end
	end
end

function SystemSettingsPage.OnClickEnableSound_ByArea(bChecked)
	if(page)then
		if(bChecked == true) then
			page:SetValue("trackBarVolume", 1)
			ParaAudio.SetVolume(1);
		else
			page:SetValue("trackBarVolume", 0)
			ParaAudio.SetVolume(0);
		end
		page:SetValue("EnableSound", bChecked);
	end
end

function SystemSettingsPage.OnClickEnableFullScreenMode()
	local attr = ParaEngine.GetAttributeObject()
	local ds = SystemSettingsPage.setting_ds;
	local is_full_screen = not ds["is_full_screen"];

	UpdateCheckBox("btn_FullScreenMode", is_full_screen);
	ds["is_full_screen"] = is_full_screen;

	SystemSettingsPage.needRefreshWithResize = true;
	if false then --?????????
		attr:SetField("ScreenResolution", attr:GetField("MonitorResolution"));
		attr:SetField("IsFullScreenMode", is_full_screen);
		attr:CallField("UpdateScreenMode");
	else
		attr:SetField("IsWindowMaximized",is_full_screen)
	end
end

function SystemSettingsPage.OnOK()
	local bNeedUpdateScreen;
	local att = ParaEngine.GetAttributeObject();
	local ds = SystemSettingsPage.setting_ds;

	--if(not System.options.IsWebBrowser) then
		--local fullScreen;
		--local value = page:GetValue("btn_FullScreenMode");
		--if(value == "??????") then
			--fullScreen = true;
		--elseif(value == "??????") then
			--fullScreen = false;
		--end	
--
		--if(att:GetField("IsFullScreenMode",false) ~= fullScreen) then
			--bNeedUpdateScreen = true;
		--end
--
		--att:SetField("IsFullScreenMode", fullScreen);
		--ParaUI.GetUIObject("root"):GetAttributeObject():SetField("EnableIME", fullScreen);
--
		--ds["is_full_screen"] = fullScreen;
--
	--end


	if(not System.options.IsWebBrowser) then
		value = page:GetValue("ScreenResolution");
		local x,y = string.match(value or "", "(%d+)%D+(%d+)");
		if(x~=nil and y~=nil) then
			x = tonumber(x)
			y = tonumber(y)
			if(x~=nil and y~=nil) then
				local size = {x, y};
				local oldsize = att:GetField("ScreenResolution", {1020,680});
				if(oldsize[1] ~=x or oldsize[2]~= y) then
					bNeedUpdateScreen = true;
				end
				if(System.options.IsWebBrowser) then
					commonlib.app_ipc.ActivateHostApp("change_resolution", nil, size[1], size[2]);
				else	
					att:SetField("ScreenResolution", size);
				end	
			end
		end
	end

	if(bNeedUpdateScreen) then
		_guihelper.MessageBox(L"??????????????????????????????:???????????????????????????, ?????????????????????????????????????", function ()
			ParaEngine.GetAttributeObject():CallField("UpdateScreenMode");
			-- we will save to "config.new.txt", so the next time the game engine is started, it will ask the user to preserve or not. 
			ParaEngine.WriteConfigFile("config/config.new.txt");
		end)
	else
		ParaEngine.WriteConfigFile("config/config.new.txt");
	end
	page:CloseWindow();
	--[[
	local bNeedUpdateScreen,value, bNeedRestart;
	local bForceShadow, ForceFarPlane;
	-- load the current settings. 
	local att = ParaEngine.GetAttributeObject();
	local att_engine = att;
	local value;
	if(not System.options.IsWebBrowser) then
		value = page:GetValue("checkBoxFullScreenMode");
		if(att:GetField("IsFullScreenMode",false) ~= value) then
			bNeedUpdateScreen = true;
		end	
		att:SetField("IsFullScreenMode", value);
		ParaUI.GetUIObject("root"):GetAttributeObject():SetField("EnableIME", value);
	end

	value = tonumber(page:GetValue("comboBoxMultiSampleType"));
	if(value) then
		bNeedRestart = bNeedRestart or (att:GetField("MultiSampleType",0) ~= value);
		att:SetField("MultiSampleType", value);
	end	
	
	value = tonumber(page:GetValue("comboBoxMultiSampleQuality"));
	if(value) then
		bNeedRestart = bNeedRestart or (att:GetField("MultiSampleQuality",0) ~= value);
		att:SetField("MultiSampleQuality", value);
	end	

	value = page:GetValue("checkBoxInverseMouse");
	if(type(value) == "boolean") then 
		att:SetField("IsMouseInverse", value);
	end	
	
	value = tonumber(page:GetValue("graphic_quality"));
	if(value) then
		commonlib.echo({graphic = value})
		if(value ~= att:GetField("Effect Level", 0)) then
			att:SetField("Effect Level", value);
			-- the set may be unsuccessful in case graphics card does not support it, so we will fetch it again here. 
			value = att:GetField("Effect Level", value);
			
			if(value == 1024) then
				value = -1024;
			end
			
			if(value<0) then
				att:SetField("TextureLOD", 1);
			else
				att:SetField("TextureLOD", 0);
			end	
			local att_ocean = ParaScene.GetAttributeObjectOcean();
			
			if(value>=1) then
				-- force using shadow if user selected high graphic mode
				bForceShadow = true;
				att_ocean:SetField("EnableTerrainReflection", true)
				att_ocean:SetField("EnableMeshReflection", true)
				ForceFarPlane = 420;
			else	
				bForceShadow = false
				att_ocean:SetField("EnableTerrainReflection", false)
				att_ocean:SetField("EnableMeshReflection", false)
			end
			if(value == -1) then
				ForceFarPlane = 200;
			elseif(value <= -1) then
				ForceFarPlane = 100;
			end
			
			if(value>=2) then
				att_ocean:SetField("EnablePlayerReflection", true)
				att_ocean:SetField("EnableCharacterReflection", true)
				att:SetField("MultiSampleQuality", 0);
				att:SetField("MultiSampleType", 0);
			else
				att_ocean:SetField("EnablePlayerReflection", false)
				att_ocean:SetField("EnableCharacterReflection", false)
				att:SetField("MultiSampleQuality", 0);
				att:SetField("MultiSampleType", 0);
			end
		end
	end
	
	if(not System.options.IsWebBrowser) then
		value = page:GetValue("ScreenResolution");
		local x,y = string.match(value or "", "(%d+)%D+(%d+)");
		if(x~=nil and y~=nil) then
			x = tonumber(x)
			y = tonumber(y)
			if(x~=nil and y~=nil) then
				local size = {x, y};
				local oldsize = att:GetField("ScreenResolution", {1020,680});
				if(oldsize[1] ~=x or oldsize[2]~= y) then
					bNeedUpdateScreen = true;
				end
				if(System.options.IsWebBrowser) then
					commonlib.app_ipc.ActivateHostApp("change_resolution", nil, size[1], size[2]);
				else	
					att:SetField("ScreenResolution", size);
				end	
			end
		end
	end
	
	local att = ParaScene.GetAttributeObject();
	
	if(bForceShadow~=nil) then
		value = bForceShadow;
	else
		value = page:GetValue("checkBoxUseShadow");
	end
	
	if(value~=nil and att:GetField("SetShadow", false)~=value) then
		att:SetField("SetShadow", value)
	end
	
	att:SetField("UseDropShadow", not att:GetField("SetShadow", false));
	
	local FarPlane = ForceFarPlane or page:GetValue("trackBarViewDistance"); 
	if(FarPlane) then
		local FarPlane_range = {from=100,to=420}
		local FogStart_range = {from=50,to=80}
		local FogEnd_range	 = {from=70,to=130}
		
		value = (FarPlane-FarPlane_range.from) / (FarPlane_range.to- FarPlane_range.from);
		att:SetField("FogEnd", FogEnd_range.from + (FogEnd_range.to - FogEnd_range.from) * value);
		att:SetField("FogStart", FogStart_range.from + (FogStart_range.to - FogStart_range.from) * value);
		ParaCamera.GetAttributeObject():SetField("FarPlane", FarPlane);
		
		att_engine:SetDynamicField("ViewDistance", FarPlane);
	end	
	
	value = tonumber(page:GetValue("trackBarVolume"));
	
	if(value) then
		if(not page:GetValue("EnableSound", true)) then
			value = 0;
		end
		
		att_engine:SetDynamicField("SoundVolume", value);
		-- set all volumes
		ParaAudio.SetVolume(value);
	end	
	
	page:CloseWindow();
	
	if(bNeedUpdateScreen) then
		_guihelper.MessageBox(L"??????????????????????????????:???????????????????????????, ?????????????????????????????????????", function ()
			ParaEngine.GetAttributeObject():CallField("UpdateScreenMode");
			-- we will save to "config.new.txt", so the next time the game engine is started, it will ask the user to preserve or not. 
			ParaEngine.WriteConfigFile("config/config.new.txt");
		end)
	else
		ParaEngine.WriteConfigFile("config/config.new.txt");
	end

	if(bNeedRestart or bNeedUpdateScreen) then
		NPL.load("(gl)script/apps/Aries/Player/main.lua");
		GameLogic.GetPlayerController():SaveLocalData("user_confirmed", true, true, false)
	end
		
	if(bNeedRestart) then
		_guihelper.MessageBox(L"????????????, ????????????????????????????????????, ????????????????????????");
		--_guihelper.MessageBox(L"????????????, ????????????????????????????????????, ?????????????????????????????????", function()
			--MyCompany.Aries.Desktop.Dock.PostLogoutTime(function()
				--Map3DSystem.App.Commands.Call("Profile.Aries.Restart", {method="hard"});
			--end);
		--end)
	end
	]]
end

function SystemSettingsPage.ShowPage()
	local customParams = GameLogic.GetFilters():apply_filters('SystemSettingsPage.PageParams');
	local params = customParams or {
		url = "script/apps/Aries/Creator/Game/Areas/SystemSettingsPage.html", 
		name = "SystemSettingsPage.ShowPage", 
		isShowTitleBar = false,
		DestroyOnClose = true,
		bToggleShowHide=true, 
		style = CommonCtrl.WindowFrame.ContainerStyle,
		allowDrag = true,
		enable_esc_key = true,
		--bShow = bShow,
		click_through = false, 
		zorder = 2,
		app_key = MyCompany.Aries.Creator.Game.Desktop.App.app_key, 
		directPosition = true,
			align = "_ct",
			x = -360/2,
			y = -530/2,
			width = 360,
			height = 530,
	};
	--CreatorDesktop.params.bShow = bShow;
	System.App.Commands.Call("File.MCMLWindowFrame", params);
	--SystemSettingsPage.InitPageParams()
	SystemSettingsPage.InitSoundDevice()
end

function SystemSettingsPage.OnCancel()
	if page then
		page:CloseWindow();
	end
end

--??????????????????????????????
function SystemSettingsPage.NeedShowViewBobbing()
	return WorldCommon.GetWorldTag("world_generator")=="paraworldMini" or WorldCommon.GetWorldTag("world_generator")=="paraworld"
end

function SystemSettingsPage.OnToggleViewBobbing()
	local value = not GameLogic.options:GetViewBobbing();
	GameLogic.options:SetViewBobbing(value);
	if(page) then
		UpdateCheckBox("btn_ViewBobbing", value);
	end
end

function SystemSettingsPage.OnChangeStereoMode(name, value)
	GameLogic.options:EnableStereoMode(value);
	WorldCommon.GetWorldInfo().stereoMode = tostring(value)
	WorldCommon.SaveWorldTag()
	if page then
		page:Refresh(0)
	end
end

function SystemSettingsPage.OnClearCache()
	GameLogic.RunCommand("/clearcache");
end

function SystemSettingsPage.OnChangeStereoEyeDist(value)
	value = tonumber(value);
	if(value) then
		GameLogic.options:SetStereoEyeSeparationDist(value);
	end
end

function SystemSettingsPage.OnTimeSliderChanged(value)
	if (value) then
		local time=(value/1000-0.5)*2;
		time = tostring(time);
		CommandManager:RunCommand("time", time);
	end
end

function SystemSettingsPage.OnChangeUIScaling(value)
	SystemSettingsPage.uiScaling = value
	SystemSettingsPage.mytimer = SystemSettingsPage.mytimer or commonlib.Timer:new({callbackFunc = function(timer)
		GameLogic.options:SetUIScaling(SystemSettingsPage.uiScaling);
	end})
	SystemSettingsPage.mytimer:Change(500)
end

function SystemSettingsPage.OnClickResetUIScaling()
	GameLogic.options:SetUIScaling(1);
	if(page) then
		page:SetValue("UI_Scaling", GameLogic.options:GetUIScaling());
	end
end

function SystemSettingsPage.OnClickMaintainMovieAspectRatio()
	local value = not GameLogic.options:IsMaintainMovieBlockAspectRatio();
	GameLogic.options:SetMaintainMovieBlockAspectRatio(value);
	if(page) then
		UpdateCheckBox("btn_MovieAspectRatio", value);
	end
end

function SystemSettingsPage.OnClickBulletScreen()
   local value = KpChatChannel.BulletScreenIsOpened() 
   value = not value;
	if(page) then
		UpdateCheckBox("btn_BulletScreen", value);
	end
    KpChatChannel.SetBulletScreen(value)
end

function SystemSettingsPage.OnClickAutoMovieFPS()
	if(page) then
		GameLogic.options:SetAutoMovieFPS(not GameLogic.options:IsAutoMovieFPS())
		UpdateCheckBox("btn_AutoFPS", GameLogic.options:IsAutoMovieFPS());
	end
end

function SystemSettingsPage.OnClearMemory()
	GameLogic.RunCommand("/clearmemory")
end

function SystemSettingsPage.OnOpenBackupFolder()
	GameLogic.world_revision:OnOpenRevisionDir();
end

function SystemSettingsPage.OnSetSchoolMode()
	_guihelper.MessageBox(L"??????????????????????????????360??????? ?????????????????????????????????????????????????????????????????????", function(res)
		if(res and res == _guihelper.DialogResult.Yes) then
			GameLogic.options:SetSchoolMode(360);
			if (System.options.isSchool) then
				_guihelper.MessageBox(L"????????????");
			end
		end
	end, _guihelper.MessageBoxButtons.YesNo);
end

function SystemSettingsPage.OnClickIsVipWorld(value)
	if(not GameLogic.IsReadOnly()) then
		GameLogic.IsVip("CreateVipWorld", true, function(result)
			if(result) then
				GameLogic.options:SetVipWorld(value)
			end
		end);
	end
end

function SystemSettingsPage.OnClickHasCopyright(value)
	if(not GameLogic.IsReadOnly()) then
		GameLogic.options:SetHasCopyright(value)
	end
end

function SystemSettingsPage.OnChangeMouseSetting(name, value)
	if SystemSettingsPage.mouse_select_list[name] == nil then
		return
	end

	local old_value = SystemSettingsPage.mouse_select_list[name]
	SystemSettingsPage.mouse_select_list[name] = value
	
	local value_to_key_list = {}
	for k, v in pairs(SystemSettingsPage.mouse_select_list) do
		if v == value and k ~= name then
			SystemSettingsPage.mouse_select_list[k] = old_value
		end

		-- page:SetNodeValue(k, SystemSettingsPage.mouse_select_list[k])
		value_to_key_list[SystemSettingsPage.mouse_select_list[k]] = k
	end

	SystemSettingsPage.RefreshPage()
	
	GameLogic.GetPlayerController():SaveRemoteData("SystemSettingsPage.mouse_select_list", SystemSettingsPage.mouse_select_list);
	GameLogic.options:SetMouseSettingList(value_to_key_list)
end

function SystemSettingsPage.GetMouseSetting(name)
	if name == nil then
		return ""
	end

	return SystemSettingsPage.mouse_select_list[name] or ""
end

function SystemSettingsPage.OnClickEnableMouseChange(value)
	page:SetNodeValue("ChangeMouseLeftRight", value);

	local change_event = value and "right" or "left"
	SystemSettingsPage.OnChangeMouseSetting("DeleteBlock", change_event)
end