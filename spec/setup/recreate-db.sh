#!/usr/bin/env bash

# This script drops the Mongo DB and adds the test user.
# It assumes the existence of a ~/opt/sis-api directory
# that is a clone of the sis-api git repo, and a 'test-user.json'
# data file that is a copy of the file by that name in this directory.
#
# The script should be run from the directory in which it exists.

mongo drop-db.js
#echo  "use sis;\n db.dropDatabase();\n exit" | mongo
cd ~/opt/sis-api
node tools/useradmin.js update test-user.json
cd -