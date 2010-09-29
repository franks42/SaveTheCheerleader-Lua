--[[  coronaJson.lua - 
--
-- Copyright (c) Frank Siebenlist. All rights reserved.
-- The use and distribution terms for this software are covered by the
-- Eclipse Public License 1.0 (http://opensource.org/licenses/eclipse-1.0.php).
-- By using this software in any fashion, you are agreeing to be bound by
-- the terms of this license.
-- You must not remove this notice, or any other, from this software.
--
Usage:

Enjoy, Frank (Sep 28, 2010)
-----------------------------------------------------------------------------]]

local json = require ("dkjson")
-- http://www-users.rwth-aachen.de/David.Kolf/json-lua

local physics = require("physics")

local coronaJson = {}

local objectRegistry = {}

coronaJson.objRegister = function(name,obj)
	objectRegistry[name] = obj
end

coronaJson.objRegistry = function(name)
	return objectRegistry[name]
end


coronaJson.tableInsert = function(tbl,item)
	if(not tbl) then tbl = {} end
	table.insert(tbl,item)
	return tbl
end


coronaJson.setFillColor = function( o, r, g, b, a )
	o.fillColor = {r,g,b,a}
	return o:setFillColor(r,g,b,a)
end

coronaJson.coronaToJson = function(value, state)
	local vtable = {}
	-- coronaJson specific
	vtable.coronaType = value.coronaType
	vtable.objectRef = tostring(value)
	vtable.eventListener = value.eventListener
	vtable.name = value.name
	-- common properties
	vtable.alpha = value.alpha
	vtable.fillColor = value.fillColor
	vtable.height = value.height
	vtable.isVisible = value.isVisible
	vtable.isHitTestable = value.isHitTestable
	vtable.rotation = value.rotation
	vtable.x = value.x
	vtable.xOrigin = value.xOrigin
	vtable.xReference = value.xReference
	vtable.xScale = value.xScale
	vtable.y = value.y
	vtable.yOrigin = value.yOrigin
	vtable.yReference = value.yReference
	vtable.yScale = value.yScale
	vtable.width = value.width
	-- physics specific
	vtable.density = value.density
	vtable.bodyType = value.bodyType
	if(vtable.bodyType) then
		local vx, vy = value:getLinearVelocity()
		vtable.linearVelocity = {vx, vy}
		vtable.bodyProp = value.bodyProp
	end
	-- Group specific
	vtable.numChildren = value.numChildren
	if(vtable.numChildren) then
		-- some group-kind of object
		-- so we "artificially" copy the array of children to a "normal" table
		vtable.children = {}
		for i = 1, vtable.numChildren do
			vtable.children[i] = value[i]
		end
	end
	--
	return json.encode(vtable, state)
end

-- register the __tojson writer with the metatable of a Corona "group"
-- it seems that most (all?) Corona objects share that metatable
local cs = display.getCurrentStage()
cs.coronaType = "Stage"
local csmt = getmetatable(cs)
csmt.__tojson = coronaJson.coronaToJson

--

local setCommonProperties = function( o, t )
	o.coronaType = t.coronaType
	o.eventListener = t.eventListener
	o.alpha = t.alpha
	o.bodyProp = t.bodyProp
	o.height = t.height
	o.isVisible = t.isVisible
	o.isHitTestable = t.isHitTestable
	o.rotation = t.rotation
	o.fillColor = t.fillColor
	o.linearVelocity = t.linearVelocity
	o.name = t.name
	o.xOrigin = t.xOrigin
	o.xReference = t.xReference
	o.xScale = t.xScale
	o.y = t.y
	o.yOrigin = t.yOrigin
	o.yReference = t.yReference
	o.yScale = t.yScale
	o.width = t.width
	--
	if(o.fillColor) then
		o:setFillColor(o.fillColor[1], o.fillColor[2],o.fillColor[3])
	end
	if(o.name) then
		coronaJson.objRegister(o.name, o)
	end
	if(o.eventListener) then
		for n,h in pairs(o.eventListener) do
			o:addEventListener( h[1], coronaJson.objRegistry(h[2]) )
		end
	end
end

local createNewCircle = function( t, p )
	print("createNewCircle")
	local o = display.newCircle(0,0,10)
	p:insert(o)
	setCommonProperties( o, t )
	if(t.bodyType) then
		-- physics body
		physics.addBody( o, t.bodyType, o.bodyProp )
		o:setLinearVelocity( o.linearVelocity[1], o.linearVelocity[2] )
	end
end

local createNewRect = function( t, p )
	print("createNewRect")
	local o = display.newRect(0,0,10,10)
	p:insert(o)
	setCommonProperties( o, t )
	if(t.bodyType) then
		-- physics body
		physics.addBody( o, t.bodyType, o.bodyProp )
		o:setLinearVelocity( o.linearVelocity[1], o.linearVelocity[2] )
	end
end

local createNewGroup = function( t, p )
	print("createNewGroup")
	local o
	if(p) then
		print("display.newGroup")
		o = display.newGroup()
		p:insert(o)
	else
		print("display.getCurrentStage")
		o = display.getCurrentStage()
	end
	-- create group's children first before setting props
	for i,v in ipairs(t.children) do
		coronaJson.tableToCorona( v, o )
	end	
	--
	setCommonProperties( o, t )
	--
	if(o.bodyType) then
		-- physics body
		physics.addBody( o, o.bodyType, o.bodyProp )
		o:setLinearVelocity( o.linearVelocity[1], o.linearVelocity[2] )
	end
	
end

coronaJson.tableToCorona = function (t,p)
	--
	print("tableToCorona")
	if(t.coronaType == "Stage") then
	--expected highest level table
		createNewGroup(t,nil)
	elseif(t.coronaType == "Group") then
		createNewGroup(t,p)
	elseif(t.coronaType == "Circle") then
		createNewCircle(t,p)
	elseif(t.coronaType == "Rect") then
		createNewRect(t,p)
	else
		print("else... unimplemented:", t.coronaType)
	end
end

coronaJson.jsonToCorona = function(s)
	local tbl = json.decode(s)
	return coronaJson.tableToCorona(tbl)
end

return coronaJson