require("libs.Utils")
require("libs.ScriptConfig")
require("libs.Stuff")
config = ScriptConfig.new()
config:SetParameter("Active", "P", config.TYPE_HOTKEY)
config:Load()

local toggleKey   = config.Active
local monitor     = client.screenSize.x/1600
local F15         = drawMgr:CreateFont("F15","Tahoma",15*monitor,550*monitor)
local F14         = drawMgr:CreateFont("F14","Tahoma",14*monitor,550*monitor)
local reg         = false

local activ       = true
local statusText  = drawMgr:CreateText(10*monitor,500*monitor,-1,"(" .. string.char(toggleKey) .. ") Auto Euls: On",F14) statusText.visible = false

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
			statusText.text = "(" .. hotkeyText .. ") Auto Euls: On"
		else
			statusText.text = "(" .. hotkeyText .. ") Auto Euls: Off"
		end
	end
end

function Tick(tick)
	if not SleepCheck() then return end	Sleep(30)
	local me = entityList:GetMyHero()
	if not (me and activ) then return end
	if me.alive and not me:IsChanneling() then
		local euls    = me:FindItem("item_cyclone")
		if euls then
			statusText.visible = true
		end
		local enemies = entityList:GetEntities({type=LuaEntity.TYPE_HERO,team = 5-me.team,alive=true,visible=true,illusion=false})
		for i,v in ipairs(enemies) do
			local MI = v:IsMagicImmune()
			local ST = v:IsStunned()
			local invis    = me:IsInvisible()

			local blink = v:FindItem("item_blink")
			if not (MI or ST or invis) then
				if GetDistance2D(v,me) <= 700 + 25 and euls and euls:CanBeCasted() and blink and (blink:CanBeCasted() or blink.cd > 11) then
					me:SafeCastItem("item_cyclone",v)
					Sleep(500)
					break
				elseif Initiation[v.name] and not MI then
					local iSpell =  v:FindSpell(Initiation[v.name].Spell)
					local iLevel = iSpell.level 
					if iSpell.level > 0 and iSpell.cd > iSpell:GetCooldown(iLevel) - 1 then
						me:SafeCastItem("item_cyclone",v)
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
