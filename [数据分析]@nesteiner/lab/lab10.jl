using MLJ
import RDatasets: dataset
import DataFrames: DataFrame, select, Not, describe
using Random

data = dataset("ISLR", "OJ")
X = select(data, [:PriceCH, :PriceMM, :DiscCH, :DiscMM, :SalePriceMM,
                  :SalePriceCH, :PriceDiff, :PctDiscMM, :PctDiscCH]);
Random.seed!(1515)
@load PCA pkg=MultivariateStats
@load KMeans pkg=Clustering
SPCA2 = @pipeline(Standardizer,
                  PCA,
                  KMeans(k=3))
spca2 = machine(SPCA2, X)
fit!(spca2)
