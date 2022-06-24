-- ZMorph profile for the "Fab" line (Fab, VX, and 2.0 SX)
-- Bedell Pierre 18/05/2022

current_extruder = 0
current_z = 0.0
current_frate = 0
changed_frate = false

current_fan_speed = -1

current_A = 0.50
current_B = 0.50

processing = false
skip_prime_retract = false
skip_ratios_change = false
last_extruder_selected = 0 -- counter to track the selected / prepared extruders

extruder_e = {} -- table of extrusion values for each extruder
extruder_e_reset = {} -- table of extrusion values for each extruder for e reset (to comply with G92 E0)
extruder_e_swap = {} -- table of extrusion values for each extruder before to keep track of e at an extruder swap

for i = 0, extruder_count -1 do
  extruder_e[i] = 0.0
  extruder_e_reset[i] = 0.0
  extruder_e_swap[i] = 0.0
end

path_type = {
  --{ 'default',    'Craftware'}
    { ';perimeter',  ';segType:Perimeter' },
    { ';shell',      ';segType:HShell' },
    { ';infill',     ';segType:Infill' },
    { ';raft',       ';segType:Raft' },
    { ';brim',       ';segType:Skirt' },
    { ';shield',     ';segType:Pillar' },
    { ';support',    ';segType:Support' },
    { ';tower',      ';segType:Pillar'}
  }

craftware = true -- allow the use of Craftware paths naming convention

--##################################################

function comment(text)
  output('; ' .. text)
end

function round(number, decimals)
  local power = 10^decimals
  return math.floor(number * power) / power
end

function e_from_dep(dep_length, dep_width, dep_height, extruder) -- get the E value (for G1 move) from a specified deposition move
  local r1 = dep_width / 2
  local r2 = filament_diameter_mm[extruder] / 2
  local extruded_vol = dep_length * math.pi * r1 * dep_height
  return extruded_vol / (math.pi * r2^2)
end

-- outputs the proper extruder string depending on the extruder_type
function extrude(e_value, ret_prime)
  ret_prime = ret_prime or false -- optional argument to check if function is used for prime / retracts
  if extruder_type == 3 then -- Dual PRO (mixing)
    local r_a = e_value * current_A
    local r_b = e_value - r_a
    if ret_prime then
      r_a = e_value / nb_input
      r_b = e_value / nb_input
    end
    return ' E' .. ff(r_a) .. ' A' .. ff(r_b)
  end
  return ' E' .. ff(e_value)
end

function header()
  output('G21 ; set units to millimeters')
  output('G90 ; use absolute coordinates')
  output('M82 ; use absolute distances for extrusion')

  output('M190 S' .. bed_temp_degree_c .. ' ; wait for bed temperature to be reached')
  output('M104 S' .. extruder_temp_degree_c[0] .. ' ; set temperature')
  output('G28; ; home all axes')
  output('M109 S' .. extruder_temp_degree_c[0] .. ' ; wait for temperature to be reached\n')

  current_frate = travel_speed_mm_per_sec * 60
  changed_frate = true
end

function footer()
  output('G92 E0')
  output('M104 S0 ; turn off hot end ')
  output('M140 S0 ; turn off hot bed')
  output('M107 ; turn off part cooling fan')
  output('G28 X0 Y0 ; home X and Y')
  output('G1 F6200 Y150 ; move Y to present finished part')
  output('M84 ; disable motors')
end

function layer_start(zheight)
  output(';<layer ' .. layer_id .. '>')
  output('G0 Z' .. f(zheight))
end

function layer_stop()
  extruder_e_reset[current_extruder] = extruder_e[current_extruder]
  output('G92 E0')
  comment('</layer>')
end

function retract(extruder,e)
  extruder_e[current_extruder] = e
  if skip_prime_retract then 
    comment('retract skipped')
    skip_prime_retract = false
    return e
  else
    comment('retract')
    local len    = filament_priming_mm[extruder] * nb_input
    local speed  = (retract_mm_per_sec[extruder] * nb_input) * 60;
    local e_value = e - len - extruder_e_reset[current_extruder]
    output('G1 F' .. speed .. extrude(e_value, true))
    extruder_e[current_extruder] = e - len
    current_frate = speed
    changed_frate = true
    return e - len
  end
end

function prime(extruder,e)
  extruder_e[current_extruder] = e
  if skip_prime_retract then 
    comment('retract skipped')
    skip_prime_retract = false
    return e
  else
    comment('prime')
    local len   = filament_priming_mm[extruder] * nb_input
    local speed = (priming_mm_per_sec[extruder] * nb_input) * 60;
    local e_value = e + len - extruder_e_reset[current_extruder]
    output('G1 F' .. speed .. extrude(e_value, true))
    extruder_e[current_extruder] = e + len
    current_frate = speed
    changed_frate = true
    return e + len
  end
end

