require("libs.Utils")
require("libs.ScriptConfig")
require("libs.Stuff")
config = ScriptConfig.new()
config:SetParameter("Active", "U", config.TYPE_HOTKEY)
config:SetParameter("UseDisableKey", true)
config:Load()

local toggleKey   = config.Active
local disableKey  = config.UseDisableKey
local reg         = false
local disabl      = false
local activ       = false
local monitor     = client.screenSize.x/1600
local F15         = drawMgr:CreateFont("F15","Tahoma",15*monitor,550*monitor)
local F14         = drawMgr:CreateFont("F14","Tahoma",14*monitor,550*monitor) 
local statusText  = drawMgr:CreateText(10*monitor,530*monitor,-1,"(" .. string.char(toggleKey) .. ") Auto Hex: Off",F14)

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
			statusText.text = "(" .. hotkeyText .. ") Auto Hex: On"
		else
			statusText.text = "(" .. hotkeyText .. ") Auto Hex: Off"
		end
	end
end

function Tick(tick)
	if not SleepCheck() then return end	Sleep(50)
	local me = entityList:GetMyHero()
	if not me then return end

	local DisableKey = 0x20

	if IsKeyDown(DisableKey) and disableKey then
		disabl = true
	else
		disabl = false
	end

	if disabl then
		statusText.text = "(" .. hotkeyText .. ") Auto Hex: Off"
	end

	if me.alive and not me:IsChanneling() then

		local ID = me.classId
		if ID == CDOTA_Unit_Hero_Lion then
			Disable(me,2,"lion_voodoo")
		elseif ID == CDOTA_Unit_Hero_ShadowShaman then		
			Disable(me,2,"shadow_shaman_voodoo")
		else
			Disable(me,nil,nil)
		end
	end
end

function Disable(me,disable,nativeSpell)
	local sheep     = me:FindItem("item_sheepstick")
	local enemies   = entityList:GetEntities({type=LuaEntity.TYPE_HERO,team = 5-me.team,alive=true,visible=true,illusion=false})
	for i,v in ipairs(enemies) do
		local blink = v:FindItem("item_blink")
		local SI    = v:IsSilenced()
		local MI    = v:IsMagicImmune()

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
					if iSpell and iSpell.cd > iSpell:GetCooldown(iLevel) - 1 then
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
						if iSpell and iSpell.cd > iSpell:GetCooldown(iLevel) - 1 then
							me:SafeCastAbility(disable1,v)
							Sleep(500)
							break
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
