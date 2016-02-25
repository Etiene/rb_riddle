local MAX = 50

local boundaries = {}
local function set_boundaries(x,y)
	boundaries.x = x <= MAX and x or MAX
	boundaries.y = y <= MAX and y or MAX
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
	local x_now, y_now = self.position.x, self.position.y
	if self.orientation == "N" then
		self.position.y = self.position.y + 1
	elseif self.orientation == "E" then
		self.position.x = self.position.x + 1
	elseif self.orientation == "S" then
		self.position.y = self.position.y - 1
	elseif self.orientation == "W" then
		self.position.x = self.position.x - 1
	end
	if self:is_off_boundaries() then self.lost = true end
end

function Robot:is_off_boundaries()
	if  self.position.x < 0 or
		self.position.x > boundaries.x or 
		self.position.y < 0 or 
		self.position.y > boundaries.y then

		return true
	end	
	return false
end

-- x,y < MAX
-- orientation: string, N,S,E or W
function Robot:new(x,y,orientation)
	local obj = {
		position = { x = x, y = y },
		orientation = orientation,
		lost = false 
	}
	setmetatable(obj,mt_rbt)
	return obj
end

 -- direction: string L, R or F
function Robot:move(direction)
	if self.lost then return end 

	if direction == "F" then
		self:walk()
	else
		self:turn(direction)
	end
end

-- Points where robots were last seen before vanishing off grid and left a "scent"
local last_seen = {}

-- allow additional commands...
local fp = io.open("input.txt","r")
local b_x, b_y = fp:read("*number","*number")
set_boundaries(b_x,b_y)

print(b_x, b_y)

while(fp:read(0)) do
	local x, y, _, o = fp:read("*number","*number",1,1) -- _ for whitespace
	local r = Robot:new(x,y,o)
	print(r.position.x,r.position.y,r.orientation)

	fp:read("*line") -- reads the rest of the line

	local instructions = fp:read("*line")
	print(instructions)

	instructions:gsub(".", function(c) r:move(c) end)

	print(r.position.x,r.position.y,r.orientation,r.lost and 'LOST' or '')

	fp:read("*line") -- reads a new line, should be blank
end 
fp:close()


