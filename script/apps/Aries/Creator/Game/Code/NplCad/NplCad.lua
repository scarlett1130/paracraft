--[[
Title: NplCad
Author(s): leio
Date: 2018/12/12
Desc: NplCad is a blockly program to create shapes with nploce on web browser
use the lib:
-------------------------------------------------------
local NplCad = NPL.load("(gl)script/apps/Aries/Creator/Game/Code/NplCad/NplCad.lua");
NplCad.MakeBlocklyFiles();
-------------------------------------------------------
]]
local CodeBlockWindow = commonlib.gettable("MyCompany.Aries.Game.Code.CodeBlockWindow");
local Files = commonlib.gettable("MyCompany.Aries.Game.Common.Files");
local CodeCompiler = commonlib.gettable("MyCompany.Aries.Game.Code.CodeCompiler");
local NplCad = NPL.export();
commonlib.setfield("MyCompany.Aries.Game.Code.NplCad.NplCad", NplCad);

local is_installed = false;
local all_cmds = {};
local all_cmds_map = {};
NplCad.categories = {
    {name = "Shapes", text = L"图形", colour = "#764bcc", },
    {name = "ShapeOperators", text = L"修改", colour = "#0078d7", },
    {name = "ObjectName", text = L"名称", colour = "#ff8c1a", custom="VARIABLE", },
    {name = "Control", text = L"控制", colour = "#d83b01", },
    {name = "Math", text = L"运算", colour = "#569138", },
    {name = "Data", text = L"数据", colour = "#459197", },
    {name = "Skeleton", text = L"骨骼", colour = "#3c3c3c", },
--    {name = "Export", text = L"导出", colour = "#235789", },
--    {name = "Animation", text = L"动画", colour = "#717171", },
    
};

-- make files for blockly 
function NplCad.MakeBlocklyFiles()
    local categories = NplCad.GetCategoryButtons();
    local all_cmds = NplCad.GetAllCmds()

    NPL.load("(gl)script/apps/Aries/Creator/Game/Code/CodeBlocklyHelper.lua");
    local CodeBlocklyHelper = commonlib.gettable("MyCompany.Aries.Game.Code.CodeBlocklyHelper");
    CodeBlocklyHelper.SaveFiles("block_configs_nplcad",categories,all_cmds);

    _guihelper.MessageBox("making blockly files finished");
	ParaGlobal.ShellExecute("open", ParaIO.GetCurDirectory(0).."block_configs_nplcad", "", "", 1); 
end
function NplCad.GetCategoryButtons()
    return NplCad.categories;
end
function NplCad.AppendAll()
	if(is_installed)then
		return
	end
	is_installed = true;

    NPL.load("(gl)script/apps/Aries/Creator/Game/Code/NplCad/NplCadDef/NplCadDef_ShapeOperators.lua");
    NPL.load("(gl)script/apps/Aries/Creator/Game/Code/NplCad/NplCadDef/NplCadDef_Shapes.lua");
    NPL.load("(gl)script/apps/Aries/Creator/Game/Code/NplCad/NplCadDef/NplCadDef_Control.lua");
    NPL.load("(gl)script/apps/Aries/Creator/Game/Code/NplCad/NplCadDef/NplCadDef_Data.lua");
    NPL.load("(gl)script/apps/Aries/Creator/Game/Code/NplCad/NplCadDef/NplCadDef_Math.lua");
    NPL.load("(gl)script/apps/Aries/Creator/Game/Code/NplCad/NplCadDef/NplCadDef_Skeleton.lua");
    NPL.load("(gl)script/apps/Aries/Creator/Game/Code/NplCad/NplCadDef/NplCadDef_Animation.lua");
    NPL.load("(gl)script/apps/Aries/Creator/Game/Code/NplCad/NplCadDef/NplCadDef_Export.lua");

    local NplCadDef_ShapeOperators = commonlib.gettable("MyCompany.Aries.Game.Code.NplCad.NplCadDef_ShapeOperators");
    local NplCadDef_Shapes = commonlib.gettable("MyCompany.Aries.Game.Code.NplCad.NplCadDef_Shapes");
    local NplCadDef_Control = commonlib.gettable("MyCompany.Aries.Game.Code.NplCad.NplCadDef_Control");
    local NplCadDef_Data = commonlib.gettable("MyCompany.Aries.Game.Code.NplCad.NplCadDef_Data");
    local NplCadDef_Math = commonlib.gettable("MyCompany.Aries.Game.Code.NplCad.NplCadDef_Math");
    local NplCadDef_Skeleton = commonlib.gettable("MyCompany.Aries.Game.Code.NplCad.NplCadDef_Skeleton");
    local NplCadDef_Animation = commonlib.gettable("MyCompany.Aries.Game.Code.NplCad.NplCadDef_Animation");
    local NplCadDef_Export = commonlib.gettable("MyCompany.Aries.Game.Code.NplCad.NplCadDef_Export");
	

	local all_source_cmds = {
		NplCadDef_ShapeOperators.GetCmds(),
		NplCadDef_Shapes.GetCmds(),
		NplCadDef_Control.GetCmds(),
		NplCadDef_Data.GetCmds(),
		NplCadDef_Math.GetCmds(),
		NplCadDef_Skeleton.GetCmds(),
--		NplCadDef_Animation.GetCmds(),
--		NplCadDef_Export.GetCmds(),
	}
	for k,v in ipairs(all_source_cmds) do
		NplCad.AppendDefinitions(v);
	end
