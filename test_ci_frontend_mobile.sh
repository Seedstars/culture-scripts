#!/usr/bin/env bash

set -e

# validate static analsys rules from semgrep
semgrep --config=r/typescript  src/
semgrep --config=r/javascript  src/

# validate eslint
./node_modules/.bin/eslint -c .eslintrc.js  -f compact 'src/**/*.{tsx,ts}'

# finally valitate prettier format
./node_modules/.bin/prettier --config .prettierrc.js --check 'src/**/*.{tsx,ts}'
