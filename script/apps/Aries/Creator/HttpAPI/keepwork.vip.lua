--[[
Title: keepwork.vip
Author(s): leio
Date: 2021/7/9
Desc:  
Use Lib:
-------------------------------------------------------
NPL.load("(gl)script/apps/Aries/Creator/HttpAPI/keepwork.vip.lua");
]]
local HttpWrapper = NPL.load("(gl)script/apps/Aries/Creator/HttpAPI/HttpWrapper.lua");

-- ��ȡ��Ʒ��Ϣ
--http://yapi.kp-para.cn/project/32/interface/api/3687
-- post
HttpWrapper.Create("keepwork.pay.searchVipProducts", "%MAIN%/core/v0/pay/systemProducts/search", "POST", true)


-- ��ȡ��������
-- ����֧����ɺ�Ҫ��ѯȥ��ȡ������״̬����������״̬ state ���� 2 ����3ʱ����Ϊ֧���ɹ���ǰ�����������Ĵ���
--http://yapi.kp-para.cn/project/32/interface/api/1512
-- get
HttpWrapper.Create("keepwork.pay.systemOrders", "%MAIN%/core/v0/pay/systemOrders/:id", "GET", true)

-- ����c��vip
--http://yapi.kp-para.cn/project/32/interface/api/1527
-- post
HttpWrapper.Create("keepwork.pay.clientVip", "%MAIN%/core/v0/pay/clientVip", "POST", true)


-- �����ά����������
--http://yapi.kp-para.cn/project/88/interface/api/4302
-- ���ɶ�ά��
--http://yapi.kp-para.cn/project/32/interface/api/3682
-- post 
HttpWrapper.Create("keepwork.pay.generateQR", "%MAIN%/core/v0/keepworks/generateQR", "POST", true)