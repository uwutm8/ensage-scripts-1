require("libs.Utils")
require("libs.ScriptConfig")
config = ScriptConfig.new()
config:SetParameter("Active", "U", config.TYPE_HOTKEY)
config:SetParameter("UseDisableKey", true)
config:Load()

local toggleKey   = config.Active
local disableKey  = config.UseDisableKey
local reg         = false
local disabl      = false
local activ       = true
local monitor     = client.screenSize.x/1600
local F15         = drawMgr:CreateFont("F15","Tahoma",15*monitor,550*monitor)
local F14         = drawMgr:CreateFont("F14","Tahoma",14*monitor,550*monitor) 
local statusText  = drawMgr:CreateText(10*monitor,545*monitor,-1,"(" .. string.char(toggleKey) .. ") Auto Medallion: Off",F14)
local statusText2 = drawMgr:CreateText(10*monitor,545*monitor,-1,"(" .. string.char(toggleKey) .. ") Auto Medallion: On",F14)

function Key(msg,code)
	if client.chat or client.console then return end
	if IsKeyDown(toggleKey) then
		activ = not activ
	end
end

function Tick(tick)
	if not SleepCheck() then return end	Sleep(125)
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
		local moc     = me:FindItem("item_medallion_of_courage")
		local enemies = entityList:GetEntities({type=LuaEntity.TYPE_HERO,team = 5-me.team,alive=true,visible=true,illusion=false})
		for i,v in ipairs(enemies) do

			if GetDistance2D(v,me) <= 1000 and moc and moc:CanBeCasted() and activ and not me.abilityPhase and v.recentDamage > 0 then
				me:SafeCastItem("item_medallion_of_courage",v)
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
			statusText.visible = false
			statusText2.visible = false
			script:Disable()
		else
			reg = true
			script:RegisterEvent(EVENT_TICK,Tick)
			script:RegisterEvent(EVENT_KEY,Key)
			script:UnregisterEvent(Load)
		end
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
