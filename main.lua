local MAX = 50

local Point = {}
local mt_pt = {	__index = Point}

function Point:new(x, y)
	local obj = {x = x, y = y}
	setmetatable(obj,mt_pt)
	return obj
end

function Point:update(x,y)
	self.x = x and x or self.x -- keeps self.x if x is nil, first boolean op will be false
	self.y = y and y or self.y
end


local Robot = {}
local mt_rbt = { __index = Robot}

-- x,y < MAX
-- orentation: string, N,S,E or W
function Robot:new(x,y,orientation)
	local obj = {
		position = Point:new(x,y),
		orientation = orientation 
	}
	setmetatable(obj,mt_rbt)
	return obj
end

 -- direction: string L, R or F
function Robot:move(direction)
end

-- Points where robots were last seen before vanishing off grid and left a "scent"
local last_seen = {}

-- Size of grid, from (0,0) to (boundaries.x, boundaries.y)
-- First input
local boundaries = {}

local instruction = ""

-- allow additional commands...