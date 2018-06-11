--[[
Title: Code Actor
Author(s): LiXizhi
Date: 2018/5/19
Desc: Code actor is the base class for CodeBlock-controlled actors. Code actor is managed by a Code Block.

use the lib:
-------------------------------------------------------
NPL.load("(gl)script/apps/Aries/Creator/Game/Code/CodeActor.lua");
local CodeActor = commonlib.gettable("MyCompany.Aries.Game.Code.CodeActor");
-------------------------------------------------------
]]
NPL.load("(gl)script/apps/Aries/Creator/Game/Movie/ActorNPC.lua");
NPL.load("(gl)script/apps/Aries/Creator/Game/Code/EntityCodeActor.lua");
NPL.load("(gl)script/ide/math/vector.lua");
NPL.load("(gl)script/apps/Aries/Creator/Game/Common/Direction.lua");
NPL.load("(gl)script/apps/Aries/Creator/Game/Physics/PhysicsWorld.lua");
local PhysicsWorld = commonlib.gettable("MyCompany.Aries.Game.PhysicsWorld");
local Direction = commonlib.gettable("MyCompany.Aries.Game.Common.Direction")
local vector3d = commonlib.gettable("mathlib.vector3d");
local BlockEngine = commonlib.gettable("MyCompany.Aries.Game.BlockEngine")
local block_types = commonlib.gettable("MyCompany.Aries.Game.block_types")
local GameLogic = commonlib.gettable("MyCompany.Aries.Game.GameLogic")
local EntityManager = commonlib.gettable("MyCompany.Aries.Game.EntityManager");

local Actor = commonlib.inherit(commonlib.gettable("MyCompany.Aries.Game.Movie.ActorNPC"), commonlib.gettable("MyCompany.Aries.Game.Code.CodeActor"));
Actor:Property("Name", "CodeActor");
Actor:Property({"entityClass", "EntityCodeActor"});
-- frame move interval in milliseconds
Actor:Property({"frameMoveInterval", 30, "GetFrameMoveInterval", "SetFrameMoveInterval", auto=true});
Actor:Property({"time", 0, "GetTime", "SetTime", auto=true});
-- the itemstack(TimeSeries) is changed
Actor:Signal("dataSourceChanged");
Actor:Signal("clicked", function(actor, mouseButton) end);
Actor:Signal("beforeRemoved", function(self) end);

function Actor:ctor()
	self.offsetPos = vector3d:new(0,0,0);
	self.offsetYaw = 0;
	self.codeEvents = {};
end

-- @param itemStack: movie block actor's item stack where time series data source of this entity is stored. 
function Actor:Init(itemStack, movieclipEntity)
	if(not Actor._super.Init(self, itemStack, movieclipEntity)) then
		return;
	end
	local entity = self.entity;
	entity:Connect("clicked", self, self.OnClick);
	return self;
end

function Actor:SetName(name)
	self.name = name;
end

function Actor:GetName()
	return self.name;
end

function Actor:OnClick(mouse_button)
	self:clicked(self, mouse_button);
end

-- @param block_id: if nil, it means any obstruction block.
-- @return true
function Actor:IsTouchingBlock(block_id)
	if(not self.entity) then
		return;
	end
	local aabb = self.entity:GetCollisionAABB();
	local blockMinX,  blockMinY, blockMinZ = BlockEngine:block(aabb:GetMinValues());
	local blockMaxX,  blockMaxY, blockMaxZ = BlockEngine:block(aabb:GetMaxValues());

    for bx = blockMinX, blockMaxX do
        for bz = blockMinZ, blockMaxZ do
            for by = blockMinY, blockMaxY do
                local block_template = BlockEngine:GetBlock(bx, by, bz);
                if (block_template) then
					if(block_template.id == block_id) then
						return true;
					elseif(not block_id and block_template.obstruction) then
						return true;
					end
                end
            end
		end
	end
end

-- @return false;
function Actor:IsTouchingEntity(entity2)
	if(not entity2) then
		return false;
	end
	local entity = self:GetEntity();
	if(entity and entity:GetCollisionAABB():Intersect(entity2:GetCollisionAABB())) then
		return true;
	end
end

