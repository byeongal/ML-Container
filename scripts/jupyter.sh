#!/bin/bash
set -e
set -x

package_list="jupyter_core \
notebook \
jupyterhub \
jupyterlab \
jupyter_contrib_nbextensions \
webcolors \
uri-template \
jsonpointer \
isoduration \
fqdn \
ipywidgets"

if [ -x "$(command -v mamba)" ]; then
    mamba install --quiet --yes ${package_list}
else
    conda install --quiet --yes ${package_list}
fi

jupyter notebook --generate-config
jupyter contrib nbextension install --user