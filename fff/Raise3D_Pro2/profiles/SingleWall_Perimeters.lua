name_en = "Perimeter only - single wall"
name_fr = "Perimeter only - single wall"
name_es = "Perimeter only - single wall"

for i = 0, max_number_brushes, 1 do
  _G['extruder_'..i] = i
  _G['infill_extruder_'..i] = i
  _G['num_shells_' ..i] = 0
  _G['cover_thickness_mm_'..i] = 0
  _G['print_perimeter_'..i] = true
  _G['infill_percentage_'..i] = 0
end
