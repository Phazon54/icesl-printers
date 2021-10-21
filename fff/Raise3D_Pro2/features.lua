-- Raise3D Pro2, by BAT - 06/05/2019

-- custom settings in the UI
tooltip_verbose_ON = 'enables comments to identify function calls inside the GCODE\n can be turned off smaller GCODE files'
tooltip_low_motor_current = 'forces low motor current mode:\nactivates M906 E400 in order to set motor current at 400mA\ninstead of the default 650mA.\nThis is especially good for low temperature PLA or\nany material subject to heat creep'
tooltip_CompHeaderActiveExtRectraction = 'compensates header retraction on active extruder:\n- if enabled then the print starts with the active extruder\nexactly at E=0 (material should be exactly at nozzle end)\n- if disabled then the retraction happened during header is not compensated\nand thus there will be less oozing at start but there could be lack of material\n\nIT IS BEST TO KEEP IT DISABLED IF BRIM OR SKIRT ARE USED'
tooltip_z_caching = 'G1 commands will not emit Z when it does not change\nthe only effect is having a smaller gcode file'
tooltip_xy_caching = 'G1 commands will not emit X and Y when they do not change\nthe only effect is having a smaller gcode file'
tooltip_z_offset = 'Z axis offset [mm]\nfixed extra distance between nozzle and heated bed\nand can be either positive or negative'
tooltip_z_extra_height = 'Z height inflation [%]\ndoes not affect extruded volume and act a Z height multiplier:\nFinal Z height = Z height * 0.01 (Z height inflation)\ncan be positive or negative and the effect is kind of similar to flow multiplier\n(flow multiplier affects flow and leaves Z height untouched, here is the opposite)'
tooltip_retract_after_z = 'Minimum Z height for retraction [mm]\nRetraction will happen only for higher Z values\nuseful to disable retractions for the first layer(s)\nQuality should not be affected but adhesion should be better (depending on the number of retractions)'
tooltip_extra_extruder_e_restart = 'Extra extrusion distance [mm]\napplied after each retract, can be positive or negative\nuseful to remove respectively voids or blobs caused by retraction\nAPPLIED TO BOTH EXTRUDERS'
tooltip_extra_extruder_e_swap_restart = 'Extra extrusion distance [mm]\napplied after each retract, can be positive or negative\nuseful to remove respectively voids or blobs caused by extruder swap\nAPPLIED TO BOTH EXTRUDERS'
tooltip_swap_length_multi = 'swap retraction/priming multiplier\nThis value is multiplied by the priming length\nenables a custom retraction length on extruder swap\nAPPLIED TO BOTH EXTRUDERS'

verbose_ON = true                       -- Verbose Gcode
low_motor_current = false               -- low current mode for motors
CompHeaderActiveExtRectraction = false  -- Header retract compensation
z_caching = true                        -- Z caching (for "lighter Gcode")
xy_caching = false                      -- XY caching (for "lighter Gcode")
z_offset = 0.0                          -- Z offset (extra distance between build plate and print)
z_extra_height = 0.0                    -- Z inflation/compression (for tuning layer squish, similar effect to changing flow multiplier)
retract_after_z = 0.0                   -- Retract only after this Z height (will disable all retracts below set value)
extra_extruder_e_restart = 0.0          -- Extra priming
extra_extruder_e_swap_restart = 0.0     -- Extra priming/purge after a swap
swap_length_multi = 3                   -- Retraction multiplier for retractions during an extruder swap

add_checkbox_setting('verbose_ON', 'Enables comment lines in the gcode file', tooltip_verbose_ON)
add_checkbox_setting('low_motor_current', 'Forces low extruder motor current', tooltip_low_motor_current)
add_checkbox_setting('CompHeaderActiveExtRectraction', 'Compensate header retraction on active extruder', tooltip_CompHeaderActiveExtRectraction)
add_checkbox_setting('z_caching', 'Enable Z caching', tooltip_z_caching)
add_checkbox_setting('xy_caching', 'Enable XY caching', tooltip_xy_caching)
add_setting('z_offset', 'Z axis offset [mm]', -0.1, 2.0, tooltip_z_offset)
add_setting('z_extra_height', 'extra Z inflation [%] (not affecting flow) ', -50, 50, tooltip_z_extra_height)
add_setting('retract_after_z', 'minimum Z height for retraction [mm]', 0, 1, tooltip_retract_after_z)
add_setting('extra_extruder_e_restart', 'extra restart distance after retraction [mm]', -1, 1, tooltip_extra_extruder_e_restart)
add_setting('extra_extruder_e_swap_restart', 'extra restart distance after extruder swap [mm]', -2, 2, tooltip_extra_extruder_e_swap_restart)
add_setting('swap_length_multi','swap retraction/priming multiplier', 0, 10, tooltip_swap_length_multi)

--#################################################

-- Build Area dimensions
bed_size_x_mm = 305
bed_size_y_mm = 305
bed_size_z_mm = 300

-- Extruders default settings
extruder_count = 2
nozzle_diameter_mm = 0.4
filament_diameter_mm = 1.75

-- Retraction settings
filament_priming_mm = 1.5
priming_mm_per_sec = 30
retract_mm_per_sec = 30

-- Layer height limits
z_layer_height_mm = 0.2
z_layer_height_mm_min = nozzle_diameter_mm * 0.15
z_layer_height_mm_max = nozzle_diameter_mm * 0.75

-- Printing temperatures limits
extruder_temp_degree_c = 210
extruder_temp_degree_c_min = 150
extruder_temp_degree_c_max = 270

bed_temp_degree_c = 55
bed_temp_degree_c_min = 0
bed_temp_degree_c_max = 110

-- Printing speed limits
print_speed_mm_per_sec = 50
print_speed_mm_per_sec_min = 5
print_speed_mm_per_sec_max = 300

perimeter_print_speed_mm_per_sec = 40
perimeter_print_speed_mm_per_sec_min = 5
perimeter_print_speed_mm_per_sec_max = 80

cover_print_speed_mm_per_sec = 40
cover_print_speed_mm_per_sec_min = 5
cover_print_speed_mm_per_sec_max = 80

first_layer_print_speed_mm_per_sec = 10
first_layer_print_speed_mm_per_sec_min = 1
first_layer_print_speed_mm_per_sec_max = 80

travel_speed_mm_per_sec = 100

support_print_speed_mm_per_sec = 50

-- Purge Tower
gen_tower = false
tower_side_x_mm = 10
tower_side_y_mm = 10
tower_brim_num_contours = 5

tower_at_location = true -- Requires extruder to swap material at a given location,
                         -- this also forces the tower to appear at this same location.
tower_location_x_mm = bed_size_x_mm - 10 - tower_side_x_mm - tower_brim_num_contours * nozzle_diameter_mm
tower_location_y_mm = bed_size_y_mm - 10 - tower_side_y_mm - tower_brim_num_contours * nozzle_diameter_mm

-- Misc Settings
add_brim = true
brim_distance_to_print_mm = 1.0
brim_num_contours = 4

add_raft = false
raft_spacing = 1.0

gen_supports = false
support_extruder = 0

z_lift_mm = 0.6

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
