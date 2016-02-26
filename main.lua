local MAX = 50

local Robot = {}
local mt_rbt = { __index = Robot} --metatable for Lua OO

local last_seen = {} -- Points where robots were last seen before vanishing off grid and left a "scent"
local orientations = {"N", "E", "S", "W"} -- <--- left ... turn ... right---->
local commands = {"L","R","F"} -- Currently available instructions
local boundaries = { x = 0, y = 0} -- Grid upper-right boundaries, updated on reading input

local function max_check(x,y)
	if x > MAX or y > MAX then
		error('Error: the maximum value for a coordinate is '..MAX)
	end
end

local function set_boundaries(x,y)
	max_check(x,y)
	boundaries.x = x 
	boundaries.y = y
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

local function get_index(t,str)
	for i, v in ipairs(t) do 
		if v == str then return i end
	end
	return nil
end

local function in_list(t,str)
	for _,v in ipairs(t) do 
		if str == v then return true end
	end
	return false
end

function Robot:new(x,y,orientation)
	local obj = {
		position = { x = x, y = y },
		orientation = orientation,
		lost = false 
	}
	if is_off_boundaries(x,y) then
		obj.lost = true
	end
	setmetatable(obj,mt_rbt)
	return obj
end

function Robot:obbey(instruction)
	if self.lost then return end 

	if instruction == "F" then
		self:walk()

	elseif instruction == "R" or instruction =="L" then
		self:turn(instruction)

	elseif in_list(commands,instruction) then
		--does nothing
		--TODO: implement new instructions
	else
		error("Error: Sorry, the instruction `"..instruction.."` is not available yet.")
	end
end

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
		return
	end

	self.position.x, self.position.y = new_x, new_y
end

function Robot:get_scent()
	for _,p in ipairs(last_seen) do
		if p.x == self.position.x and p.y == self.position.y then
			return true
		end
	end
	return false
end 


-- Main Loop for reading input file
local fp = io.open("input.txt","r")

if not fp then
	error('Error: expecting to have a file "input.txt" at the same dir.')
end

local b_x, b_y = fp:read("*number","*number")
set_boundaries(b_x,b_y)


while(fp:read(0)) do
	local x, y, _, o = fp:read("*number","*number",1,1) -- _ for whitespace
	if not x then break end -- input may have extra blank lines at the end
	max_check(x,y)
	local r = Robot:new(x,y,o)
	
	fp:read("*line") -- reads the rest of the line

	local instructions = fp:read("*line")
	instructions:gsub(".", function(cmd) r:obbey(cmd) end) -- Will run this function on every character of instruction

	print( 	r.position.x,
			r.position.y,
			r.orientation,
			r.lost and 'LOST' or ''
		)

	fp:read("*line") -- reads a new line, should be blank
end 
fp:close()
