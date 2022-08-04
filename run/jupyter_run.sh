#!/bin/bash

# We install the json-schema and idris2-python apps first. 
pack install-app json-schema
pack install-app idris2-python
# Next, we install the dependencies of dummy.ipkg, an .ipkg file which will be read by Idris when invoked by the jupyter kernel. This file must list all necessary dependencies, including the one to vegatest, otherwise we won't be able to run :module VegaTest.
pack install-deps dummy.ipkg
# We now run idris2-python to build idris2-jupyter.ipkg. Since pack installed idris2-python, it generated a wrapper script around the executable, so idris2-python has access to all packages installed by pack. 
idris2-python --build ../idris2-jupyter.ipkg
# Next we register the idris2-jupyter kernel/thing and export the $PYTHONPATH. The stuff from lib/Idris2Python/module_template will be available via pack `libs-path`. 
jupyter kernelspec install --user ../Idris2Jupyter/

export PYTHONPATH="../build/exec:$(pack libs-path)"
# Finally, we start the jupyter notebook. As confirmed by @Madman Bob , Idris will be invoked from the current directory, so the wrapper script being invoked will make all packages installed by pack available to it (the ones in the current scope).
jupyter notebook
