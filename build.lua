-- building program using parmos style, may rewrite to use api?
--[[ to do:
fix block not placed after load return
fix len pos issues after load return
work on api with separate progs, or combining this with run prog
]]
-- NOTE: coords and facing based on minecraft values so.. x=e+/w- y=up+/dn- z=n-/s+ f:0=s 1=w 2=n 3=e

--[[ usage:
cfg.home vars will be this starting point

travel height variable (cfg.trvlY) should be enough to take it over the boxes. default is 10 up

cfg.site vars are relative to the home point so should be adjusted as needed. default is 1 block up and 7 east

at the home point, place a box with fuel under the turtle and 4 stacks of 4 boxes around it (one on each side) for the materials
each box relates to a slot in the turtle inv. starting from the front of the turtle and going clockwise then up like this
box slots top to bottom, turtle starts at level 0.
(front)  0 4 8 C
(left) 3 7 B F
(right) 1 5 9 D
(back) 2 6 A E
(A-F represent 10-15 so 0-15 = 16 slots)
NOTE: turtle uses 1-16 to count slots, this program translates the characters required

input design .blp file should have lines like this:
-0123453210-L
-6789ABCDEF-^
the hex numbers directly relate to the box numbers mentioned above.
# = blank space
L = go to next line horizontally
^ =  go up one floor , so design should start from bottom and go up.

-- the program checks the highest number used, this mean that the blueprints should be made using hex numbers 0-F in order,
-- missing out numbers and not filling the respective boxes may result in the turtle not leaving a box at home area.
]]

--declare variable array
local cfg = {}
--these would normally be in buildInit(), but placing here for ease of editing while this has no menu
-- site coords, relative to home being 0,0,0,0
cfg.siteX = 0
cfg.siteY = 1
cfg.siteZ = 3
cfg.siteF = 0
--travel height relative to home height of 0.
cfg.trvlY = 10
-----------------------------------------
--Custom Turtle Move/Interact functions--
-----------------------------------------

local function goUP()
-- print("trying to go up")
local UP = turtle.up()
  if UP then
   cfg.Y = cfg.Y + 1
   --save()
   cfg.fuelNeeded = cfg.fuelNeeded - 1
  end
return UP
end

local function goDOWN()
-- print("trying to go down")
local DOWN = turtle.down()
  if DOWN then
   cfg.Y = cfg.Y - 1
   --save()
   cfg.fuelNeeded = cfg.fuelNeeded - 1
  end
return DOWN
end

local function goFORWARD()
--print("trying to go forward")
local FORWARD = turtle.forward()
if FORWARD then
  if cfg.F == 0 then
   cfg.Z = cfg.Z + 1
  elseif cfg.F == 1 then
   cfg.X = cfg.X - 1
  elseif cfg.F == 2 then
   cfg.Z = cfg.Z - 1
  elseif cfg.F == 3 then
   cfg.X = cfg.X + 1
  end
  --save()
  cfg.fuelNeeded = cfg.fuelNeeded - 1
end
return FORWARD
end

local function goBACKWARD()
-- print("trying to go backward")
local BACKWARD = turtle.back()
if BACKWARD then
  if cfg.F == 0 then
   cfg.Z = cfg.Z - 1
  elseif cfg.F == 1 then
   cfg.X = cfg.X + 1
  elseif cfg.F == 2 then
   cfg.Z = cfg.Z + 1
  elseif cfg.F == 3 then
   cfg.X = cfg.X - 1
  end
  --save()
  cfg.fuelNeeded = cfg.fuelNeeded - 1
end
return BACKWARD
end


local function goRIGHT()
-- print("trying to turn right")
turtle.turnRight()
if cfg.F == 3 then
  cfg.F = 0
else
  cfg.F = cfg.F + 1
end
--save()
end


local function goLEFT()
-- print("trying to turn left")
turtle.turnLeft()
if cfg.F == 0 then
  cfg.F = 3
else
  cfg.F = cfg.F - 1
end
--save()
end


local function dig()
-- print("trying to dig")
local DIG = turtle.dig()
if DIG then
  cfg.wood = cfg.wood + 1
  --save()
end
return DIG
end


local function digUP()
-- print("trying to dig up")
local DIGUP = turtle.digUp()
if DIGUP then
  cfg.wood = cfg.wood + 1
  --save()
end
return DIGUP
end

