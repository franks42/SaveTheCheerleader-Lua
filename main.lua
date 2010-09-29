
local json = require ("dkjson") -- coronaJson
local coronaJson = require("coronaJson") -- coronaJson
myEventHandlers = require("myEventHandlers") -- coronaJson

local physics = require("physics")
physics.start()
physics.setScale( 60 )
physics.setGravity( 0, 0 )

--physics.setDrawMode("debug")

local group = display.newGroup()
group.coronaType = "Group" -- coronaJson

local initialSpeed = 300
 
local b1 = display.newCircle( 75, 150, 25)
b1:setFillColor(255, 0, 0); 
b1.coronaType = "Circle" -- coronaJson
b1.name = "b1" -- coronaJson
coronaJson.objRegister("b1", b1) -- coronaJson
b1.fillColor = {255, 0, 0} -- coronaJson
b1.bodyProp = { density=1, friction=0, bounce=.9, radius=25 } -- coronaJson
physics.addBody( b1, b1.bodyProp )
b1:setLinearVelocity( 0, initialSpeed )

local b2 = display.newCircle( 250, 150, 25)
b2:setFillColor(0, 0, 255)
b2.coronaType = "Circle" -- coronaJson
b2.name = "b2" -- coronaJson
coronaJson.objRegister("b2", b2) -- coronaJson
b2.fillColor = {0, 0, 255} -- coronaJson
b2.bodyProp = { density=1, friction=0, bounce=.9, radius=25 } -- coronaJson
physics.addBody( b2, b2.bodyProp )
b2:setLinearVelocity( 0, -initialSpeed )

group:insert( b1 )
group:insert( b2 )


local borderPx = 10
local borderFriction = 1.0

local rect = {}

for i = 1, 12 do
	rect[i] = display.newRect( 35, 300, borderPx, 100 )
	rect[i]:setFillColor( 255, 0, 128)
	rect[i].fillColor = {255, 0, 128} -- coronaJson
	rect[i].bodyProp = { friction=borderFriction } -- coronaJson
	physics.addBody( rect[i], "static", rect[i].bodyProp )
	rect[i].coronaType = "Rect" -- coronaJson
	rect[i]:addEventListener( "touch", myEventHandlers.dragStatic )
	 -- coronaJson
	rect[i].eventListener = coronaJson.tableInsert(rect[i].eventListener, {"touch", "dragStatic"})
	group:insert( rect[i] ) -- assume rect1 is an existing display object
end

for i = 1, 12 do
	rect[i] = display.newRect( 35, 400, 100, borderPx)
	rect[i]:setFillColor( 255, 0, 128)
	rect[i].fillColor = {255, 0, 128} -- coronaJson
	rect[i].bodyProp = { friction=borderFriction } -- coronaJson
	physics.addBody( rect[i], "static", rect[i].bodyProp )
	rect[i].coronaType = "Rect" -- coronaJson
	rect[i]:addEventListener( "touch", myEventHandlers.dragStatic )
	 -- coronaJson
	rect[i].eventListener = coronaJson.tableInsert(rect[i].eventListener, {"touch", "dragStatic"})
	group:insert( rect[i] ) 
end

local nc = display.newCircle( 200, 400, 55 )
nc.coronaType = "Circle" -- coronaJson
nc:setFillColor( 0, 255,128)
nc.fillColor = {0, 255,128} -- coronaJson
nc.bodyProp = { friction=borderFriction } -- coronaJson
physics.addBody( nc, "static", nc.bodyProp )
nc:addEventListener( "touch", myEventHandlers.dragStatic )
nc.eventListener = coronaJson.tableInsert(nc.eventListener, {"touch", "dragStatic"}) -- coronaJson

group:insert(nc)

local cs = display.getCurrentStage()
local jo
local js

afterDelay1 = function( event )
	physics.pause()
	jo, js = json.encode (cs, {indent = true})
	print("afterDelay1 \n", jo)
	--jo, js = json.encode (group, {indent = true})
	--group:removeSelf()
	--cs:removeSelf()
	local g = cs[1]
	g:removeSelf()
	--
	local p = system.pathForFile( "jaja.json", system.DocumentsDirectory )
	print("p:",p)
	local f = io.open(p, "w")
	f:write(jo)
	io.close(f)
	--
	physics.start()
end

afterDelay2 = function( event )
	local p = system.pathForFile( "jaja.json", system.DocumentsDirectory )
	local f = io.open(p, "r")
	local joja = f:read("*a")
	io.close(f)
	--print("joja:", joja)
	ret = coronaJson.jsonToCorona(joja)
end

timer.performWithDelay( 5000, afterDelay1)
timer.performWithDelay( 7000, afterDelay2)
timer.performWithDelay( 12000, afterDelay1)
timer.performWithDelay( 14000, afterDelay2)

