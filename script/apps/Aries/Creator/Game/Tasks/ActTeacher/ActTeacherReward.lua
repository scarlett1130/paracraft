--[[
    luaide  模板位置位于 Template/FunTemplate/NewFileTemplate.lua 其中 Template 为配置路径 与luaide.luaTemplatesDir
    luaide.luaTemplatesDir 配置 https://www.showdoc.cc/web/#/luaide?page_id=713062580213505
    author:{pbb}
    time:2021-09-08 11:24:28
    use lib:
    local ActTeacherReward = NPL.load("(gl)script/apps/Aries/Creator/Game/Tasks/ActTeacher/ActTeacherReward.lua") 
    ActTeacherReward.ShowView()
]]

local ActTeacherReward = NPL.export()

local page = nil
function ActTeacherReward.OnInit()
    page = document:GetPageCtrl();
end

function ActTeacherReward.ShowView()
    local view_width = 640
    local view_height = 520
    local params = {
        url = "script/apps/Aries/Creator/Game/Tasks/ActTeacher/ActTeacherReward.html",
        name = "ActTeacherReward.ShowView", 
        isShowTitleBar = false,
        DestroyOnClose = true,
        style = CommonCtrl.WindowFrame.ContainerStyle,
        allowDrag = true,
        enable_esc_key = true,
        zorder = 0,
        -- app_key = MyCompany.Aries.Creator.Game.Desktop.App.app_key,
        directPosition = true,
        align = "_ct",
            x = -view_width/2,
            y = -view_height/2,
            width = view_width,
            height = view_height,
    };
    System.App.Commands.Call("File.MCMLWindowFrame", params);
end