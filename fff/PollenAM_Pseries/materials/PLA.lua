name_en = "PLA"
name_es = "PLA"
name_fr = "PLA"

cold_end_temp_degree_c = 70   -- cold end / temperature (glass transition temperature)
mixer_temp_degree_c = 200     -- extruder temperature
extruder_temp_degree_c = 200  -- nozzle temperature (melting temperature)

-- affecting settings to each extruder
for i = 0, extruder_count-1, 1 do
  _G['extruder_temp_degree_c_'..i] = extruder_temp_degree_c
  _G['filament_priming_mm_'..i] = 1.5
  _G['priming_mm_per_sec_'..i] = 5
  _G['retract_mm_per_sec_'..i] = 5
end

bed_temp_degree_c = 60

flow_multiplier_0 = 0.5
shell_flow_multiplier_0 = 0.5
speed_multiplier_0 = 1.0

enable_fan = true
fan_speed_percent = 100
fan_speed_percent_on_bridges = 100
