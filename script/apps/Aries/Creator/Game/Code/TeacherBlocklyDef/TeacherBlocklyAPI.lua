--[[
Title: Teacher Block 
Author(s): chenjinxian
Date: 2020/6/1
Desc: 
use the lib:
-------------------------------------------------------
local TeacherBlocklyAPI = NPL.load("(gl)script/apps/Aries/Creator/Game/Code/TeacherBlocklyDef/TeacherBlocklyAPI.lua");
-------------------------------------------------------
]]
NPL.load("(gl)script/ide/headon_speech.lua");
NPL.load("(gl)script/ide/System/localserver/URLResourceStore.lua");
NPL.load("(gl)script/apps/Aries/Creator/HttpAPI/keepwork.rawfile.lua");
local TeachingQuestPage = NPL.load("(gl)script/apps/Aries/Creator/Game/Tasks/TeachingQuest/TeachingQuestPage.lua");
local TeacherBlocklyAPI = commonlib.inherit(nil, NPL.export());

function TeacherBlocklyAPI:ctor()
	self.type = "program";
	self.name = "编程导师";
end

-- private:invoke code block API 
function TeacherBlocklyAPI:InvokeMethod(name, ...)
	return self.codeEnv[name](...);
end

local publicMethods = {
"BecomeTeacherNPC", "SetTeacherNPCTasks", "anim", "BecomeGeneralNPC",
}

-- create short cut in code API
function TeacherBlocklyAPI:InstallAPIToCodeEnv(codeEnv)
	for _, func_name in ipairs(publicMethods) do
		local func = self[func_name];
		if(type(func) == "function") then
			codeEnv[func_name] = function(...)
				return func(self, ...);
			end
		end
	end
end

function TeacherBlocklyAPI:Init(codeEnv)
	local fileName = "script/UIAnimation/CommonBounce.lua.table";
	UIAnimManager.LoadUIAnimationFile(fileName);
	self.codeEnv = codeEnv;
	self:InstallAPIToCodeEnv(codeEnv);
		
	-- global functions for canvas
	return self;
end

-- program data https://keepwork.com/official/paracraft/config/program
-- https://api.keepwork.com/core/v0/repos/official%2Fparacraft/files/official%2Fparacraft%2Fconfig%2Fprogram.md
-- animation data https://keepwork.com/official/paracraft/config/animation
-- https://api.keepwork.com/core/v0/repos/official%2Fparacraft/files/official%2Fparacraft%2Fconfig%2Fanimation.md
-- CAD data https://keepwork.com/official/paracraft/config/CAD
-- https://api.keepwork.com/core/v0/repos/official%2Fparacraft/files/official%2Fparacraft%2Fconfig%2FCAD.md

