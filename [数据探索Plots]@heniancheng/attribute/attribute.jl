# Plots Attribute
# written by heniancheng

# 可先通过函数快速了解有哪些属性
# plotattr(:Series)/plotattr(:Axis)
# plotattr(:Plots)/plotattr(:Subplot)
# 再通过plotattr("size")了解具体属性使用

using Plots
x=1:10
y=rand(10,2)
p=plot(x,y,title="Two Lines",label=["Line One" "Line Two"],w=3)

xlabel!(p,"X")       #设置X轴标签
ylabel!(p,"Y")       #设置Y轴标签
xlims!(0,30)         #设置X轴范围
ylims!(0,2)          #设置Y轴范围
xticks!(0:2:20)      #设置X轴刻度
yticks!(0:0.2:1)     #设置Y轴刻度
