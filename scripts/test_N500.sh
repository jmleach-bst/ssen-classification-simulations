#!/bin/bash
#SBATCH --share
#SBATCH --partition=express
#SBATCH --job-name=test_N500
#SBATCH --error=test_N500.err
#SBATCH --output=test_N500.out
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mail-type=FAIL
#SBATCH --mail-user=jleach@uab.edu
#SBATCH --time=1:59:00
#SBATCH --mem-per-cpu=50GB

module load R/3.6.0-foss-2018a-X11-20180131-bare
srun R CMD BATCH /data/user/jleach/sim_06_2021/Rcode/test_N500.R
