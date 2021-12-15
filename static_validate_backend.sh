#!/usr/bin/env bash

# run black - make sure everyone uses the same python style
black --skip-string-normalization --line-length 120 --check tests
black --skip-string-normalization --line-length 120 --check src

# run isort for import structure checkup with black profile
isort --atomic --profile black -c src
isort --atomic --profile black -c tests

# run python static validation
prospector --profile-path=. --profile=.prospector.yml --path=src --ignore-patterns=static

# run bandit - A security linter from OpenStack Security
bandit -r src

# run mypy
cd src || exit
mypy .
cd ..

# run semgrep
semgrep --config .semgrep_rules.yml src
