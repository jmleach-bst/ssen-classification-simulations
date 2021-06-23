library(tidyverse)

simdata <- c(
  readRDS(file = "/data/user/jleach/sim_06_2021/simdata/simdata_N250_40x40_1.RDS"),
  readRDS(file = "/data/user/jleach/sim_06_2021/simdata/simdata_N250_40x40_2.RDS"),
  readRDS(file = "/data/user/jleach/sim_06_2021/simdata/simdata_N250_40x40_3.RDS"),
  readRDS(file = "/data/user/jleach/sim_06_2021/simdata/simdata_N250_40x40_4.RDS"),
  readRDS(file = "/data/user/jleach/sim_06_2021/simdata/simdata_N250_40x40_5.RDS")
)

simdata.smallB <- c(
  readRDS(file = "/data/user/jleach/sim_06_2021/simdata/simdata_N250_40x40_smallB_1.RDS"),
  readRDS(file = "/data/user/jleach/sim_06_2021/simdata/simdata_N250_40x40_smallB_2.RDS"),
  readRDS(file = "/data/user/jleach/sim_06_2021/simdata/simdata_N250_40x40_smallB_3.RDS"),
  readRDS(file = "/data/user/jleach/sim_06_2021/simdata/simdata_N250_40x40_smallB_4.RDS"),
  readRDS(file = "/data/user/jleach/sim_06_2021/simdata/simdata_N250_40x40_smallB_5.RDS")
)

y.means <- c()

for (i in 1:length(simdata)) {
  y.means[i] <- mean(simdata[[i]]$Y)
}

# mean(y.means.ex)
# sd(y.means.ex)

y.means.smallB <- c()

for (i in 1:length(simdata.smallB)) {
  y.means.smallB[i] <- mean(simdata.smallB[[i]]$Y)
}

# mean(y.means.ex.smallB)
# sd(y.means.ex.smallB)

balance.smry <- cbind(
  data.frame(
    Beta = c(0.10, 0.05),
    Mean = c(mean(y.means), mean(y.means.smallB)),
    SD = c(sd(y.means), sd(y.means.smallB))
  ),
  rbind(quantile(y.means),
        quantile(y.means.smallB))
)

saveRDS(balance.smry,
        file = paste0("/data/user/jleach/sim_06_2021/results/results_balance_smry.RDS"))