-- this is called once for each used extruder at startup
function select_extruder(extruder)
  local n = nozzle_diameter_mm -- should be changed to nozzle_diameter_mm[extruder] when available
  -- hack to work around not beeing a lua global
  if extruder == 0 then
    n = nozzle_diameter_mm_0 
  elseif extruder == 1 then 
    n = nozzle_diameter_mm_1
  end

  local x_pos = 0.0
  local y_pos = 0.5 + (extruder*4*n)

  local l1 = 60 -- length of the purge start
  local l2 = 40 -- length of the purge end

  local w1 = n * 1.2 -- width of the purge start
  local w2 = n * 3.0 -- width of the purge end
  
  local e_value = 0.0


  last_extruder_selected = last_extruder_selected + 1
  -- skip unnecessary prime/retract and ratios setup when mixing
  if extruder_type == 3 then
    skip_prime_retract = true
    skip_ratios_change = true

    if last_extruder_selected == number_of_extruders then -- number_of_extruders is an IceSL internal Lua global variable which is used to know how many extruders will be used for a print job
      skip_prime_retract = false
      skip_ratios_change = false
    end
  end

  output('\n; purge extruder ' .. extruder)
  output('G92 E0')
  
  -- [no letter] single extruder 
  -- T0 + T1 -> dual extruder
  --         -> extruder A = T0 / none
  --         -> extruder B = T1
  -- T3 -> mixing extruder
  if extruder_type > 0 then
    if extruder_type == 3 then
      output('T3')
    else
      output('T' .. extruder)
    end
  end

  output('G0 F6000 X' .. x_pos .. ' Y' .. y_pos ..' Z0.3')
  output('G92 E0')

  x_pos = x_pos + l1
  e_value = round(e_from_dep(l1, w1, 0.3, extruder),2)
  output('G1 F1000 X' .. x_pos .. extrude(e_value) .. '   ; purge line start') -- purge start

  x_pos = x_pos + l2
  e_value = e_value + round(e_from_dep(l2, w2, 0.3, extruder),2)
  output('G1 F1000 X' .. x_pos .. extrude(e_value) .. '  ; purge line end') -- purge end
  output('G92 E0\n')

  current_extruder = extruder
  current_frate = travel_speed_mm_per_sec * 60
  changed_frate = true
end

function swap_extruder(from,to,x,y,z)
  output('\n;swap_extruder')

  if extruder_type == 3 then
    output('G92 E0')
    output('; Extruder change from vE' .. from .. ' to vE' .. to)
    output('G92 E0\n')
    skip_prime_retract = true
  else
    output('G92 E0')
    output('G4 P0')
    output('T' .. to)
    output('G4 P0')
    output('G92 E0\n')
  end

  current_extruder = to
  extruder_e_swap[from] = extruder_e_swap[from] + extruder_e[from] - extruder_e_reset[from]
  current_frate = travel_speed_mm_per_sec * 60
  changed_frate = true
end

function move_xyz(x,y,z)
  if processing == true then
    processing = false
    comment('travel')
  end
    if z == current_z then
    if changed_frate == true then 
      output('G0 F' .. current_frate .. ' X' .. f(x) .. ' Y' .. f(y))
      changed_frate = false
    else
      output('G0 X' .. f(x) .. ' Y' .. f(y))
    end
  else
    if changed_frate == true then
      output('G0 F' .. current_frate .. ' X' .. f(x) .. ' Y' .. f(y) .. ' Z' .. ff(z))
      changed_frate = false
    else
      output('G0 X' .. f(x) .. ' Y' .. f(y) .. ' Z' .. ff(z))
    end
    current_z = z
  end
end

function move_xyze(x,y,z,e)
  extruder_e[current_extruder] = e

  local e_value = extruder_e[current_extruder] - extruder_e_reset[current_extruder]

  -- path tagging
  if processing == false then 
    processing = true
    p_type = craftware and 2 or 1 -- select path type
    if      path_is_perimeter then output(path_type[1][p_type])
    elseif  path_is_shell     then output(path_type[2][p_type])
    elseif  path_is_infill    then output(path_type[3][p_type])
    elseif  path_is_raft      then output(path_type[4][p_type])
    elseif  path_is_brim      then output(path_type[5][p_type])
    elseif  path_is_shield    then output(path_type[6][p_type])
    elseif  path_is_support   then output(path_type[7][p_type])
    elseif  path_is_tower     then output(path_type[8][p_type])
    end
  end

  if z == current_z then
    if changed_frate == true then 
      output('G1 F' .. current_frate .. ' X' .. f(x) .. ' Y' .. f(y) .. extrude(e_value))
      changed_frate = false
    else
      output('G1 X' .. f(x) .. ' Y' .. f(y) .. extrude(e_value))
    end
  else
    if changed_frate == true then
      output('G1 F' .. current_frate .. ' X' .. f(x) .. ' Y' .. f(y) .. ' Z' .. ff(z) .. extrude(e_value))
      changed_frate = false
    else
      output('G1 X' .. f(x) .. ' Y' .. f(y) .. ' Z' .. ff(z) .. extrude(e_value))
    end
    current_z = z
  end
end

function move_e(e)
  extruder_e[current_extruder] = e

  local e_value = extruder_e[current_extruder] - extruder_e_reset[current_extruder]

  if changed_frate == true then 
    output('G1 F' .. current_frate .. extrude(e_value))
    changed_frate = false
  else
    output('G1' .. extrude(e_value, true))
  end
end

function set_feedrate(feedrate)
  if feedrate ~= current_frate then
    current_frate =  math.floor(feedrate)
    changed_frate = true
  end
end

function extruder_start()
end

function extruder_stop()
end

function progress(percent)
end

function set_extruder_temperature(extruder,temperature)
  output('M104 S' .. temperature)
end

function set_and_wait_extruder_temperature(extruder,temperature)
  output('M109 S' .. temperature)
end

function set_mixing_ratios(ratios)
  if skip_ratios_change then 
    skip_ratios_change = false
  else
    local sum = ratios[0] + ratios[1]
    if sum == 0 then
      ratios[0] = 0.50
      ratios[1] = 0.50
    end
  
    if ratios[0] ~= current_A or ratios[1] ~= current_B then
      current_A = ratios[0]
      current_B = ratios[1]
      comment('Mixing Ratios set to A' .. f(current_A) .. ' B' .. f(current_B))
      output('G92 E0')
      extruder_e_reset[current_extruder] = extruder_e[current_extruder]
    end
  end
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
