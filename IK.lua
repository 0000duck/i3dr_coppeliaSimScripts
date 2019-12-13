function euler_to_quaternion(r)
    local yaw = r[3]
    local pitch = r[1]
    local roll = r[2]
    local qx = math.sin(roll/2) * math.cos(pitch/2) * math.cos(yaw/2) - math.cos(roll/2) * math.sin(pitch/2) * math.sin(yaw/2)
    local qy = math.cos(roll/2) * math.sin(pitch/2) * math.cos(yaw/2) + math.sin(roll/2) * math.cos(pitch/2) * math.sin(yaw/2)
    local qz = math.cos(roll/2) * math.cos(pitch/2) * math.sin(yaw/2) - math.sin(roll/2) * math.sin(pitch/2) * math.cos(yaw/2)
    local qw = math.cos(roll/2) * math.cos(pitch/2) * math.cos(yaw/2) + math.sin(roll/2) * math.sin(pitch/2) * math.sin(yaw/2)
    return {qx,qy,qz,qw}
end

function moveToolToPosition(toolHandle,pos,ori,speed,relativeObjHandle)
    relativeObjHandle = relativeObjHandle or -1
    
    local curPos = sim.getObjectPosition(toolHandle,relativeObjHandle)
    local curOri = sim.getObjectOrientation(toolHandle,relativeObjHandle)
    local curQuad = sim.getObjectQuaternion(toolHandle,relativeObjHandle)

    sim.addStatusbarMessage("Moving tool to postition...")
    local transSpeed = speed   --[m/sec]
    local transAcc = 2.00     --[m/sec^2]
    local transJerk = 0.1

    pos_new = pos
    ori_new = ori
    for i=1,3,1 do
        if (pos[i] == -1) then
            pos_new[i] = curPos[i]
        end
        if (ori[i] == -1) then
            ori_new[i] = curOri[i]
        end
    end

    local poseVel = {transSpeed,transSpeed,transSpeed,transSpeed}
    local poseAccel = {transAcc,transAcc,transAcc,transAcc}
    local poseJerk = {transJerk,transJerk,transJerk,transJerk}

    local quad_new = euler_to_quaternion(ori_new)

    --local maxVel={0.02,0.02,0.02,0.02} -- vx,vy,vz in m/s, Vtheta is rad/s
    --local maxAccel={0.002,0.002,0.002,0.002} -- ax,ay,az in m/s^2, Atheta is rad/s^2
    --local maxJerk={0.001,0.001,0.001,0.001} -- is ignored (i.e. infinite) with RML type 2

    
    timeLeft = 9999
    --sim.moveToPosition(toolHandle,relativeObjHandle,pos_new,ori_new,transSpeed,transAcc)
    while timeLeft > 0 do
        res,newPos,newQuaternion,newVel,newAccel,timeLeft = sim.rmlMoveToPosition(toolHandle,relativeObjHandle,-1,nil,nil,poseVel,poseAccel,poseJerk,pos_new,quad_new,nil)
        --sim.addStatusbarMessage("res: " .. res .. " time: " .. timeLeft)
        if (sim.getSimulationState()==sim.simulation_advancing_abouttostop) then
            sim.addStatusbarMessage("Tool movement aborted due to simulation 'about to stop'")
            return
        end
        if (timeLeft ~= nil) then
            if (timeLeft <= 0.05) then
                break
            end
        end
    end
end