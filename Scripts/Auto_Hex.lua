require("libs.Utils")
require("libs.ScriptConfig")
require("libs.Stuff")
config = ScriptConfig.new()
config:SetParameter("Active", "U", config.TYPE_HOTKEY)
config:Load()

local toggleKey   = config.Active
local reg         = false
local activ       = false
local monitor     = client.screenSize.x/1600
local F15         = drawMgr:CreateFont("F15","Tahoma",15*monitor,550*monitor)
local F14         = drawMgr:CreateFont("F14","Tahoma",14*monitor,550*monitor) 
local statusText  = drawMgr:CreateText(10*monitor,290*monitor,-1,"(" .. string.char(toggleKey) .. ") Auto Hex: Initators",F14) statusText.visible = false


local hotkeyText
if string.byte("A") <= toggleKey and toggleKey <= string.byte("Z") then
	hotkeyText = string.char(toggleKey)
else
	hotkeyText = ""..toggleKey
end

function Key(msg,code)
	if client.chat or client.console or client.loading then return end
	local me = entityList:GetMyHero()

	if IsKeyDown(toggleKey) then
		activ = not activ
		if activ then
			statusText.text = "(" .. hotkeyText .. ") Auto Hex: Everyone"
		else
			statusText.text = "(" .. hotkeyText .. ") Auto Hex: Initators"
		end
	end
end

function Tick(tick)
	local me = entityList:GetMyHero()

	if not SleepCheck() then return end	Sleep(50)
	if not me then return end
	if me.alive and not me:IsChanneling() then

		local ID = me.classId
		if ID == CDOTA_Unit_Hero_Lion then
			Disable(me,2,"lion_voodoo",1,"lion_impale")
		elseif ID == CDOTA_Unit_Hero_ShadowShaman then
			Disable(me,2,"shadow_shaman_voodoo",3,"shadow_shaman_shackles")
		else
			Disable(me,nil,nil,nil,nil)
		end
	end
end

function Disable(me,disable,nativeSpell,disable2,nativeSpell2)
	local sheep     = me:FindItem("item_sheepstick")
	local ID = me.classId

	local enemies   = entityList:GetEntities({type=LuaEntity.TYPE_HERO,team = 5-me.team,alive=true,visible=true,illusion=false})
	if ID == (CDOTA_Unit_Hero_Lion or CDOTA_Unit_Hero_ShadowShaman) or sheep then
		statusText.visible = true
	end
	for i,v in ipairs(enemies) do
		local blink = v:FindItem("item_blink")
		local SI    = v:IsSilenced()
		local MI    = v:IsMagicImmune()
			local invis    = me:IsInvisible()

		if not (SI or MI or invis) then
			if GetDistance2D(v,me) < 800 and sheep and sheep:CanBeCasted() then
				if activ then
					me:SafeCastItem("item_sheepstick",v)
					Sleep(500)
					break
				end
				if blink and blink.cd > 11 then
					me:SafeCastItem("item_sheepstick",v)
					Sleep(500)
					break
				end
				if Initiation[v.name] then
					local iSpell =  v:FindSpell(Initiation[v.name].Spell)
					local iLevel = iSpell.level 
					if iSpell.level > 0 and iSpell.cd > iSpell:GetCooldown(iLevel) - 1 then
						me:SafeCastItem("item_sheepstick",v)
						Sleep(500)
						break
					end
				end
			end

			if disable ~= nil then
				local disable1  = me:GetAbility(disable)
				local SpellFind = me:FindAbility(nativeSpell)

				if SpellFind:CanBeCasted() and GetDistance2D(v,me) < disable1.castRange then
					if activ then
						me:SafeCastAbility(disable1,v)
						Sleep(500)
						break
					end
					if blink and blink.cd > 11 then
						me:SafeCastAbility(disable1,v)
						Sleep(500)
						break
					end
					if Initiation[v.name] then
						local iSpell = v:FindSpell(Initiation[v.name].Spell)
						local iLevel = iSpell.level 
						if iSpell.level > 0 and iSpell.cd > iSpell:GetCooldown(iLevel) - 1 then
							me:SafeCastAbility(disable1,v)
							Sleep(500)
							break
						end
					end
				end
			end
			if disable2 ~= nil then
				local disable2x  = me:GetAbility(disable2)
				local SpellFindz = me:FindAbility(nativeSpell2)

				if SpellFindz:CanBeCasted() and GetDistance2D(v,me) < disable2x.castRange then
					if activ then
						me:SafeCastAbility(disable2x,v)
						Sleep(500)
						break
					end
					if blink and blink.cd > 11 then
						me:SafeCastAbility(disable2x,v)
						Sleep(500)
						break
					end
					if Initiation[v.name] then
						local iSpellz = v:FindSpell(Initiation[v.name].Spell)
						local iLevelz = iSpellz.level 
						if iSpellz.level > 0 and iSpellz.cd > iSpellz:GetCooldown(iLevelz) - 1 then
							me:SafeCastAbility(disable2x,v)
							Sleep(500)
							break
						end
					end
				end
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
