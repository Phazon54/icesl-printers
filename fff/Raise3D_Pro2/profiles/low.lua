name_en = "Fast print"
name_fr = "Impression rapide"
name_es = "Impresión rápida"

z_layer_height_mm = 0.3

print_speed_mm_per_sec = 60
perimeter_print_speed_mm_per_sec = 45
cover_print_speed_mm_per_sec = 45
first_layer_print_speed_mm_per_sec = 25

travel_speed_mm_per_sec = 100

for i = 0, max_number_brushes, 1 do
  _G['extruder_'..i] = i
  _G['infill_extruder_'..i] = i
  _G['num_shells_' ..i] = 3
  _G['cover_thickness_mm_'..i] = 1.2
  _G['print_perimeter_'..i] = true
  _G['infill_percentage_'..i] = 20
end

process_thin_features = false
