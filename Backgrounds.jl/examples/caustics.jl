using Fable, Plots, Backgrounds, Colors

function plot_waves(res, bounds, waves, start_time, end_time, dt;
                    ArrayType = Array)
    time = start_time
    count = 0
    s = ArrayType(zeros(res))
    while time <= end_time
        Caustics.water_surface!(s, waves, time; bounds)

        plt = heatmap(s)
        filename = "out"*lpad(count, 5, "0")*".png"
        println(filename)
        savefig(plt, filename)

        count += 1
        time += dt
        s[:] .= 0
    end
end

function test_caustics(num_particles, num_iterations, waves,
                       start_time, end_time, dt;
                       ArrayType = Array, filebase = "out")
    world_size = (2,2)
    ppu = 500
    bl = ColorLayer(RGB{Float32}(0,0,0); world_size = world_size, ppu = ppu)

    square = define_circle(color = Shaders.white)
    H_post = fo(Caustics.pool_caustics(waves = waves))
    fl = FractalLayer(H = square, H_post = H_post,
                      world_size = world_size, ppu = ppu,
                      num_particles = num_particles,
                      num_iterations = num_iterations,
                      overlay = false, 
                      logscale = true)
    layers = [bl, fl]
    count = 0 
    time = start_time
    while time <= end_time
        run!(layers, frame = current_frame(time))
        write_image(layers; filename = filebase*lpad(count, 5, "0")*".png")
        count += 1
        time += dt
    end
end
