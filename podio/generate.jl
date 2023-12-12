using YAML

const builtin_types = Dict("int" => "Int32", "float" => "Float32", "double" => "Float64",
"bool" => "Bool", "long" => "Int64", "unsigned int" => "UInt32", 
"int16_t" => "Int16", "int32_t" => "Int32",  "uint64_t" => "UInt64", "uint32_t" => "UInt32", 
"unsigned long" => "UInt64", "char" => "Char", "short" => "Int16",
"long long" => "Int64", "unsigned long long" => "UInt64")

function to_julia(ctype)
    #---Primitive type
    haskey(builtin_types, ctype) && return builtin_types[ctype]
    #---edm4hep type
    m = match(r"edm4hep::(.*)", ctype)
    !isnothing(m) && return m.captures[1]
    #---std::array type
    m = match(r"std::array<([^,]+)[, ]+([0-9]+)>", ctype)
    !isnothing(m) && return "SVector{$(m.captures[1]),$(m.captures[1])}"
    #---Error
    error("Type [$ctype] not translatable to Julia")
end

function split_member(member)
    comment = ""
    m = match(r"(.*)[ ]+//[ ]+(.*)", member)
    if !isnothing(m)
        comment = "# " * m.captures[2]
        member = m.captures[1] |> strip
    end
    sep = findlast(' ', member)
    member[1:sep-1], member[sep+1:end], comment
end


data = YAML.load_file("edm4hep.yaml")
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
    println("    $jtype($(defs)) = new($args)")
    println("end\n")

end

components = data["components"]
for (key,value) in pairs(components)
    gen_component(io, key, value) 
end


#=
"""
    Vector3D with doubles
"""
struct Vector3d
    x::Float64
    y::Float64
    z::Float64
    Vector3d(x=0,y=0,z=0) = new(x,y,z)
end
Base.convert(::Type{Vector3d}, t::Tuple) = Vector3d(t...)
Base.show(io::IO, v::Vector3d) = print(io, "($(v.x),$(v.y),$(v.z))")
Base.:+(v1::Vector3d, v2::Vector3d) = Vector3d(v1.x + v2.x, v1.y + v2.y, v1.z + v2.z)
Base.:-(v1::Vector3d, v2::Vector3d) = Vector3d(v1.x - v2.x, v1.y - v2.y, v1.z - v2.z)
Base.:*(v::Vector3d, a::Number) = Vector3d(a*v.x, a*v.y, b*v.z)
=#