#!/usr/bin/env bash

set -e

# validate static analysis rules from semgrep
semgrep --strict --error --config .semgrep_rules.yml src/

# javascript static analysis
./node_modules/.bin/eslint -c .eslintrc -f junit src/static tests/js

# scss static analysis
./node_modules/.bin/sass-lint -f junit --verbose --no-exit
