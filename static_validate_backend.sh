#!/usr/bin/env bash

# run black - make sure everyone uses the same python style
black --skip-string-normalization --line-length 120 --check tests
black --skip-string-normalization --line-length 120 --check src

# run isort for import structure checkup with black profile
isort --atomic --profile black -c src
isort --atomic --profile black -c tests

# change to test directory to run all the necessary scripts on the correct path
cd tests || exit 1

# run semgrep
semgrep --timeout 60 --config ../.semgrep_rules.yml .

# back to root of the project
cd ..

# change to src directory to run all the necessary scripts on the correct path
cd src || exit 1

# run django migrations check to ensure that there are no migrations left to create
python manage.py makemigrations --check --dry-run

# run python static validation
prospector  --profile=../.prospector.yml --path=. --ignore-patterns=static

# run bandit - A security linter from OpenStack Security
bandit -r .

# run mypy
mypy .

# run semgrep
semgrep --timeout 60 --config ../.semgrep_rules.yml .
