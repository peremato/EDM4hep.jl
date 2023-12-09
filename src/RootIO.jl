module RootIO

    using UnROOT
    using EDM4hep
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
            elseif ft <: Index{T}         # index of himself
                push!(layout, -1)
            elseif ft <: Index            # index of another one....
                et = eltype(ft)
                id = findfirst(x -> x == "_$(branch)_$(et)_index", splitnames)
                push!(layout, id)
            else
                push!(layout, buildlayout(tree, n, ft))
            end
        end
        (T, Tuple(layout))
    end

    function getStructArray(evt::UnROOT.LazyEvent, layout, len = 0)
        if len == 0  # Need the lengh to fill missing colums
            n = layout[2][2]    # get the second data member (first may be missing)
            len = length(evt[n])
        end
        sa = AbstractArray[]
        type, inds = layout
        for l in inds
            if l isa Tuple
                push!(sa, getStructArray(evt, l, len))
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

    mutable struct Reader
        filename::String
        treename::String
        file::ROOTFile
        btypes::Dict{String, Type}
        layouts::Dict{String, Tuple}
        lazytree::LazyTree
        Reader(filename, treename="events") = new(filename, treename, ROOTFile(filename), Dict{String, Type}(), Dict{String, Tuple}())
    end

    function get(reader::Reader, treename::String)
        reader.treename = treename
        #---buyild a dinctionary of branches and associted type
        tree = reader.file[treename]
        pattern = r".+::([a-zA-Z]+?)(Data>|>)"
        for (i,key) in enumerate(keys(tree))
            classname = tree.fBranches[i].fClassName
            result = match(pattern, classname)
            if result !== nothing
                classname = result.captures[1]
                reader.btypes[key] = getproperty(EDM4hep, Symbol(classname))
            end
        end
        reader.lazytree = LazyTree(reader.file, treename,  keys(reader.btypes))
    end

    function get(reader::Reader, evt::UnROOT.LazyEvent, branchname::String)
        if !haskey(reader.layouts, branchname)
            reader.layouts[branchname] = buildlayout(reader.lazytree, branchname, reader.btypes[branchname])
        end
        getStructArray(evt, reader.layouts[branchname])
    end
end
