-- BambuLab X1C Profile
-- Bedell Pierre 2024/02/08

-- List of Bambu specific Gcodes: https://forum.bambulab.com/t/bambu-lab-x1-specific-g-code/666

extruder_e = 0
extruder_e_restart = 0

current_extruder = 0
current_frate = 0

current_fan_speed = -1

processing = false

path_type = 2 -- 1:default, 2:Craftware, 3:Prusa/Super Slicer, 4:Cura

path_tag = {
  --{ 'default',  'Craftware',              'Prusa/Super Slicer',         'Orca',                             'Cura'            }
  { ';travel',    ';segType:Travel',        '',                           '',                                 ''                },
  { ';perimeter', ';segType:Perimeter',     ';TYPE:External perimeter',   '; FEATURE: Outer wall',            ';TYPE:WALL-OUTER'},
  { ';shell',     ';segType:HShell',        ';TYPE:Internal perimeter',   '; FEATURE: Inner wall',            ';TYPE:WALL-INNER'},
  { ';cover',     ';segType:Infill',        ';TYPE:Solid infill',         '; FEATURE: Internal solid infill', ';TYPE:FILL'      }, -- for Orca typing, both '; FEATURE: Bottom surface' and '; FEATURE: Top surface' exist ... choose one or reimplment accordingly
  { ';infill',    ';segType:Infill',        ';TYPE:Internal infill',      '; FEATURE: Sparse infill',         ';TYPE:FILL'      },
  { ';gapfill',   ';segType:Infill',        ';TYPE:Gap fill',             '; FEATURE: Gap infill',            ';TYPE:FILL'      },
  { ';bridge',    ';segType:SupportTouch',  ';TYPE:Overhang perimeter',   ': FEATURE: Bridge',                ';TYPE:WALL-OUTER'},
  { ';support',   ';segType:Support',       ';TYPE:Support material',     '; FEATURE: Support',               ';TYPE:SUPPORT'   },
  { ';brim',      ';segType:Skirt',         ';TYPE:Skirt',                '; FEATURE: Skirt',                 ';TYPE:SKIRT'     },
  { ';raft',      ';segType:Raft',          ';TYPE:Skirt',                '; FEATURE: Skirt',                 ';TYPE:SKIRT'     },
  { ';shield',    ';segType:Pillar',        ';TYPE:Skirt',                '; FEATURE: Skirt',                 ';TYPE:SKIRT'     },
  { ';tower',     ';segType:Pillar',        ';TYPE:Skirt',                '; FEATURE: Prime tower',           ';TYPE:SKIRT'     },
}

model_id = math.random(1,1000)
toolchange_count = 0

--##################################################

function comment(text)
  output('; ' .. text)
end

function round(number, decimals)
  local power = 10^decimals
  return math.floor(number * power) / power
end

function convert_time(time)
  local days = floor(time/86400)
  local hours = floor(mod(time, 86400)/3600)
  local minutes = floor(mod(time,3600)/60)
  local seconds = floor(mod(time,60))
  return format("%d:%02d:%02d:%02d",days,hours,minutes,seconds)
end

function vol_to_mass(volume, density)
  return density * volume
end

function e_to_mm_cube(filament_diameter, e)
  local r = filament_diameter / 2
  return (math.pi * r^2 ) * e
end

-- get the E value (for G1 move) from a specified deposition move
function e_from_dep(dep_length, dep_width, dep_height, extruder)
  local r1 = dep_width / 2
  local r2 = filament_diameter_mm[extruder] / 2
  local extruded_vol = dep_length * math.pi * r1 * dep_height
  return extruded_vol / (math.pi * r2^2)
end

function tag_path()
  if     path_is_travel          then output(path_tag[1][path_type])
  elseif path_is_perimeter       then output(path_tag[2][path_type])
  elseif path_is_outer_perimeter then output(path_tag[2][path_type])
  elseif path_is_shell           then output(path_tag[3][path_type])
  elseif path_is_cover           then output(path_tag[4][path_type])
  elseif path_is_infill          then output(path_tag[5][path_type])
  elseif path_is_gapfill         then output(path_tag[6][path_type])
  elseif path_is_bridge          then output(path_tag[7][path_type])
  elseif path_is_support         then output(path_tag[8][path_type])
  elseif path_is_brim            then output(path_tag[9][path_type])
  elseif path_is_raft            then output(path_tag[10][path_type])
  elseif path_is_shield          then output(path_tag[11][path_type])
  elseif path_is_tower           then output(path_tag[12][path_type])
  end
