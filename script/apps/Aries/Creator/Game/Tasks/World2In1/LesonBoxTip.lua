--[[
    author:pbb
    date:
    Desc:
    use lib:
        local LesonBoxTip = NPL.load("(gl)script/apps/Aries/Creator/Game/Tasks/World2In1/LesonBoxTip.lua") 
        LesonBoxTip.ShowView()
]]

-- selection group index used to show the frame
local groupindex_hint_auto = 6;
local groupindex_wrong = 3;
local groupindex_hint = 5; -- when placeable but not matching hand block

--check_button_status
local check_width_bak = 0
local check_height_bak = 0

--local movieBlockId = block_types.names.MovieClip;
NPL.load("(gl)script/apps/Aries/Creator/Game/Sound/SoundManager.lua");
NPL.load("(gl)script/apps/Aries/Creator/Game/block_engine.lua");
NPL.load("(gl)script/apps/Aries/Creator/Game/Items/ItemClient.lua");
local ItemClient = commonlib.gettable("MyCompany.Aries.Game.Items.ItemClient");
local BlockEngine = commonlib.gettable("MyCompany.Aries.Game.BlockEngine")
local SoundManager = commonlib.gettable("MyCompany.Aries.Game.Sound.SoundManager");
local EntityManager = commonlib.gettable("MyCompany.Aries.Game.EntityManager");
local LessonBoxCompare = NPL.load("(gl)script/apps/Aries/Creator/Game/Tasks/World2In1/LessonBoxCompare.lua");
local World2In1 = NPL.load("(gl)script/apps/Aries/Creator/Game/Tasks/ParaWorld/World2In1.lua");
local LesonBoxTip = NPL.export()

local compare_type = -1
local tip_timer
local scale_timer
local errblock_timer 
local check_timer = nil
local lockarea_timer
LesonBoxTip.CheckBLockTips={
    [5]="我已经无法形容我的心情了！你已经可以担当一名小老师了！一起进行下一步吧！",
    [4]="我的天！你简直是一个天才！事不宜迟，马上开始下一步！",
    [3]="棒极了！你是我见到过的最聪明的学生！我想你已经等不及要下一步的吧？",
    [2]="太棒了！让我们进入下一步吧！",
    [1]="很好！那么让我们立即进入下一步！",
    [-1]="唔？好像有不对的地方，让我们再做一遍吧！",
    [-2]="可惜，还是有不对的地方，再好好检查一下？",
    [-3]="呃……这个可能确实有点难，好好回忆一下我的提示，再做一遍看看？",
    [-4]="还是不太对！别灰心，这个很容易，让我们再试一次！",
    [-5]="不要放弃！距离成功已经很接近了！让我们再来一次！",
    [-6]="好吧，我承认这个确实有一点难，我带着你手把手做一次吧？",
}

LesonBoxTip.RoleAni={
    [5]={{3,"Texture/blocks/Paperman/eye/eye_boy_I_01.png"},{4,"Texture/blocks/Paperman/mouth/mouth_girl_03_01.png"}},
    [4]={{3,"Texture/blocks/Paperman/eye/eye_boy_I_01.png"},{4,"Texture/blocks/Paperman/mouth/mouth_boy_05_01.png"}},
    [3]={{3,"Texture/blocks/Paperman/eye/eye_fanpai_le.png"},{4,"Texture/blocks/Paperman/mouth/mouth_boy_05_01.png"}},
    [2]={{3,"Texture/blocks/Paperman/eye/eye_fanpai_le.png"},{4,"Texture/blocks/Paperman/mouth/mouth_04.png"}},
    [1]={{3,"Texture/blocks/Paperman/eye/eye_fanpai_le.png"}},
    [-1]={{3,"Texture/blocks/Paperman/eye/eye_boy_L_01.png"}},
    [-2]={{3,"Texture/blocks/Paperman/eye/eye_boy_M_01.png"}},
    [-3]={{3,"Texture/blocks/Paperman/eye/eye_boy_R_01.png"}},
    [-4]={{3,"Texture/blocks/Paperman/eye/eye_boy_M_01.png"}},
    [-5]={{3,"Texture/blocks/Paperman/eye/eye_boy_S_01.png"}},
    [-6]={{3,"Texture/blocks/Paperman/eye/eye_boy_T_01.png"}},
}

LesonBoxTip.CheckMovieTips={
    slot = "没能在电影方块中找到对应的【摄影机】/【演员】，请先检查一下是否正确添加了【摄影机】/【演员】，或是调换了位置？",
    time = "电影方块的时长错了，正确的时长是【%s】，请重新设定",
    movie_clip = "没能在【摄影机】/【演员】上找到关键帧，请再核对一下",
    movie_prop_accurate = "",
    movie_prop_vague = "",
    actor_prop_accurate = "",
    actor_prop_vague = "",
}

LesonBoxTip.NomalTip = {
    check="仔细观察一下我这边，在绿色的格子中，摆放合适的方块吧！",
    movietarget="在电影方块中，%s",
    notfinish="像我这样，完成全部的操作吧！",
}
local checkIndex = 0
local page = nil
local page_root = nil
local lessonConfig = nil
local checkBtnType ="start"
LesonBoxTip.m_nCorrectCount = 0 --连续检查正确的次数
LesonBoxTip.NeedChangeBlocks = {} --检查以后错误的方块
LesonBoxTip.AllNeedBuildBlock = {} --小节开始时，所有需要创建或者删除的方块，用于备份
LesonBoxTip.CurNeedBuildBlock = {} --当前小节需要创建或者删除的方块
LesonBoxTip.m_nCreateBoxCount = 0
LesonBoxTip.m_nCurStageIndex = 0
LesonBoxTip.m_nMaxStageIndex = 0
LesonBoxTip.m_tblAllStageConfig = {}

function LesonBoxTip.OnInit()
    page = document:GetPageCtrl();
    if page and page:IsVisible() then
        page_root = page:GetParentUIObject()  
    end
end

