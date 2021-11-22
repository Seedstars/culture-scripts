#!/usr/bin/env bash

curl https://raw.githubusercontent.com/Seedstars/culture/master/code/validation/2021.09/prospector.yml > .prospector.yml
curl https://raw.githubusercontent.com/Seedstars/culture/master/code/validation/2021.09/coveragerc > .coveragerc

python scripts/semgrep_rules.py -r python
