local MAX = 50
local boundaries = {}
local last_seen = {} -- Points where robots were last seen before vanishing off grid and left a "scent"

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

local function is_off_boundaries(x,y)
	if  x < 0 or
		x > boundaries.x or 
		y < 0 or 
		y > boundaries.y then

		return true
	end	
	return false
end

function Robot:walk()
	local new_x, new_y
	if self.orientation == "N" then
		new_y = self.position.y + 1
	elseif self.orientation == "E" then
		new_x = self.position.x + 1
	elseif self.orientation == "S" then
		new_y = self.position.y - 1
	elseif self.orientation == "W" then
		new_x = self.position.x - 1
	end

	new_x = new_x or self.position.x -- defaulting
	new_y = new_y or self.position.y

	if is_off_boundaries(new_x, new_y) then
		if self:get_scent() then return end

		self.lost = true 
		last_seen[#last_seen+1] = {x = self.position.x, y = self.position.y}
	end

	self.position.x, self.position.y = new_x, new_y
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

function Robot:get_scent()
	for _,p in ipairs(last_seen) do
		if p.x == self.position.x and p.y == self.position.y then
			print("I stepped in a bad place")
			return true
		end
	end
	return false
end 

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


