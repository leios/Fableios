# Because the night sky is purely a shader, this is a relatively simple example
using Fable, Backgrounds

layer = ShaderLayer(night_sky)
run!(layer)
write_image(layer; filename = "out.png")
