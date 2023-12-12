module RootIO

    using UnROOT
    using EDM4hep
    using StructArrays

    """
    The Reader struture keeps a reference to the UnROOT LazyTree and caches already built 'layouts' of the EDM4hep types.
    The layouts maps a set of columns in the LazyTree into an object.
    """
    mutable struct Reader
        filename::String
        treename::String
        file::ROOTFile
        btypes::Dict{String, Type}
        layouts::Dict{String, Tuple}
        lazytree::LazyTree
        Reader(filename, treename="events") = new(filename, treename, ROOTFile(filename), Dict{String, Type}(), Dict{String, Tuple}())
    end

    function buildlayout(tree::UnROOT.LazyTree, branch::String, T::Type)
        layout = []
        relations = []
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
                push!(relations, "_$(branch)_$(fn)")
            elseif ft <: ObjectID{T}         # index of himself
                push!(layout, -1)
            elseif ft <: ObjectID            # index of another one....
                et = eltype(ft)
                id = findfirst(x -> x == "_$(branch)_$(et)_index", splitnames)
                push!(layout, id)
            else
                push!(layout, buildlayout(tree, n, ft))
            end
        end
        (T, Tuple(layout), Tuple(relations))
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
                push!(sa, collect(0:len-1))
            else
                push!(sa, evt[l])
            end
        end
        StructArray{type}(Tuple(sa))
    end

    """
    get(reader::Reader, treename::String)

    Opens a 'TTree' in the ROOT file (typically the events tree). 
    It returns a 'LazyTree' that allows the user to iterate over
    events. 
    """
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

    """
    get(reader::Reader, evt::UnROOT.LazyEvent, bname::String; btype::Type=Any, register=true)

    Gets an object collection by its name, with the possibility to overwrite the mapping Julia type or use the 
    type known in the ROOT file (C++ class name). The optonal key parameter `register` indicates is the collection
    needs to be registered to the `EDStore`.
    """
    function get(reader::Reader, evt::UnROOT.LazyEvent, bname::String; btype::Type=Any, register=true)
        btype =  btype === Any ? reader.btypes[bname] : btype    # Allow the user to force the actual type
        if haskey(reader.layouts, bname)                         # Check whether the the layout has been pre-compiled 
            layout = reader.layouts[bname]
        else
            layout = buildlayout(reader.lazytree, bname, btype)
            reader.layouts[bname] = layout
        end
        sa = getStructArray(evt, layout)
        if register 
            assignEDStore(sa)
            if !isempty(layout[3])  # check if there are relations in this branch 
                relations = Tuple(get(reader, evt, rb, btype=ObjectID{btype}; register=false) for rb in layout[3])
                assignEDStore(relations, btype)
            end
        end
        sa
    end
end
