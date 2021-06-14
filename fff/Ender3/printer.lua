-- Ender 3 Profile
-- Bedell Pierre 27/10/2018

--extruder_e = 0
--extruder_e_restart = 0

extruder_e = {}
extruder_e_restart = {}

for i = 0, extruder_count -1 do
  extruder_e[i] = 0.0
  extruder_e_restart[i] = 0.0
end

skip_prime_retract = false
skip_temp = false

current_z = 0.0

changed_frate = false

current_extruder = 0
current_frate = 0

current_fan_speed = -1

--##################################################

function comment(text)
  output('; ' .. text)
end

function header()
  local auto_level_string = 'G29 ; auto bed levelling\nG0 F6200 X0 Y0 ; back to the origin to begin the purge '
  local h = file('header.gcode')

  h = h:gsub( '<TOOLTEMP>', extruder_temp_degree_c[extruders[0]] )
  h = h:gsub( '<HBPTEMP>', bed_temp_degree_c )

  if auto_bed_leveling == true then
    h = h:gsub( '<BEDLVL>', auto_level_string )
  else
    h = h:gsub( '<BEDLVL>', "G0 F6200 X0 Y0" )
  end
  output(h)
  current_frate = travel_speed_mm_per_sec * 60
  changed_frate = true
end

function footer()
  output(file('footer.gcode'))
end

function layer_start(zheight)
  comment('<layer ' .. layer_id .. '>')
  output('G1 Z' .. f(zheight))
end

function layer_stop()
  extruder_e_restart[current_extruder] = extruder_e[current_extruder]
  output('G92 E0')
  comment('</layer>')
end

function retract(extruder,e)
  if skip_prime_retract then 
    comment('retract skipped')
    skip_prime_retract = false
    return e
  else
    comment('retract')
    local len   = filament_priming_mm[extruder]
    local speed = priming_mm_per_sec[extruder] * 60
    output('G1 F' .. speed .. ' E' .. ff(e - len - extruder_e_restart[extruder]))
    current_frate = speed
    changed_frate = true
    extruder_e[extruder] = e - len
    return e - len
  end
end

function prime(extruder,e)
  if skip_prime_retract then 
    comment('prime skipped')
    skip_prime_retract = false
    return e
  else
    comment('prime')
    local len   = filament_priming_mm[extruder]
    local speed = priming_mm_per_sec[extruder] * 60
    output('G1 F' .. speed .. ' E' .. ff(e + len - extruder_e_restart[extruder]))
    current_frate = speed
    changed_frate = true
    extruder_e[extruder] = e + len
    return e + len
  end
end

function select_extruder(extruder)
  current_extruder = extruder
  skip_prime_retract = true
  skip_temp = true
end

function swap_extruder(from,to,x,y,z)
  output('; Extruder change from vE' .. from .. ' to vE' .. to)
  output('G92 E0')
  extruder_e_restart[from] = extruder_e[from]
  current_extruder = to
  skip_temp = true
  if to == 0 then -- skip priming when going back to vE0, as vE1 has no retract
    skip_prime_retract = true
  end
  if to == 1 then -- re-prime after swap from vE0 to equalize filament level
    local len   = filament_priming_mm[from]
    local speed = priming_mm_per_sec[from] * 60
    comment('filament equalization')
    output('G1 F' .. speed .. ' E' .. ff(len))
    output('G92 E0')
  end
end

function move_xyz(x,y,z)
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
  local e_value = extruder_e[current_extruder] - extruder_e_restart[current_extruder]
  if z == current_z then
    if changed_frate == true then 
      output('G1 F' .. current_frate .. ' X' .. f(x) .. ' Y' .. f(y) .. ' E' .. ff(e_value))
      changed_frate = false
    else
      output('G1 X' .. f(x) .. ' Y' .. f(y) .. ' E' .. ff(e_value))
    end
  else
    if changed_frate == true then
      output('G1 F' .. current_frate .. ' X' .. f(x) .. ' Y' .. f(y) .. ' Z' .. ff(z) .. ' E' .. ff(e_value))
      changed_frate = false
    else
      output('G1 X' .. f(x) .. ' Y' .. f(y) .. ' Z' .. ff(z) .. ' E' .. ff(e_value))
    end
    current_z = z
  end
end

function move_e(e)
  extruder_e[current_extruder] = e
  local e_value = extruder_e[current_extruder] - extruder_e_restart[current_extruder]
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

function set_extruder_temperature(extruder,temperature)
  if skip_temp then 
    comment('M104 skipped')
    skip_temp = false
  else
    output('M104 S' .. temperature)
  end
end

function set_and_wait_extruder_temperature(extruder,temperature)
  if skip_temp then 
    comment('M109 skipped')
    skip_temp = false
  else
    output('M109 S' .. temperature)
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
