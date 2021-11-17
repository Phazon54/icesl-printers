name_en = "ABS"
name_es = "ABS"
name_fr = "ABS"

cold_end_temp_degree_c = 110  -- cold end / temperature (glass transition temperature)
mixer_temp_degree_c = 210     -- extruder temperature
extruder_temp_degree_c = 240  -- nozzle temperature (melting temperature)

-- affecting settings to each extruder
for i = 0, extruder_count-1, 1 do
  _G['extruder_temp_degree_c_'..i] = extruder_temp_degree_c
  _G['filament_priming_mm_'..i] = 0
  _G['priming_mm_per_sec_'..i] = 5
  _G['retract_mm_per_sec_'..i] = 5
end

bed_temp_degree_c = 100

flow_multiplier_0 = 1.0
speed_multiplier_0 = 1.0

enable_fan = false
fan_speed_percent = 20
fan_speed_percent_on_bridges = 50
