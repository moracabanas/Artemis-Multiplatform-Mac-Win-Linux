#!/bin/sh

set -eu

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname "$0")" && pwd)
SOURCE_ROOT=$(CDPATH= cd -- "$SCRIPT_DIR/../.." && pwd)

fail()
{
	echo "$1" 1>&2
	exit 1
}

git -C "$SOURCE_ROOT" diff-index --quiet HEAD -- || fail "Source archives must not have unstaged changes!"

BUILD_ROOT=$SOURCE_ROOT/build
ARCHIVE_FOLDER=$BUILD_ROOT/source
VERSION=`cat "$SOURCE_ROOT/app/version.txt"`

echo Cleaning output directories
rm -rf $ARCHIVE_FOLDER
mkdir -p $BUILD_ROOT
mkdir -p $ARCHIVE_FOLDER

"$SOURCE_ROOT/scripts/git-archive-all.sh" --format tar.gz "$ARCHIVE_FOLDER/ArtemisSrc-$VERSION.tar.gz" || fail "Archive failed"

echo Archive successful