function LesonBoxTip.ShowView()
    local view_width = 620
    local view_height = 220
    local params = {
        url = "script/apps/Aries/Creator/Game/Tasks/World2In1/LesonBoxTip.html",
        name = "LesonBoxTip.ShowView", 
        isShowTitleBar = false,
        DestroyOnClose = true,
        style = CommonCtrl.WindowFrame.ContainerStyle,
        allowDrag = false,
        click_through = true,
        enable_esc_key = false,
        zorder = -13,
        app_key = MyCompany.Aries.Creator.Game.Desktop.App.app_key,
        directPosition = true,
        align = "_fi",
            x = 0,
            y = 0,
            width = 0,
            height = 0,
    };
    System.App.Commands.Call("File.MCMLWindowFrame", params);
    LesonBoxTip.InitTeacherPlayer()
    LesonBoxTip.UpdateCheckBtnScale(1.016)
    LesonBoxTip.RegisterEvent()
end

function LesonBoxTip.RegisterEvent()
    GameLogic:Connect("WorldUnloaded", LesonBoxTip, LesonBoxTip.OnWorldUnload, "UniqueConnection");
end

function LesonBoxTip.OnWorldUnload()
    LesonBoxTip.EndTip()
    checkIndex = 0
    page = nil
    page_root = nil
    lessonConfig = nil
    checkBtnType ="start"
    LesonBoxTip.m_nCorrectCount = 0 --连续检查正确的次数
    LesonBoxTip.NeedChangeBlocks = {} --检查以后错误的方块
    LesonBoxTip.AllNeedBuildBlock = {} --小节开始时，所有需要创建或者删除的方块，用于备份
    LesonBoxTip.CurNeedBuildBlock = {} --当前小节需要创建或者删除的方块
    LesonBoxTip.m_nCreateBoxCount = 0
    LesonBoxTip.m_nCurStageIndex = 0
    LesonBoxTip.m_nMaxStageIndex = 0
    LesonBoxTip.m_tblAllStageConfig = {}
    LesonBoxTip.UnregisterHooks()
    LesonBoxTip.ClearBlockTip()
    LesonBoxTip.ClearErrorBlockTip()
    LesonBoxTip.ClosePage()
    LesonBoxTip.StopStageMovie()
    LesonBoxTip.EndAllTimer()
end

function LesonBoxTip.InitTeacherPlayer()
    local module_ctl = page:FindControl("teacher_role")
	local scene = ParaScene.GetMiniSceneGraph(module_ctl.resourceName);
	if scene and scene:IsValid() then
		local player = scene:GetObject(module_ctl.obj_name);
        if player then
            player:SetScale(1)
            player:SetFacing(1.57);
			player:SetField("HeadUpdownAngle", 0.3);
			player:SetField("HeadTurningAngle", 0);
            player:SetField("assetfile","character/CC/02human/paperman/principal.x")
        end
	end
end

local reset_timer = nil
function LesonBoxTip.PlayRoleAni(index)
    local module_ctl = page:FindControl("teacher_role")
	local scene = ParaScene.GetMiniSceneGraph(module_ctl.resourceName);
	if scene and scene:IsValid() then
		local player = scene:GetObject(module_ctl.obj_name);
        local aniConfig = LesonBoxTip.RoleAni[index]
        if aniConfig then
            for i=1,#aniConfig do
                local cur = aniConfig[i]
                player:SetReplaceableTexture(cur[1],ParaAsset.LoadTexture("",cur[2],1))
            end
        end
        if(reset_timer) then
			reset_timer:Change();
		end
		reset_timer = commonlib.TimerManager.SetTimeout(function ()
            player:SetReplaceableTexture(3,player:GetDefaultReplaceableTexture(3))
            player:SetReplaceableTexture(4,player:GetDefaultReplaceableTexture(4))
		end, 1500);
    end
end

function LesonBoxTip.AddOperateCount(count)
    if type(count) == "number" then
        LesonBoxTip.m_nCreateBoxCount = LesonBoxTip.m_nCreateBoxCount + count
        return 
    end
    LesonBoxTip.m_nCreateBoxCount = LesonBoxTip.m_nCreateBoxCount + 1
