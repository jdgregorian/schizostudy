#!/bin/bash
#PBS -N testjob
#PBS -l walltime=10:00
#PBS -l nodes=1:ppn=1
#PBS -l mem=500mb
#PBS -l scratch=1gb

# if error or termination clean scratch
trap 'clean_scratch' TERM EXIT

# working directory
DATADIR="$PBS_O_WORKDIR" 
echo "datadir: $DATADIR" > /storage/brno2/home/pitrazby/datadir.txt
echo "scratchdir: $SCRATCHDIR" >> /storage/brno2/home/pitrazby/datadir.txt

cd $SCRATCHDIR

git clone https://github.com/jdgregorian/schizostudy.git

module add matlab

matlab -r "cd('schizostudy'); startup; classifyFC(FCdata,'RF'); trymtl"

cp $SCRATCHDIR/test.txt $DATADIR
