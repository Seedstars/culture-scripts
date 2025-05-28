#!/usr/bin/env bash

set -e

# validate static analysis rules from semgrep
semgrep --strict --error --config .semgrep_rules.yml src/

# validate eslint
./node_modules/.bin/eslint -c eslint.config.mjs -f junit 'src/**/*.{tsx,ts}' |& tee report_eslint.xml

# validate prettier format
./node_modules/.bin/prettier --config .prettierrc.js --check 'src/**/*.{tsx,ts}'

# validate ts typing
./node_modules/.bin/tsc --noEmit --project tsconfig.json | npx typescript-xunit-xml | tee report_typescript.xml
