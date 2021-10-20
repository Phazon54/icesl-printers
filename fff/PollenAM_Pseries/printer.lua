-- Pollen AM Series P Profile
-- Bedell Pierre 20/07/2021

bed_origin_x = bed_size_x_mm/2
bed_origin_y = bed_size_y_mm/2

current_z = 0.0

current_extruder = 0
prev_extruder = 1

extruder_e = {}
extruder_e_reset = {}
extruder_e_swap = {}

for i = 0, extruder_count -1 do
  extruder_e[i] = 0.0
  extruder_e_reset[i] = 0.0
  extruder_e_swap[i] = 0.0
end

changed_frate = false
current_frate = 0

current_fan_speed = -1

--##################################################

function comment(text)
  output('; ' .. text)
end

function e_to_mm_cube(e)
  local r = filament_diameter_mm[current_extruder] / 2
  return (math.pi * r^2 ) * e
end

function header()
  output('G28 ; home all axes')
  output('G90 ; use absolute coordinates')
  output('M82 ; use absolute distances for extrusion')
  output('M190 S' .. bed_temp_degree_c .. ' ; wait for bed temperature to be reached')
  output('M107 ; turn off cooling fan')
  output('G92 E0')

  current_frate = travel_speed_mm_per_sec * 60
  changed_frate = true
end

function footer()
  output('G92 E0')
  output('M107 ; fan off')
  output('; turn off all extruders heaters')
  output('M104 T1 S0 H0')
  output('M104 T2 S0 H0')
  output('M104 T3 S0 H0')
  output('M104 T4 S0 H0')
  output('; turn off all mixers')
  output('D23 T1 V0')
  output('D23 T2 V0')
  output('D23 T3 V0')
  output('D23 T4 V0')
  output('M140 S0 ;turn off bed')
  output('G1 Z300 X140 Y0 F1200 ; present print')
  output('G90 ; absolute positioning')
  output('M82 ; absolute extrusion')
end

function layer_start(zheight)
  comment('<layer ' .. layer_id .. '>')
  output('G0 Z' .. f(zheight))
  current_z = zheight
end

function layer_stop()
  extruder_e_reset[current_extruder] = extruder_e[current_extruder]
  output('G92 E0')
  comment('</layer>')
end

function retract(extruder,e)
  comment('retract')
  local len   = filament_priming_mm[extruder]
  local speed = retract_mm_per_sec[extruder] * 60
  local e_value = e - extruder_e_swap[current_extruder]
  output('G1 F' .. speed .. ' E' .. ff(e_value - extruder_e_reset[current_extruder]) - len)
  extruder_e[current_extruder] = e - len
  current_frate = speed
  changed_frate = true
  return e - len
end

function prime(extruder,e)
  comment('prime')
  local len   = filament_priming_mm[extruder]
  local speed = priming_mm_per_sec[extruder] * 60
  local e_value = e - extruder_e_swap[current_extruder]
  output('G1 F' .. speed .. ' E' .. ff(e_value - extruder_e_reset[current_extruder]) + len)
  extruder_e[current_extruder] = e + len
  current_frate = speed
  changed_frate = true
  return e + len
end

-- extruder management
-- D23 -> "enable" extruder
-- D23 T[tool_number] V[0-1 disable/enable] S[5(hardcoded?) activation speed]

function select_extruder(extruder)
  -- enable tool
  output('D23 T' .. prev_extruder .. ' V0')
  output('D23 T' .. extruder + 1 .. ' V1 S5')
  output('T' .. extruder + 1)
  output('M104 S' .. mixer_temp_degree_c .. ' C' .. cold_end_temp_degree_c .. ' H' .. extruder_temp_degree_c[extruders[0]] .. ' ; set temperature')
  output('M109 S' .. mixer_temp_degree_c .. ' C' .. cold_end_temp_degree_c .. ' H' .. extruder_temp_degree_c[extruders[0]] .. ' ; wait for temperature to be reached')
  current_extruder = extruder
  prev_extruder = extruder + 1
end

