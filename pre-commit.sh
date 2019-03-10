#!/bin/bash

xcodebuild -project SQLite.Swiftly/SQLite.Swiftly.xcodeproj -scheme SQLite.Swiftly -destination platform="iOS Simulator",name="iPhone XS Max" build test | xcpretty