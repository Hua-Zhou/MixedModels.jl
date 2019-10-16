"""
    LinearMixedModelBLB

Representation of bag of little bootstrap (BLB) for linear mixed-effects model 

## Fields

TODO 

## Properties

TODO
"""
struct LinearMixedModelBLB{T<:AbstractFloat, TI<:Integer} <: MixedModel{T}
    lmm::LinearMixedModel{T}
    subset::Vector{TI}
    blkwts::Vector{TI}
end

# constructor
function LinearMixedModelBLB(lmm::LinearMixedModel, subsetsize::Integer)
    # TODO: figure out # independent blocks in lmm
    blkwts = Vector{Int}(undef, subsetsize)
    subset = sort(rand(1:N , subsetsize))
    LinearMixedModelBLB(lmm, blkwts, subset)
end

function bootstrap!(lmmblb::LinearMixedModelBLB)
    # set blkwts randomly

end

funciton objective(lmmblb::LinearMixedModelBLB)

end



function fit!(lmmblb::LinearMixedModelBLB)
    
end
