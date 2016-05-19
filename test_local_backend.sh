#!/usr/bin/env bash

py.test -n 8 --nomigrations --reuse-db --cov=src --cov-report=html tests/python/
