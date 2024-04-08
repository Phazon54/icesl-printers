-- BambuLab X1C Profile
-- Bedell Pierre 2024/02/08

-- Build Area dimensions
bed_size_x_mm = 256
bed_size_y_mm = 256
bed_size_z_mm = 250

-- Printer Extruder
extruder_count = 1
nozzle_diameter_mm = 0.4
filament_diameter_mm = 1.75

-- Layer height limits
z_layer_height_mm_min = nozzle_diameter_mm * 0.20
z_layer_height_mm_max = nozzle_diameter_mm * 0.70

-- Retraction Settings
filament_priming_mm = 0.8
priming_mm_per_sec = 30.0
retract_mm_per_sec = 30.0
extruder_swap_retract_length_mm = 2.0
extruder_swap_retract_speed_mm_per_sec = 30.0

-- Printing temperatures limits (defaults are for PLA)
extruder_temp_degree_c = 220
extruder_temp_degree_c_min = 150
extruder_temp_degree_c_max = 300

--add_setting('bed_type', 'Bed type', 1, 4, "Type of Bed-plate used/installed for the print:\n- 1: Cool Plate\n- 2: Engineering Plate\n- 3: Smooth PEI / High temp Plate\n- 4: Textured PEI Plate", 1)
bed_type = 1
-- cool plate: 35, engineering plate: 0, smooth PEI/HT plate: 55, textured PEI: 55
if bed_type == 1 then
  bed_temp_degree_c = 35
elseif bed_type == 2 then
  bed_temp_degree_c = 0
elseif bed_type == 3 then
  bed_temp_degree_c = 55
elseif bed_type == 4 then
  bed_temp_degree_c = 55
else
  bed_temp_degree_c = 50
end
bed_temp_degree_c_min = 0
bed_temp_degree_c_max = 120

-- Air filtering
add_checkbox_setting('air_filter', 'Enable air filter', 'Enable the air filter system, if available on the machine')
air_filter = false

-- Printing speed limits
print_speed_mm_per_sec = 300
print_speed_mm_per_sec_min = 5
print_speed_mm_per_sec_max = 400

perimeter_print_speed_mm_per_sec = 200
perimeter_print_speed_mm_per_sec_min = 5
perimeter_print_speed_mm_per_sec_max = 400

cover_print_speed_mm_per_sec = 200
cover_print_speed_mm_per_sec_min = 5
cover_print_speed_mm_per_sec_max = 400

first_layer_print_speed_mm_per_sec = 50
first_layer_print_speed_mm_per_sec_min = 5
first_layer_print_speed_mm_per_sec_max = 100

travel_speed_mm_per_sec = 500
travel_speed_mm_per_sec_min = 20
travel_speed_mm_per_sec_max = 600

support_print_speed_mm_per_sec = 150
support_print_speed_mm_per_sec_min = 5
support_print_speed_mm_per_sec_max = 250

-- Acceleration settings
-- Custom checkox to enable per-path acceleration control
add_checkbox_setting('use_per_path_accel', 'Uses Per-Path Acceleration', 'Manage Accelerations depending of the current path type')
use_per_path_accel = true

-- max settings are provided for reference only, as they should remain as set up on the machine
-- x_max_speed = 500 -- mm/s
-- y_max_speed = 500 -- mm/s
-- z_max_speed = 20 -- mm/s
-- e_max_speed = 30 -- mm/s

-- x_max_acc = 20000 -- mm/s²
-- y_max_acc = 20000 -- mm/s²
-- z_max_acc = 500 -- mm/s²
-- e_max_acc = 5000 -- mm/s²
-- extruding_max_acc = 20000 -- mm/s²
-- retracting_max_acc = 5000 -- mm/s²
-- travel_max_acc = 20000 -- mm/s²

-- x_max_jerk = 9 mm/s
-- y_max_jerk = 9 mm/s
-- z_max_jerk = 3 mm/s
-- e_max_jerk = 2.5 mm/s

default_acc = 10000 -- mm/s²
first_layer_acc = 500 -- mm/s²
perimeter_acc = 5000 -- mm/s²
infill_acc = 10000 -- mm/s²
cover_acc = 2000 -- mm/s²
travel_acc = 10000 -- mm/s²

default_jerk = 0 -- mm/s
first_layer_jerk = 9 -- mm/s
perimeter_jerk = 9 -- mm/s
infill_jerk = 9 -- mm/s
cover_jerk = 9 -- mm/s
travel_jerk = 12 -- mm/s

-- Misc default settings
export_gcode_thumbnails = true

path_width_speed_adjustment_exponent = 1.5

add_brim = true
brim_distance_to_print_mm = 2.0
brim_num_contours = 3

enable_z_lift = true
z_lift_mm = 0.4

-- default filament infos (when using "custom" profile)
name_en = "PLA"
filament_density = 1.25 -- g/cm3 PLA
max_vol_speed = 21 -- mm^3/s

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
  _G['extruder_mix_count_'..i] = 1
end
