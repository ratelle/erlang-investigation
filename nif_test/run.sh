#!/bin/bash

TEST="$1"

PROCS="1000"
CLEAN_PERCENT="1"
NPERTEN="600"
LONG="1"



if [ "$TEST" = "pure4" ]; then
  erl -pa ebin +S4:4 +sbt db -eval "nif_test:run_pure_test($PROCS,$LONG)"
elif [ "$TEST" = "pure8" ]; then
  erl -pa ebin +S8:8 +sbt db -eval "nif_test:run_pure_test($PROCS,$LONG)"
elif [ "$TEST" = "pure16" ]; then
  erl -pa ebin +S16:16 +sbt db -eval "nif_test:run_pure_test($PROCS,$LONG)"
elif [ "$TEST" = "dirty8" ]; then
  erl -pa ebin +S8:8 +sbt db -eval "nif_test:run_dirty_test($PROCS,$CLEAN_PERCENT,$LONG)"
elif  [ "$TEST" = "clean8" ]; then
  erl -pa ebin +S8:8 +sbt db -eval "nif_test:run_clean_test($PROCS,$CLEAN_PERCENT,$NPERTEN,$LONG)"

fi
