require 'i3dr/IK'
require 'i3dr/NailGun'

function setupRobot(name_suffix)
    ROBOT_END_EFFECTOR_GRIPPER = 0
    ROBOT_END_EFFECTOR_LASER = 1
    ROBOT_END_EFFECTOR_NAIL_GUN = 2
    ROBOT_END_EFFECTOR_EXTRUDER = 3

    currentRobotEndEffectorHandle = -1

    gripperTool = sim.getObjectHandle("SRMG"..name_suffix)
    gripper_IK_PI = sim.getIkGroupHandle("KUKA_Gripper_PI"..name_suffix)
    gripper_IK_DLS = sim.getIkGroupHandle("KUKA_Gripper_DLS"..name_suffix)
    gripper_tip = sim.getObjectHandle("SRMG_graspingTip"..name_suffix)
    gripper_target = sim.getObjectHandle("SRMG_graspingTarget"..name_suffix)
    
    laserTool = sim.getObjectHandle("LCT"..name_suffix)
    laser_IK_PI = sim.getIkGroupHandle("KUKA_Laser_PI"..name_suffix)
    laser_IK_DLS = sim.getIkGroupHandle("KUKA_Laser_DLS"..name_suffix)
    laser_tip = sim.getObjectHandle("LCT_laserTip"..name_suffix)
    laser_target = sim.getObjectHandle("LCT_laserTarget"..name_suffix)
    laserBeam = sim.getObjectHandle("LCT_laserBeam"..name_suffix)
    
    nailGunTool = sim.getObjectHandle("NGT"..name_suffix)
    nailGun_IK_PI = sim.getIkGroupHandle("KUKA_NailGun_PI"..name_suffix)
    nailGun_IK_DLS = sim.getIkGroupHandle("KUKA_NailGun_DLS"..name_suffix)
    nailGun_tip = sim.getObjectHandle("NGT_nailGunTip"..name_suffix)
    nailGun_target = sim.getObjectHandle("NGT_nailTarget"..name_suffix)

    extrusionTool = sim.getObjectHandle("MExT"..name_suffix)
    extrusion_IK_PI = sim.getIkGroupHandle("KUKA_Extrusion_PI"..name_suffix)
    extrusion_IK_DLS = sim.getIkGroupHandle("KUKA_Extrusion_DLS"..name_suffix)
    extrusion_tip = sim.getObjectHandle("MExT_extrusionTip"..name_suffix)
    extrusion_target = sim.getObjectHandle("MExT_extrusionTarget"..name_suffix)
    MExT_enabled_signal = "MExT_enabled"..name_suffix
    MExT_parent_obj_signal = "MExT_parent_obj"..name_suffix
    MExt_bead_width_signal = "MExT_bead_width"..name_suffix
    MExt_bead_colour_signal = "MExt_bead_colour"..name_suffix

    robot_end_effector_start = sim.getObjectPosition(gripper_target, -1)
    robot_end_effector_home = sim.getObjectPosition(sim.getObjectHandle("SRMG_graspHome"..name_suffix), -1)
    robot_end_effector_collector = sim.getObjectPosition(sim.getObjectHandle("SRMG_graspCollector"..name_suffix), -1)
end

function selectRobotEndEffector(index)
    local toolDefined = false
    local prevPos = -1
    local prevOri = -1
    if (not (currentRobotEndEffectorHandle == -1)) then
        toolDefined = true
        prevPos = sim.getObjectPosition(currentRobotEndEffectorHandle,-1)
        prevOri = sim.getObjectOrientation(currentRobotEndEffectorHandle,-1)
    end

    robotEndEffectorDisableAll()

    if (index == ROBOT_END_EFFECTOR_GRIPPER) then
        sim.addStatusbarMessage("Robot End Effector: Gripper")
        currentRobotEndEffectorHandle = gripper_target
        robotGripperEnable(true)
    elseif (index == ROBOT_END_EFFECTOR_LASER) then
        sim.addStatusbarMessage("Robot End Effector: Laser")
        currentRobotEndEffectorHandle = laser_target
        robotLaserEnable(true)
    elseif (index == ROBOT_END_EFFECTOR_NAIL_GUN) then
        sim.addStatusbarMessage("Robot End Effector: Nail Gun")
        currentRobotEndEffectorHandle = nailGun_target
        robotNailGunEnable(true)
    elseif (index == ROBOT_END_EFFECTOR_EXTRUDER) then
        sim.addStatusbarMessage("Robot End Effector: Extruder")
        currentRobotEndEffectorHandle = extrusion_target
        robotExtruderEnable(true)
    end

    if (toolDefined) then
        sim.setObjectPosition(currentRobotEndEffectorHandle,-1,prevPos)
        sim.setObjectOrientation(currentRobotEndEffectorHandle,-1,prevOri)
    end