-- only bounce in horizontal XZ plain, it just changes the direction/facing of the actor, so that the actor moves aways from the collision. 
function Actor:Bounce()
	if(not self.entity) then
		return;
	end
	local aabb = self.entity:GetCollisionAABB();
	local listCollisions = PhysicsWorld:GetCollidingBoundingBoxes(aabb, self.entity);

	local facing = self.entity:GetFacing();
	local dx, dz;
	dx = math.cos(facing) * 0.1;
	dz = -math.sin(facing) * 0.1;
	local offsetX, offsetZ = dx, dz;
	for i= 1, listCollisions:size() do
		offsetX = listCollisions:get(i):CalculateXOffset(aabb, offsetX, 0.3);
	end
	for i= 1, listCollisions:size() do
		offsetZ = listCollisions:get(i):CalculateZOffset(aabb, offsetZ, 0.3);
	end
	if(offsetX~=dx and offsetX*dx<0) then
		dx = -dx
	end
	if(offsetZ~=dz and offsetZ*dz<0) then
		dz = -dz
	end
	local newFacing = Direction.GetFacingFromOffset(dx, 0, dz);
	self.entity:SetFacing(newFacing);
end

function Actor:IsTouchingPlayers()
	if(not self.entity) then
		return;
	end
	local distExpand = 0.25;
	local aabb = self.entity:GetCollisionAABB();
    local listEntities = EntityManager.GetEntitiesByAABBExcept(aabb:clone():Expand(distExpand, distExpand, distExpand), self.entity);
	if(listEntities) then
		for _, entityCollided in ipairs(listEntities) do
			if(entityCollided:IsPlayer()) then
				return true;
			end
		end
	end
end

function Actor:DistanceTo(actor2)
	local entity = self:GetEntity();
	if(entity) then
		local entity2 = actor2:GetEntity();
		if(entity2) then
			local x, y, z = entity2:GetPosition();
			local dist = entity:GetDistanceSq(x,y,z);
			if(dist > 0.0001) then
				return math.sqrt(dist);
			else
				return dist;
			end
		end
	end
end

function Actor:DeleteThisActor()
	self:OnRemove();
	self:Destroy();
end

function Actor:OnRemove()
	self:beforeRemoved(self);
	Actor._super.OnRemove(self);
end

function Actor:SetVisible(bVisible)
	local entity = self:GetEntity();
	if(entity) then
		entity:SetVisible(bVisible);
	end
end

function Actor:SetHighlight(bHighlight)
	local entity = self:GetEntity();
	if(entity) then
		entity:SetHighlight(bHighlight);
	end
end

-- this allows us to play animation in movie block from current movie time to be relative to current entity's position
-- @param time: if nil, it means the current time. 
function Actor:ResetOffsetPosAndRotation()
	local curTime = self:GetTime();
	local entity = self.entity;

	if(not entity or not curTime) then
		return
	end
	local eX, eY, eZ = entity:GetPosition();
	local new_x, new_y, new_z, yaw, roll, pitch = Actor._super.ComputePosAndRotation(self, curTime);
	if(not new_x) then
		new_x, new_y, new_z = eX, eY, eZ;
	end;
	local obj = entity:GetInnerObject();
	self:SetOffsetPos(eX - new_x, eY - new_y, eZ - new_z);
	self:SetOffsetYaw(obj:GetField("yaw", 0) - (yaw or 0));
end

function Actor:SetOffsetYaw(yaw)
	self.offsetYaw = yaw;
end

function Actor:GetOffsetYaw()
	return self.offsetYaw;
end

function Actor:SetOffsetPos(dx,dy,dz)
	self.offsetPos:set(dx,dy,dz);
end

function Actor:GetOffsetPos()
	return self.offsetPos:get();
end

function Actor:ComputePosAndRotation(curTime)
	local new_x, new_y, new_z, yaw, roll, pitch = Actor._super.ComputePosAndRotation(self, curTime);
	
	if(new_x) then
		local dx, dy, dz = self:GetOffsetPos();
		return new_x+dx, new_y+dy, new_z+dz, (yaw or 0)+self:GetOffsetYaw(), roll, pitch;
	end
end

-- if the same event is called multiple times, the previous one is always stopped before a new one is fired. 
function Actor:SetCodeEvent(event, co)
	local last_coroutine = self.codeEvents[event];
	if(last_coroutine) then
		last_coroutine:Stop();
	end
	self.codeEvents[event] = co;
end

-- if the same event is called multiple times, the previous one is always stopped before a new one is fired. 
function Actor:StopLastCodeEvent(event)
	local last_coroutine = self.codeEvents[event];
	if(last_coroutine) then
		last_coroutine:Stop();
		self.codeEvents[event] = nil;
	end
end