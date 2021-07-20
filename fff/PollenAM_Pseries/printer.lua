-- Pollen AM Series P Profile
-- Bedell Pierre 20/07/2021

bed_origin_x = bed_size_x_mm/2
bed_origin_y = bed_size_y_mm/2

current_z = 0.0

current_extruder = 0

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

function select_extruder(extruder)
  -- enable tool
  output('D23 T' .. extruder .. 'V0')
  output('D23 T' .. extruder .. 'V1 S5')
end

function swap_extruder(from,to,x,y,z)
  output('\n;swap_extruder')
  extruder_e_swap[from] = extruder_e_swap[from] + extruder_e[from] - extruder_e_reset[from]

  -- swap extruder
  output('G92 E0')
  output('D23 T' .. from .. 'V0')
  output('D23 T' .. to .. 'V1 S5')
  output('T' .. to)
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
  local e_value = extruder_e[current_extruder] - extruder_e_restart[current_extruder]
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
  output('M104 T' .. extruder .. 'S' .. mixer_temp_degree_c ..' C' .. cold_end_temp_degree_c' H' .. temperature)
end

function set_and_wait_extruder_temperature(extruder,temperature)
  output('M109 T' .. extruder .. 'S' .. mixer_temp_degree_c ..' C' .. cold_end_temp_degree_c' H' .. temperature)
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
