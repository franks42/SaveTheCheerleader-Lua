-- 
-- Abstract: Chains sample project
-- Demonstrates how to use a sequence of joints to construct chains
-- 
-- Version: 1.1 (revised for Alpha 2)
-- 
-- Sample code is MIT licensed, see http://developer.anscamobile.com/code/license
-- Copyright (C) 2010 ANSCA Inc. All Rights Reserved.

require "rgb"

local physics = require("physics")

local tmaxf = 0.5
dragWorm = function( event)
	-- touch a worm's head and drag it around
	local body = event.target
	local phase = event.phase
	local stage = display.getCurrentStage()
	if "began" == phase then
		stage:setFocus( body, event.id )
		body.isFocus = true

		-- Create a temporary touch joint and store it in the object for later reference
		body.tempJoint = physics.newJoint( "touch", body, event.x, event.y )
		body.tempJoint.maxForce = tmaxf

	elseif body.isFocus then
		if "moved" == phase then
			print("touch max force:".. body.tempJoint.maxForce)

			-- Update the joint to track the touch
			body.tempJoint:setTarget( event.x, event.y )

		elseif "ended" == phase or "cancelled" == phase then
			stage:setFocus( body, nil )
			body.isFocus = false

			-- Remove the joint when the touch ends			
			body.tempJoint:removeSelf()

		end
	end

	-- Stop further propagation of touch event
	return true
end


allWorms = {}

local wormBodyOverlap = 0.15
local wormHeadDensity = 2.0
local wormBodyDensity = 0.02
local wormHeadFriction = 1.0
local wormBodyFriction = 1.0
local wormHeadBounce = 0.1
local wormBodyBounce = 0.1
local wormRotationLimit = 25
local wormImage = "worm"
local wormDefaultBodyState = "hungry"