end

function set_accel()
  if layer_id < 1 then -- fisrt layer specific acceleration
    output('M204 S' .. first_layer_acc)
  else
    if      path_is_travel    then output('M204 S' .. default_acc)
    elseif  path_is_perimeter then output('M204 S' .. perimeter_acc)
    elseif  path_is_shell     then output('M204 S' .. perimeter_acc)
    elseif  path_is_infill    then output('M204 S' .. infill_acc)
    elseif  path_is_raft      then output('M204 S' .. default_acc)
    elseif  path_is_brim      then output('M204 S' .. default_acc)
    elseif  path_is_shield    then output('M204 S' .. default_acc)
    elseif  path_is_support   then output('M204 S' .. default_acc)
    elseif  path_is_tower     then output('M204 S' .. default_acc)
    else output('M204 S' .. default_acc)
    end
  end
end

--##################################################

function header()
  -- additionnal informations for Bambu web API (?) (based on Bambu/Orca output)
  output("; HEADER_BLOCK_START")
  output("; generated by " .. slicer_name .. " " .. slicer_version) -- missing date/time of slicing (not available for now)
  output("; model printing time: " .. convert_time(time_sec) .. "; total estimated time: " .. convert_time(time_sec))
  output("; total layer number: " .. number_of_layers)
  output("; model label id: " .. model_id)
  output("; filament density : " .. filament_density)
  output("; filament diameter : " .. filament_diameter_mm)
  output("; max_z_height : " .. f(extent_z))
  output("; HEADER_BLOCK_END")

  output('\n')
  output('; EXECUTABLE_BLOCK_START')
  output('M73 P0 R' .. (time_sec / 60))
  output('M201 X20000 Y20000 Z500 E5000')
  output('M203 X500 Y500 Z12 E25')
  output('M204 P20000 R5000 T20000')
  output('M205 X9.00 Y9.00 Z0.20 E2.50')
  output('M106 S0')
  output('M106 P2 S0')

  output('\n')
  output(';===== machine: X1 =========================')
  output(';===== date: 20230707 =====================')
  output(';===== turn on the HB fan =================')
  output('M104 S75 ;set extruder temp to turn on the HB fan and prevent filament oozing from nozzle')
  output(';===== reset machine status =================')
  output('G91')
  output('M17 Z0.4 ; lower the z-motor current')
  output('G380 S2 Z30 F300 ; G380 is same as G38; lower the hotbed , to prevent the nozzle is below the hotbed')
  output('G380 S2 Z-25 F300 ;')
  output('G1 Z5 F300;')
  output('G90')
  output('M17 X1.2 Y1.2 Z0.75 ; reset motor current to default')
  output('M960 S5 P1 ; turn on logo lamp')
  output('G90')
  output('M220 S100 ;Reset Feedrate')
  output('M221 S100 ;Reset Flowrate')
  output('M73.2   R1.0 ;Reset left time magnitude')
  output('M1002 set_gcode_claim_speed_level : 5')
  output('M221 X0 Y0 Z0 ; turn off soft endstop to prevent protential logic problem')
  output('G29.1 Z{+0.0} ; clear z-trim value first')
  output('M204 S10000 ; init ACC set to 10m/s^2')
  
  output('\n')
  output(';===== heatbed preheat ====================')
  output('M1002 gcode_claim_action : 2')
  output('M140 S' ..bed_temp_degree_c .. ' ;set bed temp')
  output('M190 S' ..bed_temp_degree_c .. ' ;wait for bed temp')

  if first_layer_scan then
    output('\n')
    output(';=========register first layer scan=====')
    output('M977 S1 P60')
  end

  output('\n')
  output(';=============turn on fans to prevent PLA jamming=================')
  if name_en=="PLA" then
    if bed_temp_degree_c > 45 then 
      output('M106 P3 S180')
    elseif bed_temp_degree_c > 50 then
      output('M106 P3 S255 ;Prevent PLA from jamming')
    end
  end
  output('M106 P2 S100 ; turn on big fan ,to cool down toolhead')

  output('\n')
  output(';===== prepare print temperature and material ==========')
  output('M104 S' .. extruder_temp_degree_c[extruders[0]] .. ' ;set extruder temp')
  output('G91')
  output('G0 Z10 F1200')
  output('G90')
  output('G28 X')
  output('M975 S1 ; turn on')
  output('G1 X60 F12000')
  output('G1 Y245')
  output('G1 Y265 F3000')
  output('M620 M')
  output('M620 S[initial_no_support_extruder]A   ; switch material if AMS exist')
    M109 S[nozzle_temperature_initial_layer]
    G1 X120 F12000

    G1 X20 Y50 F12000
    G1 Y-3
    T[initial_no_support_extruder]
    G1 X54 F12000
    G1 Y265
    M400