end

function robotEndEffectorDisableAll()
    robotGripperEnable(false)
    robotLaserEnable(false)
    robotNailGunEnable(false)
    robotExtruderEnable(false)
end

function robotGripperEnable(en)
    if en then
        sim.addStatusbarMessage("enabling gripper tool")
        sim.setExplicitHandling(gripper_IK_PI,0)
        sim.setExplicitHandling(gripper_IK_DLS,0)
        local c = sim.ik_x_constraint + sim.ik_y_constraint + 
            sim.ik_z_constraint + sim.ik_alpha_beta_constraint + 
            sim.ik_gamma_constraint
        sim.setIkElementProperties(gripper_IK_PI,gripper_tip,c)
        sim.setIkElementProperties(gripper_IK_DLS,gripper_tip,c)
        sim.setModelProperty(gripperTool,0)
    else
        sim.addStatusbarMessage("disabling gripper tool")
        sim.setExplicitHandling(gripper_IK_PI,1)
        sim.setExplicitHandling(gripper_IK_DLS,1)
        sim.setIkElementProperties(gripper_IK_PI,gripper_tip,0)
        sim.setIkElementProperties(gripper_IK_DLS,gripper_tip,0)
        sim.setModelProperty(gripperTool,sim.modelproperty_not_visible)
    end
end

function robotLaserEnable(en)
    robotLaserBeamEnabled(false)
    if en then
        sim.addStatusbarMessage("enabling laser tool")
        sim.setExplicitHandling(laser_IK_PI,0)
        sim.setExplicitHandling(laser_IK_DLS,0)
        local c = sim.ik_x_constraint + sim.ik_y_constraint + 
            sim.ik_z_constraint + sim.ik_alpha_beta_constraint + 
            sim.ik_gamma_constraint
        sim.setIkElementProperties(laser_IK_PI,laser_tip,c)
        sim.setIkElementProperties(laser_IK_DLS,laser_tip,c)
        sim.setModelProperty(laserTool,0)
    else
        sim.addStatusbarMessage("disabling laser tool")
        sim.setExplicitHandling(laser_IK_PI,1)
        sim.setExplicitHandling(laser_IK_DLS,1)
        sim.setIkElementProperties(laser_IK_PI,laser_tip,0)
        sim.setIkElementProperties(laser_IK_DLS,laser_tip,0)
        sim.setModelProperty(laserTool,sim.modelproperty_not_visible)
    end
end

function robotNailGunEnable(en)
    if en then
        sim.addStatusbarMessage("enabling nail gun tool")
        sim.setExplicitHandling(nailGun_IK_PI,0)
        sim.setExplicitHandling(nailGun_IK_DLS,0)
        local c = sim.ik_x_constraint + sim.ik_y_constraint + 
            sim.ik_z_constraint + sim.ik_alpha_beta_constraint + 
            sim.ik_gamma_constraint
        sim.setIkElementProperties(nailGun_IK_PI,nailGun_tip,c)
        sim.setIkElementProperties(nailGun_IK_DLS,nailGun_tip,c)
        sim.setModelProperty(nailGunTool,0)
    else
        sim.addStatusbarMessage("disabling nail gun tool")
        sim.setExplicitHandling(nailGun_IK_PI,1)
        sim.setExplicitHandling(nailGun_IK_DLS,1)
        sim.setIkElementProperties(nailGun_IK_PI,nailGun_tip,0)
        sim.setIkElementProperties(nailGun_IK_DLS,nailGun_tip,0)
        sim.setModelProperty(nailGunTool,sim.modelproperty_not_visible)
    end
