#!/usr/bin/env bash

[ -d snapshots ] && rm -rf snapshots
mkdir snapshots

TOOLS=$(find bin -type f | awk '{gsub(".dart", "");gsub("bin/", "");print}')
for TOOL in ${TOOLS}
do
  dart --snapshot=snapshots/${TOOL}.snapshot bin/${TOOL}.dart
done
