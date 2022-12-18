#!/usr/bin/env bash

set -e   # this is a bash flag, if any commands in the script fails => all the script should fail
# usually shell commands are executed one by one, unless we use && (or set -e in a script instead of && of all the commands)
# e.g. COMMAND1 && echo "success" || echo "ERROR": this is a pattern to echo success after 
# COMMAND1 is executed or signal an error otherwise
## e.g. DO_SOMETHING || ROLL_BACK  (if the function do something is executed successfully roll back won't be executed)

# Exit codes:  0 => successfull, !=0 => failed

# condition structure in bash scripting: 
# ----- 1- arithmetic condition => e.g. if [ $number -eq 0 ]; then
# ------2- condition based on a command exit code => e.g. if ls $My_FOLDER; then => will fail if folder doesn't exist


LOCATION=$1

if ! type node; then
  echo "-- Installing Node --"
  curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
  sudo apt-get update
  sudo apt-get install -y nodejs
else
  echo "-- Node already installed --"
fi

if ! type forever; then
  echo "-- Installing Forever --"
  sudo npm i -g forever
else
  echo "-- Forever already installed --"
fi

# Make Logs directory if it does not exists
mkdir -p $LOCATION/logs    # -p doesn't fail if the directory exists

cd $LOCATION/app
npm install
echo "----------------------------my current location----------------"
pwd
echo "----------------------------my current location----------------"
# Substitue the placeholder (APP_LOCATION) in the forever.json file with correct path
# => whenever it find ${App_LOCATION} in forever.json it's replaced with $LOCATION
(APP_LOCATION=$LOCATION envsubst < forever.json) > forever1.json 
rm forever.json
mv forever1.json forever.json
echo "----------------------------APP_LOCATION----------------"
cat forever.json
echo "---------------------------APP_LOCATION----------------"
(forever list | grep app) || forever start forever.json
# app is the UID specified in the forever.json, it has nothing to do with the folder app
# watch mode is enabled in forever.json, so we just need to start forever if it's not running
