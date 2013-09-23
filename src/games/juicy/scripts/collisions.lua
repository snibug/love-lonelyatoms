require 'enums.tags'

function resetCollisionSystem(world)

    local collision_system = world:getSystem(CollisionSystem)

    collision_system:reset()
    collision_system:watchCollision(world:getTaggedEntity(Tags.BALL), world:getEntitiesInGroup(Tags.BRICK_GROUP))
    collision_system:watchCollision(world:getTaggedEntity(Tags.PLAYER), world:getEntitiesInGroup(Tags.WALL_GROUP))
    collision_system:watchCollision(world:getTaggedEntity(Tags.BALL), world:getTaggedEntity(Tags.PLAYER))
    collision_system:watchCollision(world:getTaggedEntity(Tags.BALL), world:getEntitiesInGroup(Tags.WALL_GROUP))

end

function announceCollisions(world, collisions) 

    local message_system = world:getMessageSystem()

    -- Go through all collisions
    for collision_event in collisions:members() do

        -- Collision of Player with Wall
        if collision_event.a == world:getTaggedEntity(Tags.PLAYER) and
           world:getGroupsContainingEntity(collision_event.b):contains(Tags.WALL_GROUP) then

            message_system:emitMessage(Events.PLAYER_COLLISION_WALL, collision_event.a, collision_event.b)

            -- TODO move 
            collidePlayerWithWall(collision_event.a, collision_event.b)

        -- Collision of Ball with Wall
        elseif collision_event.a == world:getTaggedEntity(Tags.BALL) and
           world:getGroupsContainingEntity(collision_event.b):contains(Tags.WALL_GROUP) then

            
            message_system:emitMessage(Events.BALL_COLLISION_WALL, collision_event.a, collision_event.b)

            -- TODO move 
            collideBallWithWall(collision_event.a, collision_event.b)

        -- Collision of Ball with Player
        elseif collision_event.a == world:getTaggedEntity(Tags.BALL) and
           collision_event.b == world:getTaggedEntity(Tags.PLAYER) then

            message_system:emitMessage(Events.BALL_COLLISION_PLAYER, collision_event.a, collision_event.b)

            -- TODO move 
            collideBallWithPaddle(collision_event.a, collision_event.b)
      
        -- Collision of Ball with Brick
        elseif collision_event.a == world:getTaggedEntity(Tags.BALL) and
           world:getGroupsContainingEntity(collision_event.b):contains(Tags.BRICK_GROUP) then

            message_system:emitMessage(Events.BALL_COLLISION_BRICK, collision_event.a, collision_event.b)

            -- TODO move 
            collideBallWithBrick(collision_event.a, collision_event.b)

        end

    end
end