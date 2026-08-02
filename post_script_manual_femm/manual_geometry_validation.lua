function vector_z_rotation_matrix(x, y, theta)
    -- matrix multiplication formula
    local new_x = x * cos(theta) - y * sin(theta)
    local new_y = x * sin(theta) + y * cos(theta)
    return new_x, new_y
end

function run_calculations(parameters)
    -- parameters
    local session_id = parameters.session_id
    local empty_material = parameters.empty_material
    local depth = parameters.depth

    local stator_r_out = parameters.stator_r_out
    local stator_out_d = parameters.stator_out_d
    local stator_r_in = stator_r_out-stator_out_d
    local stator_material = parameters.stator_material

    local mag_size_x = parameters.mag_size_x
    local mag_size_y = parameters.mag_size_y
    local mag_count = parameters.mag_count
    local mag_material = parameters.mag_material

    local rotor_core_r = parameters.rotor_core_r
    local rotor_core_material = parameters.rotor_core_material
    local plastic_material = parameters.plastic_material

    local coil_groove_in_r = parameters.coil_groove_in_r
    local coil_groove_out_r = parameters.coil_groove_out_r
    local coil_groove_ang = parameters.coil_groove_ang
    local coil_groove_count = parameters.coil_groove_count
    local coil_turns = parameters.coil_turns
    local coil_amps = parameters.coil_amps
    local coil_material = parameters.coil_material

    newdocument(0)
    mi_probdef(0, "millimeters", "planar", 1e-8, depth, 30)

    mi_getmaterial(empty_material)
    mi_getmaterial(mag_material)
    mi_getmaterial(stator_material)
    mi_getmaterial(plastic_material)
    mi_getmaterial(rotor_core_material)
    mi_getmaterial(coil_material)

    mi_maximize()

    -- OUT STATOR
    for i = 0, 3 do
        local theta = (PI/2) * i
        local fi = (PI/2) * (i + 1)
        
        local x1 = stator_r_out * cos(theta)
        local y1 = stator_r_out * sin(theta)
        local x2 = stator_r_out * cos(fi)
        local y2 = stator_r_out * sin(fi)
        
        mi_addnode(x1, y1)
        mi_addnode(x2, y2)
        mi_addarc(x1, y1, x2, y2, 90, 1)
    end

    -- IN STATOR
    for i = 0, 3 do
        local theta = (PI/2) * i
        local fi = (PI/2) * (i + 1)
        
        local x1 = stator_r_in * cos(theta)
        local y1 = stator_r_in * sin(theta)
        local x2 = stator_r_in * cos(fi)
        local y2 = stator_r_in * sin(fi)
        
        mi_addnode(x1, y1)
        mi_addnode(x2, y2)
        mi_addarc(x1, y1, x2, y2, 90, 1)
    end

    -- STATOR MATERIAL
    mi_addblocklabel(0, stator_r_out-(stator_out_d/2))
    mi_selectlabel(0, stator_r_out-(stator_out_d/2))
    mi_setblockprop(stator_material, 1, 0, "<None>", 0, 1, 0)
    mi_clearselected()

    mag_node_sw_x = mag_size_x/2
    mag_node_sw_y = sqrt(stator_r_in^2 - mag_node_sw_x^2)

    -- first magnet
    mag_node_sw = {mag_node_sw_x, -mag_node_sw_y}
    mag_node_se = {-mag_node_sw_x, -mag_node_sw_y}
    mag_node_nw = {mag_node_sw_x, -mag_node_sw_y+mag_size_y}
    mag_node_ne = {-mag_node_sw_x, -mag_node_sw_y+mag_size_y}
    mag_node_center = {0, mag_node_nw[2]-(mag_size_y/2)}

    local correction_theta = (PI)/mag_count

    for i = 0, mag_count-1 do
        local theta = (2 * PI * i / mag_count) + correction_theta

        local sw_x, sw_y = vector_z_rotation_matrix(mag_node_sw[1], mag_node_sw[2], theta)
        local se_x, se_y = vector_z_rotation_matrix(mag_node_se[1], mag_node_se[2], theta)
        local nw_x, nw_y = vector_z_rotation_matrix(mag_node_nw[1], mag_node_nw[2], theta)
        local ne_x, ne_y = vector_z_rotation_matrix(mag_node_ne[1], mag_node_ne[2], theta)
        local center_x, center_y = vector_z_rotation_matrix(mag_node_center[1], mag_node_center[2], theta)
        
        -- AIR MATERIAL
        if i == 0 then 
            mi_addblocklabel(nw_x, nw_y+0.01)
            mi_selectlabel(nw_x, nw_y+0.01)
            mi_setblockprop(empty_material, 1, 0, "<None>", 0, 1, 0)
            mi_clearselected()
        end

        mi_addnode(sw_x, sw_y)
        mi_addnode(se_x, se_y)
        mi_addnode(nw_x, nw_y)
        mi_addnode(ne_x, ne_y)

        mi_addsegment(sw_x, sw_y, se_x, se_y)
        mi_addsegment(se_x, se_y, ne_x, ne_y)
        mi_addsegment(ne_x, ne_y, nw_x, nw_y)
        mi_addsegment(nw_x, nw_y, sw_x, sw_y)

        -- AIR BEHIND MAGNET AND MAGNET MATERIAL
        mi_addblocklabel(center_x, center_y)
        mi_selectlabel(center_x, center_y)

        local fi = (theta * 180) / PI + 90
        
        if i >= (mag_count-1)/2 then 
            fi = fi + 180 
        end

        mi_setblockprop(mag_material, 1, 0, "<None>", fi, 1, 0)
        mi_clearselected()

        local air_pos_x, air_pos_y = vector_z_rotation_matrix(mag_node_center[1], (mag_node_center[2]-(mag_size_y/2+0.01)), theta)
        mi_addblocklabel(air_pos_x, air_pos_y)
        mi_selectlabel(air_pos_x, air_pos_y)
        mi_setblockprop(empty_material, 1, 0, "<None>", 0, 1, 0)
        mi_clearselected()
    end

    -- ROTOR
    for i = 0, 3 do
        local theta = (PI/2) * i
        local fi = (PI/2) * (i + 1)
        
        local x1 = rotor_core_r * cos(theta)
        local y1 = rotor_core_r * sin(theta)
        local x2 = rotor_core_r * cos(fi)
        local y2 = rotor_core_r * sin(fi)
        
        mi_addnode(x1, y1)
        mi_addnode(x2, y2)
        mi_addarc(x1, y1, x2, y2, 90, 1)
    end

    -- ROTOR MATERIAL
    mi_addblocklabel(0, 0)
    mi_selectlabel(0, 0)
    mi_setblockprop(rotor_core_material, 1, 0, "<None>", 0, 2, 0)
    mi_clearselected()

    -- WINDINGS
    mi_addcircprop("Winding", coil_amps, 1)

    local correction_theta_coil = (PI/coil_groove_count) - (PI/2)

    for i = 0, coil_groove_count-1 do
        local theta = ((2 * PI)/coil_groove_count) * i

        local in_x = coil_groove_in_r * cos(theta)
        local in_y = coil_groove_in_r * sin(theta)

        local rotated_in_x, rotated_in_y = vector_z_rotation_matrix(in_x, in_y, correction_theta_coil)

        mi_addnode(rotated_in_x, rotated_in_y)
        
        local fi = ((coil_groove_ang*2*PI)/360)/2
        local out_x1 = coil_groove_out_r * cos(theta+fi)
        local out_y1 = coil_groove_out_r * sin(theta+fi)

        local out_x2 = coil_groove_out_r * cos(theta-fi)
        local out_y2 = coil_groove_out_r * sin(theta-fi)
        
        local rotated_out_x1, rotated_out_y1 = vector_z_rotation_matrix(out_x1, out_y1, correction_theta_coil)
        local rotated_out_x2, rotated_out_y2 = vector_z_rotation_matrix(out_x2, out_y2, correction_theta_coil)

        mi_addnode(rotated_out_x1, rotated_out_y1)
        mi_addnode(rotated_out_x2, rotated_out_y2)

        mi_addsegment(rotated_in_x, rotated_in_y, rotated_out_x1, rotated_out_y1)
        mi_addsegment(rotated_in_x, rotated_in_y, rotated_out_x2, rotated_out_y2)
        mi_addarc(rotated_out_x2, rotated_out_y2, rotated_out_x1, rotated_out_y1, 2 * asin(sqrt((rotated_out_x1 - rotated_out_x2)^2 + (rotated_out_y1 - rotated_out_y2)^2) / (2 * coil_groove_out_r)) * (180 / PI), 1)
        
        local theta_prev = ((2 * PI)/coil_groove_count) * (i - 1)
        local prev_out_x1 = coil_groove_out_r * cos(theta_prev + fi)
        local prev_out_y1 = coil_groove_out_r * sin(theta_prev + fi)

        local rotated_prev_out_x1, rotated_prev_out_y1 = vector_z_rotation_matrix(prev_out_x1, prev_out_y1, correction_theta_coil)
        
        if i ~= 0 then 
            mi_addarc(rotated_prev_out_x1, rotated_prev_out_y1, rotated_out_x2, rotated_out_y2, 2 * asin(sqrt((rotated_out_x2 - rotated_prev_out_x1)^2 + (rotated_out_y2 - rotated_prev_out_y1)^2) / (2 * coil_groove_out_r)) * (180 / PI), 1)
        end
        
        -- LABELING
           local direction = 1
            if i >= coil_groove_count / 2 then
                direction = -1
            end
        
        local label_x = (coil_groove_in_r+0.1) * cos(theta)
        local label_y = (coil_groove_in_r+0.1) * sin(theta)

        local rotated_label_x, rotated_label_y = vector_z_rotation_matrix(label_x, label_y, correction_theta_coil)
        
        -- WINDING MATERIAL
        mi_addblocklabel(rotated_label_x, rotated_label_y)
        mi_selectlabel(rotated_label_x, rotated_label_y)
        mi_setblockprop(coil_material, 1, 0, "Winding", 0, 2, direction*coil_turns)
        mi_clearselected()
    end

    --last connection
    local fi_last = ((coil_groove_ang*2*PI)/360)/2
    local theta_first = 0
    local first_out_x2 = coil_groove_out_r * cos(theta_first - fi_last)
    local first_out_y2 = coil_groove_out_r * sin(theta_first - fi_last)
    local theta_last = ((2 * PI)/coil_groove_count) * (coil_groove_count - 1)
    local last_out_x1 = coil_groove_out_r * cos(theta_last + fi_last)
    local last_out_y1 = coil_groove_out_r * sin(theta_last + fi_last)

    local rotated_first_out_x2, rotated_first_out_y2 = vector_z_rotation_matrix(first_out_x2, first_out_y2, correction_theta_coil)
    local rotated_last_out_x1, rotated_last_out_y1 = vector_z_rotation_matrix(last_out_x1, last_out_y1, correction_theta_coil)
    mi_addarc(rotated_last_out_x1, rotated_last_out_y1, rotated_first_out_x2, rotated_first_out_y2, 2 * asin(sqrt((rotated_first_out_x2 - rotated_last_out_x1)^2 + (rotated_first_out_y2 - rotated_last_out_y1)^2) / (2 * coil_groove_out_r)) * (180 / PI), 1)

    -- NON CORE ROTOR MATERIAL
    mi_addblocklabel(0, rotor_core_r+0.01)
    mi_selectlabel(0, rotor_core_r+0.01)
    mi_setblockprop(plastic_material, 1, 0, "<None>", 0, 2, 0)
    mi_clearselected()
    
    mi_zoomnatural()
    
    mi_saveas("motor_geometry.FEM")
    -- pause()
    
    mi_analyze()
    mi_loadsolution()
    
    mo_showdensityplot(1, 0, 0.6, 0, "bmag")
    mo_groupselectblock(2)
    local stress_tensor_torque = mo_blockintegral(22)
    mo_clearblock()

    -- OUTPUT
    local R = stator_r_out - stator_out_d
    local w = mag_size_x
    local h = mag_size_y
    local d_zewn = sqrt(R^2 - (w / 2)^2)
    local d_min = d_zewn - h
        
    local impedance_correction_factor = 1.45
    local current, volts, flux_re = mo_getcircuitproperties("Winding")
    local impedance = (volts/current)*impedance_correction_factor
    local volts = current*impedance
    local k_const = stress_tensor_torque/current
        
    local v_supply = 24 --VOLTS CHOSEN FOR COMPARASON
    local omega_nom = (v_supply - volts)/k_const
    local rpm_nom = (omega_nom*30)/(PI)
    local power_nom = omega_nom * stress_tensor_torque
        
    local power_elec = v_supply * current
    local efficiency_nom = (power_nom / power_elec) * 100 --%
        
    local air_gap = d_min - coil_groove_out_r

    print("")
    print("")
    print("index: " .. session_id)
    print("stress_tensor_torque: " .. stress_tensor_torque)
    print("air_gap: " .. air_gap)
        
    print("current: " .. current)
    print("volts: " .. volts)
    print("impedance: " .. impedance)
    print("flux_re: " .. flux_re)
        
    print("k_const: " .. k_const)
    print("v_supply: " .. v_supply)
    print("omega_nom: " .. omega_nom)
    print("rpm_nom: " .. rpm_nom)
    print("power_nom: " .. power_nom)
    print("efficiency_nom: " .. efficiency_nom)

    print("depth: " .. depth)

    print("stator_r_out: " .. stator_r_out)
    print("stator_out_d: " .. stator_out_d)
    print("rotor_core_r: " .. rotor_core_r)

    print("mag_size_x: " .. mag_size_x)
    print("mag_size_y: " .. mag_size_y)
    print("mag_count: " .. mag_count)

    print("coil_groove_in_r: " .. coil_groove_in_r)
    print("coil_groove_out_r: " .. coil_groove_out_r)
    print("coil_groove_ang: " .. coil_groove_ang)
    print("coil_groove_count: " .. coil_groove_count)
    print("coil_amps: " .. coil_amps)
    print("coil_turns: " .. coil_turns)

    print("mag_material: " .. mag_material)
    print("rotor_core_material: " .. rotor_core_material)
    print("stator_material: " .. stator_material)
    print("plastic_material: " .. plastic_material)
    print("coil_material: " .. coil_material)
end

dofile("femm_input.lua")
showconsole()
local i = 1
while parameters_list[i] ~= nil do
    run_calculations(parameters_list[i])
    i = i + 1
end