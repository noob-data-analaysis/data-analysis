using MLJ
X = (a = rand(12), b = rand(12), c = rand(12))
y = X.a .+ 2 .* X.b + 0.05 .* rand(12)

model = @load RidgeRegressor pkg=MultivariateStats
cv = CV(nfolds = 3)

evaluate(model, X, y, resampling = cv, measure = l2, verbosity = 0)
evaluate(model, X, y, resampling = cv, measure = [l1, rms, rmslp1], verbosity = 0)

using LossFunctions

X = (x1 = rand(5), x2 = rand(5))
y = categorical(["y", "y", "y", "n", "y"])
w = [1, 2, 1, 2, 3]

mach = machine(ConstantClassifier(), X, y)
holdout = Holdout(fraction_train = 0.6)

# predict is needless
evaluate!(mach,
          measure = [ZeroOneLoss(), L1HingeLoss(), L2HingeLoss(), SigmoidLoss()],
          resampling = holdout,
          weights = w)
