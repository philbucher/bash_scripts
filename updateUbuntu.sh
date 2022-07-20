#!/bin/bash

# small utility script for updating ubuntu
# Author: Philipp Bucher

for _ in {1..3} # running multiple times, as sometimes package changes do not get detected in the first run
do
    sudo apt-get dist-upgrade
    sudo apt-get update
    sudo apt-get autoremove
    sudo apt-get autoclean
    echo
done
