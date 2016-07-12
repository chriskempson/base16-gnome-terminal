#!/usr/bin/env bash
# Installs one base-16 profile
# Marcos Menegazzo at robotdance

for f in ./profiles/*.sh
do
  echo "Installing $f"
  ./install-one.sh $f
done
echo "Done."
