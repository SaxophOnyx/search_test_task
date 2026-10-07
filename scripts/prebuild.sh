#!/bin/sh
set -e

cd "$(dirname "$0")/.."

flutter clean
flutter pub get
dart run build_runner build