local function digDOWN()
-- print("trying to dig down")
local DIGDOWN = turtle.digDown()
if DIGDOWN then
  cfg.wood = cfg.wood + 1
  --save()
end
return DIGDOWN
end


local function digMOVEFORWARD()
while not goFORWARD() do
  if dig() then
  end
end
end

local function digMOVEUP()
while not goUP() do
  if digUP() then
  end
end
end

local function digMOVEDOWN()
while not goDOWN() do
  if digDOWN() then
  end
end
end



local function toTRAVELHEIGHT() --moving to the travel height in prep for going places
cfg.status = 3
print("trying to get to travel height")
--save()
local reachedTravelY = false
while cfg.Y ~= cfg.trvlY do
  if cfg.Y < cfg.trvlY then
   digMOVEUP()
  else
   digMOVEDOWN()
  end
end

if cfg.Y == cfg.trvlY then
  reachedTravelY = true
else
  cfg.status = 4
  --save()
  error("Failed to get to travel height!")
end
return reachedTravelY
end --End function toTRAVELHEIGHT

local function turnFACE(face) -- turn to correct facing
while cfg.F ~= face do
  goRIGHT()
end
end -- End function turnFACE

local function gotoDEST(dest) --travelling to specified destination
local reachedDest = false
print("trying to get to "..dest)

if dest == "home" then
  cfg.status = 5
  --save()

  --get to correct Z coord
  if cfg.Z < cfg.homeZ then
   turnFACE(0)
  else
   turnFACE(2)
  end
 
  while cfg.Z ~= cfg.homeZ do
    digMOVEFORWARD()
  end
  --get to correct X coord
  if cfg.X < cfg.homeX then
   turnFACE(3)
  else
   turnFACE(1)
  end

  while cfg.X ~= cfg.homeX do
    digMOVEFORWARD()

  end

-- get to correct height coord
  while cfg.Y ~= cfg.homeY do
   if cfg.Y < cfg.homeY then
    digMOVEUP()
   else
    digMOVEDOWN()
   end
  end

  turnFACE(cfg.homeF)

  reachedDest = true
end


if dest == "site" then
  cfg.status = 6
  --save()
    --get to correct Z coord
  if cfg.Z < cfg.siteZ then
   turnFACE(0)
  else
   turnFACE(2)
  end
 
  while cfg.Z ~= cfg.siteZ do
    digMOVEFORWARD()
  end
  --get to correct X coord
  if cfg.X < cfg.siteX then
   turnFACE(3)
  else
   turnFACE(1)
  end

  while cfg.X ~= cfg.siteX do
    digMOVEFORWARD()

  end

-- get to correct height coord
  while cfg.Y ~= cfg.siteY do
   if cfg.Y < cfg.siteY then
    digMOVEUP()
   else
    digMOVEDOWN()
   end
  end

  turnFACE(cfg.siteF)
  reachedDest = true
end


if not reachedDest then
  cfg.status = 7
  --save()
  error("Failed to get to "..dest)
  else
  return reachedDest
end

end -- End function gotoDEST


local function checkSPACEFUEL() --checks if the turtle has enough fuel and space to continue
print("checking space and fuel")
local hasSpace = false
local hasFuel = false
local hasBoth = false
i = 1
while (not hasSpace) and i < 17 do
  if turtle.getItemCount(i) == 0 then
   hasSpace = true
  end
  i = i + 1
end

if cfg.fuel >= cfg.fuelNeeded then
  hasFuel = true
end

if hasSpace and hasFuel then
  hasBoth = true
end
return hasBoth
end
-- End function checkSPACEFUEL


------------------------------------------------
--End of Custom Turtle Move/Interact functions--
------------------------------------------------

------------------
--Build Functions--
------------------

local function buildLoadBluprnt()
print("loading blueprint")
--**add a check for existing here?
write("|build source file name ?")
input = read()
cfg.file = input
h = fs.open(cfg.file,"r")
bluPrnt = h.readAll()
--[[ local line = -1
local eof = false
while not eof do
  if h.readLine(line) then
   bluPrnt = bluPrnt..h.readLine(line)
  else
   eof = true
  end
  line = line + 1
end ]]
h.close()
--print(bluPrnt)
end
-- End function buildLoadBBluprnt()

