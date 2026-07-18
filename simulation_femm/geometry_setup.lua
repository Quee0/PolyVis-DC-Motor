-- input_parameters = {
--     session_id = 1,
--     empty_material = "Air",
--     depth = 50,

--     stator_r_out = 10.65,
--     stator_out_d = 2,
--     stator_material = "1117 Steel",

--     mag_size_x = 4,
--     mag_size_y = 0.5,
--     mag_size_z = depth,
--     mag_count = 8,
--     mag_material = "N45",

--     rotor_core_r = 3.5,
--     rotor_core_material = "1117 Steel",
--     plastic_material = "Air",

--     coil_groove_in_r = 4,
--     coil_groove_out_r = 7,
--     coil_groove_ang = 10, --not rad
--     coil_groove_count = 12,
--     coil_turns = 20,
--     coil_amps = 4,
--     coil_material = "24 AWG",
-- }

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
    local mag_size_z = parameters.mag_size_z
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
    mi_probdef(0, "millimeters", "planar", 1e-8, 0, depth)

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

    -- AIR MATERIAL
    mi_addblocklabel(mag_node_nw[1], mag_node_nw[2]+0.01)
    mi_selectlabel(mag_node_nw[1], mag_node_nw[2]+0.01)
    mi_setblockprop(empty_material, 1, 0, "<None>", 0, 1, 0)
    mi_clearselected()

    for i = 0, mag_count-1 do
        local theta = 2*PI*i/mag_count

        local sw_x, sw_y = vector_z_rotation_matrix(mag_node_sw[1], mag_node_sw[2], theta)
        local se_x, se_y = vector_z_rotation_matrix(mag_node_se[1], mag_node_se[2], theta)
        local nw_x, nw_y = vector_z_rotation_matrix(mag_node_nw[1], mag_node_nw[2], theta)
        local ne_x, ne_y = vector_z_rotation_matrix(mag_node_ne[1], mag_node_ne[2], theta)
        local center_x, center_y = vector_z_rotation_matrix(mag_node_center[1], mag_node_center[2], theta)
        
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

        local fi = (theta*180)/PI+90
        if i >= (mag_count-1)/2 then fi = fi + 180 end

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

    for i = 0, coil_groove_count-1 do
        local theta = ((2 * PI)/coil_groove_count) * i

        local in_x = coil_groove_in_r * cos(theta)
        local in_y = coil_groove_in_r * sin(theta)

        mi_addnode(in_x, in_y)
        
        local fi = ((coil_groove_ang*2*PI)/360)/2
        local out_x1 = coil_groove_out_r * cos(theta+fi)
        local out_y1 = coil_groove_out_r * sin(theta+fi)

        local out_x2 = coil_groove_out_r * cos(theta-fi)
        local out_y2 = coil_groove_out_r * sin(theta-fi)
        
        mi_addnode(out_x1, out_y1)
        mi_addnode(out_x2, out_y2)

        mi_addsegment(in_x, in_y, out_x1, out_y1)
        mi_addsegment(in_x, in_y, out_x2, out_y2)
        -- mi_addsegment(out_x1, out_y1, out_x2, out_y2)
        mi_addarc(out_x2, out_y2, out_x1, out_y1, 2 * asin(sqrt((out_x1 - out_x2)^2 + (out_y1 - out_y2)^2) / (2 * coil_groove_out_r)) * (180 / PI), 1)
        
        local theta_prev = ((2 * PI)/coil_groove_count) * (i - 1)
        local prev_out_x1 = coil_groove_out_r * cos(theta_prev + fi)
        local prev_out_y1 = coil_groove_out_r * sin(theta_prev + fi)
        
        if i ~= 0 then 
            -- mi_addsegment(out_x2, out_y2, prev_out_x1, prev_out_y1)
            mi_addarc(prev_out_x1, prev_out_y1, out_x2, out_y2, 2 * asin(sqrt((out_x2 - prev_out_x1)^2 + (out_y2 - prev_out_y1)^2) / (2 * coil_groove_out_r)) * (180 / PI), 1)
        end
        
        -- LABELING
        local alfa = (360*theta)/(2*PI) --theta in not rad
        if (alfa>= 180 and alfa< 360) then
            direction = -1 -- into
        else
            direction = 1 -- out
        end
        
        local label_x = (coil_groove_in_r+0.1) * cos(theta)
        local label_y = (coil_groove_in_r+0.1) * sin(theta)
        
        -- WINDING MATERIAL
        mi_addblocklabel(label_x, label_y)
        mi_selectlabel(label_x, label_y)
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
    -- mi_addsegment(first_out_x2, first_out_y2, last_out_x1, last_out_y1)
    mi_addarc(last_out_x1, last_out_y1, first_out_x2, first_out_y2, 2 * asin(sqrt((first_out_x2 - last_out_x1)^2 + (first_out_y2 - last_out_y1)^2) / (2 * coil_groove_out_r)) * (180 / PI), 1)

    -- NON CORE ROTOR MATERIAL
    mi_addblocklabel(0, rotor_core_r+0.01)
    mi_selectlabel(0, rotor_core_r+0.01)
    mi_setblockprop(plastic_material, 1, 0, "<None>", 0, 2, 0)
    mi_clearselected()

    mi_zoomnatural()

    mi_saveas("motor_geometry.FEM")

    mi_analyze()
    mi_loadsolution()

    mo_showdensityplot(1, 0, 0.6, 0, "bmag")
    mo_groupselectblock(2)
    local stress_tensor_torque = mo_blockintegral(22)

    -- OUTPUT
    
    local file = openfile("output.csv", "a")
    if file ~= nil then
        local append_text = session_id .. "," .. stress_tensor_torque .. "\n"
        write(file, append_text)
        closefile(file)
    else 
        print("File append error")
    end

    mo_close()
    mi_close()
end

dofile("femm_input.lua")
local i = 1
while parameters_list[i] ~= nil do
    run_calculations(parameters_list[i])
    i = i + 1
end
quit()