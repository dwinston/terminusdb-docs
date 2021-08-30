#!/bin/bash

BRANCH=$1
FILES="docs/reference/ref.md docs/reference/repository.md docs/reference/system_schema.md docs/reference/woql.md"

DOCS_DIR=$(pwd)
sudo apt install ronn
git clone -b "$1" --single-branch https://github.com/terminusdb/terminusdb
TERMINUSDB_FOLDER="$DOCS_DIR/terminusdb"
cd .ci/jsonToMDConverter
npm i
cd "$TERMINUSDB_FOLDER"
node "$DOCS_DIR/.ci/jsonToMDConverter/script.js" "$DOCS_DIR/reference/"
