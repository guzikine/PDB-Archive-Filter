#!/bin/sh

# This script is called from within the
# pdb_file_statistics script located
# in the scripts/ directory. This shell
# script is used to extract PDB or CIF
# files from the specified direcotry.

DIR=$1
FILE_TYPE=$2

cd $DIR

if [ $FILE_TYPE == "PDB" ]
then
    FILES=`ls`
elif [ $FILE_TYPE == "CIF" ]
then
    FILES=`ls`
fi

echo -n "$FILES"
    
