using AppBundler

import Pkg.BinaryPlatforms: Linux, MacOS, Windows

APP_DIR = dirname(@__DIR__)

BUILD_DIR = joinpath(APP_DIR, "build")
mkpath(BUILD_DIR)

AppBundler.bundle_app(MacOS(:x86_64), APP_DIR, "$BUILD_DIR/gtkapp-x64.app")
AppBundler.bundle_app(MacOS(:aarch64), APP_DIR, "$BUILD_DIR/gtkapp-arm64.app")

AppBundler.bundle_app(Linux(:x86_64), APP_DIR, "$BUILD_DIR/gtkapp-x64-linux")
AppBundler.bundle_app(Linux(:aarch64), APP_DIR, "$BUILD_DIR/gtkapp-arm64-linux")
AppBundler.bundle_app(Linux(:aarch64), APP_DIR, "$BUILD_DIR/gtkapp-arm64.snap")

AppBundler.bundle_app(Windows(:x86_64), APP_DIR, "$BUILD_DIR/gtkapp-x64-win")
