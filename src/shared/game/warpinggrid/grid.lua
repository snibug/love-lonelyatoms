require 'external.middleclass'
require 'collections.matrix'
require 'collections.list'
require 'math.vector3'
require 'math.vector2'
require 'game.warpinggrid.pointmass'
require 'game.warpinggrid.spring'

Grid = class('Grid')

local half_screen_size = Vector2(love.graphics.getWidth() / 2, love.graphics.getHeight() / 2)

function Grid:initialize(screen_width, screen_height, cols, rows)

	self.screen_width = screen_width
	self.screen_height = screen_height

	self.cols = cols
	self.rows = rows

	self.x_spacer = self.screen_width / (self.cols - 1)
	self.y_spacer = self.screen_height / (self.rows - 1)


	self.point_grid = Matrix(cols, rows,  nil)
	self.springs = List()

	self.fixed_points = Matrix(cols, rows,  nil)

	for x = 0, cols - 1  do
		for y = 0, rows - 1  do
			self.point_grid:put(x + 1, y + 1, PointMass(x * self.x_spacer, y * self.y_spacer, 0, 1))
			self.fixed_points:put(x + 1, y + 1, PointMass(x * self.x_spacer, y * self.y_spacer, 0, 0))
		end
	end


	local stiffness = 0.28
	local damping = 0.06 

	for x = 1, self.cols do
		for y = 1, self.rows do

			-- anchor the border of the grid 
			if x == 1 or y == 1 or x == self.cols or y == self.rows then

			  	self.springs:append(Spring(self.fixed_points:get(x, y), self.point_grid:get(x, y), 0.7, 0.7))
        
            elseif x % 3 == 0 and y % 3 == 0 then  -- loosely anchor 1/9th of the point masses 
 			  	self.springs:append(Spring(self.fixed_points:get(x, y), self.point_grid:get(x, y), 0.002, 0.002))
 			end


            if x > 1 then
            	self.springs:append(Spring(self.point_grid:get(x - 1, y), self.point_grid:get(x, y), stiffness, damping))
            end

            if y > 1 then
            	self.springs:append(Spring(self.point_grid:get(x, y - 1), self.point_grid:get(x, y), stiffness, damping))
            end

		end
	end


end

function Grid:update(dt)

	for _, spring in self.springs:members() do
		spring:update(dt)
	end

	
	for x = 1, self.cols do
		for y = 1, self.rows do
			self.point_grid.matrix[x][y]:update(dt)
		end
	end

end



local point = Vector2(0, 0)
local left = Vector2(0, 0)
local up = Vector2(0, 0)

function Grid:draw()


	local radius = 4

	for x = 1, self.cols do
		for y = 1, self.rows do
			
			local pointmass = self.point_grid.matrix[x][y]
			point = toVec2(pointmass.position, point)
			
			love.graphics.point(point.x, point.y)

			if x > 1 then
				left = toVec2(self.point_grid.matrix[x - 1][y].position, left)
				love.graphics.line(point.x, point.y, left.x, left.y)
			end

			if y > 1 then
				up = toVec2(self.point_grid.matrix[x][y - 1].position, up)
				love.graphics.line(point.x, point.y, up.x, up.y)				
			end

		end
	end

end


function toVec2(v3, v2)

	-- do a perspective projection
	local factor = (v3.z + 2000) / 2000

	v2.x = v3.x - half_screen_size.x
	v2.y = v3.y - half_screen_size.y

	v2.x = v2.x * factor
	v2.y = v2.y  * factor

	v2.x = v2.x + half_screen_size.x
	v2.y = v2.y + half_screen_size.y

	return v2

end


function Grid:applyImplosiveForce(force, position, radius)

	local _force_buffer = Vector3(0, 0, 0)

	for x = 1, self.cols do
		for y = 1, self.rows do
			
			local point = self.point_grid:get(x, y)

			local distance_from_point = Vector3.distance2(position, point.position)

			if distance_from_point < radius * radius then

				_force_buffer:copy(position)
				_force_buffer:subtract(point.position)
				_force_buffer:multiply(10 * force)
				_force_buffer:divide(100 + distance_from_point)

				point:applyForce(_force_buffer)
				point:increaseDamping(0.6)
			end

		end
	end

end

function Grid:applyExplosiveForce(force, position, radius)

	local _force_buffer = Vector3(0, 0, 0)
	
	for x = 1, self.cols do
		for y = 1, self.rows do
			
			local point = self.point_grid:get(x, y)

			local distance_from_point = Vector3.distance2(position, point.position)

			if distance_from_point < radius * radius then

				_force_buffer:copy(position)
				_force_buffer:subtract(point.position)
				_force_buffer:multiply(100 * force)
				_force_buffer:divide(10000 + distance_from_point)

				point:applyForce(_force_buffer)
				point:increaseDamping(0.6)

			end

		end
	end

end

