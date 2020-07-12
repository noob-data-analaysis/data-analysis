# 1、系列图
# written by heniancheng

using Plots
default(show=true)

# 1.1散点图
scatter(rand(10,2))

# 1.2条形图
bar(rand(10,2))

# 1.3柱状图
histogram(rand(10,2))

# 1.4线状图（默认）
line(rand(10,2))

# 1.5饼状图
pie(rand(10,2))
