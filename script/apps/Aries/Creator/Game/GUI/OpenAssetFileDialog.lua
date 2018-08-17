--[[
Title: Open Asset File Dialog
Author(s): LiXizhi
Date: 2018/8/13
Desc: Open Asset File Dialog
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/Creator/Game/GUI/OpenAssetFileDialog.lua");
local OpenAssetFileDialog = commonlib.gettable("MyCompany.Aries.Game.GUI.OpenAssetFileDialog");
OpenAssetFileDialog.ShowPage("Please enter text", function(result)
	
end, default_text, title, filters)
-------------------------------------------------------
]]
NPL.load("(gl)script/apps/Aries/Creator/Game/Common/Files.lua");
NPL.load("(gl)script/apps/Aries/Creator/Game/GUI/OpenAssetFileDialog.lua");
NPL.load("(gl)script/apps/Aries/Creator/Game/Entity/PlayerSkins.lua");
local PlayerSkins = commonlib.gettable("MyCompany.Aries.Game.EntityManager.PlayerSkins")
local PlayerAssetFile = commonlib.gettable("MyCompany.Aries.Game.EntityManager.PlayerAssetFile")
local Files = commonlib.gettable("MyCompany.Aries.Game.Common.Files");
local EntityManager = commonlib.gettable("MyCompany.Aries.Game.EntityManager");
local GameLogic = commonlib.gettable("MyCompany.Aries.Game.GameLogic");

local OpenAssetFileDialog = commonlib.gettable("MyCompany.Aries.Game.GUI.OpenAssetFileDialog");
-- whether in save mode. 
OpenAssetFileDialog.IsSaveMode = false;

OpenAssetFileDialog.category_index = 1;

OpenAssetFileDialog.categories = {
	{name = "all", text = L"全部", colour="#ffffff", },
	{name = "local", text = L"本地", colour="#0078d7", },
	{name = "common", text = L"常用" , colour="#7abb55", },
	{name = "people", text = L"人物", colour="#764bcc", },
	{name = "animals", text = L"动物", colour="#d83b01", },
	{name = "fantasy", text = L"科幻", colour="#8f6d40", },
	{name = "vehicles", text = L"交通", colour="#69b090", },
	{name = "props", text = L"物品", colour="#69b090", },
	{name = "effects", text = L"特效", colour="#69b090", },
};

OpenAssetFileDialog.IndexLocal = 1;
OpenAssetFileDialog.IndexCommon = 2;
OpenAssetFileDialog.IndexPeople = 3;
OpenAssetFileDialog.IndexAnimals = 4;
OpenAssetFileDialog.IndexFantasy = 5;
OpenAssetFileDialog.IndexVehicles = 6;
OpenAssetFileDialog.IndexEffects = 7;


local page;
function OpenAssetFileDialog.OnInit()
	page = document:GetPageCtrl();
end

-- @param filterName: "model", "bmax", "audio", "texture", "xml", "script"
function OpenAssetFileDialog.GetFilters(filterName)
	if(filterName == "model") then
		return {
			{L"全部文件(*.fbx,*.x,*.bmax,*.xml)",  "*.fbx;*.x;*.bmax;*.xml"},
			{L"FBX模型(*.fbx)",  "*.fbx"},
			{L"bmax模型(*.bmax)",  "*.bmax"},
			{L"ParaX模型(*.x,*.xml)",  "*.x;*.xml"},
			{L"block模版(*.blocks.xml)",  "*.blocks.xml"},
		};
	elseif(filterName == "bmax") then
		return {
			{L"bmax模型(*.bmax)",  "*.bmax"},
		};
	elseif(filterName == "script" or filterName == "lua") then
		return {
			{L"(*.lua)",  "*.lua"},
		};
	elseif(filterName == "audio") then
		return {
			{L"全部文件(*.mp3,*.ogg,*.wav)",  "*.mp3;*.ogg;*.wav"},
			{L"mp3(*.mp3)",  "*.mp3"},
			{L"ogg(*.ogg)",  "*.ogg"},
			{L"wav(*.wav)",  "*.wav"},
		};
	elseif(filterName == "texture") then
		return {
			{L"全部文件(*.png,*.jpg)",  "*.png;*.jpg"},
			{L"png(*.png)",  "*.png"},
			{L"jpg(*.jpg)",  "*.jpg"},
		};
	elseif(filterName == "xml") then
		return {
			{L"全部文件(*.xml)",  "*.xml"},
		};
	end
