name_en = "EasyCork"
name_fr = "EasyCork"
name_es = "EasyCork"

z_layer_height_mm = 0.25

-- temperatures and retracts
for i = 0, extruder_count-1, 1 do
  _G['filament_diameter_mm_'..i] = 1.80
  _G['nozzle_diameter_mm_'..i] = 0.5
  _G['extruder_temp_degree_c_'..i] = 225
  _G['filament_priming_mm_'..i] = 1.5
  _G['priming_mm_per_sec_'..i] = 60
  _G['retract_mm_per_sec_'..i] = 60
end

-- bed temperature
bed_temp_degree_c = 60

retract_after_z = 0

-- cooling
enable_fan = true
enable_fan_first_layer = false
fan_speed_percent = 75
fan_speed_percent_on_bridges = 100
