#!/bin/bash

python3 setup.py build_ext && \
python3 runner.py $1