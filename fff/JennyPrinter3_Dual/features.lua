-- Jenny Printer 3 Dual (cloned Ultimaker2)
-- Pierre Bedell 06/06/2019

-- Build Area dimensions
bed_size_x_mm = 215
bed_size_y_mm = 195
bed_size_z_mm = 200

-- Printer Extruders
extruder_count = 2
nozzle_diameter_mm = 0.4
filament_diameter_mm = 1.75

extruder_offset_x = {}
extruder_offset_y = {}
extruder_offset_x[0] =   0.0
extruder_offset_y[0] =   0.0
extruder_offset_x[1] = -18.0
extruder_offset_y[1] =   0.0

filament_priming_mm = 3.0

-- Layer height limits
z_layer_height_mm_min = nozzle_diameter_mm * 0.15
z_layer_height_mm_max = nozzle_diameter_mm * 0.75

-- Printing temperatures limits
extruder_temp_degree_c = 210
extruder_temp_degree_c_min = 150
extruder_temp_degree_c_max = 270

bed_temp_degree_c = 45
bed_temp_degree_c_min = 0
bed_temp_degree_c_max = 120

enable_active_temperature_control = true

-- Printing speed limits
print_speed_mm_per_sec = 40
print_speed_mm_per_sec_min = 5
print_speed_mm_per_sec_max = 80

perimeter_print_speed_mm_per_sec = 35
perimeter_print_speed_mm_per_sec_min = 5
perimeter_print_speed_mm_per_sec_max = 80

first_layer_print_speed_mm_per_sec = 10
first_layer_print_speed_mm_per_sec_min = 1
first_layer_print_speed_mm_per_sec_max = 80

-- Purge Tower
gen_tower = true
tower_side_x_mm = 10.0
tower_side_y_mm = 5.0
tower_brim_num_contours = 12

extruder_swap_at_location = true
extruder_swap_location_x_mm = 201
extruder_swap_location_y_mm = 179

--extruder_swap_retract_length_mm = 16.0
--extruder_swap_retract_speed_mm_per_sec = 30.0

for i=0,63,1 do
  _G['filament_diameter_mm_'..i] = filament_diameter_mm
  _G['filament_priming_mm_'..i] = filament_priming_mm
  _G['extruder_temp_degree_c_' ..i] = extruder_temp_degree_c
  _G['extruder_temp_degree_c_'..i..'_min'] = extruder_temp_degree_c_min
  _G['extruder_temp_degree_c_'..i..'_max'] = extruder_temp_degree_c_max
  _G['extruder_mix_count_'..i] = 1
end
