#!/bin/bash
cd XCode
xcodebuild -configuration Debug
exec build/Debug/Xsera.app/Contents/MacOS/Xsera -test $@
