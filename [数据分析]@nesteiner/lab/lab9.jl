using MLJ
import RDatasets: dataset
using PrettyPrinting
using Random

Random.seed!(3203)
X = randn(20, 2)
y = vcat(-ones(10), ones(10))

using Plots
y₁ = y .== -1
y₂ = y .!= -1
plot(X[y₁, 1], X[y₁, 2], line=:scatter, marker=:o)
plot!(X[y₂, 1], X[y₂, 2], line=:scatter, marker=:x)
X = MLJ.table(X)
y = categorical(y)

@load SVC pkg=LIBSVM
svc_mdl = SVC()
svc = machine(svc_mdl, X, y)
fit!(svc)
ypred = predict(svc, X)
misclassification_rate(ypred, y)

rc = range(svc_mdl, :cost, lower = 0.1, upper = 5)
tm = TunedModel(model = svc_mdl,
                range = rc,
                tuning = Grid(resolution=10),
                resampling = CV(nfolds=3, rng=33),
                measure=misclassification_rate)
mtm = machine(tm, X, y)
fit!(mtm)
best_model = fitted_params(mtm).best_model
evaluate(best_model, X, y,
         resampling = CV(nfolds=3, rng=33),
         measure = [misclassification_rate, accuracy, precision])
