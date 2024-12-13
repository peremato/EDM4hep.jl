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
        energy = sqrt(p.mass^2 + p.momentum.x^2 + p.momentum.y^2 + p.momentum.z^2)
        recoil_lv -= LorentzVector(energy, p.momentum...)
    end
    push!(result, ReconstructedParticle(mass=mass(recoil_lv), momentum=(recoil_lv.x, recoil_lv.y, recoil_lv.z)))
    return result
end


"""
    unBoostCrossingAngle(in, angle)
    
    Apply the crossing angle correction to the input `ReconstructedParticle` `in` with the given `angle`.
"""
function unBoostCrossingAngle(in, angle)
    ta = tan(angle)
    e = in.energy
    pₓ = in.momentum.x
    e′  = e * sqrt(1 + ta^2) + pₓ * ta 
    pₓ′ = pₓ * sqrt(1 + ta^2) + e * ta
    return @set (@set in.momentum.x = pₓ′).energy = e′
end

"""
    unBoostCrossingAngle_loop(in, angle)

    Apply the crossing angle correction to the input `ReconstructedParticle` `in` with the given `angle`.
"""
function unBoostCrossingAngle_loop(in, angle)
    result = StructArray(ReconstructedParticle[])
    ta = tan(angle)
    for p in in
        e = p.energy
        pₓ = p.momentum.x
        e′ = e * sqrt(1 + ta*ta) + pₓ * ta
        pₓ′ = pₓ * sqrt(1 + ta*ta) + e * ta
        push!(result, @set (@set p.momentum.x=pₓ′).energy = e′)
    end
    return result
end

function visibleEnergy(rps)
    return sum(rps.energy)
end

function visibleEnergy(rps, p_cutoff)
    return sum(p.energy for p in rps if pₜ(p) >= p_cutoff)
end

function missingEnergy(ecm, rps)
    p = -sum(rps.momentum)
    e =  sum(rps.energy)
    ReconstructedParticle(momentum=(p.x, p.y, p.z), energy=ecm-e)
end

function missingEnergy(ecm, rps, p_cutoff)
    p = -sum(r.momentum for r in rps if pₜ(r) >= p_cutoff)
    e =  sum(r.energy for r in rps if pₜ(r) >= p_cutoff)
    ReconstructedParticle(momentum=(p.x, p.y, p.z), energy=ecm-e)
end


deltaR(lv1, lv2) = sqrt((eta(lv1)-eta(lv2))^2 + (phi(lv1)-phi(lv2))^2)
p(lv) = sqrt(lv.x^2 + lv.y^2 + lv.z^2)
LorentzVectorHEP.LorentzVector(p::T) where T <: Union{ReconstructedParticle, MCParticle} = LorentzVector(p.energy, p.momentum.x, p.momentum.y, p.momentum.z)

function coneIsolation(dr_min, dr_max, in, rps)
    result = Float64[]
    lv_reco = [LorentzVector(r) for r in in]
    lv_charged = [LorentzVector(r) for r in rps if r.charge != 0]
    lv_neutral = [LorentzVector(r) for r in rps if r.charge == 0]
    for lv in lv_reco
        sumNeutral = 0.0
        sumCharged = 0.0
        for lvc in lv_charged
            dr_min < deltaR(lv, lvc) < dr_max && (sumCharged += p(lvc))
        end
        for lvn in lv_neutral
            dr_min < deltaR(lv, lvn) < dr_max && (sumNeutral += p(lvn))
        end
        sum = sumCharged + sumNeutral
        ratio = sum / p(lv)
        push!(result, ratio)
    end
    return result
end
