#!/usr/bin/env bash

curl https://raw.githubusercontent.com/Seedstars/culture/master/code/validation/2022.07/tsconfig.json > tsconfig.json
curl https://raw.githubusercontent.com/Seedstars/culture/master/code/validation/2022.07/prettierrc.js > .prettierrc.js
curl https://raw.githubusercontent.com/Seedstars/culture/master/code/validation/2022.07/eslintrc.js > .eslintrc.js

python scripts/semgrep_rules.py -r javascript typescript -v 2022.07
