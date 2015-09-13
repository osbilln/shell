#!/bin/bash

PATH_TO_PACKAGE=$1
echo "$PATH_TO_PACKAGE"
PACKAGE_NAME=`basename "${PATH_TO_PACKAGE}"`
RECEIPT_DIR="/Library/Parallels/Receipts"

mkdir -p "${RECEIPT_DIR}/${PACKAGE_NAME}/Contents"
if [ -e "${PATH_TO_PACKAGE}/Contents/Archive.bom" ]; then
	cp -f "${PATH_TO_PACKAGE}/Contents/Archive.bom" "${RECEIPT_DIR}/${PACKAGE_NAME}/Contents/Archive.bom"
fi
if [ -e "${PATH_TO_PACKAGE}/Contents/Info.plist" ]; then
	cp -f "${PATH_TO_PACKAGE}/Contents/Info.plist" "${RECEIPT_DIR}/${PACKAGE_NAME}/Contents/Info.plist"
fi
if [ -e "${PATH_TO_PACKAGE}/Contents/PkgInfo" ]; then
	cp -f "${PATH_TO_PACKAGE}/Contents/PkgInfo" "${RECEIPT_DIR}/${PACKAGE_NAME}/Contents/PkgInfo"
fi
if [ -d "${PATH_TO_PACKAGE}/Contents/Resources" ]; then
	cp -RHf "${PATH_TO_PACKAGE}/Contents/Resources" "${RECEIPT_DIR}/${PACKAGE_NAME}/Contents/"
fi

true
