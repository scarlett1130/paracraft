--[[
Title: paraworld list
Author(s): chenjinxian
Date: 2020/9/8
Desc: 
use the lib:
------------------------------------------------------------
local ParaWorldApply = NPL.load("(gl)script/apps/Aries/Creator/Game/Tasks/ParaWorld/ParaWorldApply.lua");
ParaWorldApply.ShowPage();
-------------------------------------------------------
]]
NPL.load("(gl)script/apps/Aries/Creator/HttpAPI/keepwork.world.lua");
local ParaWorldApply = NPL.export();

ParaWorldApply.CurrentWorld = nil;
ParaWorldApply.SelectGame = 0;
ParaWorldApply.SelectOrg = 1;
ParaWorldApply.SelectSchool = 2;
ParaWorldApply.SelectRegion = 3;
ParaWorldApply.SelectType = 0;

local page;
function ParaWorldApply.OnInit()
	page = document:GetPageCtrl();
end

function ParaWorldApply.ShowPage()
	ParaWorldApply.CheckIsMyParaworld(function(world)
		ParaWorldApply.CurrentWorld = world;
		local params = {
			url = "script/apps/Aries/Creator/Game/Tasks/ParaWorld/ParaWorldApply.html",
			name = "ParaWorldApply.ShowPage", 
			isShowTitleBar = false,
			DestroyOnClose = true,
			style = CommonCtrl.WindowFrame.ContainerStyle,
			allowDrag = true,
			enable_esc_key = true,
			app_key = MyCompany.Aries.Creator.Game.Desktop.App.app_key, 
			directPosition = true,
			align = "_ct",
			x = -520 / 2,
			y = -400 / 2,
			width = 520,
			height = 400,
		};
		System.App.Commands.Call("File.MCMLWindowFrame", params);

		ParaWorldApply.schoolData = nil
		ParaWorldApply.orgData = nil
		ParaWorldApply.SelectType = ParaWorldApply.SelectRegion;
		commonlib.TimerManager.SetTimeout(function()
			GameLogic.GetFilters():apply_filters('get_my_orgs_and_schools', function(schoolData, orgData)
				if type(schoolData) == "table" and schoolData.regionId then
					ParaWorldApply.schoolData= schoolData
				end
				if type(orgData) == "table" and #orgData > 0 then
					ParaWorldApply.orgData = orgData
				end

				ParaWorldApply.GetRegionData();
			end);
		end, 10);
	end);
end

function ParaWorldApply.CheckIsMyParaworld(callback)
	local projectId = GameLogic.options:GetProjectId();
	if (not projectId) then
		_guihelper.MessageBox(L"请先分享世界，分享后可以提交申请！");
		return;
	end
	projectId = tonumber(projectId);
	if (not projectId) then
		_guihelper.MessageBox(L"请先分享世界，分享后可以提交申请！");
		return;
	end
	local userId = tonumber(GameLogic.GetFilters():apply_filters('get_user_id'));

	keepwork.world.worlds_list({projectId = projectId}, function(err, msg, data)
		if (data and type(data) == "table") then
			for i = 1, #data do
				local world = data[i];
				if (world.projectId == projectId and world.userId == userId) then
					if (callback) then
						callback(world);
					end
					return;
				end
			end
			_guihelper.MessageBox(L"请先分享世界，分享后可以提交申请！");
		end
	end);
end

