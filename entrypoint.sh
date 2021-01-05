#!/bin/bash

# Checks out each of your branches 
# copies the current version of 
# certain files to each branch

echo "==================================="

git config --global user.name "${GITHUB_ACTOR}"
git config --global user.email "${INPUT_EMAIL}"

args_key="${key}"
args_files="${files}"
args_branches="${branches}"
args_exclude="${exclude}"

# Set default list of branches to use
if [ ! -z "${args_branches}" ];
then
	ALL_THE_BRANCHES=( "${args_branches[@]}" )
else
  ALL_THE_BRANCHES=`git branch -r --list|sed 's/origin\///g'`
fi

# Set the KEY branch
if [ ! -z "${args_key}" ];
then
	KEY_BRANCH=$args_key
elif [[ $ALL_THE_BRANCHES[*]} =~ 'master' ]];
then
  KEY_BRANCH='master'
elif [[ $ALL_THE_BRANCHES[*]} =~ 'main' ]];
then
  KEY_BRANCH='main'
else
	echo "Error: A key branch does not exist"
 	exit 1
fi

# Set default list of files to copy
if [ ! -z "${args_files}" ];
then
  echo "\n\n\n\n===================================\n"
  echo "FILES TO PROCESS: ${args_files[*]}"
	ALL_THE_FILES=( "${args_files[@]}" )
else
  ALL_THE_FILES=('LICENSE' 'NOTICE' 'README.md')
fi

# Loop through the array of branches and perform
# a series of checkouts from the KEY_BRANCH 
for CURRENT_BRANCH in ${ALL_THE_BRANCHES[@]};
  do

    # If this is one of the branches marked for exclusion
    CONTINUE_BRANCH=false
    for EXCLUDE_BRANCH in "${args_exclude[@]}"
      do
        if [ "$CURRENT_BRANCH" = "$EXCLUDE_BRANCH" ];
        then
          CONTINUE_BRANCH=true
        fi
      done

    if [ "$CONTINUE_BRANCH" = true ]
    then
      echo "--SKIPPING $CURRENT_BRANCH"
      continue
    fi

    echo "========DO I CONTINUE: $CONTINUE_BRANCH"

    echo "-------------------------------"
    
    # Check out the current branch, but only if
    # the branch is NOT the same as the key branch
    if [ "${KEY_BRANCH}" != "${CURRENT_BRANCH}" ];
    then
      echo "--GIT CHECKOUT -B $CURRENT_BRANCH ORIGIN/$CURRENT_BRANCH"
      git checkout -b $CURRENT_BRANCH origin/$CURRENT_BRANCH

      # Go through each of the files
      # Check out the selected files from the source branch
      for CURRENT_FILE in ${ALL_THE_FILES[@]};
        do
          echo "--GIT CHECKOUT $KEY_BRANCH -- $CURRENT_FILE"
          git checkout $KEY_BRANCH -- $CURRENT_FILE
        done

      # Commit the changes
      echo "--GIT COMMIT -M Moving files"
      git add -A && git commit -m "Moving files"

      # push the branch to the repository origin
      echo "--PUSHING: $CURRENT_BRANCH"
      git push --set-upstream origin $CURRENT_BRANCH
    fi
  done

# Check out the key branch
git checkout $KEY_BRANCH

echo "\n===================================\n\n\n\n"
