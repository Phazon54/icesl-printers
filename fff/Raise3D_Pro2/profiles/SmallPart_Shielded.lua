name_en = "Small parts - SHIELD ON"
name_fr = "Small parts - SHIELD ON"
name_es = "Small parts - SHIELD ON"

for i = 0, max_number_brushes, 1 do
  _G['extruder_'..i] = i
  _G['infill_extruder_'..i] = i
  _G['num_shells_' ..i] = 1
  _G['cover_thickness_mm_'..i] = 1.0
  _G['print_perimeter_'..i] = true
  _G['infill_percentage_'..i] = 100
end

gen_shield = true
shield_distance_to_part_mm = 2.0
shield_num_contour = 1
shield_brim_num_contour = 1