function ParaWorldApply.GetTypeList()
	local typeList = {};
	typeList[1] = {text = L"地域", value = "region"};
	if (ParaWorldApply.orgData and #ParaWorldApply.orgData > 0) then
		typeList[#typeList + 1] = {text = L"机构", value = "org"};
	end
	if (ParaWorldApply.schoolData) then
		typeList[#typeList + 1] = {text = L"学校", value = "school"};
	end
	return typeList;
end

function ParaWorldApply.GetGameList()
	local gameList = {};
	return;
end

function ParaWorldApply.GeOrgList()
	local orgList = {};
	if (ParaWorldApply.orgData) then
		for i = 1, #ParaWorldApply.orgData do
			orgList[i] = {text = ParaWorldApply.orgData[i].name, value = ParaWorldApply.orgData[i].id};
		end
	end
	return orgList;
end

function ParaWorldApply.GetSchoolList()
	local schoolList = {};
	if (ParaWorldApply.schoolData) then
		schoolList[1] = {text = ParaWorldApply.schoolData.name, value = ParaWorldApply.schoolData.id};
	end
	return schoolList;
end

function ParaWorldApply.GetWorldName()
	if (ParaWorldApply.CurrentWorld.extra and ParaWorldApply.CurrentWorld.extra.worldTagName) then
		return ParaWorldApply.CurrentWorld.extra.worldTagName;
	else
		return ParaWorldApply.CurrentWorld.worldName;
	end
end

function ParaWorldApply.GetWorldId()
	return string.format("%s（%d）", ParaWorldApply.GetWorldName(), ParaWorldApply.CurrentWorld.projectId);
end

function ParaWorldApply.GetWorldCommitId()
	return ParaWorldApply.CurrentWorld.commitId;
end

function ParaWorldApply.GetWorldCoverUrl()
	if (ParaWorldApply.CurrentWorld.extra and ParaWorldApply.CurrentWorld.extra.coverUrl and ParaWorldApply.CurrentWorld.extra.coverUrl ~= "") then
		return ParaWorldApply.CurrentWorld.extra.coverUrl;
	elseif (ParaWorldApply.CurrentWorld.project.extra and ParaWorldApply.CurrentWorld.project.extra.imageUrl) then
		return ParaWorldApply.CurrentWorld.project.extra.imageUrl;
	else
		return "";
	end
end

function ParaWorldApply.GetRegionData()
	ParaWorldApply.provinces = {
		{
			text = L"省",
			value = 0,
			selected = true,
		}
	}

	ParaWorldApply.cities = {
		{
			text = L"市",
			value = 0,
			selected = true,
		}
	}

	ParaWorldApply.areas = {
		{
			text = L"区",
			value = 0,
			selected = true,
		}
	}

	ParaWorldApply.GetProvinces(function(data)
		if type(data) ~= "table" then
			return false
		end

		ParaWorldApply.provinces = data

		if (page) then
			if (ParaWorldApply.schoolData) then
				ParaWorldApply.SelectType = ParaWorldApply.SelectSchool;
				page:Refresh(0);
				page:SetValue("paraworld_type", "school");
				page:SetValue("SchoolList", ParaWorldApply.schoolData.id);
				ParaWorldApply.GetCities(ParaWorldApply.schoolData.region.state.id, function(data)
					if type(data) ~= "table" then
						return false
					end

					ParaWorldApply.cities = data
				
					ParaWorldApply.GetAreas(ParaWorldApply.schoolData.region.city.id, function(data)
						if type(data) ~= "table" then
							return false
						end

						ParaWorldApply.areas = data
						page:Refresh(0);
						page:SetValue("paraworld_type", "school");
						page:SetValue("SchoolList", ParaWorldApply.schoolData.id);
						page:SetValue("province", ParaWorldApply.schoolData.region.state.id);
						page:SetValue("city", ParaWorldApply.schoolData.region.city.id);
						page:SetValue("area", ParaWorldApply.schoolData.region.county.id);
					end);
				end);
			elseif (ParaWorldApply.orgData and #ParaWorldApply.orgData > 0) then
				ParaWorldApply.SelectType = ParaWorldApply.SelectOrg;
				page:Refresh(0);
				page:SetValue("paraworld_type", "org");
				page:SetValue("OrgList", ParaWorldApply.orgData[1].id);
			else
				ParaWorldApply.provinces1 = {
					{
						text = L"省",
						value = 0,
						selected = true,
					}
				}

				ParaWorldApply.cities1 = {
					{
						text = L"市",
						value = 0,
						selected = true,
					}
				}

				ParaWorldApply.areas1 = {
					{
						text = L"区",
						value = 0,
						selected = true,
					}
				}
				ParaWorldApply.provinces1 = data;

				page:Refresh(0);
				page:SetValue("paraworld_type", "region");
			end
		end
	end)
end

function ParaWorldApply.GetProvinces(callback)
	GameLogic.GetFilters():apply_filters('get_school_region', 'province', nil, function(data)
		if type(data) ~= "table" then
			return false
		end

		if type(callback) == "function" then
			for key, item in ipairs(data) do
				item.text = item.name
				item.value = item.id
			end

			data[#data + 1] = {
				text = L"省",
				value = 0,
				selected = true,
			}

			callback(data)
		end
	end)
end

function ParaWorldApply.GetCities(id, callback)
	GameLogic.GetFilters():apply_filters('get_school_region',"city", id, function(data)
		if type(data) ~= "table" then
			return false
		end

		if type(callback) == "function" then
			for key, item in ipairs(data) do
				item.text = item.name
				item.value = item.id
			end

			data[#data + 1] = {
				text = L"市",
				value = 0,
				selected = true,
			}

			callback(data)
		end
	end)
end

function ParaWorldApply.GetAreas(id, callback)
	GameLogic.GetFilters():apply_filters('get_school_region', 'area', id, function(data)
		if type(data) ~= "table" then
			return false
		end

		if type(callback) == "function" then
			for key, item in ipairs(data) do
				item.text = item.name
				item.value = item.id
			end

			data[#data + 1] = {
				text = L"区",
				value = 0,
				selected = true,
			}

			callback(data)
		end
	end)
end

function ParaWorldApply.OnClose()
	page:CloseWindow();
end

function ParaWorldApply.OnOK()
	local name = page:GetValue("paraworld_name", nil);
	if (not name or name == "") then
		_guihelper.MessageBox(L"请输入有效的世界名称！");
		return;
	end

	local region = page:GetValue("city", nil);
	if (not region or region == 0) then
		_guihelper.MessageBox(L"请选择有效的区域！");
		return;
	end

	local objectId = 0;
	local type = page:GetValue("paraworld_type", nil);
	if (type == "game") then
		objectId = page:GetValue("GameList", nil);
		if (not objectId) then
			_guihelper.MessageBox(L"请选择有效的大赛项目！");
			return;
		end
	elseif (type == "org") then
		objectId = page:GetValue("OrgList", nil);
		if (not objectId) then
			_guihelper.MessageBox(L"请选择有效的机构！");
			return;
		end
	elseif (type == "school") then
		objectId = page:GetValue("SchoolList", nil);
		if (not objectId) then
			_guihelper.MessageBox(L"请选择有效的学校！");
			return;
		end
	elseif (type == "region") then
		objectId = page:GetValue("area_type", nil);
		if (not objectId or objectId == 0) then
			_guihelper.MessageBox(L"请选择有效的地域类型！");
			return;
		end
	end

	keepwork.world.apply({
		name = name,
		projectId = ParaWorldApply.CurrentWorld.projectId,
		objectId = objectId,
		objectType = type,
		cover = ParaWorldApply.GetWorldCoverUrl(),
		commitId = ParaWorldApply.CurrentWorld.commitId,
		regionId = region,
	}, function(err, msg, data)
		if (err == 200) then
			page:CloseWindow();
			_guihelper.MessageBox(L"提交成功，请等待审核！");
		else
			_guihelper.MessageBox(L"提交失败，请稍后重试！");
		end
	end);
end
