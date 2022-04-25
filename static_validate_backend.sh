#!/usr/bin/env bash

# run black - make sure everyone uses the same python style
black --skip-string-normalization --line-length 120 --check tests
black --skip-string-normalization --line-length 120 --check src

# run isort for import structure checkup with black profile
isort --atomic --profile black -c src
isort --atomic --profile black -c tests

# change to src directory to run all the necessary scripts on the correct path
cd src || exit

# run python static validation
prospector  --profile=../.prospector.yml --path=. --ignore-patterns=static

# run bandit - A security linter from OpenStack Security
bandit -r .

# run mypy
mypy .

# run semgrep
semgrep --config ../.semgrep_rules.yml .
