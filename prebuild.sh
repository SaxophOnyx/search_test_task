#!/bin/sh

flutter clean
dart pub get
dart run build_runner build