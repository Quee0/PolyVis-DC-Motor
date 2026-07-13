depth = 50
stator_r_out = 10.65
stator_out_d = 2

stator_r_in = stator_r_out-stator_out_d

mag_size_x = 4
mag_size_y = 0.5
mag_size_z = depth
mag_count = 8

rotor_core_r = 3.5

newdocument(0)
mi_probdef(0, "millimeters", "planar", 1e-8, 0, depth)

function vector_z_rotation_matrix(x, y, theta)
    -- matrix multiplication formula
    local new_x = x * cos(theta) - y * sin(theta)
    local new_y = x * sin(theta) + y * cos(theta)
    return new_x, new_y
end

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

mag_node_sw_x = mag_size_x/2
mag_node_sw_y = sqrt(stator_r_in^2 - mag_node_sw_x^2)

-- first magnet
mag_node_sw = {mag_node_sw_x, -mag_node_sw_y}
mag_node_se = {-mag_node_sw_x, -mag_node_sw_y}
mag_node_nw = {mag_node_sw_x, -mag_node_sw_y+mag_size_y}
mag_node_ne = {-mag_node_sw_x, -mag_node_sw_y+mag_size_y}

mi_addnode(mag_node_sw[1], mag_node_sw[2])
mi_addnode(mag_node_se[1], mag_node_se[2])
mi_addnode(mag_node_nw[1], mag_node_nw[2])
mi_addnode(mag_node_ne[1], mag_node_ne[2])

for i = 0, mag_count-1 do
    local theta = 2*PI*i/mag_count

    local sw_x, sw_y = vector_z_rotation_matrix(mag_node_sw[1], mag_node_sw[2], theta)
    local se_x, se_y = vector_z_rotation_matrix(mag_node_se[1], mag_node_se[2], theta)
    local nw_x, nw_y = vector_z_rotation_matrix(mag_node_nw[1], mag_node_nw[2], theta)
    local ne_x, ne_y = vector_z_rotation_matrix(mag_node_ne[1], mag_node_ne[2], theta)
    
    mi_addnode(sw_x, sw_y)
    mi_addnode(se_x, se_y)
    mi_addnode(nw_x, nw_y)
    mi_addnode(ne_x, ne_y)

    mi_addsegment(sw_x, sw_y, se_x, se_y)
    mi_addsegment(se_x, se_y, ne_x, ne_y)
    mi_addsegment(ne_x, ne_y, nw_x, nw_y)
    mi_addsegment(nw_x, nw_y, sw_x, sw_y)
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

mi_zoomnatural()