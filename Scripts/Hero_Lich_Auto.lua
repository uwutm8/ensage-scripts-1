require("libs.Utils")
require("libs.ScriptConfig")
config = ScriptConfig.new()
config:SetParameter("ToggleKey", "G", config.TYPE_HOTKEY)
config:Load()

local toggleKey   = config.ToggleKey
local reg         = false
local activ       = false
local disabl      = false
local monitor     = client.screenSize.x/1600
local F15         = drawMgr:CreateFont("F15","Tahoma",15*monitor,550*monitor)
local F14         = drawMgr:CreateFont("F14","Tahoma",14*monitor,550*monitor) 
local statusText  = drawMgr:CreateText(10*monitor,500*monitor,-1,"(" .. string.char(toggleKey) .. ") Auto Lich: Off",F14) statusText.visible = false

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
			statusText.text = "(" .. hotkeyText .. ") Auto Lich: On"
		else
			statusText.text = "(" .. hotkeyText .. ") Auto Lich: Off"
		end
	end
end

function Tick(tick)
	if not SleepCheck() then return end	Sleep(125)
	local me = entityList:GetMyHero()
	if not (me or activ) then return end

	if me.alive and not me:IsChanneling() then
		local icearmor   = me:GetAbility(2)
		local sacrifice  = me:GetAbility(3)
		local enemies    = entityList:GetEntities({type=LuaEntity.TYPE_HERO,team = 5-me.team,alive=true,visible=true,illusion=false})
		local allies     = entityList:GetEntities({type=LuaEntity.TYPE_HERO,team = me.team,alive=true,visible=true,illusion=false})
		local creeps     = entityList:GetEntities({classId=CDOTA_BaseNPC_Creep_Lane, alive=true, visible=true, team=me.team})

		for i,v in ipairs(allies) do
			if GetDistance2D(v,me) <= icearmor.castRange + 15 and activ and v.name ~= me.name and icearmor:CanBeCasted() and icearmor and v:DoesHaveModifier("modifier_lich_frost_armor") == false and v.alive and v.visible and not me.abilityPhase then
				me:SafeCastAbility(icearmor,v)
				Sleep(500)
				break
			end
		end

		for i,v in ipairs(creeps) do
			if GetDistance2D(v,me) <= sacrifice.castRange + 15 and activ and sacrifice and sacrifice:CanBeCasted() and v.health == v.maxHealth and not v:IsRanged() and v.spawned and v.alive and v.visible and not me.abilityPhase then
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
			statusText.text = ""
			script:Disable() 
		else
			statusText.visible = true

			reg = true
			script:RegisterEvent(EVENT_TICK,Tick)
			script:RegisterEvent(EVENT_KEY,Key)
			script:UnregisterEvent(Load)
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
