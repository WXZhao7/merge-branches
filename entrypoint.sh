#!/bin/bash
echo "==================================="

git config --global user.name "${GITHUB_ACTOR}"
git config --global user.email "${INPUT_EMAIL}"

args_base="${base}"
args_over="${over}"
args_build="${build}"
args_exclude="${exclude}"

echo "--GIT FETCH origin"
git fetch origin

echo "--GIT pull ${args_over} Branch"
git switch -q ${args_over}
git merge origin/${args_over}

echo "--GIT pull ${args_base} Branch"
git switch -q ${args_base}
git merge origin/${args_base}

echo "--GIT checkout ${args_build} Branch base on ${args_base}"
git switch -C ${args_build}
git merge origin/${args_base}

echo "--GIT merge ${args_over} Branch over ${args_build}"
git merge -Xtheirs ${args_over} --m "merge ${args_base} and ${args_over} to ${args_build}" --allow-unrelated-historie

echo "--GIT rm ${args_exclude} in ${args_build} Branch"
for file in $(git ls-files -i -c --exclude="${args_exclude}");
    do
        git rm -f $file
    done

git add -A && git commit -m "Update ${args_build} Branch"

git push --set-upstream origin ${args_build}

git switch -q ${args_base}

echo "==================================="
