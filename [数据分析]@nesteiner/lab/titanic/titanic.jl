using MLJ
import DataFrames: DataFrame, describe, select
import CSV
using StableRNGs
rng = StableRNG(1234)


data = DataFrame(CSV.read("data/train.csv"));
test_data = DataFrame(CSV.read("data/test.csv"));
# labels, features = unpack(data, ==(:Survived), colname -> true; :Survived => Multiclass{2})

# MODULE 数据清洗
# Age <- mean
# Fare <- mean
# Embarked <- S, then -> OneHot
# Cabin <- drop??
# Sex: OneHot
# 特征选择
features_domain = [:Pclass, :Sex, :Age, :SibSp, :Parch, :Fare, :Embarked, :Survived]

train_pipe = @pipeline(FeatureSelector(features_domain),
                       df -> coerce(df, autotype(df, (:string_to_multiclass, :discrete_to_continuous))),
                       df -> coerce(df, :Survived => Multiclass),
                       FillImputer(features = [:Age, :Fare, :Embarked],
                                   continuous_fill = e -> skipmissing(e) |> mean),
                       OneHotEncoder(features = [:Sex, :Embarked]),
                       Standardizer(features = [:Age, :Fare]))

test_pipe = @pipeline(FeatureSelector(features_domain[features_domain .!= :Survived]),
                      df -> coerce(df, autotype(df, (:string_to_multiclass, :discrete_to_continuous))),
                      FillImputer(features = [:Age, :Fare, :Embarked],
                                  continuous_fill = e -> skipmissing(e) |> mean),
                      OneHotEncoder(features = [:Sex, :Embarked]),
                      Standardizer(features = [:Age, :Fare]))

# transform test dataset 
transform_test_mach = machine(test_pipe, test_data)
fit!(transform_test_mach)
test_features = transform(transform_test_mach, test_data)

# transform train dataset
transform_train_mach = machine(train_pipe, data)
fit!(transform_train_mach)
train_labels, train_features = unpack(transform(transform_train_mach, data),
                                      ==(:Survived),
                                      colname -> true)




# MODULE train with LogisticClassifier
# score 0.76794
@load LogisticClassifier pkg=MLJLinearModels
clf = LogisticClassifier()

# TODO Tuning Model
r_lambda = range(clf, :lambda, lower = 0.01, upper = 10.0, scale = :linear)
r_penalty = range(clf, :penalty, values = [:l1, :l2])
tuning = Grid(resolution = 20, rng = rng)

self_tuning_model = TunedModel(model = clf,
                               range = [r_lambda, r_penalty],
                               tuning = tuning,
                               resampling = CV(nfolds = 6, rng=rng),
                               measure = cross_entropy)
self_tuning_mach = machine(self_tuning_model, train_features, train_labels)
fit!(self_tuning_mach)
best_model = fitted_params(self_tuning_mach).best_model
best_mach = machine(best_model, train_features, train_labels)
evaluate!(best_mach,
          resampling = CV(nfolds = 6, rng = rng),
          measure = [cross_entropy, area_under_curve])

# MODULE predict
predict_labels = predict_mode(best_mach, test_features)
output_dataframe =  DataFrame(PassengerId = 892:1309, Survived = convert(Vector{Int}, predict_labels))
CSV.write("data/output_logistic.csv", output_dataframe)

# MODULE train with SVMLinearClassifier
# score 0.7655
@load SVMClassifier pkg=ScikitLearn
@load SVMLinearClassifier pkg=ScikitLearn
clf = SVMLinearClassifier(dual = false)

# tuning range
r_penalty = range(clf, :penalty, values = ["l1", "l2"])
r_tol = range(clf, :tol, lower = 0.00001, upper = 1.0, scale = :linear)
r_C = range(clf, :C, lower= 0.001, upper = 10.0, scale = :linear)
resampling = CV(nfolds = 6, rng = rng)
tuning = Grid(rng = rng)

self_tuning_model = TunedModel(model = clf,
                               resampling = resampling,
                               range = [r_penalty, r_tol, r_C],
                               tuning = tuning,
                               measure = [accuracy, precision])
self_tuning_mach = machine(self_tuning_model, train_features, train_labels)
fit!(self_tuning_mach)

best_model = fitted_params(self_tuning_mach).best_model
evaluate(best_model, train_features, train_labels,
         resampling = resampling,
         measure = [accuracy, precision])
# MODULE predict
best_mach = machine(best_model, train_features, train_labels)
fit!(best_mach)
predict_labels = predict(best_mach, test_features)
output_dataframe = DataFrame(PassengerId = 892:1309, Survived = convert(Vector{Int}, predict_labels))
CSV.write("data/output_svmlinearclassifier.csv", output_dataframe)

# MODULE train with SVMClassifier
@load SVMClassifier


