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
    member[1:sep-1], member[sep+1:end], comment
end

data = YAML.load_file(joinpath(@__DIR__, "edm4hep.yaml"))
io = Base.stdout

function gen_component(io, key, body)
    jtype = to_julia(key)
    println(io, "\"\"\"\n    $jtype\n\"\"\"")
    println(io, "struct $jtype")
    members = []
    for m in body["Members"]
        t, v, c = split_member(m)
        vt = "$(v)::$(to_julia(t))"
        vt = vt * " "^(32 - length(vt))
        println(io, "    $(vt) $(c)")
        push!(members,v)
    end
    args = join(members, ", ")
    defs = join(["$m=0" for m in members], ", ")
    println(io, "    $jtype($(defs)) = new($args)")
    println(io, "end\n")
end

function gen_datatype(io, key, dtype)
    jtype = to_julia(key)
    desc = dtype["Description"]
    author = dtype["Author"]
    println(io, "\"\"\"\nstruct $jtype\n\n    Description: $desc\n    Author: $author\n\"\"\"")
    println(io, "struct $jtype <: POD")
    vt = gen_member("index", "ObjectID{$jtype}")
    println(io, "    $(vt) # ObjectID of himself")
    println(io, "\n    #---Data Members")
    members = []
    defvalues = []
    for m in dtype["Members"]
        t, v, c = split_member(m)
        t = to_julia(t)
        println(io, "    $(gen_member(v,t)) $(c)")
        push!(members,v)
        push!(defvalues, t in fundamental_types ? "0" : contains(t,"SVector") ? "zero($t)" : t*"()")
    end
    if haskey(dtype, "OneToOneRelations")
        println(io, "\n    #---OneToOneRelations")
        for r in dtype["OneToOneRelations"]
            t, v, c = split_member(r)
            t = to_julia(t)
            vt = gen_member(v*"_idx", "ObjectID{$(t)}")
            println(io, "    $(vt) $(c)")
            push!(members, v)
            push!(defvalues, "-1")
        end
    end
    nrelations = 0
    if haskey(dtype, "OneToManyRelations")
        println(io, "\n    #---OneToManyRelations")
        for (i,r) in enumerate(dtype["OneToManyRelations"])
            t, v, c = split_member(r)
            t = to_julia(t)

            vt = gen_member(v, "Relation{$(t),$(i)}")
            println(io, "    $(vt) $(c)")
            push!(members, v)
            push!(defvalues, "Relation{$(t),$(i)}()")
            nrelations += 1
        end
    end
    println(io, "end\n")
    # add relations(::Type{ED}) = <number>
    println(io,"relations(::Type{$jtype}) = $(nrelations)")
    # add an extra constructor with keyword parameters
    args = join(members, ", ")
    defs = join(["$m=$dv" for (m,dv) in zip(members,defvalues)], ", ")
    println(io, """
                function $jtype(;$(defs))
                    $jtype(-1, $args)
                end
                """)
end

function build_graph(datatypes)
    types = to_julia.(keys(datatypes))
    graph = SimpleDiGraph(length(types))
    for (i,dtype) in enumerate(values(datatypes))
        for r in [get(dtype,"OneToOneRelations",[]);get(dtype,"OneToManyRelations",[])]
            t = split_member(r)[1] |> to_julia
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
println(io, "export $(join(exports,", "))")
close(io)

