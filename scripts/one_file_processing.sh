#!/bin/bash

# This shell script is used to extract
# CIF or PDB values from single files.
# The script itself is called from within
# the pdb_archive_filter which is found in
# scripts folder.

FILE=$1
FILE_TYPE=$2

FZ=""
GZ=""
GZ=`echo -n $FILE | grep '\.gz$'`
RESOLUTION=""
METHOD=""
YEAR=""
ID=""
ATOMS=""

if [ $FILE_TYPE == "CIF" ]
then
    if [[ $GZ == $FZ ]]
    then
	RESOLUTION=`cat $FILE | cifvalues --vseparator " " \
	-t _refine.ls_d_res_high | awk '{print $2}'`
	METHOD=`cat $FILE | cifvalues --vseparator " " \
    	-t _exptl.method | awk '{print $2 "_" $3}'`
	YEAR=`cat $FILE | cifvalues --vseparator " " \
    	-t _pdbx_database_status.recvd_initial_deposition_date \
	| awk '{print $2}' | sed 's/^\([0-9]*\)-[0-9]*-[0-9]*$/\1/'`
	ID=`cat $FILE | cifvalues --vseparator " " -t _entry.id \
       	| awk '{print $2}'`
	ATOMS=`cat $FILE | cifvalues --vseparator " " -t \
       	_refine_hist.number_atoms_total | awk '{print $2}'`
    else
	RESOLUTION=`zcat $FILE | cifvalues --vseparator " " \
       	-t _refine.ls_d_res_high | awk '{print $2}'`
	METHOD=`zcat $FILE | cifvalues --vseparator " " \
       	-t _exptl.method | awk '{print $2 "_" $3}'`
	YEAR=`zcat $FILE | cifvalues --vseparator " " \
       	-t _pdbx_database_status.recvd_initial_deposition_date \
       	| awk '{print $2}' | sed 's/^\([0-9]*\)-[0-9]*-[0-9]*$/\1/'`
	ID=`zcat $FILE | cifvalues --vseparator " " -t _entry.id \
       	| awk '{print $2}'`
	ATOMS=`zcat $FILE | cifvalues --vseparator " " -t \
       	_refine_hist.number_atoms_total | awk '{print $2}'`
    fi
elif [ $FILE_TYPE == "PDB" ]
then
    if [[ $GZ == $FZ ]]
    then
	RESOLUTION=`cat $FILE | grep '^REMARK.*RESOLUTION\..*[0-9]' | \
	awk '{print $4}'`
	METHOD=`cat $FILE | grep '^EXPDTA' | awk '{print $2 "_" $3}'`
	YEAR=`cat $FILE | grep '^HEADER' | awk '{print $(NF-1)}' \
	| sed 's/[0-9]\{2\}-[A-Z]\{3\}-\([0-9]\{2\}\)/\1/'`
	ID=`cat $FILE | grep '^HEADER' | awk '{print $NF}'`
	ATOMS=`cat $FILE | grep -c ^ATOM`
    else
	RESOLUTION=`zcat $FILE | grep '^REMARK.*RESOLUTION\..*[0-9]' | \
	awk '{print $4}'`
        METHOD=`zcat $FILE | grep '^EXPDTA' | awk '{print $2 "_" $3}'`
        YEAR=`zcat $FILE | grep '^HEADER' | awk '{print $(NF-1)}' \
	| sed 's/[0-9]\{2\}-[A-Z]\{3\}-\([0-9]\{2\}\)/\1/'`
        ID=`zcat $FILE | grep '^HEADER' | awk '{print $NF}'`
        ATOMS=`zcat $FILE | grep -c ^ATOM`
    fi
fi
    
echo -n "$ID|$YEAR|$METHOD|$RESOLUTION|$ATOMS"
