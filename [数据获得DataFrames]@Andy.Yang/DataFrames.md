# DataFrames.md
> - 本文档的目标是翻译并总结 DataFrames.jl文件
> - version: DataFrames v0.21.4
> - Author: Andy.Yang 
> - E-mail: yjd2008@hotmail.com

## 一、简介
DataFrames用来处理表格式数据（类似于Python中的Pandas），即每一列数据有相同的属性，不同列可以有不同的属性。

注：Excel，数据库(以下用SQL代替)也可以用来处理这样的数据。个人认为关系数据库中的每个表非常类似于DataFrames需要处理的数据排布。那么什么时候应该使用Excel，SQL？Excel的优势是明显，但是如果将提取出来的数据用作其它地方不方便，而且只能固定xls格式；SQL非常适用于大数据量的情况下，效率会比DataFrames高出很多，但是其体积较大。相比之下，DataFrames就比较适用于非固定格式、中小批量数据的分析处理、转化了。

## 二、安装
- 方法一： 
``` 
julia> using Pkg 
julia> Pkg.add("DataFrames")
```
- 方法二：
```
julia> ;
(@v1.5) pkg> add DataFrames
```

导入方法：
```
using DataFrames
```

以下均默认已正常安装，并且程序在REPL中测试，每行开头均已导入包

## 三、构造 DataFrame 类型
DataFrame 类型是由若干个向量构成的数据表，每一个向量对应于一列或变量。创建 DataFrame 类型最简单的方法是传入若干个关键字-向量对，如下所示：
```
julia> df = DataFrame(A = 1:4, B = ["M", "F", "F", "M"])
4×2 DataFrame
│ Row │ A     │ B      │
│     │ Int64 │ String │
├─────┼───────┼────────┤
│ 1   │ 1     │ M      │
│ 2   │ 2     │ F      │
│ 3   │ 3     │ F      │
│ 4   │ 4     │ M      │

# 构造空类型
julia》 df = DataFrame()

# 从具名元组(NamedTuples)构造
julia> v = [(a=1,b=2), (a=3,b=4)]
2-element Array{NamedTuple{(:a, :b),Tuple{Int64,Int64}},1}:
 (a = 1, b = 2)
 (a = 3, b = 4)

julia> df = DataFrame(v)
2×2 DataFrame
│ Row │ a     │ b     │
│     │ Int64 │ Int64 │
├─────┼───────┼───────┤
│ 1   │ 1     │ 2     │
│ 2   │ 3     │ 4     │
```
注：由上可看出，列名是一个变量名，每列的数据类型必须是一致的，首列代表着行号。

## 四、基本操作
### 4.1 列数据获取
注：列数据的索引方法随着版本的更新不断变化，《Julia数据科学应用》中的许多API已经无法弃用。

1. df.colName
2. df."colName"
3. df[ : , :colName ]
4. df[ : , "colName" ]
5. df[ ! , :colName ]
6. df[ ! , "colName" ]

```
julia> df.A
julia> df."A"
julia> df[ : , :A ]
julia> df[ : , "A" ]
julia> df[ ! , :A ]
julia> df[ ! , "A" ]
```
- 方法1,2,5,6并不copy数据，因此速度相对3,4较快，但是更改数据会影响最原始的数据
- 上述列名也可以直接用列的位置代替

### 4.2 增加列
```
julia> df.C=2:5
julia> df
4×3 DataFrame
│ Row │ A     │ B      │ C     │
│     │ Int64 │ String │ Int64 │
├─────┼───────┼────────┼───────┤
│ 1   │ 1     │ M      │ 2     │
│ 2   │ 2     │ F      │ 3     │
│ 3   │ 3     │ F      │ 4     │
│ 4   │ 4     │ M      │ 5     │
```

### 4.3 在行末尾增加一行数据
注：这种方法性能较差，不太适用于大量的行数据插入
```
# 在行末尾增加一行数据
julia> push!(df,(1,"N",6))
5×3 DataFrame
│ Row │ A     │ B      │ C     │
│     │ Int64 │ String │ Int64 │
├─────┼───────┼────────┼───────┤
│ 1   │ 1     │ M      │ 2     │
│ 2   │ 2     │ F      │ 3     │
│ 3   │ 3     │ F      │ 4     │
│ 4   │ 4     │ M      │ 5     │
│ 5   │ 1     │ N      │ 6     │

# 使用字典增加一行数据
julia> push!(df,Dict(:A=>5, :B=>"G", :C=>7))
6×3 DataFrame
│ Row │ A     │ B      │ C     │
│     │ Int64 │ String │ Int64 │
├─────┼───────┼────────┼───────┤
│ 1   │ 1     │ M      │ 2     │
│ 2   │ 2     │ F      │ 3     │
│ 3   │ 3     │ F      │ 4     │
│ 4   │ 4     │ M      │ 5     │
│ 5   │ 1     │ N      │ 6     │
│ 6   │ 5     │ G      │ 7     │
```

