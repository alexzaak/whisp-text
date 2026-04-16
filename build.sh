#!/bin/bash
set -e

APP_NAME="WhispText"
BUILD_DIR=".build/release"
APP_DIR="build/${APP_NAME}.app"
CONTENTS_DIR="${APP_DIR}/Contents"
MACOS_DIR="${CONTENTS_DIR}/MacOS"
RESOURCES_DIR="${CONTENTS_DIR}/Resources"

echo "Building Swift package..."
swift build -c release

echo "Creating App Bundle structure..."
mkdir -p "${MACOS_DIR}"
mkdir -p "${RESOURCES_DIR}"

echo "Copying executable..."
cp "${BUILD_DIR}/${APP_NAME}" "${MACOS_DIR}/"

echo "Copying Info.plist..."
cp "Constants/Info.plist" "${CONTENTS_DIR}/"

# Assuming you might want to bundle an icon later:
# cp "Resources/AppIcon.icns" "${RESOURCES_DIR}/" || true

echo "App Bundle created at ${APP_DIR}!"
