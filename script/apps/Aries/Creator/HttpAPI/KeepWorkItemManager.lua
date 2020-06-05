--[[
Title: KeepWorkItemManager
Author(s): leio
Date: 2020/4/24
Desc:  
use the lib:

using cmd parameter "kpitem_enabled" to debug:
local kpitem_enabled = ParaEngine.GetAppCommandLineByParam("kpitem_enabled", false);

KeepWorkItemManager for an authorized user
please login first
-------------------------------------------------------
local KeepWorkItemManager = NPL.load("(gl)script/apps/Aries/Creator/HttpAPI/KeepWorkItemManager.lua");
KeepWorkItemManager.Load(true, function()
    commonlib.echo("=====KeepWorkItemManager.globalstore");
    commonlib.echo(KeepWorkItemManager.globalstore);
    commonlib.echo("=====KeepWorkItemManager.extendedcost");
    commonlib.echo(KeepWorkItemManager.extendedcost);
    commonlib.echo("=====KeepWorkItemManager.bags");
    commonlib.echo(KeepWorkItemManager.bags);
    commonlib.echo("=====KeepWorkItemManager.items");
    commonlib.echo(KeepWorkItemManager.items);
end)

echo(KeepWorkItemManager.GetItemTemplate(10004),true)

local bags_number = KeepWorkItemManager.SearchBagsNoFromExid(10001)
echo("==========bags_number");
echo(bags_number);

KeepWorkItemManager.DoExtendedCost(10001)
-------------------------------------------------------
]]
NPL.load("(gl)script/ide/System/Core/Filters.lua");
local Filters = commonlib.gettable("System.Core.Filters");

NPL.load("(gl)script/apps/Aries/Creator/HttpAPI/KeepWorkAPI.lua");
local GameLogic = commonlib.gettable("MyCompany.Aries.Game.GameLogic")

local KeepWorkItemManager = NPL.export()

KeepWorkItemManager.globalstore_map = {};
KeepWorkItemManager.globalstore = {};
KeepWorkItemManager.extendedcost_map = {};
KeepWorkItemManager.extendedcost = {};
KeepWorkItemManager.bags = {};
KeepWorkItemManager.bags_map = {};
KeepWorkItemManager.items = {};
KeepWorkItemManager.profile = {};
KeepWorkItemManager.loaded = false;
KeepWorkItemManager.filter = nil;

function KeepWorkItemManager.IsEnabled()
    local kpitem_enabled = ParaEngine.GetAppCommandLineByParam("kpitem_enabled", false);
    return kpitem_enabled;
end

function KeepWorkItemManager.StaticInit()
    if(not KeepWorkItemManager.IsEnabled())then
        return
    end
	LOG.std(nil, "info", "KeepWorkItemManager", "StaticInit");
    if(not KeepWorkItemManager.filter)then
        KeepWorkItemManager.filter = Filters:new();
    end
    GameLogic.GetFilters():add_filter("OnKeepWorkLogin", KeepWorkItemManager.OnKeepWorkLogin_Callback);
	GameLogic.GetFilters():add_filter("OnKeepWorkLogout", KeepWorkItemManager.OnKeepWorkLogout_Callback)
end
function KeepWorkItemManager.GetFilter()
    return KeepWorkItemManager.filter;
end
function KeepWorkItemManager.OnKeepWorkLogin_Callback(res)
	LOG.std(nil, "info", "KeepWorkItemManager", "OnKeepWorkLogin_Callback");
    KeepWorkItemManager.Load(true, function()
        commonlib.echo("=====KeepWorkItemManager.globalstore");
        commonlib.echo(KeepWorkItemManager.globalstore);
        commonlib.echo("=====KeepWorkItemManager.extendedcost");
        commonlib.echo(KeepWorkItemManager.extendedcost);
        commonlib.echo("=====KeepWorkItemManager.bags");
        commonlib.echo(KeepWorkItemManager.bags);
        commonlib.echo("=====KeepWorkItemManager.items");
        commonlib.echo(KeepWorkItemManager.items);
    end)            
    return res;
end
function KeepWorkItemManager.OnKeepWorkLogout_Callback(res)
	LOG.std(nil, "info", "KeepWorkItemManager", "OnKeepWorkLogout_Callback");
    KeepWorkItemManager.Clear();
    return res;
end

function KeepWorkItemManager.Clear()
    KeepWorkItemManager.globalstore_map = {};
    KeepWorkItemManager.globalstore = {};
    KeepWorkItemManager.extendedcost_map = {};
    KeepWorkItemManager.extendedcost = {};
    KeepWorkItemManager.bags = {};
    KeepWorkItemManager.bags_map = {};
    KeepWorkItemManager.items = {};
    KeepWorkItemManager.profile = {};
    KeepWorkItemManager.loaded = false;
