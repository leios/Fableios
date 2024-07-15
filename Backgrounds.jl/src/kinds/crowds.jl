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
    @inbounds return point(y+translation[1], x+translation[2])
end

struct Row <: AbstractCrowd
    num_lollis::Int
    color_distribution::Vector{FUM} where FUM <: FableUserMethod
    height::Number
    spacing::Number
    location::Tuple{Number, Number}
    chair_idx::Number
    fill_percentage::Number
end

# right now, this assumes the only pre-layer is a chair
function create_H_set(row::Row; chair = false)
    if chair
        fill_percentage = 1.0
    else
        fill_percentage = row.fill_percentage
    end

    start_location = (row.location[1],
                      row.location[2] - 0.5*(row.num_lollis-1)*row.spacing)

    # creating H_set for each lolli
    if rand() < fill_percentage
        H_set = (fo(translate(translation = start_location),
                 Shaders.previous),)
        #H_set = (fo(translate(translation = start_location),
        #         rand(row.color_distribution)),)
    else
        H_set = ()
    end

    for i = 2:row.num_lollis
        new_location = (start_location[1], start_location[2]+row.spacing*(i-1))

        if rand() < fill_percentage
            H_set = (H_set..., fo(translate(translation = new_location),
                               Shaders.previous))
            #H_set = (H_set..., fo(translate(translation = new_location),
            #                   rand(row.color_distribution)))
        end
    end

    return H_set
end

function create_H_set(rows::Vector{Row}; chair = false)
    H_set = create_H_set(rows[1]; chair)
    for i = 2:length(rows)
        new_set = create_H_set(rows[i]; chair)
        H_set = (H_set..., new_set...)
    end

    return H_set
end

function create_row(; num_lollis = 0, color_distribution = [Shaders.black],
                      scale = 0.5, space = scale, location = (0,0),
                      chair_idx = 0, fill_percentage = 1)
    return Row(num_lollis, color_distribution, scale,
               space, location, chair_idx, fill_percentage)
end

function create_crowd!(lolli::LolliLayer, rows::Vector{Row})
    H_set = fo(create_H_set(rows))
    if rows[1].chair_idx != 0
        chair_set = fo(create_H_set(rows; chair = true))
    end
    lolli.head_transforms = H_set
    lolli.body_transforms = H_set
    if lolli.post_objects != nothing
        lolli.post_object_transforms =
            [H_set for i = 1:length(lolli.post_objects)]
    end
    if lolli.pre_objects != nothing
        pre_object_array = [H_set for i = 1:length(lolli.pre_objects)]
        pre_object_array[rows[1].chair_idx] = chair_set
        lolli.pre_object_transforms = pre_object_array
    end
    rebuild_operators!(lolli)
end

#------------------------------------------------------------------------------#
# CHAIRS
#------------------------------------------------------------------------------#

bench_shader = @fum color function bench_shader(y, x; scale, y_location,
                                                base_color = (0.5, 0.5, 0.5, 1))
    @inbounds begin
        ratio = (y-y_location-scale*0.5)/scale
        red = base_color[1]*ratio
        green = base_color[2]*ratio
        blue = base_color[3]*ratio
        alpha = base_color[4]*ratio
    end

    return RGBA{Float32}(red, green, blue, alpha)
    
end

function create_bench(; location = (0,0), width = 0.5, height = 0.25,
                        color = bench_shader(scale = height, 
                                             y_location = location[1]))
    return create_rectangle(; scale_y = height, scale_x = width, color = color,
                              position = (height*0.5, 0))
end
