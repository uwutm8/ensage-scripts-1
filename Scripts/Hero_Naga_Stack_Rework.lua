require("libs.Utils")
require("libs.ScriptConfig")

config = ScriptConfig.new()
config:SetParameter("ToggleKey", "G", config.TYPE_HOTKEY)
config:Load()

local toggleKey   = config.ToggleKey
local monitor     = client.screenSize.x/1600
local reg         = false
local activ       = false
local F15         = drawMgr:CreateFont("F15","Tahoma",15*monitor,550*monitor)
local F14         = drawMgr:CreateFont("F14","Tahoma",14*monitor,550*monitor) 
local statusText  = drawMgr:CreateText(10*monitor,530*monitor,-1,"(" .. string.char(toggleKey) .. ") Naga Stack: Off",F14)


local hotkeyText -- toggleKey might be a keycode number, so string.char will throw an error!!
if string.byte("A") <= toggleKey and toggleKey <= string.byte("Z") then
	hotkeyText = string.char(toggleKey)
else
	hotkeyText = ""..toggleKey
end

-- SCRIPT SETTINGS
local sleep = 50
local x0,y0=5,50      -- gui pos
-- STACKING SETTINGS
local n_cycles = 8                            -- number of stack cycles
local start_time = 49                         -- game time seconds when start to stack (from wait point)


local radiant_bot_tower = Vector(4705,-6112,256)
local radiant_mid_tower = Vector(-1574,-1394,127)
local radiant_top_tower = Vector(-5922,1780,256)

local dire_bot_tower = Vector(6108,-1827,256)
local dire_mid_tower = Vector(954,469,128)
local dire_top_tower = Vector(-4810,6186,256)
-- 
local stack_route_direa = {Vector(5083,-1433,127),Vector(4447,-1950,127), Vector(-3040,3360,256)}      -- triangle route for dire  1:pull point, 2: fountain, 3: wait point )
local stack_route_direa2 = {Vector(4311,-1011,127),Vector(4536,-1930,127), Vector(6975,6742,256)}      
local stack_route_dire1 = {Vector(-4863,4253,256),Vector(-4443,3521,256), Vector(1302,5150,256)}  -- triangle route for radiant ( 1:wait, 2: pull, 3: die )
local stack_route_dire2 = {Vector(-3147,5459,256),Vector(-3057,4596,256), Vector(-32,1687,271)}
local stack_route_dire3 = {Vector(-1818,3382,129),Vector(-1478,2608,127), Vector(5334,-4183,256)}
local stack_route_dire4 = {Vector(708,5140,256),Vector(-304,3893,256), Vector(2258,4324,127)}
local stack_route_dire5 = {Vector(441,4030,256),Vector(1176,3337,256), Vector(2637,4384,128)}

local stack_route_direwait = {Vector(3936,-3296,256),Vector(3936,-3296,256), Vector(3936,-3296,256)}  -- 


--stack_route_radianta = {Vector(-2144,-480,256),Vector(-2991,198,256), Vector(512,-5595,256)}
local stack_route_radianta = {Vector(-2080,416,256),Vector(-2991,198,256), Vector(-7264,-6752,270)}
local stack_route_radianta2 = {Vector(-2144,-480,256),Vector(-2948,250,256), Vector(512,-5595,256)}

local stack_route_radiant1 = {Vector(-1327,-2701,127),Vector(-1174,-4023,127), Vector(-3540,-3054,127)}  -- triangle route for radiant ( 1:wait, 2: pull, 3: die )
local stack_route_radiant2 = {Vector(1503,-2785,256),Vector(-449,-2927,127), Vector(-641,-1263,127)}  -- 
local stack_route_radiant3 = {Vector(1662,-4964,256),Vector(1675,-3714,256), Vector(-459,4735,256)}  -- 
local stack_route_radiant4 = {Vector(3936,-3296,256),Vector(3165,-3459,256), Vector(1939,-2334,101)}  -- 
local stack_route_radiant5 = {Vector(4238,-4811,256),Vector(3065,-4672,256), Vector(3754,-6369,256)}  -- 

