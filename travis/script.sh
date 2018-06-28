#!/bin/sh
set -e

cp Snow IO/mock-GoogleService-Info.plist Snow IO/GoogleService-Info.plist

xcodebuild -workspace Snow IO.xcworkspace -scheme Snow IO -destination 'platform=iOS Simulator,name=iPhone 8,OS=11.4' build