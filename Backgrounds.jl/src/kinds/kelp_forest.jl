export kelp_forest

@inline function background_ocean(y, x, horizon, greenness)
    if y <= horizon # above the ocean
        red = 0.25
        green = 0.25+0.5*greenness
        blue = 0.75
    else # below the ocean
        red = 0.25
        green = (0.25+(0.5*greenness))
        blue = 0.75
    end

    return RGBA{Float32}(red, green, blue, 1.0)
end

kelp_forest = @fum color function kelp_forest(y, x;
                                              horizon = 0.0,
                                              greenness = 0.0)
    return background_ocean(y, x, horizon, greenness)
end
