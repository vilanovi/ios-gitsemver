#!/bin/sh

# This script reverts the build string and commit related values
# of an Xcode project to a default value
# 
# To use this script in Xcode 5:
# Edit Scheme > Build > Post-actions > + > New run script action
# Then, paste the following:${PROJECT_DIR}/<path_to_file>/RevertBumpVersionBuildNumber.sh "${PROJECT_DIR}/${INFOPLIST_FILE}"
# Also, set teh "Provide build settings from" to the current project.

plist="$1"
PROJECT_DIR="$(dirname "$plist")"

buildPlist=$"$PROJECT_DIR/$plist}"

BUNDLE_VERSION=0
COMMIT_ID=0
COMMIT_IS_DIRTY=0

/usr/libexec/PlistBuddy -c "Set :CFBundleVersion $BUNDLE_VERSION" "$plist"
/usr/libexec/PlistBuddy -c "Set :GSVGitCommitID $COMMIT_ID" "$plist"
/usr/libexec/PlistBuddy -c "Set :GSVGitDirtyRepository $COMMIT_IS_DIRTY" "$plist"