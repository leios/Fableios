using Fable, Images, LolliPeople

function check_crowd_example(num_particles, num_iterations;
                             height = 0.5, ArrayType = Array, num_frames = 10,
                             filename = "out.png")
    bg = ColorLayer(RGBA(0.5, 0.5, 0.5, 1); ArrayType = ArrayType)
    res = (1080, 1920)

    translation_1 = fo(translate(translation = (0, -0.5)))
    translation_2 = fo(translate(translation = (0, 0.5)))
    lolli = LolliPerson(size = height, ArrayType = ArrayType,
                        num_particles = num_particles,
                        num_iterations = num_iterations,
                        head_smears = ((translation_1, translation_2), translation_2),
                        body_smears = ((translation_1, translation_2), translation_2))
    run!(lolli)
    write_image([bg, lolli]; filename = filename)

end
