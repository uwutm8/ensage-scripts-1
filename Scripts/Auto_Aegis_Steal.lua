-[[Auto_Aegis_Steal.lua Props to Moones for helping create this!]]-
require("libs.Utils")
require("libs.ScriptConfig")
config = ScriptConfig.new()
config:SetParameter("ToggleKey", "G", config.TYPE_HOTKEY)
config:SetParameter("UseDisableKey", true)
config:Load()

local toggleKey   = config.ToggleKey
local disableKey  = config.UseDisableKey
local reg         = false
local activ       = true
local disabl      = false
local monitor     = client.screenSize.x/1600
local F15         = drawMgr:CreateFont("F15","Tahoma",15*monitor,550*monitor)
local F14         = drawMgr:CreateFont("F14","Tahoma",14*monitor,550*monitor) 
local statusText  = drawMgr:CreateText(10*monitor,530*monitor,-1,"(" .. string.char(toggleKey) .. ") Steal Aegis: Off",F14)
local statusText2 = drawMgr:CreateText(10*monitor,530*monitor,-1,"(" .. string.char(toggleKey) .. ") Steal Aegis: On",F14)

function Key(msg,code)
	if client.chat or client.console then return end
	if IsKeyDown(toggleKey) then
		activ = not activ
	end
end

function Tick(tick)
	if not SleepCheck() then return end
	local me = entityList:GetMyHero()
	if not me then return end

	local DisableKey = 0x20

	if IsKeyDown(DisableKey) and disableKey then
		disabl = true
	else
		disabl = false
	end

	if disabl or not activ then
		statusText2.visible = false
		statusText.visible  = true
	else
		statusText.visible  = false
		statusText2.visible = true
	end

	if me.alive and not me:IsChanneling() then
		local items = entityList:GetEntities({type=LuaEntity.TYPE_ITEM_PHYSICAL})

		for i,v in ipairs(items) do
			local IH = v.itemHolds
			if IH.name == "item_aegis" and GetDistance2D(v,me) < 2000 and activ then
				entityList:GetMyPlayer():TakeItem(v)
				Sleep(500)
				break
			end
		end
	end
end

function Load()
	if PlayingGame() then
		local me = entityList:GetMyHero()
		if not me then
			statusText.visible  = false
			statusText2.visible = false
			script:Disable() 
		else
			reg = true
			script:RegisterEvent(EVENT_TICK,Tick)
			script:RegisterEvent(EVENT_KEY,Key)
			script:UnregisterEvent(Load)
		end
	else
		statusText.visible  = false
		statusText2.visible  = false

	end
end

function GameClose()
	if reg then
		script:UnregisterEvent(Tick)
		script:UnregisterEvent(Key)
		script:RegisterEvent(EVENT_TICK,Load)
		reg = false
	end
	collectgarbage("collect")
end

script:RegisterEvent(EVENT_CLOSE,GameClose)
script:RegisterEvent(EVENT_TICK,Load)
