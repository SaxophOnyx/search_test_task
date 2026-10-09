#!/bin/sh
set -e

cd "$(dirname "$0")/.."

flutter clean
flutter pub get
flutter gen-l10n
dart run build_runner build
