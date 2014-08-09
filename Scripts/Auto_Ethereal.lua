require("libs.Utils")
require("libs.ScriptConfig")
config = ScriptConfig.new()
config:SetParameter("Active", "N", config.TYPE_HOTKEY)
config:Load()

local toggleKey   = config.Active
local reg         = false
local activ       = true
local monitor     = client.screenSize.x/1600
local F15         = drawMgr:CreateFont("F15","Tahoma",15*monitor,550*monitor)
local F14         = drawMgr:CreateFont("F14","Tahoma",14*monitor,550*monitor) 
local statusText  = drawMgr:CreateText(10*monitor,245*monitor,-1,"(" .. string.char(toggleKey) .. ") Auto Ethereal: On",F14) statusText.visible = false

local hotkeyText
if string.byte("A") <= toggleKey and toggleKey <= string.byte("Z") then
	hotkeyText = string.char(toggleKey)
else
	hotkeyText = ""..toggleKey
end

function Key(msg,code)
	if client.chat or client.console or client.loading then return end
	if IsKeyDown(toggleKey) then
		activ = not activ
		if activ then
			statusText.text = "(" .. hotkeyText .. ") Auto Ethereal: On"
		else
			statusText.text = "(" .. hotkeyText .. ") Auto Ethereal: Off"
		end
	end
end

function Tick(tick)
	if not IsIngame() or not SleepCheck() then return end Sleep(30)
	local me = entityList:GetMyHero()
	if not me then return end	
	if not activ then return end	
	local eth = me:FindItem("item_ethereal_blade")
	if not eth then return end
	if me.alive and not me:IsChanneling() then

		statusText.visible = true

		local enemies = entityList:GetEntities({type=LuaEntity.TYPE_HERO,team = 5-me.team,alive=true,visible=true,illusion=false})
		for i,v in ipairs(enemies) do
			local invis    = me:IsInvisible()

			if GetDistance2D(v,me) <= 800 and eth and eth:CanBeCasted() and activ and not invis then
				me:SafeCastItem("item_ethereal_blade",v)
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
	collectgarbage("collect")
	if reg then
		script:UnregisterEvent(Tick)
		script:UnregisterEvent(Key)
		script:RegisterEvent(EVENT_TICK,Load)
		reg = false
		statusText.visible = false
	end
end

script:RegisterEvent(EVENT_CLOSE,GameClose)
script:RegisterEvent(EVENT_TICK,Load)
