#------------------------------------------------------------------------------#
# Purpose: To easily create a crowd of people with Fable.jl
#
#   Notes: I am creating each crowd as a series of rows:
#          - This means that the chairs for each lolli will go to every row
#            position
#          - The lolli, themself, might not. It depends on how many lollis are
#            in the crowd and how many can fit in each chair.
#------------------------------------------------------------------------------#
export create_row, create_crowd!, create_bench

abstract type AbstractCrowd end;

translate = @fum function translate(y,x; translation = (0,0))
    return point(y+translation[1], x+translation[2])
end

struct Row <: AbstractCrowd
    num_lollis::Int
    color_distribution::Union{FractalUserMethod, Vector{FractalUserMethod}}
    lolli_scale::Number
    spacing::Number
    location::Tuple{Number, Number}
    chair_idx::Number
    fill_percentage::Number
end

# right now, this assumes the only pre-layer is a chair
function create_H_set(row::Row; num_pre_layers = 0, num_post_layers = 0)
    if row.chair_idx > 0
        num_pre_layers += 1
    end

    start_location = (row.location[1],
                      row.location[2] - 0.5*row.num_lollis*row.spacing)

    if row.chair_idx > 0
        chair_set = (fo(translation(translation = start_location),))
    else
        chair_set = nothing
    end

    # creating H_set for each lolli
    if rand() < row.fill_percentage
        H_set = (fo(translation(translation = start_location),
                 rand(row.color_distribution)),)
    else
        H_set = ()
    end
    for i = 2:num_lollis
        new_location = (start_location[1], start_location[2]+spacing*(i-1))
        if row.chair_idx > 0
            chair_set = (chair_set...,
                         fo(translation(translation = new_location)))
        end

        if rand() < row.fill_percentage
            H_set = (H_set..., fo(translation(translation = new_location),
                               rand(row.color_distribution)))
        end
    end

    if length(H_set) > 0
        # distributing across all layers (chair, head, body, etc)
        H_set = (chair_set, H_set, H_set)
        for i = num_post_layers
            H_set = (H_set..., H_set)
        end
    else
        H_set = nothing
    end

    return H_set
end

function create_H_set(rows::Vector{Row};
                      num_pre_layers = 0, num_post_layers = 1)
    H_set = create_H_set(rows[1])
    for i = 2:length(rows)
        new_set = create_H_set(rows[i])
        H_set = Tuple([(H_set[i]..., new_set[i]...) for i = 1:length(H_set)])
    end

    return H_set
end

function create_row(; num_lollis = 0, color_distribution = [Shaders.black],
                      scale = 0.5, space = 0.5, location = (0,0),
                      chair_idx = 0, fill_percentage = 1)
    return Row(num_lollis, color_distribution, scale,
               space, location, chair_idx, fill_percentage)
end

function create_crowd!(base_lolli::LolliLayer, rows::Vector{Row})
    H_set = create_H_set(rows)
    set_transforms!(base_lolli, H_set)
end

#------------------------------------------------------------------------------#
# CHAIRS
#------------------------------------------------------------------------------#

bench_shader = @fum color function bench_shader(y, x; scale, y_location,
                                                base_color = (0.5, 0.5, 0.5, 1))
    ratio = (y-y_location-scale*0.5)/scale
    red = base_color[1]*ratio
    green = base_color[2]*ratio
    blue = base_color[3]*ratio
    alpha = base_color[4]*ratio

    return RGBA{Float32}(red, green, blue, alpha)
    
end

function create_bench(; location = (0,0), width = 0.5, height = 0.25,
                        color = bench_shader(scale = height, 
                                             y_location = location[1]))
    return create_rectangle(; scale_x = height, scale_y = width, color = color,
                              position = (height*0.5, 0))
end
