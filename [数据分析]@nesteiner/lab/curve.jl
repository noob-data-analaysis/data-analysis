using MLJ

X, y = @load_boston;
atom = @load RidgeRegressor pkg=MultivariateStats
ensemble = EnsembleModel(atom = atom, n = 100)
mach = machine(ensemble, X, y)

r_lambda = range(ensemble, :(atom.lambda), lower = 10, upper = 500, scale = :log10)
curve = learning_curve(mach,
                       range = r_lambda,
                       resampling = CV(nfolds = 3),
                       measure = mav)

using Plots
plot(curve.parameter_values,
     curve.measurements,
     xlab = curve.parameter_name,
     xscale = curve.parameter_scale,
     ylab = "CV estimate of RMS error")

atom.lambda = 200
r_n = range(ensemble, :n, lower = 1, upper = 50)
curves = learning_curve(mach,
                        range = r_n,
                        verbosity = 0,
                        rng_name = :rng,
                        rngs = 4)
plot(curves.parameter_values,
     curves.measurements,
     xlab = curves.parameter_name,
     ylab = "Holdout estimate of RMS error")
