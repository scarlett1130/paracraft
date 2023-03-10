--[[
Title: make app Command
Author(s): LiXizhi,big
CreateDate: 2020.4.23
ModifyDate: 2022.3.2
Desc: make current world into a standalone app file (zip)

use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/Creator/Game/Tasks/MakeAppTask.lua");
local MakeApp = commonlib.gettable("MyCompany.Aries.Game.Tasks.MakeApp");
local task = MyCompany.Aries.Game.Tasks.MakeApp:new()
task:Run();
-------------------------------------------------------
]]

--------- thread part start ---------
NPL.load("(gl)script/ide/commonlib.lua")
NPL.load("(gl)script/ide/System/Concurrent/rpc.lua")

local rpc = commonlib.gettable("System.Concurrent.Async.rpc")

rpc:new():init(
    "MyCompany.Aries.Game.Tasks.MakeAppThread.AndroidSignApk",
    function(self, msg)
        NPL.load("(gl)script/apps/Aries/Creator/Game/Tasks/MakeAppTask.lua");
        local MakeApp = commonlib.gettable("MyCompany.Aries.Game.Tasks.MakeApp");
        MakeApp:AndroidSignApkThread();

        return true;
    end,
    "script/apps/Aries/Creator/Game/Tasks/MakeAppTask.lua"
)

rpc:new():init(
    "MyCompany.Aries.Game.Tasks.MakeAppThread.AndroidZipAlignApk",
    function(self, msg)
        NPL.load("(gl)script/apps/Aries/Creator/Game/Tasks/MakeAppTask.lua");
        local MakeApp = commonlib.gettable("MyCompany.Aries.Game.Tasks.MakeApp");
        MakeApp:AndroidZipAlignApkThread();

        return true;
    end,
    "script/apps/Aries/Creator/Game/Tasks/MakeAppTask.lua"
)

rpc:new():init(
    "MyCompany.Aries.Game.Tasks.MakeAppThread.AndroidDecodeApk",
    function(self, msg)
        NPL.load("(gl)script/apps/Aries/Creator/Game/Tasks/MakeAppTask.lua");
        local MakeApp = commonlib.gettable("MyCompany.Aries.Game.Tasks.MakeApp");

        MakeApp:AndroidDecodeApkThread();

        return true;
    end,
    "script/apps/Aries/Creator/Game/Tasks/MakeAppTask.lua"
)

rpc:new():init(
    "MyCompany.Aries.Game.Tasks.MakeAppThread.AndroidGenerateApk",
    function(self, msg)
        NPL.load("(gl)script/apps/Aries/Creator/Game/Tasks/MakeAppTask.lua");
        local MakeApp = commonlib.gettable("MyCompany.Aries.Game.Tasks.MakeApp");

        MakeApp:AndroidGenerateApkThread();

        return true;
    end,
    "script/apps/Aries/Creator/Game/Tasks/MakeAppTask.lua"
)

--------- thread part end ---------

NPL.load("(gl)script/apps/Aries/Creator/Game/Common/Files.lua");
NPL.load("(gl)script/apps/Aries/Creator/Game/API/FileDownloader.lua");
NPL.load("(gl)script/ide/System/Encoding/crc32.lua");
local Encoding = commonlib.gettable("System.Encoding");
local FileDownloader = commonlib.gettable("MyCompany.Aries.Creator.Game.API.FileDownloader");
local Files = commonlib.gettable("MyCompany.Aries.Game.Common.Files");
local WorldCommon = commonlib.gettable("MyCompany.Aries.Creator.WorldCommon")
local GameLogic = commonlib.gettable("MyCompany.Aries.Game.GameLogic")

local MakeApp = commonlib.inherit(commonlib.gettable("MyCompany.Aries.Game.Task"), commonlib.gettable("MyCompany.Aries.Game.Tasks.MakeApp"));

MakeApp.mode = {
    android = 0,
    UI = 1,
}

MakeApp.curAndroidVersion = "2.0.20";
MakeApp.androidBuildRoot = "temp/build_android_resource/";
MakeApp.iOSBuildRoot = "temp/build_ios_resource/";
MakeApp.iOSResourceBaseCDN = "https://cdn.keepwork.com/paracraft/ios/";
MakeApp.xcodePath = ""

function MakeApp:ctor()
end

function MakeApp:Run(...)
    local platform = System.os.GetPlatform();

    if (platform == "win32" or platform == "mac") then
        self:RunImp(...);
    else
        _guihelper.MessageBox(L"????????????????????????????????????");
    end
end

function MakeApp:RunImp(mode, ...)
    local platform = System.os.GetPlatform();

    if (mode == self.mode.UI) then
        System.App.Commands.Call(
            "File.MCMLWindowFrame",
            {
                url = "script/apps/Aries/Creator/Game/Tasks/MakeApp.html",
                name = "Tasks.MakeApp",
                isShowTitleBar = false,
                DestroyOnClose = true, -- prevent many ViewProfile pages staying in memory
                style = CommonCtrl.WindowFrame.ContainerStyle,
                zorder = 0,
                allowDrag = true,
                bShow = nil,
                directPosition = true,
                align = "_ct",
                x = -300,
                y = -225,
                width = 600,
                height = 460,
                cancelShowAnimation = true,
                bToggleShowHide = true,
                enable_esc_key = true
            }
        )
    else
        if (platform == "win32") then
            if (mode == self.mode.android) then
                if (not MakeApp.localAndroidVersion) then
                    if (ParaIO.DoesFileExist(MakeApp.androidBuildRoot .. "version.txt")) then
                        local readFile = ParaIO.open(MakeApp.androidBuildRoot .. "version.txt", "r");
    
                        if (readFile:IsValid()) then
                            local version = readFile:GetText(0, -1);
                            readFile:close();
    
                            MakeApp.localAndroidVersion = version;
                        end
                    end
                end

                local method = ...;
    
                GameLogic.IsVip("MakeApk", true, function(result) 
                    if (result) then
                        self:MakeAndroidApp(method);
                    end
                end)
            else
                self:MakeWindows();
            end
        elseif (platform == "mac") then
            
        end
    end
end

-- windows
function MakeApp:MakeWindows()
    local name = WorldCommon.GetWorldTag("name");
    self.name = name;
    local dirName = commonlib.Encoding.Utf8ToDefault(name);
    self.dirName = dirName;
    local output_folder = ParaIO.GetWritablePath() .. "release/" .. dirName .. "/";
    self.output_folder = output_folder;

    _guihelper.MessageBox(format(L"???????????????%s ????????????????????????????", self.name), function(res)
        if(res and res == _guihelper.DialogResult.Yes) then
            self:MakeApp();
        end
    end, _guihelper.MessageBoxButtons.YesNo);
end

function MakeApp:MakeApp()
    if(self:GenerateFiles()) then
        if(self:MakeZipInstaller()) then
            GameLogic.AddBBS(nil, L"??????????????????????????????????????????", 5000, "0 255 0")
            System.App.Commands.Call("File.WinExplorer", self:GetOutputDir());
            return true;
        end
    end
end

function MakeApp:GetOutputDir()
    return self.output_folder;
end

function MakeApp:GetBinDir()
    return self.output_folder .. "bin/"
end

function MakeApp:GenerateFiles()
    ParaIO.CreateDirectory(self:GetBinDir())

    if(self:MakeStartupExe() and self:CopyWorldFiles() and self:GenerateHelpFile()) then
        if(self:CopyParacraftFiles()) then
            return true;
        end
    end
end

function MakeApp:GetBatFile()
    return self.output_folder .. "start" .. ".bat";
end

