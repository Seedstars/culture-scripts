#!/usr/bin/env bash

curl https://raw.githubusercontent.com/Seedstars/culture/master/code/validation/2022.07/eslintrc > .eslintrc
curl https://raw.githubusercontent.com/Seedstars/culture/master/code/validation/2022.07/prettierrc > .prettierrc
curl https://raw.githubusercontent.com/Seedstars/culture/master/code/validation/2022.07/sass-lint.yml > .sass-lint.yml

python scripts/semgrep_rules.py -r javascript typescript -v 2022.07
