--[[
Title: RailCarAddCameraPage
Author(s): yangguiyi
Date: 2021/7/27
Desc:  
Use Lib:
-------------------------------------------------------
NPL.load("(gl)script/apps/Aries/Creator/Game/Tasks/RailCar/RailCarAddCameraPage.lua").Show();
--]]
local RailCarAddCameraPage = NPL.export();
local CameraController = commonlib.gettable("MyCompany.Aries.Game.CameraController")
local RailCarFiexdCameraPage = NPL.load("(gl)script/apps/Aries/Creator/Game/Tasks/RailCar/RailCarFiexdCameraPage.lua")
local BlockEngine = commonlib.gettable("MyCompany.Aries.Game.BlockEngine")
local server_time = 0
local page


function RailCarAddCameraPage.OnInit()
    page = document:GetPageCtrl();
    page.OnClose = RailCarAddCameraPage.CloseView
    page.OnCreate = RailCarAddCameraPage.OnCreate
end

function RailCarAddCameraPage.OnCreate()
end
function RailCarAddCameraPage.Show()
    RailCarAddCameraPage.ShowView()
end

function RailCarAddCameraPage.ShowView()
    if page and page:IsVisible() then
        return
    end
    RailCarAddCameraPage.InitData()
    
    local params = {
        url = "script/apps/Aries/Creator/Game/Tasks/RailCar/RailCarAddCameraPage.html",
        name = "RailCarAddCameraPage.Show", 
        isShowTitleBar = false,
        DestroyOnClose = true,
        style = CommonCtrl.WindowFrame.ContainerStyle,
        allowDrag = true,
        enable_esc_key = true,
        zorder = 0,
        directPosition = true,
        
        align = "_ct",
        x = -335/2,
        y = -227/2,
        width = 335,
        height = 227,
    };
    System.App.Commands.Call("File.MCMLWindowFrame", params);
end

function RailCarAddCameraPage.FreshView()
    local parent  = page:GetParentUIObject()
end

function RailCarAddCameraPage.OnRefresh()
    if(page)then
        page:Refresh(0);
    end
    RailCarAddCameraPage.FreshView()
end

function RailCarAddCameraPage.CloseView()
    RailCarAddCameraPage.ClearData()
end

function RailCarAddCameraPage.ClearData()
end

function RailCarAddCameraPage.InitData()

end

function RailCarAddCameraPage.Close()
    if page and page:IsVisible() then
        page:CloseWindow(0)
        RailCarAddCameraPage.CloseView()
    end
end


function RailCarAddCameraPage.ChangeIsRandom()
    RailCarAddCameraPage.SettingData.is_random = not RailCarAddCameraPage.SettingData.is_random
    page:Refresh(0)
end

function RailCarAddCameraPage.TimeInputOnChange()
end

function RailCarAddCameraPage.ClickOk()
    local value = page:GetValue("pos_input")
    if value == nil or value == "" then
        GameLogic.AddBBS(nil, L"???????????????");
        return
    end
    
    local arr = commonlib.split(value,",");
    if #arr ~= 3 then
        GameLogic.AddBBS(nil, L"???????????????????????????x,y,z??????????????????????????????");
        return
    end

    for k, v in pairs(arr) do
        local num_value = tonumber(v)
        if num_value == nil then
            GameLogic.AddBBS(nil, L"????????????????????????????????????????????????");
            return
        end

        arr[k] = num_value
    end

    local movie_entity = BlockEngine:GetBlockEntity(arr[1] or 0, arr[2] or 0, arr[3] or 0);
    if not movie_entity or not movie_entity.movieClip then
        GameLogic.AddBBS(nil, L"???????????????????????????????????????????????????????????????????????????");
        return
    end

    local desc = string.format("%s,%s,%s", arr[1], arr[2], arr[3])
    RailCarFiexdCameraPage.AddPosData({pos = arr, is_select = true, desc = desc})
    -- page:SetValue("pos_input", "")
    RailCarAddCameraPage.Close()
end