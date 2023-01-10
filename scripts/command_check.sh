#!/bin/bash

# This script is used to check if the
# required commands are installed in
# linux.

if ! command -v cifvalues &> /dev/null
then
    echo 1
else
    echo 0
fi

