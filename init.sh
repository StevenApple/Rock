#!/bin/bash
# install CocoaPods
sudo gem install cocoapods

rm -rf Pods Podfile.lock Softphone.xcworkspace/ DerivedData
rm -rf ~/Library/Developer/Xcode/DerivedData/
rm -rf "${HOME}/Library/Caches/CocoaPods"
pod install

#Fix pjsip build
PJPROJECT="Pods/pjsip/build/pjproject-2.3/"
mkdir -p "${PJPROJECT}pjlib/lib"
mkdir -p "${PJPROJECT}pjlib-util/lib"
mkdir -p "${PJPROJECT}pjmedia/lib"
mkdir -p "${PJPROJECT}pjnath/lib"
mkdir -p "${PJPROJECT}pjsip/lib"
mkdir -p "${PJPROJECT}third_party/lib"

cp -a Pods/pjsip/build/pjproject/src/pjlib/lib/* "${PJPROJECT}pjlib/lib/"
cp -a Pods/pjsip/build/pjproject/src/pjlib-util/lib/* "${PJPROJECT}pjlib-util/lib/"
cp -a Pods/pjsip/build/pjproject/src/pjmedia/lib/* "${PJPROJECT}pjmedia/lib/"
cp -a Pods/pjsip/build/pjproject/src/pjnath/lib/* "${PJPROJECT}pjnath/lib/"
cp -a Pods/pjsip/build/pjproject/src/pjsip/lib/* "${PJPROJECT}pjsip/lib/"
cp -a Pods/pjsip/build/pjproject/src/third_party/lib/* "${PJPROJECT}third_party/lib/"

