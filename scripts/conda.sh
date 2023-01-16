#!/bin/bash
set -e
set -x

CONDA_INSTALL_PATH=${1:-"/opt/conda"}
PYTHON_VERSION=${2:-"default"}

echo ${CONDA_INSTALL_PATH}
mkdir -p ${CONDA_INSTALL_PATH}
chown ${USERNAME}:root ${CONDA_INSTALL_PATH}
echo "Downloading Anaconda..."
su --login -c "wget -q https://github.com/conda-forge/miniforge/releases/latest/download/Mambaforge-$(uname)-$(uname -m).sh -O /tmp/anaconda-install.sh && /bin/bash /tmp/anaconda-install.sh -u -b -p ${CONDA_INSTALL_PATH}" ${USERNAME} 2>&1  \
rm /tmp/anaconda-install.sh
ln -s ${CONDA_INSTALL_PATH}/etc/profile.d/conda.sh /etc/profile.d/conda.sh

if [[ "${PYTHON_VERSION}" != "default" ]]; then
    if [ -x "$(command -v mamba)" ]; then
        mamba install --quiet --yes python="${PYTHON_VERSION}"
    else
        conda install --quiet --yes python="${PYTHON_VERSION}"
    fi
fi

export SNIPPET="export PATH=\$PATH:\$HOME/.local/bin"
. ${CONDA_INSTALL_PATH}/etc/profile.d/conda.sh
conda activate base

echo "$SNIPPET" | tee -a /root/.bashrc >> /home/${USERNAME}/.bashrc
echo "$SNIPPET" | tee -a /root/.zshrc >> /home/${USERNAME}/.zshrc

find ${CONDA_INSTALL_PATH}/ -follow -type f -name '*.a' -delete
find ${CONDA_INSTALL_PATH}/ -follow -type f -name '*.js.map' -delete