end

function robotExtruderEnable(en)
    if en then
        sim.addStatusbarMessage("enabling material extrusion tool")
        sim.setExplicitHandling(extrusion_IK_PI,0)
        sim.setExplicitHandling(extrusion_IK_DLS,0)
        local c = sim.ik_x_constraint + sim.ik_y_constraint + 
            sim.ik_z_constraint + sim.ik_alpha_beta_constraint + 
            sim.ik_gamma_constraint
        sim.setIkElementProperties(extrusion_IK_PI,extrusion_tip,c)
        sim.setIkElementProperties(extrusion_IK_DLS,extrusion_tip,c)
        sim.setModelProperty(extrusionTool,0)
    else
        sim.addStatusbarMessage("disabling material extrusion tool")
        sim.setExplicitHandling(extrusion_IK_PI,1)
        sim.setExplicitHandling(extrusion_IK_DLS,1)
        sim.setIkElementProperties(extrusion_IK_PI,extrusion_tip,0)
        sim.setIkElementProperties(extrusion_IK_DLS,extrusion_tip,0)
        sim.setModelProperty(extrusionTool,sim.modelproperty_not_visible)
    end
end

function robotLaserBeamEnabled(en)
    if en then
        sim.setObjectInt32Parameter(laserBeam,10,1)
    else
        sim.setObjectInt32Parameter(laserBeam,10,0)
    end
end

function robotExtruderOn(en,parentHandle,beadWidth,beadColour)
    sim.setIntegerSignal(MExT_parent_obj_signal,parentHandle)
    sim.setFloatSignal(MExt_bead_width_signal,beadWidth)
    sim.setStringSignal(MExt_bead_colour_signal,sim.packTable(beadColour))
    if en then
        sim.setIntegerSignal(MExT_enabled_signal,1)
    else
        sim.setIntegerSignal(MExT_enabled_signal,0)
    end
end

function updateRobotEndEffectorTargets()
    local toolPos = sim.getObjectPosition(currentRobotEndEffectorHandle,-1)
    local toolOri = sim.getObjectOrientation(currentRobotEndEffectorHandle,-1)
    sim.setObjectPosition(gripper_target,-1,toolPos)
    sim.setObjectOrientation(gripper_target,-1,toolOri)
    sim.setObjectPosition(laser_target,-1,toolPos)
    sim.setObjectOrientation(laser_target,-1,toolOri)
    sim.setObjectPosition(nailGun_target,-1,toolPos)
    sim.setObjectOrientation(nailGun_target,-1,toolOri)
    sim.setObjectPosition(extrusion_target,-1,toolPos)
    sim.setObjectOrientation(extrusion_target,-1,toolOri)
end

function moveObjectToTargetZ(objHandle,targetHandle,speed)
    while sim.getSimulationState()~=sim.simulation_advancing_abouttostop do
        local p = sim.getObjectPosition(objHandle,targetHandle)
        if (p[3] > 0 + (speed*sim.getSimulationTimeStep())) then
            p[3]=p[3] - (speed*sim.getSimulationTimeStep())
        elseif(p[3] < 0 - (speed*sim.getSimulationTimeStep())) then
            p[3]=p[3] + (speed*sim.getSimulationTimeStep())
        else
            p[3] = 0
            sim.setObjectPosition(objHandle,targetHandle,p)
            return
        end
        sim.setObjectPosition(objHandle,targetHandle,p)
        sim.switchThread() -- resume in next simulation step
    end
end

function moveRobotEndEffectorToPos(pos,ori,speed,relativeObjHandle)
    moveToolToPosition(currentRobotEndEffectorHandle,pos,ori,speed,relativeObjHandle)
    updateRobotEndEffectorTargets()