-- @param penBlockId: default to 10
function TeacherBlocklyAPI:BecomeTeacherNPC(type)
	local actor = self:InvokeMethod("getActor", "myself");
	if (actor) then
		self.obj = actor:GetEntity();
	end

	self.type = TeachingQuestPage.TaskTypeIndex[type] or TeachingQuestPage.UnknowType;

	local function getTaskFromUrl(taskName, callback)
		--[[
		keepwork.rawfile.get({
			cache_policy =  "access plus 0",
			router_params = {
				repoPath = "official%%2Fparacraft",
				filePath = "official%%2Fparacraft%%2Fconfig%%2F"..taskName..".md",
			}
		},function(err, msg, data)
			local result = commonlib.LoadTableFromString(data);
			if (result and callback) then
				callback(result);
			end
		end)
		]]
		keepwork.npc.list({cache_policy = "access plus 0", code = taskName}, function(err, msg, data)
			if (data and #data > 0) then
				local result = {};
				result.npcName = data[1].npcName;
				result.npcScript = data[1].npcScript;
				keepwork.npc.tasks({cache_policy = "access plus 0", code = taskName}, function(err, msg, data)
					result.npcTasks = {};
					if (data and data.rows) then
						for i = 1, #data.rows do
							result.npcTasks[i] = {pid = data.rows[i].pid, title = data.rows[i].title, info = data.rows[i].info, url = data.rows[i].url};
						end
						if (callback) then
							callback(result);
						end
					end
				end);
			end
		end);
	end

	getTaskFromUrl(TeachingQuestPage.TaskTypeNames[self.type], function(data)
		self.name = data.npcName or self.name;
		local tasks = data.npcTasks;
		TeachingQuestPage.RegisterTasksChanged(function(state)
			self:ShowHeadOn(state);
		end, self.type);
		TeachingQuestPage.AddTasks(tasks, self.type);
		self:InvokeMethod("registerClickEvent", function()
			if (data.npcScript) then
				TeacherBlocklyAPI.RunExternalFunc(data.npcScript);
			end
		end);
	end);
end

function TeacherBlocklyAPI:BecomeGeneralNPC(configName, npcType)
	local actor = self:InvokeMethod("getActor", "myself");
	if (actor) then
		self.obj = actor:GetEntity();
	end

	local function getTaskFromUrl(taskName, callback)
		keepwork.rawfile.get({
			cache_policy =  "access plus 0",
			router_params = {
				repoPath = "official%%2Fparacraft",
				filePath = "official%%2Fparacraft%%2Fconfig%%2F"..taskName..".md",
			}
		},function(err, msg, data)
			local result = commonlib.LoadTableFromString(data);
			if (result and callback) then
				callback(result);
			end
		end)
	end

	getTaskFromUrl(configName, function(datas)
		if (type(datas) ~= "table") then return end
		for i = 1, #datas do
			local data = datas[i];
			if (data.npcType == npcType) then
				self.name = data.npcName or self.name;
				self:ShowHeadOn(data.npcState or TeachingQuestPage.AllFinished, data.npcColor);
				self:InvokeMethod("registerClickEvent", function()
					if (data.npcScript) then
						TeacherBlocklyAPI.RunExternalFunc(data.npcScript);
					end
				end);
				break;
			end
		end
	end);
end

-- not used
function TeacherBlocklyAPI:SetTeacherNPCTasks(tasks, callback)
	--[[
	if (tasks and type(tasks) == "table") then
		TeachingQuestPage.RegisterTasksChanged(function(state)
			self:ShowHeadOn(state);
		end, self.type);
		TeachingQuestPage.AddTasks(tasks, self.type);
		self:InvokeMethod("registerClickEvent", function()
			TeachingQuestPage.ShowPage(self.type);
		end);err
	end
	]]
end

function TeacherBlocklyAPI:anim(anim_id)
	anim_id = anim_id or 0;
	local actor = self:InvokeMethod("getActor", "myself");
	if (actor) then
		local entity = actor:GetEntity();
		if(entity) then
			entity:EnableAnimation(true);
			if(actor.UnbindAnimInstance) then
				-- this ensures that actor are not bound to current bone position in the movie block
				actor:UnbindAnimInstance();
			end
			entity:SetAnimation(anim_id);
		end
	end
end

function TeacherBlocklyAPI:ShowHeadOn(state, npcColor)
	if (not self.obj) then return end
	--local actor_name = {L"编程导师", L"动画导师", L"CAD导师", L"机器人导师"};
	if (state == TeachingQuestPage.AllFinished) then
		local headon_mcml = string.format(
			[[<pe:mcml><div style="margin-left:-100px;margin-top:-60px;width:200px;height:20px;">
				<div style="margin-top:20px;width:200px;height:20px;text-align:center;font-size:15px;base-font-size:15;font-weight:bold;shadow-quality:8;color:%s;shadow-color:#8000468e;text-shadow:true">%s</div>
			</div></pe:mcml>]],
			npcColor or "#fcf73c", self.name);
		--headon_speech.Speak(self.obj, headon_mcml, -1, nil, true, nil, -100);
		self.obj:SetHeadOnDisplay({url=ParaXML.LuaXML_ParseString(headon_mcml)})
	else
		local state_img = {"Texture/Aries/HeadOn/exclamation.png", "Texture/Aries/HeadOn/question.png"};
		local left = {"92px", "84px"};
		local width = {"16px", "32px"};
		local headon_mcml = string.format(
			[[<pe:mcml><div style="margin-left:-100px;margin-top:-120px;width:200px;height:80px;">
				<img style="margin-left:%s;width:%s;height:64px;background:url(%s);background-animation:url(script/UIAnimation/CommonBounce.lua.table#ShakeUD);" />
				<div style="margin-top:20px;width:200px;height:20px;text-align:center;font-size:15px;base-font-size:15;font-weight:bold;shadow-quality:8;color:%s;shadow-color:#8000468e;text-shadow:true">%s</div>
			</div></pe:mcml>]],
			left[state], width[state], state_img[state], npcColor or "#fcf73c", self.name);

		--[[
		local ctl_name = headon_speech.Speak(self.obj, headon_mcml, -1, nil, true, nil, -100);
		local _parent = ParaUI.GetUIObject(ctl_name);
		local img = _parent:GetChildAt(0):GetChildAt(0);
		local fileName = "script/UIAnimation/CommonBounce.lua.table";
		UIAnimManager.PlayUIAnimationSequence(img, fileName, "ShakeUD", true);
		]]
		self.obj:SetHeadOnDisplay({url=ParaXML.LuaXML_ParseString(headon_mcml)})
	end
end


function TeacherBlocklyAPI.RunExternalFunc(func)
	if (type(func) == "string" and func ~= "") then
		NPL.DoString(func);
	end
end