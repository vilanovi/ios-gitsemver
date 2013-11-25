#!/bin/sh

# The MIT License (MIT)
# 
# Copyright (c) 2013 Joan Martin
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy of
# this software and associated documentation files (the "Software"), to deal in
# the Software without restriction, including without limitation the rights to
# use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
# the Software, and to permit persons to whom the Software is furnished to do so,
# subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
# FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
# COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
# IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
# CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 
# This script automatically sets the version and build string of
# an Xcode project from the Git repository containing the project.  
#
# VERSION: last tag in the git repository (should be something like 0.1.4)
# BUILD: number of commits since last tag
# 
# OUTPUT SAMPLE: 2.4.1.11 (version 2.4.1, build 11).
#
# Also, updates to the project info-PLIST the current commit and if it is dirty or not (contains uncomited changes).
# This values are listed in the fields GSVGitCommitID and GSVGitDirtyRepository.
#
# To use this script in Xcode 5:
# Edit Scheme > Build > Pre-actions > + > New run script action
# Then, paste the following: ${PROJECT_DIR}/<path_to_file>/BumpVersionBuildNumber.sh "${PROJECT_DIR}/${INFOPLIST_FILE}"
# Also, set teh "Provide build settings from" to the current project.

function DoLog {
    d=$(date +'%Y-%m-%d %H:%M:%S|%N')
    ms=$(( ${d#*|}/1000000 ))
    d="${d%|*}.$ms"
    
    logtext="[$d] $1"
    file="$GIT_REPO_DIR/../bump_version_log.txt"
    echo "$logtext" >> "$file"
}

plist="$1"
PROJECT_DIR="$(dirname "$plist")"

cd "$PROJECT_DIR"
GIT_REPO_DIR="$(git rev-parse --show-toplevel)"

cd "$GIT_REPO_DIR"

LAST_TAG=$(git describe --dirty | awk '{split($0,a,"-"); print a[1]}')
COMMIT_COUNT_FROM_TAG=$(git describe --dirty | awk '{split($0,a,"-"); print a[2]}');
COMMIT_ID=$(git describe --dirty | awk '{split($0,a,"-"); print a[3]}');
COMMIT_DIRTY=$(git describe --dirty | awk '{split($0,a,"-"); print a[4]}');
COMMIT_COUNT_TOTAL=$(git rev-list HEAD --count);
  
# Validate LAST_TAG
if [[ "$LAST_TAG" == "" ]]; then
	LAST_TAG="0.0.0"
fi

# validate CommitCountFromTag
if [[ "$COMMIT_COUNT_FROM_TAG" == "" ]]; then
    COMMIT_COUNT_FROM_TAG="0"
fi

# validate CommitIsDirty
COMMIT_IS_DIRTY=1;
if [[ "$COMMIT_DIRTY" == "" ]]; then
    COMMIT_IS_DIRTY=0;
fi

# Validate CommitCountTotal
if [[ "$COMMIT_COUNT_TOTAL" == "" ]]; then
	COMMIT_COUNT_TOTAL="0"
fi

# Assign the choosen values
SHORT_VERSION_STRING="$LAST_TAG"
#BUNDLE_VERSION="$COMMIT_COUNT_FROM_TAG" # <-- NOT VALID FOR AppStore SUBMISSION!
#BUNDLE_VERSION="$COMMIT_COUNT_TOTAL"
BUNDLE_VERSION="$LAST_TAG"

# Log if debug needed
# DoLog "CFBundleShortVersionString $SHORT_VERSION_STRING"
# DoLog "CFBundleVersion $BUNDLE_VERSION"
# DoLog "GSVGitCommitID $COMMIT_ID"
# DoLog "GSVGitDirtyRepository $COMMIT_IS_DIRTY"

#Setting the ShortVersionString and BundleVersion
/usr/libexec/Plistbuddy -c "Set :CFBundleShortVersionString $SHORT_VERSION_STRING" "$plist"
/usr/libexec/Plistbuddy -c "Set :CFBundleVersion $BUNDLE_VERSION" "$plist"

#Setting additional values
/usr/libexec/Plistbuddy -c "Add :GSVGitCommitID string 0" "$plist"
/usr/libexec/Plistbuddy -c "Add :GSVGitDirtyRepository bool 0" "$plist"
/usr/libexec/Plistbuddy -c "Set :GSVGitCommitID $COMMIT_ID" "$plist"
/usr/libexec/Plistbuddy -c "Set :GSVGitDirtyRepository $COMMIT_IS_DIRTY" "$plist"
