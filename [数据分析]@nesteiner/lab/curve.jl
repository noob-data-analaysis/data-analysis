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
using StableRNGs
using Plots
rng = StableRNG(1234)

plot(curve.parameter_values,
     curve.measurements,
     xlab = curve.parameter_name,
     xscale = curve.parameter_scale,
     ylab = "CV estimate of RMS error")


# curve of ridgeregressor
@load RidgeRegressor pkg=MultivariateStats
model = RidgeRegressor()
r_lambda = range(model, :lambda, lower = 0.1, upper = 10.0, scale = :linear)
mach = machine(model, X, y)
# curves = learning_curve(mach,
#                         range = r_lambda,
#                         verbosity = 0,
#                         rng_name = :rng,
#                         rngs = rng)

curves = learning_curve(mach,
                        resampling = CV(nfolds = 6, rng = rng),
                        range = r_lambda,
                        measure = rms)
plot(curves.parameter_values,
     curves.measurements,
     xlab = curves.parameter_name,
     ylab = "Holdout estimate of RMS error")

atom.lambda = 200
r_n = range(ensemble, :n, lower = 1, upper = 50)
curves = learning_curve(mach,
                        range = r_n,
                        verbosity = 0,
                        rng_name = :rng,
                        rngs = rng)
plot(curves.parameter_values,
     curves.measurements,
     xlab = curves.parameter_name,
     ylab = "Holdout estimate of RMS error")

# MODULE learning_curve
# train_sizes, train_scores, test_scores = learning_curve(estimator, X, y, cv=cv, n_jobs=n_jobs, train_sizes=train_size)

X, y = @load_boston;

@load RidgeRegressor pkg=MultivariateStats
model = RidgeRegressor()
r_lambda = range(model, :lambda, lower = 0.1, upper = 10.0, scale = :linear)

train, test = partition(eachindex(y), 0.7, shuffle = true, rng = rng)
curve_train = learning_curve(model, X, y;
                             range = r_lambda,
                             measure = rms,
                             resampling = Holdout(fraction_train=0.7, rng = rng),
                             rows = train)
curve_test = learning_curve(model, X, y;
                            range = r_lambda,
                            measure = rms,
                            resampling = Holdout(fraction_train=0.7, rng = rng),
                            rows = test)

plot(curve_train.parameter_values,
     curve_train.measurements,
     label = "train_error",
     xlab = curve_train.parameter_name,
     xscale = curve_train.parameter_scale,
     ylab = "CV estimate of RMS error")
plot!(curve_test.parameter_values,
      curve_test.measurements,
      label = "test_error")



# STUB although something wrong, write it first
function plot_learning_curve(mach, y)
    training_size_iter = 5:10:length(y)
    errors = ones(length(training_size_iter), 2)
    rng = StableRNG(1234)

    row = 1                     # for iterate
    for training_size = training_size_iter
        train, cv = partition(1:training_size, 0.7, rng = rng)
        fit_only!(mach, rows = train)
        
        m_train = length(train)
        Jtrain = (1 / (2 * m_train)) * reduce(+, map(x -> x^2, predict(mach, rows = train) - y[train]))

        m_cv = length(cv)
        Jcv = (1 / (2 * m_cv)) * reduce(+, map(x -> x^2, predict(mach, rows = cv) - y[cv]))

        errors[row, :] = [Jtrain, Jcv]

        row += 1
    end

    plot(errors,
         label = ["Jtrain" "Jcv"],
         color = [:red :blue],
         xlab = "training size",
         ylab = "error")


end



@load RidgeRegressor pkg=MultivariateStats
model = RidgeRegressor()
X, y = @load_boston

# Tuning
rng = StableRNG(1234)
r_lambda = range(model, :lambda, lower = 0.1, upper = 10.0, scale = :linear)
tuning = Grid(resolution = 100, rng = rng)
resampling = CV(nfolds = 6, rng = rng)
self_tuning_model = TunedModel(model = model,
                               range = r_lambda,
                               tuning = tuning,
                               resampling = resampling,
                               measure = l1)
self_tuning_mach = machine(self_tuning_model, X, y)
fit!(self_tuning_mach, force = true)

best_model = fitted_params(self_tuning_mach).best_model
best_mach = machine(best_model, X, y)
plot_learning_curve(best_mach, y)

curve = learning_curve(best_mach,
                       range = r_lambda,
                       resampling = resampling,
                       measure = rms)
plot(curve.parameter_values,
     curve.measurements,
     xlab = curve.parameter_name,
     xscale = curve.parameter_scale,
     ylab = "CV estimate of RMS error")



