-- ZMorph profile for the "Fab" line (Fab, VX, and 2.0 SX)
-- Bedell Pierre 18/05/2022

-- Build Area dimensions
bed_size_x_mm = 235
bed_size_y_mm = 250
bed_size_z_mm = 165

-- Printer Extruder

-- Type of extruder
-- 0: Single 1.75mm
-- 1: Single 3.00mm
-- 2: Dualhead
-- 3: Dual PRO (mixing)
extruder_type = 0

-- number of extruders
--can also be using to enable virtual extruders for differents printing settings
-- or using a mixing extruder as a "normal" multi-extruder
extruder_count = 1

-- number of inputed filament in the nozzle (mixing nozzle)
nb_input = 1

nozzle_diameter_mm = 0.4
filament_diameter_mm = 1.75

-- Retraction Settings
filament_priming_mm = 2.5 -- between 2 and 5mm
priming_mm_per_sec = 100
retract_mm_per_sec = 100
extruder_swap_retract_mm = filament_priming_mm

-- Layer height limits
z_layer_height_mm = 0.3
z_layer_height_mm_min = nozzle_diameter_mm * 0.125
z_layer_height_mm_max = nozzle_diameter_mm * 0.8

-- Printing temperatures limits
extruder_temp_degree_c = 210
extruder_temp_degree_c_min = 150
extruder_temp_degree_c_max = 250

bed_temp_degree_c = 55
bed_temp_degree_c_min = 0
bed_temp_degree_c_max = 115

-- Printing speed limits
print_speed_mm_per_sec = 40
print_speed_mm_per_sec_min = 5
print_speed_mm_per_sec_max = 80

perimeter_print_speed_mm_per_sec = 30
perimeter_print_speed_mm_per_sec_min = 5
perimeter_print_speed_mm_per_sec_max = 80

cover_print_speed_mm_per_sec = 30
cover_print_speed_mm_per_sec_min = 5
cover_print_speed_mm_per_sec_max = 80

first_layer_print_speed_mm_per_sec = 20
first_layer_print_speed_mm_per_sec_min = 5
first_layer_print_speed_mm_per_sec_max = 30

travel_speed_mm_per_sec = 120

print_speed_microlayers_mm_per_sec = 40
mixing_shield_speed_multiplier = 1

-- Specific settings for each extruder type
if extruder_type > 0 then
  if extruder_type == 1 then -- Single 3.00mm
    filament_diameter_mm = 3.0
  elseif extruder_type == 2 then -- Dualhead
    extruder_count = 2
  elseif extruder_type == 3 then -- Dual PRO (mixing)
    extruder_purge_volume_mm3 = 10
    extruder_count = 1
    nb_input = 2
  end
end

-- Misc default settings
add_brim = true
brim_distance_to_print_mm = 2.0
brim_num_contours = 3

enable_z_lift = true
z_lift_mm = 0.4

if nb_input > 1 then  
  gen_shield = true
  shield_distance_to_part_mm = 2
end

-- "regular" multi-material mode (DualHead extruder)
if extruder_count > 1 then 
  gen_shield = false

  gen_tower = true
  tower_at_location = false -- Sent the tool head to the specified location to swap materials and create the purge tower
  tower_side_x_mm = 10.0
  tower_side_y_mm = 25.0
  tower_brim_num_contours = 12
  
  purge_tower_offset = 5 -- Offset between the side of the build plate and the purging tower
  if tower_at_location then
    tower_location_x_mm = bed_size_x_mm - (tower_side_x_mm / 2) - ((tower_brim_num_contours * z_layer_height_mm) * 2) - purge_tower_offset
    tower_location_y_mm = bed_size_y_mm - (tower_side_y_mm / 2) - ((tower_brim_num_contours * z_layer_height_mm) * 2) - purge_tower_offset
  end
end

--#################################################

-- Internal procedure to fill brushes / extruder settings
for i = 0, max_number_extruders, 1 do
  _G['nozzle_diameter_mm_'..i] = nozzle_diameter_mm
  _G['filament_diameter_mm_'..i] = filament_diameter_mm
  _G['filament_priming_mm_'..i] = filament_priming_mm
  _G['priming_mm_per_sec_'..i] = priming_mm_per_sec
  _G['retract_mm_per_sec_'..i] = retract_mm_per_sec
  _G['extruder_temp_degree_c_' ..i] = extruder_temp_degree_c
  _G['extruder_temp_degree_c_'..i..'_min'] = extruder_temp_degree_c_min
  _G['extruder_temp_degree_c_'..i..'_max'] = extruder_temp_degree_c_max
  _G['extruder_mix_count_'..i] = nb_input
end
