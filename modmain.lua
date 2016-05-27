local require = GLOBAL.require
local GetPlayer = GLOBAL.GetPlayer
local SpawnPrefab = GLOBAL.SpawnPrefab
local TUNING = GLOBAL.TUNING

local adjust_boost = GetModConfigData("adjust_boost")

local function wetanddamage(inst, other)
    --get wet and take damage
    if other and other.components.moisture then
        local hitmoisturerate = 1.0
        if other.components.driver and other.components.driver.vehicle and other.components.driver.vehicle.components.drivable then
            hitmoisturerate = other.components.driver.vehicle.components.drivable:GetHitMoistureRate()
        end
        local waterproofMultiplier = 1
        if other.components.inventory then
            waterproofMultiplier = 1 - other.components.inventory:GetWaterproofness()
        end
        other.components.moisture:DoDelta(inst.hitmoisture * hitmoisturerate * waterproofMultiplier)
    end
    if other and other.components.driver and other.components.driver.vehicle then
        local vehicle = other.components.driver.vehicle
        if vehicle.components.boathealth then
            vehicle.components.boathealth:DoDelta(inst.hitdamage, "wave")
        end
    end
end

local function splash(inst)
  local splash = SpawnPrefab("splash_water")
  local pos = inst:GetPosition()
  splash.Transform:SetPosition(pos.x, pos.y, pos.z)
  inst:Remove()
end

local function oncollidewave(inst, other, rogue) -- copy paste
    local boostThreshold = TUNING.WAVE_BOOST_ANGLE_THRESHOLD
    local player = GetPlayer()

    if not player.components.playercontroller.enabled then
      inst:Remove()
      return
    end

    if other == player then-- and inst.sg:HasStateTag("idle") then
        local moving = player.sg:HasStateTag("moving")
        local playerAngle =  other.Transform:GetRotation()
        -- fix 1 here
        --if playerAngle < 0 then playerAngle = playerAngle + 360 end

        local waveAngle = inst.Transform:GetRotation()
        -- fix 2 here
        --if waveAngle < 0 then waveAngle = waveAngle + 360 end

        local angleDiff = math.abs(waveAngle - playerAngle)
        inst.SoundEmitter:PlaySound( "dontstarve_DLC002/common/wave_break")

        -- fix 3 here,
        --if angleDiff > 360 then angleDiff = angleDiff - 360 end

				-- fix 4 here
				if angleDiff > 180 then angleDiff = 360 - angleDiff end
				
        if angleDiff < boostThreshold and moving then
            --Do boost
            local waveboost = TUNING.WAVEBOOST

            if other == player then
                if player.components.driver.vehicle and player.components.driver.vehicle.prefab == "surfboard" then
                  if rogue then
                    waveboost = TUNING.SURFBOARD_ROGUEBOOST
                  else
                    waveboost = TUNING.SURFBOARD_WAVEBOOST
                  end
                end
            end
            if adjust_boost then
              waveboost = 1.3 * waveboost * math.cos(math.rad(math.min(angleDiff,90)))
            end

            other:PushEvent("boostbywave", {position = inst.Transform:GetWorldPosition(), velocity = inst.Physics:GetVelocity(), boost = waveboost})
            inst.SoundEmitter:PlaySound( "dontstarve_DLC002/common/wave_boost")
        else
            wetanddamage(inst, other)
        end
        splash(inst)
    elseif other and other.components.waveobstacle then
        other.components.waveobstacle:OnCollide(inst)
        wetanddamage(inst, other)
        splash(inst)
    end
end


local function oncolliderogue(inst, other) -- copy paste
    -- check for surfboard, which actually just boosts
    local player = GetPlayer()

    if not player.components.playercontroller.enabled then
      inst:Remove()
      return
    end

    if other == player then
        if player.components.driver.vehicle and player.components.driver.vehicle.prefab == "surfboard" then
            oncollidewave(inst, other, true)
            return
        else
            wetanddamage(inst, other)
            splash(inst)
            return
        end
    end

    if other and other.components.waveobstacle then
        other.components.waveobstacle:OnCollide(inst)
        wetanddamage(inst, other)
        splash(inst)
    end

end

local function RipplePostInit(inst)
  inst.Physics:SetCollisionCallback(oncollidewave)
end

local function RougePostInit(inst)
  inst.Physics:SetCollisionCallback(oncolliderouge)
end

AddPrefabPostInit('wave_ripple', RipplePostInit)
AddPrefabPostInit('wave_rouge', RougePostInit)
