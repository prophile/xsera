keyControls = { left = false, right = false, forward = false, brake = false }
camera = { w = 1024, h = 768 }
playerShip = nil

import('Math')
import('ShipLoad')

function init ()
    print("Demo2 started")
    lastTime = mode_manager.time()
    physics.open(0.6)
    playerShip = NewShip("Ishiman/HeavyCruiser")
end

function discard (x)
end

function update ()
    local newTime = mode_manager.time()
    local dt = newTime - lastTime
    lastTime = newTime
    
    -- update angular velocity
    if keyControls.left then
        playerShip.physicsObject.angular_velocity = playerShip.turningRate
    elseif keyControls.right then
        playerShip.physicsObject.angular_velocity = -playerShip.turningRate
    else
        playerShip.physicsObject.angular_velocity = 0
    end
    
    -- update force
    if keyControls.forward then
        -- apply a forward force in the direction the ship is facing
        local angle = playerShip.physicsObject.angle
        local thrust = playerShip.thrust
        local force = { x = thrust * math.cos(angle), y = thrust * math.sin(angle) }
        playerShip.physicsObject:apply_force(force)
    elseif keyControls.brake then
        -- apply a reverse force in the direction opposite the direction the ship is MOVING
        local velocityVector = playerShip.physicsObject.velocity
        local velocityMag = hypot(velocityVector.x, velocityVector.y)
        velocityVector.x = -velocityVector.x / velocityMag
        velocityVector.y = -velocityVector.y / velocityMag
        local thrust = playerShip.reverseThrust
        velocityVector.x = velocityVector.x * thrust
        velocityVector.y = velocityVector.y * thrust
        playerShip.physicsObject:apply_force(velocityVector)
    end
    physics.update(dt)
end

function render ()
    graphics.begin_frame()
    
    local shipPosition = playerShip.physicsObject.position
    graphics.set_camera(shipPosition.x - 46 - (camera.w / 2.0), shipPosition.y - (camera.h / 2.0), shipPosition.x - 46 + (camera.w / 2.0), shipPosition.y + (camera.w / 2.0))
    graphics.draw_starfield()
    graphics.draw_sprite(playerShip.image, shipPosition.x, shipPosition.y, playerShip.size.x, playerShip.size.y, playerShip.physicsObject.angle)
    
    graphics.end_frame()
end

function key ( k )
    if k == "w" then
        keyControls.forward = true
    elseif k == "s" then
        keyControls.brake = true
    elseif k == "a" then
        keyControls.left = true
    elseif k == "d" then
        keyControls.right = true
    end
end

function keyup ( k )
    if k == "w" then
        keyControls.forward = false
    elseif k == "s" then
        keyControls.brake = false
    elseif k == "a" then
        keyControls.left = false
    elseif k == "d" then
        keyControls.right = false
    end
end

function quit ()
    physics.close()
end
