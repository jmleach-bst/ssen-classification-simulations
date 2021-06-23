# Model fit: ssnet

library(tidyverse)
library(sim2Dpredictr)

# image resolution
im.res <- c(50, 50)

# package to fit model
library(BhGLM)
library(rstan)
rstan_options(auto_write = TRUE)
library(ssnet)

models <- "ss"
alpha <- c(0.5, 1)

# load data -> use array jobs
runID <- as.numeric(Sys.getenv("SLURM_ARRAY_TASK_ID"))

# load data
simdata <- readRDS(file = paste0("/data/user/jleach/sim_06_2021/simdata/simdata_N500_50x50_",
                                 runID, ".RDS"))

# Get M from length of list of dataframes
M <- length(simdata)

# generate parameter vector
betas <- beta_builder(index.type = "ellipse",
                      w = 8, h = 8,
                      row.index = 10, col.index = 24,
                      B.values = 0.1, im.res = im.res)

# to store errors
file.create(paste0("/data/user/jleach/sim_06_2021/errors/errors_ssnet_N500_50x50_500_",
                   runID, ".txt"))

## pre-specify stan model
sm <- stan_model(file = "/data/user/jleach/sim_01_2020/stan_models/iar_incl_prob_notau.stan")

t1 <- proc.time()
for (m in 1:M) {

  datm <- simdata[[m]]

  tryCatch(
    expr = {
      fits.m <- compare_ssnet(x = as.matrix(datm[, grep("X.*", names(datm), perl = TRUE)]),
                           y = datm$Y, models = models, im.res = im.res, alpha = alpha,
                           family = "binomial", model_fit = "all",
                           variable_selection = TRUE, verbose = FALSE,
                           type_error = "kcv", nfolds = 5, ncv = 1,
                           B = betas$B[-1],
                           fold.seed = 438774,
                           s0 = seq(0.01, 0.3, 0.01),
                           s1 = 1:10,
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
                  path = paste0("/data/user/jleach/sim_06_2021/errors/errors_ssnet_N500_50x50_500_",
                                runID, ".txt"),
                  append = TRUE)
    },
    finally = {
      message(cat(models, " fit for simulated dataset ", m, " has completed."))
    }
  )
}
fit.time <- proc.time() - t1
fit.time

results <- smry_ssnet(fits, output = "mean")

out <- list(fit.time = fit.time,
            estimates = ests,
            inference = fits,
            results = results)

saveRDS(out,
        file = paste0("/data/user/jleach/sim_06_2021/results/results_ssnet_N500_50x50_500_",
                      runID, ".RDS"))

