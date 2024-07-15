using Fable, Images, LolliPeople

function pre_post_example(num_particles, num_iterations;
                          height = 0.5, ArrayType = Array,
                          pre_objects = [create_square(color=Shaders.blue)],
                          post_objects = [create_circle(color=Shaders.magenta,
                                                        position = (0, 1))],
                          filename = "out.png")
    bg = ColorLayer(RGBA(0.5, 0.5, 0.5, 1); ArrayType = ArrayType)
    res = (1080, 1920)

    lolli = LolliPerson(; scale = height, ArrayType, num_particles,
                          num_iterations, pre_objects, post_objects)

    run!(lolli)
    write_image([bg, lolli.layer]; filename = filename)
end
