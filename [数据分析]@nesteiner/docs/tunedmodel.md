[TOC]
## 1. 什么是`TunedModel`
为了得到更好的模型，我们需要调试模型的参数
还好MLJ为我们提供了`TunedModel`，我们要做的就是把原来的模型包装起来，进行调试
```julia
self_tuning_model = TunedModel(model = model,
                               resampling = resampling,
                               measure = measure,
							   rannge = range,
                               tuning = tuning,
							   weights = weights)
self_tuning_mach = machine(self_tuning_model, train_features, train_labels)
```
## 2. 怎么调优模型 
最重要的是参数范围`range`，参数范围的搜索策略`tuning`和判断最优结果的指标`measure`
#### 2.1 `range`
`range`需要指定`model`,`model`的参数`:param`，范围和取值(scale)
不过scale我不知道怎么回事，不懂，好像是取值规定，比如`:linear`是均匀，其他的比如`:log`我就不知道了

[数值]单个参数
```julia
r = range(model, :param, lower, upper, scale) 
range = r,
```
[数值]多个参数
```julia
r1 = range(model, :param1, lower, upper, scale) 
r2 = range(model, :param2, lower, upper, scale) 
range = [r1, r2]
```
[特殊]
```julia
r1 = range(model, :param, values = [v1, v2, ...])
```
补充
如果没有指定`scale`的话
>   If scale is unspecified, it is set to :linear, :log, :logminus, or :linear,
	according to whether the interval (lower, upper) is bounded, right-unbounded,
	left-unbounded, or doubly unbounded, respectively. Note upper=Inf and
	lower=-Inf are allowed.

ps: 其实`range(model, :param, lower, upper, scale = :linear)` 跟 `range(model, :param, values = lower:upper)`是一样的

#### 2.2 `tuning`
`tuning`有两种策略，网格搜索和随机搜索
>   Grid(goal=nothing, resolution=10, rng=Random.GLOBAL_RNG, shuffle=true)

	Instantiate a Cartesian grid-based hyperparameter tuning strategy with a
	specified number of grid points as goal, or using a specified default
	resolution in each numeric dimension.
具体可以看[这篇文章](https://www.cnblogs.com/Vancuicide/p/10530583.html)
但是这些参数有点特别，我不懂`goal`的意思，google了半天也没找到，本来想用`sklearn`类比一下的，可是参数有点特别，希望有人能为我解答
ps: 从slack上作者给我的解释 **resolution is number of points in each dim**，还好我这个菜鸟问了这么多没把我弄死
>   RandomSearch(bounded=Distributions.Uniform,
	             positive_unbounded=Distributions.Gamma,
                 other=Distributions.Normal,
				 rng=Random.GLOBAL_RNG)

	Instantiate a random search tuning strategy, for searching over Cartesian
	hyperparameter domains, with customizable priors in each dimension.


#### 2.3 `measure`
`measure`是为了衡量模型调整参数后的好坏而引入的指标，我们只讨论分类和回归的情况
[文档在这里](https://alan-turing-institute.github.io/MLJ.jl/stable/performance_measures/)
ps: 也可以指定多个`measure`
#### `weights`
也可以指定权重，用数组向量表示

#### 2.4 `resampling`
内置的重采样策略有三种，
`Holdout`: 将数据集分为`train`和`test`两部分，比例由`fraction_train`指定
`CV`: K折交叉验证
`StratifiedCV`: K折分层交叉验证
三种重采样方法都可以指定`shuffle = true`来指定，同时可以设定可重复使用的随机数种子
具体用法[看这里](https://alan-turing-institute.github.io/MLJ.jl/stable/evaluating_model_performance/)
```julia
using StableRNGs
rng = StableRNG(1234)
```
## 3. 怎么得到最优模型
```julia
fit!(self_tuning_mach)
best_model = fitted_params(sefl_tuning_mach).best_model
```
## 4. 接下来的工作
如果我们对这个模型有疑问怎么办？
我们可以对这个最优模型进行评估，或是通过`learning_curve`来观察训练过程
当然，`evaluate`和`learning_curve`会单独写文档，因为内容有点多

## 5. 贴个代码试试
#### 5.1 先试试单个参数调整
```julia
using MLJ
X = MLJ.table(rand(100,10))
y = 2X.x1 - X.x2 + 0.05 * rand(100)
tree_model = @load DecisionTreeRegressor
# 调整单个参数
r = range(tree_model, :min_purity_increase, lower = 0.01, upper = 1.0, scale = :linear)

self_tuning_tree_model = TunedModel(model = tree_model,
                                    resampling = CV(nfolds = 3),
                                    tuning = Grid(resolution = 10),
                                    range = r,
                                    measure = [rms, l1]

self_tuning_tree = machine(self_tuning_tree_model, X, y)
fit!(self_tuning_tree)

best_model = fitted_params(self_tuning_tree).best_model
```
这是`tree_model`
```julia
julia> tree_model
DecisionTreeRegressor(
    max_depth = -1,
    min_samples_leaf = 5,
    min_samples_split = 2,
    min_purity_increase = 0.0,
    n_subfeatures = 0,
    post_prune = false,
    merge_purity_threshold = 1.0) @371
```
这是`best_model`
```julia
julia> best_model = fitted_params(self_tuning_tree).best_model
DecisionTreeRegressor(
    max_depth = -1,
    min_samples_leaf = 5,
    min_samples_split = 2,
    min_purity_increase = 0.01,
    n_subfeatures = 0,
    post_prune = false,
    merge_purity_threshold = 1.0) @408
```
好吧，好像没什么变化

#### 5.2 再试试多个参数调整，顺便强化一下`tree_model`，进化成`forest`
没办法，我没系统学过决策树，不知道里面的参数含义
```julia
forest_model = EnsembleModel(atom = tree_model)
r1 = range(forest_model, :(atom.n_subfeatures), lower = 1, upper = 9)
r2 = range(forest_model, :bagging_fraction, lower = 0.4, upper = 1.0)

self_tuning_forest_model = TunedModel(model = forest_model,
                                      tuning = Grid(resolution = 10),
                                      resampling = CV(nfolds = 6),
                                      range = [r1, r2],
                                      measure = rms)

```
原来的`forest_model`
```julia
julia> forest_model
DeterministicEnsembleModel(
    atom = DecisionTreeRegressor(
            max_depth = -1,
            min_samples_leaf = 5,
            min_samples_split = 2,
            min_purity_increase = 0.0,
            n_subfeatures = 0,
            post_prune = false,
            merge_purity_threshold = 1.0),
    atomic_weights = Float64[],
    bagging_fraction = 0.8,
    rng = Random._GLOBAL_RNG(),
    n = 100,
    acceleration = CPU1{Nothing}(nothing),
    out_of_bag_measure = Any[]) @723
```
最优模型
```julia
julia> best_model = fitted_params(self_tuning_forest).best_model
DeterministicEnsembleModel(
    atom = DecisionTreeRegressor(
            max_depth = -1,
            min_samples_leaf = 5,
            min_samples_split = 2,
            min_purity_increase = 0.0,
            n_subfeatures = 9,
            post_prune = false,
            merge_purity_threshold = 1.0),
    atomic_weights = Float64[],
    bagging_fraction = 0.8,
    rng = Random._GLOBAL_RNG(),
    n = 100,
    acceleration = CPU1{Nothing}(nothing),
    out_of_bag_measure = Any[]) @027
```
娘的，好像还是没什么变化

## 6. 疑问
1. 在指定`range`时，`scale`的作用
2. 调整策略`tuning`中`Grid`的参数，`Grid`对训练模型个数的影响