local p1=nil
--GLOBALS
local activ = false
local melocation = nil
local dude1route =nil
local dude2route =nil
local dude3route =nil

local route = nil
local creep = nil
local do_stack = false
local sleeptick = nil
local msg = nil -- msg = { TEXT, TICK, TIME, SIZE, COLOR, X, Y }
local order_tick = nil
local anc = nil
local pressed = false
local stack_n = 0
local currentSelection = nil
local count = 1
local dude1=nil
local dude2=nil
local dude3=nil

function Key(msg,code)
	if client.chat or client.console then return end
	if IsKeyDown(toggleKey) then
		activ = not activ
		if activ then
			statusText.text = "(" .. hotkeyText .. ") Naga Stack: On"
msg = {"naga creep off. ", tick, 4000, 24, 0xFF0000FF} --old
else
	statusText.text = "(" .. hotkeyText .. ") Naga Stack: Off"
msg = {"naga creep on. ", tick, 4000, 24, 0xFF0000FF} --old
end
end
end

function Tick( tick )

	local me = entityList:GetMyHero()

	if client.chat or client.console then return end
	if not me then return end

	if me.name == nil then return end
	if sleepTick and sleepTick > tick then return end
--if me.team == TEAM_RADIANT then home = radiant else home = dire end

if activ then

if client.gameTime % 60 == 30 then-- and (do_stack) then 
	for t=1,6 do
		if me:GetAbility(t) and me:GetAbility(t).name == "naga_siren_mirror_image" and me:GetAbility(t).state == STATE_READY then
			me:SafeCastAbility(me:GetAbility(t))
			sleepTick= GetTick() +300
			return 
		end
	end

end

for t=1,6 do
	local iSpell =  me:FindSpell("naga_siren_mirror_image")
	local iLevel = iSpell.level 

	if me:GetAbility(t).name == "naga_siren_mirror_image" then

		if math.ceil(me:GetAbility(t).cd - 0.7) <=  math.ceil(iSpell:GetCooldown(iLevel)) - 1 and math.ceil(me:GetAbility(t).cd - 0.7) >=  math.ceil(iSpell:GetCooldown(iLevel)) - 2  then
			count=1

			if me.team == TEAM_RADIANT then
				melocation = "radiant_top"

				if GetDistance2D(me,radiant_top_tower) > GetDistance2D(me,radiant_mid_tower)then
					melocation = "radiant_mid"
				end
				if GetDistance2D(me,radiant_mid_tower) > GetDistance2D(me,radiant_bot_tower)then
					melocation = "radiant_bot"
				end
				if melocation == "radiant_top" then
					dude1route = stack_route_radianta
					dude2route = stack_route_radianta2
					dude3route = stack_route_radiant2
				elseif melocation== "radiant_mid" then
					dude1route = stack_route_radianta
					dude2route = stack_route_radianta2
					dude3route = stack_route_radiant2
				elseif melocation== "radiant_bot" then
					dude1route = stack_route_radiant3
					dude2route = stack_route_radiant4
					dude3route = stack_route_radiant5

--print(stack_route_dire4[1])
--print(dude1route[1])

end

--home = radiant

else 
	melocation = "dire_top"

	if GetDistance2D(me,dire_top_tower) > GetDistance2D(me,dire_mid_tower)then
		melocation = "dire_mid"
	end
	if GetDistance2D(me,dire_mid_tower) > GetDistance2D(me,dire_bot_tower)then
		melocation = "dire_bot"
	end
	if melocation == "dire_top" then
		dude1route = stack_route_dire1
		dude2route = stack_route_dire2
		dude3route = stack_route_dire3
	elseif melocation== "dire_mid" then
		dude1route = stack_route_dire5
		dude2route = stack_route_direa
		dude3route = stack_route_direa2
	elseif melocation== "dire_bot" then
		dude1route = stack_route_direwait
		dude2route = stack_route_direa
		dude3route = stack_route_direa2
	end

