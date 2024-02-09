name_en = "PLA"
name_es = "PLA"
name_fr = "PLA"

filament_density = 1.25 --g/cm3
max_vol_speed = 21 -- mm^3/s

-- temperatures
extruder_temp_degree_c = 210
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

-- prime/retracts
filament_priming_mm = 0.8
priming_mm_per_sec = 30
retract_mm_per_sec = 30
extruder_swap_retract_length_mm = 2.0
extruder_swap_retract_speed_mm_per_sec = 30.0

-- flow
flow_multiplier = 1.0
speed_multiplier = 1.0

-- cooling
enable_fan = true
fan_speed_percent = 100
fan_speed_percent_on_bridges = 100

--#################################################

-- affecting settings to each extruder
for i = 0, extruder_count-1, 1 do
  _G['extruder_temp_degree_c_'..i] = extruder_temp_degree_c
  _G['filament_priming_mm_'..i] = filament_priming_mm
  _G['priming_mm_per_sec_'..i] = priming_mm_per_sec
  _G['retract_mm_per_sec_'..i] = retract_mm_per_sec
end

-- affecting settings to all brushes
for i = 0, max_number_brushes, 1 do
	_G['flow_multiplier_'..i] = flow_multiplier 
	_G['speed_multiplier_'..i] = speed_multiplier
end
