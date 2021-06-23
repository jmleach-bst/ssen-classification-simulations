# Spike-and-Slab with IAR Priors

library(tidyverse)
library(sim2Dpredictr)

# image resolution
im.res <- c(40, 40)

# package to fit model
library(BhGLM)
library(rstan)
rstan_options(auto_write = TRUE)
library(ssnet)

models <- "ss_iar"
alpha <- c(0.5, 1)

# load data -> use array jobs
runID <- as.numeric(Sys.getenv("SLURM_ARRAY_TASK_ID"))

if (runID %in% 1:2) {
  simdata <- readRDS(file = "/data/user/jleach/sim_06_2021/simdata/simdata_N250_40x40_1.RDS")
  if (runID == 1) {
    simdata <- simdata[1:250]
  } 
  if (runID == 2) {
    simdata <- simdata[251:500]
  }
}

if (runID %in% 3:4) {
  simdata <- readRDS(file = "/data/user/jleach/sim_06_2021/simdata/simdata_N250_40x40_2.RDS")
  if (runID == 3) {
    simdata <- simdata[1:250]
  } 
  if (runID == 4) {
    simdata <- simdata[251:500]
  }
}

if (runID %in% 5:6) {
  simdata <- readRDS(file = "/data/user/jleach/sim_06_2021/simdata/simdata_N250_40x40_3.RDS")
  if (runID == 5) {
    simdata <- simdata[1:250]
  } 
  if (runID == 6) {
    simdata <- simdata[251:500]
  }
}

if (runID %in% 7:8) {
  simdata <- readRDS(file = "/data/user/jleach/sim_06_2021/simdata/simdata_N250_40x40_4.RDS")
  if (runID == 7) {
    simdata <- simdata[1:250]
  } 
  if (runID == 8) {
    simdata <- simdata[251:500]
  }
}

if (runID %in% 9:10) {
  simdata <- readRDS(file = "/data/user/jleach/sim_06_2021/simdata/simdata_N250_40x40_5.RDS")
  if (runID == 9) {
    simdata <- simdata[1:250]
  } 
  if (runID == 10) {
    simdata <- simdata[251:500]
  }
}

if (runID %in% 11:12) {
  simdata <- readRDS(file = "/data/user/jleach/sim_06_2021/simdata/simdata_N250_40x40_6.RDS")
  if (runID == 11) {
    simdata <- simdata[1:250]
  } 
  if (runID == 12) {
    simdata <- simdata[251:500]
  }
}

if (runID %in% 13:14) {
  simdata <- readRDS(file = "/data/user/jleach/sim_06_2021/simdata/simdata_N250_40x40_7.RDS")
  if (runID == 13) {
    simdata <- simdata[1:250]
  } 
  if (runID == 14) {
    simdata <- simdata[251:500]
  }
}

if (runID %in% 15:16) {
  simdata <- readRDS(file = "/data/user/jleach/sim_06_2021/simdata/simdata_N250_40x40_8.RDS")
  if (runID == 15) {
    simdata <- simdata[1:250]
  } 
  if (runID == 16) {
    simdata <- simdata[251:500]
  }
}

if (runID %in% 17:18) {
  simdata <- readRDS(file = "/data/user/jleach/sim_06_2021/simdata/simdata_N250_40x40_9.RDS")
  if (runID == 17) {
    simdata <- simdata[1:250]
  } 
  if (runID == 18) {
    simdata <- simdata[251:500]
  }
}

if (runID %in% 19:20) {
  simdata <- readRDS(file = "/data/user/jleach/sim_06_2021/simdata/simdata_N250_40x40_10.RDS")
  if (runID == 19) {
    simdata <- simdata[1:250]
  } 
  if (runID == 20) {
    simdata <- simdata[251:500]
  }
}


# Get M from length of list of dataframes
M <- length(simdata)

# IAR info for stan
adjmat <- proximity_builder(im.res = im.res, type = "sparse")
model_info <- mungeCARdata4stan(adjmat$nb.index,
                                table(adjmat$location.index))

# generate parameter vector
betas <- beta_builder(index.type = "ellipse",
                      w = 8, h = 8,
                      row.index = 15, col.index = 24,
                      B.values = 0.1, im.res = im.res)

# to store errors
file.create(paste0("/data/user/jleach/sim_06_2021/errors/errors_ssnet_iar_N250_40x40_250_",
                   runID, ".txt"))

## pre-specify stan model
sm <- stan_model(file = "/data/user/jleach/sim_01_2020/stan_models/iar_incl_prob_notau.stan")

t1 <- proc.time()
for (m in 1:M) {
  
  datm <- simdata[[m]]
  
  tryCatch(
    expr = {
      fits.m <- compare_ssnet(x = as.matrix(datm[, grep("X.*", names(datm), perl = TRUE)]),
                              alpha = alpha,
                              y = datm$Y, models = models, im.res = im.res,
                              family = "binomial", model_fit = "all",
                              variable_selection = FALSE, verbose = FALSE,
                              classify = TRUE, classify.rule = 0.5,
                              type_error = "kcv", nfolds = 5, ncv = 1,
                              B = betas$B[-1],
                              iar.data = model_info,
                              # tau.prior = "none",
                              stan_manual = sm,
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
                  path = paste0("/data/user/jleach/sim_06_2021/errors/errors_ssnet_iar_N250_40x40_250_",
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

out <- list(fit.time = fit.time,
            estimates = ests,
            inference = fits)

saveRDS(out,
        file = paste0("/data/user/jleach/sim_06_2021/results/results_ssnet_iar_N250_40x40_250_",
                      runID, ".RDS"))