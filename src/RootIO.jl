module RootIO

    using UnROOT
    using EDM4hep
    using StructArrays
    using StaticArrays

    """
    The Reader struture keeps a reference to the UnROOT LazyTree and caches already built 'layouts' of the EDM4hep types.
    The layouts maps a set of columns in the LazyTree into an object.
    """
    mutable struct Reader
        filename::String
        treename::String
        file::ROOTFile
        collectionIDs::Dict{String, UInt32}
        btypes::Dict{String, Type}
        layouts::Dict{String, Tuple}
        lazytree::LazyTree
        function Reader(filename, treename="events")
            reader = new(filename, treename)
            initReader(reader)
        end
    end

    function initReader(reader)
        #---Open the file ------------(need to know which type of file)----------------------------
        reader.file = ROOTFile(reader.filename)
        # collection IDs
        if  "podio_metadata" in keys(reader.file)
            meta = LazyTree(reader.file, "podio_metadata", [Regex("events___idTable/(.*)") => s"\1"])[1]
            reader.collectionIDs = Dict(meta.m_names .=> meta.m_collectionIDs)
        else
            @warn "ROOT file $filename does not have a 'podio_metadate' tree. Is it a PODIO file?"
            reader.collectionIDs = Dict{UInt32, String}()
        end
        # layouts and branch types
        reader.btypes = Dict{String, Type}()
        reader.layouts = Dict{String, Tuple}()
        return reader
    end

    function buildlayout(tree::UnROOT.LazyTree, branch::String, T::Type)
        layout = []
        relations = []
        fnames = fieldnames(T)
        ftypes = fieldtypes(T)
        splitnames = names(tree)
        for (fn,ft) in zip(fnames, ftypes)
            n = "$(branch)_$(fn)"
            if isempty(fieldnames(ft))          # foundamental type (Int, Float,...)
                id = findfirst(x -> x == n, splitnames)
                push!(layout, isnothing(id) ? 0 : id)
            elseif ft <: Relation               # special treatment becuase 'begin' and 'end' cannot be fieldnames
                b = findfirst(x -> x == n * "_begin", splitnames)
                e = findfirst(x -> x == n * "_end", splitnames)
                push!(layout, (ft, (b,e,-2)))   # -2 is collectionID of himself
                push!(relations, ("_$(branch)_$(fn)", eltype(ft)))  # add a tuple with (relation_branchname, target_type)
            elseif ft <: ObjectID{T}            # index of himself
                push!(layout, -1)
            elseif ft <: ObjectID               # index of another one....
                na = replace("$(fn)", "_idx" => "")     # remove the added suffix
                id = findfirst(x -> x == "_$(branch)_$(na)_index", splitnames)
                if isnothing(id)  # try with case insensitive compare
                    id = findfirst(x -> lowercase(x) == lowercase("_$(branch)_$(na)_index"), splitnames)
                end
                cid = findfirst(x -> x == "_$(branch)_$(na)_collectionID", splitnames)
                if isnothing(cid)  # try with case insensitive compare
                    cid = findfirst(x -> lowercase(x) == lowercase("_$(branch)_$(na)_collectionID"), splitnames)
                end
                push!(layout, (ft, (id, cid)))
            elseif ft <: SVector                # fixed arrarys are translated to SVector
                s = size(ft)[1]
                id = findfirst(x-> x == n * "[$(s)]", splitnames)
                push!(layout, (ft,(id,s))) 
            else
                push!(layout, buildlayout(tree, n, ft))
            end
        end
        (T, Tuple(layout), Tuple(relations))
    end

    function getStructArray(evt::UnROOT.LazyEvent, layout, collid, len = 0)
        if len == 0  # Need the length to fill missing colums
            n = layout[2][2]    # get the second data member (first may be missing)
            len = length(evt[n])
        end
        sa = AbstractArray[]
        type, inds = layout
        for l in inds
            if l isa Tuple 
                if l[1] <: SVector    # (type,(id, size))
                    ft, (id, s) = l 
                    push!(sa, StructArray{ft}(reshape(evt[id], s, len);dims=1))
                else
                    push!(sa, getStructArray(evt, l, collid, len))
                end
            elseif l == 0
                push!(sa, zeros(Int64,len))
            elseif l == -1
                push!(sa, collect(0:len-1))
            elseif l == -2
                push!(sa, fill(collid, len))
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
        collid = Base.get(reader.collectionIDs, bname, 0)             # The CollectionID has beeen assigned when opening the file
        sa = getStructArray(evt, layout, collid)
        if register
            assignEDStore(sa, collid)
            if !isempty(layout[3])  # check if there are relations in this branch 
                relations = Tuple(get(reader, evt, rb, btype=ObjectID{rt}; register=false) for (rb, rt) in layout[3])
                assignEDStore(relations, btype, collid)
            end
        end
        sa
    end
end
