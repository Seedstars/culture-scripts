#!/usr/bin/env bash

set -e

# run black - make sure everyone uses same python style
black --skip-string-normalization --line-length 120 --check tests
black --skip-string-normalization --line-length 120 --check src

# run isort for import structure checkup with black profile
isort --atomic --profile black -c src
isort --atomic --profile black -c tests

# change to src directory to run all the necessary scripts on the correct path
cd src || exit 1

# run django migrations check to ensure that there are no migrations left to create
python manage.py makemigrations --check --dry-run

# run mypy
mypy .

# run bandit - A security linter from OpenStack Security
bandit -r .

# python static analysis
prospector  --profile=../.prospector.yml --path=. --ignore-patterns=static

# run semgrep
semgrep --timeout 60 --strict --error --config ../.semgrep_rules.yml .

# back to root of the project
cd ..

# python tests
py.test -c pytest_ci.ini -x --disable-socket -W error::RuntimeWarning --cov=src --cov-fail-under=100
