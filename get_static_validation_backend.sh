#!/usr/bin/env bash

curl https://raw.githubusercontent.com/Seedstars/culture/master/code/validation/2022.07/prospector.yml > .prospector.yml
curl https://raw.githubusercontent.com/Seedstars/culture/master/code/validation/2022.07/coveragerc > .coveragerc

python scripts/semgrep_rules.py -r python -v 2022.07
