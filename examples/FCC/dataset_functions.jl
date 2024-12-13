using XRootD.XrdCl
using Measurements

const base_location = "/eos/experiment/fcc/prod/fcc/ee/test_spring2024/240gev"
const server = "root://eospublic.cern.ch"

struct DataSample
    name::String
    sublocation::String
    crosssection::Measurement
    sampleid::Int
    totalevents::Int
    eventsinfile::Int
end
location(ds) = joinpath(base_location, ds.sublocation, lpad(string(ds.sampleid), 8, '0'))

const datasamples = Dict(
    "ee_mumuH" => DataSample("ee_mumuH", "mumuH/CLD_o2_v05/rec", 6.7626 ± 0.0001, 16610, 3964000, 1000),
    "Hbb" => DataSample("ee_Hbb", "Hbb/CLD_o2_v05/rec", 46.1684 ± 0.0002, 16562, 1998800, 100))

function get_filelist(ds::AbstractString, nevents::Int)
    ds = datasamples[ds]
    nevents > ds.totalevents && error("Requested more events than available")
    filesneeded = ceil(Int, nevents/ds.eventsinfile)
    xrd = FileSystem(server)
    result = String[]
    root = location(ds)
    for (root, dirs, files) in walkdir(xrd, root)
        length(files) == 0 && continue
        nfiles = min(length(files), filesneeded)
        fullroot = server * "/" * root
        append!(result, joinpath.(Ref(fullroot), files[1:nfiles]))
        filesneeded -= nfiles
        filesneeded <= 0 && break
    end
    return result
end






