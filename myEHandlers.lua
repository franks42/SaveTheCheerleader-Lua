local coronaJson = require("coronaJson")

dragStatic = function( event)
	-- touch a worm's head and drag it around
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

jsonEventHandlers.dragStatic = dragStatic

