# Model fit: ssnet

library(tidyverse)
library(sim2Dpredictr)

# image resolution
im.res <- c(40, 40)

# package to fit model
library(BhGLM)
library(rstan)
rstan_options(auto_write = TRUE)
library(ssnet)

models <- "ss"
alpha <- c(0.5, 1)

# load data
simdata <- readRDS(file = "/data/user/jleach/sim_06_2021/simdata/simdata_N250_40x40_1.RDS")

# Get M from length of list of dataframes
M <- length(simdata)

# generate parameter vector
betas <- beta_builder(index.type = "ellipse",
                      w = 8, h = 8,
                      row.index = 15, col.index = 24,
                      B.values = 0.1, im.res = im.res)

# to store errors
file.create("/data/user/jleach/sim_06_2021/errors/errors_test_ssnet_N250_40x40_500.txt")

## pre-specify stan model
sm <- stan_model(file = "/data/user/jleach/sim_01_2020/stan_models/iar_incl_prob_notau.stan")

t1 <- proc.time()
for (m in 1:25) {

  datm <- simdata[[m]]

  tryCatch(
    expr = {
      fits.m <- compare_ssnet(x = as.matrix(datm[, grep("X.*", names(datm), perl = TRUE)]),
                           y = datm$Y, models = models, im.res = im.res, alpha = alpha,
                           family = "binomial", model_fit = "all",
                           variable_selection = FALSE, verbose = FALSE,
                           classify = TRUE, classify.rule = 0.5,
                           type_error = "kcv", nfolds = 5, ncv = 1,
                           B = betas$B[-1],
                           fold.seed = 438774,
                           s0 = seq(0.01, 0.1, 0.01),
                           s1 = 1:2,
                           output_param_est = TRUE)

      if (m > 1 & exists("fits") == TRUE) {
        fits <- rbind(fits, fits.m$inference)
        ests <- rbind(ests, fits.m$estimates)
      } else {
        fits <- fits.m$inference
        ests <- fits.m$estimates
      }
    },
    error = function(e) {
      message("* Caught an error on iteration ", m)
      print(e)
      write_lines(paste("Iteration #", m , ":", as.character(e)),
                  path = "/data/user/jleach/sim_06_2021/errors/errors_test_ssnet_N250_40x40_500.txt",
                  append = TRUE)
    },
    finally = {
      message(cat(models, " fit for simulated dataset ", m, " has completed."))
    }
  )
}
fit.time <- proc.time() - t1
fit.time

out <- list(fit.time = fit.time,
            estimates = ests,
            inference = fits)

saveRDS(out,
        file = paste0("/data/user/jleach/sim_06_2021/results/results_test_ssnet_N250_40x40_500.RDS"))

