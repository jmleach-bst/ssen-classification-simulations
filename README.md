
<!-- README.md is generated from README.Rmd. Please edit that file -->

# What is it?

This repository contains code for reproducing simulations in a paper
we’re submitting for publication. The folder “Rcode” contains code for
simulating and analyzing data, while the folder “scripts” contains `.sh`
files for running simulations and analyses on UAB’s cluster, which uses
Slurm Workload Manager (<https://slurm.schedmd.com/overview.html>). If
you want to re-run everything from scratch, you will need to change path
names in `R` files and the slurm scripts, and if your institution does
not use slurm, then the shells may not be that useful to you. The `R`
files whose file names are of the form `test_.*.R` can be used to get an
idea for runtimes necessary on your machine or institution cluster. The
primary file of interest for most users is the `.Rmd` file, which
reproduces tables and figures, and gives some brief details of the
simulation scenario and how values were generated.