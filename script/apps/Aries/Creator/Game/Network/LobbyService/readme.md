# Lobby Service Design

- date: 2018.12.19
- author: LiXizhi

## Introduction
UDP lobby will automatically connect to one another in Intranet, when user signed in to a game world with `registerNetworkEvent`. 
After peers are discovered, they communicate via TCP on the same port. 

## Code Block network design:


```lua
registerNetworkEvent("updateScore", function(msg)
     showVariable(msg.nid, msg.score)
end)

broadcastNetworkEvent("updateScore", {score = 100})

registerNetworkEvent("connect|disconnect", function(msg)
    tip(msg.nid.." joined | left ")
end)
```

������������3��������ʵ��ΪĿ�꣬ ����һ���汾���� 
ֻҪ�û�д��registerNetworkEvent���Զ�����+�㲥����������ϷID�����ӡ� 
ʹ�������ProjectID���������ֵ�CRC32��Ϊ��ϷID�� 

δ����ʱ�䣬�����г�������������С��Ϸ��UI