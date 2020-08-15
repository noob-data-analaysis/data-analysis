using MLJ
import DataFrames: DataFrame, describe
import RDatasets: dataset
using StableRNGs
boston = dataset("MASS", "Boston");
labels, features = unpack(boston, ==(:MedV), !=(:MedV); :Chas => Continuous, :Rad => Continuous, :Tax => Continuous)
describe(features, :min, :mean, :max, :std)
models(matching(features, labels))

@load RidgeRegressor pkg=MLJLinearModels
info("RidgeRegressor", pkg="MLJLinearModels")
@doc RidgeRegressor
regressor = RidgeRegressor()

rng = StableRNG(1234)
train, test = partition(eachindex(labels), 1 - 173/506, rng = rng)
r = range(regressor, :lambda, lower = 0.01, upper = 10.0, scale = :linear)
self_tuning_model = TunedModel(model = regressor,
                               range = r,
                               tuning = Grid(resolution = 30, rng = rng),
                               resampling = CV(nfolds = 6, rng = rng),
                               measure = l2)
self_tuning_mach = machine(self_tuning_model, features, labels)
fit!(self_tuning_mach, rows = train)
best_model = fitted_params(self_tuning_mach).best_model
evaluate(best_model,
         features[train, :],
         labels[train],
         resampling = CV(nfolds=6, rng=rng),
         measure = [l1, l2, rms])


# TODO try learning_curves
r_lambda = range(self_tuning_model, :(model.lambda), lower = 0.01, upper = 10.0, scale = :linear)
curve = learning_curve(self_tuning_mach;
                       range = r_lambda,
                       resampling = CV(nfolds=6, rng=rng),
                       measure = l2)
using Plots
plot(curve.parameter_values,
     curve.measurements)
