require("libs.Utils")
require("libs.ScriptConfig")
config = ScriptConfig.new()
config:SetParameter("ToggleKey", "G", config.TYPE_HOTKEY)
config:Load()

local toggleKey   = config.ToggleKey
local reg         = false
local activ		  = true
local monitor     = client.screenSize.x/1600
local F15         = drawMgr:CreateFont("F15","Tahoma",15*monitor,550*monitor)
local F14         = drawMgr:CreateFont("F14","Tahoma",14*monitor,550*monitor) 
local statusText  = drawMgr:CreateText(10*monitor,560*monitor,-1,"(" .. string.char(toggleKey) .. ") TA: On",F14) statusText.visible = false
level0 = false
level1 = false
level2 = false
level3 = false
level4 = false
effect = nil
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
			level0 = false
			level1 = false
			level2 = false
			level3 = false
			level4 = false
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


	if bonus == nil and level0 == false and psy.level == 0 then
		effect = Effect(me,"range_display")
		effect:SetVector(1,Vector(me.attackRange,0,0))
		level0 = true
	elseif bonus ~= nil and level1 == false and psy.level == 1 then
		effect = nil
		effect = Effect(me,"range_display")
		effect:SetVector(1,Vector(me.attackRange + bonus,0,0))
		level1 = true
	elseif bonus ~= nil and level2 == false and psy.level == 2 then

		effect = nil
		effect = Effect(me,"range_display")
		effect:SetVector(1,Vector(me.attackRange + bonus,0,0))
		level2= true
	elseif bonus ~= nil and level3 == false and psy.level == 3 then
		effect = nil
		effect = Effect(me,"range_display")
		effect:SetVector(1,Vector(me.attackRange + bonus,0,0))
		level3 = true
	elseif bonus ~= nil and level4 == false and psy.level == 4 then
		effect = nil
		effect = Effect(me,"range_display")
		effect:SetVector(1,Vector(me.attackRange + bonus,0,0))
		level4 = true
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
		level0 = false
		level1 = false
		level2 = false
		level3 = false
		level4 = false
		statusText.visible = false
	end
end

script:RegisterEvent(EVENT_CLOSE,GameClose)
script:RegisterEvent(EVENT_TICK,Load)
