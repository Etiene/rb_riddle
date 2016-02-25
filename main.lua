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


local function get_index(t,str)
	for i, v in ipairs(t) do 
		if v == str then return i end
	end
	return nil
end

local orientations = {"N", "E", "S", "W"} -- <--- left ... turn ... right---->

function Robot:turn(direction)
	local i = get_index(orientations,self.orientation)
	local new_i 
	if direction == "L" then
		new_i = i == 1 and #orientations or i - 1
	elseif direction == "R" then
		new_i = (i % #orientations) + 1
	end
	self.orientation = orientations[new_i]
end

function Robot:walk()
	if self.orientation == "N" then
		self.position.y = self.position.y + 1
	elseif self.orientation == "E" then
		self.position.x = self.position.x + 1
	elseif self.orientation == "S" then
		self.position.y = self.position.y - 1
	elseif self.orientation == "W" then
		self.position.x = self.position.x - 1
	end
end

-- x,y < MAX
-- orientation: string, N,S,E or W
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
	if direction == "F" then
		self:walk()
	else
		self:turn(direction)
	end
end

-- Points where robots were last seen before vanishing off grid and left a "scent"
local last_seen = {}

-- Size of grid, from (0,0) to (boundaries.x, boundaries.y)
-- First input
local boundaries = {}

local instruction = ""

-- allow additional commands...
local fp = io.open("input.txt","r")
local b_x, b_y = fp:read("*number","*number")

print(b_x, b_y)

local x, y, _, o = fp:read("*number","*number",1,1) -- _ for whitespace
local r = Robot:new(x,y,o)
print(r.position.x,r.position.y,r.orientation)

fp:read("*line") -- reads the rest of the line

local instructions = fp:read("*line")
print(instructions)

instructions:gsub(".", function(c) r:move(c) end)

print(r.position.x,r.position.y,r.orientation)

fp:close()


