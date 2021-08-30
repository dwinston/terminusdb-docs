#!/bin/bash

BRANCH=$1
FILES="docs/reference/ref.md docs/reference/repository.md docs/reference/system_schema.md docs/reference/woql.md"

DOCS_DIR=$(pwd)
sudo apt install ronn
git clone -b "$1" --single-branch https://github.com/terminusdb/terminusdb
cd terminusdb
TERMINUSDB_FOLDER=$(pwd)
cd src/utils/jsonToMDConverter
npm i
cd "$TERMINUSDB_FOLDER"
make docs
cp $FILES "$DOCS_DIR/reference/"
cd "$DOCS_DIR"