M621 S[initial_no_support_extruder]A
M620.1 E F{filament_max_volumetric_speed[initial_no_support_extruder]/2.4053*60} T{nozzle_temperature_range_high[initial_no_support_extruder]}

end

function footer()
  --output(';end gcode')

  output(';===== date: 20230428 =====================')
  output('M400 ; wait for buffer to clear')
  output('G92 E0 ; zero the extruder')
  output('G1 E-0.8 F1800 ; retract')
  output('G1 Z' .. (f(extent_z) + 0.5) ..' F900 ; lower z a little')
  output('G1 X65 Y245 F12000 ; move to safe pos ')
  output('G1 Y265 F3000')

  output('G1 X65 Y245 F12000')
  output('G1 Y265 F3000')
  output('M140 S0 ; turn off bed')
  output('M106 S0 ; turn off fan')
  output('M106 P2 S0 ; turn off remote part cooling fan')
  output('M106 P3 S0 ; turn off chamber cooling fan')

  output('G1 X100 F12000 ; wipe')
  output('; pull back filament to AMS')
  output('M620 S255')
  output('G1 X20 Y50 F12000')
  output('G1 Y-3')
  output('T255')
  output('G1 X65 F12000')
  output('G1 Y265')
  output('G1 X100 F12000 ; wipe')
  output('M621 S255')
  output('M104 S0 ; turn off hotend')

  output('M622.1 S1 ; for prev firware, default turned on')
  output('M1002 judge_flag timelapse_record_flag')
  output('M622 J1')
  output('    M400 ; wait all motion done')
  output('    M991 S0 P-1 ;end smooth timelapse at safe pos')
  output('    M400 S3 ;wait for last picture to be taken')
  output('M623; end of "timelapse_record_flag"')

  output('M400 ; wait all motion done')
  output('M17 S')
  output('M17 Z0.4 ; lower z motor current to reduce impact if there is something in the bottom')
  if (f(extent_z) + 100.0) <250 then
    output('G1 Z' .. (f(extent_z) + 100.0) .. ' F600')
    output('G1 Z' .. (f(extent_z) + 98.0))
  else
    output('G1 Z250 F600')
    output('G1 Z248')
  end
  output('M400 P100')
  output('M17 R ; restore z current')

  output('G90')
  output('G1 X128 Y250 F3600')

  output('M220 S100  ; Reset feedrate magnitude')
  output('M201.2 K1.0 ; Reset acc magnitude')
  output('M73.2   R1.0 ;Reset left time magnitude')
  output('M1002 set_gcode_claim_speed_level : 0')

  output('M17 X0.8 Y0.8 Z0.5 ; lower motor current to 45% power')

  output('M106 P3 S0') -- turn off filter fan
end

function layer_start(zheight)
  output('; update layer progress')
  output('M73 L' .. layer_id .. 'M623')
  output('M991 S0 P' .. layer_id .. ' ;notify layer change')
end

function layer_stop()
  extruder_e_restart = extruder_e
  output('G92 E0')

  --output('; layer change')

  output('; layer num/total_layer_count: ' .. layer_id .. '/' .. number_of_layers)
  output('M622.1 S1 ; for prev firware, default turned on')
  output('M1002 judge_flag timelapse_record_flag')
  output('M622 J1')
  if timelapse_type == 0 then
    output('; timelapse without wipe tower')
    output('M971 S11 C10 O0')
  elseif timelapse_type == 1 then
    output('; timelapse with wipe tower')
    output('G92 E0')
    output('G1 E-[retraction_length] F1800')
    output('G17')
    output('G2 Z{layer_z + 0.4} I0.86 J0.86 P1 F20000 ; spiral lift a little')
    output('G1 X65 Y245 F20000 ; move to safe pos')
    output('G17')
    output('G2 Z{layer_z} I0.86 J0.86 P1 F20000')
    output('G1 Y265 F3000')
    output('M400 P300')
    output('M971 S11 C10 O0')
    output('G92 E0')
    output('G1 E[retraction_length] F300')
    output('G1 X100 F5000')
    output('G1 Y255 F20000')
  end
