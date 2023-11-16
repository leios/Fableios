using Fable, Plots#, Backgrounds

function water_surface(res, bounds, waves, time; ArrayType = Array)
    surface = ArrayType(zeros(res))
    water_surface!(surface, waves, time; bounds)
    return surface
end

function plot_waves(res, bounds, waves, start_time, end_time, dt;
                    ArrayType = Array)
    time = start_time
    count = 0
    s = ArrayType(zeros(res))
    while time <= end_time
        water_surface!(s, waves, time; bounds)

        plt = heatmap(s)
        filename = "out"*lpad(count, 5, "0")*".png"
        println(filename)
        savefig(plt, filename)

        count += 1
        time += dt
        s[:] .= 0
    end
end
