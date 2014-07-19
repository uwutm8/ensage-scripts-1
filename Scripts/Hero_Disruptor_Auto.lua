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
local statusText  = drawMgr:CreateText(10*monitor,530*monitor,-1,"(" .. string.char(toggleKey) .. ") Auto Disruptor: Off",F14)
local statusText2 = drawMgr:CreateText(10*monitor,530*monitor,-1,"(" .. string.char(toggleKey) .. ") Auto Disruptor: On",F14)

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
		local glimpse = me:GetAbility(2)
		local kfield  = me:GetAbility(3)
		local static  = me:GetAbility(4)
		local enemies = entityList:GetEntities({type=LuaEntity.TYPE_HERO,team = 5-me.team,alive=true,visible=true,illusion=false})

		for i,v in ipairs(enemies) do
			local tp      = v:FindItem("item_tpscroll")
			local stunned = v:FindModifier("modifier_stunned")

			if GetDistance2D(v,me) <= glimpse.castRange and glimpse and glimpse:CanBeCasted() and activ and not me.abilityPhase then
				if (tp and tp.cd > 56) or v:DoesHaveModifier("modifier_fountain_aura_buff") == true or v:DoesHaveModifier("modifier_teleporting") == true then
					me:SafeCastAbility(glimpse,v)
					Sleep(500)
					break
				end
			end

			if GetDistance2D(v,me) <= kfield.castRange and kfield and kfield:CanBeCasted() and activ and not me.abilityPhase then
				if GetDistance2D(v,me) <= static.castRange and static and static:CanBeCasted() and activ and not me.abilityPhase then
					if stunned and stunned.remainingTime >= 1 then
						me:SafeCastAbility(static,v.position)
						me:SafeCastAbility(kfield,v.position)
						Sleep(500)
						break
					end
				end
			end
			if GetDistance2D(v,me) <= kfield.castRange and kfield and kfield:CanBeCasted() and activ and not me.abilityPhase then
				if stunned and stunned.remainingTime <= 1 then
					me:SafeCastAbility(kfield,v.position)
					Sleep(500)
					break
				end
			end
		end
	end
end

function Load()
	if PlayingGame() then
		local me = entityList:GetMyHero()
		if me.classId ~= CDOTA_Unit_Hero_Disruptor then 
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
