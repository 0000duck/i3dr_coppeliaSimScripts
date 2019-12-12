require 'i3dr/IK'
require 'i3dr/NailGun'

function setupCNCFramer()
    CNCFramer_nailGun_target = sim.getObjectHandle("Framer_CNC_nail_target")

    framer_cnc_BottomSheath_target = sim.getObjectHandle("Framer_CNC_bottomSheath_target")
    framer_cnc_TopSheath_target = sim.getObjectHandle("Framer_CNC_topSheath_target")
end

function moveCNCFramerToolToPos(pos,ori,speed,relativeObjHandle)
    moveToolToPosition(CNCFramer_nailGun_target,pos,ori,speed,relativeObjHandle)
end

function CNCFramerFireNailGun(targetObjHandle)
    fireNailGun(targetObjHandle,CNCFramer_nailGun_target,true)
end