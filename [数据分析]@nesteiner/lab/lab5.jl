using MLJ
import RDatasets: dataset
import DataFrames: DataFrame
auto = dataset("ISLR", "Auto")
y, X = unpack(auto, ==(:MPG), colname -> true);
train, test = partition(eachindex(y), 0.5, shuffle = true, rng = 444)

@load LinearRegressor pkg=MLJLinearModels

using Plots
scatter(X.Horsepower, y,
        xticks = 50:50:250,
        yticks = 10:10:50)

lm = LinearRegressor()
mlm = machine(lm, select(X, :Horsepower), y)
fit!(mlm, rows=train)
rms(predict(mlm, rows=test), y[test])^2

xx = (Horsepower = collect(range(50, 225, length=100)), )
yy = predict(mlm, xx)
scatter(X.Horsepower, y, linemarker="o")
plot!(xx.Horsepower, yy, lineweight=3)

# TODO 三个多项式模型
hp = X.Horsepower
Xhp = DataFrame(hp1=hp, hp2=hp.^2, hp3=hp.^3)
LinMod = @pipeline(FeatureSelector(features=[:hp1]),
                   LinearRegressor())
lr1 = machine(LinMod, Xhp, y)
fit!(lr1, rows=train)

LinMod.feature_selector.features = [:hp1, :hp2]
lr2 = machine(LinMod, Xhp, y)
fit!(lr2, rows=train)

LinMod.feature_selector.features = [:hp1, :hp2, :hp3]
lr3 = machine(LinMod, Xhp, y)
fit!(lr3, rows=train)

# TODO 检测性能
get_mse(lr) = rms(predict(lr, rows=test), y[test]) ^ 2
@show get_mse(lr1)
@show get_mse(lr2)
@show get_mse(lr3)

# TODO visual
hpn = xx.Horsepower
Xnew = DataFrame(hp1=hpn, hp2=hpn.^2, hp3=hpn.^3)

yy1 = predict(lr1, Xnew)
yy2 = predict(lr2, Xnew)
yy3 = predict(lr3, Xnew)

scatter(X.Horsepower, y)
plot!(xx.Horsepower, yy1, lw=5, label = "Order 1")
plot!(xx.Horsepower, yy2, lw=5, label = "Order 2")
plot!(xx.Horsepower, yy3, lw=5, label = "Order 3")

# TODO K折交叉验证 最优模型
Xhp = DataFrame(map(i -> hp.^i, 1:10))
cases = [[Symbol("x$j") for j in 1:i] for i in 1:10]
r = range(LinMod, :(feature_selector.features), values = cases)

tm = TunedModel(model=LinMod, range = r, resampling = CV(nfolds = 10), measure = rms)
mtm = machine(tm, Xhp, y)
fit!(mtm)
rep = report(mtm)
res = rep.plotting

best_model = fitted_params(mtm).best_model
Xnew = DataFrame(map(i -> hpn.^i, 1:10))
yy5 = predict(mtm, Xnew)
scatter(X.Horsepower, y)
plot!(xx.Horsepower, yy5, lw=4)
