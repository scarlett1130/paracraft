--[[
Title: CodeAPI
Author(s): LiXizhi
Date: 2018/6/8
Desc: sandbox API environment
use the lib:
-------------------------------------------------------
NPL.load("(gl)script/apps/Aries/Creator/Game/Code/CodeAPI_Sound.lua");
-------------------------------------------------------
]]
NPL.load("(gl)script/apps/Aries/Creator/Game/Sound/SoundManager.lua");
local SoundManager = commonlib.gettable("MyCompany.Aries.Game.Sound.SoundManager");
local GameLogic = commonlib.gettable("MyCompany.Aries.Game.GameLogic");
local env_imp = commonlib.gettable("MyCompany.Aries.Game.Code.env_imp");

-- same as /midi [note]
-- @param beat: 
function env_imp:playNote(note, beat, base_note, channel)
	local command = "";

	if (not base_note) then
		command = "/midi ";
	else
		if (channel) then
			command = "/midi -base_note " .. tostring(base_note) .. " -channel " .. channel .. " ";
		else
			command = "/midi -base_note " .. tostring(base_note) .. " ";
		end
	end

	beat = math.max((beat or 1) * 1, env_imp.GetDefaultTick(self));

	if (beat) then
		command = command .. "-beat " .. beat .. " ";
	end

	command = command .. tostring(note);

	GameLogic.RunCommand(command);

	env_imp.wait(self, beat);
end

-- play a sound 
-- @param channel_name: channelname or filename, where filename can be relative to current world or a predefined name
function env_imp:playSound(channel_name, filename, from_time, volume, pitch)
	filename = filename or channel_name;
	SoundManager:PlaySound(channel_name, filename, from_time or 0, volume, pitch);	
	env_imp.checkyield(self);
end

-- play a sound 
-- @param channel_name: channelname or filename, where filename can be relative to current world or a predefined name
function env_imp:playSoundAndWait(channel_name, filename, from_time, volume, pitch)
	filename = filename or channel_name;
	SoundManager:PlaySound(channel_name, filename, from_time or 0, volume, pitch);	
	local sound = AudioEngine.CreateGet(channel_name);
	if(sound) then
		local src = sound:GetSource()
		if(src) then
			local total_time = tonumber(src.TotalAudioTime);
			env_imp.wait(self, total_time);
		end
	end
end

-- same as /sound [filename]
function env_imp:stopSound(filename)
	SoundManager:StopSound(filename)
	env_imp.checkyield(self);
end

-- same as /music [filename]
function env_imp:playMusic(filename,volume)
	local commandStr = "/music "..(filename or "")
	if volume then
		commandStr = "/music "..(filename or "").. " -volume " ..volume
	end
	GameLogic.RunCommand(commandStr);
	env_imp.checkyield(self);
end

-- play a text 
-- @param text: the text to play
-- @param voiceNarrator: the narrator of the voice
function env_imp:playText(text, duration, voiceNarrator)
	if text == nil or text == "" then
		SoundManager:StopPlayText()
	else
		SoundManager:PlayText(text, voiceNarrator);	
	end
	
	if duration then
		env_imp.wait(self, duration);
	end
end