end

function OpenAssetFileDialog.GetCategoryButtons()
	return OpenAssetFileDialog.categories;
end

OpenAssetFileDialog.anims_ds = {
--	{name="anim", attr={text=L"待机", id=0, selected=true}},
--	{name="anim", attr={text=L"走路", id=4,}},
--	{name="anim", attr={text=L"跑步", id=5,}},
}

function OpenAssetFileDialog.GetModelAnimDs()
	return OpenAssetFileDialog.anims_ds;
end

-- @param OnClose: function(filename)
-- @param default_text: default text to be displayed. 
-- @param filters: "model", "bmax", "audio", "texture", "xml", nil for any file, or filters table
-- @param editButton: this can be nil or a function(filename) end or {text="edit", callback=function(filename) end}
-- the callback function can return a new filename to be displayed. 
function OpenAssetFileDialog.ShowPage(text, OnClose, default_text, title, filters, IsSaveMode, editButton)
	OpenAssetFileDialog.category_index = 1;
	OpenAssetFileDialog.result = nil;
	OpenAssetFileDialog.text = text;
	OpenAssetFileDialog.title = title;
	OpenAssetFileDialog.modelFilename = nil;
	if(type(filters) == "string") then
		filters = OpenAssetFileDialog.GetFilters(filters)
	end
	OpenAssetFileDialog.filters = filters;
	OpenAssetFileDialog.editButton = editButton;
	OpenAssetFileDialog.IsSaveMode = IsSaveMode == true;
	OpenAssetFileDialog.UpdateExistingFiles();

	local params = {
			url = "script/apps/Aries/Creator/Game/GUI/OpenAssetFileDialog.html", 
			name = "OpenAssetFileDialog.ShowPage", 
			isShowTitleBar = false,
			DestroyOnClose = true,
			bToggleShowHide=false, 
			style = CommonCtrl.WindowFrame.ContainerStyle,
			allowDrag = true,
			click_through = false, 
			enable_esc_key = true,
			bShow = true,
			isTopLevel = true,
			---app_key = MyCompany.Aries.Creator.Game.Desktop.App.app_key, 
			directPosition = true,
				align = "_ct",
				x = -680/2,
				y = -450/2,
				width = 680,
				height = 470,
		};
	System.App.Commands.Call("File.MCMLWindowFrame", params);

	if(default_text) then
		OpenAssetFileDialog.SetText(default_text);
	end
	params._page.OnClose = function()
		if(OnClose) then
			OnClose(OpenAssetFileDialog.result);
		end
	end
	
	params._page.OnDropFiles = function(filelist)
		if filelist then
			local _, firstFile = next(filelist);
			
			if(firstFile and page) then
				local fileItem = Files.ResolveFilePath(firstFile);
				if(fileItem and fileItem.relativeToWorldPath) then
					local filename = fileItem.relativeToWorldPath;
					OpenAssetFileDialog.SetText(filename);
				end
			end
			
			return true;
		else
			return false;
		end
	end
end

-- get model parameters. 
function OpenAssetFileDialog.GetModelParams()
	
end

function OpenAssetFileDialog.OnOK()
	if(page) then
		local text = page:GetValue("text")
		local filepath = PlayerAssetFile:GetValidAssetByString(text);
		if(filepath) then
			local fileItem = Files.ResolveFilePath(filepath);
			if(fileItem and fileItem.relativeToWorldPath) then
				filepath = fileItem.relativeToWorldPath;
			end
		end
		OpenAssetFileDialog.result = filepath;
		page:CloseWindow();
	end
end

