function _init()
	poke(0x5f2d,0x1)
	defmath()
end

function _update()
	math()
	if calcinit == true then
		calc()
	end
end

function _draw()
	cls(0)
	print(instructions)
	if secinstructions != nil then
		print(secinstructions)
	end
	if place != nil and place2 != nil and calcinit == false then
		print(place .. place2)
	elseif place != nil and place2 == nil and calcinit == false then
		print(place)
	end
	if calcinit == true then
		print(totalac)
		print("◆◆◆")
		print("set bonus: +" .. bon)
		print("torso: +" .. tor)
		print("legs: +" .. leg)
		print("helmet: +" .. hel)
		print("♥")
	end
end
-->8
function defmath()
place = nil
place2 = nil
totalac = nil
calcinit = false
bon = 0
tor = 0
leg = 0
hel = 0
calcdelay = 0

instructions = "please enter your total ac:"
secinstructions = "press z to confirm"
end
function math()
	if btnp(4) and
	place2 != nil and
	totalac == nil then
		secinstructions = nil
		calcinit = true
		instructions = "calculating..."
		totalac = tonum(place .. place2)
	elseif btnp(4) and
	place != nil and
	totalac == nil then
		totalac = tonum(place)
		calcinit = true
		secinstructions = nil
		instructions = "calculating..."
	end
	if stat(30) and
	place == nil then
		place = stat(31)
		if type(tonum(place)) != "number" then
			place = nil
		end
	elseif stat(30) and
	place2 == nil then
		place2 = stat(31)
		if type(tonum(place2)) != "number" then
			place2 = nil
		end
	end
end

function calc()
	if totalac <= 10 then
		instructions = "done!"
	 return
	end
	calcdelay += 1
	if calcdelay == 5 then
		totalac -= 1
		bon += 1
	end
	if calcdelay == 10 then
		totalac -= 1
		tor += 1
	end
	if calcdelay == 15 then
		totalac -= 1
		leg += 1
	end
	if calcdelay == 20 then
		totalac -= 1
		hel += 1
		calcdelay = 0
	end
end