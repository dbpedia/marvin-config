#!/bin/bash

# get all variables and functions
source functions.sh


##################
# Setup and clone pom files
#################

# fails if folder exists
git clone "https://github.com/dbpedia/databus-maven-plugin.git" $DATABUSDIR 
cd $DATABUSDIR
git pull 

# copy 