### 4.4 打印所有列名
```
julia> names(df)
2-element Array{String,1}:
 "A"
 "B"

julia> propertynames(df)
2-element Array{Symbol,1}:
 :A
 :B
```
注: :colName 类型是 Symbol，"colName" 类型是 String。一般使用 Symbol比String更快。

### 4.5 获得表的尺寸
```
# 返回表的行数
julia> size(df,1)
4
# 返回表的列数
julia> size(df,2)
3
# 返回表的尺寸
julia> size(df)
(4, 3)
```

### 4.6 外部数据的导入与导出
```
# 将 DataFrame 存储为 CSV，要先 add CSV
julia> using CSV
julia> CSV.write("dataframe.csv", df)

# 将 DataFrame 存储为关系数据库中的表，要先 add SQLite
# 注意：首先要建立关系数据库
julia> SQLite.load!(df, db, "dataframe_table")
```

### 4.7 打印 DataFrame 中的数据
- 默认 df 根据屏幕大小打印若干行数据（并非所有）。如果需要打印所有数据，手动设置：
```
# 打印所有行
julia> show(df, allrows=true)

# 打印所有列
julia> show(df, allcols=true)
```

- 打印最开始或最后的若干行数据
```
# 打印起始的3行数据
julia> first(df, 3)

# 打印末尾的2行数据
julia> last(df, 2)
```

### 4.8 获取 DataFrame 数据的子集（筛选出一部分数据）
#### 4.8.1 普通索引
```
# 获取1-3行，所有列的数据
julia> df[1:3, :]

# 获取第1,5,10行，所有列的数据
julia> df[[1, 5, 10], :]

# 获取所有行，A和B列的数据
julia> df[:, [:A, :B]]

# 获取1-3行， B和A列的数据，列的显示顺序按照索引的次序
julia> df[1:3, [:B, :A]]

# 获取第3, 1行，C列的数据
julia> df[[3, 1], [:C]]

# 使用view宏，并不返回一个copy
julia> @view df[1:3, :A]
```
注： df[!, [:A]] 和 df[:, [:A]] 返回的数据类型是DataFrame，而 df[!, :A] and df[:, :A] 返回的是一个向量

#### 4.8.2 正则表达式、Not、All 索引
```
julia> df = DataFrame(x1=1, x2=2, y=3);
julia> df[!, r"x"]
1×2 DataFrame
│ Row │ x1    │ x2    │
│     │ Int64 │ Int64 │
├─────┼───────┼───────┤
│ 1   │ 1     │ 2     │

julia> df[!, Not(:x1)]
1×2 DataFrame
│ Row │ x2    │ y     │
│     │ Int64 │ Int64 │
├─────┼───────┼───────┤
│ 1   │ 2     │ 3     │

julia> df = DataFrame(r=1, x1=2, x2=3, y=4);
# 将所有列名包含字符x的移动到最前方
julia> df[:, All(r"x", :)]
1×4 DataFrame
│ Row │ x1    │ x2    │ r     │ y     │
│     │ Int64 │ Int64 │ Int64 │ Int64 │
├─────┼───────┼───────┼───────┼───────┤
│ 1   │ 2     │ 3     │ 1     │ 4     │

# 将所有列名包含字符x的移动到最后方
julia> df[:, All(Not(r"x"), :)]
1×4 DataFrame
│ Row │ r     │ y     │ x1    │ x2    │
│     │ Int64 │ Int64 │ Int64 │ Int64 │
├─────┼───────┼───────┼───────┼───────┤
│ 1   │ 1     │ 4     │ 2     │ 3     │
```

#### 4.8.3 条件索引
```
# 索引出A列数据大于500的所有行和所有列数据
julia> df[df.A .> 500, :]

# 列A大于500 并且 列C在(300,400)之间的所有行和所有列数据
julia> df[(df.A .> 500) .& (300 .< df.C .< 400), :]

# 列A中数据等于1,5,601的所有行和所有列的数据
julia> df[in.(df.A, Ref([1, 5, 601])), :]
```

#### 4.8.4 列索引
通过使用 select，select! 可以选择、重命名、转换列数据。