function MakeApp:MakeStartupExe()
    local file = ParaIO.open(self:GetBatFile(), "w")
    if(file:IsValid()) then
        file:WriteString("@echo off\n");
        file:WriteString("cd bin\n");
        local worldPath = Files.ResolveFilePath(GameLogic.GetWorldDirectory()).relativeToRootPath or GameLogic.GetWorldDirectory()
        file:WriteString("start ParaEngineClient.exe noupdate=\"true\" IsAppVersion=\"true\" mc=\"true\" bootstrapper=\"script/apps/Aries/main_loop.lua\" world=\"%~dp0data/\"");
        file:close();
        return true;
    end
end

function MakeApp:GenerateHelpFile()
    local file = ParaIO.open(self.output_folder..commonlib.Encoding.Utf8ToDefault(L"????????????")..".html", "w")
    if(file:IsValid()) then
        file:WriteString([[<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<META HTTP-EQUIV="Refresh" CONTENT="1; URL=https://keepwork.com/official/docs/tutorials/exe_Instruction">
<title>Paracraft App</title>
</head>
<body>
<p>Powered by NPL and paracraft</p>
<p>Page will be redirected in 3 seconds</p>
</body>
</html>
]]);
        file:close();
        return true;
    end
end

local excluded_files = {
    ["log.txt"] = true,
    ["paracraft.exe"] = true,
    ["haqilauncherkids.exe"] = true,
    ["haqilauncherkids.mem.exe"] = true,
    ["auto_update_log.txt"] = true,
    ["assets.log"] = true,
}

-- minimum paracraft files
local bin_files = {
    ["ParaEngineClient.exe"] = true,
    ["ParaEngineClient.dll"] = true,
    ["physicsbt.dll"] = true,
    ["ParaEngine.sig"] = true,
    ["lua.dll"] = true,
    ["FreeImage.dll"] = true,
    ["libcurl.dll"] = true,
    ["sqlite.dll"] = true,
    ["assets_manifest.txt"] = true,
    ["config/bootstrapper.xml"] = true,
    ["config/GameClient.config.xml"] = true,
    ["config/commands.xml"] = true,
    ["config/config.txt"] = true,
    ["caudioengine.dll"] = true,
    ["config.txt"] = true,
    ["d3dx9_43.dll"] = true,
    ["main.pkg"] = true,
    ["main_mobile_res.pkg"] = true,
    ["main150727.pkg"] = true,
    ["openal32.dll"] = true,
    ["wrap_oal.dll"] = true,
    ["database/characters.db"] = true,
    ["database/extendedcost.db.mem"] = true,
    ["database/globalstore.db.mem"] = true,
    ["database/apps.db"] = true,
    ["npl_packages/paracraftbuildinmod.zip"] = true,
}

function MakeApp:CopyParacraftFiles()
    local redist_root = self:GetBinDir();
    ParaIO.DeleteFile(redist_root)
    local sdk_root = ParaIO.GetCurDirectory(0);

    for filename, _ in pairs(bin_files) do
        ParaIO.CreateDirectory(sdk_root..filename);
        ParaIO.CopyFile(sdk_root..filename, redist_root..filename, true)
    end
    return true;
end

function MakeApp:CopyWorldFiles()
    WorldCommon.CopyWorldTo(self.output_folder.."data/")
    return true
end

function MakeApp:GetZipFile()
    return self.output_folder..self.dirName..".zip"
end

function MakeApp:MakeZipInstaller()
    local output_folder = self.output_folder;
    local result = commonlib.Files.Find({}, self.output_folder, 10, 5000, function(item)
        return true;
        --no need to check zipfile
        --[[
        local ext = commonlib.Files.GetFileExtension(item.filename);
        if(ext) then
            return (ext ~= "zip")
        end
        ]]
    end)

    local zipfile = self:GetZipFile();
    ParaIO.DeleteFile(zipfile)
    local writer = ParaIO.CreateZip(zipfile,"");
    local appFolder = "ParacraftApp/";
    for i, item in ipairs(result) do
        local filename = item.filename;
        if(filename) then
            -- add all files
            local destFolder = (appFolder..filename):gsub("[/\\][^/\\]+$", "");
            writer:AddDirectory(destFolder, output_folder..filename, 0);
        end
    end
    writer:close();
    LOG.std(nil, "info", "MakeZipInstaller", "successfully generated package to %s", commonlib.Encoding.DefaultToUtf8(zipfile))
    return true;
end

-- android
function MakeApp:AndroidDecodeApk(callback)
    if not callback or type(callback) ~= "function" then
        return
    end

    GameLogic.GetFilters():apply_filters("cellar.common.msg_box.show", L"????????????APK????????????...", 120000, nil, 350);

    MyCompany.Aries.Game.Tasks.MakeAppThread.AndroidDecodeApk(
        "(worker_android_decode_apk)",
        {},
        function(err, msg)
            GameLogic.GetFilters():apply_filters("cellar.common.msg_box.close");

            ParaIO.DeleteFile("temp/worker_android_decode_apk_temp.bat");
            ParaIO.DeleteFile("temp/main_temp.bat");

            callback()
        end
    )
end

function MakeApp:AndroidDecodeApkThread()
    System.os.run(
        "temp\\build_android_resource\\jre-windows\\bin\\java -jar " ..
        self.androidBuildRoot .. "apktool.jar d " ..
        self.androidBuildRoot .. "paracraft_ver" .. self.curAndroidVersion .. ".apk -o " ..
        self.androidBuildRoot .. "paracraft_ver" .. self.curAndroidVersion
    );
end

