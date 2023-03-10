--[[
Title: Mainmenu in InGame UI for 3D Map system
Author(s): Andy, Xizhi
Date: 2007/12/29
Desc: Show the main menu in game UI
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemUI/Desktop/MainMenu.lua");
Map3DSystem.UI.MainMenu.InitMainMenu();
Map3DSystem.UI.MainMenu.SendMessage({type = Map3DSystem.UI.MainMenu.MSGTYPE.MENU_SHOW});
------------------------------------------------------------
]]

NPL.load("(gl)script/kids/3DMapSystem_Data.lua");
NPL.load("(gl)script/ide/MainMenu.lua");

if(not Map3DSystem.UI.MainMenu) then Map3DSystem.UI.MainMenu={}; end

Map3DSystem.UI.MainMenu.UIname = "MainMenu_bar";

-- messge types
Map3DSystem.UI.MainMenu.MSGTYPE = {
	MENU_SHOW = 1000,
}

-- add a menu command at given position. the parent folders must be created beforehand, otherwise it will be inserted to the first unfound folder.
-- if there is already an object at the position, the add command will do nothing. 
-- @param command; type of Map3DSystem.App.Command
-- @param position: this is a tree path string of folder names separated by dot
--  e.g. "Tools.Artist", "File.Save", "File.Open".
-- @param posIndex: if position is a item in another folder, this is the index at which to add the item. 
-- if nil, it is added to end, if 1 it is the beginning. 
function Map3DSystem.UI.MainMenu.AddMenuCommand(command, position, posIndex)
	local ctl = CommonCtrl.GetControl("PW_MainMenu");
	if(ctl~=nil)then
		local node = ctl.RootNode;
		local nodeName;
		
		for nodeName in string.gfind(position, "([^%.]+)") do
			local subnode = node:GetChildByName(nodeName);	
			if(subnode == nil) then
				if( command.CommandStyle ~= Map3DSystem.App.CommandStyle.Separator) then
					-- menu command is inserted to the first unfound folder in position
					-- TODO: shall we display something different if the command is unavailable, locked, etc. 
					node:AddChild(CommonCtrl.TreeNode:new({Name = nodeName, Text = command.ButtonText, Icon = command.icon, 
						AppCommand = command, onclick = Map3DSystem.UI.MainMenu.OnClickCommand}), posIndex);
				else
					-- it is just a separator. 
					node:AddChild(CommonCtrl.TreeNode:new({Name = nodeName, Type = "separator", NodeHeight=5}));
				end		
				break;
			else
				node = subnode;
			end
		end
	end
end

-- return an iterator for all menu commands whose appkey is same as input
-- @param appkey: appkey we search for. 
function Map3DSystem.UI.MainMenu.GetAppCommands(appkey)
	local ctl = CommonCtrl.GetControl("PW_MainMenu");
	if(ctl~=nil)then
		local node = ctl.RootNode:GetNextNode2();
		return function()
			while (node~=nil) do
				if(node.AppCommand and node.AppCommand.app_key==appkey) then
					local appCommand = node.AppCommand;
					node = node:GetNextNode2();
					return appCommand;
				else
					node = node:GetNextNode2();
				end
			end
		end
	end
	return function() return nil end
end

-- return a menu item index by its position. This function is mosted called before AddMenuCommand to determine where to insert a new command. 
-- @param position: this is a tree path string of folder names separated by dot
--  e.g. "Tools.Artist", "File.Save", "File.Open".
-- @return nil if not found, other the item index integer is returned. please note that the index may change when new items are added later on. 
function Map3DSystem.UI.MainMenu.GetItemIndex(position)
	local ctl = CommonCtrl.GetControl("PW_MainMenu");
	local index;
	if(ctl~=nil)then
		local node = ctl.RootNode;
		local nodeName;
		
		for nodeName in string.gfind(position, "([^%.]+)") do
			node = node:GetChildByName(nodeName);	
			if(node == nil) then
				break;
			end
		end
		if(node ~= nil) then
			index = node.index;
		end
	end
	return index; 
end

-- call the application command
function Map3DSystem.UI.MainMenu.OnClickCommand(treeNode)
	if(treeNode~=nil and treeNode.AppCommand~=nil)then
		treeNode.AppCommand:Call();
	end
end

-- call this only once during the game. 
-- init main bar: this does not show the menu, it just build the data structure and messaging system.
function Map3DSystem.UI.MainMenu.InitMainMenu()
	if(Map3DSystem.UI.MainMenu.IsInit) then return end
	Map3DSystem.UI.MainMenu.IsInit = true;
	
	NPL.load("(gl)script/ide/os.lua");
	local _app = CommonCtrl.os.CreateGetApp("MainMenu");
	Map3DSystem.UI.MainMenu.App = _app;
	Map3DSystem.UI.MainMenu.MainWnd = _app:RegisterWindow("main", nil, Map3DSystem.UI.MainMenu.MSGProc);
