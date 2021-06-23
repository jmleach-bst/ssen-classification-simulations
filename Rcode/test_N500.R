# test file for estimating computation time

library(tidyverse)
library(sim2Dpredictr)

set.seed(87462384)

# How many simulations?
M <- 50

# How many subjects per dataset?
N <- 500

# Continuous or binary predictors?
x.ms <- "continuous"
# x.ms <- "binary"

# Continuous or binary outcomes?
y.ms <- "binomial"
# y.ms <- "gaussian"

# image resolution; i.e., number of predictors
im.res <- c(50, 50)

if (x.ms == "continuous") {
  # can modify these arguments if needed.
  L = chol_s2Dp(im.res = im.res, rho = 0.90,
                corr.structure = "ar1",
                triangle = "lower")
}

# generate parameter vector
betas <- beta_builder(index.type = "ellipse",
                      w = 8, h = 8,
                      row.index = 10, col.index = 24,
                      B.values = 0.5, im.res = im.res)

# to store data
data.list <- list()

# run simulations
set.seed(23432)
t1 <- proc.time()
for (m in 1:M) {
  
  # generate data
  if (x.ms == "continuous") {
    datm <- sim_Y_MVN_X(N = N, dist = y.ms,
                        L = L$L, S = L$S,
                        B = betas$B)
  } else {
    # from second line on will likely need adjustments
    datm <- sim_Y_Binary_X(N = N, dist = "binomial", B = betas$B, im.res = im.res,
                           lambda = 50, sub.area = TRUE,
                           min.sa = c(0.15, 0.2), max.sa = c(0.25, 0.5),
                           radius.bounds.min.sa = c(0.02, 0.04),
                           radius.bounds.max.sa = c(0.045, 0.06))
  }
  
  data.list[[m]] <- datm
  cat("Simulation ", m, " has completed. \n")
}
proc.time() - t1

# # break up into more manageable pieces; here 10 independent datasets of 500 each.
# D <- 10
# # size of each data set; i.e., 1k in this case.
# S <- M/D
# 
# for (d in 1:D) {
#   min <- 1 + (S * (d - 1))
#   max <- S * d
#   saveRDS(data.list[min:max], 
#           file = paste0("/data/user/jleach/sim_06_2021/simdata/simdata_N500_50x50_", d, ".RDS"))
# }

saveRDS(data.list,
        file = "/data/user/jleach/sim_06_2021/simdata/test_N500_50x50.RDS")