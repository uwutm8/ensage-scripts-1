require("libs.Utils")
require("libs.ScriptConfig")

config = ScriptConfig.new()
config:SetParameter("Active", "H", config.TYPE_HOTKEY)
config:Load()

local toggleKey = config.Active
local activ = false
local monitor = client.screenSize.x/1600
local F14 = drawMgr:CreateFont("F14","Tahoma",14*monitor,550*monitor) 
local statusText = drawMgr:CreateText(10*monitor,605*monitor,-1,"(" .. string.char(toggleKey) .. ") Auto Orchid: Blinkers",F14) statusText.visible = false

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
			statusText.text = "(" .. hotkeyText .. ") Auto Orchid: All"
		else
			statusText.text = "(" .. hotkeyText .. ") Auto Orchid: Blinkers"
		end
	end
end

function Tick(tick)
	if PlayingGame() then
		local me = entityList:GetMyHero()
		if not me then 
			script:Disable()
		else
			if me.alive and not me:IsChanneling() then
				local orchid = me:FindItem("item_orchid")
				if orchid then
					statusText.visible = true
				end
				local enemies = entityList:GetEntities({type=LuaEntity.TYPE_HERO,team = 5-me.team,alive=true,visible=true,illusion=false})
				for i,v in ipairs(enemies) do
					local MI = v:IsMagicImmune()
					local invis = me:IsInvisible()
					local blink = v:FindItem("item_blink")

					if not (MI and invis) and orchid and orchid:CanBeCasted() and GetDistance2D(v,me) <= 900 + 25 then
						if blink and blink.cd > 11 then
							me:SafeCastItem("item_orchid",v)
							break
						elseif activ then
							me:SafeCastItem("item_orchid",v)
							break
						elseif Initiation[v.name] then
							local iSpell =  v:FindSpell(Initiation[v.name].Spell)
							local iLevel = iSpell.level 
							if iSpell.level > 0 and iSpell.cd > iSpell:GetCooldown(iLevel) - 1 then
								me:SafeCastItem("item_orchid",v)
								break
							end
						end
					end
				end
			end
		end
	end
end

script:RegisterEvent(EVENT_TICK,Tick)
script:RegisterEvent(EVENT_KEY,Key)
