require 'i3dr/Generic'

function fireNailGun(targetObjHandle,toolTargetHandle,isUp)
    local nailLength = 0.03
    local nailDiam = 0.005
    local nailHeadDiam = nailDiam*4
    local nailHeadThickness = 0.005
    -- get current tool position
    local nailPos = sim.getObjectPosition(toolTargetHandle,-1)
    local nailOri = sim.getObjectOrientation(toolTargetHandle,-1)
    local nailHeadPos = sim.getObjectPosition(toolTargetHandle,-1)
    local nailHeadOri = sim.getObjectOrientation(toolTargetHandle,-1)
    if (isUp) then
        nailPos[3] = nailPos[3] + (nailLength/2)
    else
        nailPos[3] = nailPos[3] - (nailLength/2)
    end
    
    -- create nail object
    local nailObjHandle = sim.createPureShape(2,16,{nailDiam,nailDiam,nailLength},1)
    local nailHeadObjHandle = sim.createPureShape(2,16,{nailHeadDiam,nailHeadDiam,nailHeadThickness},1)
    sim.setObjectInt32Parameter(nailObjHandle,sim.shapeintparam_static,1)
    sim.setObjectInt32Parameter(nailObjHandle,sim.shapeintparam_respondable,0)
    sim.setObjectInt32Parameter(nailHeadObjHandle,sim.shapeintparam_static,1)
    sim.setObjectInt32Parameter(nailHeadObjHandle,sim.shapeintparam_respondable,0)
    sim.setShapeColor(nailObjHandle,nil,sim.colorcomponent_ambient_diffuse,{0.2,0.2,0.2})
    sim.setShapeColor(nailHeadObjHandle,nil,sim.colorcomponent_ambient_diffuse,{0.2,0.2,0.2})
    local randomChars = randomString(6)
    local randomNailName = "nailObj_" .. randomChars
    local randomNailHeadName = "nailHeadObj_" .. randomChars
    sim.setObjectName(nailObjHandle,randomNailName)
    sim.setObjectName(nailHeadObjHandle,randomNailHeadName)
    -- place nail object at current tool position
    sim.setObjectPosition(nailObjHandle,-1,nailPos)
    sim.setObjectOrientation(nailObjHandle,-1,nailOri)
    sim.setObjectPosition(nailHeadObjHandle,-1,nailHeadPos)
    sim.setObjectOrientation(nailHeadObjHandle,-1,nailHeadOri)
    -- set nail object as child of target object
    sim.setObjectParent(nailObjHandle,targetObjHandle,true)
    sim.setObjectParent(nailHeadObjHandle,nailObjHandle,true)
end
