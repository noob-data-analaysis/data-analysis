# 4、数据源
# written by heniancheng

using Plots
default(show=true)

# 4.1 向量与矩阵
xs = range(0, 2π, length = 10)
data = [sin.(xs) cos.(xs) 2sin.(xs) 2cos.(xs)]
markershapes = [:circle :star5]
markercolors = [:green :orange :black :purple]
plot(xs,data,shape = markershapes,color = markercolors,markersize = 10)

# 4.2 DataFrames支持
# using StatsPlots
# using DataFrames
# df=DataFrame(a=1:10,b=10*rand(10),c=10*rand(10)) 
# @df df plot(:a,[:b :c])

# 4.3 函数支持
# tmin = 0
# tmax = 4π
# tvec = range(tmin, tmax, length = 100)
# plot(sin.(tvec), cos.(tvec))
# plot(sin,cos,tvec)
# plot(sin,cos,tmin,tmax)
