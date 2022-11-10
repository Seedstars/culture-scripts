#!/usr/bin/env bash

curl https://raw.githubusercontent.com/Seedstars/culture/master/code/validation/2022.11/tsconfig.json > tsconfig.json
curl https://raw.githubusercontent.com/Seedstars/culture/master/code/validation/2022.11/prettierrc.js > .prettierrc.js
curl https://raw.githubusercontent.com/Seedstars/culture/master/code/validation/2022.11/eslintrc.js > .eslintrc.js

python scripts/semgrep_rules.py -r javascript typescript -v 2022.07
