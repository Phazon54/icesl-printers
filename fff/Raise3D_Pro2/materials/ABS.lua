name_en = "ABS"
name_fr = "ABS"
name_es = "ABS"

-- temperatures and retracts
for i = 0, extruder_count-1, 1 do
  _G['extruder_temp_degree_c_'..i] = 230
  _G['filament_priming_mm_'..i] = 1
  _G['priming_mm_per_sec_'..i] = 60
  _G['retract_mm_per_sec_'..i] = 60
end

-- bed temperature
bed_temp_degree_c = 100

retract_after_z = 0

-- cooling
enable_fan = false
enable_fan_first_layer = false
fan_speed_percent = 100
fan_speed_percent_on_bridges = 100
