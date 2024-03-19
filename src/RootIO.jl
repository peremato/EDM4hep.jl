"""
ROOT I/O module for `EDM4hep.jl`

It supports both formats: TTree and RNTuple

"""
module RootIO

    using UnROOT
    using EDM4hep
    using StructArrays
    using StaticArrays
    using PrettyTables


    export StructArray, isnewpodio

    const builtin_types = Dict("int" => Int32, "float" => Float32, "double" => Float64,
    "bool" => Bool, "long" => Int64, "unsigned int" => UInt32, 
    "int16_t" => Int16, "int32_t" => Int32,  "uint64_t" => UInt64, "uint32_t" => UInt32, 
    "unsigned long" => UInt64, "char" => Char, "short" => Int16,
    "long long" => Int64, "unsigned long long" => UInt64,
    "string" => String)

    const newpodio = v"0.16.99"
    const _isnewpodio = Ref(false)
    isnewpodio() = _isnewpodio[]

    """
    The Reader structure keeps a reference to the UnROOT LazyTree and caches already built 'layouts' of the EDM4hep types.
    The layouts maps a set of columns in the LazyTree into an object.
    """
    mutable struct Reader
        filename::Vector{String}
        treename::String
        files::Vector{ROOTFile}
        isRNTuple::Bool
        podioversion::VersionNumber
        collectionIDs::Dict{String, UInt32}
        collectionNames::Dict{UInt32, String}
        btypes::Dict{String, Type} 
        layouts::Dict{String, Tuple}
        lazytree::LazyTree
        Reader(filename::AbstractString, treename="events") = initReader(new([filename], treename))
        Reader(filenames::Vector{<:AbstractString}, treename="events") = initReader(new(filenames, treename))
        Reader(filenames::Base.Generator{<:AbstractVector}, treename="events") = initReader(new(collect(filenames), treename))
    end

    function initReader(reader)
        #---Open the file ------------(need to know which type of file)----------------------------
        reader.files = ROOTFile.(reader.filename)
        #---Loop over all files and check consistency --------------------------------------------
        for (i,tfile) in enumerate(reader.files)
            if  "podio_metadata" in keys(tfile)
                rtuple = tfile["podio_metadata"]
                if rtuple isa UnROOT.RNTuple
                    isRNTuple = true
                    meta = LazyTree(rtuple, ["events___idTable", "events_collectionNames",  "PodioBuildVersion"])[1]
                    collectionIDs = Dict(meta.events_collectionNames .=> meta.events___idTable)
                    collectionNames = Dict(meta.events___idTable .=> meta.events_collectionNames)
                    podioversion = VersionNumber(meta.PodioBuildVersion...)
                else
                    isRNTuple = false
                    meta = LazyTree(tfile, "podio_metadata", [Regex("events___idTable/|PodioBuildVersion/(.*)") => s"\1"])[1]
                    collectionIDs = Dict(meta.m_names .=> meta.m_collectionIDs)
                    collectionNames = Dict(meta.m_collectionIDs .=> meta.m_names)
                    podioversion = VersionNumber(meta.major, meta.minor, meta.patch)
                end
            else
                error("""ROOT file $(reader.filename[i]) does not have a 'podio_metadata' tree. 
                        Is it a PODIO file? or perhaps is from a very old version of podio?
                        Stopping here.""")
            end
            #---store and check consistency
            if i == 1
                reader.isRNTuple = isRNTuple
                reader.collectionIDs = collectionIDs
                reader.collectionNames = collectionNames
                reader.podioversion = podioversion
            else
                reader.isRNTuple != isRNTuple && error("File list is not uniform ROOT I/O format (TTree/RNTuple) for file $(reader.filename[i])")
                reader.podioversion != podioversion && error("File list is not uniform PODIO version. $(reader.podioversion) != $(podioversion) for file $(reader.filename[i])")
            end
        end
        if reader.podioversion >= newpodio
            _isnewpodio[] = true
        else
            _isnewpodio[] = false
        end

        # layouts and branch types
        reader.btypes = Dict{String, Type}()
        reader.layouts = Dict{String, Tuple}()
        if !reader.isRNTuple
            pmajor = reader.podioversion >= newpodio ? "17" : "16"
            include(joinpath(@__DIR__,"../podio/genStructArrays-v$pmajor.jl"))
        end
        return reader
    end

    function Base.show(io::IO, r::Reader)
        nfiles = length(r.filename)
        nevents = sum([r.isRNTuple ? UnROOT._length(tf["events"]) : tf["events"].fEntries for tf in r.files])
        data1 = [hcat([i == 1 ? "File Name(s)" : "" for i in 1:nfiles], r.filename);
                 "# of events" nevents;
                 "IO Format" r.isRNTuple ? "RNTuple" : "TTree";
                 "PODIO version" r.podioversion;
                 "ROOT version" VersionNumber(r.files[1].format_version÷10000, r.files[1].format_version%10000÷100, r.files[1].format_version%100)]
        pretty_table(io, data1, header=["Atribute", "Value"], alignment=:l)
        if !isempty(r.btypes)
            bs = sort([b for b in keys(r.btypes) if !occursin("_", b)])
            bt = getindex.(Ref(r.btypes), bs)
            bc = EDM4hep.hex.(Base.get.(Ref(r.collectionIDs), bs, 0x00000000))
            pretty_table(io, [bs bt bc], header=["BranchName", "Type", "CollectionID"], alignment=:l, sortkeys = true, max_num_of_rows=100)
        end
    end 

    function buildlayoutTTree(reader::Reader, branch::String, T::Type)
        layout = []
        relations = []
        vmembers = []
        fnames = fieldnames(T)
        ftypes = fieldtypes(T)
        splitnames = names(reader.lazytree)
        n_rels  = 0      # number of one-to-one or one-to-many Relations 
        n_pvecs = 0      # number of vector member
        for (fn,ft) in zip(fnames, ftypes)
            n = "$(branch)_$(fn)"
            if isempty(fieldnames(ft))          # foundamental type (Int, Float,...)
                id = findfirst(x -> x == n, splitnames)
                push!(layout, isnothing(id) ? 0 : id)
            elseif ft <: Relation               # special treatment becuase 'begin' and 'end' cannot be fieldnames
                b = findfirst(x -> x == n * "_begin", splitnames)
                e = findfirst(x -> x == n * "_end", splitnames)
                push!(layout, (ft, (b,e,-2)))   # -2 is collectionID of himself
                if reader.podioversion >= newpodio
                    push!(relations, ("_$(branch)_$(fn)", eltype(ft)))  # add a tuple with (relation_branchname, target_type)
                else
                    push!(relations, ("$(branch)#$(n_rels)", eltype(ft)))
                    n_rels += 1
                end
            elseif ft <: PVector
                b = findfirst(x -> x == n * "_begin", splitnames)
                if isnothing(b)
                    b = findfirst(x -> lowercase(x) == lowercase( n * "_begin"), splitnames)
                end
                e = findfirst(x -> x == n * "_end", splitnames)
                if isnothing(e)
                    e = findfirst(x -> lowercase(x) == lowercase( n * "_end"), splitnames)
                end
                push!(layout, (ft, (b,e,-2)))   # -2 is collectionID of himself
                if reader.podioversion >= newpodio
                    push!(vmembers, ("_$(branch)_$(fn)", eltype(ft)))  # add a tuple with (vector_branchname, target_type)
                else
                    push!(vmembers, ("$(branch)_$(n_pvecs)", eltype(ft)))  # add a tuple with (vector_branchname, target_type)
                    n_pvecs += 1
                end
            elseif ft <: ObjectID{T}            # index of himself
                push!(layout, (ft, (-1,-2)))
            elseif ft <: ObjectID               # index of another one....
                na = replace("$(fn)", "_idx" => "")     # remove the added suffix
                id = cid = nothing
                if reader.podioversion >= newpodio
                    id = findfirst(x -> x == "_$(branch)_$(na)_index", splitnames)
                    if isnothing(id)  # try with case insensitive compare
                        id = findfirst(x -> lowercase(x) == lowercase("_$(branch)_$(na)_index"), splitnames)
                    end
                    cid = findfirst(x -> x == "_$(branch)_$(na)_collectionID", splitnames)
                    if isnothing(cid)  # try with case insensitive compare
                        cid = findfirst(x -> lowercase(x) == lowercase("_$(branch)_$(na)_collectionID"), splitnames)
                    end
                else
                    id = findfirst(x -> x == "$(branch)#$(n_rels)_index", splitnames)
                    cid = findfirst(x -> x == "$(branch)#$(n_rels)_collectionID", splitnames)
                    n_rels += 1
                end
                if isnothing(id) || isnothing(cid)  # link not found in the data file
                    @warn "Cannot find branch for one-to-one relation $(branch)::$(na)"
                    push!(layout, (ft,(0,0)))
                else
                    push!(layout, (ft, (id, cid)))
                end
            elseif ft <: SVector                # fixed arrays are translated to SVector
                s = size(ft)[1]
                id = findfirst(x-> x == n * "[$(s)]", splitnames)
                push!(layout, (ft,(id,s))) 
            else
                push!(layout, buildlayoutTTree(reader, n, ft))
            end
        end
        (T, Tuple(layout), Tuple(relations), Tuple(vmembers))
    end

    function buildlayoutRNTuple(reader::Reader, branch::String, T::Type)
        relations = []
        vmembers = []
        fnames = fieldnames(T)
        ftypes = fieldtypes(T)
        for (fn,ft) in zip(fnames, ftypes)
            if ft <: Relation
                push!(relations, ("_$(branch)_$(fn)", eltype(ft)))  # add a tuple with (relation_branchname, target_type)
            elseif ft <: PVector
                push!(vmembers, ("_$(branch)_$(fn)", eltype(ft)))  # add a tuple with (relation_branchname, target_type)
            end
        end
        (T, (), Tuple(relations), Tuple(vmembers))
    end

    #=
    # Only for TTree-------
    function getStructArrayTTree(evt::UnROOT.LazyEvent, layout, collid, len = -1)
        if len == -1  # Need the length to fill missing colums
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
                elseif l[1] <: ObjectID
                    ft, (id, cid) = l
                    if id == -1                             # self ObjectID
                        push!(sa, StructArray{ft}((collect(0:len-1),fill(collid, len))))
                    elseif len > 0 && evt[cid][1] == -2     # Handle the case collid is -2 :-( )
                        push!(sa, StructArray{ft}((evt[id],zeros(UInt32,len))))
                    else                                    # general case
                        push!(sa, StructArray{ft}((evt[id],evt[cid])))
                    end    
                else
                    push!(sa, getStructArrayTTree(evt, l, collid, len))
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
    =#

    #---Only for RNTuple
    function getStructArrayRNTuple(evt::UnROOT.LazyEvent, branch, collection, layout, collid, len = -1)
        type = layout[1]
        pnames = propertynames(collection)
        ftypes = fieldtypes(type)
        fnames = fieldnames(type)
        if len == -1  # Need the length to fill missing colums
            len = length(getproperty(collection, pnames[1]))
        end
        sa = AbstractArray[]
        for (fn, ft) in zip(fnames, ftypes)
            if isempty(fieldnames(ft))          # fundamental type (Int, Float,...)
                if fn in pnames
                    push!(sa, getproperty(collection, fn))
                else
                    push!(sa, zeros(ft,len))
                end
            elseif ft <: SVector
                push!(sa, getproperty(collection, fn))  # no reshaping to be done, it is already an SVector  
            elseif ft == ObjectID{type}
                push!(sa, StructArray{ft}((collect(0:len-1),fill(collid,len))))
            elseif ft <: ObjectID                       # index of another one....
                na = replace("$(fn)", "_idx" => "", "mcparticle" => "MCParticle")     # remove the added suffix
                br = "_$(branch)_$(na)"
                se = getproperty(evt, Symbol(br))
                push!(sa, StructArray{ft}((se.index, se.collectionID)))
            elseif ft <: Relation               # special treatment because 'begin' and 'end' cannot be fieldnames
                bsym = Symbol("$fn" * "_begin")
                esym = Symbol("$fn" * "_end")
                push!(sa, StructArray{ft}((getproperty(collection, bsym), getproperty(collection, esym), fill(collid,len))))
            elseif ft <: PVector               # special treatment becuase 'begin' and 'end' cannot be fieldnames
                bsym = Symbol("$fn" * "_begin")
                esym = Symbol("$fn" * "_end")
                v = StructArray{ft}((getproperty(collection, bsym), getproperty(collection, esym), fill(collid,len)))
                push!(sa, StructArray{ft}((getproperty(collection, bsym), getproperty(collection, esym), fill(collid,len))))
            else
                se = getproperty(collection, fn)
                push!(sa, getStructArrayRNTuple(evt, branch, se, (ft,(),()), collid, len))
            end
        end
        StructArray{type}(Tuple(sa))
    end

    #---StructArray constructors--------------------------------------------------------------------
    @inline function StructArray{Relation{ED,TD,N}, bname}(evt::UnROOT.LazyEvent, collid, len) where {ED,TD,N,bname}
        StructArray{Relation{ED,TD,N}}((getproperty(evt, Symbol(bname, :_begin)), getproperty(evt, Symbol(bname, :_end)), fill(collid,len)))
    end
    @inline function StructArray{PVector{ED,T, N}, bname}(evt::UnROOT.LazyEvent, collid, len) where {ED,T,N,bname}
        StructArray{PVector{ED,T,N}}((getproperty(evt, Symbol(bname, :_begin)), getproperty(evt, Symbol(bname, :_end)), fill(collid,len)))
    end
    @inline function StructArray{SVector{N,T}, bname}(evt::UnROOT.LazyEvent, collid, len) where {N,T,bname}
        StructArray{SVector{N,T}}(reshape(getproperty(evt, Symbol(bname, "[$N]")), N, len);dims=1)
    end
    @inline function StructArray{ObjectID{ED}, bname}(evt::UnROOT.LazyEvent, collid = UInt32(0), len = -1) where {ED,bname}
        inds = getproperty(evt, Symbol(bname, :_index))
        cids = getproperty(evt, Symbol(bname, :_collectionID))
        len > 0 && cids[1] == -2 && fill!(cids, 0)      # Handle the case collid is -2 :-( )
        StructArray{ObjectID{ED}}((inds, cids))
    end
    @inline function StructArray{Vector3f, bname}(evt::UnROOT.LazyEvent, collid, len) where {bname}
        StructArray{Vector3f}((getproperty(evt, Symbol(bname, :_x)), getproperty(evt, Symbol(bname, :_y)), getproperty(evt, Symbol(bname, :_z))))
    end
    @inline function StructArray{T, bname}(evt::UnROOT.LazyEvent, collid, len) where {T <: Number,bname}
        getproperty(evt, bname)
    end

    #---Generic StructArray constructor (fall-back)------------------------------------------------
    function StructArray{T,bname}(evt::UnROOT.LazyEvent, collid = UInt32(0), len = -1) where {T,bname} 
        fnames = fieldnames(T)
        n_rels::Int32  = 0      # number of one-to-one or one-to-many Relations 
        if len == -1            # Need the length to fill missing colums
            len = length(getproperty(evt, Symbol(bname, :_, fnames[2])))
        end
        sa = Tuple( map(zip(fieldnames(T), fieldtypes(T))) do (fn,ft)
            if ft == ObjectID{T}
                StructArray{ft}((collect(0:len-1),fill(collid,len)))
            elseif ft <: Relation
                n_rels += 1
                StructArray{ft,Symbol(bname,:_,fn)}(evt, collid, len)
            elseif ft <: ObjectID              # index of another one....
                n_rels += 1
                StructArray{ft, Symbol(bname, "#$(n_rels-1)")}(evt, collid, len)
            else
                StructArray{ft,Symbol(bname,:_,fn)}(evt, collid, len)
            end
        end)
        StructArray{T}(sa)
    end

    """
    get(reader::Reader, treename::String)

    Opens a 'TTree' in the ROOT file (typically the events tree). 
    It returns a 'LazyTree' that allows the user to iterate over
    events. 
    """
    function get(reader::Reader, treename::String)
        reader.treename = treename
        #---build a dictionary of branches and associted type
        tree = reader.files[1][treename]
        pattern = r"(edm4hep|podio)::([a-zA-Z]+?)(Data$|$)"
        vpattern = r"(std::)?vector<(std::)?(.*)>"
        if tree isa UnROOT.TTree
            for (i,key) in enumerate(keys(tree))
                classname = tree.fBranches[i].fClassName
                result = match(vpattern, classname)
                isnothing(result) && continue
                classname = result.captures[3]
                result = match(pattern, classname)
                if isnothing(result) # Primitive type
                    reader.btypes[key] = builtin_types[classname]
                else
                    classname = result.captures[2]
                    reader.btypes[key] = getproperty(EDM4hep, Symbol(classname))
                end
            end
        elseif tree isa UnROOT.RNTuple
            for fr in tree.header.field_records
                fr.struct_role != 0x0001 && continue
                fieldname = fr.field_name
                fieldname == "_0" && continue
                classname = fr.type_name
                result = match(vpattern, classname)
                isnothing(result) && continue
                classname = result.captures[3]
                result = match(pattern, classname)
                if isnothing(result) # Primitive type
                    reader.btypes[fieldname] = Base.get(builtin_types, classname, Nothing)
                else
                    classname = result.captures[2]
                    reader.btypes[fieldname] = getproperty(EDM4hep, Symbol(classname))
                end
            end
        else
            error("$treename is not a TTree or RNutple")
        end
        reader.lazytree = reduce(vcat, (LazyTree(tfile, "events", keys(reader.btypes)) for tfile in reader.files))
    end

    #---This shouldn't be needed when issue https://github.com/JuliaHEP/UnROOT.jl/issues/305
    function safe_getproperty(evt::UnROOT.LazyEvent, s::Symbol, t::Type)
        try
            return getproperty(evt, s)
        catch e
            if e isa MethodError
                if isempty(fieldnames(t))
                    return t[]
                else
                    return StructArray(t[])
                end
            else
                rethrow()
            end
        end
    end
    
    function _get(reader::Reader, evt::UnROOT.LazyEvent, bname::String, btype::Type, register::Bool)
        if haskey(reader.layouts, bname)                         # Check whether the the layout has been pre-compiled 
            layout = reader.layouts[bname]
        else
            if reader.isRNTuple
                layout = buildlayoutRNTuple(reader, bname, btype)
            else
                layout = buildlayoutTTree(reader, bname, btype)
            end
            reader.layouts[bname] = layout
        end
        collid = Base.get(reader.collectionIDs, bname, 0)             # The CollectionID has beeen assigned when opening the file
        sbranch = Symbol(bname)
        if reader.isRNTuple
            if isprimitivetype(layout[1])
                sa = hasproperty(evt, sbranch) ? safe_getproperty(evt,sbranch,layout[1]) : layout[1][]
            else
                sa = getStructArrayRNTuple(evt, sbranch, safe_getproperty(evt, sbranch, layout[1]), layout, collid)
            end
        else
            sa = StructArray{btype,sbranch}(evt, collid)
        end
        if register
            assignEDStore(sa, collid)
            if !isempty(layout[3])  # check if there are relations in this branch
                relations = Tuple(_get(reader, evt, rb, ObjectID{rt}, false) for (rb, rt) in layout[3])
                assignEDStore_relations(relations, btype, collid)
            end
            if !isempty(layout[4])  # check if there are vector members in this branch
                vmembers = Tuple(_get(reader, evt, rb, rt, false) for (rb, rt) in layout[4])
                assignEDStore_vmembers(vmembers, btype, collid)
            end
        end
        sa
    end

    """
    get(reader::Reader, evt::UnROOT.LazyEvent, bname::String; btype::Type=Any, register=true)

    Gets an object collection by its name, with the possibility to overwrite the mapping Julia type or use the 
    type known in the ROOT file (C++ class name). The optonal key parameter `register` indicates is the collection
    needs to be registered to the `EDStore`.
    """
    function get(reader::Reader, evt::UnROOT.LazyEvent, bname::String; btype::Type=Any, register=false)
        btype = btype === Any ? reader.btypes[bname] : btype     # Allow the user to force the actual type
        _get(reader, evt, bname, btype, register)
    end
end
