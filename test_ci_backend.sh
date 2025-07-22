#!/usr/bin/env bash

# exit on first non zero return status
set -e

# ensure tee passes the error of the test tool
# https://stackoverflow.com/questions/6871859/piping-command-output-to-tee-but-also-save-exit-code-of-command
set -o pipefail

# run black - make sure everyone uses same python style
black --skip-string-normalization --line-length 120 --check tests
black --skip-string-normalization --line-length 120 --check src

# run isort for import structure checkup with black profile
isort --atomic --profile black -c src
isort --atomic --profile black -c tests

# run semgrep for tests and src
semgrep --timeout 30 --strict --error --jobs=4  --max-target-bytes=500000 --config .semgrep_rules.yml --exclude=node_modules/,dist/,venv/,virtualenv/ --junit-xml -o report_semgrep.xml src tests 

# change to src directory to run all the necessary scripts on the correct path
cd src || exit 1

# run django migrations check to ensure that there are no migrations left to create
python manage.py makemigrations --check --dry-run

# run mypy
mypy --junit-xml ../report_mypy.xml .

# run bandit - A security linter from OpenStack Security
bandit -r .

# python static analysis
prospector  --profile=../.prospector.yml --path=. --ignore-patterns=static --output-format=xunit |& tee ../report_prospector.xml

# back to root of the project
cd ..

# python tests
py.test -c pytest_ci.ini -x --disable-socket -W error::RuntimeWarning --cov=src --cov-fail-under=100 --junitxml=report_pytest.xml
