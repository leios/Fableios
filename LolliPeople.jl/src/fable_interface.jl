function Fable.run!(layer::LolliLayer; frame = 0)
    run!(layer.head; frame = frame)
    run!(layer.body; frame = frame)
end

function Fable.postprocess!(layer::LolliLayer)
    postprocess!(layer.head)
    postprocess!(layer.body)

    for i = 1:length(layer.postprocessing_steps)
        if !layer.postprocessing_steps[i].initialized
            @info("initializing " *
                  string(typeof(layer.postprocessing_steps[i])) * "!")
            initialize!(layer.postprocessing_steps[i], layer)
        end
        layer.postprocessing_steps[i].op(layer, layer.postprocessing_steps[i])
    end
end

function Fable.to_canvas!(layer::LolliLayer, canvas_params::CopyToCanvas)
    to_canvas!(layer)
end

function Fable.to_canvas!(layer::LolliLayer)

    if layer.params.ArrayType <: Array
        kernel! = lolli_copy_kernel!(CPU(), layer.params.numcores)
    elseif has_cuda_gpu() && layer.params.ArrayType <: CuArray
        kernel! = lolli_copy_kernel!(CUDADevice(), layer.params.numthreads)
    elseif has_rocm_gpu() && layer.params.ArrayType <: ROCArray
        kernel! = lolli_copy_kernel!(ROCDevice(), layer.params.numthreads)
    end

    wait(kernel!(layer.canvas, layer.head.canvas, layer.body.canvas;
                 ndrange = size(layer.canvas)))
    
    return nothing
end

@kernel function lolli_copy_kernel!(canvas_out, head_canvas, body_canvas)

    tid = @index(Global, Linear)

    if head_canvas[tid].alpha == 0
        canvas_out[tid] = body_canvas[tid]
    else
        canvas_out[tid] = head_canvas[tid]
    end
end

function Fable.zero!(layer::LolliLayer)
    zero!(layer.head)
    zero!(layer.body)
    zero!(layer.canvas)
end