--local wormState = {	hungry=			{head=	{color= 	{255,0,0}},
local wormState = {	hungry=			{head=	{color= 	"red"},
									body=	{color= 	"orange"}},
					eating=			{head=	{color= 	"brown"},
									body=	{color= 	"gold"}},
					wandering=		{head=	{color= 	"blue"},
									body=	{color= 	"darkblue"}},
					eaten=			{head=	{color= 	"green"},
									body=	{color= 	"darkgreen"}},
					fed=			{head=	{color= 	"darkturquoise"},
									body=	{color= 	"honeydew"}},
					sleeping=		{head=	{color= 	"fuchsia"},
									body=	{color= 	"limegreen"}}
				}


setWormState = function( aWorm, aState)
-- setWorm docs
	aWorm.state = aState
	aWorm.stateChangeTime = system.getTimer()
	for i = 1, #(aWorm.segments) do
		if (i==1) then
			c = wormState[aState].head.color
			aWorm.segments[i]:setFillColor(rgbColor(c))
		else
			c = wormState[aState].body.color
			aWorm.segments[i]:setFillColor(rgbColor(c))
		end
	end
end


newWorm = function( topx, topy, wstate, wradius, nsegments )
-- newWorm docs
	local worm = {}
	local wsegments = {}
	local wjoints = {}
	worm.segments = wsegments
	worm.joints = wjoints
	worm.radius = wradius
	for j = 1,nsegments do						-- create display segments
		if (j == 1) then						-- head of the worm
			fname = wormImage .. "-" .. "head" .. "-" .. wstate .. ".png"
			--fname = "worm-head-hungry.png"
--			wsegments[j] = display.newImage( fname )
--			wsegments[j].xScale = wradius / wsegments[j].x
--			wsegments[j].yScale = wradius / wsegments[j].y
--			wsegments[j].x = topx
--			wsegments[j].y = topy + (j*2*(wradius - wormBodyOverlap * wradius))
--			wsegments[j].rotation = -90
			
			wsegments[j] = display.newCircle( topx, topy, wradius )
			wsegments[j]:setFillColor( 255, 0, 0) 
						
			worm.head = wsegments[j]
			worm.head.prevX = wsegments[j].x
			worm.head.prevY = wsegments[j].y
		else									-- body of worm
			fname = wormImage .. "-" .. "body" .. "-" .. wstate .. ".png"
			--fname = "worm-body-hungry.png"
--			wsegments[j] = display.newImage( fname )
--			wsegments[j].xScale = wradius / wsegments[j].x
--			wsegments[j].yScale = wradius / wsegments[j].y
--			wsegments[j].x = topx
--			wsegments[j].y = topy + (j*2*(wradius - wormBodyOverlap * wradius))
			
			wsegments[j] = display.newCircle( topx, wsegments[j-1].y + (2*(wradius - wormBodyOverlap * wradius)), wradius )
			wsegments[j]:setFillColor( 0, 255, 0) 
			
		end
	end	-- create display segments
	
	for j = 1,nsegments do						-- register physics body elements
		if (j == 1) then						-- head of the worm
			physics.addBody( wsegments[j], { density=wormHeadDensity, friction=wormHeadFriction, bounce=wormHeadBounce, radius=wradius } )
		else									-- body of worm
			physics.addBody( wsegments[j], { density=wormBodyDensity, friction=wormBodyFriction, bounce=wormBodyBounce, radius=wradius } )
			wjoints[#wjoints + 1] = physics.newJoint( "pivot", wsegments[j-1], wsegments[j], topx, (wsegments[j].y+wsegments[j-1].y)/2 )
			wjoints[#wjoints].isLimitEnabled = true
			wjoints[#wjoints]:setRotationLimits( -wormRotationLimit, wormRotationLimit )
		end
	end -- register physics body elements
	
	worm.tail = wsegments[#wsegments]
	setWormState(worm, wstate)
	worm.wandertime = 0
	allWorms[#allWorms+1] = worm
	--local wh = worm.head
	worm.head:addEventListener( "touch", dragWorm )
	return worm
end

local wmaxf = 0.025
local wanderingWorms = function( event)
	-- any worm in the "wandering" state will wander about...
	for i = 1, #allWorms do
		w = allWorms[i]
		if (w.state == "wandering" or w.state == "eaten" or w.state == "eating") then
			--make worm wander
			if(w.wandertime < system.getTimer()) then
				w.wandertime = system.getTimer()+1000
				w.fx = wmaxf * 2*(math.random() - 0.5)
				w.fy = wmaxf * 2*(math.random() - 0.5)
			end
			w.head:applyForce( w.fx, w.fy, w.head.x, w.head.y )
			if(w.state == "eaten" or w.state == "eating") then
				if(w.stateChangeTime + 5000 < system.getTimer()) then
					if(w.state == "eaten") then setWormState(w, "wandering") 
					else setWormState(w, "hungry") end
				end
			end
		end
	end
end
Runtime:addEventListener( "enterFrame", wanderingWorms )

local wtmaxf = 0.025
local hungryWorms = function( event)
	-- any worm in the "wandering" state will wander about...
	for i = 1, #allWorms do
		w = allWorms[i]
		if (w.state == "hungry") then
			fx = 0; fy = 0; dt = math.huge; tj = -1
			for j = 1, #allWorms do
				t = allWorms[j]
				if (t.state == "wandering") then
					ddt = math.sqrt((t.tail.x - w.head.x)^2+(t.tail.y - w.head.y)^2)
					if(ddt<dt) then
						dt = ddt
						tj = j
					end
				end
			end
			--make worm chase nearest tail
			if(tj > -1) then
				fx = wtmaxf * (allWorms[tj].tail.x - w.head.x)/dt
				fy = wtmaxf * (allWorms[tj].tail.y - w.head.y)/dt
			end
			--print("i,tj,dt,fx,fy"..i,tj,dt,fx,fy)
			w.head:applyForce( fx, fy, w.head.x, w.head.y )
		end
	end
end
Runtime:addEventListener( "enterFrame", hungryWorms )

local function looseWormTail(w)
	local oldsegments  = w.segments
	local oldjoints = w.joints
	local oldTail = w.tail
	w.joints = {}
	w.segments = {}
	if(#oldsegments == 1) then
		oldTail:removeSelf()
		w.state = "gone"
	else
		for i = 1, #oldjoints-1 do
			w.joints[i] = oldjoints[i]
		end
		for i = 1, #oldsegments-1 do
			w.segments[i] = oldsegments[i]
		end
		w.head = w.segments[1]
		w.tail = w.segments[#w.segments]
		oldjoints[#oldjoints]:removeSelf()
		oldTail:removeSelf()
	end
end

local function addWormTail(w)
	local n = #w.segments
	local nj = #w.joints
	local wradius = w.radius
	w.segments[n+1] = display.newCircle( w.segments[n].x, w.segments[n].y + (2*(wradius - wormBodyOverlap * wradius)), wradius )
	w.segments[n+1]:setFillColor( 0, 255, 0) 
	w.tail = w.segments[n+1]
	--physics.addBody( w.segments[n+1], { density=wormBodyDensity, friction=wormBodyFriction, bounce=wormBodyBounce, radius=wradius } )
	--w.joints[#w.joints + 1] = physics.newJoint( "pivot", w.segments[n], w.segments[n+1], (w.segments[n+1].x+w.segments[n].x)/2, (w.segments[n+1].y+w.segments[n].y)/2 )
	--wjoints[#wjoints].isLimitEnabled = true
	--wjoints[#wjoints]:setRotationLimits( -wormRotationLimit, wormRotationLimit )

end



local function onGlobalCollision( event )
	if ( event.phase == "began" ) then
		local o1 = event.object1; o2 = event.object2
		-- let's see if anyone is getting eaten...
		-- see if a hungry head collided with a wandering tail
		for i = 1, #allWorms do
			wi = allWorms[i]
			if (o1 == wi.head and wi.state == "hungry") then
				for j = 1, #allWorms do
					wj = allWorms[j]
					if (o2 == wj.tail and wj.state == "wandering")  then
						setWormState(wi, "eating")
						setWormState(wj, "eaten")
						looseWormTail(wj)
						--addWormTail(wi)
						--eatJoint = physics.newJoint( "pivot",wi.head, wj.tail, (wj.tail.x + wi.head.x)/2, (wj.tail.y + wi.head.y)/2 )
						--wi.eatJoint = eatJoint
						--wj.eatJoint = eatJoint
						break
					end
				end
				break
			end
		end
	end
end

Runtime:addEventListener( "collision", onGlobalCollision )



