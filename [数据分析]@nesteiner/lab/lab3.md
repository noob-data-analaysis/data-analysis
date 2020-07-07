```julia
using MLJ
@load LinearRegressor pkg=MLJLinearModels
```
```julia
LinearRegressor(
	fit_intercept = true,
    solver = nothing) @ 9…47
```
让我们加载波士顿数据集
```julia
import RDatasets: dataset
import DataFrames: describe, select, Not, rename!
boston = dataset("MASS", "Boston")
first(boston, 3)
```
让我们感受一下数据
```julia
describe(boston, :mean, :std, :eltype)
```
因此，不会丢失任何值，并且大多数变量都被编码为浮点数。在MLJ中，指定特征的解释很重要（应该将其视为连续特征，如Count，...？），另请参阅本教程中有关科学类型的部分。

在这里，我们将解释整数特征为连续的，就像我们将使用基本线性回归一样：
```julia
data = coerce(boston, autotype(boston, :discrete_to_continuous));
```
让我们还提取目标变量（MedV）：
```julia
y = data.MedV
X = select(data,Not(:MedV)
```
让我们声明一个简单的多元线性回归模型：
```julia
mdl = LinearRegressor()
```
```julia  
LinearRegressor(
    fit_intercept = true,
    solver = nothing) @ 5…14  
```

首先，我们做一个非常简单的单变量回归，为了使其适合数据，我们需要将其包装在机器中，在MLJ中，该机器是模型和数据的组成部分，并将模型应用于：
```julia
X_uni = select(X, :LStat) # only a single feature
mach_uni = machine(mdl, X_uni, y)
fit!(mach_uni)  
```
```julia
Machine{LinearRegressor} @ 4…79  
```
然后，您可以使用检索拟合的参数fitted_params：  

```julia
fp = fitted_params(mach_uni)
@show fp.coefs
@show fp.intercept
```
```julia
fp.coefs = [:LStat => -0.950049353757991]
fp.intercept = 34.553840879383095
```

您也可以将其可视化
```julia
using PyPlot

figure(figsize=(8,6))
plot(X.LStat, y, ls="none", marker="o")
Xnew = (LStat = collect(range(extrema(X.LStat)..., length=100)),)
plot(Xnew.LStat, predict(mach_uni, Xnew))
```

多元情况非常相似
```julia  
mach = machine(mdl, X, y)
fit!(mach)

fp = fitted_params(mach)
coefs = fp.coefs
intercept = fp.intercept
for (name, val) in coefs
    println("$(rpad(name, 8)):  $(round(val, sigdigits=3))")
end
println("Intercept: $(round(intercept, sigdigits=3))")  
```

```julia
Crim    :  -0.108
Zn      :  0.0464
Indus   :  0.0206
Chas    :  2.69
NOx     :  -17.8
Rm      :  3.81
Age     :  0.000692
Dis     :  -1.48
Rad     :  0.306
Tax     :  -0.0123
PTRatio :  -0.953
Black   :  0.00931
LStat   :  -0.525
Intercept: 36.5  
```
您也可以使用machine来预测值，例如，计算均方根误差：
```julia
ŷ = predict(mach, X)
round(rms(ŷ, y), sigdigits=4)
```
```julia
4.679
```
让我们看看残像是什么样子
```julia
figure(figsize=(8,6))
res = ŷ .- y
stem(res)
```
也许直方图在这里更合适
```julia
figure(figsize=(8,6))
hist(res, density=true)
```

