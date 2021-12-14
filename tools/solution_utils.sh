#!/bin/bash

RED='\033[0;31m'
ORANGE='\033[0;33m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

printWaitExec() {
  echo -n "\$ $*"
  read text
  eval "$@"
}

next() {
  echo -n "Next >>"
  read text
  clear
}

echoDashes() {
  echo "----------------------------------------------"
}