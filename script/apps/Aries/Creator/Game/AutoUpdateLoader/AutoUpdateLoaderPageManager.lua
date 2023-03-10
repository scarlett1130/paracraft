--[[
Title: AutoUpdateLoaderPageManager
Author(s): leio
Date: 2019.12.26
Desc: 
use the lib:
------------------------------------------------------------
local AutoUpdateLoaderPageManager = NPL.load("(gl)script/apps/Aries/Creator/Game/AutoUpdateLoader/AutoUpdateLoaderPageManager.lua");
local nplbrowser_loader_page = AutoUpdateLoaderPageManager.CreateOrGet_NplBrowser();
nplbrowser_loader_page:Check();

local AutoUpdateLoaderPageManager = NPL.load("(gl)script/apps/Aries/Creator/Game/AutoUpdateLoader/AutoUpdateLoaderPageManager.lua");
local nodejs_loader_page = AutoUpdateLoaderPageManager.CreateOrGet_NodeJsRuntime();
nodejs_loader_page:Check();
------------------------------------------------------------
]]
local AutoUpdateLoaderPage = NPL.load("(gl)script/apps/Aries/Creator/Game/AutoUpdateLoader/AutoUpdateLoaderPage.lua");
local AutoUpdateLoaderPageManager = NPL.export();

AutoUpdateLoaderPageManager.pages = {};
function AutoUpdateLoaderPageManager.CreateOrGet_NplBrowser()
    local name = "nplbrowser"
    local loader_page = AutoUpdateLoaderPageManager.pages[name];
    if(not loader_page)then
        loader_page = AutoUpdateLoaderPage:new():OnInit(
            "nplbrowser",
            "NplBrowser",
            "cef3",
            "script/apps/Aries/Creator/Game/NplBrowser/configs/nplbrowser.xml",
            {
                "cefclient.exe",
                "NplCefPlugin.dll",
                "libcef.dll",
                "cef.pak",
            }
        );
        AutoUpdateLoaderPageManager.pages[name] = loader_page;
    end
    return loader_page;
end

function AutoUpdateLoaderPageManager.CreateOrGet_NodeJsRuntime()
    local name = "NodeJsRuntime"
    local loader_page = AutoUpdateLoaderPageManager.pages[name];
    if(not loader_page)then
        loader_page = AutoUpdateLoaderPage:new():OnInit(
            name,
            name,
            name,
            "script/apps/Aries/Creator/Game/NodeJsRuntime/configs/NodeJsRuntime.xml",
            {
                "node.exe",
                "node_modules/pxt/cli.js",
            }
        );
        AutoUpdateLoaderPageManager.pages[name] = loader_page;
    end
    return loader_page;
end

function AutoUpdateLoaderPageManager.CreateOrGet_NplExtensions(name)
    name = name or "npl_extensions"
    local loader_page = AutoUpdateLoaderPageManager.pages[name];

	local version = ParaEngine.GetAppCommandLineByParam("http_env", "ONLINE");
    version = string.upper(version);
	local config_filepath = "script/apps/Aries/Creator/Game/NplExtensionsUpdater/configs/npl_extensions.xml";
	if( version ~= "ONLINE")then
		config_filepath = "script/apps/Aries/Creator/Game/NplExtensionsUpdater/configs/npl_extensions.debug.xml";
	end
	LOG.std(nil, "info", "AutoUpdateLoaderPageManager", "npl_extensions load: %s", config_filepath);
    if(not loader_page)then
        loader_page = AutoUpdateLoaderPage:new():OnInit(
            name,
            name,
            name,
            config_filepath,
            {
            }
        );
        AutoUpdateLoaderPageManager.pages[name] = loader_page;
    end
    return loader_page;
end