end

function NplCad.OnSelect()
    if(CodeBlockWindow.GetSceneContext and CodeBlockWindow:GetSceneContext())then
        CodeBlockWindow:GetSceneContext():SetShowBones(true);
    end
end

function NplCad.OnDeselect()
    if(CodeBlockWindow.GetSceneContext and CodeBlockWindow:GetSceneContext())then
        CodeBlockWindow:GetSceneContext():SetShowBones(false);
    end
end

function NplCad.AppendDefinitions(source)
	if(source)then
		for k,v in ipairs(source) do
			table.insert(all_cmds,v);
			all_cmds_map[v.type] = v;
		end
	end
end

function NplCad.GetAllCmds()
	NplCad.AppendAll();
	return all_cmds;
end

-- custom compiler here: 
-- @param codeblock: code block object here
function NplCad.CompileCode(code, filename, codeblock)
    local NplOceConnection = NPL.load("Mod/NplCad2/NplOceConnection.lua");
    if(not NplOceConnection or not NplOceConnection.is_loaded)then
	    LOG.std(nil, "info", "NplCad", "load nploce failed");
        return
    end

    local block_name = codeblock:GetBlockName();
    if(not block_name or block_name == "")then
        block_name = "default"
    end
	local worldpath = ParaWorld.GetWorldDirectory();
	local relativePath = format("blocktemplates/nplcad/%s.x",commonlib.Encoding.Utf8ToDefault(block_name));
    local filepath = worldpath..relativePath;
	code = NplCad.GetCode(code, filepath);

	NplCad.SetCodeBlockActorAsset(codeblock, relativePath);

	return CodeCompiler:new():SetFilename(filename):Compile(code);
end

-- set code block's nearby movie block's first actor's model to filepath if it is not. 
function NplCad.SetCodeBlockActorAsset(codeBlock, filepath)
	if(CodeBlockWindow.GetCodeBlock() == codeBlock and CodeBlockWindow.IsVisible()) then
		local actor;
		local movieEntity = codeBlock:GetMovieEntity();
		if(movieEntity and not movieEntity:GetFirstActorStack()) then
			movieEntity:CreateNPC();
			CodeBlockWindow:GetSceneContext():UpdateCodeBlock();
		end

		local sceneContext = CodeBlockWindow:GetSceneContext();
		if(sceneContext) then
			actor = sceneContext:GetActor()
		end
		actor = actor or codeBlock:GetActor();
		if(actor) then
			local assetfile = actor:GetValue("assetfile", 0);
			if(assetfile ~= filepath) then
				actor:AddKeyFrameByName("assetfile", 0, filepath);
				actor:FrameMovePlaying(0);
			end
		end
	end
end

-- create short cut in code API, so that we can write cube() instead of ShapeBuilder.cube()
function NplCad.InstallMethods(codeAPI, shape)
	
	for func_name, func in pairs(shape) do
		if(type(func_name) == "string" and type(func) == "function") then
			codeAPI[func_name] = function(...)
				return func(...);
			end
		end
	end
