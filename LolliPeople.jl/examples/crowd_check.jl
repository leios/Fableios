using Fable, Images, LolliPeople

function check_crowd_example(num_particles, num_iterations;
                             height = 0.5, ArrayType = Array,
                             filename = "out.png")
    bg = ColorLayer(RGBA(0.5, 0.5, 0.5, 1); ArrayType = ArrayType)
    res = (1080, 1920)

    translation_0 = fo(Smears.null)
    translation_1 = fo(translate(translation = (0, -0.5)))
    translation_2 = fo(translate(translation = (0, 0.5)))
    lolli = LolliPerson(scale = height, ArrayType = ArrayType,
                        num_particles = num_particles,
                        num_iterations = num_iterations,
                        head_transforms = (translation_0,
                                           translation_1,
                                           translation_2),
                        body_transforms = (translation_0,
                                           translation_1,
                                           translation_2))


    run!(lolli)
    write_image([bg, lolli.layer]; filename = filename)
end
