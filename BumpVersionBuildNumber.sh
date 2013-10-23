#!/bin/sh
 
# This script automatically sets the version and build string of
# an Xcode project from the Git repository containing the project.  
#
# VERSION: last tag in the git repository (should be something like 0.1.4)
# BUILD: <number_of_commits_since_last_tag>
# 
# OUTPUT SAMPLE: 2.4.1.11 (version 2.4.1, build 11).
#
# Also, updates to the project PLIST the current commit and if dirty or not.
# This values are listed in the fields CTVGitCommitID and CTVGitDirtyRepository.
#
# To use this script in Xcode 5:
# Edit Scheme > Build > Pre-actions > + > New run script action
# Then, paste the following: ${PROJECT_DIR}/<path_to_file>/BumpVersionBuildNumber.sh "${PROJECT_DIR}/${INFOPLIST_FILE}"
# Also, set teh "Provide build settings from" to the current project.

function CTVLog {
    d=$(date +'%Y-%m-%d %H:%M:%S|%N')
    ms=$(( ${d#*|}/1000000 ))
    d="${d%|*}.$ms"
    
    logtext="[$d] $1"
    file="$GIT_REPO_DIR/../bump_version_log.txt"
    echo "$logtext" >> "$file"
}

plist="$1"
PROJECT_DIR="$(dirname "$plist")"
GIT_REPO_DIR="${PROJECT_DIR}/../../"

cd "$GIT_REPO_DIR"

SHORT_VERSION_STRING=$(git describe --dirty | awk '{split($0,a,"-"); print a[1]}')
COMMIT_VERSION=$(git describe --dirty | awk '{split($0,a,"-"); print a[2]}');
COMMIT_ID=$(git describe --dirty | awk '{split($0,a,"-"); print a[3]}');
COMMIT_DIRTY=$(git describe --dirty | awk '{split($0,a,"-"); print a[4]}');

# CTVLog "SHORT_VERSION_STRING $SHORT_VERSION_STRING"
# CTVLog "COMMIT_VERSION $COMMIT_VERSION"
# CTVLog "COMMIT_ID $COMMIT_ID"
# CTVLog "COMMIT_DIRTY $COMMIT_DIRTY"
  
if [[ "$SHORT_VERSION_STRING" == "" ]]; then
    #nothing to do!
    exit 0;
fi

if [[ "$COMMIT_VERSION" == "" ]]; then
    BUILD_STRING="0"
else
    BUILD_STRING="$COMMIT_VERSION"
fi

COMMIT_IS_DIRTY=0;
if [[ "$COMMIT_DIRTY" == "" ]]; then
    COMMIT_IS_DIRTY=0;
else
    COMMIT_IS_DIRTY=1;
fi

# CTVLog "CFBundleShortVersionString $SHORT_VERSION_STRING"
# CTVLog "CFBundleVersion $BUILD_STRING"
# CTVLog "CTVGitCommitID $COMMIT_ID"
# CTVLog "CTVGitDirtyRepository $COMMIT_IS_DIRTY"

/usr/libexec/Plistbuddy -c "Set CFBundleShortVersionString $SHORT_VERSION_STRING" "$plist"
/usr/libexec/Plistbuddy -c "Set CFBundleVersion $BUILD_STRING" "$plist"
/usr/libexec/Plistbuddy -c "Set CTVGitCommitID $COMMIT_ID" "$plist"
/usr/libexec/Plistbuddy -c "Set CTVGitDirtyRepository $COMMIT_IS_DIRTY" "$plist"
