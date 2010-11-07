import('Physics')
import('PilotAI')

lastTime = 0
keys = {
    up = false;
    down = false;
    left = false;
    right = false;
    w = false;
    a = false;
    s = false;
    d = false;
}
power = 20
angle = 0

turret = vec(300,300)
launcher = vec(0,0)

projectiles = {}
bulletSpeed = 650
bulletRadius = 5.0
pigeonRadius = 10.0

turnRate = 2 * math.pi
powerUpRate = 50.0



function init()
    lastTime = mode_manager.time()
    Physics.NewSystem()
end

function update()
    local currentTime = mode_manager.time()
    dt = currentTime - lastTime
    lastTime = currentTime
    if keys.left == true then
        angle = angle + turnRate * dt
    elseif keys.right == true then
        angle = angle - turnRate * dt
    end
    
    if keys.up == true then
        power = power + powerUpRate * dt
    elseif keys.down == true then
        power = power - powerUpRate * dt
    end
    Physics.UpdateSystem(dt, projectiles)
end

function render()
    graphics.begin_frame()
    graphics.set_camera(-512, -384, 512, 384)
    
    local endPoint = PolarVec(power,angle)
    graphics.draw_line({x=0, y=0}, endPoint, 1.0, {r=0, g=1, b=0, a=1})
    
    graphics.draw_circle(turret, 25, 4, {r=1, g=0, b=0, a=1})
    
    for i,o in pairs(projectiles) do
        if o.type == "p" then
            graphics.draw_circle(o.physics.position, pigeonRadius, 1, {r=1.0, g=0.3, b=0, a=1})
            graphics.draw_circle(o.physics.position, pigeonRadius * 0.75, 1, {r=1.0, g=0.3, b=0, a=1})
        else
            graphics.draw_circle(o.physics.position, bulletRadius, 1, {r=1, g=1, b=1, a=1})
        end
    end
    
    graphics.end_frame()
end

function key(k)
    if k == "escape"
    or k == "q" then
        mode_manager.switch("Xsera/MainMenu")
    elseif k == " " then
        local pigeon = Physics.NewObject(1)
        pigeon.collision_radius= pigeonRadius
        pigeon.angle = angle
        pigeon.velocity = PolarVec(power*2,angle)
        projectiles[pigeon.object_id] = {type = "p"; physics = pigeon}
        
        
        local bullet = Physics.NewObject(1)
        bullet.collision_radius = bulletRadius
        bullet.angle = AimTurret(
            {
                position = turret;
                velocity = vec(0,0);
            },
            pigeon,
            bulletSpeed
        )
        bullet.position = turret
        bullet.velocity = PolarVec(bulletSpeed, bullet.angle)
        
        projectiles[bullet.object_id] = {type = "b"; physics = bullet}
        
    elseif keys[k] ~= nil then
        keys[k] = true
    else
        print("Key: ", k)
    end
end

function keyup(k)
    if keys[k] ~= nil then
        keys[k] = false
    end
end