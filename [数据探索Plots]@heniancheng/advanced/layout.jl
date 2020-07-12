# 2、布局
# written by heniancheng

using Plots
default(show=true)

# plot(rand(10,4),layout=(2,2))

# plot(rand(100, 4), layout = grid(4, 1, heights=[0.1 ,0.4, 0.4, 0.1]))


lo = @layout [
    a{0.3w} [grid(3,3)
            b{0.2h}]
]
plot(rand(10, 11),
    layout = lo, legend = false, seriestype = [:bar :scatter :path],
    title = ["($i)" for j in 1:1, i in 1:11], titleloc = :right, titlefont = font(8)
)
