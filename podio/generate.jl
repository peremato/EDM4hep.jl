using YAML
using Graphs

const builtin_types = Dict("int" => "Int32", "float" => "Float32", "double" => "Float64",
"bool" => "Bool", "long" => "Int64", "unsigned int" => "UInt32", 
"int16_t" => "Int16", "int32_t" => "Int32",  "uint64_t" => "UInt64", "uint32_t" => "UInt32", 
"unsigned long" => "UInt64", "char" => "Char", "short" => "Int16",
"long long" => "Int64", "unsigned long long" => "UInt64")

const fundamental_types = [
    "Int8", "UInt8", "Int16", "UInt16", "Int32", "UInt32",
    "Int64", "UInt64", "Int128", "UInt128",
    "Float16", "Float32", "Float64",
    "Complex{T}", "Bool", "Char", "Void",
    "Ptr{T}", "Function", "Function{T}",
    "Csize_t", "Cptrdiff_t"
]

function to_julia(ctype)
    ctype = ctype |> strip 
    #---Primitive type
    haskey(builtin_types, ctype) && return builtin_types[ctype]
    #---edm4hep type
    m = match(r"^edm4hep::(.*)", ctype)
    !isnothing(m) && return m.captures[1]
    #---std::array type
    m = match(r"std::array<([^,]+)[, ]+([0-9]+)>", ctype)
    !isnothing(m) && return "SVector{$(m.captures[2]),$(to_julia(m.captures[1]))}"
    #---Error
    error("Type [$ctype] not translatable to Julia")
end

function gen_member(v,t)
    vt = "$(v)::$(t)"
    vt = vt * " "^(length(vt) > 32 ? 1 : 32 - length(vt))
end

function split_member(member)
    comment = ""
    m = match(r"(.*)[ ]*//[ ]*(.*)", member)
    if !isnothing(m)
        comment = "# " * m.captures[2]
        member = m.captures[1] |> strip
    end
    sep = findlast(' ', member)
    member[1:sep-1] |> to_julia, member[sep+1:end], comment
end

data = YAML.load_file(joinpath(@__DIR__, "edm4hep.yaml"))
io = Base.stdout

function gen_component(io, key, body)
    jtype = to_julia(key)
    gen_docstring(io, key, body)
    println(io, "struct $jtype <: POD")
    members = []
    types = []
    for m in body["Members"]
        t, v, c = split_member(m)
        vt = "$(v)::$(t)"
        vt = vt * " "^(32 - length(vt))
        println(io, "    $(vt) $(c)")
        push!(members,v)
        push!(types, t)
    end
    args = join(members, ", ")
    defs = join(["$m=0" for m in members], ", ")
    println(io, "    $jtype($(defs)) = new($args)")
    println(io, "end\n")
    # add the converters here
    println(io, "Base.convert(::Type{$(jtype)}, t::Tuple) = $(jtype)(t...)")
    ntype = "@NamedTuple{$(join(["$m::$t" for (m,t) in zip(members,types)],", "))}"
    ninit = join(["v.$m" for m in members],", ")
    println(io, "Base.convert(::Type{$(jtype)}, v::$(ntype)) = $(jtype)($(ninit))\n")
end

