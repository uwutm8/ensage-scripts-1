require("libs.Utils")
require("libs.ScriptConfig")
config = ScriptConfig.new()
config:SetParameter("ToggleKey", "G", config.TYPE_HOTKEY)
config:Load()

local toggleKey   = config.ToggleKey
local reg         = false
local activ		  = true
local monitor     = client.screenSize.x/1600
local F14         = drawMgr:CreateFont("F14","Tahoma",14*monitor,550*monitor) 
local statusText  = drawMgr:CreateText(10*monitor,560*monitor,-1,"(" .. string.char(toggleKey) .. ") TA: On",F14) statusText.visible = false
local lastLevel = -1 -- last level we created the attack range circle before
local effect = nil -- attack range circle
local bonus = 0 -- save bonus range of psy blades
local bonus2 = 0 -- save spill range of psy blades
local width = 0 -- save spill width
local lines = {} -- save lines for every enemy hero
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
			statusText.text = "(" .. hotkeyText .. ") TA: On"
		else
			effect = nil
			statusText.text = "(" .. hotkeyText .. ") TA: Off"
			collectgarbage("collect") -- to remove the old attack circle!
		end
	end
end

function Tick(tick)
	if not SleepCheck() then return end	Sleep(30)
	local me = entityList:GetMyHero()
	if not (me and activ) then return end
	-- only enable the script for TA
	if me.classId ~= CDOTA_Unit_Hero_TemplarAssassin then 
		script:Disable() 
		return
	else
		statusText.visible = true
	end
	-- get our spell
	local psy = me:GetAbility(3)
	if not psy then
		Sleep(1000)
		return
	end
	local currentLevel = psy.level
	-- if we haven't created an effect for the current level -> do it! (also save stats)
	if lastLevel ~= currentLevel then
		-- if attack range is not set yet...
		if me.attackRange == 0 then	return end

		lastLevel = currentLevel
		if currentLevel == 0 then
			bonus = 0
			bonus2 = 0
			width = 0
		else
			bonus = psy:GetSpecialData("bonus_attack_range",currentLevel)
			bonus2 = psy:GetSpecialData("attack_spill_range",currentLevel)
			width = psy:GetSpecialData("attack_spill_width",currentLevel)
		end
		-- create effect
		effect = Effect(me,"range_display")
		effect:SetVector(1,Vector(me.attackRange + bonus,0,0))
		collectgarbage("collect") -- to remove the old attack circle!
	end
	-- get enemy heroes
	local enemies = entityList:GetEntities({type=LuaEntity.TYPE_HERO,team = me:GetEnemyTeam(),illusion=false})
	local nearestEnemy = nil
	local nearestDistance = nil
	local validEnemies = {}
	for i,v in ipairs(enemies) do
		local handle = v.handle
		-- hide line if enemy is not visible or dead
		local distance = GetDistance2D(v,me)
		if distance >= (me.attackRange + bonus + bonus2) or not v.visible or not v.alive then
			if lines[handle] then lines[handle].visible = false end
		else
			-- check if we are visible
			local visible1,screenPos1 = client:ScreenPosition(me.position);
			if visible1 then
				local visible2,screenPos2 = client:ScreenPosition(v.position);
				-- check if enemy is visible
				if visible2 then
					-- if we have no line yet, then add one
					if not lines[handle] then
						lines[handle] = drawMgr:CreateLine(screenPos1.x,screenPos1.y, screenPos2.x, screenPos2.y,0xFF99FFFF)
					else
						-- update the current line
						lines[handle].visible = true
						lines[handle]:SetPosition(screenPos1,screenPos2)
					end
					-- check for width then
					table.insert(validEnemies,v)
					if not nearestEnemy or distance < nearestDistance then
						nearestEnemy = v
						nearestDistance = distance
					end
				else
					-- hide line if enemy is not on screen
					if lines[handle] then lines[handle].visible = false end
				end
			else
				-- hide line if we're not on the screen
				if lines[handle] then lines[handle].visible = false end
			end
		end
	end
	-- change color of line if width is okay
	if nearestEnemy then
		for _,v in ipairs(validEnemies) do
			local handle = v.handle
			-- nearest enemy is always "valid"
			if v == nearestEnemy then
				lines[handle].color = 0xFF99FFFF
			-- if angle is below the width then it will hit the enemy
			elseif AngleBelow(me,nearestEnemy,v,5.5) then
				lines[handle].color = 0xFF99FFFF
			-- else mark it in another color
			else
				lines[handle].color = 0x6D76F2FF
			end
		end
	end
end

function AngleBelow(myHero,nearestHero,targetHero,angle)
	local myPos = Vector2D(myHero.position.x,myHero.position.y)
	local nearestHeroPos = Vector2D(nearestHero.position.x,nearestHero.position.y)
	local targetHeroPos = Vector2D(targetHero.position.x,targetHero.position.y)
	local t1 = (nearestHeroPos - myPos)
	local t2 = (targetHeroPos - myPos)
	return math.abs(math.deg(math.atan2(t2.y, t2.x) - math.atan2(t1.y, t1.x))) <= angle
end

function GameClose()
	-- kill the effect
	effect = nil
	-- kill all known lines
	lines = {}
	collectgarbage("collect")
	-- reset variables
	lastLevel = -1
end


script:RegisterEvent(EVENT_CLOSE,GameClose)
script:RegisterEvent(EVENT_TICK,Tick)
script:RegisterEvent(EVENT_KEY,Key)
