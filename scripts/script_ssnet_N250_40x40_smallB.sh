#!/bin/bash
#SBATCH --array=1-5
#SBATCH --share
#SBATCH --partition=short
#SBATCH --job-name=ssnet_N250_40x40_smallB_%a
#SBATCH --error=ssnet_N250_40x40_smallB_%a.err
#SBATCH --output=ssnet_N250_40x40_smallB_%a.out
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mail-type=FAIL
#SBATCH --mail-user=jleach@uab.edu
#SBATCH --time=11:59:00
#SBATCH --mem-per-cpu=50GB

module load R/3.6.0-foss-2018a-X11-20180131-bare
srun R CMD BATCH /data/user/jleach/sim_06_2021/Rcode/rcode_ssnet_N250_40x40_smallB.R
