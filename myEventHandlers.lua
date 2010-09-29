local coronaJson = require("coronaJson")

local myEventHandlers = {}

myEventHandlers.dragStatic = function( event)
	-- touch a registered static object and drag it around
	local body = event.target
	local phase = event.phase
	local stage = display.getCurrentStage()
	if "began" == phase then
		stage:setFocus( body, event.id )
		body.isFocus = true
		body.beforeDragX = body.x
		body.beforeDragY = body.y
		body.x = event.x
		body.y = event.y
	elseif body.isFocus then
		if "moved" == phase then
			body.x = event.x
			body.y = event.y
		elseif "ended" == phase or "cancelled" == phase then
			stage:setFocus( body, nil )
			body.isFocus = false
			body.x = event.x
			body.y = event.y
		end
	end
	-- Stop further propagation of touch event
	return true
end

coronaJson.objRegister("dragStatic", myEventHandlers.dragStatic) -- coronaJson

----

local forceFactor = 10

myEventHandlers.ballForce = function(event)
	-- excert an attracting force between the two objects "b1" and "b2".
	local b1 = coronaJson.objRegistry("b1") -- coronaJson
	local b2 = coronaJson.objRegistry("b2") -- coronaJson
	if(not (b1 and b2 and b1.x and b2.x)) then return end
	vx = b2.x-b1.x; vy = b2.y-b1.y
	d12 = math.sqrt(vx^2 + vy^2)
	f1x = forceFactor*vx/d12; f1y = forceFactor*vy/d12
	b1:applyForce( f1x, f1y, b1.x, b1.y )
	b2:applyForce( -f1x, -f1y, b2.x, b2.y )
end

Runtime:addEventListener("enterFrame", myEventHandlers.ballForce)

return myEventHandlers