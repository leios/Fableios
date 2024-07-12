using Fable, Backgrounds

layer = ShaderLayer(kelp_forest)
run!(layer)
write_image(layer; filename = "out.png")
