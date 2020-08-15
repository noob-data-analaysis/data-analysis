using MLJ
import RDatasets: dataset
using PrettyPrinting
import Distributions
const D = Distributions

@load LinearRegressor pkg=MLJLinearModels
@load RidgeRegressor  pkg=MLJLinearModels
@load LassoRegressor  pkg=MLJLinearModels

hitters = dataset("ISLR", "Hitters");
names(hitters) |> pprint

y, X = unpack(hitters, ==(:Salary), colname -> true)
# 忽略缺失值
no_miss = map(x -> !x, ismissing.(y))
y = collect(skipmissing(y))
X = X[no_miss, :]
train, test = partition(eachindex(y), 0.5, shuffle = true, rng = 444)

using Plots

histogram(y, bins=50, density=true,
          xlabel = "Salary",
          ylabel = "Density",
