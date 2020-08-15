using MLJ
import RDatasets: dataset
using PrettyPrinting
import DataFrames: DataFrame, select, Not

boston = dataset("MASS", "Boston")
y, X = unpack(boston, ==(:MedV), colname -> true)
train, test = partition(eachindex(y), 0.5, shuffle = true, rng = 551)

@load RandomForestRegressor pkg=ScikitLearn
rf_mdl = RandomForestRegressor()
rf = machine(rf_mdl, X, y)
fit!(rf, rows=train)

ypred = predict(rf, rows=test)
round(rms(ypred, y[test]), sigdigits=3)
