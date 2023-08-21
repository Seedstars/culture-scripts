#!/usr/bin/env bash

# exit on first non zero return status
set -e

# ensure tee passes the error of the test tool
# https://stackoverflow.com/questions/6871859/piping-command-output-to-tee-but-also-save-exit-code-of-command
set -o pipefail

# validate static analysis rules from semgrep
semgrep --timeout 60 --strict --error --config .semgrep_rules.yml --junit-xml -o report_semgrep.xml src

# validate eslint
./node_modules/.bin/eslint -c .eslintrc.js  -f junit 'src/**/*.{tsx,ts}' |& tee report_eslint.xml

# finally valitate prettier format
./node_modules/.bin/prettier --config .prettierrc.js --check 'src/**/*.{tsx,ts}'

# validate ts typing 
./node_modules/.bin/tsc --noEmit --project tsconfig.json | npx typescript-xunit-xml | tee report_typescript.xml