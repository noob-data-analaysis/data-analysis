# PROBLEM fitted_params
# PROBLEM coerce, autotype, :discrete_to_continuous

using MLJ
@load LinearRegressor pkg=MLJLinearModels
import RDatasets: dataset
import DataFrames: describe, select, Not, rename!

boston = dataset("MASS", "Boston")
data = coerce(boston, autotype(boston, :discrete_to_continuous))
mdl = LinearRegressor()
# TODO split data 70% train, 30% test

# TODO fit train
train_machine = machine(mdl,train_data,train_label)
fit!(train_machine,rows = train_rows)
# TODO predict test
ŷ = predict(train_machine,rows = test_rows)
# TODO show accuracy
round(rms(ŷ, test_label), sigdigits=4)
