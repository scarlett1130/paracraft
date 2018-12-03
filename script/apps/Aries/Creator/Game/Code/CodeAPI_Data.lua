--[[
Title: CodeAPI
Author(s): LiXizhi
Date: 2018/6/8
Desc: sandbox API environment
use the lib:
-------------------------------------------------------
NPL.load("(gl)script/apps/Aries/Creator/Game/Code/CodeAPI_Data.lua");
-------------------------------------------------------
]]
NPL.load("(gl)script/apps/Aries/Creator/Game/Code/CodeUI.lua");
NPL.load("(gl)script/apps/Aries/Creator/Game/Code/CodeGlobals.lua");
local CodeGlobals = commonlib.gettable("MyCompany.Aries.Game.Code.CodeGlobals");
local EntityManager = commonlib.gettable("MyCompany.Aries.Game.EntityManager");
local CodeUI = commonlib.gettable("MyCompany.Aries.Game.Code.CodeUI");
local GameLogic = commonlib.gettable("MyCompany.Aries.Game.GameLogic");
local env_imp = commonlib.gettable("MyCompany.Aries.Game.Code.env_imp");


-- simple log any object, same as echo. 
function env_imp:log(...)
	commonlib.echo(...);
end

function env_imp:echo(obj, ...)
	commonlib.echo(obj, ...);
	GameLogic.RunCommand("/echo "..commonlib.serialize_in_length(obj, 100))
end

-- get the entity associated with the actor.
function env_imp:GetEntity()
	if(self.actor) then
		return self.actor:GetEntity();
	end		
end

function env_imp:GetActor()
	return self.actor;
end


function env_imp:getActorValue(name)
	if(self.actor) then
		return self.actor:GetActorValue(name)
	end
end

function env_imp:setActorValue(name, value)
	if(self.actor) then
		self.actor:SetActorValue(name, value)
	end
end

function env_imp:showVariable(name, title, color)
	if(type(name) == "string") then
		local item = CodeUI:ShowGlobalData(name, title, color);
		if(item) then
			item:TrackCodeBlock(self.codeblock)
		end
	end
end

-- make the current actor an agent of input entity. 
-- The entity could be current player or a network player on server.
-- @param entityName: "@p" means current player, or any valid player name or entity name. 
function env_imp:becomeAgent(entityName)
	if(self.actor) then
		local entity;
		if(entityName == "@p") then
			entity = EntityManager.GetPlayer();
		else
			entity = EntityManager.GetEntity(entityName);
		end
		self.actor:BecomeAgent(entity);
	end
end

-- set the code block output value, this is the wire signal that this code block will emit, 
-- the signal can be tracked by a block repeater. 
function env_imp:setOutput(result)
	if(self.codeblock) then
		self.codeblock:SetOutput(tonumber(result))
	end
end

-- @param filename: include a file relative to current world directory
function env_imp:include(filename)
	if(self.codeblock) then
		return self.codeblock:IncludeFile(filename)
	end
end

-- get actor by name
-- @param name: nil or "myself" means current actor, or any actor name
function env_imp:getActor(name)
	if(name == "myself" or not name) then
		return self.actor;
	else
		return GameLogic.GetCodeGlobal():GetActorByName(name);
	end
end