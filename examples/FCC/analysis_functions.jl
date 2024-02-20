using EDM4hep
using LorentzVectorHEP
using Combinatorics
using IterTools

export resonanceBuilder, recoilBuilder

"""
    resonanceBuilder(rmass::AbstractFloat, legs::AbstractVector{ReconstructedParticle})

Returns a container with the best resonance of 2 by 2 combinatorics of the `legs` container
sorted by closest to the input `rmass` in absolute value.
"""
function resonanceBuilder(rmass::AbstractFloat, legs::AbstractVector{ReconstructedParticle})
    result = ReconstructedParticle[]
    length(legs) < 2 && return result
    for (a,b) in combinations(legs, 2)
        lv = LorentzVector(a.energy, a.momentum...) + LorentzVector(b.energy, b.momentum...)
        rcharge = a.charge + b.charge
        push!(result, ReconstructedParticle(mass=mass(lv), momentum=(lv.x, lv.y, lv.z), charge=rcharge))
    end
    sort!(result, lt =  (a,b) -> abs(rmass-a.mass) < abs(rmass-b.mass))
    return result[1:1]  # take the best one
end

"""
    recoilBuilder(comenergy::AbstractFloat, legs::AbstractVector{ReconstructedParticle})

    build the recoil from an arbitrary list of input `ReconstructedParticle`s and the center of mass energy.
"""
function recoilBuilder(comenergy::AbstractFloat, in::AbstractVector{ReconstructedParticle})
    result = ReconstructedParticle[]
    isempty(in) && return result
    recoil_lv = LorentzVector(comenergy, 0, 0, 0)
    for p in in
        recoil_lv -= LorentzVector(p.mass, p.momentum...)
    end
    push!(result, ReconstructedParticle(mass=mass(recoil_lv), momentum=(recoil_lv.x, recoil_lv.y, recoil_lv.z)))
    return result
end

