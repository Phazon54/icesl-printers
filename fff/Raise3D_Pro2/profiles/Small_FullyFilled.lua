name_en = "Small Prints 100% infill"
name_fr = "Small Prints 100% infill"
name_es = "Small Prints 100% infill"

for i = 0, max_number_brushes, 1 do
  _G['extruder_'..i] = i
  _G['infill_extruder_'..i] = i
  _G['num_shells_' ..i] = 1
  _G['cover_thickness_mm_'..i] = 1.0
  _G['print_perimeter_'..i] = true
  _G['infill_percentage_'..i] = 100
end
