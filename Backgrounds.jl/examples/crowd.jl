using Fable, LolliPeople, Backgrounds, Images

function crowd_example(num_particles, num_iterations; ArrayType = Array,
                       lollis_per_row = 5, num_rows = 1, scale = 0.25)
    bg = ColorLayer(RGBA(0.5, 0.5, 0.5, 1); ArrayType = ArrayType)

    chair = create_bench(; width = scale, height = 0.5*scale)
    lolli = LolliPerson(; scale = 0.25, ArrayType,
                          num_particles, num_iterations,
                          pre_objects = [chair])
    start_height = -(num_rows*0.5*scale)
    rows = [create_row(num_lollis = lollis_per_row - floor(i/2),
                       scale = scale,
                       location = (start_height + 0.5*scale, 0),
                       chair_idx = 1
                       ) for i = 1:num_rows]
    create_crowd!(lolli, rows)
    return lolli

    run!(lolli)
    write_image([bg, lolli.layer])
end 
