#!/bin/sh

echo "Release: PRE-Xcode Build is activated .... "

# for future reference
# https://developer.apple.com/documentation/xcode/environment-variable-reference

cd ..

plutil -replace GITHUB_API_KEY -string $GITHUB_API_KEY ./Targets/PRtify/Resources/iOS/PRtify.plist
plutil -replace GITHUB_API_SECRET -string $GITHUB_API_SECRET ./Targets/PRtify/Resources/iOS/PRtify.plist

plutil -p ./Targets/PRtify/Resources/iOS/PRtify.plist

echo "Release: PRE-Xcode Build is DONE .... "

exit 0
