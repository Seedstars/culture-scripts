#!/usr/bin/env bash

# validate static analysis rules from semgrep
semgrep --strict --error --config .semgrep_rules.yml src/

# validate eslint
./node_modules/.bin/eslint -c .eslintrc.js  -f compact 'src/**/*.{tsx,ts}'

# validate prettier format
./node_modules/.bin/prettier --config .prettierrc.js --check 'src/**/*.{tsx,ts}'

# validate ts typing 
./node_modules/.bin/tsc --noEmit --project tsconfig.json