end
function KeepWorkItemManager.GetToken()
    local User = commonlib.gettable('System.User');
    return System.User.keepworktoken;
end
--[[
{
  createdAt="2020-04-24T01:29:46.000Z",
  desc="222",
  endTime="2020-05-28T16:00:00.000Z",
  exId=11,
  exchangeCosts={
    {
      amount=3,
      goods={
        bagId=1,
        canHandsel=true,
        canTrade=true,
        canUse=true,
        coins=1111,
        createdAt="2020-03-13T02:43:32.000Z",
        dayMax=11,
        deleted=false,
        desc="23123",
        destoryAfterUse=true,
        expiredRules=1,
        gsId=5,
        icon="http://www.baidu.com",
        id=2,
        max=11,
        name="������Ʒ",
        price=111,
        stackable=true,
        typeId=3,
        updatedAt="2020-03-13T02:43:32.000Z",
        weekMax=11 
      },
      id=2 
    } 
  },
  exchangeTargets={
    {
      goods={
        {
          amount=1,
          goods={ bagId=2, id=4, ... },
          id=4 
        } 
      },
      probability=100 
    } 
  },
  greedy=true,
  id=10,
  name="22",
  preconditions={
    {
      amount=4,
      goods={ ... },
      id=2,
      op="lt" 
    } 
  },
  startTime="2020-04-22T16:00:00.000Z",
  storage=3,
  updatedAt="2020-04-24T01:29:55.000Z" 
}
--]]
function KeepWorkItemManager.GetExtendedCostTemplate(exid)
    if(not exid)then
        return
    end
    exid = tonumber(exid)
    local template = KeepWorkItemManager.extendedcost_map[exid];
    if(template)then
        return template;
    end
    for k,v in ipairs(KeepWorkItemManager.extendedcost) do
        if( v.exId == exid)then
            KeepWorkItemManager.extendedcost_map[exid] = v;
            return v;
        end
    end
end

-- get conditions in a extendedcost
-- @param exid: the id of extendedcost 
-- return precondition,cost,goal
function KeepWorkItemManager.GetConditions(exid)
    local precondition = KeepWorkItemManager.GetPrecondition(exid);
    local cost = KeepWorkItemManager.GetCost(exid);
    local goal = KeepWorkItemManager.GetGoal(exid);
    return precondition,cost,goal
end
function KeepWorkItemManager.GetPrecondition(exid)
    local template = KeepWorkItemManager.GetExtendedCostTemplate(exid);
    if(template)then
        return template.preconditions;
    end
end
function KeepWorkItemManager.GetCost(exid)
    local template = KeepWorkItemManager.GetExtendedCostTemplate(exid);
    if(template)then
        return template.exchangeCosts;
    end
end
function KeepWorkItemManager.GetGoal(exid)
    local template = KeepWorkItemManager.GetExtendedCostTemplate(exid);
    if(template)then
        return template.exchangeTargets;
    end
end

--[[
{
  bagId=2,
  canHandsel=false,
  canTrade=false,
  canUse=true,
  coins=999999999999,
  createdAt="2020-05-21T06:54:00.000Z",
  dayMax=1,
  deleted=false,
  desc="����볡ȯ",
  destoryAfterUse=true,
  expiredRules=1,
  expiredSeconds=0,
  gsId=10004,
  icon="Texture/Aries/Item/1022_LargeLollipop.png",
  id=13,
  max=7,
  name="����볡ȯ",
  price=999999999999,
  stackable=true,
  typeId=3,
  updatedAt="2020-05-21T06:54:00.000Z",
  weekMax=2 
}
--]]
function KeepWorkItemManager.GetItemTemplate(gsid)
    gsid = tonumber(gsid)
    local template = KeepWorkItemManager.globalstore_map[gsid];
    if(template)then
        return template;
    end
    for k,v in ipairs(KeepWorkItemManager.globalstore) do
        if( v.gsId == gsid)then
            KeepWorkItemManager.globalstore_map[gsid] = v;
            return v;
        end
    end
end
function KeepWorkItemManager.GetItem(guid)
    guid = tonumber(guid)
    for k,v in ipairs(KeepWorkItemManager.items) do
        if( v.goodsId == guid)then
            return v;
        end
    end
end
function KeepWorkItemManager.IsLoaded()
    return KeepWorkItemManager.loaded;
