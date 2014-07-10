	require("libs.Utils")
	require("libs.ScriptConfig")

	config = ScriptConfig.new()
	config:SetParameter("Active", "F", config.TYPE_HOTKEY)
	config:Load()

	local toggleKey = config.Active
	local reg = false
	local activerino = false
	local monitor = client.screenSize.x/1600
	local F15 = drawMgr:CreateFont("F15","Tahoma",15*monitor,550*monitor)
	local F14 = drawMgr:CreateFont("F14","Tahoma",14*monitor,550*monitor) 
	local statusText  = drawMgr:CreateText(10*monitor,560*monitor,-1,"Disable On Sight: Initiators",F14)
	local statusText2 = drawMgr:CreateText(10*monitor,560*monitor,-1,"Disable On Sight: Any Enemy",F14)


	function Key(msg,code)
		if client.chat then return end
		if IsKeyDown(toggleKey) then
			activerino = not activerino
		end
		if not activerino then
			statusText2.visible = false
			statusText.visible = true
		else
			statusText.visible = false
			statusText2.visible = true
		end
	end

	function Tick(tick)
		if not SleepCheck() then return end	Sleep(5)
		local me = entityList:GetMyHero()
		if not me then return end
		local ID = me.classId
		if ID == CDOTA_Unit_Hero_Lion then
			Disable(me,2,true)
		elseif ID == CDOTA_Unit_Hero_ShadowShaman then		
			Disable(me,2,true)
		else
			Disable(me,1,false)
		end
	end

	function Disable(me,disable,nativeHex)
		if me.alive and not me:IsChanneling() then
			local SpellDisable = me:GetAbility(disable)
			local sheepstick = me:FindItem("item_sheepstick")
			local enemies = entityList:GetEntities({type=LuaEntity.TYPE_HERO,team = 5-me.team,alive=true,visible=true,illusion=false})
			for i,v in ipairs(enemies) do
				local blink = v:FindItem("item_blink")
				local Hexed = v:IsHexed()
				local Stunned = v:IsStunned()			
				if sheepstick and sheepstick:CanBeCasted() and GetDistance2D(v,me) < 825 then
					if activerino and not Hexed and not Stunned then
						me:SafeCastItem("item_sheepstick",v)
						break
					end
					if blink and blink.cd > 11 and not Hexed and not Stunned then
						me:SafeCastItem("item_sheepstick",v)
						break
					end
				elseif nativeHex and GetDistance2D(v,me) < SpellDisable.castRange < 25 then
					if activerino and not Hexed and not Stunned then
						me:SafeCastAbility(SpellDisable,v)
						break
					end
					if blink and blink.cd > 11 and not Hexed and not Stunned then
						me:SafeCastAbility(SpellDisable,v)
						break
					end
				end
			end
		end
	end

	function Load()
		if PlayingGame() then
			statusText.visible = true
			local me = entityList:GetMyHero()
			reg = true
			script:RegisterEvent(EVENT_TICK,Tick)
			script:RegisterEvent(EVENT_KEY,Key)
			script:UnregisterEvent(Load)
		end
	end

	function GameClose()
		DisableOnSight = nil
		statusText.visible = false
		statusText2.visible = false
		collectgarbage("collect")
		if reg then
			script:UnregisterEvent(Tick)
			script:UnregisterEvent(Key)
			script:RegisterEvent(EVENT_TICK,Load)
			reg = false
		end
	end

	script:RegisterEvent(EVENT_CLOSE,GameClose)
	script:RegisterEvent(EVENT_TICK,Load)
