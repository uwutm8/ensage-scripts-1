require("libs.Utils")
require("libs.ScriptConfig")
config = ScriptConfig.new()
config:SetParameter("ToggleKey", "G", config.TYPE_HOTKEY)
config:Load()

local toggleKey   = config.ToggleKey
local reg         = false
local activ		  = false
local effect      = nil
local monitor     = client.screenSize.x/1600
local F15         = drawMgr:CreateFont("F15","Tahoma",15*monitor,550*monitor)
local F14         = drawMgr:CreateFont("F14","Tahoma",14*monitor,550*monitor) 
local statusText  = drawMgr:CreateText(10*monitor,560*monitor,-1,"(" .. string.char(toggleKey) .. ") TA: Off",F14) statusText.visible = false
local blah = false

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
			statusText.text = "(" .. hotkeyText .. ") TA: On"
		else
			effect = nil
			statusText.text = "(" .. hotkeyText .. ") TA: Off"
		end
	end
end

function Tick(tick)
	if not SleepCheck() then return end	Sleep(30)
	local me = entityList:GetMyHero()
	if not (me and activ) then return end
	local enemies = entityList:GetEntities({type=LuaEntity.TYPE_HERO,team = 5-me.team,alive=true,visible=true,illusion=false})

	psy = me:GetAbility(3)
	psyrange = {60,120,180,240}
	bonus = psyrange[psy.level]
	effect = Effect(me,"range_display")

	if bonus == nil and blah == false then
		blah = true
		effect:SetVector(1,Vector(me.attackRange,0,0))
	elseif bonus ~= nil
		effect:SetVector(1,Vector(me.attackRange + bonus,0,0))
	end

	for i,v in ipairs(enemies) do

		local visible1,screenPos1 = client:ScreenPosition(me.position);
		local visible2,screenPos2 = client:ScreenPosition(v.position);

		if visible1 and visible2 then
			drawMgr:CreateLine(screenPos1.x,screenPos1.y, screenPos2.x, screenPos2.y,0x0080FFFF)
		end
	end
end


function Load()
	if PlayingGame() then
		local me = entityList:GetMyHero()
		if me.classId ~= CDOTA_Unit_Hero_TemplarAssassin then 
			script:Disable() 
		else
			statusText.visible = true
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
		effect = nil
		statusText.visible = false
	end
end

script:RegisterEvent(EVENT_CLOSE,GameClose)
script:RegisterEvent(EVENT_TICK,Load)
