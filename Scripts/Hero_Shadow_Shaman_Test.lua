require("libs.Utils")
require("libs.ScriptConfig")
require("libs.Stuff")
config = ScriptConfig.new()
config:SetParameter("Active", "G", config.TYPE_HOTKEY)
config:Load()

local toggleKey   = config.Active
local reg         = false
local activ       = false
local monitor     = client.screenSize.x/1600
local F15         = drawMgr:CreateFont("F15","Tahoma",15*monitor,550*monitor)
local F14         = drawMgr:CreateFont("F14","Tahoma",14*monitor,550*monitor) 
local statusText  = drawMgr:CreateText(10*monitor,560*monitor,-1,"(" .. string.char(toggleKey) .. ") Auto Shadow Shaman: Initiators",F14) statusText.visible = false

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
			statusText.text = "(" .. hotkeyText .. ") Auto Shadow Shaman: Everyone"
		else
			statusText.text = "(" .. hotkeyText .. ") Auto Shadow Shaman: Initiators"
		end
	end

	if me:IsChanneling() and msg == RBUTTON_DOWN then return true end
end


function Tick(tick)
	if not SleepCheck() then return end	Sleep(50)
	local me = entityList:GetMyHero()
	if not me then return end

	if me.alive and not me:IsChanneling() then


		local enemies   = entityList:GetEntities({type=LuaEntity.TYPE_HERO,alive=true,visible=true,team=me:GetEnemyTeam(),illusion=false})
		for i,v in ipairs(enemies) do

			local blink    = v:FindItem("item_blink")
			local SI       = v:IsSilenced()
			local MI       = v:IsMagicImmune()
			local ST       = v:IsStunned()
			local hex      = me:GetAbility(2)
			local shackles = me:GetAbility(3)
			local serpents = me:GetAbility(4)

			if not (SI or MI) and v.health > 0 then
				if shackles:CanBeCasted() then
					if GetDistance2D(v,me) < shackles.castRange + 25 then
						if activ or (blink and blink.cd > 11) then
							me:SafeCastAbility(shackles,v)
							Sleep(300)
							break
						elseif Initiation[v.name] then
							local iSpellz = v:FindSpell(Initiation[v.name].Spell)
							local iLevelz = iSpellz.level 
							if iSpellz.level > 0 and iSpellz.cd > iSpellz:GetCooldown(iLevelz) - 1 then
								me:SafeCastAbility(shackles,v)
								Sleep(300)
								break
							end
						end
					end
				elseif hex:CanBeCasted() and GetDistance2D(v,me) < hex.castRange + 25 then
					if activ or (blink and blink.cd > 11) then
						me:SafeCastAbility(hex,v)
						Sleep(300)
						break
					elseif Initiation[v.name] then
						local iSpell = v:FindSpell(Initiation[v.name].Spell)
						local iLevel = iSpell.level 
						if iSpell.level > 0 and iSpell.cd > iSpell:GetCooldown(iLevel) - 1 then
							me:SafeCastAbility(hex,v)
							Sleep(300)
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
		if me.classId ~= CDOTA_Unit_Hero_ShadowShaman then
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
		statusText.visible = false
	end
end

script:RegisterEvent(EVENT_CLOSE,GameClose)
script:RegisterEvent(EVENT_TICK,Load)
