#!/usr/bin/env bash

curl https://raw.githubusercontent.com/Seedstars/culture/master/code/validation/2025.05/eslint.config.mjs > eslint.config.mjs
curl https://raw.githubusercontent.com/Seedstars/culture/master/code/validation/2023.03/tsconfig.json > tsconfig.json
curl https://raw.githubusercontent.com/Seedstars/culture/master/code/validation/2023.03/prettierrc.js > .prettierrc.js

python scripts/semgrep_rules.py -r javascript typescript -v 2022.07
