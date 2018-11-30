--[[
Title: CodeBlocklyDef_Data
Author(s): leio
Date: 2018/7/5
Desc: define blocks in category of Data
use the lib:
-------------------------------------------------------
NPL.load("(gl)script/apps/Aries/Creator/Game/Code/CodeBlocklyDef/CodeBlocklyDef_Data.lua");
local CodeBlocklyDef_Data= commonlib.gettable("MyCompany.Aries.Game.Code.CodeBlocklyDef.CodeBlocklyDef_Data");
-------------------------------------------------------
]]
local CodeBlocklyDef_Data = commonlib.gettable("MyCompany.Aries.Game.Code.CodeBlocklyDef.CodeBlocklyDef_Data");
local cmds = {
-- Data
{
	type = "getLocalVariable", 
	message0 = L"获取变量%1",
	arg0 = {
		{
			name = "var",
			type = "field_variable",
			variable = "score",
			variableTypes = {""},
			text = "score",
		},
	},
	output = {type = "null",},
	category = "Data", 
	helpUrl = "", 
	canRun = false,
	func_description = '%s',
	ToNPL = function(self)
		return self:getFieldAsString('var');
	end,
	examples = {{desc = "", canRun = true, code = [[
local key = "value"
say(key, 1)
]]}},
},

{
	type = "createLocalVariable", 
	message0 = L"新建本地变量%1为%2",
	arg0 = {
		{
			name = "var",
			type = "field_variable",
			variable = "score",
			variableTypes = {""},
			text = "score",
		},
		{
			name = "value",
			type = "input_value",
			shadow = { type = "text", value = "value",},
			text = "value",
		},
	},
	category = "Data", 
	helpUrl = "", 
	canRun = false,
	previousStatement = true,
	nextStatement = true,
	func_description = 'local %s = %s',
	ToNPL = function(self)
		return 'local key = "value"\n';
	end,
	examples = {{desc = "", canRun = true, code = [[
local key = "value"
say(key, 1)
]]}},
},

{
	type = "assign", 
	message0 = L"%1赋值为%2",
	arg0 = {
		{
			name = "left",
			type = "input_value",
			shadow = { type = "text", value = "score",},
			text = "score",
		},
		{
			name = "right",
			type = "input_value",
			shadow = { type = "text", value = "1",},
			text = "1",
		},
	},
	category = "Data", 
	helpUrl = "", 
	canRun = false,
	previousStatement = true,
	nextStatement = true,
	func_description = '%s = %s',
	ToNPL = function(self)
		return 'key = "value"\n';
	end,
	examples = {{desc = "", canRun = true, code = [[
text = "hello"
say(text, 1)
]]}},
},
{
	type = "set", 
	message0 = L"设置全局变量%1为%2",
	arg0 = {
		{
			name = "key",
			type = "field_input",
			text = "score", 
		},
		{
			name = "value",
			type = "input_value",
            shadow = { type = "text", value = "1",},
			text = "1", 
		},
	},
	category = "Data", 
	helpUrl = "", 
	canRun = true,
	previousStatement = true,
	nextStatement = true,
	func_description = 'set("%s", %s)',
	ToNPL = function(self)
		return string.format('set("%s", "%s")\n', self:getFieldAsString('key'), self:getFieldAsString('value'));
	end,
	examples = {{desc = L"也可以用_G.a", canRun = true, code = [[
_G.a = _G.a or 1
while(true) do
    _G.a = a + 1
    set("a", get("a") + 1)
    say(a)
end
]]}},
},

{
	type = "registerCloneEvent", 
	message0 = L"当角色被复制时(%1)",
	message1 = L"%1",
	arg0 = {
		{
			name = "param",
			type = "field_input",
			shadow = { type = "text", value = "name",},
			text = "name", 
		},
	},
	arg1 = {
		{
			name = "input",
			type = "input_statement",
			text = "",
		},
		
	},
	category = "Data", color="#cc0000",
	helpUrl = "", 
	canRun = false,
	previousStatement = true,
	nextStatement = true,
	func_description = 'registerCloneEvent(function(%s)\\n%send)',
	ToNPL = function(self)
		return string.format('registerCloneEvent(function(%s)\n    %s\nend)\n', self:getFieldAsString('param'), self:getFieldAsString('input'));
	end,
	examples = {{desc = "", canRun = true, code = [[
registerCloneEvent(function(msg)
    move(msg or 1, 0, 0, 0.5)
    wait(1)
    delete()
end)
clone()
clone("myself", 2)
clone("myself", 3)
]]}},
},

{
	type = "actorNames", 
	message0 = "%1",
	arg0 = {
		{
			name = "value",
			type = "field_dropdown",
			options = {
				{ L"此角色", "myself" },
				{ L"某个角色", "" },
			},
		},
	},
	hide_in_toolbox = true,
	category = "Data", 
	output = {type = "null",},
	helpUrl = "", 
	canRun = false,
	func_description = '%s',
	ToNPL = function(self)
		return self:getFieldAsString('value');
	end,
	examples = {{desc = "", canRun = true, code = [[
]]}},
},

{
	type = "clone", 
	message0 = L"复制%1(%2)",
	arg0 = {
		{
			name = "input",
			type = "input_value",
			shadow = { type = "actorNames", value = "myself",},
			text = "myself",
		},
		{
			name = "params",
			type = "input_value",
			shadow = { type = "text", value = "",},
			text = "", 
		},
	},
	category = "Data", color="#cc0000",
	helpUrl = "", 
	canRun = false,
	previousStatement = true,
	nextStatement = true,
	func_description = 'clone(%s, %s)',
	ToNPL = function(self)
		return string.format('clone("%s")\n', self:getFieldAsString('input'));
	end,
	examples = {{desc = "", canRun = true, code = [[
registerClickEvent(function()
    move(1,0,0, 0.5)
end)
clone()
clone()
say("click")
]]}},
},


{
	type = "delete", 
	message0 = L"删除角色", color="#cc0000",
	arg0 = {
	},
	category = "Data", 
	helpUrl = "", 
	canRun = false,
	previousStatement = true,
	nextStatement = true,
	func_description = "delete()",
	ToNPL = function(self)
		return string.format('delete()\n');
	end,
	examples = {{desc = "", canRun = true, code = [[
move(1,0)
say("Default actor will be deleted!", 1)
delete()
registerCloneEvent(function()
    say("This clone will be deleted!", 1)
    delete()
end)
for i=1, 100 do
    clone()
    wait(2)
end
]]}},
},

{
	type = "actorProperties", 
	message0 = "%1",
	arg0 = {
		{
			name = "value",
			type = "field_dropdown",
			options = {
				{ L"名字", "name" },
				{ L"物理半径", "physicsRadius" },
				{ L"物理高度", "physicsHeight" },
				{ L"组Id", "groupId" },
				{ "x", "x" },
				{ "y", "y" },
				{ "z", "z" },
				{ L"朝向", "facing" },
				{ L"颜色", "color" },
				{ L"文字", "text" },
				{ L"是否为化身", "isAgent" },
				{ L"模型文件", "assetfile" },
				{ L"绘图代码", "rendercode" },
			},
		},
	},
	hide_in_toolbox = true,
	category = "Data", 
	output = {type = "null",},
	helpUrl = "", 
	canRun = false,
	func_description = '"%s"',
	ToNPL = function(self)
		return self:getFieldAsString('value');
	end,
	examples = {{desc = "", canRun = true, code = [[
]]}},
},


{
	type = "setActorValue", 
	message0 = L"设置角色的%1为%2",
	arg0 = {
		{
			name = "key",
			type = "input_value",
			shadow = { type = "actorProperties", value = "name",},
			text = "name", 
		},
		{
			name = "value",
			type = "input_value",
            shadow = { type = "text", value = "actor1",},
			text = "actor1", 
		},
	},
	category = "Data", 
	color = "#cc0000",
	helpUrl = "", 
	canRun = false,
	previousStatement = true,
	nextStatement = true,
	func_description = 'setActorValue(%s, %s)',
	ToNPL = function(self)
		return string.format('setActorValue("%s", "%s")\n', self:getFieldAsString('key'), self:getFieldAsString('value'));
	end,
	examples = {{desc = "", canRun = true, code = [[
registerCloneEvent(function(name)
    setActorValue("name", name)
    moveForward(1);
end)
registerClickEvent(function()
    local myname = getActorValue("name")
    say("my name is "..myname)
end)
setActorValue("name", "Default")
setActorValue("color", "#ff0000")
clone("myself", "Cloned")
say("click us!")
]]}},
},

{
	type = "getActorValue", 
	message0 = L"获取角色的%1",
	arg0 = {
		{
			name = "key",
			type = "input_value",
			shadow = { type = "actorProperties", value = "name",},
			text = "name", 
		},
	},
	category = "Data", 
	output = {type = "field_variable",},
	helpUrl = "", 
	canRun = false,
	func_description = 'getActorValue(%s)',
	ToNPL = function(self)
		return string.format('getActorValue("%s")', self:getFieldAsString('key'));
	end,
	examples = {{desc = "", canRun = true, code = [[
registerCloneEvent(function(msg)
    setActorValue("name", msg.name)
    moveForward(msg.dist);
end)
registerClickEvent(function()
    local myname = getActorValue("name")
    say("my name is "..myname)
end)
setActorValue("name", "Default")
clone("myself", {name = "clone1", dist=1})
clone(nil, {name = "clone2", dist=2})
say("click us!")
]]}},
},


{
	type = "getActor", 
	message0 = L"获取角色对象%1", 
	arg0 = {
		{
			name = "actorName",
			type = "input_value",
            shadow = { type = "text", value = "myself",},
			text = "myself", 
		},
	},
	output = {type = "field_variable",},
	category = "Data", 
	helpUrl = "", 
	canRun = false,
	func_description = 'getActor(%s)',
	ToNPL = function(self)
		return string.format('getActor("%s")\n', self:getFieldAsString('actorName'));
	end,
	examples = {
	{desc = L"", canRun = true, code = [[
local actor = getActor("myself")
runForActor(actor, function()
	say("hello", 1)
end)
]]},
	{desc = L"", canRun = true, code = [[
local actor = getActor("name1")
local data = actor:GetActorValue("some_data")
]]},
},
},

{
	type = "getString", 
	message0 = "\"%1\"",
	arg0 = {
		{
			name = "left",
			type = "field_input",
			text = "string",
		},
	},
	output = {type = "null",},
	category = "Data", 
	helpUrl = "", 
	canRun = false,
	func_description = '"%s"',
	ToNPL = function(self)
		return string.format('"%s"', self:getFieldAsString('left'));
	end,
	examples = {{desc = "", canRun = true, code = [[
]]}},
},
{
	type = "getBoolean", 
	message0 = L"%1",
	arg0 = {
		{
			name = "value",
			type = "field_dropdown",
			options = {
				{ "true", "true" },
				{ "false", "false" },
				{ "nil", "nil" },
			  }
		},
	},
	output = {type = "field_number",},
	category = "Data", 
	helpUrl = "", 
	canRun = false,
	func_description = '%s',
	ToNPL = function(self)
		return self:getFieldAsString("value");
	end,
	examples = {{desc = "", canRun = true, code = [[
]]}},
},
{
	type = "getNumber", 
	message0 = L"%1",
	arg0 = {
		{
			name = "left",
			type = "field_number",
			text = "0",
		},
	},
	output = {type = "field_number",},
	category = "Data", 
	helpUrl = "", 
	canRun = false,
	func_description = '%s',
	ToNPL = function(self)
		return string.format('%s', self:getFieldAsString('left'));
	end,
	examples = {{desc = "", canRun = true, code = [[
]]}},
},

{
	type = "getTableValue", 
	message0 = L"获取表%1中的%2",
	arg0 = {
		{
			name = "table",
			type = "field_variable",
			variable = "_G",
			text = "_G",
		},
		{
			name = "key",
			type = "input_value",
			variable = "_G",
			shadow = { type = "text", value = "key",},
			text = "key", 
		},
	},
	output = {type = "field_number",},
	category = "Data", 
	helpUrl = "", 
	canRun = false,
	func_description = '%s[%s]',
	ToNPL = function(self)
		return string.format('%s["%s"]', self:getFieldAsString('table'), self:getFieldAsString('key'));
	end,
	examples = {{desc = "", canRun = true, code = [[
local t = {}
t[1] = "hello"
t["age"] = 10;
log(t)
]]}},
},

{
	type = "newEmptyTable", 
	message0 = L"空的表{}",
	output = {type = "field_number",},
	category = "Data", 
	helpUrl = "", 
	canRun = false,
	func_description = '{}',
	ToNPL = function(self)
		return "{}";
	end,
	examples = {{desc = "", canRun = true, code = [[
local t = {}
t[1] = "hello"
t["age"] = 10;
log(t)
]]}},
},

{
	type = "newFunction", 
	message0 = L"新函数(%1)",
	message1 = L"%1",
	arg0 = {
		{
			name = "param",
			type = "field_input",
			text = "param", 
		},
	},
    arg1 = {
        {
			name = "input",
			type = "input_statement",
			text = "", 
		},
    },
	output = {type = "field_number",},
	category = "Data", 
	helpUrl = "", 
	canRun = false,
	func_description = 'function(%s)\\n%send',
	ToNPL = function(self)
		return string.format('function(%s)\n    %s\nend\n', self:getFieldAsString('param'), self:getFieldAsString('input'));
	end,
	examples = {{desc = "", canRun = true, code = [[
local thinkText = function(text)
	say(text.."...")
end
thinkText("Let me think");
]]}},
},

{
	type = "callFunction", 
	message0 = L"调用函数%1(%2)",
	arg0 = {
		{
			name = "name",
			type = "field_variable",
			variable = "log",
		},
		{
			name = "param",
			type = "input_value",
			shadow = { type = "text", value = "param",},
			text = "param",
		},
	},
	previousStatement = true,
	nextStatement = true,
	category = "Data", 
	helpUrl = "", 
	canRun = false,
	func_description = '%s(%s)',
	ToNPL = function(self)
		return string.format('%s("%s")\n', self:getFieldAsString('name'), self:getFieldAsString('param'));
	end,
	examples = {{desc = "", canRun = true, code = [[
local thinkText = function(text)
	say(text.."...")
end
thinkText("Let me think");
]]}},
},


{
	type = "showVariable", 
	message0 = L"显示全局变量%1",
	arg0 = {
		{
			name = "name",
			type = "field_input",
			text = "score", 
		},
	},
	category = "Data", 
	helpUrl = "", 
	canRun = true,
	previousStatement = true,
	nextStatement = true,
	func_description = 'showVariable("%s")',
	ToNPL = function(self)
		return string.format('showVariable("%s")\n', self:getFieldAsString('name'));
	end,
	examples = {{desc = "", canRun = true, code = [[
_G.score = 1
_G.msg = "hello"
showVariable("score", "Your Score")
showVariable("msg", "", "#ff0000")
while(true) do
   _G.score = _G.score + 1
   wait(0.01)
end
]]}},
},

{
	type = "hideVariable", 
	message0 = L"隐藏全局变量%1",
	arg0 = {
		{
			name = "name",
			type = "field_input",
			text = "score", 
		},
	},
	category = "Data", 
	helpUrl = "", 
	canRun = true,
	previousStatement = true,
	nextStatement = true,
	func_description = 'hideVariable("%s")',
	ToNPL = function(self)
		return string.format('hideVariable("%s")\n', self:getFieldAsString('name'));
	end,
	examples = {{desc = "", canRun = true, code = [[
_G.score = 1
showVariable("score")
wait(1);
hideVariable("score")
]]}},
},


{
	type = "log", 
	message0 = L"输出日志%1",
	arg0 = {
		{
			name = "obj",
			type = "input_value",
            shadow = { type = "text", value = "hello",},
			text = "hello", 
		},
	},
	category = "Data", 
	helpUrl = "", 
	canRun = true,
	previousStatement = true,
	nextStatement = true,
	func_description = 'log(%s)',
	ToNPL = function(self)
		return string.format('log("%s")\n', self:getFieldAsString('obj'));
	end,
	examples = {{desc = L"查看log.txt或F11看日志", canRun = true, code = [[
log(123)
log("hello")
something = {any="object"}
log(something)
]]}},
},

{
	type = "echo", 
	message0 = L"输出到聊天框%1",
	arg0 = {
		{
			name = "obj",
			type = "input_value",
            shadow = { type = "text", value = "hello",},
			text = "hello", 
		},
	},
	category = "Data", 
	helpUrl = "", 
	canRun = true,
	previousStatement = true,
	nextStatement = true,
	func_description = 'echo(%s)',
	ToNPL = function(self)
		return string.format('echo("%s")\n', self:getFieldAsString('obj'));
	end,
	examples = {{desc = "", canRun = true, code = [[
echo(123)
echo("hello")
something = {any="object"}
echo(something)
]]}},
},

{
	type = "include", 
	message0 = L"引用文件%1", color="#cc0000",
	arg0 = {
		{
			name = "filename",
			type = "input_value",
            shadow = { type = "text", value = "hello.npl",},
			text = "hello.npl", 
		},
	},
	category = "Data", 
	helpUrl = "", 
	canRun = false,
	previousStatement = true,
	nextStatement = true,
	func_description = 'include(%s)',
	ToNPL = function(self)
		return string.format('include("%s")\n', self:getFieldAsString('filename'));
	end,
	examples = {{desc = L"文件需要放到当前世界目录下", canRun = true, code = [[
-- _G.hello = function say("hello") end
include("hello.npl")
hello()
]]}},
},

{
	type = "code_block", 
	message0 = L"代码%1",
	message1 = L"%1",
    arg0 = {
		{
			name = "label_dummy",
			type = "input_dummy",
			text = "",
		},
	},
	arg1 = {
		{
			name = "codes",
			type = "field_input",
			text = "",
		},
	},
	category = "Data", 
	helpUrl = "", 
	canRun = false,
	previousStatement = true,
	nextStatement = true,
	func_description = '%s',
	ToNPL = function(self)
		return string.format('%s\n', self:getFieldAsString('codes'));
	end,
	examples = {{desc = L"", canRun = true, code = [[
]]}},
},

};
function CodeBlocklyDef_Data.GetCmds()
	return cmds;
end
