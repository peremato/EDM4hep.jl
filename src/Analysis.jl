"""
Analysis module for `EDM4hep.jl`

A number of data structures and functions to support analysis of EDM4hep data in multithreaded mode.

"""
module Analysis
    export AbstractAnalysisData, do_analysis!

    abstract type AbstractAnalysisData end

    """
        Base.empty!(data::AbstractAnalysisData)

    Default function to reset the user analysis data structure in case it 
    is not provided explicitly.
    """
    function Base.empty!(data::AbstractAnalysisData)
        for (fn,ft) in zip(propertynames(data), fieldtypes(typeof(data)))
            if isprimitivetype(ft)
                setproperty!(data, fn, zero(ft))
            else
                empty!(getproperty(data, fn))
            end
        end
    end

     """
        Base.append!(d1::AbstractAnalysisData, d2::AbstractAnalysisData)

    Default function to reset the user analysis data structure in case it 
    is not provided explicitly.
    """
    function Base.append!(d1::AbstractAnalysisData, d2::AbstractAnalysisData)
        typeof(d1) != typeof(d2) && error("Cannot append!() data of different types")
        for (fn,ft) in zip(propertynames(d1), fieldtypes(typeof(d1)))
            if isprimitivetype(ft)
                setproperty!(d1, fn, getproperty(d1,fn) + getproperty(d2,fn))
            else
                append!(getproperty(d1, fn), getproperty(d2, fn))
            end
        end
    end

    """
    do_analysis!(data::AbstractAnalysisData, analysis, reader, events; mt::Bool=false, tasks_per_thread::Int=4)

    Perform an analysis on all `events` by executing the `analysis` function. 
    The iteration will be chunked and distributed to different tasks running on 
    different threads if the option argument `mt` is set to `true`. 
    The results in `data` for all the chunks will be merged at the end of the analysis.   
    """
    function do_analysis!(data::AbstractAnalysisData, analysis, reader, events; mt::Bool=false, tasks_per_thread::Int=4)
        # Empty the user analysis data
        empty!(data)
        if mt
            # Chunk the total number of events to process
            chunks = Iterators.partition(events, length(events) ÷ (tasks_per_thread * Threads.nthreads()))
            # Spawn the tasks
            tasks = map(chunks) do chunk
                Threads.@spawn analysis(deepcopy(data), reader, chunk)
            end
            # Wait and sum the reduce the results
            results = fetch.(tasks)
            append!.(Ref(data), results)
        else
            analysis(data, reader, events)
        end
        return data
    end

end