end


-- send a message to MainMenu:main window handler
-- Map3DSystem.UI.MainMenu.SendMessage({type = Map3DSystem.UI.MainMenu.MSGTYPE.MENU_SHOW});
function Map3DSystem.UI.MainMenu.SendMessage(msg)
	msg.wndName = "main";
	Map3DSystem.UI.MainMenu.App:SendMessage(msg);
end


-- main bar: MainMenu window handler
function Map3DSystem.UI.MainMenu.MSGProc(window, msg)
	if(msg.type == Map3DSystem.UI.MainMenu.MSGTYPE.MENU_SHOW) then
		-- show, hide or toggle the main bar UI
		Map3DSystem.UI.MainMenu.Show(msg.bShow);
	end
end

-- private: for autohide animation. 
local function OnMenuAutoHideToggle(bShow, uiobj)
	if(bShow and uiobj and uiobj:IsValid()) then
		if(not Map3DSystem.UI.MainMenu.FadeInMotion_) then
			-- create animation if not create before. 
			NPL.load("(gl)script/ide/Motion/AnimatorEngine.lua");
			Map3DSystem.UI.MainMenu.FadeInMotion_ = CommonCtrl.Motion.AnimatorEngine:new({framerate=24});
			local groupManager = CommonCtrl.Motion.AnimatorManager:new();
			local layerManager = CommonCtrl.Motion.LayerManager:new();
			local PopupAnimator = CommonCtrl.Motion.Animator:new();
			PopupAnimator:Init("script/kids/3DMapSystemUI/styles/MenuFadeInMotionData.xml", uiobj.id);
			
			layerManager:AddChild(PopupAnimator);
			groupManager:AddChild(layerManager);
			groupManager:AddChild(layerBGManager);
			Map3DSystem.UI.MainMenu.FadeInMotion_:SetAnimatorManager(groupManager);
		end	
		-- play animation
		Map3DSystem.UI.MainMenu.FadeInMotion_:doPlay();
	end	
end

-- show or hide main bar UI
function Map3DSystem.UI.MainMenu.Show(bShow)
	local _this,_parent;
	local left,top,width,height;
	
	_this = ParaUI.GetUIObject(Map3DSystem.UI.MainMenu.UIname);
	if(_this:IsValid())then
		if(bShow==nil) then
			_this.visible = not _this.visible;
		else
			_this.visible = bShow;
		end
	else
		if( bShow == false)then
			return;
		end
		_this = ParaUI.CreateUIObject("container", Map3DSystem.UI.MainMenu.UIname, "_mt", 0, 0, 0, 22)
		--_this.background = "Texture/whitedot.png";
		--_this.color = "255 255 255 120";
		_this.background = "Texture/3DMapSystem/common/ThemeLightBlue/toolbar_bg.png";
		
		_this:AttachToRoot();
		
		-- enable auto hide for this menu, using 5 pixel height area. 
		NPL.load("(gl)script/ide/AutoHide.lua");
		CommonCtrl.AutoHide.EnableAutoHide(_this, {leave_interval=2.5, height=5, ontoggle=OnMenuAutoHideToggle})

		_parent = _this;
		
		--_this = ParaUI.CreateUIObject("button", "btnExitApp", "_rt", -24, 0, 20, 20)
		--_this.background = "Texture/3DMapSystem/MainBarIcon/ExitApp.png";
		--_this.tooltip = "??????????????????";
		--_parent:AddChild(_this);
--
		--_this = ParaUI.CreateUIObject("button", "btnHelp", "_rt", -46, 0, 20, 20)
		--_this.background = "Texture/3DMapSystem/MainBarIcon/help.png";
		--_this.tooltip = "????????????";
		--_parent:AddChild(_this);]]
--
		--_this = ParaUI.CreateUIObject("button", "searchMap", "_rt", -100, 0, 20, 20)
		--_this.background = "Texture/3DMapSystem/webbrowser/goto.png";
		--_parent:AddChild(_this);
		--
		--_this = ParaUI.CreateUIObject("text", "s", "_rt", -280, 0, 60, 20)
		--_this.text = "??????";
		--_guihelper.SetUIFontFormat(_this, 36+256);-- 36 for single-lined  vertical center alignment
		--_parent:AddChild(_this);
