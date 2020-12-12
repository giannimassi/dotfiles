#!/bin/bash

/usr/local/bin/fswatch -e ".git" -e ".*\.swp" -e ".*~" -0 . | xargs -0 -n 1 -I {} basename {}
