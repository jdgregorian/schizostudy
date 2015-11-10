#!/bin/bash
# Metacentrum task manager for deployd Matlab-compiled 'metacentrum_task_matlab' binary

# usage:
#   ./metacentrum_runExperiment.sh EXPID META_QUEUE [ID1] [ID2]...
#
# where
#   EXPID       -- string with experiment's unique ID
#   META_QUEUE  -- string with walltime for Metacentrum (2h/4h/1d/2d/1w)
#   NUM_OF_JOBS -- integer defining how many jobs will run
#
# settings within this file:
#   EXPPATH_SHORT  -- $CWD/experiments

# ExperimentID (string)
EXPID=$1

# Metacentrum queue/walltime (2h/4h/1d/2d/1w)
QUEUE=$2

# Number of jobs (integer)
NUM_OF_JOBS=$3

# IDs of the tasks to be submitted (CWD == path where the current file is)
CWD=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
EXPPATH_SHORT="$CWD/experiments"

export EXPID
export EXPPATH_SHORT
export JOBID

for JOBID in $NUM_OF_JOBS; do
  qsub -N "${EXPID}__${JOBID}" -l "walltime=$QUEUE" -v EXPID,EXPPATH_SHORT,JOBID $EXPPATH_SHORT/binary_task.sh
  if [ ! $? -eq 0 ] ; then
    echo "Nepodarilo se zadat ulohu segment ${JOBID}! Koncim."; exit 1
  else
    echo "Job ${EXPID} / ${JOBID} submitted to the '$QUEUE' queue."
    touch "$EXPPATH_SHORT/$EXPID/queued_$JOBID"
  fi
done
