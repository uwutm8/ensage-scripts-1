require("libs.Utils")
require("libs.ScriptConfig")

config = ScriptConfig.new()
config:SetParameter("ToggleKey", "G", config.TYPE_HOTKEY)
config:Load()

local toggleKey   = config.ToggleKey
local reg         = false
local activ       = true
local monitor     = client.screenSize.x/1600
local F15         = drawMgr:CreateFont("F15","Tahoma",15*monitor,550*monitor)
local F14         = drawMgr:CreateFont("F14","Tahoma",14*monitor,550*monitor) 
local statusText  = drawMgr:CreateText(10*monitor,530*monitor,-1,"(" .. string.char(toggleKey) .. ") Steal Aegis: Off",F14)

local hotkeyText -- toggleKey might be a keycode number, so string.char will throw an error!!
if string.byte("A") <= toggleKey and toggleKey <= string.byte("Z") then
	hotkeyText = string.char(toggleKey)
else
	hotkeyText = ""..toggleKey
end

function Key(msg,code)
	if client.chat or client.console then return end
	if IsKeyDown(toggleKey) then
		activ = not activ
		if activ then
			statusText.text = "(" .. hotkeyText .. ") Steal Aegis: On"
		else
			statusText.text = "(" .. hotkeyText .. ") Steal Aegis: Off"
		end
	end
end

function Tick(tick)
	if not SleepCheck() then return end
	sleep(125)
	if not activ then return end
	-- get our hero
	local me = entityList:GetMyHero()
	if not me then return end
	-- check if we're alive and not using any channeling spell
	if me.alive and not me:IsChanneling() then
		-- get all ground items
		local items = entityList:GetEntities({type=LuaEntity.TYPE_ITEM_PHYSICAL})
		-- search for aegis
		for i,v in ipairs(items) do
			local IH = v.itemHolds
			if IH.name == "item_aegis" and GetDistance2D(v,me) <= 150 then
				entityList:GetMyPlayer():TakeItem(v)
				Sleep(500)
				break
			end
		end
	end
end

function Roshan( kill )
    if kill.name == "dota_roshan_kill" then		
		script:RegisterEvent(EVENT_TICK,Roha)		
    end
end

script:RegisterEvent(EVENT_TICK,Tick)
script:RegisterEvent(EVENT_KEY,Key)
script:RegisterEvent(EVENT_DOTA,Roshan)
