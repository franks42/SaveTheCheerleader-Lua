
local physics = require("physics")
local json = require ("dkjson") -- coronaJson
local coronaJson = require("coronaJson") -- coronaJson
myEventHandlers = require("myEventHandlers") -- coronaJson

physics.start()
physics.setScale( 60 )
physics.setGravity( 0, 0 )

--physics.setDrawMode("debug")

local cs = display.getCurrentStage()

local group = display.newGroup()
group.coronaType = "Group" -- coronaJson

local panel = display.newGroup()
panel.coronaType = "Group" -- coronaJson
panel.name = "panel" -- coronaJson


local initialSpeed = 300
 
local b1 = display.newCircle( 75, 150, 25)
b1.radius = 25
b1:setFillColor(255, 0, 0); 
b1.coronaType = "Circle" -- coronaJson
b1.name = "b1" -- coronaJson
coronaJson.objRegister("b1", b1) -- coronaJson
b1.fillColor = {255, 0, 0} -- coronaJson
b1.bodyProp = { density=1, friction=0, bounce=.9, radius=b1.radius } -- coronaJson
physics.addBody( b1, b1.bodyProp )
--b1:setLinearVelocity( 0, initialSpeed )
b1:setLinearVelocity( 0, 0 )

--local b2 = display.newCircle( 250, 150, 25)
--b2:setFillColor(0, 0, 255)
--b2.coronaType = "Circle" -- coronaJson
--b2.name = "b2" -- coronaJson
--coronaJson.objRegister("b2", b2) -- coronaJson
--b2.fillColor = {0, 0, 255} -- coronaJson
--b2.bodyProp = { density=1, friction=0, bounce=.9, radius=25 } -- coronaJson
--physics.addBody( b2, b2.bodyProp )
--b2:setLinearVelocity( 0, -initialSpeed )

fnb2 = "worm.png"
fpb2 = system.pathForFile( fnb2, system.ResourceDirectory )
print("fpb2:", fpb2)
local b2 = display.newImage(fnb2)
b2.imageFile = fpb2 -- coronaJson
b2.coronaType = "Image" -- coronaJson
b2.radius = 25
print("b2xy:", b2.x,b2.y, b2.width, b2.height)
b2.xScale = 2 * b2.radius / b2.width
b2.yScale = 2 * b2.radius / b2.height
b2.x = 250; b2.y = 150
b2.name = "b2" -- coronaJson
coronaJson.objRegister("b2", b2) -- coronaJson
b2.bodyProp = { density=1, friction=0, bounce=.9, radius=b2.radius }
physics.addBody( b2, b2.bodyProp )
--b2:setLinearVelocity( 0, -initialSpeed )
b2:setLinearVelocity( 0, 0 )

group:insert( b1 )
group:insert( b2 )

local borderPx = 10
local borderFriction = 1.0

local rect = {}

for i = 1, 2 do
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

for i = 1, 2 do
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


p1 = display.newRect( -50, -50, 100, 100)
p1:setFillColor(0,255,255)
p1.fillColor = {0,255,255} -- coronaJson
p1.coronaType = "Rect" -- coronaJson
p1.name = "p1 - large rect" -- coronaJson
p1.bodyProp = { friction=borderFriction } -- coronaJson
--physics.addBody( p1, "kinematic", panel.bodyProp )
--p1:addEventListener( "touch", myEventHandlers.dragStatic )
--p1.eventListener = coronaJson.tableInsert(p1.eventListener, {"touch", "dragStatic"})
panel:insert(p1)

p2 = display.newRect( -25, -25, 50, 50)
p2:setFillColor(100,255,0)
p2.fillColor = {100,255,0} -- coronaJson
p2.coronaType = "Rect" -- coronaJson
p2.name = "p2 - small rect" -- coronaJson
p2.bodyProp = { friction=borderFriction } -- coronaJson
--physics.addBody( p1, "kinematic", panel.bodyProp )
p2:addEventListener( "touch", myEventHandlers.dragStatic )
p2.eventListener = coronaJson.tableInsert(p2.eventListener, {"touch", "dragStatic"})
panel:insert(p2)

panel:addEventListener( "touch", myEventHandlers.dragStatic )
panel.eventListener = coronaJson.tableInsert(panel.eventListener, {"touch", "dragStatic"})

local jo
local js

afterDelay1 = function( event )
	physics.pause()
	jo, js = json.encode (cs, {indent = true})
	--print("b2:",json.encode (b2, {indent = true}))
	
	--print("afterDelay1 \n", jo)
	--jo, js = json.encode (group, {indent = true})
	--group:removeSelf()
	--cs:removeSelf()
	for i=cs.numChildren,1,-1 do 
		-- note that we have to count down if we remove elements in loop
		local g = cs[i]
		g:removeSelf()
	end
	--
	local p = system.pathForFile( "jaja.json", system.DocumentsDirectory )
	--print("p:",p)
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

afterDelay3 = function( event )
	physics.pause()
end

timer.performWithDelay( 5000, afterDelay1)
timer.performWithDelay( 5100, afterDelay2)
--timer.performWithDelay( 7100, afterDelay3)
--timer.performWithDelay( 300, afterDelay1)
--timer.performWithDelay( 400, afterDelay2)