local function buildFindLastSlot() -- find out how many slots will be used ** - needs testing
local i=0
local a=""
cfg.lastSlot = 1
for i=0, 15 do
  if i<10 then
   a = tostring(i)
  elseif i == 10 then
   a = "A"
  elseif i == 11 then
   a = "B"
  elseif i == 12 then
   a = "C"
  elseif i == 13 then
   a = "D"
  elseif i == 14 then
   a = "E"
  elseif i == 15 then
   a = "F"
  end
 
  if string.find(bluPrnt, a) then
   cfg.lastSlot = i + 1
  end
end

end
-- End function buildFindSlots()


local function buildCheckLevels()
cfg.fuel = turtle.getFuelLevel()
print("fuel is - "..cfg.fuel)
end
--End function buildCheckLevels()


local function buildCheckFuelNeeded()
print("working out fuel needed")
local total = 0
local trvlDist = 0

if (cfg.X ~= cfg.homeX and cfg.Y ~= cfg.homeY and cfg.Z ~= cfg.homeZ ) then
  if cfg.Y ~= cfg.trvlY then
   if (cfg.X ~= cfg.siteX and cfg.Y ~= cfg.siteY and cfg.Z ~= cfg.siteZ ) then
   gotoDEST("site")
   end
   toTRAVELHEIGHT()
  end
  gotoDEST("home")
end

if cfg.siteX > cfg.homeX then
  trvlDist = trvlDist + (cfg.siteX - cfg.homeX)
else 
  trvlDist = trvlDist + (cfg.homeX - cfg.siteX)
end

if cfg.siteZ > cfg.homeZ then
  trvlDist = trvlDist + (cfg.siteZ - cfg.homeZ)
else 
  trvlDist = trvlDist + (cfg.homeZ - cfg.siteZ)
end  

if cfg.trvlY > cfg.homeY then
  trvlDist = trvlDist + (cfg.trvlY - cfg.homeY)
else 
  trvlDist = trvlDist + (cfg.homeY - cfg.trvlY)
end  

if cfg.trvlY > cfg.siteY then
  trvlDist = trvlDist + (cfg.trvlY - cfg.siteY)
else 
  trvlDist = trvlDist + (cfg.siteY - cfg.trvlY)
end  

total = (trvlDist * (tonumber(string.len(bluPrnt)) / 32)) + tonumber(string.len(bluPrnt)) 
-- rought total of movement needed based on trips to site for blocks and blueprint length

cfg.fuelNeeded = (cfg.fuelNeeded + total + 100) -- adds to current amount needed for calc mid mine + extra 100 just for a little spare

end
-- End function buildCheckFuelNeeded()


local function buildLoadRefuel()

local loadSlot = 1
local i = 0
if not (cfg.X == cfg.homeX and cfg.Y == cfg.homeY and cfg.Z == cfg.homeZ ) then
  gotoDEST("site")
  toTRAVELHEIGHT()
  gotoDEST("home")
end

turtle.select(loadSlot)
turtle.drop(loadSlot)
print("refueling")
while cfg.fuel < cfg.fuelNeeded do
  turtle.suckDown()
  if turtle.getFuelLevel() ~= "unlimited" then -- this bit checks to make sure fuel is not consumed beyond the max fuel limit of the turtle.
    if turtle.getFuelLimit() then
      while turtle.getFuelLevel() < turtle.getFuelLimit() and turtle.getItemCount(loadSlot) > 0 do
        turtle.refuel(1)
      end
    else
      turtle.refuel()
    end
  end
  buildCheckLevels()
  sleep(2)
end
turtle.dropDown(loadSlot) --drop any fuel left that was not needed to reach max fuel limit

print("reloading")
for loadSlot = 1, cfg.lastSlot do
  turtle.select(loadSlot)
  while turtle.getItemCount(loadSlot) == 0 do
    turtle.suck()
     if turtle.getItemCount(loadSlot) == 0 then
       print("need more blocks for slot "..loadSlot)
       sleep(3)
     end
  end
  goRIGHT()
  if loadSlot % 4 == 0 then
    goUP()
  end
end
--[[** empty slot 1 suckdown to get fuel into slot 1, refuel and grab stack from slot 1. then do function to rotate right and rise filling each slot.
see usage note at top for info on this layout.
]]
toTRAVELHEIGHT()
gotoDEST("site")
end
--End function buildLoadRefuel()


local function buildInit()
print("initilising")

