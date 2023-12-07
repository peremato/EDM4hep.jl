using UnROOT
using StructArrays

export buildlayout, getStructArray

function buildlayout(tree::UnROOT.LazyTree, branch::String, T::Type)
    layout = []
    #(index, type, [simple, composite, undef])
    fnames = fieldnames(T)
    ftypes = fieldtypes(T)
    splitnames = names(tree)
    for (fn,ft) in zip(fnames, ftypes)
        n = "$(branch)_$(fn)"
        if isempty(fieldnames(ft))    # atomic type (Int, Float,...)
            id = findfirst(x -> x == n, splitnames)
            push!(layout, isnothing(id) ? 0 : id)
        elseif ft <: Relation         # special treatment becuase 'begin' and 'end' cannot be fieldnames
            b = findfirst(x -> x == n * "_begin", splitnames)
            e = findfirst(x -> x == n * "_end", splitnames)
            push!(layout, (ft, (b,e)))
        elseif ft <: Index{T}
            push!(layout, -1)
        else
            push!(layout, buildlayout(tree, n, ft))
        end
    end
    (T, Tuple(layout))
end

function getStructArray(evt::UnROOT.LazyEvent, layout)
    len = length(evt[1])
    sa = AbstractArray[]
    type, inds = layout
    for l in inds
        if l isa Tuple
            push!(sa, getStructArray(evt, l))
        elseif l == 0
            push!(sa, zeros(Int64,len))
        elseif l == -1
            push!(sa, collect(1:len))
        else
            push!(sa, evt[l])
        end
    end
    StructArray{type}(Tuple(sa))
end