function MakeApp:AndroidDownloadApk(callback)
    local apkUrl = "https://cdn.keepwork.com/paracraft/android/paracraft_" .. self.curAndroidVersion .. ".apk";

    local fileDownloader = FileDownloader:new();
    fileDownloader.isSilent = true;

    GameLogic.GetFilters():apply_filters("cellar.common.msg_box.show", L"????????????????????????????????????...", 120000, nil, 350);

    local apkFile = self.androidBuildRoot .. "paracraft_ver" .. self.curAndroidVersion .. ".apk";

    if (not ParaIO.DoesFileExist(apkFile)) then
        commonlib.TimerManager.SetTimeout(function()
            fileDownloader:Init("paracraft.apk", apkUrl, apkFile, function(result)
                if (result) then
                    fileDownloader:DeleteCacheFile();
    
                    ParaIO.DeleteFile(self.androidBuildRoot .. "version.txt");
    
                    local writeFile = ParaIO.open(self.androidBuildRoot .. "version.txt", "w");
    
                    if (writeFile:IsValid()) then
                        writeFile:write(self.curAndroidVersion, #self.curAndroidVersion);
                        writeFile:close();
                        MakeApp.localAndroidVersion = self.curAndroidVersion;
                    end
    
                    GameLogic.GetFilters():apply_filters("cellar.common.msg_box.close");
    
                    if (callback and type(callback) == "function") then
                        callback();
                    end
                end
            end)
        end, 500);
    else
        callback()
    end
end

function MakeApp:AndroidUpdateManifest(callback)
    if (not callback or type(callback) ~= "function") then
        return
    end

    GameLogic.GetFilters():apply_filters(
        "cellar.common.msg_box.show",
        L"????????????Manifest????????????...",
        120000,
        nil,
        350
    );

    local currentEnterWorld = GameLogic.GetFilters():apply_filters("store_get", "world/currentEnterWorld");
    local fileRead = ParaIO.open(self.androidBuildRoot .. "paracraft_ver2.0.20/AndroidManifest.xml", "r");
    local content = "";
    local appName = "";

    if (currentEnterWorld.name and type(currentEnterWorld.name) == "string") then
        appName = currentEnterWorld.name;
    else
        appName = currentEnterWorld.foldername;
    end

    if (fileRead:IsValid()) then
        local line = "";

        while (line) do
            line = fileRead:readline();

            if (line) then
                if (string.match(line,  "(.+package%=)%\"")) then
                    local packageName = string.match(line, ".+package%=%\"([a-z.]+)%\"")
                    local newPackageName = "com.paraengine.paracraft.world.c" .. Encoding.crc32(currentEnterWorld.foldername)

                    if (packageName) then
                        line = line:gsub(packageName, newPackageName)
                    end

                    content = content .. line .. "\n";
                elseif (string.match(line, "(.+android:label%=)%\"")) then
                    local labelName = string.match(line, ".+android%:label%=%\"([a-z.@/_]+)%\"")
                    local newLabelName = appName

                    if (labelName) then
                        line = line:gsub(labelName, newLabelName)
                    end

                    content = content .. line .. "\n";
                else
                    content = content .. line .. "\n";
                end
            end
        end

        fileRead:close();
    end

    local writeFile = ParaIO.open(self.androidBuildRoot .. "paracraft_ver2.0.20/AndroidManifest.xml", "w");

    if (writeFile:IsValid()) then
        writeFile:write(content, #content);
        writeFile:close();
    end

    GameLogic.GetFilters():apply_filters("cellar.common.msg_box.close");
    callback();
end

function MakeApp:AndroidGenerateApk(callback)
    GameLogic.GetFilters():apply_filters("cellar.common.msg_box.show", L"????????????APK????????????...", 120000, nil, 350);

    MyCompany.Aries.Game.Tasks.MakeAppThread.AndroidGenerateApk(
        "(worker_android_generate_apk)",
        {},
        function(err, msg)
            GameLogic.GetFilters():apply_filters("cellar.common.msg_box.close");

            ParaIO.DeleteFile("temp/worker_android_generate_apk_temp.bat");
            ParaIO.DeleteFile("temp/main_temp.bat");

            callback();
        end
    )
end

function MakeApp:AndroidGenerateApkThread()
    System.os.run(
        "temp\\build_android_resource\\jre-windows\\bin\\java -jar " ..
        self.androidBuildRoot .. "apktool.jar b " ..
        self.androidBuildRoot .. "paracraft_ver" .. self.curAndroidVersion .. " -o " ..
        self.androidBuildRoot .. "paracraft_ver" .. self.curAndroidVersion .. "_build_temp.apk"
    );
end

function MakeApp:AndroidCopyWorld(compress, beAutoUpdate, beAutoUpdateWorld, loginEnable, callback)
    GameLogic.GetFilters():apply_filters(
        "cellar.common.msg_box.show",
        L"??????????????????????????????...",
        120000,
        nil,
        350
    );

    local currentEnterWorld = GameLogic.GetFilters():apply_filters("store_get", "world/currentEnterWorld");

    if (currentEnterWorld and type(currentEnterWorld) == "table") then
        if (compress) then
            -- copy world
            local fileList = GameLogic.GetFilters():apply_filters("service.local_service.load_files", currentEnterWorld.worldpath, true, true);
    
            if not fileList or type(fileList) ~= "table" or #fileList == 0 then
                return;
            end

            for key, item in ipairs(fileList) do
                if item.filename == "icon.png" then
                    local worldIcon = item.file_path;

                    ParaIO.CreateDirectory(self.androidBuildRoot .. "backup/");

                    local drawableHdpiIconPath =
                        self.androidBuildRoot ..
                        "paracraft_ver" .. self.curAndroidVersion ..
                        "/res/drawable-hdpi/ic_launcher.png";
                    local drawableXhdpiIconPath =
                        self.androidBuildRoot ..
                        "paracraft_ver" .. self.curAndroidVersion ..
                        "/res/drawable-xhdpi/ic_launcher.png";
                    local drawableXxhdpiIconPath =
                        self.androidBuildRoot ..
                        "paracraft_ver" .. self.curAndroidVersion ..
                        "/res/drawable-xxhdpi/ic_launcher.png";

                    local drawableHdpiBackupIconPath = self.androidBuildRoot .. "backup/drawable_hdpi_icon.png";
                    local drawableXhdpiBackupIconPath = self.androidBuildRoot .. "backup/drawable_xhdpi_icon.png";
                    local drawableXxhdpiBackupIconPath = self.androidBuildRoot .. "backup/drawable_xxhdpi_icon.png";

                    if (not ParaIO.DoesFileExist(drawableHdpiBackupIconPath)) then
                        ParaIO.CopyFile(drawableHdpiIconPath, drawableHdpiV4BackupIconPath, true);
                    end

                    if (not ParaIO.DoesFileExist(drawableXhdpiBackupIconPath)) then
                        ParaIO.CopyFile(drawableXhdpiIconPath, drawableXhdpiV4BackupIconPath, true);
                    end

                    if (not ParaIO.DoesFileExist(drawableXxhdpiBackupIconPath)) then
                        ParaIO.CopyFile(drawableXxhdpiIconPath, drawableXxhdpiV4BackupIconPath, true);
                    end

                    ParaIO.CopyFile(worldIcon, drawableHdpiIconPath, true);
                    ParaIO.CopyFile(worldIcon, drawableXhdpiIconPath, true);
                    ParaIO.CopyFile(worldIcon, drawableXxhdpiIconPath, true);

                    break;
                end
            end
    
            local apkWorldPath =
                self.androidBuildRoot ..
                "paracraft_ver" ..
                self.curAndroidVersion ..
                "/assets/worlds/DesignHouse/" ..
                commonlib.Encoding.Utf8ToDefault(currentEnterWorld.foldername) .. "/" ..
                commonlib.Encoding.Utf8ToDefault(currentEnterWorld.foldername) .. "/";

            ParaIO.CreateDirectory(apkWorldPath);

            for key, item in ipairs(fileList) do
                local relativePath = commonlib.Encoding.Utf8ToDefault(item.filename);

                if item.filesize == 0 then
                    local folderPath = apkWorldPath .. relativePath .. "/";
    
                    ParaIO.CreateDirectory(folderPath);
                else
                    local filePath = apkWorldPath .. relativePath;
    
                    ParaIO.CopyFile(item.file_path, filePath, true);
                end
            end

            local apkWorldPath1 =
                self.androidBuildRoot ..
                "paracraft_ver" ..
                self.curAndroidVersion ..
                "/assets/worlds/DesignHouse/" ..
                commonlib.Encoding.Utf8ToDefault(currentEnterWorld.foldername) .. "/";

            GameLogic.GetFilters():apply_filters(
                "service.local_service.move_folder_to_zip",
                apkWorldPath1,
                self.androidBuildRoot ..
                "paracraft_ver" ..
                self.curAndroidVersion ..
                "/assets/worlds/DesignHouse/" ..
                commonlib.Encoding.Utf8ToDefault(currentEnterWorld.foldername) .. ".zip",
                function()
                    GameLogic.GetFilters():apply_filters("cellar.common.msg_box.close");

                    -- update config.txt file
                    local writeFile =
                        ParaIO.open(
                            self.androidBuildRoot ..
                            "paracraft_ver" ..
                            self.curAndroidVersion ..
                            "/assets/config.txt",
                            "w"
                        );

                    if (writeFile:IsValid()) then
                        local content = 
                            "cmdline=mc=\"true\" debug=\"main\" IsAppVersion=\"true\" bootstrapper=\"script/apps/Aries/main_loop.lua\" " .. 
                            "world=\"" .. "worlds/DesignHouse/" .. currentEnterWorld.foldername .. ".zip\"";

                        if (not beAutoUpdate) then
                            content = content .. " noclientupdate=\"true\"";
                        end

                        if (beAutoUpdateWorld) then
                            content = content .. " auto_update_world=\"true\"";
                        end

                        if (loginEnable) then
                            content = content .. " login_enable=\"true\"";
                        end

                        writeFile:write(content, #content);
                        writeFile:close();
                    end

                    ParaIO.DeleteFile(apkWorldPath1);

                    if (callback and type(callback) == "function") then
                        callback();
                    end
                end
            )
        else
            -- copy world
            local fileList =
                GameLogic.GetFilters():apply_filters(
                    "service.local_service.load_files",
                    currentEnterWorld.worldpath,
                    true,
                    true
                );
    
            if not fileList or type(fileList) ~= "table" or #fileList == 0 then
                return;
            end

            for key, item in ipairs(fileList) do
                if item.filename == "icon.png" then
                    local worldIcon = item.file_path;

                    ParaIO.CreateDirectory(self.androidBuildRoot .. "backup/");

                    local drawableHdpiIconPath =
                        self.androidBuildRoot ..
                        "paracraft_ver" ..
                        self.curAndroidVersion ..
                        "/res/drawable-hdpi/ic_launcher.png";
                    local drawableXhdpiIconPath =
                        self.androidBuildRoot ..
                        "paracraft_ver" .. self.curAndroidVersion ..
                        "/res/drawable-xhdpi/ic_launcher.png";
                    local drawableXxhdpiIconPath =
                        self.androidBuildRoot ..
                        "paracraft_ver" ..
                        self.curAndroidVersion ..
                        "/res/drawable-xxhdpi/ic_launcher.png";

                    local drawableHdpiBackupIconPath = self.androidBuildRoot .. "backup/drawable_hdpi_icon.png";
                    local drawableXhdpiBackupIconPath = self.androidBuildRoot .. "backup/drawable_xhdpi_icon.png";
                    local drawableXxhdpiBackupIconPath = self.androidBuildRoot .. "backup/drawable_xxhdpi_icon.png";

                    if (not ParaIO.DoesFileExist(drawableHdpiBackupIconPath)) then
                        ParaIO.CopyFile(drawableHdpiIconPath, drawableHdpiBackupIconPath, true);
                    end

                    if (not ParaIO.DoesFileExist(drawableXhdpiBackupIconPath)) then
                        ParaIO.CopyFile(drawableXhdpiIconPath, drawableXhdpiBackupIconPath, true);
                    end

                    if (not ParaIO.DoesFileExist(drawableXxhdpiBackupIconPath)) then
                        ParaIO.CopyFile(drawableXxhdpiIconPath, drawableXxhdpiBackupIconPath, true);
                    end

                    ParaIO.CopyFile(worldIcon, drawableHdpiIconPath, true);
                    ParaIO.CopyFile(worldIcon, drawableXhdpiIconPath, true);
                    ParaIO.CopyFile(worldIcon, drawableXxhdpiIconPath, true);

                    break;
                end
            end

            local apkWorldPath =
                self.androidBuildRoot ..
                "paracraft_ver" ..
                self.curAndroidVersion ..
                "/assets/worlds/DesignHouse/" ..
                commonlib.Encoding.Utf8ToDefault(currentEnterWorld.foldername) .. "/";

            ParaIO.CreateDirectory(apkWorldPath);

            for key, item in ipairs(fileList) do
                local relativePath = commonlib.Encoding.Utf8ToDefault(item.filename);

                if item.filesize == 0 then
                    local folderPath = apkWorldPath .. relativePath .. "/";

                    ParaIO.CreateDirectory(folderPath);
                else
                    local filePath = apkWorldPath .. relativePath;

                    ParaIO.CopyFile(item.file_path, filePath, true);
                end
            end
    
            -- update config.txt file
            local writeFile = ParaIO.open(self.androidBuildRoot .. "paracraft_ver" .. self.curAndroidVersion .."/assets/config.txt", "w");
    
            if (writeFile:IsValid()) then
                local content = 
                    "cmdline=mc=\"true\" debug=\"main\" IsAppVersion=\"true\" bootstrapper=\"script/apps/Aries/main_loop.lua\" " ..
                    "world=\"" .. "worlds/DesignHouse/" .. currentEnterWorld.foldername .. "\"";

                if (not beAutoUpdate) then
                    content = content .. " noclientupdate=\"true\"";
                end

                if (beAutoUpdateWorld) then
                    content = content .. " auto_update_world=\"true\"";
                end

                if (loginEnable) then
                    content = content .. " login_enable=\"true\"";
                end

                writeFile:write(content, #content);
                writeFile:close();
            end
    
            GameLogic.GetFilters():apply_filters("cellar.common.msg_box.close");
    
            if (callback and type(callback) == "function") then
                callback();
            end
        end
    end
end

function MakeApp:AndroidDownloadTools(callback)
    if not callback or type(callback) ~= "function" then
        return;
    end

    local host = "https://cdn.keepwork.com/paracraft/android"

    local function downloadJre(callback)
        if (not ParaIO.DoesFileExist(self.androidBuildRoot .. "jre-windows/")) then
            local jreTool = host .. "/jre-windows.zip";
    
            local fileDownloader = FileDownloader:new();
            fileDownloader.isSilent = true;
    
            GameLogic.GetFilters():apply_filters("cellar.common.msg_box.show", L"????????????Jre Runtime????????????...", 120000, nil, 400)
            commonlib.TimerManager.SetTimeout(function()
                fileDownloader:Init("jre-windows.zip", jreTool, self.androidBuildRoot .. "jre-windows.zip", function(result)
                    if (result) then
                        fileDownloader:DeleteCacheFile();
    
                        GameLogic.GetFilters():apply_filters("cellar.common.msg_box.close");
                        GameLogic.GetFilters():apply_filters("cellar.common.msg_box.show", L"????????????Jre Runtime????????????...", 120000, nil, 400);
    
                        GameLogic.GetFilters():apply_filters(
                            "service.local_service.move_zip_to_folder",
                            self.androidBuildRoot .. "jre-windows/",
                            self.androidBuildRoot .. "jre-windows.zip",
                            function()
                                GameLogic.GetFilters():apply_filters("cellar.common.msg_box.close");
    
                                callback()
                            end
                        )
                    end
                end)
            end, 500)
        else
            callback()
        end
    end
    
    local function downloadApkTool(callback)
        if (not ParaIO.DoesFileExist(self.androidBuildRoot .. "apktool.jar")) then
            local apkTool = host .. "/apktool.jar"

            local fileDownloader = FileDownloader:new();
            fileDownloader.isSilent = true;

            GameLogic.GetFilters():apply_filters("cellar.common.msg_box.show", L"????????????ApkTool????????????...", 120000, nil, 400)
            commonlib.TimerManager.SetTimeout(function()
                fileDownloader:Init("apktool.jar", apkTool, self.androidBuildRoot .. "apktool.jar", function(result)
                    if (result) then
                        fileDownloader:DeleteCacheFile();

                        GameLogic.GetFilters():apply_filters("cellar.common.msg_box.close");

                        callback()
                    end
                end)
            end, 500)
        else
            callback()
        end
    end

    local function downloadAndroidSDKBuildTool(callback)
        if (not ParaIO.DoesFileExist(self.androidBuildRoot .. "android-sdk-build-tools-32.0.0/")) then
            local androidSDKBuildTool = host .. "/android-sdk-build-tools-32.0.0.zip"

            local fileDownloader = FileDownloader:new();
            fileDownloader.isSilent = true;

            GameLogic.GetFilters():apply_filters("cellar.common.msg_box.show", L"????????????Android SDK Build Tool????????????...", 120000, nil, 400)
            commonlib.TimerManager.SetTimeout(function()
                fileDownloader:Init("android-sdk-build-tools-32.0.0.zip", androidSDKBuildTool, self.androidBuildRoot .. "android-sdk-build-tools-32.0.0.zip", function(result)
                    if (result) then
                        fileDownloader:DeleteCacheFile();
    
                        GameLogic.GetFilters():apply_filters("cellar.common.msg_box.close");
                        GameLogic.GetFilters():apply_filters("cellar.common.msg_box.show", L"????????????Android SDK Build Tool????????????...", 120000, nil, 400);
    
                        GameLogic.GetFilters():apply_filters(
                            "service.local_service.move_zip_to_folder",
                            self.androidBuildRoot .. "android-sdk-build-tools-32.0.0/",
                            self.androidBuildRoot .. "android-sdk-build-tools-32.0.0.zip",
                            function()
                                GameLogic.GetFilters():apply_filters("cellar.common.msg_box.close");
    
                                callback()
                            end
                        )
                    end
                end)
            end, 500)
        else
            callback()
        end
    end

    downloadJre(function()
        downloadApkTool(function()
            downloadAndroidSDKBuildTool(function()
                callback()
            end)
        end)
    end)
end

function MakeApp:AndroidSignApkWrapper(callback)
    if (not ParaIO.DoesFileExist(self.androidBuildRoot .. "personal-key.keystore")) then
        local function downloadLicense(downloadCallback)
            local keystore = "https://cdn.keepwork.com/paracraft/android/personal-key.keystore";

            local fileDownloader = FileDownloader:new();
            fileDownloader.isSilent = true;

            GameLogic.GetFilters():apply_filters("cellar.common.msg_box.show", L"????????????Certification????????????...", 120000, nil, 400);

            commonlib.TimerManager.SetTimeout(function()
                fileDownloader:Init("personal-key.keystore", keystore, self.androidBuildRoot .. "personal-key.keystore", function(result)
                    if (result) then
                        fileDownloader:DeleteCacheFile();
    
                        GameLogic.GetFilters():apply_filters("cellar.common.msg_box.close");

                        if downloadCallback and type(downloadCallback) == "function" then
                            downloadCallback();
                        end
                    end
                end)
            end, 500)
        end

        downloadLicense(function()
            self:AndroidZipAlignApk(function()
                self:AndroidSignApk(callback)
            end)
        end)
    else
        self:AndroidZipAlignApk(function()
            self:AndroidSignApk(callback)
        end)
    end
end

function MakeApp:AndroidZipAlignApk(callback)
    GameLogic.GetFilters():apply_filters("cellar.common.msg_box.show", L"????????????APK????????????...", 120000, nil, 350);

    MyCompany.Aries.Game.Tasks.MakeAppThread.AndroidZipAlignApk(
        "(worker_android_zip_align_apk)",
        {},
        function(err, msg)
            GameLogic.GetFilters():apply_filters("cellar.common.msg_box.close");

            ParaIO.DeleteFile("temp/worker_android_zip_align_apk_temp.bat");
            ParaIO.DeleteFile("temp/main_temp.bat");

            if callback and type(callback) == "function" then
                callback();
            end
        end
    )
end

function MakeApp:AndroidZipAlignApkThread()
    System.os.run(
        "temp\\build_android_resource\\android-sdk-build-tools-32.0.0\\32.0.0\\zipalign.exe -p -f -v 4 " ..
        self.androidBuildRoot .. "paracraft_ver" .. self.curAndroidVersion .. "_build_temp.apk " ..
        self.androidBuildRoot .. "paracraft_ver" .. self.curAndroidVersion .. "_align_temp.apk"
    );

    ParaIO.DeleteFile(self.androidBuildRoot .. "paracraft_ver" .. self.curAndroidVersion .. "_build_temp.apk");
end

function MakeApp:AndroidSignApk(callback)
    GameLogic.GetFilters():apply_filters("cellar.common.msg_box.show", L"????????????APK????????????...", 120000, nil, 350);

    MyCompany.Aries.Game.Tasks.MakeAppThread.AndroidSignApk(
        "(worker_android_sign_apk)",
        {},
        function(err, msg)
            GameLogic.GetFilters():apply_filters("cellar.common.msg_box.close");

            _guihelper.MessageBox(L"APK?????????(" .. self.androidBuildRoot .. "paracraft_ver" .. self.curAndroidVersion .. "_pack.apk)");

            ParaIO.DeleteFile("temp/worker_android_sign_apk_temp.bat");
            ParaIO.DeleteFile("temp/main_temp.bat");

            Map3DSystem.App.Commands.Call("File.WinExplorer", {filepath = self.androidBuildRoot, silentmode = true});

            if callback and type(callback) == "function" then
                callback();
            end
        end
    )
end

function MakeApp:AndroidSignApkThread()
    System.os.run(
        "temp\\build_android_resource\\jre-windows\\bin\\java -jar " ..
        "temp\\build_android_resource\\android-sdk-build-tools-32.0.0\\32.0.0\\lib\\apksigner.jar sign -ks " ..
        self.androidBuildRoot .. "personal-key.keystore " ..
        "--ks-key-alias paracraft " ..
        "--ks-pass pass:paracraft " ..
        "--out " .. self.androidBuildRoot .. "paracraft_ver" .. self.curAndroidVersion .. "_pack.apk " ..
        self.androidBuildRoot .. "paracraft_ver" .. self.curAndroidVersion .. "_align_temp.apk"
    );

    ParaIO.DeleteFile(self.androidBuildRoot .. "paracraft_ver" .. self.curAndroidVersion .. "_align_temp.apk");
end

function MakeApp:AndroidClean(callback)
    GameLogic.GetFilters():apply_filters("cellar.common.msg_box.show", L"????????????????????????...", 120000, nil, 400);

    commonlib.TimerManager.SetTimeout(function()
        ParaIO.DeleteFile(self.androidBuildRoot);

        GameLogic.GetFilters():apply_filters("cellar.common.msg_box.close");

        if (callback and type(callback) == "function") then
            callback();
        end
    end, 1000)
end

function MakeApp:AndroidZip()
    ParaIO.CreateDirectory(self.androidBuildRoot);

    if ParaIO.DoesFileExist(self.androidBuildRoot .. "paracraft_android_ver" .. self.curAndroidVersion .. "/") then
        self:AndroidDownloadTools(function()
            self:AndroidDecodeApk(function()
                self:AndroidUpdateManifest(function()
                    self:AndroidCopyWorld(false, false, false, false, function()	
                        self:AndroidGenerateApk(function()
                            self:AndroidSignApk()
                        end)
                    end)
                end)
            end)
        end)
    else
        self:AndroidDownloadApk(function()
            self:AndroidDownloadTools(function()
                self:AndroidDecodeApk(function()
                    self:AndroidUpdateManifest(function()
                        self:AndroidCopyWorld(false, false, false, false, function()	
                            self:AndroidGenerateApk(function()
                                self:AndroidSignApk()
                            end)
                        end)
                    end)
                end)
            end)
        end)
    end
end

function MakeApp:MakeAndroidApp(method)
    if (method == "zip") then
        self:AndroidZip()
        return
    end

    if (method == "clean") then
        self:AndroidClean()
        return
    end

    self:AndroidClean(function()
        commonlib.TimerManager.SetTimeout(function()
            self:AndroidZip()
        end, 5000)
    end)	
end

-- ios
function MakeApp:iOSCheckENV(callback)
    if (not callback or type(callback) ~= "function") then
        return;
    end

    if (not self:iOSCheckXcode()) then
        return;
    end

    if (not ParaIO.DoesFileExist("/usr/bin/tar")) then
        _guihelper.MessageBox(L"????????????tar");
        return;
    end

    self:iOSCheckCmake(function(result)
        if (result) then
            self:iOSCheckNPLRuntime(function(result)
                if (result) then
                    self:iOSCheckBoost(function(result)
                        if (result) then
                            callback(true);
                        else
                            _guihelper.MessageBox(L"??????Boost?????????");
                            callback(false);
                        end
                    end);
                else
                    _guihelper.MessageBox(L"??????NPLRuntime?????????");
                    callback(false);
                 end
            end);
        else
            _guihelper.MessageBox(L"??????Cmake?????????");
            callback(false);
        end
    end)
end

function MakeApp:iOSCheckXcode()
    if not ParaIO.DoesFileExist("/Applications/Xcode.app") then
        _guihelper.MessageBox(L"????????????Xcode");

        return false;
    else
        return true;
    end
end

function MakeApp:iOSCheckCmake(callback)
    if (not callback or type(callback) ~= "function") then
        return;
    end

    if (not ParaIO.DoesFileExist(self.iOSBuildRoot)) then
        ParaIO.CreateDirectory(self.iOSBuildRoot);
    end

    if (not ParaIO.DoesFileExist(self.iOSBuildRoot .. "/Cmake.app")) then
        local url = self.iOSResourceBaseCDN .. "cmake-3.21.3-macos-universal.tar.gz";

        local fileDownloader = FileDownloader:new();
        fileDownloader.isSilent = true;

        GameLogic.GetFilters():apply_filters("cellar.common.msg_box.show", L"????????????Cmake????????????...", 120000, nil, 400)

        local tarGzFile = self.iOSBuildRoot .. "cmake-3.21.3-macos-universal.tar.gz";

        if (ParaIO.DoesFileExist(tarGzFile)) then
            ParaIO.DeleteFile(tarGzFile);
        end

        commonlib.TimerManager.SetTimeout(function()
            fileDownloader:Init("cmake-3.21.3-macos-universal.tar.gz", url, tarGzFile, function(result)
                if (result) then
                    local tarGzAbsPath = ParaIO.GetWritablePath() .. tarGzFile;

                    os.execute("tar -xzf " .. tarGzAbsPath .. " -C " .. ParaIO.GetWritablePath() .. self.iOSBuildRoot .. " --strip-components 1");
                    
                    if (ParaIO.DoesFileExist(self.iOSBuildRoot .. "/Cmake.app")) then
                        GameLogic.GetFilters():apply_filters("cellar.common.msg_box.close");

                        callback(true);
                    else
                        GameLogic.GetFilters():apply_filters("cellar.common.msg_box.close");
                        _guihelper.MessageBox(L"??????Cmake?????????");
                        callback(false);
                    end
                else
                    GameLogic.GetFilters():apply_filters("cellar.common.msg_box.close");
                    _guihelper.MessageBox(L"??????Cmake?????????");
                    callback(false);
                end
            end)
        end, 500)
    else
        callback(true);
    end
end

function MakeApp:iOSCheckNPLRuntime(callback)
    if (not callback or type(callback) ~= "function") then
        return;
    end

    if (not ParaIO.DoesFileExist(self.iOSBuildRoot)) then
        ParaIO.CreateDirectory(self.iOSBuildRoot);
    end

    if (not ParaIO.DoesFileExist(self.iOSBuildRoot .. "NPLRuntime/")) then
        local version = '2.3'
        local url = "http://code.kp-para.cn/root/NPLRuntime/-/archive/v" .. version .. "/NPLRuntime-v" .. version .. ".tar.bz2";

        local fileDownloader = FileDownloader:new();
        fileDownloader.isSilent = true;

        GameLogic.GetFilters():apply_filters("cellar.common.msg_box.show", L"????????????NPLRuntime????????????...", 120000, nil, 400)

        local tarGzFile = self.iOSBuildRoot .. "NPLRuntime.tar.gz";

        if (ParaIO.DoesFileExist(tarGzFile)) then
            ParaIO.DeleteFile(tarGzFile);
        end

        commonlib.TimerManager.SetTimeout(function()
            fileDownloader:Init("NPLRuntime.tar.gz", url, tarGzFile, function(result)
                if (result) then
                    local tarGzAbsPath = ParaIO.GetWritablePath() .. tarGzFile;

                    os.execute("mkdir " ..
                               ParaIO.GetWritablePath() ..
                               self.iOSBuildRoot ..
                               "NPLRuntime/ && tar -xzf " ..
                               tarGzAbsPath ..
                               " -C " ..
                               ParaIO.GetWritablePath() ..
                               self.iOSBuildRoot ..
                               "NPLRuntime/ --strip-components 1");

                    if (ParaIO.DoesFileExist(self.iOSBuildRoot .. "NPLRuntime/")) then
                        GameLogic.GetFilters():apply_filters("cellar.common.msg_box.close");

                        callback(true);
                    else
                        GameLogic.GetFilters():apply_filters("cellar.common.msg_box.close");
                        _guihelper.MessageBox(L"??????NPLRuntime?????????");
                        callback(false);
                    end
                else
                    GameLogic.GetFilters():apply_filters("cellar.common.msg_box.close");
                    _guihelper.MessageBox(L"??????NPLRuntime?????????");
                    callback(false);
                end
            end)
        end, 500)
    else
        callback(true);
    end
end

function MakeApp:iOSCheckBoost(callback)
    if (not callback or type(callback) ~= "function") then
        return;
    end

    if (not ParaIO.DoesFileExist(self.iOSBuildRoot)) then
        ParaIO.CreateDirectory(self.iOSBuildRoot);
    end

    if (not ParaIO.DoesFileExist(self.iOSBuildRoot .. "Boost/")) then
        ParaIO.CreateDirectory(self.iOSBuildRoot .. "Boost/");
    end

    if (not ParaIO.DoesFileExist(self.iOSBuildRoot .. "Boost/src/boost_1_74_0")) then
        local url = self.iOSResourceBaseCDN .. "boost_1_74_0.tar.bz2";

        local fileDownloader = FileDownloader:new();
        fileDownloader.isSilent = true;

        GameLogic.GetFilters():apply_filters("cellar.common.msg_box.show", L"????????????Boost????????????...", 120000, nil, 400)

        local tarGzFile = self.iOSBuildRoot .. "Boost/boost_1_74_0.tar.bz2";

        if (ParaIO.DoesFileExist(tarGzFile)) then
            ParaIO.DeleteFile(tarGzFile);
        end

        commonlib.TimerManager.SetTimeout(function()
            fileDownloader:Init("boost_1_74_0.tar.bz2", url, tarGzFile, function(result)
                if (result) then
                    local tarGzAbsPath = ParaIO.GetWritablePath() .. tarGzFile;

                    os.execute("mkdir -p " ..
                               ParaIO.GetWritablePath() ..
                               self.iOSBuildRoot ..
                               "Boost/src/boost_1_74_0/ && tar -xjf " ..
                               tarGzAbsPath ..
                               " -C " ..
                               ParaIO.GetWritablePath() ..
                               self.iOSBuildRoot ..
                               "Boost/src/boost_1_74_0/ --strip-components 1");

                    if (ParaIO.DoesFileExist(self.iOSBuildRoot .. "Boost/src/boost_1_74_0/")) then
                        GameLogic.GetFilters():apply_filters("cellar.common.msg_box.close");
                        callback(true);
                    else
                        GameLogic.GetFilters():apply_filters("cellar.common.msg_box.close");
                        _guihelper.MessageBox(L"??????Boost?????????");
                        callback(false);
                    end
                else
                    GameLogic.GetFilters():apply_filters("cellar.common.msg_box.close");
                    _guihelper.MessageBox(L"??????Boost?????????");
                    callback(false);
                end
            end)
        end, 500)
    else
        callback(true);
    end
end

function MakeApp:iOSBuildProject(callback)
    if (not callback or type(callback) ~= "function") then
        return;
    end

    -- copy assets files
    local assetsDir = 'apps/haqi/';

    if (ParaIO.DoesFileExist(assetsDir)) then
        commonlib.Files.CopyFolder("apps/haqi", self.iOSBuildRoot .. "NPLRuntime/NPLRuntime/Platform/iOS/assets");
        commonlib.Files.CopyFolder(
            "/Applications/Paracraft.app/Contents/Resources/assets/fonts",
            self.iOSBuildRoot .. "NPLRuntime/NPLRuntime/Platform/iOS/assets/fonts"
        )
    else
        commonlib.Files.CopyFolder(
            "/Applications/Paracraft.app/Contents/Resources/assets",
            self.iOSBuildRoot .. "NPLRuntime/NPLRuntime/Platform/iOS/assets"
        )
    end

    local guideFolder = "???????????????sh??????build.sh?????????????????????????????????????????????/"

    if (not ParaIO.DoesFileExist(self.iOSBuildRoot .. guideFolder)) then
        ParaIO.CreateDirectory(self.iOSBuildRoot .. guideFolder);
    end

    local shFilePath = ParaIO.GetWritablePath() .. self.iOSBuildRoot .. guideFolder .. "build.sh"

    if (not ParaIO.DoesFileExist(shFilePath)) then
        local shFile = [[
#!/bin/sh
# Author: big
# CreateDate: 2022.2.11
# ModifyDate: 2022.2.21

echo "????????????iOS??????"

cd ../

if [ ! -f "./Boost/src/boost_1_74_0/b2" ]; then
    xattr -d com.apple.quarantine ./Boost/src/boost_1_74_0/tools/build/src/engine/build.sh
    xattr -d com.apple.quarantine ./Boost/src/boost_1_74_0/bootstrap.sh


    pushd ./Boost/src/boost_1_74_0/ && ./bootstrap.sh && popd
fi

xattr -d com.apple.quarantine ]] ..
ParaIO.GetWritablePath() ..
self.iOSBuildRoot ..
"NPLRuntime/NPLRuntime/externals/EmbedResource/prebuild/osx/embed-resource" ..
[[

if [ ! -d "./Boost/build" ]; then
    pushd ./Boost/

    sh ../NPLRuntime/NPLRuntime/externals/boost/scripts/boost.sh \
    -ios -macos --no-framework --boost-version 1.74.0 \
    --boost-libs "thread date_time filesystem system chrono regex serialization iostreams log"

    popd
fi

xattr -d com.apple.quarantine ./Cmake.app
xattr -dr com.apple.quarantine ./Cmake.app/*

if [ ! -d "./build/" ]; then
    mkdir build
fi

echo "Building NPLRuntime..."

pushd ./build/

cmake=../CMake.app/Contents/bin/cmake
export BOOST_ROOT=]] ..
ParaIO.GetWritablePath() ..
[[temp/build_ios_resource/Boost/src/boost_1_74_0/

$cmake -G Xcode -S ../NPLRuntime/NPLRuntime \
       -DCMAKE_TOOLCHAIN_FILE=../NPLRuntime/NPLRuntime/cmake/ios.toolchain.cmake \
       -DIOS_PLATFORM=OS -DENABLE_BITCODE=0 -DIOS_DEPLOYMENT_TARGET=10.0

popd

echo "?????????????????????????????????"

if [ -f "./build/lock" ]; then
    rm ./build/lock
fi

exit 0;
        ]];

        local writeFile = ParaIO.open(shFilePath, "w");

        if (writeFile:IsValid()) then
            writeFile:write(shFile, #shFile);
            writeFile:close();

            os.execute("tr -d \"\\r\" < " .. shFilePath .. " > " .. shFilePath .. ".tmp && mv " .. shFilePath .. ".tmp " .. shFilePath);
        end
    end

    if (ParaIO.DoesFileExist(self.iOSBuildRoot .. "build/lock")) then
        ParaIO.DeleteFile(self.iOSBuildRoot .. "build/lock");
    end

    if (not ParaIO.DoesFileExist(self.iOSBuildRoot .. "build/")) then
        ParaIO.CreateDirectory(self.iOSBuildRoot .. "build/");

        local writeFile = ParaIO.open(self.iOSBuildRoot .. "build/lock", "w");
    
        if (writeFile:IsValid()) then
            writeFile:write("lock", 4);
            writeFile:close();
        end
    
        os.execute("open -a Terminal " ..
                   ParaIO.GetWritablePath() ..
                   self.iOSBuildRoot ..
                   guideFolder);
    
        local checkTimer
    
        GameLogic.GetFilters():apply_filters("cellar.common.msg_box.show", L"????????????????????????Terminal??????...", 60000 * 120, nil, 350);

        checkTimer = commonlib.Timer:new({callbackFunc = function()
            if (not ParaIO.DoesFileExist(self.iOSBuildRoot .. "build/lock")) then
                ParaIO.DeleteFile(self.iOSBuildRoot .. guideFolder);
                ParaIO.DeleteFile(self.iOSBuildRoot .. "build/lock");
    
                checkTimer:Change(nil, nil);

                GameLogic.GetFilters():apply_filters("cellar.common.msg_box.close");
    
                callback();
            end
        end});
    
        checkTimer:Change(100, 100);
    else
        callback();
    end
end

function MakeApp:iOSCopyCurWorldToProject(compress, beAutoUpdate, beAutoUpdateWorld, loginEnable, callback)
    local currentEnterWorld = Mod.WorldShare.Store:Get("world/currentEnterWorld");

    if (not currentEnterWorld or type(currentEnterWorld) ~= "table") then
        return;
    end

    GameLogic.GetFilters():apply_filters("cellar.common.msg_box.show", L"??????????????????????????????...", 120000, nil, 350);

    local worldPath = currentEnterWorld.worldpath;
    local worldsPath = self.iOSBuildRoot .. "NPLRuntime/NPLRuntime/Platform/iOS/assets/worlds/DesignHouse/";

    if (not ParaIO.DoesFileExist(worldsPath)) then
        commonlib.Files.CreateDirectory(worldsPath);
    end

    if (compress) then
        ParaIO.DeleteFile("temp/" .. currentEnterWorld.foldername .. "/");
        local tempWorldPath =
            "temp/" ..
            currentEnterWorld.foldername ..
            "/" ..
            currentEnterWorld.foldername ..
            "/";
        commonlib.Files.CopyFolder(worldPath, tempWorldPath);

        GameLogic.GetFilters():apply_filters(
            "service.local_service.move_folder_to_zip",
            "temp/" .. currentEnterWorld.foldername .. "/",
            worldsPath .. currentEnterWorld.foldername .. ".zip"
        );
    else
        commonlib.Files.CopyFolder(worldPath, worldsPath .. currentEnterWorld.foldername);
    end

    -- update config.txt file
    local configPath = self.iOSBuildRoot .. "NPLRuntime/NPLRuntime/Platform/iOS/assets/config.txt";

    if (ParaIO.DoesFileExist(configPath)) then
        ParaIO.DeleteFile(configPath);
    end

    local writeFile = ParaIO.open(configPath, "w");

    if (writeFile:IsValid()) then
        local foldername = currentEnterWorld.foldername;

        if (compress) then
            foldername = foldername .. ".zip";
        end

        local content = 
            "cmdline=mc=\"true\" debug=\"main\" IsAppVersion=\"true\" bootstrapper=\"script/apps/Aries/main_loop.lua\" " ..
            "world=\"" .. "worlds/DesignHouse/" .. foldername .. "\"";

        if (not beAutoUpdate) then
            content = content .. " noclientupdate=\"true\"";
        end

        if (beAutoUpdateWorld) then
            content = content .. " auto_update_world=\"true\"";
        end

        if (loginEnable) then
            content = content .. " login_enable=\"true\"";
        end

        writeFile:write(content, #content);
        writeFile:close();
    end

    GameLogic.GetFilters():apply_filters("cellar.common.msg_box.close");

    if (callback and type(callback) == "function") then
        callback();
    end
end

function MakeApp:CopyIconToProject(callback)
    local currentEnterWorld = Mod.WorldShare.Store:Get("world/currentEnterWorld");

    if (not currentEnterWorld or type(currentEnterWorld) ~= "table") then
        return;
    end

    local size = {
        {
            dimensions = {
                width = 20,
                height = 20,
            },
            idiom = "",
            scale = 1,
        },
        {
            dimensions = {
                width = 20,
                height = 20,
            },
            scale = 2,
        },
        {
            dimensions = {
                width = 20,
                height = 20,
            },
            scale = 3,
        },
        {
            dimensions = {
                width = 29,
                height = 29,
            },
            scale = 1,
        },
        {
            dimensions = {
                width = 29,
                height = 29,
            },
            scale = 2,
        },
        {
            dimensions = {
                width = 29,
                height = 29,
            },
            scale = 3,
        },
        {
            dimensions = {
                width = 40,
                height = 40,
            },
            scale = 1,
        },
        {
            dimensions = {
                width = 40,
                height = 40,
            },
            scale = 2,
        },
        {
            dimensions = {
                width = 40,
                height = 40,
            },
            scale = 3,
        },
        {
            dimensions = {
                width = 57,
                height = 57,
            },
            scale = 1,
        },
        {
            dimensions = {
                width = 57,
                height = 57,
            },
            scale = 2,
        },
        {
            dimensions = {
                width = 60,
                height = 60,
            },
            scale = 2,
        },
        {
            dimensions = {
                width = 60,
                height = 60,
            },
            scale = 3,
        },
        {
            dimensions = {
                width = 72,
                height = 72,
            },
            scale = 1,
        },
        {
            dimensions = {
                width = 72,
                height = 72,
            },
            scale = 2,
        },
        {
            dimensions = {
                width = 76,
                height = 76,
            },
            scale = 1,
        },
        {
            dimensions = {
                width = 76,
                height = 76,
            },
            scale = 2,
        },
        {
            dimensions = {
                width = 83.5,
                height = 83.5,
            },
            scale = 2,
        },
        {
            dimensions = {
                width = 50,
                height = 50,
            },
            scale = 1,
            name = "Icon-Small-50x50@1x",
        },
        {
            dimensions = {
                width = 50,
                height = 50,
            },
            scale = 2,
            name = "Icon-Small-50x50@2x",
        },
        {
            dimensions = {
                width = 512,
                height = 512,
            },
            scale = 2,
            name = "ItunesArtwork@2x",
        },
    }

    local appIconFolder = ParaIO.GetWritablePath() .. self.iOSBuildRoot .. "NPLRuntime/NPLRuntime/Platform/iOS/Images.xcassets/AppIcon.appiconset";
    local iconPath;

    ParaIO.DeleteFile(appIconFolder .. "/");
    ParaIO.CreateDirectory(appIconFolder .. "/");

    if (ParaIO.DoesFileExist(currentEnterWorld.worldpath .. "/icon.png")) then
        iconPath = currentEnterWorld.worldpath .. "/icon.png"
    else
        ParaIO.CopyFile(
            "Texture/Aries/Creator/paracraft/default_icon_32bits.png",
            "temp/default_icon_32bits.png",
            true
        );

        iconPath = ParaIO.GetWritablePath() .. "temp/default_icon_32bits.png";
    end

    for key, item in ipairs(size) do
        local dest

        if (item.name) then
            dest = appIconFolder .. "/" .. item.name;
        else
            dest = appIconFolder .. "/" .. format("Icon-App-%sx%s@%dx",
                                                  tostring(item.dimensions.width),
                                                  tostring(item.dimensions.height),
                                                  item.scale
                                                 );
        end

        os.execute(format("sips -Z %d %s --out %s.png",
                          item.dimensions.width * item.scale,
                          iconPath,
                          dest));
    end

    local contents = [[
{
    "images" : [
        {
            "size" : "20x20",
            "idiom" : "iphone",
            "filename" : "Icon-App-20x20@2x.png",
            "scale" : "2x"
        },
        {
            "size" : "20x20",
            "idiom" : "iphone",
            "filename" : "Icon-App-20x20@3x.png",
            "scale" : "3x"
        },
        {
            "size" : "29x29",
            "idiom" : "iphone",
            "filename" : "Icon-App-29x29@1x.png",
            "scale" : "1x"
        },
        {
            "size" : "29x29",
            "idiom" : "iphone",
            "filename" : "Icon-App-29x29@2x.png",
            "scale" : "2x"
        },
        {
            "size" : "29x29",
            "idiom" : "iphone",
            "filename" : "Icon-App-29x29@3x.png",
            "scale" : "3x"
        },
        {
            "size" : "40x40",
            "idiom" : "iphone",
            "filename" : "Icon-App-40x40@2x.png",
            "scale" : "2x"
        },
        {
            "size" : "40x40",
            "idiom" : "iphone",
            "filename" : "Icon-App-40x40@3x.png",
            "scale" : "3x"
        },
        {
            "size" : "57x57",
            "idiom" : "iphone",
            "filename" : "Icon-App-57x57@1x.png",
            "scale" : "1x"
        },
        {
            "size" : "57x57",
            "idiom" : "iphone",
            "filename" : "Icon-App-57x57@2x.png",
            "scale" : "2x"
        },
        {
            "size" : "60x60",
            "idiom" : "iphone",
            "filename" : "Icon-App-60x60@2x.png",
            "scale" : "2x"
        },
        {
            "size" : "60x60",
            "idiom" : "iphone",
            "filename" : "Icon-App-60x60@3x.png",
            "scale" : "3x"
        },
        {
            "size" : "20x20",
            "idiom" : "ipad",
            "filename" : "Icon-App-20x20@1x.png",
            "scale" : "1x"
        },
        {
            "size" : "20x20",
            "idiom" : "ipad",
            "filename" : "Icon-App-20x20@2x.png",
            "scale" : "2x"
        },
        {
            "size" : "29x29",
            "idiom" : "ipad",
            "filename" : "Icon-App-29x29@1x.png",
            "scale" : "1x"
        },
        {
            "size" : "29x29",
            "idiom" : "ipad",
            "filename" : "Icon-App-29x29@2x.png",
            "scale" : "2x"
        },
        {
            "size" : "40x40",
            "idiom" : "ipad",
            "filename" : "Icon-App-40x40@1x.png",
            "scale" : "1x"
        },
        {
            "size" : "40x40",
            "idiom" : "ipad",
            "filename" : "Icon-App-40x40@2x.png",
            "scale" : "2x"
        },
        {
            "size" : "50x50",
            "idiom" : "ipad",
            "filename" : "Icon-Small-50x50@1x.png",
            "scale" : "1x"
        },
        {
            "size" : "50x50",
            "idiom" : "ipad",
            "filename" : "Icon-Small-50x50@2x.png",
            "scale" : "2x"
        },
        {
            "size" : "72x72",
            "idiom" : "ipad",
            "filename" : "Icon-App-72x72@1x.png",
            "scale" : "1x"
        },
        {
            "size" : "72x72",
            "idiom" : "ipad",
            "filename" : "Icon-App-72x72@2x.png",
            "scale" : "2x"
        },
        {
            "size" : "76x76",
            "idiom" : "ipad",
            "filename" : "Icon-App-76x76@1x.png",
            "scale" : "1x"
        },
        {
            "size" : "76x76",
            "idiom" : "ipad",
            "filename" : "Icon-App-76x76@2x.png",
            "scale" : "2x"
        },
        {
            "size" : "83.5x83.5",
            "idiom" : "ipad",
            "filename" : "Icon-App-83.5x83.5@2x.png",
            "scale" : "2x"
        },
        {
            "size" : "1024x1024",
            "idiom" : "ios-marketing",
            "filename" : "ItunesArtwork@2x.png",
            "scale" : "1x"
        }
    ],
    "info" : {
        "version" : 1,
        "author" : "xcode"
    }
}
    ]];

    local writeFile = ParaIO.open(appIconFolder .. "/Contents.json", "w");

    if (writeFile:IsValid()) then
        writeFile:write(contents, #contents);
        writeFile:close();
    end

    if (callback and type(callback) == "function") then
        callback();
    end
end

function MakeApp:iOSOpenProject()
    os.execute("open -a Xcode " ..
               ParaIO.GetWritablePath() ..
               self.iOSBuildRoot .. 
               "build/NPLRuntime.xcodeproj");
end
