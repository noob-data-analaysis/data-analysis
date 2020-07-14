# 3、绘图菜谱
# written by heniancheng

using Plots
default(show=true)

# 3.1引入DataFrame数据类型
using StatsPlots
using DataFrames
df=DataFrame(a=1:10,b=10*rand(10),c=10*rand(10)) 
@df df plot(:a,[:b :c])

# 3.2类型菜谱
# using StatsPlots
# using Distributions
# plot(Normal(3,5),lw=3)
