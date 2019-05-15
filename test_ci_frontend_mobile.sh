#!/usr/bin/env bash

set -e

# validate eslint
./node_modules/.bin/eslint -c .eslintrc -f compact js tests/js 

# finally valitate prettier format
./node_modules/.bin/prettier --config .prettierrc --check "js/**/*.js"
./node_modules/.bin/prettier --config .prettierrc --check "tests/js/**/*.js"
