#!/bin/bash
#SBATCH --array=1-10
#SBATCH --share
#SBATCH --partition=medium
#SBATCH --job-name=ssnet_iar_N250_40x40_%a
#SBATCH --error=ssnet_iar_N250_40x40_%a.err
#SBATCH --output=ssnet_iar_N250_40x40_%a.out
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mail-type=FAIL
#SBATCH --mail-user=jleach@uab.edu
#SBATCH --time=48:59:00
#SBATCH --mem-per-cpu=50GB

module load R/3.6.0-foss-2018a-X11-20180131-bare
srun R CMD BATCH /data/user/jleach/sim_06_2021/Rcode/rcode_ssnet_iar_N250_40x40.R
