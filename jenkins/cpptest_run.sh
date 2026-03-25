#!/bin/bash 

set -x

# SCRIPTS_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

WORK_DIR=`pwd`
# CPPTEST_DIR=$HOME/parasoft/cpptest/10.4
CPPTEST_DIR=/opt/e3sdk/parasoft/cpptest-extension/10.4

# cleanup
rm -rf atm_cpp14 workspace reports
mkdir -p reports

# normally it should be 
git clone http://git.parasoft.com.pl/proserve/atm_cpp14.git
# here is poor man's "git clone" 
# tar xvfz $WORK_DIR/atm_cpp14.tar.gz

# import project into workspace
$CPPTEST_DIR/cpptestcli \
    -data workspace \
    -localsettings cpptest.properties \
    -showdetails -appconsole stdout \
    -import atm_cpp14 \
    "$@"

# run static analysis
$CPPTEST_DIR/cpptestcli \
    -data workspace \
    -localsettings cpptest.properties \
    -showdetails -appconsole stdout \
    -config "builtin://AUTOSAR C++14 Coding Guidelines" \
    -resource ATM_Cpp14 \
    -report reports/autosar \
    "$@"

# run unit tests
$CPPTEST_DIR/cpptestcli \
    -data workspace \
    -localsettings cpptest.properties \
    -showdetails -appconsole stdout \
    -config "builtin://Run Unit Tests" \
    -resource ATM_Cpp14 \
    -report reports/unit_tests \
    "$@"

ls -l reports/*
 