end

function NplCad.RefreshFile(filename)
	if(filename and ParaIO.DoesFileExist(filename)) then
		local function filterFunc(shouldRefresh, fullname)
			if(shouldRefresh and filename:match("[^\\/]+$")==fullname:match("[^\\/]+$")) then
				LOG.std(nil, "debug", "NplCAD", "skip refresh disk file %s", fullname);
				return false
			else
				return shouldRefresh;
			end
		end
		GameLogic.GetFilters():add_filter("shouldRefreshWorldFile", filterFunc);
		ParaAsset.LoadParaX("", filename):UnloadAsset()
		commonlib.TimerManager.SetTimeout(function()  
			GameLogic.GetFilters():remove_filter("shouldRefreshWorldFile", filterFunc);	
		end, 5000)
	end
end


function NplCad.GetCode(code, filename)
    return string.format([[
local SceneHelper = NPL.load("Mod/NplCad2/SceneHelper.lua");
local ShapeBuilder = NPL.load("Mod/NplCad2/Blocks/ShapeBuilder.lua");
ShapeBuilder.create();
local NplCad = NPL.load("(gl)script/apps/Aries/Creator/Game/Code/NplCad/NplCad.lua");
NplCad.InstallMethods(codeblock:GetCodeEnv(), ShapeBuilder)
%s
local result = SceneHelper.saveSceneToParaX(%q,ShapeBuilder.getScene());
NplCad.ExportToFile(ShapeBuilder.getScene(),%q);
if(result)then
	setActorValue("assetfile", %q)
	setActorValue("showBones", true)
    NplCad.RefreshFile(%q)
end
]], code, filename, filename, filename, filename, filename)
end

-- custom toolbar UI's mcml on top of the code block window. return nil for default UI. 
-- return nil or a mcml string. 
function NplCad.GetCustomToolbarMCML()

	NplCad.toolBarMcmlText = NplCad.toolBarMcmlText or string.format([[
    <div style="float:left;margin-left:0px;margin-top:7px;"
            tooltip='page://script/apps/Aries/Creator/Game/Code/NplCad/NplCadToolMenus.html' use_mouse_offset="false" is_lock_position="true" tooltip_offset_x="-5" tooltip_offset_y="22" show_duration="10" enable_tooltip_hover="true" tooltip_is_interactive="true" show_height="200" show_width="230">
        <div style="background-color:#808080;color:#ffffff;padding:3px;font-size:12px;height:25px;min-width:20px;">%s</div>
    </div>
]],
		L"导出");
	return NplCad.toolBarMcmlText;
end

function NplCad.OnClickExport(type)
	local codeBlock = CodeBlockWindow.GetCodeBlock();
	if(codeBlock) then
		codeBlock:SetModified();
		NplCad.export_type = type;
		codeBlock:GetEntity():Restart();
		NplCad.export_type = nil;
	end
end
function NplCad.ExportToFile(scene,filename)
    local type = NplCad.export_type;
    if(not type or not scene or not filename)then
        return
    end
    local SceneHelper = NPL.load("Mod/NplCad2/SceneHelper.lua");

    filename = string.match(filename, [[(.+).(.+)$]]);
    if(type == "stl")then
        filename = filename .. ".stl";
        SceneHelper.saveSceneToStl(filename,scene,false,true);
    elseif(type == "gltf")then
        filename = filename .. ".gltf";
        SceneHelper.saveSceneToGltf(filename,scene);
    end
    _guihelper.MessageBox(string.format(L"成功导出:%s, 是否打开所在目录", commonlib.Encoding.DefaultToUtf8(filename)), function(res)
		if(res and res == _guihelper.DialogResult.Yes) then
			local info = Files.ResolveFilePath(filename)
			if(info and info.relativeToRootPath) then
				local absPath = ParaIO.GetCurDirectory(0)..info.relativeToRootPath;
				local absPathFolder = absPath:gsub("[^/\\]+$", "")
				ParaGlobal.ShellExecute("open", absPathFolder, "", "", 1);
			end
		end
	end, _guihelper.MessageBoxButtons.YesNo);

end

