#!/usr/bin/env bash

curl https://raw.githubusercontent.com/Seedstars/culture/master/code/validation/2021.12/tsconfig.json > tsconfig.json
curl https://raw.githubusercontent.com/Seedstars/culture/master/code/validation/2021.12/prettierrc.js > .prettierrc.js
curl https://raw.githubusercontent.com/Seedstars/culture/master/code/validation/2021.12/eslintrc.js > .eslintrc.js

python scripts/semgrep_rules.py -r javascript typescript