function swap_extruder(from,to,x,y,z)
  output('\n;swap_extruder')
  extruder_e_swap[from] = extruder_e_swap[from] + extruder_e[from] - extruder_e_reset[from]

  -- swap extruder
  output('G92 E0')
  output('D23 T' .. from + 1 .. ' V0')
  output('D23 T' .. to + 1 .. ' V1 S5')
  output('T' .. to + 1)
  output('G92 E0')

  current_extruder = to
  current_frate = travel_speed_mm_per_sec * 60
  changed_frate = true
end

function move_xyz(x,y,z)
  local centered_x = x - bed_origin_x
  local centered_y = y - bed_origin_y
  if z == current_z then
    if changed_frate == true then 
      output('G0 F' .. current_frate .. ' X' .. f(centered_x) .. ' Y' .. f(centered_y))
      changed_frate = false
    else
      output('G0 X' .. f(centered_x) .. ' Y' .. f(centered_y))
    end
  else
    if changed_frate == true then
      output('G0 F' .. current_frate .. ' X' .. f(centered_x) .. ' Y' .. f(centered_y) .. ' Z' .. ff(z))
      changed_frate = false
    else
      output('G0 X' .. f(centered_x) .. ' Y' .. f(centered_y) .. ' Z' .. ff(z))
    end
    current_z = z
  end
end

function move_xyze(x,y,z,e)
  extruder_e[current_extruder] = e - extruder_e_swap[current_extruder]
  local e_value = extruder_e[current_extruder] - extruder_e_reset[current_extruder]
  local centered_x = x - bed_origin_x
  local centered_y = y - bed_origin_y
  if z == current_z then
    if changed_frate == true then 
      output('G1 F' .. current_frate .. ' X' .. f(centered_x) .. ' Y' .. f(centered_y) .. ' E' .. ff(e_value))
      changed_frate = false
    else
      output('G1 X' .. f(centered_x) .. ' Y' .. f(centered_y) .. ' E' .. ff(e_value))
    end
  else
    if changed_frate == true then
      output('G1 F' .. current_frate .. ' X' .. f(centered_x) .. ' Y' .. f(centered_y) .. ' Z' .. ff(z) .. ' E' .. ff(e_value))
      changed_frate = false
    else
      output('G1 X' .. f(centered_x) .. ' Y' .. f(centered_y) .. ' Z' .. ff(z) .. ' E' .. ff(e_value))
    end
    current_z = z
  end
end

function move_e(e)
  extruder_e[current_extruder] = e - extruder_e_swap[current_extruder]
  local e_value = extruder_e[current_extruder] - extruder_e_reset[current_extruder]
  if changed_frate == true then 
    output('G1 F' .. current_frate .. ' E' .. ff(e_value))
    changed_frate = false
  else
    output('G1 E' .. ff(e_value))
  end
end

function set_feedrate(feedrate)
  if feedrate ~= current_frate then
    current_frate = feedrate
    changed_frate = true
  end
end

function extruder_start()
end

function extruder_stop()
end

function progress(percent)
end

-- temperature management
-- M104 / M109 T[tool_number] S[extruder_temp] C[mixer_temp]   H[nozzle_temp]
--                            body/mid         cold-end/entry  nozzle
--  \  /
--  | |
--  [C]
--  | |
--  [S]
--  | |
--  [H]
--  \/

function set_extruder_temperature(extruder,temperature)
  output('M104 T' .. extruder + 1 .. 'S' .. mixer_temp_degree_c ..' C' .. cold_end_temp_degree_c' H' .. temperature)
end

function set_and_wait_extruder_temperature(extruder,temperature)
  output('M109 T' .. extruder + 1 .. 'S' .. mixer_temp_degree_c ..' C' .. cold_end_temp_degree_c' H' .. temperature)
end

function set_fan_speed(speed)
  if speed ~= current_fan_speed then
    output('M106 S'.. math.floor(255 * speed/100))
    current_fan_speed = speed
  end
end

function wait(sec,x,y,z)
  output("; WAIT --" .. sec .. "s remaining" )
  output("G0 F" .. travel_speed_mm_per_sec .. " X10 Y10")
  output("G4 S" .. sec .. "; wait for " .. sec .. "s")
  output("G0 F" .. travel_speed_mm_per_sec .. " X" .. f(x) .. " Y" .. f(y) .. " Z" .. ff(z))
end