end
function KeepWorkItemManager.Load(bForced, callback)
    if(not bForced and KeepWorkItemManager.IsLoaded())then
        if(callback)then
            callback();
        end            
        return
    end
    KeepWorkItemManager.GetFilter():apply_filters("loading", L"����GlobalStore");
    KeepWorkItemManager.LoadGlobalStore(true, function()
        KeepWorkItemManager.GetFilter():apply_filters("loading", L"����ExtendedCost");
        KeepWorkItemManager.LoadExtendedCost(true, function()
            KeepWorkItemManager.GetFilter():apply_filters("loading", L"���ر���");
            KeepWorkItemManager.LoadBags(true, function()
                KeepWorkItemManager.GetFilter():apply_filters("loading", L"������Ʒ");
                KeepWorkItemManager.LoadItems(nil, function()
                    KeepWorkItemManager.GetFilter():apply_filters("loading", L"����������Ϣ");
                    KeepWorkItemManager.LoadProfile(true, function()
                        KeepWorkItemManager.loaded = true;
                        if(callback)then
                            callback();
                        end            
                        KeepWorkItemManager.GetFilter():apply_filters("loading", L"�������");
                        KeepWorkItemManager.GetFilter():apply_filters("loaded_all");
                    end)
                end)
            end)
        end)
    end)
end
function KeepWorkItemManager.LoadGlobalStore(bForced, callback)
    local cache_policy;
    if(bForced)then
        cache_policy = "access plus 0";
    end
    keepwork.globalstore.get({
        cache_policy = "access plus 0";
    },function(err, msg, data)
        echo("==============KeepWorkItemManager.LoadGlobalStore");
        echo(err);
        echo(data);
        if(err ~= 200)then
            return
        end
        if(data and data.data and data.data.rows)then
            KeepWorkItemManager.globalstore = data.data.rows;
        echo("==============KeepWorkItemManager.LoadGlobalStore 2");

            if(callback)then
        echo("==============KeepWorkItemManager.LoadGlobalStore 3");
                callback();
            end
        end
    end)
end

function KeepWorkItemManager.LoadExtendedCost(bForced, callback)
    local cache_policy;
    if(bForced)then
        cache_policy = "access plus 0";
    end
    keepwork.extendedcost.get({
        cache_policy = cache_policy,
    },function(err, msg, data)
        if(err ~= 200)then
            return
        end
        if(data and data.data and data.data.rows)then
            KeepWorkItemManager.extendedcost = data.data.rows;

            if(callback)then
                callback();
            end
        end
    end)
end
--[[
{
  data={
    count=2,
    rows={
      {
        bagNo=1001,
        createdAt="2020-06-01T07:14:07.000Z",
        deleted=false,
        desc="���û���ʾ��������������Ʒ",
        id=4,
        name="��ʾ��Ʒ",
        updatedAt="2020-06-01T07:14:25.000Z" 
      },
      {
        bagNo=1002,
        createdAt="2020-06-01T07:15:07.000Z",
        deleted=false,
        desc="�����û���ʾ�ı������Ʒ",
        id=5,
        name="������Ʒ",
        updatedAt="2020-06-01T07:15:07.000Z" 
      } 
    } 
  },
  message="����ɹ�" 
}
--]]
function KeepWorkItemManager.LoadBags(bForced, callback)
    local cache_policy;
    if(bForced)then
        cache_policy = "access plus 0";
    end
    keepwork.bags.get({
        cache_policy = cache_policy,
    },function(err, msg, data)
        if(err ~= 200)then
            return
        end
        if(data and data.data and data.data.rows)then
            KeepWorkItemManager.bags = data.data.rows;

            for k,v in ipairs(KeepWorkItemManager.bags) do
                KeepWorkItemManager.bags_map[v.id] = v;
            end

            if(callback)then
                callback();
            end
        end
    end)
end
--[[
{
    "message": "����ɹ�",
    "data": [
        {
            "id": 477,
            "userId": 238,
            "goodsId": 19,
            "expireTime": "9999-12-31T23:59:59.000Z",
            "clientData": null,
            "serverData": null,
            "copies": 1,
            "gsId": 10,
            "bagId": 5
        }
    ]
}
--]]
-- @param bagNos: nil to load all, "1001,1002" to load specific bags by bag number
function KeepWorkItemManager.LoadItems(bagNos, callback, error_callback)
    keepwork.items.get({
        bagNos = bagNos,
        cache_policy = "access plus 0", -- no cache
    },function(err, msg, data)
        echo("=========KeepWorkItemManager.LoadItems");
        echo(err)
        echo(msg)
        echo(data)
        if(err ~= 200)then
            if(error_callback)then
                error_callback(err, msg, data)
            end
            return
        end
        if(data and data.data)then
            KeepWorkItemManager.items = data.data;

            if(callback)then
                callback();
            end
        end
    end)
