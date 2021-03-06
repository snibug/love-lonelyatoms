require 'game.screenmap'
require 'collections.matrix'
require 'entity.systems.inputsystem'

DEBUG = true

function love.load()

    screen_map = ScreenMap(love.graphics.getWidth(), love.graphics.getHeight(), 10, 10)

    mouse_x = 0
    mouse_y = 0

    clicked_matrix = Matrix(10, 10, 0)

    input_system = InputSystem()
    input_system:registerInput(' ', "reset")
end


-- Perform computations, etc. between screen refreshes.
function love.update(dt)

    input_system:update(dt)

    mouse_x, mouse_y = love.mouse.getPosition()
    tile_hover = screen_map:getCoordinates(mouse_x, mouse_y)

    if input_system:newAction("reset") then
        clicked_matrix:populateDefault()
    end
   
end

function love.mousepressed(x, y, button)
    mouse_x, mouse_y = love.mouse.getPosition()
    tile_hover = screen_map:getCoordinates(mouse_x, mouse_y)
    local x, y = tile_hover:unpack()
    local current = clicked_matrix:get(x, y)
    clicked_matrix:put(x, y, current + 1)
end


function drawScreenTiles(screen_map)

    local r = 200
    local b = 40

    for x = 0, screen_map.xtiles - 1 do 

        r = r - 10
        b = b + 10
        local g = 50

        for y = 0, screen_map.ytiles - 1 do

            g = g + 10

            local alpha = l
            local current = clicked_matrix:get(x + 1, y + 1)

            assert(current, "There should be a current for " .. x + 1 .. ", " ..y + 1 .. " but instead there is not..." .. tostring(clicked_matrix))

            if current % 2 == 1 then alpha = 255 end

            love.graphics.setColor(r,g,b, alpha)

            love.graphics.rectangle("fill", x * screen_map.tile_width, y * screen_map.tile_height, screen_map.tile_width, screen_map.tile_height)
           
            love.graphics.print(tostring(current), x * screen_map.tile_width, y * screen_map.tile_height)
        end
    end


end


-- Update the screen.

function love.draw()


    love.graphics.setBackgroundColor(63, 63, 63, 255)

    drawScreenTiles(screen_map)


    if DEBUG then
       local debugstart = 50
        love.graphics.setColor(255, 255, 255)
        love.graphics.print("FPS: " .. love.timer.getFPS(), 50, debugstart + 20)
        love.graphics.print("Mouse X: " .. tostring(mouse_x), 50, debugstart + 40)
        love.graphics.print("Mouse Y: " .. tostring(mouse_y), 50, debugstart + 60)
        love.graphics.print("Mouse Tile Coordinates: " .. tostring(tile_hover), 50, debugstart + 80)

    end

end
