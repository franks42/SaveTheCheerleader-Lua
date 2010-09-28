
local json = require ("dkjson")
local coronaJson = require("coronaJson")
local myEHandlers = require("myEHandlers")

local physics = require("physics")
physics.start()
physics.setScale( 60 )
physics.setGravity( 0, 0 )

--physics.setDrawMode("debug")

local group = display.newGroup()
group.coronaType = "Group"

local initialSpeed = 300
local forceFactor = 10
 
local b1 = display.newCircle( 75, 150, 25)
b1:setFillColor(255, 0, 0); 
b1.coronaType = "Circle"
b1.name = "b1"
jsonObjects.b1 = b1
b1.fillColor = {255, 0, 0}
b1.bodyProp = { density=1, friction=0, bounce=.9, radius=25 }
physics.addBody( b1, b1.bodyProp )
b1:setLinearVelocity( 0, initialSpeed )

local b2 = display.newCircle( 250, 150, 25)
b2:setFillColor(0, 0, 255)
b2.coronaType = "Circle"
b2.name = "b2"
jsonObjects.b2 = b2
b2.fillColor = {0, 0, 255}
b2.bodyProp = { density=1, friction=0, bounce=.9, radius=25 }
physics.addBody( b2, b2.bodyProp )
b2:setLinearVelocity( 0, -initialSpeed )

group:insert( b1 )
group:insert( b2 )

function ballForce(event) 
	local b1 = jsonObjects.b1
	local b2 = jsonObjects.b2
	if(not (b1.x and b2.x)) then return end
	vx = b2.x-b1.x; vy = b2.y-b1.y
	d12 = math.sqrt(vx^2 + vy^2)
	f1x = forceFactor*vx/d12; f1y = forceFactor*vy/d12
	b1:applyForce( f1x, f1y, b1.x, b1.y )
	b2:applyForce( -f1x, -f1y, b2.x, b2.y )
end

Runtime:addEventListener("enterFrame", ballForce)


local borderPx = 10
local borderFriction = 1.0

local rect = {}

for i = 1, 2 do
	rect[i] = display.newRect( 35, 300, borderPx, 100 )
	rect[i]:setFillColor( 255, 0, 128)
	rect[i].fillColor = {255, 0, 128}
	rect[i].bodyProp = { friction=borderFriction }
	physics.addBody( rect[i], "static", rect[i].bodyProp )
	rect[i].coronaType = "Rect"
	rect[i]:addEventListener( "touch", dragStatic )
	rect[i].eventListener = jTableInsert(rect[i].eventListener, {"touch", "dragStatic"})
	group:insert( rect[i] ) -- assume rect1 is an existing display object
end

local nc = display.newCircle( 200, 400, 55 )
nc.coronaType = "Circle"
nc:setFillColor( 0, 255,128)
nc.fillColor = {0, 255,128}
nc.bodyProp = { friction=borderFriction }
physics.addBody( nc, "static", nc.bodyProp )
nc:addEventListener( "touch", dragStatic )
nc.eventListener = jTableInsert(nc.eventListener, {"touch", "dragStatic"})

group:insert(nc)

local cs = display.getCurrentStage()

afterDelay1 = function( event )
	physics.pause()
	jo, js = json.encode (cs, {indent = true})
	print("afterDelay1 \n", jo)
	--jo, js = json.encode (group, {indent = true})
	--group:removeSelf()
	--cs:removeSelf()
	local g = cs[1]
	g:removeSelf()
	physics.start()
end

afterDelay2 = function( event )
	ret = jsonToCorona(jo)
end

timer.performWithDelay( 5000, afterDelay1)
timer.performWithDelay( 7000, afterDelay2)
timer.performWithDelay( 12000, afterDelay1)
timer.performWithDelay( 14000, afterDelay2)