function gen_datatype(io, key, dtype)
    jtype = to_julia(key)
    gen_docstring(io, key, dtype)
    println(io, "struct $jtype <: POD")
    vt = gen_member("index", "ObjectID{$jtype}")
    println(io, "    $(vt) # ObjectID of himself")
    println(io, "    #---Data Members")
    members = []
    defvalues = []
    for m in dtype["Members"]
        t, v, c = split_member(m)
        println(io, "    $(gen_member(v,t)) $(c)")
        push!(members,v)
        push!(defvalues, t in fundamental_types ? "0" : contains(t,"SVector") ? "zero($t)" : t*"()")
    end
    vectormembers = @NamedTuple{varname::String, totype::String}[]
    if haskey(dtype, "VectorMembers")
        println(io, "    #---VectorMembers")
        for (i,r) in enumerate(dtype["VectorMembers"])
            t, v, c = split_member(r)
            vt = gen_member(v, "PVector{$(jtype),$(t),$(i)}")
            println(io, "    $(vt) $(c)")
            push!(members, v)
            push!(defvalues, "PVector{$(jtype),$(t),$(i)}()")
            push!(vectormembers, (varname=v,totype=t))
        end
    end
    relations1toN = @NamedTuple{varname::String, totype::String}[]
    if haskey(dtype, "OneToManyRelations")
        println(io, "    #---OneToManyRelations")
        for (i,r) in enumerate(dtype["OneToManyRelations"])
            t, v, c = split_member(r)
            vt = gen_member(v, "Relation{$(jtype),$(t),$(i)}")
            println(io, "    $(vt) $(c)")
            push!(members, v)
            push!(defvalues, "Relation{$(jtype),$(t),$(i)}()")
            push!(relations1toN, (varname=v, totype=t))
        end
    end
    relations1to1 = @NamedTuple{varname::String, totype::String}[]
    if haskey(dtype, "OneToOneRelations")
        println(io, "    #---OneToOneRelations")
        for r in dtype["OneToOneRelations"]
            t, v, c = split_member(r)
            vt = gen_member(v*"_idx", "ObjectID{$(t)}")
            println(io, "    $(vt) $(c)")
            push!(members, v)
            push!(defvalues, "-1")
            push!(relations1to1, (varname=v, totype=t))
        end
    end
    println(io, "end\n")

    # add an extra constructor with keyword parameters
    args = join(members, ", ")
    defs = join(["$m=$dv" for (m,dv) in zip(members,defvalues)], ", ")
    println(io, """
                function $jtype(;$(defs))
                    $jtype(-1, $args)
                end
                """)
    # add an Base.getproperty() for the one-to-one relations
    if !isempty(relations1to1)
        println(io, "function Base.getproperty(obj::$jtype, sym::Symbol)")
        for (i, r) in enumerate(relations1to1)
            if i == 1
                println(io, "    if sym == :$(r.varname)")
            else
                println(io, "    elseif sym == :$(r.varname)")
            end
            println(io, "        idx = getfield(obj, :$(r.varname)_idx)")
            println(io, "        return iszero(idx) ? nothing : convert($(r.totype), idx)")
        end
        println(io, """
                        else # fallback to getfield
                            return getfield(obj, sym)
                        end
                    end""")
    end
    # add pushToXxxx() and popFromXxxx for al one-to-many relations
    if !isempty(relations1toN)
        global exports
        for r in relations1toN
            (;varname, totype) = r
            upvarname = uppercasefirst(varname)
            println(io, "function pushTo$(upvarname)(c::$jtype, o::$totype)")
            println(io, "    iszero(c.index) && (c = register(c))")
            println(io, "    c = @set c.$(varname) = push(c.$varname, o)")
            println(io, "    update(c)")
            println(io, "end")
            println(io, "function popFrom$(upvarname)(c::$jtype)")
            println(io, "    iszero(c.index) && (c = register(c))")
            println(io, "    c = @set c.$(varname) = pop(c.$varname)")
            println(io, "    update(c)")
            println(io, "end")
            push!(exports, "pushTo$(upvarname)", "popFrom$(upvarname)")
        end
    end
    if !isempty(vectormembers)
        global exports
        for v in vectormembers
            (;varname, totype) = v
            upvarname = uppercasefirst(varname)
            println(io, "function set$(upvarname)(o::$jtype, v::AbstractVector{$totype})")
            println(io, "    iszero(o.index) && (o = register(o))")
            println(io, "    o = @set o.$(varname) = v")
            println(io, "    update(o)")
            println(io,"end")
            push!(exports, "set$(upvarname)")
        end
    end
end