end

function retract(extruder,e)
  local len   = filament_priming_mm[extruder]
  local speed = retract_mm_per_sec[extruder] * 60
  output('G1 F' .. speed .. ' E' .. ff(e - len - extruder_e_restart))
  extruder_e = e - len
  return e - len
end

function prime(extruder,e)
  local len   = filament_priming_mm[extruder]
  local speed = priming_mm_per_sec[extruder] * 60
  output('G1 F' .. speed .. ' E' .. ff(e + len - extruder_e_restart))
  extruder_e = e + len
  return e + len
end

function filament_flush(flush_length, flush_compensation, filament_feedrate)
  output('; FLUSH_START')
  output('; always use highest temperature to flush')
  output('M400')
  
  if name_en == "PETG" then
    output('M109 S220')
  else
    output('M109 S' .. filament_max_temp)
  end

  -- the multipliers seem arbitrary of computer from the purge tool
  -- the values used here seemed to be the generic ones
  output('G1 E' .. (flush_length - flush_compensation) * 0.18 .. ' F' .. filament_feedrate)
  output('G1 E' .. (flush_length - flush_compensation) * 0.02 .. ' F50')
  output('G1 E' .. (flush_length - flush_compensation) * 0.18 .. ' F' .. filament_feedrate)
  output('G1 E' .. (flush_length - flush_compensation) * 0.02 .. ' F50')
  output('G1 E' .. (flush_length - flush_compensation) * 0.18 .. ' F' .. filament_feedrate)
  output('G1 E' .. (flush_length - flush_compensation) * 0.02 .. ' F50')
  output('G1 E' .. (flush_length - flush_compensation) * 0.18 .. ' F' .. filament_feedrate)
  output('G1 E' .. (flush_length - flush_compensation) * 0.02 .. ' F50')
  output('G1 E' .. (flush_length - flush_compensation) * 0.18 .. ' F' .. filament_feedrate)
  output('G1 E' .. (flush_length - flush_compensation) * 0.02 .. ' F50')
  output('; FLUSH_END')
end

function eject_purge(extruder)
  -- ejection procedure
  output('G1 E-' .. filament_priming_mm[extruder] .. ' F1800')
  output('M106 P1 S255')
  output('M400 S3')
  output('M106 P1 S0')
  output('G1 X80 F15000')
  output('G1 X60 F15000')
  output('G1 X80 F15000')
  output('G1 X60 F15000; shake to put down garbage')

  output('G1 X70 F5000')
  output('G1 X90 F3000')
  output('G1 Y255 F4000')
  output('G1 X100 F5000')
  output('G1 Y265 F5000')
  output('G1 X70 F10000')
  output('G1 X100 F5000')
  output('G1 X70 F10000')
  output('G1 X100 F5000')
  output('G1 X165 F15000; wipe and shake')
  output('G1 Y245 F21000')
  output('G1 X65 ')
  output('G1 Y265 F3000')

  output('G1 E' .. filament_priming_mm[extruder] .. ' F300')
end

-- this is called once for each used extruder at startup
-- it is used here to generate purge with proper nozzle diameter
function select_extruder(extruder)



  if air_filter then
    output('M106 P3 S170') -- ~70%
  end
end