buildCheckLevels()
cfg.run = "Builder"
cfg.label = "zolbuild"
cfg.widPos = 0
cfg.lenPos = 1
cfg.floorPos = 0
cfg.X = 0
cfg.Y = 0
cfg.Z = 0
cfg.F = 0
cfg.homeX = 0
cfg.homeY = 0
cfg.homeZ = 0
cfg.homeF = 0
cfg.fuelNeeded = 0
buildLoadBluprnt()
buildFindLastSlot()
buildCheckFuelNeeded()
if cfg.fuel < cfg.fuelNeeded then
  buildLoadRefuel()
end

end
--End function buildInit()

local function buildGUI()
--cls()
buildCheckLevels()
print("Program :"..cfg.run)
print("Computer:"..cfg.label)
print("build file:"..cfg.file)
print("X,Y,Z,F :"..cfg.X..","..cfg.Y..","..cfg.Z..","..cfg.F)
print("Fuel :"..cfg.fuel)
--debug prints
--sleep(3)
end
--End function buildGUI()


local function buildLaneStart()
local j = 0
print("going to start of lane")
for j = 0, cfg.lenPos - 1 do
  goBACKWARD()
end
end
--End function buildLaneStart()


local function buildNewLane()
buildLaneStart()
print("new lane")
cfg.lenPos = 0
goRIGHT()
goFORWARD()
cfg.widPos = cfg.widPos + 1
goLEFT()

end
--End function buildNewLane()

local function buildFloorStart()
local j = 0
buildLaneStart()
print("going to start of floor")
goRIGHT()
for j = 0, cfg.widPos - 1 do
  goBACKWARD()
end
goLEFT()
end
--End function buildFloorStart()


local function buildNewFloor()
buildFloorStart()
print("new floor")
cfg.lenPos = 0
cfg.widPos = 0
goUP()
cfg.floorPos = cfg.floorPos + 1
end
--End function buildNewFloor()

local function buildStartPos()
local j = 0
buildFloorStart()
print ("going to start of build")
goBACKWARD()
for j = 0, cfg.floorPos -1 do
  goDOWN()
end
end
-- End function buildStartPos()


local function buildLoadAndReturn()
buildStartPos()
buildLoadRefuel()
local flr = 0
local wid = 0
local len = 0
print ("going back to place")
while flr ~= cfg.floorPos do
  goUP()
  flr = flr + 1
end
goFORWARD()
goRIGHT()
while wid ~= cfg.widPos do
  goFORWARD()
  wid = wid + 1
end
goLEFT()
while len ~= cfg.lenPos do
  goFORWARD()
  len = len + 1
end
end
-- End function buildLoadAndReturn()


local function buildPlace()
--print ("placing a block")
if cfg.slot < 17 then --**test if this errors when 99 the slot
  turtle.select(cfg.slot)
  if turtle.getItemCount(cfg.slot) > 0 then
    if turtle.detectDown() then
       if not turtle.compareDown() then
         turtle.digDown()
         turtle.placeDown()
       end
     else
      turtle.placeDown()
    end
  else
   buildLoadAndReturn()
  end
   
end
end
-- End function buildPlace()


local function buildMain()
buildGUI()
goFORWARD()
for i=1,string.len(bluPrnt) do
  a = string.sub(bluPrnt,i,i)
  --print (a)
  if a == "L" then
   buildNewLane()
   cfg.slot = 99
  elseif a == "^" then
   buildNewFloor()
   cfg.slot = 99
  else
   if tonumber(a) then
    cfg.slot = (tonumber(a) + 1)
   elseif a == "A" then
    cfg.slot = 11
   elseif a == "B" then
    cfg.slot = 12
   elseif a == "C" then
    cfg.slot = 13
   elseif a == "D" then
    cfg.slot = 14
   elseif a == "E" then
    cfg.slot = 15
   elseif a == "F" then
    cfg.slot = 16
   elseif a == "#" then
    cfg.slot = 99
   else
    cfg.slot = 99
    print("Error, invalid character at position "..tostring(i).." on blueprint")
   end
   if cfg.slot < 98 then
    print("can place "..cfg.slot)
    buildPlace()
   end
   goFORWARD()
   cfg.lenPos = cfg.lenPos + 1
  end
  if not checkSPACEFUEL() then
   buildLoadAndReturn()
  end
  buildGUI()
  --save()
end
toTRAVELHEIGHT()
gotoDEST("home")
end
--End function buildMain()

------------------------
--End Building Functions--
------------------------
buildInit()
buildLoadRefuel()
buildMain()