function gen_docstring(io, key, dtype)
    jtype = to_julia(key)
    desc = Base.get(dtype, "Description", "$jtype")
    author = Base.get(dtype, "Author", "")
    println(io, "\"\"\"")
    println(io, "$desc")
    !isempty(author) && println(io, "- Author: $author")
    println(io, "# Fields")
    for m in dtype["Members"] 
        t, v, c = split_member(m)
        println(io, "- `$v::$t`: $(c[3:end])")
    end
    for m in Base.get(dtype,"VectorMembers", []) 
        t, v, c = split_member(m)
        t = "PVector{$(t)}"
        println(io, "- `$v::$t`: $(c[3:end])")
    end
    if "OneToOneRelations" in keys(dtype) || "OneToManyRelations" in keys(dtype)
        println(io, "# Relations")
        for m in vcat(Base.get(dtype,"OneToOneRelations",[]),Base.get(dtype,"OneToManyRelations",[])) 
            t, v, c = split_member(m)
            println(io, "- `$v::$t`: $(c[3:end])")
        end
    end
    if !isempty(intersect(("VectorMembers", "OneToManyRelations"),keys(dtype)))
        println(io, "# Methods")
        for m in Base.get(dtype,"VectorMembers", [])
            t, v, c = split_member(m)
            println(io, "- `set$(uppercasefirst(v))(object::$jtype, v::AbstractVector{$t})`: assign a set of values to the `$v` vector member")
        end
        for m in Base.get(dtype,"OneToManyRelations", [])
            t, v, c = split_member(m)
            println(io, "- `pushTo$(uppercasefirst(v))(obj::$jtype, robj::$t)`: push related object to the `$v` relation")
            println(io, "- `popFrom$(uppercasefirst(v))(obj::$jtype)`: pop last related object from `$v` relation")
        end
    end
    println(io,"\"\"\"")
end

function gen_structarray(io, key, dtype; podio=17)
    jtype = to_julia(key)
    println(io, "function StructArray{$jtype, bname}(evt::UnROOT.LazyEvent, collid = UInt32(0), len = -1) where bname")
    first = true
    for m in dtype["Members"] 
        t, v, c = split_member(m)
        if first
            println(io, "    firstmem = getproperty(evt, Symbol(bname, :_$v))")
            println(io, "    len = length(firstmem)")
            println(io, "    columns = (StructArray{ObjectID{$jtype}}((collect(0:len-1),fill(collid,len))),")
            println(io, "        firstmem,")
            first = false
        else
            if t in fundamental_types
                println(io, "        getproperty(evt, Symbol(bname, :_$v)),")
            elseif startswith(t, "SVector")
                N = match(r"SVector{([0-9]+)[, ]([^,]+)}", t).captures[1]
                println(io, "        StructArray{$t}(reshape(getproperty(evt, Symbol(bname, \"_$v[$N]\")), $N, len);dims=1),")
            else
                println(io, "        StructArray{$t, Symbol(bname, :_$v)}(evt, collid, len),")
            end 
        end
    end
    if haskey(dtype, "VectorMembers")
        for (i,r) in enumerate(dtype["VectorMembers"])
            t, v, c = split_member(r)
            v == "subdetectorHitNumbers" && (v = "subDetectorHitNumbers")   # adhoc fixes
            println(io, "        StructArray{PVector{$(jtype),$(t),$(i)}, Symbol(bname, :_$v)}(evt, collid, len),")
        end
    end
    n_rels = 0
    if haskey(dtype, "OneToManyRelations")
        for (i,r) in enumerate(dtype["OneToManyRelations"])
            t, v, c = split_member(r)
            println(io, "        StructArray{Relation{$(jtype),$(t),$(i)}, Symbol(bname, :_$v)}(evt, collid, len),")
            n_rels += 1
        end
    end
    if haskey(dtype, "OneToOneRelations")
        for (i,r) in enumerate(dtype["OneToOneRelations"])
            t, v, c = split_member(r)
            v == "mcparticle" && (v = "MCParticle")   # adhoc fixes
            if podio == 16
                println(io, "        StructArray{ObjectID{$(t)}, Symbol(bname, \"#$n_rels\")}(evt, collid, len),")
            else
                println(io, "        StructArray{ObjectID{$(t)}, Symbol(:_, bname, \"_$v\")}(evt, collid, len),")
            end
            n_rels += 1
        end
    end
    println(io, "    )")
    println(io, "    return StructArray{$jtype}(columns)")
    println(io, "end\n")
end

