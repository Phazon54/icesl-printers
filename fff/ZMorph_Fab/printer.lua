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

craftware = false -- allow the use of Craftware paths naming convention

--##################################################

function comment(text)
  output('; ' .. text)
end

function header()
  output('G21 ; set units to millimeters')
  output('G90 ; use absolute coordinates')
  output('M82 ; use absolute distances for extrusion')

  output('M190 S' .. bed_temp_degree_c .. ' ; wait for bed temperature to be reached')
  output('M104 S' .. extruder_temp_degree_c[0] .. ' ; set temperature')
  output('G28; ; home all axes')
  output('M109 S' .. extruder_temp_degree_c[0] .. ' ; wait for temperature to be reached')

  output('G92 E0')
  output('G1 Z1.0 F3000 ; move z up little to prevent scratching of surface')
  output('G1 X0.1 Y20 Z0.3 F5000.0 ; move to start-line position')
  output('G1 X0.1 Y200.0 Z0.3 F1500.0 E15 ; draw 1st line')
  output('G1 X0.4 Y200.0 Z0.3 F5000.0 ; move to side a little')
  output('G1 X0.4 Y20 Z0.3 F1500.0 E30 ; draw 2nd line')
  output('G92 E0 ; reset extruder')
  output('; done purging extruder')

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
    --comment('retract skipped')
    skip_prime_retract = false
    return e
  else
    comment('retract')
    local len    = filament_priming_mm[extruder] * nb_input
    local speed  = (retract_mm_per_sec[extruder] * nb_input) * 60;
    local e_value = e - len - extruder_e_reset[current_extruder]
    output('G1 F' .. speed .. ' E' .. ff(e_value) .. ' A0.50 B0.50')
    extruder_e[current_extruder] = e - len
    current_frate = speed
    changed_frate = true
    return e - len
  end
end

function prime(extruder,e)
  extruder_e[current_extruder] = e
  if skip_prime_retract then 
    --comment('retract skipped')
    skip_prime_retract = false
    return e
  else
    comment('prime')
    local len   = filament_priming_mm[extruder] * nb_input
    local speed = (priming_mm_per_sec[extruder] * nb_input) * 60;
    local e_value = e + len - extruder_e_reset[current_extruder]
    output('G1 F' .. speed .. ' E' .. ff(e_value) .. ' A0.50 B0.50')
    extruder_e[current_extruder] = e + len
    current_frate = speed
    changed_frate = true
    return e + len
  end
end

function select_extruder(extruder)
  -- [no letter] single extruder 
  -- T0 + T1 -> dual extruder
  --         -> extruder A = T0 / none
  --         -> extruder B = T1
  -- T3 -> mixing extruder
  last_extruder_selected = last_extruder_selected + 1
  -- skip unnecessary prime/retract and ratios setup
  skip_prime_retract = true
  skip_ratios_change = true

  if last_extruder_selected == number_of_extruders then -- number_of_extruders is an IceSL internal Lua global variable which is used to know how many extruders will be used for a print job
    skip_prime_retract = false
    skip_ratios_change = false
    current_extruder = extruder
  end
end

function swap_extruder(from,to,x,y,z)
  output('; Extruder change from vE' .. from .. ' to vE' .. to)

  extruder_e_swap[from] = extruder_e_swap[from] + extruder_e[from] - extruder_e_reset[from]
  current_extruder = to
  skip_prime_retract = true
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

  if z == current_z then
    if changed_frate == true then 
      output('G1 F' .. current_frate .. ' X' .. f(x) .. ' Y' .. f(y) .. ' E' .. ff(e_value) .. ' A' .. f(current_A) .. ' B' .. f(current_B))
      changed_frate = false
    else
      output('G1 X' .. f(x) .. ' Y' .. f(y) .. ' E' .. ff(e_value) .. ' A' .. f(current_A) .. ' B' .. f(current_B))
    end
  else
    if changed_frate == true then
      output('G1 F' .. current_frate .. ' X' .. f(x) .. ' Y' .. f(y) .. ' Z' .. ff(z) .. ' E' .. ff(e_value) .. ' A' .. f(current_A) .. ' B' .. f(current_B))
      changed_frate = false
    else
      output('G1 X' .. f(x) .. ' Y' .. f(y) .. ' Z' .. ff(z) .. ' E' .. ff(e_value) .. ' A' .. f(current_A) .. ' B' .. f(current_B))
    end
    current_z = z
  end
end

function move_e(e)
  extruder_e[current_extruder] = e

  local e_value = extruder_e[current_extruder] - extruder_e_reset[current_extruder]

  if changed_frate == true then 
    output('G1 F' .. current_frate .. ' E' .. ff(e_value) .. ' A' .. f(current_A) .. ' B' .. f(current_B))
    changed_frate = false
  else
    output('G1 E' .. ff(e_value) .. ' A' .. f(current_A) .. ' B' .. f(current_B))
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
