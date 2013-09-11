require 'external.middleclass'
require 'core.entity.sprite'
require 'core.vector'
require 'states.actions'
require 'core.shapes'

Player = class('Player', Sprite)


function Player:initialize(x, y, width, height)

	sprite_and_collider_shape = RectangleShape(width, height)

    Sprite.initialize(self, x, y, sprite_and_collider_shape)


    local half_rectangle = RectangleShape(width / 2, height)
    self.leftEdge = Sprite(x, y, half_rectangle)
    self.rightEdge = Sprite(x + width - 1, y, half_rectangle)

	self.active = true
	self.visible = true

	self:setColor(147,147,205)

    self:setMaxVelocity(800, 0)
    self:setMinVelocity(-800, 0)
    self:setDrag(800, 0)

    self.speed_delta = Vector(1500, 0)
    self.base_speed = Vector(200, 0)

    self.current_action = nil

end


function Player:moveTo(x, y)

    -- TODO refactor
    self.position.x = x;
    self.position.y = y;

    self.leftEdge:moveTo(x, y)
    self.rightEdge:moveTo(x + (self.shape.width/2), y)

end


function Player:stop()

    self.velocity = Vector.zero
    self.acceleration = Vector.zero
end

function Player:accelerateRight(dt)

    if self.velocity < Vector.zero then 
        self.velocity = self.base_speed
    end

    self.velocity = self.velocity + (self.speed_delta * dt)
end


function Player:accelerateLeft(dt)

    if self.velocity > Vector.zero then 
        self.velocity = -self.base_speed
    end

    self.velocity = self.velocity - (self.speed_delta * dt)
end

function Player:capVelocity()
    if self.velocity > self.maxVelocity then
        self.velocity = self.maxVelocity
    elseif self.velocity < self.minVelocity then
        self.velocity = self.minVelocity
    end
end

function Player:applyDrag(dt)

    if self.velocity > Vector.zero then
        
        self.velocity = self.velocity - (self.drag * dt)

        if self.velocity < Vector.zero then
            self.velocity = Vector.zero
        end

    elseif self.velocity < Vector.zero then

        self.velocity = self.velocity + (self.drag * dt)

        if self.velocity > Vector.zero then
            self.velocity = Vector.zero
        end

    end
end

function Player:processInput(dt, input)

    if input:heldAction(Actions.PLAYER_RIGHT) then
    
        self:accelerateRight(dt)
        self.current_action = Actions.PLAYER_RIGHT
    
    elseif input:heldAction(Actions.PLAYER_LEFT) then
    
        self:accelerateLeft(dt)
        self.current_action = Actions.PLAYER_LEFT

    else
        self:applyDrag(dt)
        self.current_action = nil

    end

end

function Player:collideWithWall(collided_sprite)

    assert(instanceOf(RectangleShape, collided_sprite.hitbox), "Can only be applied to rectangles")

    local collided_position = collided_sprite.position


    -- If something is immovable, then I could only collide with it in the direction I'm going
    if self.leftEdge:collidesWith(collided_sprite) then

        -- Translate to be on the other side of it

        local new_x = collided_position.x + collided_sprite.hitbox.width + 1

        self:moveTo(new_x, self.position.y)

        if self.current_action == Actions.PLAYER_LEFT then
            self.velocity = Vector.zero
        else
            self.velocity = -self.velocity
        end


    elseif self.rightEdge:collidesWith(collided_sprite) then

        -- Translate to be on the other side of it
        self:moveTo(collided_position.x - self.hitbox.width - 1, self.position.y)

        if self.current_action == Actions.PLAYER_RIGHT then
            self.velocity = Vector.zero
        else
            self.velocity = -self.velocity
        end

    else 

        assert(false, "Collided but didn't detect right or left edge collision " .. tostring(self.shape) .. tostring(self.rightEdge) .. tostring(collided_sprite.hitbox))

    end

    -- Reverse Velocity


end

function Player:update(dt)

    self:capVelocity()


    -- assert(false, "inspecting transform: " .. tostring(self.shape.transform))
    local new_position = self.position + (self.velocity * dt) 

    self:moveTo(new_position.x, new_position.y)

end


function Player:processAI(dt, ball)

    local paddle_origin = self.position.x
    local paddle_width = self.shape.width
    local third_of_paddle = paddle_width / 3

    local middle_ball = ball.position.x + self.shape.width/2

    local first_third = paddle_origin + third_of_paddle
    local second_third = first_third + third_of_paddle
    local third_third = paddle_origin + paddle_width

    if middle_ball < first_third then

        self:accelerateLeft(dt)
        self.current_action = Actions.PLAYER_LEFT

    elseif middle_ball > second_third then
        
        self:accelerateRight(dt)
        self.current_action = Actions.PLAYER_RIGHT

    else

        self:applyDrag(dt)
        self.current_action = nil

    end

end

