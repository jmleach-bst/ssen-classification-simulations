#!/bin/bash
#SBATCH --array=1-10
#SBATCH --share
#SBATCH --partition=express
#SBATCH --job-name=simdata_N250_%a
#SBATCH --error=simdata_N250_%a.err
#SBATCH --output=simdata_N250_%a.out
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mail-type=FAIL
#SBATCH --mail-user=jleach@uab.edu
#SBATCH --time=1:59:00
#SBATCH --mem-per-cpu=50GB

module load R/3.6.0-foss-2018a-X11-20180131-bare
srun R CMD BATCH /data/user/jleach/sim_06_2021/Rcode/simdata_N250.R