end


if client.gameTime % 60 <= 45 then-- and (do_stack) then 
--print("time")
for i, v in ipairs(entityList:FindEntities({type=TYPE_HERO,team=me.team,visible=true,illusion=true})) do   
	if v.health > 0 then
--                      print("count")
--                    print(count)
if count == 1 then
	dude1=v
	count =2
--print("dd1")
elseif count == 2 then
	dude2=v
	count =3

elseif count == 3 then
	dude3=v
	count =4
end

end

end


if dude1 then
--dude1:Move(stack_route_radiant3[1])

dude1:Move(dude1route[1])
--dude1:Move(stack_route_radiant3[1])

--print(dude1route[1])
end
if dude2 then
	dude2:Move(dude2route[1])
--dude2:Move(stack_route_radiant4[1])
end
if dude3 then
	dude3:Move(dude3route[1])
--dude3:Move(stack_route_radiant5[1])
end
end
end

end
end


--

--print(me.x,me.y,me.z)


if (client.gameTime % 60 == start_time) then-- and (do_stack) then  
	if dude1 and dude1.health>0 then

		dude1:Move(dude1route[2])
		QueueNextAction()
		dude1:Move(dude1route[3])

		dude2:Move(dude2route[2])
		QueueNextAction()
		dude1:Move(dude2route[3])

		dude3:Move(dude3route[2])
		QueueNextAction()
		dude1:Move(dude3route[3])

--dude1:Move(stack_route_radiant3[2])
--dude2:Move(stack_route_radiant4[2])
--dude3:Move(stack_route_radiant5[2])
end
end




if dude1 then
	if isPosEqual(dude1.position, dude1route[2], 3) then
--dude1:Move(stack_route_radiant3[3])
dude1:Move(dude1route[3])
end
if isPosEqual(dude2.position, dude2route[2], 3) then
--dude2:Move(stack_route_radiant4[3])
dude2:Move(dude2route[3])
end
if isPosEqual(dude3.position, dude3route[2], 3) then
--dude3:Move(stack_route_radiant5[3])
dude3:Move(dude3route[3])
end
end



end
sleepTick = GetTick() + 300
--count = 1

end


function Frame( tick ) 
	local text_size = 16
	local msg_time = 3000  
	local msg_color = 0xFFFFFFFF
	local msg_x, msg_y
	if do_stack then
		drawManager:DrawText(x0,y0,text_size,0xFFFFFFFF,"Creep will stack.")
	end
	if not msg or not msg[2] then          
		return
	else           
		if msg[3] then
			msg_time = msg[3]
		end
		if msg[4] then
			text_size = msg[4]
		end
		if msg[5] then
			msg_color = msg[5]
		end
		if msg[6] then
			msg_x = msg[6].x
			msg_y = msg[6].y
		else
			msg_x, msg_y = x0, y0 + text_size
		end                            
	end
	if (tick < msg[2] + msg_time) then
		drawManager:DrawText(msg_x, msg_y, text_size, msg_color, msg[1])
	elseif msg and tick > msg[2] + msg_time then
		msg = nil              
	end
end

function restoreSelection(selection)
	for i,v in ipairs(selection) do
		if v.health>0 and v.visible then
			if i == 1 then
				Select(v)
			else
				SelectAdd(v)
			end
		end
	end
end

function isPosEqual(v1, v2, d)
	return (v1-v2).length <= d
end

function Load()
	if PlayingGame() then
		local me = entityList:GetMyHero()
		if me.classId ~= CDOTA_Unit_Hero_Naga_siren then 
			script:Disable() 
		else
			statusText.visible = true
			reg = true
			script:RegisterEvent(EVENT_FRAME,Frame)
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
		script:UnregisterEvent(Frame)
		script:UnregisterEvent(Key)
		script:RegisterEvent(EVENT_TICK,Load)
		reg = false
		statusText.visible = false
	end
end

script:RegisterEvent(EVENT_CLOSE,GameClose)
script:RegisterEvent(EVENT_TICK,Load)
