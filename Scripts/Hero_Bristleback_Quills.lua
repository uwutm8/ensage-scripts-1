require("libs.Utils")
require("libs.ScriptConfig")
config = ScriptConfig.new()
config:SetParameter("Active", "G", config.TYPE_HOTKEY)
config:Load()

local toggleKey   = config.Active
local reg         = false
local activ       = false
local monitor     = client.screenSize.x/1600
local F14         = drawMgr:CreateFont("F14","Tahoma",14*monitor,550*monitor) 
local statusText  = drawMgr:CreateText(10*monitor,560*monitor,-1,"(" .. string.char(toggleKey) .. ") Bristleback: Off",F14) statusText.visible = false

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
			statusText.text = "(" .. hotkeyText .. ") Bristleback: Auto Quills"
		else
			statusText.text = "(" .. hotkeyText .. ") Bristleback: Off"
		end
	end
end

function Tick(tick)
	if not SleepCheck() then return end	Sleep(50)
	local me = entityList:GetMyHero()
	if not me then return end
	local invis    = me:IsInvisible()

	if me.alive and not (me:IsChanneling() and invis) then

		local enemies   = entityList:GetEntities({type=LuaEntity.TYPE_HERO,alive=true,visible=true,team=me:GetEnemyTeam(),illusion=false})

		for i,v in ipairs(enemies) do

			local AI       = v:IsAttackImmune()
			local quill    = me:GetAbility(2)

			if activ and (v.health >= 0) and not (AI) then
				if quill and quill:CanBeCasted() and GetDistance2D(v,me) <= quill.castRange - 25 then
					me:SafeCastAbility(quill)
					Sleep(300)
					break
				end
			end
		end
	end
end

function Load()
	if PlayingGame() then
		local me = entityList:GetMyHero()
		if me.classId ~= CDOTA_Unit_Hero_Bristleback then
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
