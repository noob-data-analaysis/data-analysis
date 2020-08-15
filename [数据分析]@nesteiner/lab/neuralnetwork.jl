using MLJ
import RDatasets: dataset
iris = dataset("datasets", "iris")
y, X = unpack(iris, ==(:Species), colname -> true, rng = 1234)

@load NeuralNetworkClassifier
clf = NeuralNetworkClassifier()

import Random.seed!;
seed!(123)
mach = machine(clf, X, y)
fit!(mach)

training_loss = cross_entropy(predict(mach, X), y) |> mean


clf.optimiser.eta *= 2
clf.epochs = clf.epochs + 5
fit!(mach, verbosity=2)
fitted_params(mach).chain

r = range(clf, :epochs, lower=1, upper=200, scale=:log10)
curve = learning_curve(clf, X, y,
                       range = r,
                       resampling = Holdout(fraction_train=0.7),
                       measure = cross_entropy)
using Plots
plot(curve.parameter_values,
     curve.measurements,
     xlab = curve.parameter_name,
     xscale = curve.parameter_scale,
     ylab = "Cross Entropy")