function swap_extruder(from,to,x,y,z) 
  local filament_velocity = 523 -- (mm/min) magic value from gcode? (not found in any orca setting)
  --output('; filament change')

  output('M620 S' .. to .. 'A')
  output('M204 S9000')
  if toolchange_count > 1 then
    output('G17')
    output('G2 Z' .. z + 0.4 .. ' I0.86 J0.86 P1 F10000 ; spiral lift a little from second lift')
  end
  output('G1 Z' .. z + 3.0 .. ' F1200')

  output('G1 X70 F21000')
  output('G1 Y245')
  output('G1 Y265 F3000')
  output('M400')
  output('M106 P1 S0')
  output('M106 P2 S0')
  if extruder_temp_degree_c[from] > 142 and extruder_temp_degree_c[to] < 255
    output('M104 S'.. extruder_temp_degree_c[from])
  end
  output('G1 X90 F3000')
  output('G1 Y255 F4000')
  output('G1 X100 F5000')
  output('G1 X120 F15000')

  output('G1 X20 Y50 F21000')
  output('G1 Y-3')

  -- no idea if it is really used, as not present in most gcodes ?
  --[[

    if toolchange_count == 2
    output('; get travel path for change filament')
    -- impossible to find documentation for 'travel_point_' placeholders
    output('M620.1 X' .. travel_point_1_x .. ' Y' .. travel_point_1_y ..' F21000 P0')
    output('M620.1 X' .. travel_point_2_x .. ' Y' .. travel_point_2_y ..' F21000 P1')
    output('M620.1 X' .. travel_point_3_x .. ' Y' .. travel_point_3_y ..' F21000 P2')
  end
  ]]
  -- warning, IceSL cannot manage filament type per extruder !
  output('M620.1 E F' .. filament_velocity .. ' T' .. filament_max_temp)-- previous extruder
  output('T' .. to)
  output('M620.1 E F' .. filament_velocity .. ' T' .. filament_max_temp)-- next extruder

  if to < 255 then -- wtf? this check might be here to prevent an overflow on orca extruder management ?
    output('M400')

    output('G92 E0')

    -- TODO: add flush_length support ?
    filament_flush(flush_length, flush_compensation, filament_velocity)
    eject_purge(extruder)

  else
    output('G1 X' .. x .. ' Y' .. y .. ' Z' .. z .. ' F12000')
  end
  output('M621 S' .. to .. 'A')

  output('M106 P3 S0') -- turn off chamber fan
  toolchange_count = toolchange_count + 1
end

function move_xyz(x,y,z)
  if processing == true then 
    tag_path() 
    processing = false

    -- acceleration management
    if use_per_path_accel then
      set_accel()
    end
  end
  output('G0 X' .. f(x) .. ' Y' .. f(y) .. ' Z' .. ff(z))
end

function move_xyze(x,y,z,e)
  if processing == false then 
    tag_path() 
    processing = true

    -- acceleration management
    if use_per_path_accel then
      set_accel()
    end
  end

  local e_value = e - extruder_e_restart
  extruder_e = e
  output('G1 X' .. f(x) .. ' Y' .. f(y) .. ' Z' .. ff(z) .. ' F' .. current_frate .. ' E' .. ff(e_value))
end

function move_e(e)
  local e_value = e - extruder_e_restart
  extruder_e = e
  output('G1 E' .. ff(e_value))
end

function set_feedrate(feedrate)
  output('G1 F' .. feedrate)
  current_frate = feedrate
end

function extruder_start()
end

function extruder_stop()
end

function progress(percent)
  output('M73 P0 R' .. (percent * time_sec) / 60 )
end

function set_extruder_temperature(extruder,temperature)
  output('M104 S' .. temperature .. ' T' .. extruder)
end

function set_and_wait_extruder_temperature(extruder,temperature)
  output('M109 S' .. temperature .. ' T' .. extruder)
end

function set_fan_speed(speed)
  if speed ~= current_fan_speed then
    output('M106 S'.. math.floor(255 * speed/100))
    current_fan_speed = speed
  end

  -- air filter fan management
  if bed_temp_degree_c > 55 then 
    output('M106 P3 S200')
  elseif bed_temp_degree_c > 50 then 
    output('M106 P3 S150')
  elseif bed_temp_degree_c > 45 then 
    output('M106 P3 S50')
  end
end

-- The contents of this function is a placeholder
-- you can replace it by what you see fit to exented "layer time"
function wait(sec,x,y,z)
  local pos_x = 10 -- "parking" coordinates
  local pos_y = 10

  output("\n; Waiting for minimum layer time -- " .. f(sec) .. "s remaining")
  output("G0 F" .. travel_speed_mm_per_sec * 60 .. " X" .. pos_x .. " Y" .. pos_y .. " ; go to the parking position")
  -- G4 uses milliseconds on Klipper !
  output("G4 P" .. f(sec) * 1000 .. " ; wait for " .. f(sec) .. "s")
  output("G0 F" .. travel_speed_mm_per_sec * 60 .. " X" .. f(x) .." Y" .. f(y) .. " Z" .. ff(z) .. "; going back to  the previous location\n")
end
