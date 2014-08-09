--[[Steal
    earth spirit combo, spectre(Haunt->reality illusion closest to aegis->steal->spectral dagger out)

    Steal with vision
    if sniper/rattletrap providing vision, use jugg ult, etc

   	Deny
	auto spawn veno ward and deny
    lycan(auto deny by invis wolves), broodmother(army of broodmother's spiders), enigma(army of demonic conversions),
    invoker(spirits),lone druid(bear),naga(illusions),np(nature call),pl(illusions),shadowshaman(serpent ward),
    sniper(shrapnel, deny),terrorblade(illusions),veno(wards),visage(familiars),warlock(chaotic offering rosh pit, then deny),

    if 6 slotted then auto deny]]

    	require("libs.Utils")
    	require("libs.ScriptConfig")

    	local config = ScriptConfig.new()
    	config:SetParameter("ToggleKey", "J", config.TYPE_HOTKEY)
    	config:Load()

    	local toggleKey  = config.ToggleKey
    	local activ      = false
    	local monitor    = client.screenSize.x/1600
    	local F14        = drawMgr:CreateFont("F14","Tahoma",14*monitor,550*monitor) 
    	local statusText = drawMgr:CreateText(10*monitor,590*monitor,-1,"(" .. string.char(toggleKey) .. ") Auto Aegis: Off",F14) statusText.visible = false
    	local EmberRosh  = 0
    	local aegisloc   = Vector(2413.25,-239.313,4.1875)
    	local shortloc   = Vector(2515,-124,3)

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
			statusText.text = "(" .. hotkeyText .. ") Auto Aegis: On"
		else
			statusText.text = "(" .. hotkeyText .. ") Auto Aegis: Off"
		end
	end
end

function Tick(tick)
	if not IsIngame() or not SleepCheck() then return end	
	local me = entityList:GetMyHero()
	if not me then return end	
	local ID    = me.classId
	local blink = me:FindItem("item_blink")
	if blink then
		statusText.visible = true
	end
	if ID == CDOTA_Unit_Hero_EmberSpirit or ID == CDOTA_Unit_Hero_AntiMage or ID == CDOTA_Unit_Hero_Rattletrap or ID == CDOTA_Unit_Hero_FacelessVoid or ID == CDOTA_Unit_Hero_Magnataur or ID == CDOTA_Unit_Hero_SandKing or ID == CDOTA_Unit_Hero_QueenOfPain or ID == CDOTA_Unit_Hero_Morphling or ID == CDOTA_Unit_Hero_Naga_Siren or ID == CDOTA_Unit_Hero_StormSpirit or ID == CDOTA_Unit_Hero_Sniper or ID == CDOTA_Unit_Hero_Venomancer then
		statusText.visible = true
	end
	if not activ then return end
	if me.alive and not me:IsChanneling() then
		local items = entityList:GetEntities({type=LuaEntity.TYPE_ITEM_PHYSICAL})
		for i,v in ipairs(items) do
			local IH = v.itemHolds
			if IH.name == "item_aegis" and GetDistance2D(v,me) <= 400 then
				entityList:GetMyPlayer():TakeItem(v)
				break
			end
		end
		if EmberRosh == 1 then
			local sleight = me:GetAbility(2)
			if sleight:CanBeCasted() then
				Sleep(50,"two")
				EmberRosh = 2
			else
				EmberRosh = 0
			end
		elseif EmberRosh == 2 then
			local sleight = me:GetAbility(2)
			if not sleight:CanBeCasted() then
				EmberRosh = 0
			elseif SleepCheck("two") then
				me:CastAbility(sleight,shortloc)
				EmberRosh = 0
			end
		end
	end
end

function Roshan (kill)
	if PlayingGame() then
		local me    = entityList:GetMyHero()
		local blink = me:FindItem("item_blink")
		local ID    = me.classId
		if kill.name == "dota_roshan_kill" and activ then
			if GetDistance2D(aegisloc,me) <= 1200 and blink and blink.cd == 0 then		
				me:SafeCastItem(blink.name,aegisloc)
			elseif ID == CDOTA_Unit_Hero_EmberSpirit and GetDistance2D(shortloc,me) <= 700 then
				EmberRosh = 1
			elseif ID == CDOTA_Unit_Hero_AntiMage and GetDistance2D(aegisloc,me) <= 1150 then
				local amblink = me:GetAbility(2)
				if amblink:CanBeCasted() then
					me:SafeCastAbility(amblink,aegisloc)
				end
			elseif ID == CDOTA_Unit_Hero_Rattletrap and GetDistance2D(aegisloc,me) <= 2000 then
				local hook = me:GetAbility(4)
				if hook:CanBeCasted() then
					me:SafeCastAbility(hook,aegisloc)
				end
			elseif ID == CDOTA_Unit_Hero_FacelessVoid and GetDistance2D(aegisloc,me) <= 1300 then
				local timewalk = me:GetAbility(1)
				if timewalk:CanBeCasted() then
					me:SafeCastAbility(timewalk,aegisloc)
				end
			elseif ID == CDOTA_Unit_Hero_Magnataur and GetDistance2D(aegisloc,me) <= 1200 then
				local skewer = me:GetAbility(3)
				if skewer:CanBeCasted() then
					me:SafeCastAbility(skewer,aegisloc)
				end
			elseif ID == CDOTA_Unit_Hero_SandKing and GetDistance2D(aegisloc,me) <= 650 then
				local burrow = me:GetAbility(1)
				if burrow:CanBeCasted() then
					me:SafeCastAbility(burrow,shortloc)
				end
			elseif ID == CDOTA_Unit_Hero_QueenOfPain and GetDistance2D(aegisloc,me) <= 1150 then
				local qopblink = me:GetAbility(2)
				if qopblink:CanBeCasted() then
					me:SafeCastAbility(qopblink,aegisloc)
				end
			elseif ID == CDOTA_Unit_Hero_Morphling and GetDistance2D(aegisloc,me) <= 1000 then
				local waveform = me:GetAbility(1)
				if waveform:CanBeCasted() then
					me:SafeCastAbility(waveform,aegisloc)
				end
			elseif ID == CDOTA_Unit_Hero_Naga_Siren and GetDistance2D(aegisloc,me) <= 1250 then
				local sirensong = me:GetAbility(4)
				if sirensong:CanBeCasted() then
					me:SafeCastAbility(sirensong,aegisloc)
				end
			elseif ID == CDOTA_Unit_Hero_StormSpirit and GetDistance2D(aegisloc,me) <= 1000 then
				local ball = me:GetAbility(4)
				if ball:CanBeCasted() then
					me:SafeCastAbility(ball,aegisloc)
				end
			elseif ID == CDOTA_Unit_Hero_Sniper then
				local takeaim = me:GetAbility(3)
				aimrange = {100,200,300,400}
				bonus = 0
				if takeaim and takeaim.level > 0 then
					bonus = aimrange[takeaim.level]
				end
				if GetDistance2D(aegisloc,me) <= me.attackRange + bonus then
					local items = entityList:GetEntities({type=LuaEntity.TYPE_ITEM_PHYSICAL})
					for i,v in ipairs(items) do
						local IH = v.itemHolds
						if IH.name == "item_aegis" then
							me:Attack(v.itemHolds)
							break
						end
					end
				end
			elseif ID == CDOTA_Unit_Hero_Venomancer then
				local plagueward = me:GetAbility(3)
				local ward = entityList:GetEntities({classId=CDOTA_BaseNPC_Venomancer_PlagueWard,alive = true,visible = true,controllable=true})
				local items = entityList:GetEntities({type=LuaEntity.TYPE_ITEM_PHYSICAL})

				if plagueward:CanBeCasted() then
					me:SafeCastAbility(plagueward,shortloc)
					for i,v in ipairs(items) do
						for l,k in ipairs(ward) do
							local IH = v.itemHolds
							if IH.name == "item_aegis" and GetDistance2D(v,me) <= k.castRange then
								k:Attack(v)
							end
						end
					end
				end
			end
		end
	end
end

function GameClose()
	collectgarbage("collect")
	script:UnregisterEvent(Roshan)
	script:UnregisterEvent(Key)
	script:UnregisterEvent(Tick)
	statusText.visible = false
end

script:RegisterEvent(EVENT_TICK,Tick)
script:RegisterEvent(EVENT_KEY,Key)
script:RegisterEvent(EVENT_DOTA,Roshan)
script:RegisterEvent(EVENT_CLOSE,GameClose)
