#!/bin/bash
set +e
set -x

# Delete files that pip caches when installing a package.
rm -rf /root/.cache/pip/*
# Delete old downloaded archive files 
apt-get autoremove -y
# Delete downloaded archive files
apt-get clean
# Ensures the current working directory won't be deleted
cd /usr/local/src/
# Delete source files used for building binaries
rm -rf /usr/local/src/*

# Conda Cleanup
if [ -x "$(command -v conda)" ]; then
    conda clean --all -f -y
    conda build purge-all
fi
# npm Cleanup
if [ -x "$(command -v npm)" ]; then
    npm cache clean --force
fi