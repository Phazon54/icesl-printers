name_en = "PETG"
name_es = "PETG"
name_fr = "PETG"

cold_end_temp_degree_c = 70  -- cold end / temperature (glass transition temperature)
mixer_temp_degree_c = 210     -- extruder temperature
extruder_temp_degree_c = 230  -- nozzle temperature (melting temperature)

-- affecting settings to each extruder
for i = 0, extruder_count-1, 1 do
  _G['cold_end_temp_degree_c_' ..i] = cold_end_temp_degree_c
  _G['mixer_temp_degree_c_' ..i] = mixer_temp_degree_c
  _G['extruder_temp_degree_c_'..i] = extruder_temp_degree_c
  _G['filament_priming_mm_'..i] = 0
  _G['priming_mm_per_sec_'..i] = 5
  _G['retract_mm_per_sec_'..i] = 5
end

bed_temp_degree_c = 70

flow_multiplier_0 = 1.0
speed_multiplier_0 = 1.0

enable_fan = true
fan_speed_percent = 50
fan_speed_percent_on_bridges = 100
