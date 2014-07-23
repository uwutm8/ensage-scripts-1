--[[potential steal spell special instructions for death of rosh:
   blink carriers, Anti-Mage(blink), clocwerk(auto ult), earth spirit(?), ember spirit(use slight of fist)
   void(blink),magnus(cut trees, stand next to pit,skewer), mirana(leap, invis),morphling(waveform),puck(illusory orb,blink,steal,jaunt)
   qop(blink),sand king(blink,burrow out),slark(pounce),phoenix(icarus dive),spectre(Haunt->reality illusion closest to aegis->steal->spectral dagger out)
   storm spirit(ball lightning in, steal, ball lightning out),timbersaw(cut trees on cliff, timberchain to other side and steal aegis while you're over it)


   potential deny:
   lycan(auto deny by invis wolves), broodmother(army of broodmother's spiders), enigma(army of demonic conversions),
   invoker(spirits),lone druid(bear),naga(illusions),np(nature call),pl(illusions),shadowshaman(serpent ward),
   sniper(shrapnel, deny),terrorblade(illusions),veno(wards),visage(familiars),warlock(chaotic offering rosh pit, then deny), ]]

require("libs.Utils")
require("libs.ScriptConfig")

config = ScriptConfig.new()
config:SetParameter("ToggleKey", "G", config.TYPE_HOTKEY)
config:Load()

local toggleKey   = config.ToggleKey
local reg         = false
local activ       = true
local monitor     = client.screenSize.x/1600
local F15         = drawMgr:CreateFont("F15","Tahoma",15*monitor,550*monitor)
local F14         = drawMgr:CreateFont("F14","Tahoma",14*monitor,550*monitor) 
local statusText  = drawMgr:CreateText(10*monitor,530*monitor,-1,"(" .. string.char(toggleKey) .. ") Steal Aegis: Off",F14) statusText.visible = false

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
			statusText.text = "(" .. hotkeyText .. ") Steal Aegis: On"
		else
			statusText.text = "(" .. hotkeyText .. ") Steal Aegis: Off"
		end
	end
end

function Tick(tick)
	if not SleepCheck() then return end
	Sleep(125)
	if not activ then return end
	-- get our hero
	local me = entityList:GetMyHero()
	if not me then return end
	-- check if we're alive and not using any channeling spell
	if me.alive and not me:IsChanneling() then
		-- get all ground items
		local items = entityList:GetEntities({type=LuaEntity.TYPE_ITEM_PHYSICAL})
		-- search for aegis
		for i,v in ipairs(items) do
			local IH = v.itemHolds
-- default_aegis = {Vector(2413.25,-239.313,4.1875)}
-- default position for aegis: 2413.25,-239.313,4.1875
			if IH.name == "item_aegis" and GetDistance2D(v,me) <= 150 then
						entityList:GetMyPlayer():TakeItem(v)
				Sleep(500)
				break
			end
--			if IH.name == "item_aegis" and GetDistance2D(v,allies) => 1000 then
--				use lycan wolves to deny
--				entityList:GetMyPlayer():Attack(v) deny
--			end
		end
	end
end

function Roshan( kill )
    if kill.name == "dota_roshan_kill" then		
		script:RegisterEvent(EVENT_TICK,Roha)		
    end
end

script:RegisterEvent(EVENT_TICK,Tick)
script:RegisterEvent(EVENT_KEY,Key)
script:RegisterEvent(EVENT_DOTA,Roshan)
