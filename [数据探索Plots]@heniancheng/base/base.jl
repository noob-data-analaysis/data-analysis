# Plots Base
# written by heniancheng

using Plots
default(show=true)  #方法一：用于默认显示GUI
# gr(show=true)

# 1、Line Plots
x = 1:20
y=rand(20)
p=plot(x,y)
z=rand(20,2)
plot!(p,x,z)

#display(p)         #方法二：用于手动显示GUI
#gui()              #方法一：用于手动显示GUI

#savefig(p,"fig1.pdf")    #保存图片
