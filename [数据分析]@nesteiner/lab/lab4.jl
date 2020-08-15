using MLJ
import RDatasets: dataset
import DataFrames: DataFrame, describe, select, Not
import StatsBase: countmap, cor, var
using PrettyPrinting
using Plots

smarket = dataset("ISLR", "Smarket")
@show size(smarket)
@show names(smarket)

describe(smarket, :mean, :std, :eltype)

y = coerce(smarket[!,:Direction], OrderedFactor)
X = select(smarket, Not(:Direction))

cm = X |> Matrix |> cor
round.(cm, sigdigits=1)

@load LogisticClassifier pkg=MLJLinearModels
X2 = select(X, Not([:Year, :Today]))
clf = machine(LogisticClassifier(), X2, y)
fit!(clf)
# PROBLEM what the hell is this
ŷ = predict(clf, X2)
ŷ[1:3]
cross_entropy(ŷ, y) |> mean

ŷ = predict_mode(clf, X2)


# TODO LDA
@load BayesianLDA pkg=MultivariateStats
train = 1:findlast(X.Year .< 2005)
test = last(train) + 1:length(y)

X3 = select(X, [:Lag1, :Lag2])

clf = machine(BayesianLDA(), X3, y)
fit!(clf, rows = train)
ŷ = predict_mode(clf, rows = test)
accuracy(ŷ, y[test])


# TODO ROC
caravan = dataset("ISLR", "Caravan")
y, X = unpack(caravan, ==(:Purchase), colname -> true)
mstd = fit!(machine(Standardizer(), X))
Xs = transform(mstd, X)

test = 1:1000
train = last(test) + 1:nrows(Xs)

# TODO test roc with KNN
@load KNNClassifier pkg=NearestNeighbors
clf = machine(KNNClassifier(K=3), Xs, y)
fit!(clf, rows=train)
ŷ = predict(clf, rows=test)
fprs, tprs, thresholds = roc(ŷ, y[test])


plot(fprs, tprs)
# TODO test roc with logistic
@load LogisticClassifier pkg=MLJLinearModels
clf = machine(LogisticClassifier(), Xs, y)
fit!(clf, rows=train)
ŷ = predict(clf, rows=test)
auc(ŷ, y[test])

fprs, tprs, thresholds = roc(ŷ, y[test])
plot(fprs, tprs)

# TODO test roc with decisiontree
@load DecisionTreeClassifier pkg=DecisionTree
clf = machine(DecisionTreeClassifier(), Xs, y)
fit!(clf, rows=train)
ŷ = predict(clf, rows=test)
fprs, tprs, thresholds = roc(ŷ, y[test])

plot(fprs, tprs)
