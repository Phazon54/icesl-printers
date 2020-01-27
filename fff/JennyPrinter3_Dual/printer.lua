-- Jenny Printer 3 Dual (cloned Ultimaker2)
-- Pierre Bedell 06/06/2019

current_extruder = 0
current_z = 0.0
current_frate = 0
changed_frate = false
processing = false
current_fan_speed = -1

extruder_e = {} -- table of extrusion values for each extruder
extruder_e_reset = {} -- table of extrusion values for each extruder for e reset (to comply with G92 E0)
extruder_e_swap = {} -- table of extrusion values for each extruder before to keep track of e at an extruder swap

for i = 0, extruder_count -1 do
  extruder_e[i] = 0.0
  extruder_e_reset[i] = 0.0
  extruder_e_swap[i] = 0.0
end

last_extruder_selected = 0 -- counter to track the selected / prepared extruders

skip_prime_retract = false

craftware_debug = true

--##################################################

function comment(text)
  output('; ' .. text)
end

--local r = filament_diameter_mm[extruders[0]] / 2
function to_mm_cube(filament_diameter,e)
  local r = filament_diameter / 2
  return math.pi * r * r * e
end

function round(number, decimals)
  local power = 10^decimals
  return math.floor(number * power) / power
end

function header()
  output(';FLAVOR:UltiGCode')
  output(';TIME:' .. time_sec)

  if filament_tot_length_mm[0] > 0 then
    output(';MATERIAL:' .. to_mm_cube(filament_diameter_mm[0], filament_tot_length_mm[0]) )
    output(';NOZZLE_DIAMETER:' .. round(nozzle_diameter_mm_0,2))
  end

  if filament_tot_length_mm[1] > 0 then 
    output(';MATERIAL2:' .. to_mm_cube(filament_diameter_mm[1], filament_tot_length_mm[1]) )
    output(';NOZZLE_DIAMETER2:' .. round(nozzle_diameter_mm_1,2))
  end

  output('M107')
  output('M82')
  output('G92 E0')
end

function footer()
  output('G10')
  output('M107')
end

function retract(extruder,e)
  extruder_e[current_extruder] = e - extruder_e_swap[current_extruder]
  if skip_prime_retract then 
    --comment('retract skipped')
    skip_prime_retract = false
    return e
  else
    comment('retract')
    output('G10')
  end
  return e
end

function prime(extruder,e)
  extruder_e[current_extruder] = e - extruder_e_swap[current_extruder]
  if skip_prime_retract then 
    --comment('prime skipped')
    skip_prime_retract = false
    return e
  else
    comment('prime')
    output('G11')
  end
  return e
end

function layer_start(zheight)
  output('; <layer ' .. layer_id .. '>')
  if layer_id == 0 then
    output('G0 F600 Z' .. ff(zheight))
  else
    output('G0 F100 Z' .. ff(zheight))
  end
  current_z = zheight
end

function layer_stop()
  extruder_e_reset[current_extruder] = extruder_e[current_extruder]
  output('G92 E0')
  output('; </layer>')
end

function select_extruder(extruder)
  --[[
  last_extruder_selected = last_extruder_selected + 1
  skip_prime_retract = true

  if last_extruder_selected == number_of_extruders then
    skip_prime_retract = false
    output('T' .. extruder)
    current_extruder = extruder
  end
  ]]

  skip_prime_retract = false
  output('T' .. extruder)
  current_extruder = extruder
  --prep extruder ??
end

function swap_extruder(from,to,x,y,z)
  output('; Tool change from T' .. from .. ' to T' .. to)
  extruder_e_swap[from] = extruder_e_swap[from] + extruder_e[from] - extruder_e_reset[from]
  current_extruder = to
  --skip_prime_retract = true
  output('T' .. to)
end

function move_xyz(x,y,z)
  if processing == true then
    processing = false
    comment('travel')
  end

  x = x + extruder_offset_x[current_extruder]
  y = y + extruder_offset_y[current_extruder]

  if z == current_z then
    if changed_frate == true then 
      output('G0 F' .. current_frate .. ' X' .. f(x) .. ' Y' .. f(y))
      changed_frate = false
    else
      output('G0 X' .. f(x) .. ' Y' .. f(y))
    end
  else
    if changed_frate == true then
      output('G0 F' .. current_frate .. ' X' .. f(x) .. ' Y' .. f(y) .. ' Z' .. f(z))
      changed_frate = false
    else
      output('G0 X' .. f(x) .. ' Y' .. f(y) .. ' Z' .. f(z))
    end
    current_z = z
  end
end

function move_xyze(x,y,z,e)
  extruder_e[current_extruder] = e - extruder_e_swap[current_extruder]

  local e_value = to_mm_cube(filament_diameter_mm[current_extruder], extruder_e[current_extruder] - extruder_e_reset[current_extruder])

  if processing == false then 
    processing = true
    if craftware_debug == true then
      if      path_is_perimeter then output(';segType:Perimeter')
      elseif  path_is_shell     then output(';segType:HShell')
      elseif  path_is_infill    then output(';segType:Infill')
      elseif  path_is_raft      then output(';segType:Raft')
      elseif  path_is_brim      then output(';segType:Skirt')
      elseif  path_is_shield    then output(';segType:Pillar')
      elseif  path_is_support   then output(';segType:Support')
      elseif  path_is_tower     then output(';segType:Pillar')
      end
    else
      if      path_is_perimeter then comment('perimeter')
      elseif  path_is_shell     then comment('shell')
      elseif  path_is_infill    then comment('infill')
      elseif  path_is_raft      then comment('raft')
      elseif  path_is_brim      then comment('brim')
      elseif  path_is_shield    then comment('shield')
      elseif  path_is_support   then comment('support')
      elseif  path_is_tower     then comment('tower')
      end
    end
  end

  x = x + extruder_offset_x[current_extruder]
  y = y + extruder_offset_y[current_extruder]

  if z == current_z then
    if changed_frate == true then 
      output('G1 F' .. current_frate .. ' X' .. f(x) .. ' Y' .. f(y) .. ' E' .. ff(e_value))
      changed_frate = false
    else
      output('G1 X' .. f(x) .. ' Y' .. f(y) .. ' E' .. ff(e_value))
    end
  else
    if changed_frate == true then
      output('G1 F' .. current_frate .. ' X' .. f(x) .. ' Y' .. f(y) .. ' Z' .. f(z) .. ' E' .. ff(e_value))
      changed_frate = false
    else
      output('G1 X' .. f(x) .. ' Y' .. f(y) .. ' Z' .. f(z) .. ' E' .. ff(e_value))
    end
    current_z = z
  end
end

function move_e(e)
  extruder_e[current_extruder] = e - extruder_e_swap[current_extruder]

  local e_value =  to_mm_cube(filament_diameter_mm[current_extruder], extruder_e[current_extruder] - extruder_e_reset[current_extruder])

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
  else
    changed_frate = false
  end
end

function extruder_start()
end

function extruder_stop()
end

function progress(percent)
end

function set_extruder_temperature(extruder,temperature)
  --output('M104 S' .. f(temperature) .. ' T' .. extruder)
  output('M104 S' .. f(temperature))
end

function set_and_wait_extruder_temperature(extruder,temperature)
  --output('M109 S' .. f(temperature) .. ' T' .. extruder)
  output('M109 S' .. f(temperature))
end

function set_fan_speed(speed)
  if speed ~= current_fan_speed then
    output('M106 S'.. math.floor(255 * speed/100))
    current_fan_speed = speed
  end
end