OpenAssetFileDialog.dsExistingFiles = {};
function OpenAssetFileDialog.GetExistingFiles()
	return OpenAssetFileDialog.dsExistingFiles;
end

function OpenAssetFileDialog.UpdateExistingFiles()
	NPL.load("(gl)script/ide/Files.lua");
	local rootPath = ParaWorld.GetWorldDirectory();

	local filter, filterFunc;
	if(OpenAssetFileDialog.filters) then
		filter = OpenAssetFileDialog.filters[OpenAssetFileDialog.curFilterIndex or 1];
		if(filter) then
			filter = filter[2];
			if(filter) then
				-- "*.fbx;*.x;*.bmax;*.xml"
				local exts = {};
				for ext in filter:gmatch("%*%.([^;]+)") do
					exts[#exts + 1] = "%."..ext.."$";
				end
				
				-- skip these system files and all files under blockWorld.lastsave/
				local skippedFiles = {
					["LocalNPC.xml"] = true,
					["entity.xml"] = true,
					["players/0.entity.xml"] = true,
					["revision.xml"] = true,
					["tag.xml"] = true,
				}

				filterFunc = function(item)
					if(not skippedFiles[item.filename] and not item.filename:match("^blockWorld%.lastsave")) then
						for i=1, #exts do
							if(item.filename:match(exts[i])) then
								return true;
							end
						end
					end
				end
			end
		end
	end
	local files = OpenAssetFileDialog.dsExistingFiles;
	table.resize(OpenAssetFileDialog.dsExistingFiles, 0);
	local result = commonlib.Files.Find({}, rootPath, 2, 500, filterFunc);
	for i = 1, #result do
		files[#files+1] = {name="file", attr=result[i]};
	end
end

function OpenAssetFileDialog.OnOpenAssetFileDialog()
	NPL.load("(gl)script/ide/OpenFileDialog.lua");

	local filename = CommonCtrl.OpenFileDialog.ShowDialog_Win32(OpenAssetFileDialog.filters, 
		OpenAssetFileDialog.title,
		GameLogic.GetWorldDirectory() or "", 
		OpenAssetFileDialog.IsSaveMode);
		
	if(filename and page) then
		local fileItem = Files.ResolveFilePath(filename);
		if(fileItem and fileItem.relativeToWorldPath) then
			local filename = fileItem.relativeToWorldPath;
			OpenAssetFileDialog.SetText(filename);
		end
	end
end

function OpenAssetFileDialog.GetText()
	return OpenAssetFileDialog.text or L"请输入:";
end

function OpenAssetFileDialog.OnClickEdit()
	local filename = page:GetValue("text");
	local callback;
	if(type(OpenAssetFileDialog.editButton) == "function") then
		callback = OpenAssetFileDialog.editButton;
	elseif(type(OpenAssetFileDialog.editButton) == "table") then
		callback = OpenAssetFileDialog.editButton.callback;
	end
	if(callback) then
		local new_filename = callback(filename);
		if(new_filename and new_filename~=filename) then
			OpenAssetFileDialog.SetText(new_filename);
		end
	end
end

function OpenAssetFileDialog.SetModelFilename(filename)
	if(OpenAssetFileDialog.modelFilename ~= filename) then
		OpenAssetFileDialog.modelFilename = filename;
		if(filename) then
			OpenAssetFileDialog.UpdateModel();
		end
	end
end

function OpenAssetFileDialog.GetModelFilename()
	return OpenAssetFileDialog.modelFilename;
end

function OpenAssetFileDialog.UpdateModel()
	local filepath = PlayerAssetFile:GetValidAssetByString(OpenAssetFileDialog.modelFilename);
	if(filepath) then
		local ctl = page:FindControl("AssetPreview");
		if(ctl) then
			local ReplaceableTextures;
			if(PlayerSkins:CheckModelHasSkin(filepath)) then
				-- TODO:  hard code worker skin here
				ReplaceableTextures = {[2] = PlayerSkins:GetSkinByID(12)};
			end
			ctl:ShowModel({AssetFile = filepath, IsCharacter=true, x=0, y=0, z=0, ReplaceableTextures=ReplaceableTextures});

			OpenAssetFileDialog.RefreshAnims(filepath);
		end
	end	
end

function OpenAssetFileDialog.SetText(text)
	if(page and text) then
		page:SetValue("text", text);
		local filepath = PlayerAssetFile:GetValidAssetByString(text);
		if(filepath) then
			local ctl = page:FindControl("AssetPreview");
			if(ctl) then
				local ReplaceableTextures;
				if(PlayerSkins:CheckModelHasSkin(filepath)) then
					-- TODO:  hard code worker skin here
					ReplaceableTextures = {[2] = PlayerSkins:GetSkinByID(12)};
				end
				ctl:ShowModel({AssetFile = filepath, IsCharacter=true, x=0, y=0, z=0, ReplaceableTextures=ReplaceableTextures});

				OpenAssetFileDialog.RefreshAnims(filepath);
			end
		end	
	end
end

function OpenAssetFileDialog.RefreshAnims(filepath, tryCount)
	if(not page) then
		return
	end
	local self = OpenAssetFileDialog;
	self.tryCount = tryCount;
	local asset = ParaAsset.LoadParaX(filepath, filepath);
	asset:LoadAsset();
	if(asset:IsValid() and asset:IsLoaded())then
		local options = OpenAssetFileDialog.GetAnimIdsByFilename(filepath);
		if(options) then
			local animIds = OpenAssetFileDialog.GetModelAnimDs();
			table.clear(animIds)
			for i, anim in ipairs(options) do
				animIds[i] = {name="anim", attr={text=anim.text, id=anim.value}}
			end
			page:CallMethod("tvwAnimIds", "DataBind", true);
			return true;
		end
	elseif(asset:IsValid()) then
		self.curFilePath = filepath;
		if(not tryCount) then
			-- only try 5 times
			self.tryCount = 5;
		end
		self.mytimer = self.mytimer or commonlib.Timer:new({callbackFunc = function(timer)
			if(self.tryCount and self.tryCount > 1) then
				OpenAssetFileDialog.RefreshAnims(self.curFilePath, self.tryCount - 1)
			end
		end})
		self.mytimer:Change(500);
	end
end

local allFiles;
function OpenAssetFileDialog.GetAllFiles()
	if(not allFiles) then
		allFiles = {};

		-- fill local files
		allFiles[OpenAssetFileDialog.IndexLocal] = OpenAssetFileDialog.GetExistingFiles();
		
		-- fill all categories from PlayerAsset files
		NPL.load("(gl)script/apps/Aries/Creator/Game/Entity/PlayerAssetFile.lua");
		local PlayerAssetFile = commonlib.gettable("MyCompany.Aries.Game.EntityManager.PlayerAssetFile")
		
		for i=1, #OpenAssetFileDialog.categories do
			local category = OpenAssetFileDialog.categories[i];
			local idx = i-1;
			allFiles[idx] = allFiles[idx] or {};
			local commonFiles = allFiles[idx];
			commonFiles.name = "category";
			commonFiles.attr = {text=category.text, expanded=false, count=0};

			if(PlayerAssetFile:HasCategory(category.name)) then
				local items = PlayerAssetFile:GetCategoryItems(category.name);
				for i, item in ipairs(items) do
					local assetfile = item.filename;
					if(assetfile and assetfile~="") then
						commonFiles[#commonFiles+1] = {name="commonfile", attr={text=item.displayname or item.filename, filename=item.name or item.filename}};
					end
				end
			end
			commonFiles.attr.count = #commonFiles;
		end
		allFiles[OpenAssetFileDialog.IndexLocal].attr.expanded = true;
		allFiles[OpenAssetFileDialog.IndexCommon].attr.expanded = true;
	end
	return allFiles;
end

function OpenAssetFileDialog.OnChangeCategory(index)
	OpenAssetFileDialog.category_index = index;
	local category = OpenAssetFileDialog.GetCategoryButtons()[index];
	if(category.name == "all") then
		for _, category in ipairs(OpenAssetFileDialog.GetAllFiles()) do
			category.attr.expanded = true;
		end
	else
		local idx = index - 1;
		for i, category in ipairs(OpenAssetFileDialog.GetAllFiles()) do
			category.attr.expanded = (i == idx);
		end
	end
	if(page) then
		page:Refresh(0.01);
	end
end

function OpenAssetFileDialog.OnSelectAnimId(id)
	if(page and type(id) == "number") then
		local ctl = page:FindControl("AssetPreview");
		if(ctl) then
			local obj = ctl:GetObject()
			if(obj and obj:IsValid()) then
				obj:SetField("AnimID", id);
			end
		end
	end
end

function OpenAssetFileDialog.GetAnimIdsByFilename(assetfile)
	NPL.load("(gl)script/ide/System/Scene/Assets/ParaXModelAttr.lua");
	local ParaXModelAttr = commonlib.gettable("System.Scene.Assets.ParaXModelAttr");
	NPL.load("(gl)script/apps/Aries/Creator/Game/Effects/EntityAnimation.lua");
	local EntityAnimation = commonlib.gettable("MyCompany.Aries.Game.Effects.EntityAnimation");

	local attr = ParaXModelAttr:new():initFromAssetFile(assetfile);
	local animations = attr:GetAnimations()
	if(animations) then
		local options = {};
		for _, anim in ipairs(animations) do
			if(anim.animID) then
				options[#options+1] = {value = anim.animID, text = EntityAnimation.GetAnimTextByID(anim.animID)}
			end
		end
		table.sort(options, function(a, b)
			return a.value < b.value;
		end)
		return options;
	end
end

function OpenAssetFileDialog.OnTextChange(name, mcmlNode)
	local text = mcmlNode:GetUIValue()
	local filepath = PlayerAssetFile:GetValidAssetByString(text);
	if(filepath) then
		OpenAssetFileDialog.SetModelFilename(filepath);
	end
end

-- only used temporarily to parse for effie's translation file
-- @param prefixPath: such as "model/", "character/"
-- @param outputFilename: if nil, default to filename.csv
-- e.g.
-- OpenAssetFileDialog.ParseFile("temp/assets/character.txt", "character/")
-- OpenAssetFileDialog.ParseFile("temp/assets/model.txt", "model/")
-- OpenAssetFileDialog.ParseFile("temp/assets/Texture.txt", "Texture/")
-- OpenAssetFileDialog.ParseFile("temp/assets/character.txt", "character/")
-- OpenAssetFileDialog.ParseFile("temp/assets/Audio.txt", "Audio/")
function OpenAssetFileDialog.ParseFile(filename, prefixPath, outputFilename)
	local file = ParaIO.open(filename, "r")
	if(file:IsValid()) then
		local folders = {};
		local output = {};
		local parentPath = "";
		local line = file:readline();
		while(line) do
			local folderName = line:match("─([%w]+)");
			if(folderName) then
				local depth=1;
				for _ in line:gmatch("│  ") do
					depth = depth + 1
				end
				folders[depth] = folderName.."/";

				local path = prefixPath or "";
				for i=1, depth do 
					path = path..folders[i];
				end
				parentPath = path;
			else
				line = line:gsub("，",",")
				local filename, separator, comments = line:match("  (%w[^,]+%.x)([^%.%a])(.*)");
				if(comments) then
					filename = parentPath..filename;
					if(ParaIO.DoesAssetFileExist(filename, true)) then
						if(separator ~= ",") then
							comments = separator..comments;
						end
						output[#output+1] = filename..","..comments;
					end
				end
			end
			line = file:readline();
		end
		file:close()

		if(#output > 0) then
			outputFilename = outputFilename or (filename..".csv")
			local file = ParaIO.open(outputFilename, "w")
			if(file:IsValid()) then
				for _, line in ipairs(output) do
					file:WriteString(line.."\n");
				end
				LOG.std(nil, "info", "OpenAssetFileDialog", "%d items written to %s", #output, outputFilename);
				file:close();
			end
		end
	end
end
