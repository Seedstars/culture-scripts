#!/usr/bin/env bash

curl https://raw.githubusercontent.com/Seedstars/culture/master/code/validation/2023.03/prospector.yml > .prospector.yml
curl https://raw.githubusercontent.com/Seedstars/culture/master/code/validation/2023.03/coveragerc > .coveragerc

python scripts/semgrep_rules.py -r python -v 2023.03