end
--/select 18870,13,19151(-19,1,-19)
function LesonBoxTip.InitLessonConfig(config)
    if config then
        lessonConfig = config
        echo(config,true)
        LesonBoxTip.InitLessonData()
        LesonBoxTip.m_nMaxStageIndex = #lessonConfig.taskCnf
        LesonBoxTip.m_nCurStageIndex = LesonBoxTip.m_nCurStageIndex + 1
        -- echo(lessonConfig.taskCnf,true)
        -- print("maxstage============",LesonBoxTip.m_nMaxStageIndex,#lessonConfig.taskCnf)
        LesonBoxTip.PrepareStageScene()
    end
end

function LesonBoxTip.ClearLearnArea(area)
    if not area or not area.pos or not area.size then
        return 
    end
    -- print("ClearLearnArea==============")
    -- echo(area)
    GameLogic.RunCommand(string.format("/select %d,%d,%d (%d %d %d)",area.pos[1],area.pos[2],area.pos[3],area.size[1],area.size[2],area.size[3]))
    GameLogic.RunCommand("/del")
    GameLogic.RunCommand("/select -clear")
end

local Isprepare = false
local isStopMovieBySelf = false
--18663,12,19336(49,1,20)
function LesonBoxTip.PrepareStageScene()
    Isprepare = true
    isStopMovieBySelf = false
    LesonBoxTip.EndTip()
    local stagePos = lessonConfig.teachStage
    if stagePos[1] then
        GameLogic.GetPlayer():MountEntity(nil);
        GameLogic.RunCommand(string.format("/goto %d,%d,%d",stagePos[1],stagePos[2],stagePos[3]))
    end
    local lookPos = lessonConfig.lookPos
    if lookPos then
        GameLogic.RunCommand(string.format("/lookat %d,%d,%d",lookPos[1],lookPos[2],lookPos[3]))
    end
    GameLogic.RunCommand("/ggs user hidden");
    -- print("runcommand showMask===============start")
    GameLogic.RunCommand("/sendevent showMask")
    -- print("runcommand showMask===============end")
    local taskCnf = lessonConfig.taskCnf[LesonBoxTip.m_nCurStageIndex]
    local moivePos = taskCnf.moviePos
    if moivePos[1] then
        GameLogic.RunCommand("/sendevent hideNpc")
        GameLogic.GetCodeGlobal():BroadcastTextEvent("playstagemovie", {config = taskCnf});
    end
end


function LesonBoxTip.StopStageMovie()
    isStopMovieBySelf = true
    GameLogic.GetCodeGlobal():BroadcastTextEvent("stopStageMovie");
end

function LesonBoxTip.StartCurStage()
    -- print("StartCurStage=============== 18692,13,19355")
    if isStopMovieBySelf then
        isStopMovieBySelf = false
        -- print("cccccccccccccccc")
        return 
    end
    local taskArea = lessonConfig.stageArea
    local posTeacher = lessonConfig.templateteacher
    local posMy = lessonConfig.templatemy
    local taskCnf = lessonConfig.taskCnf[LesonBoxTip.m_nCurStageIndex]
    -- print("clear start")
    LesonBoxTip.ClearLearnArea(taskArea)
    -- print("clear end")
    LesonBoxTip.ShowView()
    commonlib.TimerManager.SetTimeout(function()
        Isprepare = false
        local endTemp = taskCnf.finishtemplate
        local startTemp = taskCnf.starttemplate
        -- print("temp========",endTemp,startTemp)
        -- print(string.format("/loadtemplate %d,%d,%d %s",posMy[1],posMy[2],posMy[3],startTemp))
        -- print(string.format("/loadtemplate %d,%d,%d %s",posTeacher[1],posTeacher[2],posTeacher[3],endTemp))
        -- echo(lessonConfig,true)
        GameLogic.RunCommand("/clearbag")
        GameLogic.RunCommand(string.format("/loadtemplate %d,%d,%d %s",posTeacher[1],posTeacher[2],posTeacher[3],endTemp))
        GameLogic.RunCommand(string.format("/loadtemplate %d,%d,%d %s",posMy[1],posMy[2],posMy[3],startTemp))
        local stagePos = lessonConfig.myStage
        if stagePos[1] then
            GameLogic.GetPlayer():MountEntity(nil);
            GameLogic.RunCommand(string.format("/goto %d,%d,%d",stagePos[1],stagePos[2],stagePos[3]))
            GameLogic.RunCommand("/camerayaw 1.57")
        end
        LesonBoxTip.StartTip()
        LesonBoxTip.StartLearn()
    end,500)
end

function LesonBoxTip.ResetMyArea()
    if not lessonConfig then
        return 
    end
    local taskCnf = lessonConfig.taskCnf[LesonBoxTip.m_nCurStageIndex]
    local startTemp = taskCnf.starttemplate
    local posMy = lessonConfig.templatemy
    local regionsrc = lessonConfig.regionMy
    LesonBoxTip.ClearLearnArea(regionsrc)
    commonlib.TimerManager.SetTimeout(function()
        GameLogic.RunCommand(string.format("/loadtemplate %d,%d,%d %s",posMy[1],posMy[2],posMy[3],startTemp))
        GameLogic.AddBBS("resetArea","区域已恢复到初始状态")
    end,500)
end

function LesonBoxTip.InitLessonData()
    checkIndex = 0
    checkBtnType ="start"
    LesonBoxTip.m_nCorrectCount = 0 --连续检查正确的次数
    LesonBoxTip.m_nCreateBoxCount = 0
    LesonBoxTip.NeedChangeBlocks = {} --检查以后错误的方块
    LesonBoxTip.AllNeedBuildBlock = {} --小节开始时，所有需要创建或者删除的方块，用于备份
    LesonBoxTip.CurNeedBuildBlock = {} --当前小节需要创建或者删除的方块
    LesonBoxTip.CreatePos = nil
    LesonBoxTip.SrcBlockOrigin = nil
    LesonBoxTip.m_nCurStageIndex = 0
    LesonBoxTip.m_nMaxStageIndex = 0
end

function LesonBoxTip.RegisterHooks()
	GameLogic.events:AddEventListener("CreateBlockTask", LesonBoxTip.OnCreateBlockTask, LesonBoxTip, "LesonBoxTip");
    GameLogic.events:AddEventListener("DestroyBlockTask", LesonBoxTip.OnDestroyBlockTask, LesonBoxTip, "LesonBoxTip");
    GameLogic.GetFilters():add_filter("lessonbox_change_region_blocks",function(blocks)
        -- echo(commonlib.debugstack(),true)
        -- print("block num changes============",blocks and #blocks or 0)
        -- echo(blocks)
        if type(blocks) == "number" then
            LesonBoxTip.AddOperateCount(blocks)
        elseif type(blocks) == "table" then
            LesonBoxTip.AddOperateCount(#blocks)
        end
        
    end)
end

function LesonBoxTip.UnregisterHooks()
	GameLogic.events:RemoveEventListener("CreateBlockTask", LesonBoxTip.OnCreateBlockTask, LesonBoxTip);
    GameLogic.events:RemoveEventListener("DestroyBlockTask", LesonBoxTip.OnDestroyBlockTask, LesonBoxTip);
    GameLogic.GetFilters():remove_filter("lessonbox_change_region_blocks", function() end);
    LesonBoxTip.EndTip()
end

function LesonBoxTip.OnDestroyBlockTask(self,event)
    -- print("OnCreateBlockTask=================1'")
    --echo(self,true)
    -- echo(event,true)
	if(event.x) then
        LesonBoxTip.AddOperateCount()
        local startPos = LesonBoxTip.CreatePos and LesonBoxTip.CreatePos or lessonConfig.regionMy.pos
		local x, y, z = unpack(startPos);
		x, y, z = event.x - x, event.y -y, event.z-z;
        -- echo(startPos)
        -- echo(LesonBoxTip.CreatePos)
		local block = LesonBoxTip.FindBlock(x, y, z);
        -- echo(block and block[4] > 6)
		if(block) then --and block[4] == event.block_id
            LesonBoxTip.FinishBlock(x, y, z)
		end
	end
end

function LesonBoxTip.OnCreateBlockTask(self,event)
    -- print("OnCreateBlockTask=================1'")
    --echo(self,true)
    -- echo(event,true)
	if(event.x) then
        LesonBoxTip.AddOperateCount()
        local startPos = LesonBoxTip.CreatePos and LesonBoxTip.CreatePos or lessonConfig.regionMy.pos
		local x, y, z = unpack(startPos);
		x, y, z = event.x - x, event.y -y, event.z-z;
        -- echo(startPos)
        -- echo(LesonBoxTip.CreatePos)
		local block = LesonBoxTip.FindBlock(x, y, z);
        -- echo(block and block[4] > 6)
		if(block) then --and block[4] == event.block_id
            LesonBoxTip.FinishBlock(x, y, z)
		end
	end
end

function LesonBoxTip.UpdateCreateResult()

end



function LesonBoxTip.StartLearn()
    --print("StartLearn=================")
    if LessonBoxCompare and lessonConfig then
        -- GameLogic.RunCommand(string.format("/loadtemplate 18873,12,19156 %s",lessonConfig.starttemplate))
        local regionsrc = lessonConfig.regionMy
        local regiondest = lessonConfig.regionOther
        --print("StartLearn=================1")
        --echo({regionsrc,regiondest})
        LessonBoxCompare.CompareTwoAreas(regionsrc,regiondest,function(needbuild,pivotConfig)
            echo(needbuild)
            LesonBoxTip.AllNeedBuildBlock = needbuild.blocks
            LesonBoxTip.CurNeedBuildBlock = needbuild.blocks
            LesonBoxTip.CreatePos = pivotConfig.createpos
            LesonBoxTip.SrcBlockOrigin = pivotConfig.srcPivot
            LesonBoxTip.SetLessonTitle()
            compare_type = needbuild.nAddType
            if(#needbuild.blocks == 0 and needbuild.nAddType == 3)then
                local movieBlocks = needbuild.movies
                local codeBlocks = needbuild.codes
                LesonBoxTip.CompareCode(codeBlocks)
                LesonBoxTip.CompareMovie(movieBlocks)
            else
                -- LesonBoxTip.AutoEquipHandTools()
                LesonBoxTip.RegisterHooks()
                commonlib.TimerManager.SetTimeout(function()
                    LesonBoxTip.SetTaskTip("check")
                    LesonBoxTip.SetRoleName()
                    LesonBoxTip.UpdateNextBtnStatus()
                    LesonBoxTip.RenderBlockTip()
                end,200)
            end
        end)
    end
end

function LesonBoxTip.CompareCode(blocks)
    if type(blocks) == "table" then
        if #blocks == 0 then
            LesonBoxTip.RemoveErrBlockTip()
            LesonBoxTip.SetErrorTip(LesonBoxTip.m_nCorrectCount)
            GameLogic.AddBBS(nil,"当前小节已完成，你可以点击检查进入下一小节")
            commonlib.TimerManager.SetTimeout(function()
                LesonBoxTip.ClearErrorBlockTip()
                LesonBoxTip.RemoveErrBlockTip()
                LesonBoxTip.ClearBlockTip()
                -- LesonBoxTip.GotoNextStage()
                
            end,1000)
        else
            for i=1,#blocks do
                local possrc,posdest = LesonBoxTip.AddTwoPosition(blocks[i][1],LesonBoxTip.CreatePos),LesonBoxTip.AddTwoPosition(blocks[i][2],LesonBoxTip.SrcBlockOrigin)
                local entitySrc = EntityManager.GetBlockEntity(possrc)
                local entityDest = EntityManager.GetBlockEntity(posdest)
                local bSame,nType = LessonBoxCompare.CompareCode(entitySrc,entityDest)
                if not bSame then
                    
                    break
                end
            end
        end
    end
end

function LesonBoxTip.CompareMovie(blocks)
    if type(blocks) == "table" then
        if #blocks == 0 then
            LesonBoxTip.RemoveErrBlockTip()
            LesonBoxTip.SetErrorTip(LesonBoxTip.m_nCorrectCount)
            GameLogic.AddBBS(nil,"当前小节已完成，你可以点击检查进入下一小节")
            commonlib.TimerManager.SetTimeout(function()
                LesonBoxTip.ClearErrorBlockTip()
                LesonBoxTip.RemoveErrBlockTip()
                LesonBoxTip.ClearBlockTip()
                -- LesonBoxTip.GotoNextStage()
            end,1000)
        else
            for i=1,#blocks do
                local possrc,posdest = LesonBoxTip.AddTwoPosition(blocks[i][1],LesonBoxTip.CreatePos),LesonBoxTip.AddTwoPosition(blocks[i][2],LesonBoxTip.SrcBlockOrigin)
                local entitySrc = EntityManager.GetBlockEntity(possrc)
                local entityDest = EntityManager.GetBlockEntity(posdest)
                local bSame,type = LessonBoxCompare.CompareMovieClip(entitySrc,entityDest)
                if not bSame then

                    break
                end
            end
        end
    end
    -- LessonBoxCompare.CompareMovieClip
end

function LesonBoxTip.AddTwoPosition(pos1,pos2)
    if not pos1 or not pos2 then
        return 
    end
    local newPos = {}
    newPos = {pos1[1]+pos2[1],pos1[2]+pos2[2],pos1[3]+pos2[3]}
    return newPos
end

function LesonBoxTip.RenderBlockTip()
    local startPos = LesonBoxTip.CreatePos and LesonBoxTip.CreatePos or lessonConfig.regionMy.pos
    for i = 1,#LesonBoxTip.CurNeedBuildBlock do
        local block = LesonBoxTip.CurNeedBuildBlock[i]
        local x,y,z = startPos[1]+block[1],startPos[2]+block[2],startPos[3]+block[3]
        ParaTerrain.SelectBlock(x,y,z, true, groupindex_hint_auto);
        -- print("pos=========",x,y,z)
    end
end

function LesonBoxTip.ClearBlockTip()
    if not lessonConfig then
        return
    end
    local startPos = LesonBoxTip.CreatePos and LesonBoxTip.CreatePos or lessonConfig.regionMy.pos
    for i = 1,#LesonBoxTip.AllNeedBuildBlock do 
        local block = LesonBoxTip.AllNeedBuildBlock[i]
        local x,y,z = startPos[1]+block[1],startPos[2]+block[2],startPos[3]+block[3]
        ParaTerrain.SelectBlock(x,y,z, false, groupindex_hint_auto);
        -- print("ClearBlockTip===========")
    end
end

function LesonBoxTip.RenderErrorBlockTip()
    --clear
    local startPos = LesonBoxTip.CreatePos and LesonBoxTip.CreatePos or lessonConfig.regionMy.pos
    for i = 1,#LesonBoxTip.NeedChangeBlocks do 
        local block = LesonBoxTip.NeedChangeBlocks[i]
        local x,y,z = startPos[1]+block[1],startPos[2]+block[2],startPos[3]+block[3]
        ParaTerrain.SelectBlock(x,y,z, false, groupindex_wrong);
    end
    --set
    local block = LesonBoxTip.NeedChangeBlocks[checkIndex]
    if block then
        local x,y,z = startPos[1]+block[1],startPos[2]+block[2],startPos[3]+block[3]
        ParaTerrain.SelectBlock(x,y,z, true, groupindex_wrong);
        LesonBoxTip.UpdateErrArrow({block[1],block[2],block[3]})
    end    
end

function LesonBoxTip.UpdateErrArrow(pos)
    if not pos or not LesonBoxTip.CreatePos[1] or not LesonBoxTip.SrcBlockOrigin[1] then
        return
    end
    local startPos = LesonBoxTip.CreatePos and LesonBoxTip.CreatePos or lessonConfig.regionMy.pos
    local leftPos = {startPos[1]+pos[1],startPos[2]+pos[2],startPos[3]+pos[3]}
    startPos = LesonBoxTip.SrcBlockOrigin and LesonBoxTip.SrcBlockOrigin or lessonConfig.regionOther.pos
    local rightPos = {startPos[1]+pos[1],startPos[2]+pos[2],startPos[3]+pos[3]}
    GameLogic.GetCodeGlobal():BroadcastTextEvent("showArrow", {leftpos=leftPos,rightpos = rightPos});
end

function LesonBoxTip.ClearErrorBlockTip()
    if not lessonConfig then
        return
    end
    local startPos = LesonBoxTip.CreatePos and LesonBoxTip.CreatePos or lessonConfig.regionMy.pos
    for i = 1,#LesonBoxTip.NeedChangeBlocks do 
        local block = LesonBoxTip.NeedChangeBlocks[i]
        local x,y,z = startPos[1]+block[1],startPos[2]+block[2],startPos[3]+block[3]
        ParaTerrain.SelectBlock(x,y,z, false, groupindex_wrong);
    end
    GameLogic.RunCommand("/sendevent hideArrow")
end

function LesonBoxTip.FindBlock(x, y, z)
    for i = 1,#LesonBoxTip.AllNeedBuildBlock do
        local block = LesonBoxTip.AllNeedBuildBlock[i]
        if block[1] == x and block[2] == y and block[3] == z then
            return block
        end
    end
end

function LesonBoxTip.FinishBlock(x, y, z)
    for i = 1,#LesonBoxTip.CurNeedBuildBlock do
        local block = LesonBoxTip.CurNeedBuildBlock[i]
        if block[1] == x and block[2] == y and block[3] == z then
            block.finish = true
        end
    end
end

function LesonBoxTip.CheckFinishAll()
    local curOperateNum = LesonBoxTip.m_nCreateBoxCount
    -- print("num=============",LesonBoxTip.m_nCreateBoxCount,#LesonBoxTip.CurNeedBuildBlock)
    if curOperateNum >= #LesonBoxTip.CurNeedBuildBlock then
        return true
    end
    return false
    -- local isFinish = true
    -- for i = 1,#LesonBoxTip.CurNeedBuildBlock do
    --     local block = LesonBoxTip.CurNeedBuildBlock[i]
    --     if not block.finish then
    --         isFinish = false
    --         break
    --     end
    -- end
    -- return isFinish
end

function LesonBoxTip.AutoEquipHandTools()
    if not lessonConfig then
        return 
    end
    local part = {}
    for i = 1,#LesonBoxTip.AllNeedBuildBlock do
        local block = LesonBoxTip.AllNeedBuildBlock[i]
        if block and block[4] then
            part[block[4]] = block[4]
        end
    end
    local temp = {}
    for k,v in pairs(part) do
        temp[#temp + 1] = v
    end
    -- echo(temp)

    local player = EntityManager.GetPlayer();
    local count = #temp

    for idx =1, 9 do
        if(idx<=count) then
            player.inventory:SetItemByBagPos(idx, temp[idx]);
            -- print("SetItemByBagPos",idx,temp[idx])
        else
            player.inventory:SetItemByBagPos(idx, 0);
        end
    end
    player.inventory:SetHandToolIndex(1);    
end




function LesonBoxTip.SetRoleName()
    if page and lessonConfig then
        local name = lessonConfig.teacherName or "校长" 
        -- print("SetRoleName===",name)
        page:SetValue("role_name", name);
        
    end
end

function LesonBoxTip.SetTaskTip(type)
    if page then
        local strTip = LesonBoxTip.NomalTip[type]
        page:SetValue("role_tip", strTip);
        if strTip then
            SoundManager:PlayText(strTip,10006)
        end
    end
end

function LesonBoxTip.SetErrorTip(index)
    if page then
        local strTip = LesonBoxTip.CheckBLockTips[index]
        page:SetValue("role_tip", strTip);
        if strTip then
            LesonBoxTip.PlayRoleAni(index)
            SoundManager:PlayText(strTip,10006)
        end
    end
end

function LesonBoxTip.SetLessonTitle()
    if lessonConfig and page then
        local curStage = LesonBoxTip.m_nCurStageIndex
        local taskCnf = lessonConfig.taskCnf[curStage]
        local strTitle = string.format("%s步骤%d-%s",lessonConfig.stageTitle,lessonConfig.learnIndex,taskCnf.name) 
        page:SetValue("lesson_title", strTitle);
    end
end

function LesonBoxTip.ReplayMovie()
    if LesonBoxTip.CheckHasePlayMovie() or Isprepare == true then
        GameLogic.AddBBS(nil,"当前正在播放其他的动画或动画没有准备好,请稍后")
        return
    end
    LesonBoxTip.EndTip()
    local taskCnf = lessonConfig.taskCnf[LesonBoxTip.m_nCurStageIndex]
    local moivePos = taskCnf.moviePos
    if moivePos[1] then
        LesonBoxTip.ClosePage() 
        local stagePos = lessonConfig.teachStage
        if stagePos[1] then
            GameLogic.RunCommand(string.format("/goto %d,%d,%d",stagePos[1],stagePos[2],stagePos[3]))
        end
        local lookPos = lessonConfig.lookPos
        if lookPos then
            GameLogic.RunCommand(string.format("/lookat %d,%d,%d",lookPos[1],lookPos[2],lookPos[3]))
        end
        GameLogic.GetCodeGlobal():BroadcastTextEvent("playstagemovie", {config = taskCnf,isOnlyPlay = true});
    end
end
--请按照园长的讲解，在自己的区域也练习一遍吧！
function LesonBoxTip.ResumeLessonUI()
    LesonBoxTip.ShowView()
    LesonBoxTip.SetLessonTitle()
    LesonBoxTip.SetTaskTip("check")
    LesonBoxTip.SetRoleName()
    LesonBoxTip.UpdateNextBtnStatus()
    GameLogic.RunCommand("/sendevent showNpc")
    GameLogic.RunCommand("/sendevent showMask")
    local stagePos = lessonConfig.myStage
    if stagePos[1] then
        GameLogic.RunCommand(string.format("/goto %d,%d,%d",stagePos[1],stagePos[2],stagePos[3]))
    end
    GameLogic.RunCommand("/tip")
    LesonBoxTip.StartTip()
    commonlib.TimerManager.SetTimeout(function()
        LesonBoxTip.RenderBlockTip()
    end,200)
end

function LesonBoxTip.StartTip(strType)
    tip_timer = tip_timer or commonlib.Timer:new({callbackFunc = function(timer)
		GameLogic.AddBBS(nil,"请按照讲解练习一遍吧，练习好后点击按钮【开始检查】查看结果！",3000)
	end})
	tip_timer:Change(0, 10000);
end

function LesonBoxTip.EndTip()
    if tip_timer then
        tip_timer:Change()
    end
end

function LesonBoxTip.CheckHaseNextErr(nDis)
    if LesonBoxTip.NeedChangeBlocks[checkIndex + nDis] ~= nil then
        return true
    end
    return false
end

function LesonBoxTip.ClosePage() 
    if page then
        page:CloseWindow()
        page = nil
    end
    if errblock_timer then
        errblock_timer:Change()
        errblock_timer = nil
    end
    if scale_timer then
        scale_timer:Change()
        scale_timer = nil
        check_width_bak = 0
        check_height_bak = 0
    end
end

function LesonBoxTip.StartCheck()
    if check_timer then
        check_timer:Change()
    end   
    check_timer = commonlib.TimerManager.SetTimeout(function()
        if LesonBoxTip.CheckHasePlayMovie() then
            GameLogic.AddBBS(nil,"先去老师区域，看完操作演示吧")
            return
        end
        if not LesonBoxTip.CheckFinishAll() then
            if compare_type == 1  or compare_type == 3 then
                LesonBoxTip.RemoveErrBlockTip()
                LesonBoxTip.SetTaskTip("notfinish")
                compare_type = -1
                return 
            end
        end
        checkBtnType = "stop"
        LesonBoxTip.UpdateCheckBtnStatus(checkBtnType)
        LesonBoxTip.ClearBlockTip()
        LesonBoxTip.ClearErrorBlockTip()
        if LessonBoxCompare and lessonConfig then
            local regionsrc = lessonConfig.regionMy
            local regiondest = lessonConfig.regionOther
            LessonBoxCompare.CompareTwoAreas(regionsrc,regiondest,function(needbuild,pivot)
                echo(needbuild,true)
                local isCorrect = false
                local blocks = needbuild.blocks
                if needbuild.nAddType ~= 3 then
                    -- LesonBoxTip.m_nCorrectCount = 0
                    LesonBoxTip.m_nCorrectCount = LesonBoxTip.m_nCorrectCount - 1
                    LesonBoxTip.NeedChangeBlocks = blocks
                    checkIndex = 1
                    LesonBoxTip.RenderErrorBlockTip()
                    LesonBoxTip.UpdateNextBtnStatus()
                else
                    if #blocks == 0 then
                        if LesonBoxTip.m_nCorrectCount < 0 then
                            LesonBoxTip.m_nCorrectCount = 0
                        end
                        isCorrect = true
                        LesonBoxTip.m_nCorrectCount = LesonBoxTip.m_nCorrectCount + 1
                    else
                        if LesonBoxTip.m_nCorrectCount > 0 then
                            LesonBoxTip.m_nCorrectCount = 0
                        end
                        LesonBoxTip.m_nCorrectCount = LesonBoxTip.m_nCorrectCount - 1
                        LesonBoxTip.NeedChangeBlocks = blocks
                        checkIndex = 1
                        LesonBoxTip.RenderErrorBlockTip()
                        LesonBoxTip.UpdateNextBtnStatus()
                    end
                end
                if isCorrect then
                    LesonBoxTip.RemoveErrBlockTip()
                    LesonBoxTip.SetErrorTip(LesonBoxTip.m_nCorrectCount)
                    GameLogic.AddBBS(nil,"当前小节已完成，即将进入下一小节的学习")
                    commonlib.TimerManager.SetTimeout(function()
                        LesonBoxTip.ClearErrorBlockTip()
                        LesonBoxTip.RemoveErrBlockTip()
                        LesonBoxTip.ClearBlockTip()
                        LesonBoxTip.GotoNextStage()
                    end,3000)
                    return
                end
                if LesonBoxTip.m_nCorrectCount <= -5 then
                    _guihelper.MessageBox("开启教学模式，跟着帕帕卡卡拉拉一起手把手一步一步完成课程的学习吧！",function()
                        LesonBoxTip.OnStartMacroLearn()
                    end)
                end
                if LesonBoxTip.m_nCorrectCount < - 6 then LesonBoxTip.m_nCorrectCount = -6  end
                if LesonBoxTip.m_nCorrectCount > 5 then LesonBoxTip.m_nCorrectCount = 5 end
                if LesonBoxTip.m_nCorrectCount <=5 and LesonBoxTip.m_nCorrectCount >= -6 then
                    LesonBoxTip.RemoveErrBlockTip()
                    LesonBoxTip.SetErrorTip(LesonBoxTip.m_nCorrectCount)
                    LesonBoxTip.DelayShowErrBlockTip()
                    
                end
            end)
        end
    end,500)
end


function LesonBoxTip.DelayShowErrBlockTip()
    if errblock_timer then
        errblock_timer:Change();
    end
    errblock_timer = commonlib.TimerManager.SetTimeout(function ()
        LesonBoxTip.SetErrBlockTip()
    end, 3000);
end
function LesonBoxTip.UpdateCheckBtnStatus(type)
    if type then
        local back1 = "Texture/Aries/Creator/keepwork/macro/lessonbox/btn_startcheck_32bits.png;0 0 121 40"
        local back2 = "Texture/Aries/Creator/keepwork/macro/lessonbox/btn_stopcheck_32bits.png;0 0 121 40"
        local background = back1--type == "stop" and back2 or back1
        local btnObject = ParaUI.GetUIObject("lesson_check_button")
        if (btnObject) then
            --btnObject.background = background
        end
    end
end


function LesonBoxTip.UpdateCheckBtnScale(scale_dis)
    local btnObject = ParaUI.GetUIObject("lesson_check_button")
    if (btnObject and btnObject:IsValid()) then
        --备份原始大小
        local x,y
        if check_width_bak == 0 or check_height_bak == 0 then
            check_width_bak = btnObject.width
            check_height_bak = btnObject.height
            x = btnObject.x
            y = btnObject.y
        end
        local max_width = check_width_bak*1.0
        local min_width = check_width_bak*0.9
        local max_height = check_height_bak*1.0
        local min_height = check_height_bak*0.9
        local scale_state = "add"
        local scale_dis = scale_dis or 1.02
        scale_timer = commonlib.Timer:new({callbackFunc = function(timer)
            if scale_state == "add" then
                local width = btnObject.width
                local height = btnObject.height
                btnObject.width = width *scale_dis
                btnObject.height = height *scale_dis
                if btnObject.width >= max_width then
                    scale_state = "reduce"
                    check_width_bak = btnObject.width
                    check_height_bak = btnObject.height
                    x = btnObject.x
                    y = btnObject.y
                end
                btnObject.x = math.floor(x - (btnObject.width - check_width_bak) /2)
                btnObject.y = math.floor(y - (btnObject.height - check_height_bak) /2)
            end

            if scale_state == "reduce" then
                local width = btnObject.width
                local height = btnObject.height
                btnObject.width = width /scale_dis
                btnObject.height = height /scale_dis
                if btnObject.width <= min_width then
                    scale_state = "add"
                    check_width_bak = btnObject.width
                    check_height_bak = btnObject.height
                    x = btnObject.x
                    y = btnObject.y
                end
                btnObject.x = math.floor(x + (check_width_bak - btnObject.width) /2)
                btnObject.y = math.floor(y + (check_height_bak - btnObject.height) /2)
            end
        end})
        scale_timer:Change(0, 100);
    end
end

function LesonBoxTip.UpdateNextBtnStatus()
    local btnNextObject = ParaUI.GetUIObject("lesson_next_button")
    local btnPreObject = ParaUI.GetUIObject("lesson_pre_button")
    btnNextObject.visible = false
    if LesonBoxTip.CheckHaseNextErr(1) then
        btnNextObject.visible = true
    end
    btnPreObject.visible = false
    if LesonBoxTip.CheckHaseNextErr(-1) then
        btnPreObject.visible = true
    end
end

function LesonBoxTip.StopCheck()
    LesonBoxTip.ClearBlockTip()
    LesonBoxTip.ClearErrorBlockTip()
    checkIndex = 0
    LesonBoxTip.NeedChangeBlocks = {}
    LesonBoxTip.UpdateNextBtnStatus()
end

function LesonBoxTip.OnClickPre()
    if not LesonBoxTip.CheckHaseNextErr(-1) then
        GameLogic.AddBBS(nil,"没有更多的错误方块了")
        return 
    end
    checkIndex = checkIndex - 1
    LesonBoxTip.RenderErrorBlockTip()
    LesonBoxTip.UpdateNextBtnStatus()
    LesonBoxTip.SetErrBlockTip()
end

function LesonBoxTip.OnClickNext()
    if not LesonBoxTip.CheckHaseNextErr(1) then
        GameLogic.AddBBS(nil,"没有更多的错误方块了")
        return 
    end
    checkIndex = checkIndex + 1
    LesonBoxTip.RenderErrorBlockTip()
    LesonBoxTip.UpdateNextBtnStatus()
    LesonBoxTip.SetErrBlockTip()
end

--[[红色方框中的方块错了，正确的应该是【iocn】【方块名称】（编号：【方块编号】）。]]
function LesonBoxTip.SetErrBlockTip()
    if not page or not page_root or not page:IsVisible() then
        print("界面初始化失败~")
        return
    end
    local posSrc = LesonBoxTip.SrcBlockOrigin
    local block = LesonBoxTip.NeedChangeBlocks[checkIndex]
    local startPos = posSrc or lessonConfig.regionOther.pos
    if block then
        if page then
            page:SetValue("role_tip", "");
        end
        local x,y,z = startPos[1]+block[1],startPos[2]+block[2],startPos[3]+block[3]
        local blockId,blockData = BlockEngine:GetBlockIdAndData(x,y,z)
        -- print("blockId========",blockId,type(blockId),x,y,z)
        local block_item = ItemClient.GetItem(blockId);
        if blockId == 0 or block_item == nil then
            -- GameLogic.RunCommand(string.format("/goto %d %d %d",x,y,z))
            local strErrTip = string.format("红色方框里面不应该有方块，请将其清除。")
            SoundManager:PlayText(strErrTip,10006)
            local txtErrTip = ParaUI.GetUIObject("lessonbox_err_text")
            if not txtErrTip:IsValid() then
                txtErrTip = ParaUI.CreateUIObject("text", "lessonbox_err_text", "_lt", 240, 70, 330, 100);
                page_root:AddChild(txtErrTip)
            end
            txtErrTip.zorder = 3
            txtErrTip.font = "System;16;normal";
            txtErrTip.text = strErrTip;

            local imgBlock = ParaUI.GetUIObject("lessonbox_err_block")
            if imgBlock and imgBlock:IsValid() then
                ParaUI.Destroy("lessonbox_err_block")
            end
            return
        end
        local background = block_item:GetIcon(blockData):gsub("#", ";");
        local name = block_item:GetStatName()
        --print("block=========",name,background,tooltip)	
        local strErrTip = string.format("红色方框中的方块错了，正确的应该是【     】【%s】（编号：【%d】）。",name,blockId)
        SoundManager:PlayText(strErrTip,10006)
        local txtErrTip = ParaUI.GetUIObject("lessonbox_err_text")
        if not txtErrTip:IsValid() then
            txtErrTip = ParaUI.CreateUIObject("text", "lessonbox_err_text", "_lt", 240, 70, 330, 100);
            page_root:AddChild(txtErrTip)
        end
        txtErrTip.zorder = 3
        txtErrTip.font = "System;16;normal";
        txtErrTip.text = strErrTip;
        

        if background then
            local imgBlock = ParaUI.GetUIObject("lessonbox_err_block")
            if not imgBlock:IsValid() then
                imgBlock = ParaUI.CreateUIObject("button", "lessonbox_err_block", "_lt", 528, 68, 26, 26);
                page_root:AddChild(imgBlock)
            end
            imgBlock.enable = false
            imgBlock.background = background
        end
    end  
end

function LesonBoxTip.RemoveErrBlockTip()
    if page_root then
        ParaUI.Destroy("lessonbox_err_text")
        ParaUI.Destroy("lessonbox_err_block")
    end
end

function LesonBoxTip.OnStartMacroLearn()
    local taskArea = lessonConfig.stageArea
    local posTeacher = lessonConfig.templateteacher
    local posMy = lessonConfig.templatemy
    local taskCnf = lessonConfig.taskCnf[LesonBoxTip.m_nCurStageIndex]
    LesonBoxTip.ClearLearnArea(taskArea)
    LesonBoxTip.EndTip()
    commonlib.TimerManager.SetTimeout(function()
        local endTemp = taskCnf.finishtemplate
        local startTemp = taskCnf.starttemplate
        GameLogic.RunCommand(string.format("/loadtemplate %d,%d,%d %s",posTeacher[1],posTeacher[2],posTeacher[3],endTemp))
        GameLogic.RunCommand(string.format("/loadtemplate %d,%d,%d %s",posMy[1],posMy[2],posMy[3],startTemp))
        LesonBoxTip.ClearBlockTip()
        LesonBoxTip.ClearErrorBlockTip()
        LesonBoxTip.ClosePage()
        LesonBoxTip.StopStageMovie()
        GameLogic.GetCodeGlobal():BroadcastTextEvent("playFollowMacro", {macroPos = taskCnf.follow});
    end,200)
end

function LesonBoxTip.OnRetunMacro(isFinish)
    LesonBoxTip.ClosePage() 
    LesonBoxTip.UnregisterHooks()
    LesonBoxTip.ClearBlockTip()
    LesonBoxTip.ClearErrorBlockTip()
    LesonBoxTip.StopStageMovie()
    LesonBoxTip.EndTip()
    GameLogic.RunCommand("/sendevent hideNpc")
    GameLogic.RunCommand("/ggs user visible");
    GameLogic.GetCodeGlobal():BroadcastTextEvent("enterMacroMode", {isFinish = isFinish or false});
end

function LesonBoxTip.CheckHasePlayMovie()
    local MovieManager = commonlib.gettable("MyCompany.Aries.Game.Movie.MovieManager");
	if(#MovieManager.active_clips > 0) then
		return true
	end
    return false
end

function LesonBoxTip.FinishCurStageMacro()
    LesonBoxTip.GotoNextStage()
end

function LesonBoxTip.GotoNextStage()
    LesonBoxTip.ClosePage() 
    GameLogic.RunCommand("/sendevent hideNpc")
    GameLogic.RunCommand("/sendevent showMask")
    checkIndex = 0
    checkBtnType ="start"
    -- LesonBoxTip.m_nCorrectCount = 0 --连续检查正确的次数
    LesonBoxTip.m_nCreateBoxCount = 0
    LesonBoxTip.NeedChangeBlocks = {} --检查以后错误的方块
    LesonBoxTip.AllNeedBuildBlock = {} --小节开始时，所有需要创建或者删除的方块，用于备份
    LesonBoxTip.CurNeedBuildBlock = {} --当前小节需要创建或者删除的方块
    LesonBoxTip.CreatePos = nil
    LesonBoxTip.SrcBlockOrigin = nil
    LesonBoxTip.m_nCurStageIndex = LesonBoxTip.m_nCurStageIndex + 1
    --print("LesonBoxTip stage===========",LesonBoxTip.m_nCurStageIndex,LesonBoxTip.m_nMaxStageIndex,LesonBoxTip.m_nCurStageIndex )
    if LesonBoxTip.m_nCurStageIndex > LesonBoxTip.m_nMaxStageIndex then
        LesonBoxTip.m_nCurStageIndex = 0
        LesonBoxTip.m_nMaxStageIndex = 0
        -- GameLogic.AddBBS(nil,"当前步骤的所有课程已经全部完成，你可以点击下一个步骤继续学习")
        LesonBoxTip.OnRetunMacro(true)
        return 
    end
    LesonBoxTip.EndTip()
    LesonBoxTip.UpdateCheckBtnStatus(checkBtnType)
    LesonBoxTip.UpdateNextBtnStatus()
    LesonBoxTip.PrepareStageScene()
end

function LesonBoxTip.ExitLesson()
    
end


function LesonBoxTip.LockLessonArea()
    lockarea_timer = lockarea_timer or commonlib.Timer:new({callbackFunc = function(timer)
		if World2In1.GetCurrentType() == "course" then
            local player = EntityManager.GetPlayer()
            if player then
                local x, y, z = player:GetBlockPos();
                local dis = 50
                local minX, minY, minZ = 18626,3,19010;
                local maxX = minX+128 ;
                local maxZ = minZ+128*3 ;
                local newX = math.min(maxX-5, math.max(minX + 2, x));
                local newZ = math.min(maxZ-5, math.max(minZ , z));
                local newY = math.max(minY-1, y);
                if(x~=newX or y~=newY or z~=newZ) then
                    player:SetBlockPos(newX, newY, newZ)
                end
            end
        end
	end})
	lockarea_timer:Change(1000, 500);
    
end

function LesonBoxTip.EndLockArea()
    if lockarea_timer then
        lockarea_timer:Change()
        lockarea_timer = nil
    end
end

function LesonBoxTip.EndAllTimer()
    if lockarea_timer then
        lockarea_timer:Change()
        lockarea_timer = nil
    end
    if tip_timer then
        tip_timer:Change()
        tip_timer = nil
    end
    if scale_timer then
        scale_timer:Change()
        scale_timer = nil
    end
    if errblock_timer then
        errblock_timer:Change()
        errblock_timer = nil
    end
    if check_timer then
        check_timer:Change()
        check_timer = nil
    end
end

