#!/bin/bash

SCRIPTPATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
echo "$SCRIPTPATH"

pack install-app json-schema
pack install-app idris2-python
pack install-deps *.ipkg

idris2-python --build "$SCRIPTPATH/../idris2-jupyter.ipkg"
jupyter kernelspec install --user "$SCRIPTPATH/../Idris2Jupyter/"
export PYTHONPATH="$SCRIPTPATH/../build/exec:$(pack libs-path)"

jupyter notebook