end

function grabObj(objHandle)
    sim.addStatusbarMessage("Grabbing object...")
    sim.resetDynamicObject(objHandle)
    sim.setObjectInt32Parameter(objHandle,sim.shapeintparam_static,1)
    sim.setObjectInt32Parameter(objHandle,sim.shapeintparam_respondable,0)
    sim.setObjectParent(objHandle,currentRobotEndEffectorHandle,1)
end

function dropObj(objHandle,parent,isNoCollide)
    sim.addStatusbarMessage("Dropping object...")
    sim.setObjectParent(objHandle,parent,1)
    if (not isNoCollide) then
        sim.resetDynamicObject(objHandle)
        sim.setObjectInt32Parameter(objHandle,sim.shapeintparam_static,0)
        sim.setObjectInt32Parameter(objHandle,sim.shapeintparam_respondable,1)
    end
end

function robotFireNailGun(targetObjHandle)
    fireNailGun(targetObjHandle,currentRobotEndEffectorHandle,false)
end

function robotExtrusionFillCube(relObjHandle,parent,x,y,z,w,l,h,beadWidth,speed,colour)
    local layerWidth = (beadWidth/1.5)
    local layer_index = 0
    local isCubeComplete = false
    local nextZ = z
    while ((not isCubeComplete) and (sim.getSimulationState()~=sim.simulation_advancing_abouttostop)) do
        layer_index = layer_index + 1
        local nextZ_top = (layerWidth * layer_index) + z
        -- sim.addStatusbarMessage(nextZ_top)
        if (nextZ_top > h+z) then
            isCubeComplete = true
        else
            moveRobotEndEffectorToPos({x,y,nextZ},{-1,-1,-1},speed,relObjHandle)
            robotExtruderOn(true,parent,beadWidth,colour)
            robotExtrusionFillSquare(relObjHandle,x,y,nextZ,w,l,beadWidth,speed)
            robotExtruderOn(false,parent,beadWidth,colour)
            nextZ = nextZ_top
        end
    end
end

