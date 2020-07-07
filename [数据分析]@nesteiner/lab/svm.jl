using MLJ
using DataFrames
import CSV

data = DataFrame(CSV.read("./data.csv"))

# clean data select!(data,
select!(data, Not(:id))
coerce!(data, :diagnosis => Multiclass)
data[!,:diagnosis] = replace(data[!,:diagnosis], "M" => 1, "B" => 0)

# select feature features_remain = [:radius_mean, :texture_mean,
features_remain = [:smoothness_mean, :compactness_mean, :symmetry_mean,
                   :fractal_dimension_mean]

train, test = partition(eachindex(data[!,:diagnosis]), 0.7, rng = 444)
train_features = select(data[train, :], features_remain)
train_labels = data[train, :diagnosis]


test_features = select(data[test, :], features_remain)
test_labels = data[test, :diagnosis]

# model
@load SVMClassifier pkg=ScikitLearn
model = SVMClassifier()
mach = machine(model, train_features, train_labels)
fit!(mach)

MLJScikitLearnInterface
