using MLJ
using PrettyPrinting

X = table(rand(100, 10))
y = 2 .* X.x1 .- X.x2 .+ 0.05 .* rand(100)
tree_model = @load DecisionTreeRegressor

r = range(tree_model, :min_purity_increase, lower = 0.001, upper = 1.0, scale = :log)
self_tuning_tree_model = TunedModel(model = tree_model,
                                    resampling = CV(nfolds = 3),
                                    range = r,
                                    measure = rms)


selector_model = FeatureSelector()
r2 = range(selector_model, :features, values = [[:x1,], [:x1, :x2]])

self_tuning_tree = machine(self_tuning_tree_model, X, y)
fit!(self_tuning_tree, verbosity = 1)
fitted_params(self_tuning_tree).best_model

Xnew = table(rand(3,10))
predict(self_tuning_tree, Xnew)

# TODO 调整多个嵌套超参数
tree_model = DecisionTreeRegressor()
forest_model = EnsembleModel(atom = tree_model)

r1 = range(forest_model, :(atom.n_subfeatures), lower = 1,upper = 9)
r2 = range(forest_model, :bagging_fraction, lower = 0.4,upper = 1.0)
self_tuning_forest_model = TunedModel(model = forest_model,
                                      tuning = Grid(goal = 30),
                                      resampling = CV(nfolds = 6),
                                      range = [r1, r2],
                                      measure = rms)
self_tuning_forest = machine(self_tuning_forest_model, X, y)
fit!(self_tuning_forest, verbosity = 0)

using Plots
plot(self_tuning_forest)

tuning = Grid(resolution = 100, shuffle = true, rng = 1234)
self_tuning_forest_model = TunedModel(model = forest_model,
                                      tuning = tuning,
                                      resampling = CV(nfolds = 6),
                                      range = [(r1, 4), r2],
                                      measure = rms,
                                      n = 25)
fit!(machine(self_tuning_forest_model, X, y), verbosity = 0)

# TODO 使用随机搜索进行调整
self_tuning_forest_model = TunedModel(model = forest_model,
                                      tuning = RandomSearch(),
                                      resampling = CV(nfolds = 6),
                                      range = [r1, r2],
                                      measure = rms,
                                      n = 25)
self_tuning_forest = machine(self_tuning_forest_model, X, y)
fit!(self_tuning_forest, verbosity = 0)

plot(self_tuning_forest)
