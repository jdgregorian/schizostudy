#!/bin/sh
#PBS -l nodes=1:ppn=1
#PBS -l mem=1gb
#PBS -l scratch=1gb

# it suppose the following variables set:
#
#   EXPID          -- string with unique identifier of the whole experiment
#   JOBID         -- integer which identifies running job
#   EXPPATH_SHORT  -- usually $APPROOT/exp/experiments
# 

# MATLAB Runtime environment
export LD_LIBRARY_PATH=/storage/plzen1/home/pitrazby/bin/mcr/v90/runtime/glnxa64:/storage/plzen1/home/pitrazby/bin/mcr/v90/bin/glnxa64:/storage/plzen1/home/pitrazby/bin/mcr/v90/sys/os/glnxa64:$LD_LIBRARY_PATH
export SCRATCHDIR
export LOGNAME
EXPPATH="$EXPPATH_SHORT/$EXPID"

if [ -z "$EXPID" ] ; then
  echo "Error: EXPID (experiment ID) is not known"; exit 1
fi
if [ -z "$JOBID" ] ; then
  echo "Error: JOBID is not known"; exit 1
fi
if [ -z "$EXPPATH_SHORT" ] ; then
  echo "Error: directory with the experiment is not known"; exit 1
fi

cd "$EXPPATH_SHORT/.."
ulimit -t unlimited

######### CALL #########
#
./metacentrum_task "$EXPID"  "$JOBID"
#
########################

echo `date "+%Y-%m-%d %H:%M:%S"` "  **$EXPID**  ==== FINISHED ===="