function gen_structarray_rntuple(io, key, dtype)
    jtype = to_julia(key)
    println(io, "function StructArray{$jtype}(evt::UnROOT.LazyEvent, branch::Symbol, collid = UInt32(0))")
    println(io, "    sa = getproperty(evt, branch)")
    first = true
    for m in dtype["Members"] 
        t, v, c = split_member(m)
        if first
            println(io, "    len = length(sa.$(v))")
            println(io, "    fcollid = fill(collid,len)")
            println(io, "    columns = (StructArray{ObjectID{$jtype}}((collect(0:len-1),fcollid)),")
            println(io, "        sa.$(v),")
            first = false
        else
            if t in fundamental_types || startswith(t, "SVector")
                println(io, "        sa.$(v),")
            else
                println(io, "        StructArray{$(t)}(StructArrays.components(sa.$(v))),")
            end
        end
    end
    if haskey(dtype, "VectorMembers")
        for (i,r) in enumerate(dtype["VectorMembers"])
            t, v, c = split_member(r)
            v == "subdetectorHitNumbers" && (v = "subDetectorHitNumbers")   # adhoc fixes
            println(io, "        StructArray{PVector{$(jtype),$(t),$(i)}}((sa.$(v)_begin, sa.$(v)_end, fcollid)),")
        end
    end
    if haskey(dtype, "OneToManyRelations")
        for (i,r) in enumerate(dtype["OneToManyRelations"])
            t, v, c = split_member(r)
            println(io, "        StructArray{Relation{$(jtype),$(t),$(i)}}((sa.$(v)_begin, sa.$(v)_end, fcollid)),")
        end
    end
    if haskey(dtype, "OneToOneRelations")
        for (i,r) in enumerate(dtype["OneToOneRelations"])
            t, v, c = split_member(r)
            v == "mcparticle" && (v = "MCParticle")   # adhoc fixes
            println(io, "        StructArray{ObjectID{$(t)}}(StructArrays.components(getproperty(evt, Symbol(:_, branch, :_$v)))),")
        end
    end
    println(io, "    )")
    println(io, "    return StructArray{$jtype}(columns)")
    println(io, "end\n")
end

function build_graph(datatypes)
    types = to_julia.(keys(datatypes))
    graph = SimpleDiGraph(length(types))
    for (i,dtype) in enumerate(values(datatypes))
        for r in [get(dtype,"OneToOneRelations",[]);get(dtype,"OneToManyRelations",[])]
            t = split_member(r)[1]
            t == "POD" && continue
            d = findfirst(x->x == t, types)
            i != d && add_edge!(graph, d, i)
        end
    end
    graph
end


#---Components-------------------------------------------------------------------------------------
io = open(joinpath(@__DIR__, "genComponents.jl"), "w")
components = data["components"]
exports = []
for (key,value) in pairs(components)
    key == "edm4hep::ObjectID" && continue    # skip ObjectID (need a pametric one)
    gen_component(io, key, value)
    push!(exports, to_julia(key)) 
end
println(io, "export $(join(exports,", "))")
close(io)

#---Datatypes--------------------------------------------------------------------------------------
io = open(joinpath(@__DIR__, "genDatatypes.jl"), "w")
datatypes = data["datatypes"]
exports = []
dtypes = collect(keys(datatypes))
graph = build_graph(datatypes)
for i in topological_sort(graph)
    gen_datatype(io, dtypes[i], datatypes[dtypes[i]])
    push!(exports, to_julia(dtypes[i])) 
end
println(io, "export $(join(unique(exports),", "))")
close(io)

#---StructArrays--------------------------------------------------------------------------------------
for v in (16,17)
    local io = open(joinpath(@__DIR__, "genStructArrays-v$(v).jl"), "w")
    local datatypes = data["datatypes"]
    for (key,value) in pairs(datatypes)
        gen_structarray(io, key, value; podio=v)
    end
    close(io)
end
io = open(joinpath(@__DIR__, "genStructArrays-rntuple.jl"), "w")
datatypes = data["datatypes"]
for (key,value) in pairs(datatypes)
    gen_structarray_rntuple(io, key, value)
end
close(io)