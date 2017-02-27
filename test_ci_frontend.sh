#!/usr/bin/env bash

set -e

# javascript static analysis
./node_modules/.bin/eslint -c .eslintrc -f junit src/static tests/js

# scss static analysis
./node_modules/.bin/sass-lint -f junit --verbose --no-exit
