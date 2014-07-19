require("libs.Utils")
require("libs.ScriptConfig")
config = ScriptConfig.new()
config:SetParameter("ToggleKey", "G", config.TYPE_HOTKEY)
config:SetParameter("UseDisableKey", true)
config:Load()

local toggleKey   = config.ToggleKey
local disableKey  = config.UseDisableKey
local reg         = false
local activ		  = false
local disabl      = false
local monitor     = client.screenSize.x/1600
local F15         = drawMgr:CreateFont("F15","Tahoma",15*monitor,550*monitor)
local F14         = drawMgr:CreateFont("F14","Tahoma",14*monitor,550*monitor) 
local statusText  = drawMgr:CreateText(10*monitor,530*monitor,-1,"(" .. string.char(toggleKey) .. ") Auto Lich: Off",F14)
local statusText2 = drawMgr:CreateText(10*monitor,530*monitor,-1,"(" .. string.char(toggleKey) .. ") Auto Lich: On",F14)

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
		local icearmor   = me:GetAbility(2)
		local sacrifice  = me:GetAbility(3)
		local enemies    = entityList:GetEntities({type=LuaEntity.TYPE_HERO,team = 5-me.team,alive=true,visible=true,illusion=false})
		local allies     = entityList:GetEntities({type=LuaEntity.TYPE_HERO,team = me.team,alive=true,visible=true,illusion=false})
		local creeps     = entityList:GetEntities({classId=CDOTA_BaseNPC_Creep_Lane, alive=true, visible=true, team=me.team})

		for i,v in ipairs(allies) do
			if GetDistance2D(v,me) <= icearmor.castRange and activ and v.name ~= me.name and icearmor:CanBeCasted() and icearmor and v:DoesHaveModifier("modifier_lich_frost_armor") == false and v.alive and v.visible and not me.abilityPhase then
				me:SafeCastAbility(icearmor,v)
				Sleep(500)
				break
			end
		end

		for i,v in ipairs(creeps) do
			if GetDistance2D(v,me) <= sacrifice.castRange and activ and sacrifice and sacrifice:CanBeCasted() and v.health == v.maxHealth and not v:IsRanged() and v.spawned and v.alive and v.visible and not me.abilityPhase then
				me:SafeCastAbility(sacrifice,v)
				Sleep(500)
				break
			end
		end
	end
end

function Load()
	if PlayingGame() then
		local me = entityList:GetMyHero()
		if me.classId ~= CDOTA_Unit_Hero_Lich then 
			statusText.visible  = false
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
