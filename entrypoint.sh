#!/bin/bash

# Checks out each of your branches 
# copies the current version of 
# certain files to each branch

echo "==================================="

git config --global user.name "${GITHUB_ACTOR}"
git config --global user.email "${INPUT_EMAIL}"

args_base="${base}"
args_over="${over}"
args_build="${build}"

echo "--GIT FETCH origin"
git fetch origin

git switch -q ${args_base}

# create build branch
git switch -C ${args_build}

# merge
git merge -Xtheirs origin/${args_over} --m "merge ${args_base} and ${args_over} to ${args_build}" --allow-unrelated-historie

git push --set-upstream origin ${args_build}

git switch -q ${args_base}

echo "==================================="