end
-- http://yapi.kp-para.cn/project/32/interface/api/492               
function KeepWorkItemManager.GetProfile()
    return KeepWorkItemManager.profile or {};
end
-- load profile of logined user
function KeepWorkItemManager.LoadProfile(bForced, callback)
    local cache_policy;
    if(bForced)then
        cache_policy = "access plus 0";
    end
    keepwork.user.profile({
        cache_policy = cache_policy,
    },function(err, msg, data)
        if(err ~= 200)then
            return
        end
        if(data)then
            KeepWorkItemManager.profile = data;
            if(callback)then
                callback();
            end
        end
    end)
end
-- check if the user has the global store item in inventory
-- @param {number} gsid: global store id
-- @return bOwn, guid, bag, copies, item
function KeepWorkItemManager.HasGSItem(gsid)
    if(not gsid)then
        return
    end
    gsid = tonumber(gsid)
    if(gsid > 0)then
        for k,v in ipairs(KeepWorkItemManager.items) do
            if( v.gsId == gsid)then
                local copies = v.copies or 0;
                local bOwn = false;
                if(copies > 0)then
                    bOwn = true;
                end
                return bOwn, v.id, v.bagId, copies, v;
            end    
        end
    end
end
-- union copies in gsid_list
function KeepWorkItemManager.UnionCopies(gsid_list)
    gsid_list = gsid_list or {};
    local copies_all = 0;
    for k,v in ipairs(gsid_list) do
        local gsid = v.gsid;
		local hasItem, guid, bag, copies = KeepWorkItemManager.HasGSItem(gsid);
        copies = copies or 0;
        copies_all = copies_all + copies;
    end
    return copies_all;
end

function KeepWorkItemManager.DoExtendedCost(exid, callback, error_callback)
    if(not exid)then
        return
    end
    local profile = KeepWorkItemManager.GetProfile()
    local userId = profile.id;
    keepwork.items.exchange({
        userId = userId, 
        exId = exid,
    },function(err, msg, data)
        if(err == 200)then

            local bags_number = KeepWorkItemManager.SearchBagsNoFromExid(exid);
            echo("=========bags_number");
            echo(bags_number);
            local len = #bags_number;
            if(len > 0)then
                local s = "";
                for k,v in ipairs(bags_number) do
                    if(s == "")then
                        s = v;
                    else
                        s = string.format("%s,%s",s,v);
                    end
                end
                echo("=========s");
                echo(s);
                -- reload items data 
                KeepWorkItemManager.LoadItems(s,callback, error_callback)
                return
            end
            if(callback)then
                callback();
            end
        else
            if(error_callback)then
                error_callback(err, msg, data);
            end
        end
    end)
end
function KeepWorkItemManager.SetClientData(gsid, clientdata, callback, error_callback)
    local bOwn, guid, bag, copies, item = KeepWorkItemManager.HasGSItem(gsid)
    if(not bOwn)then
        return
    end
    keepwork.items.setClientData({
        userGoodsId = guid,
        clientdata,
    },function(err, msg, data)
        commonlib.echo("==========setClientData");
        commonlib.echo(err);
        commonlib.echo(msg);
        commonlib.echo(data);
        if(err == 200)then
            --synchronize data to memory 
            item.clientData = clientData;
            if(callback)then
                callback();
            end
        else
            if(error_callback)then
                error_callback(err, msg, data);
            end
        end
    end)
end
-- search all bag number in a extendedcost for update item data
-- NOTE: bagNo isn't bagId
function KeepWorkItemManager.SearchBagsNoFromExid(exid)
    if(not exid)then
        return
    end
    local bags_id = {};
    local bags_id_map = {};
    local function read_ids(data)
        if(data)then
            for k,v in ipairs(data) do
                echo(v);
                if(v.goods and v.goods.bagId)then
                    local bagId = v.goods.bagId;
                    local bagNo = KeepWorkItemManager.SearchBagNo(bagId)
                    bags_id_map[bagNo] = bagNo;
                end
            end 
        end
    end
    local precondition,cost,goal = KeepWorkItemManager.GetConditions(exid);
    echo("=========precondition");
    echo(precondition);
    echo(cost);
    echo(goal);
    read_ids(precondition)
    read_ids(cost)
    if(goal)then
        for k,v in ipairs(goal) do
            read_ids(v.goods)
        end
    end
    for k,v in pairs(bags_id_map) do
        table.insert(bags_id,v);
    end
    return bags_id;
end
function KeepWorkItemManager.SearchBagNo(bagId)
    if(not bagId)then
        return
    end
    local bag = KeepWorkItemManager.bags_map[bagId];
    if(bag)then
        return bag.bagNo; 
    end
end