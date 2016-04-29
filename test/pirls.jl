using RCall, MixedModels, Base.Test, DataFramesu

cbpp = rcopy("lme4::cbpp")
contra = rcopy(rcall(:readRDS, "/home/bates/IRI/contra.rds"));

m1 = fit!(glmm(use01 ~ 1 + age + age2 + urban + livch + (1 | urbdist), contra, Bernoulli()), true);
LaplaceDeviance(m1)
@time fit!(glmm(use01 ~ 1 + age + age2 + urban + livch + (1 | urbdist), contra, Bernoulli()));
m1[:βθ] = [-1.05927786640742, 0.00327178741060179, -0.00447366485006533, 0.770684236080492, 0.834652084384278,
    0.91377101590113, 0.927294561171754, 0.572997715814166]
copy!(m1.u[1], [-1.6499558843067, -0.0462909118402155, -0.423869610726728, 0.214339118939034, -0.651076958009171,
     -0.322410927013078, 0.127116105399692, -0.503100515985293, -0.781094223537074, -1.59843624701506,
     -0.0875814386739525, 0.380180403261145, 0.116142626388445, 0.111683153682811, 1.18061658491803,
     -0.339708169743181, -0.24264769012453, -0.152015579159662, 0.543753037803242, 0.83989061371515,
     -0.822149028965342, -0.364603818814437, -1.03406437586499, 0.464790552079515, 0.00630908943334267,
     -0.95038621793917, -0.462291394471262, -0.470700874454309, 0.543560611914633, 0.742080137843383,
     -0.892379139844369, -0.547870282918762, 1.93544072190157, 0.534797171745585, -0.146013795859715,
     0.737473263405055, -0.669267651461427, 1.03251319828118, 0.35186625260459, 0.884660576464641, 1.19820637224804,
     1.13708489522704, -0.646100351448136, -0.512413752029011, 1.03040577610054, 0.408986087851385, 0.946114906939915,
     -0.454592419751671, 0.115446816398449, -0.00906832187444102, 1.10736630547448, 1.17815977075278,
     -0.83808990485612, 1.19073528010451, -0.804991026141868, -0.741158782380667, -0.846926970360788, -1.0301946402959,
     0.506948375659576, 1.10892158007818, 0.0557002209277003, 0.427816721779668, 0.522389391205491, 0.180802921511802,
     -0.345420350635311, -0.217332349916283, 1.23097978945458, -0.341053161708066, 0.511758675063832,
     0.107197711314256, 0.52390842938882, -0.827470920791179, -0.228192262095966, -0.196561074402358,
     -0.608421573526171, 0.200657159547459, 0.911358626328854, 0.10026801629732, 0.23331956091397, -0.492829294711615,
     0.221557595937087, -0.200022745436875, 0.280853712636902, -0.0696490053057741, -0.0514611989350849,
     -0.752757165462876, -0.707161037153504, 0.275364500452707, 0.555605376292061, 0.402697073683478,
     0.0711826258096426, 0.289186643191771, 0.857517160090248, 0.271683540111046, -0.903048817024538,
     -0.353960611141151, -0.918843218776565, 0.681636138836564, -0.550806732424881, -0.547263869457544,
     -0.531191171435582, -0.68269152390653])
copy!(m1.u₀[1], m1.u[1])
@test isapprox(MixedModels.LaplaceDeviance!(m1), 2361.54575; atol = 0.001)
@test isapprox(logdet(m1), 75.712935; atol = 0.001)
@test isapprox(mapreduce(sumabs2, +, m1.u), 48.4749121; atol = 0.0001)

cbpp[:prop] = cbpp[:incidence] ./ cbpp[:size]
m2 = glmm(prop ~ 1 + period + (1 | herd), cbpp, Binomial(), cbpp[:size], GLM.LogitLink());
MixedModels.pirls!(m2)
μ = 1 - eps()
1 - μ
exp(log1p(-μ))
# converged estimates from glmer

m2[:βθ] = [-1.39834286447115, -0.991924974975739, -1.12821621594334, -1.57974541364919, 0.642069927729179]
copy!(m2.u₀[1], [0.918325887925426, -0.465826716427159, 0.632120882325963, 0.0607769944357498,
    -0.296362248729738, -0.623720151231402, 1.38452598866026, 0.933139186773548,
    -0.370327517496405, -0.842757110363279, -0.13231840518007, -0.101239681557089,
    -1.07473252380136, 1.5112868046504, -0.826394410094271])
copy!(m2.u[1], m2.u₀[1])
@test isapprox(MixedModels.LaplaceDeviance!(m2), 184.0525724; atol = 0.001)
mapreduce(sumabs2, +, m2.u)
@test isapprox(mapreduce(sumabs2, +, m2.u), 9.72521112; atol = 0.0001)
@test isapprox(logdet(m2), 16.89637; atol = 0.0001)

using DataFrames
cbpp[:herd] = pool([parse(Int8, x) for x in cbpp[:herd]])
cbpp[:incidence] = convert(Vector{Int8}, cbpp[:incidence])
cbpp[:size] = convert(Vector{Int8}, cbpp[:size])
cbpp[:period] = pool([parse(Int8, x) for x in cbpp[:period]])
cbpp[:prop] = cbpp[:incidence] ./ cbpp[:size]
names(cbpp)
f = prop ~ 1 + period + (1 | herd)
m2 = glmm(f, cbpp, Binomial(), cbpp[:size], GLM.LogitLink());
m2.y
fit!(m2, true);

VerbAgg = rcopy("lme4::VerbAgg")
VerbAgg[:r201] = [Int8(x == "N" ? 0 : 1) for x in VerbAgg[:r2]]
m3 = glmm(r201 ~ 1 + Anger + Gender + btype + situ + (1 | id) + (1 | item), VerbAgg, Bernoulli());
f = r201 ~ 1 + Anger + Gender + btype + situ + (1 | id)