--
		--NPL.load("(gl)script/ide/dropdownlistbox.lua");
		--local ctl = CommonCtrl.dropdownlistbox:new{
			--name = "comboBoxSearchMap",
			--alignment = "_rt",
			--left = -240,
			--top = 0,
			--width = 138,
			--height = 20,
			--dropdownheight = 106,
 			--parent = _parent,
			--text = "",
			--items = {"?????????", "ParaEngine?????????", "?????????"},
		--};
		--ctl:Show();
		
		------------------------------------------
		-- replace this with a menu control in IDE. refer to context menu. 
		------------------------------------------
		local ctl = CommonCtrl.GetControl("PW_MainMenu");
		if(ctl==nil)then
			ctl = CommonCtrl.MainMenu:new{
				name = "PW_MainMenu",
				alignment = "_lt",
				left = 0,
				top = 0,
				width = 450,
				height = 20,
				parent = _parent,
				popmenu_container_bg = "Texture/3DMapSystem/ContextMenu/BG2.png:8 8 8 8",
				--onclick = function (node, param1) _guihelper.MessageBox(node.Text) end
			};
			local level1;
			local node = ctl.RootNode:AddChild(CommonCtrl.TreeNode:new({Text = "??????", Name = "File"}));
			level1 = node;
			
			node = node:AddChild(CommonCtrl.TreeNode:new({Text = "??????", Name = "New", Expanded = false}));
			
			node = level1;
			node = node:AddChild(CommonCtrl.TreeNode:new({Text = "??????", Name = "Open", Expanded = false}));
			node = level1;
					
			node:AddChild(CommonCtrl.TreeNode:new({Name = "Group2", Type = "separator", NodeHeight=5}));	
			node:AddChild(CommonCtrl.TreeNode:new({Name = "GroupLast",  Type = "separator", NodeHeight=5}));
			node:AddChild(CommonCtrl.TreeNode:new({Text = "????????????", Name = "signout", onclick=function()
					-- back to main startup
					Map3DSystem.reset();
					main_state = nil;
				end}));		
			node:AddChild(CommonCtrl.TreeNode:new({Text = "??????", Name = "model browser", onclick=function()
					_guihelper.MessageBox("?????????????????????????", Map3DSystem.UI.Exit.OnExit);
				end}));	
			
			node = ctl.RootNode:AddChild(CommonCtrl.TreeNode:new({Text = "?????????", Name = "Profile"}));
			level1 = node;
			--node:AddChild("????????????");
			--node:AddChild("????????????");
			--node:AddChild("????????????");
			--node:AddChild("????????????");
			node:AddChild(CommonCtrl.TreeNode:new({Name = "Group1", Type = "separator", NodeHeight=5}));
			--node:AddChild("????????????");
			--node = node:AddChild(CommonCtrl.TreeNode:new({Text = "????????????", Name = "my worlds", Expanded = false}));
			--node:AddChild("??????1");
			--node:AddChild("??????2");
			--node:AddChild("??????3");
			
			node = level1;
			node:AddChild(CommonCtrl.TreeNode:new({Name = "Group2", Type = "separator", NodeHeight=5}));	
			-- node:AddChild("???????????????...");
			node = node:AddChild(CommonCtrl.TreeNode:new({Text = "??????????????????", Name = "app", Icon = "Texture/3DMapSystem/common/plugin.png"}));
			--node:AddChild("?????????");
			--node:AddChild("?????????");
			--node:AddChild("Poke");
			--node:AddChild("??????");
			
			
			node = ctl.RootNode:AddChild(CommonCtrl.TreeNode:new({Text = "??????", Name = "Friends"}));
			--node:AddChild("????????????");
			node:AddChild(CommonCtrl.TreeNode:new({Name = "Group1", Type = "separator", NodeHeight=5}));
			--node:AddChild("?????????");
			--node:AddChild("???????????????");
			--node:AddChild("???????????????");
			--node:AddChild(CommonCtrl.TreeNode:new({Name = "Group2", Type = "separator", NodeHeight=5}));
			--node:AddChild("?????????");
			--node:AddChild("????????????");
			
			
			node = ctl.RootNode:AddChild(CommonCtrl.TreeNode:new({Text = "??????", Name = "Map"}));
			--node:AddChild("????????????");
			--node:AddChild("??????");
			node:AddChild(CommonCtrl.TreeNode:new({Name = "Group1", Type = "separator", NodeHeight=5}));
			node = node:AddChild(CommonCtrl.TreeNode:new({Text = "????????????", Name = "Locations"}));
			
			--node:AddChild("MC????????????");
			--node:AddChild("ParaEngine??????");
			--node:AddChild("?????????");
			--node:AddChild("?????????");
			--node:AddChild("?????????");
			--node:AddChild("????????????");
			--node:AddChild("?????????");
			--node:AddChild("??????????????????");
			--node:AddChild("?????????");
			--node:AddChild("K??????");
			--node:AddChild("???????????????");
			--node:AddChild("?????????");
			--node:AddChild("???????????????");
			--node:AddChild("??????");
			--node:AddChild("?????????");
			--node:AddChild("????????????");
			--node:AddChild("????????????");
			--node:AddChild("MC????????????");
			--node:AddChild("APP???");
			
			
			-- TODO: it should be implemented by the local inventory
			--node = ctl.RootNode:AddChild("?????????");
			--node:AddChild("????????????(0)");
			--node:AddChild("????????????(1)");
			--node:AddChild("????????????(2)");
			--node:AddChild("????????????(3)");
			--node:AddChild("????????????(4)");
			--node:AddChild("????????????(5)");
			--
			--node = ctl.RootNode:AddChild("??????(1)");
			--node:AddChild("?????????");
			--node:AddChild("?????????(1)");

			node = ctl.RootNode:AddChild(CommonCtrl.TreeNode:new({Text = "??????", Name = "Help"}));
			--node:AddChild("???????????????");
			--node:AddChild(CommonCtrl.TreeNode:new({Text = "", Type = "separator", NodeHeight=5}));
			--node:AddChild("?????? ...");
			--node:AddChild(CommonCtrl.TreeNode:new({Text = "??????", Icon="Texture/3DMapSystem/MainBarIcon/help.png"}));
			--node:AddChild(CommonCtrl.TreeNode:new({Text = "", Type = "separator", NodeHeight=5}));
			--node:AddChild("APP SDK ??????");
			--node:AddChild("APP ????????????...");
			--node:AddChild(CommonCtrl.TreeNode:new({Name = "Group2", Type = "separator", NodeHeight=5}));	
			--node:AddChild("???????????????");
			--node:AddChild("ParaEngine??????");
			node:AddChild(CommonCtrl.TreeNode:new({Name = "GroupLast", Type = "separator", NodeHeight=5}));
			--node:AddChild("?????? & ?????????");
			
			-------------------------------------------
			-- Disable this at release time. 
			if(not ReleaseBuild)then
				node = ctl.RootNode:AddChild("[????????????]");
				node:AddChild(CommonCtrl.TreeNode:new({Text = "???????????????", Name = "model browser", onclick=function()
					_guihelper.MessageBox("???????????????(??????)->??????->??????????????? ?????????????????????\n         2008.4.28 LiXizhi")
				end}));
				node:AddChild(CommonCtrl.TreeNode:new({Text = "????????????...", Name = "old settings", onclick=function()
					NPL.activate("(gl)script/demo/setting/t7_setting.lua");
				end}));
				
				node:AddChild(CommonCtrl.TreeNode:new({Text = "???????????????...", Name = "attachment editor", onclick=function()
					NPL.load("(gl)script/kids/3DMapSystemUI/InGame/ItemEditor.lua");
					Map3DSystem.UI.ItemEditor.Show();	
				end}));
				
				node:AddChild(CommonCtrl.TreeNode:new({Text = "????????????...", Name = "test panel", onclick=function()
					NPL.load("(gl)script/kids/3DMapSystemUI/InGame/TestPanel.lua");
					Map3DSystem.UI.TestPanel.Show();
				end}));
				
				node:AddChild(CommonCtrl.TreeNode:new({Text = "????????????...", Name = "animation tester", onclick=function()
					NPL.load("(gl)script/kids/3DMapSystemUI/InGame/TestPanel.lua");
					Map3DSystem.UI.TestPanel.TestExternalAnimation();
				end}));
				
				node:AddChild(CommonCtrl.TreeNode:new({Text = "???????????????...", Name = "quick launch bar", onclick=function()
					NPL.load("(gl)script/kids/3DMapSystemUI/InGame/Creation.lua");
					Map3DSystem.UI.Creation.ShowQuickLaunchBar();
				end}));
			end	
			--------------------------------------------
		else
			ctl.parent = _parent;
		end
		
		ctl:Show(true);
		
		--_this = ParaUI.CreateUIObject("text", "s", "_lt", 400, 5, 400, 20)
		--_this.text = "????????? ?????????????????????????????????????????????????????????";
		--_this.enabled = false; -- so that it does not receive events
		--_this:GetFont("text").color = "100 0 0";
		--_parent:AddChild(_this);
		
		-- update menu items according to the current user profile.
		Map3DSystem.UI.MainMenu.UpdateUI();
	end
end

-- update UI according to data 
function Map3DSystem.UI.MainMenu.UpdateUI()
	
end