function robotExtrusionFillSquare(relObjHandle,x,y,z,w,h,beadWidth,speed)
    local startPos = {x,y,z}
    --local startOri = {0,0,0}
    
    moveRobotEndEffectorToPos(startPos,{-1,-1,-1},speed,relObjHandle)
    --sim.setObjectPosition(currentRobotEndEffectorHandle,relObjHandle,startPos)
    --sim.setObjectOrientation(currentRobotEndEffectorHandle,relObjHandle,startOri)
    
    local x_dir = 1
    local y_dir = 1
    if (w < 0) then
        x_dir = -1
    end
    if (h < 0) then
        y_dir = -1
    end
    
    local lineWidth = (beadWidth/1.5)*y_dir
    
    
    local line_index = 0
    local isSquareComplete = false
    while not isSquareComplete do
        local nextPos = {0,0,0}
        local isLineComplete = false
        while (not isLineComplete and not isSquareComplete) do
            if (sim.getSimulationState()~=sim.simulation_advancing_abouttostop) then
                local curPos = sim.getObjectPosition(currentRobotEndEffectorHandle,relObjHandle)
                nextPos = curPos
                nextPos[1] = curPos[1] + (speed*sim.getSimulationTimeStep()*x_dir)
                nextPos[2] = curPos[2]
                nextPos[3] = curPos[3]

                if (h >= 0) then
                    if (nextPos[2] >= h+y) then
                        isSquareComplete = true
                        break
                    end
                else
                    if (nextPos[2] <= h+y) then
                        isSquareComplete = true
                        break
                    end
                end

                --moveRobotEndEffectorToPos(nextPos,{-1,-1,-1},speed,relObjHandle)
                sim.setObjectPosition(currentRobotEndEffectorHandle,relObjHandle,nextPos)
                --sim.setObjectOrientation(currentRobotEndEffectorHandle,relObjHandle,startOri)
                if (w >= 0) then
                    if (nextPos[1] >= w+x) then
                        isLineComplete = true
                    end
                else
                    if (nextPos[1] <= w+x) then
                        isLineComplete = true
                    end
                end
                sim.switchThread() -- resume in next simulation step
            end
        end
        line_index = line_index + 1
        isLineComplete = false
        while (not isLineComplete and not isSquareComplete) do
            if (sim.getSimulationState()~=sim.simulation_advancing_abouttostop) then
                local curPos = sim.getObjectPosition(currentRobotEndEffectorHandle,relObjHandle)
                local posIncrease = (speed*sim.getSimulationTimeStep()*y_dir)
                nextPos = {curPos[1],curPos[2]+posIncrease,curPos[3]}

                if (h >= 0) then
                    if (nextPos[2] >= h+y) then
                        isSquareComplete = true
                        break
                    end
                else
                    if (nextPos[2] <= h+y) then
                        isSquareComplete = true
                        break
                    end
                end

                sim.setObjectPosition(currentRobotEndEffectorHandle,relObjHandle,nextPos)
                --moveRobotEndEffectorToPos(nextPos,{-1,-1,-1},speed,relObjHandle)

                if (y_dir > 0) then
                    if (nextPos[2] >= ((lineWidth*line_index)+y)) then
                        isLineComplete = true
                    end
                else
                    if (nextPos[2] <= ((lineWidth*line_index)+y)) then
                        isLineComplete = true
                    end
                end
                sim.switchThread() -- resume in next simulation step
            end
        end
        isLineComplete = false
        while (not isLineComplete and not isSquareComplete) do
            if (sim.getSimulationState()~=sim.simulation_advancing_abouttostop) then
                local curPos = sim.getObjectPosition(currentRobotEndEffectorHandle,relObjHandle)
                nextPos = curPos
                nextPos[1] = curPos[1] - (speed*sim.getSimulationTimeStep()*x_dir)
                nextPos[2] = curPos[2]
                nextPos[3] = curPos[3]

                if (h >= 0) then
                    if (nextPos[2] >= h+y) then
                        isSquareComplete = true
                        break
                    end
                else
                    if (nextPos[2] <= h+y) then
                        isSquareComplete = true
                        break
                    end
                end

                --moveRobotEndEffectorToPos(nextPos,{-1,-1,-1},speed,relObjHandle)
                sim.setObjectPosition(currentRobotEndEffectorHandle,relObjHandle,nextPos)
                --sim.setObjectOrientation(currentRobotEndEffectorHandle,relObjHandle,startOri)

                if (w >= 0) then
                    if (nextPos[1] <= x) then
                        isLineComplete = true
                    end
                else
                    if (nextPos[1] >= x) then
                        isLineComplete = true
                    end
                end
                sim.switchThread() -- resume in next simulation step
            end
        end
        line_index = line_index + 1
        isLineComplete = false
        while (not isLineComplete and not isSquareComplete) do
            if (sim.getSimulationState()~=sim.simulation_advancing_abouttostop) then
                local curPos = sim.getObjectPosition(currentRobotEndEffectorHandle,relObjHandle)
                local posIncrease = (speed*sim.getSimulationTimeStep()*y_dir)
                nextPos = {curPos[1],curPos[2]+posIncrease,curPos[3]}

                if (h >= 0) then
                    if (nextPos[2] >= h+y) then
                        isSquareComplete = true
                        break
                    end
                else
                    if (nextPos[2] <= h+y) then
                        isSquareComplete = true
                        break
                    end
                end
                
                --moveRobotEndEffectorToPos(nextPos,{-1,-1,-1},speed,relObjHandle)
                sim.setObjectPosition(currentRobotEndEffectorHandle,relObjHandle,nextPos)

                if (y_dir > 0) then
                    if (nextPos[2] >= ((lineWidth*line_index)+y)) then
                        isLineComplete = true
                    end
                else
                    if (nextPos[2] <= ((lineWidth*line_index)+y)) then
                        isLineComplete = true
                    end
                end
                sim.switchThread() -- resume in next simulation step
            end
        end
    end
    updateRobotEndEffectorTargets()
end