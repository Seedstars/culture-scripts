#!/usr/bin/env bash

set -e

# javascript static analysis
./node_modules/.bin/eslint -c .eslintrc -f junit js tests/js 
