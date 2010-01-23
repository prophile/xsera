
--[[-----------------------------
	--{{---------------------
--MARK:	Weapon Management
	---------------------}}--
-----------------------------]]--
function WeaponManage(weapon, weapData, weapOwner)
	if weapon.firing == true then
		WeaponCreate(weapon, weapData, weapOwner)
	end
	
	WeaponUpdate(weapon, weapData, weapOwner)
end

function WeaponCreate(weapon, weapData, weapOwner)

	if	weapon.cooldown <= mode_manager.time() - weapon.start
	and	weapOwner.energy - weapon.cost >= 0
	and (weapon.ammo == nil or weapon.ammo > 0)
	then
		sound.play(weapon.sound)
		weapon.fired = true
		weapon.start = mode_manager.time()

		weapOwner.energy = weapOwner.energy - weapon.cost

		if weapon.ammo ~= nil then
			weapon.ammo = weapon.ammo - 1
		end
		
		local idx = #weapData+1
		
		if weapon.image ~= nil then
			weapData[idx] = NewEntity(weapOwner, weapon.image, "Projectile", weapon.class)
		else
			weapData[idx] = NewEntity(weapOwner, weapon.fileName, "Projectile", weapon.class)
		end
		
		weapData[idx].start = mode_manager.time()
		
		if weapon.class == "beam" then
			-- [ADAM, FIX] this piece of code is a hack, it relies on what little weapons we have right now to make the assumption
			if weapOwner.switch == true then
				weapData[idx].physicsObject.position = {
				x = weapOwner.physicsObject.position.x + math.cos(weapData[idx].physicsObject.angle + 0.17) * (weapon.length - 3),
				y = weapOwner.physicsObject.position.y + math.sin(weapData[idx].physicsObject.angle + 0.17) * (weapon.length - 3) }
				weapOwner.switch = false
			else
				weapData[idx].physicsObject.position = {
				x = weapOwner.physicsObject.position.x + math.cos(weapData[idx].physicsObject.angle - 0.17) * (weapon.length - 3),
				y = weapOwner.physicsObject.position.y + math.sin(weapData[idx].physicsObject.angle - 0.17) * (weapon.length - 3) }
				weapOwner.switch = true
			end
		elseif weapon.class == "pulse" then
			return
		elseif weapon.class == "special" then
			if computerShip ~= nil then
				weapData[idx].dest = {
					x = computerShip.physicsObject.position.x,
					y = computerShip.physicsObject.position.y
				}
				weapData[idx].isSeeking = true
			else
				weapData[idx].isSeeking = false
			end
		elseif weapon.class == nil then
			LogError("Projectile '" .. entType .. "' has no class.", 12)
		else
			LogError("Unknown projectile class '" .. entClass .. "'", 11)
		end
	end
end

function WeaponUpdate(weapon, weapData, weapOwner)
-- handling for existing weapons and projectiles
	local idx
	for idx=1, #weapData do
		if weapData[idx] ~= nil then
			if weapData[idx].physicsObject == nil then
				-- this object needs to be deleted, probably the initializing table
				table.remove(weapData, idx)
				idx = idx - 1 --If we don't do this then the next element in the table will be skipped
			else
				if computerShip ~= nil then
					local x = computerShip.physicsObject.position.x - weapData[idx].physicsObject.position.x
					local y = computerShip.physicsObject.position.y - weapData[idx].physicsObject.position.y
					-- put in real collision code here [ALISTAIR, DEMO3]
					if hypot (x, y) <= computerShip.physicsObject.collision_radius * 2 / 7 then
						ProjectileCollision(weapData, idx, weapon, computerShip)
						return
					end
				end
				if mode_manager.time() - weapData[idx].start >= weapon.life then
					table.remove(weapData, idx)
					idx = idx - 1
					
					if #weapData ~= 0 then
						weapon.fired = true
					else
						weapon.fired = false
					end
				end
			end
		end
	end
end
