#!/bin/bash
set -e

if [ -z "$PASSWORD" ]
then
password="rR3QTtyo9ZfD11dx"
else
password="$PASSWORD"
fi


echo "Set Password ${password}"
echo "${USERNAME}:${password}" 
echo "${USERNAME}:${password}" | sudo chpasswd

echo "Generate ssh key"
mkdir -p "${HOME}/.ssh"
ssh-keygen -t rsa -m pem -N "" <<< $'\ny' >/dev/null 2>&1
echo "- - - - - Pem Key - - - - -"
echo $(cat "${HOME}/.ssh/id_rsa")
echo "- - - - - - - - - - - - - -"

echo "Run SSH Server"
sudo service ssh start

echo "Run Jupyter Server"
notebook_password=$(python -c "from notebook.auth import passwd; print(passwd(passphrase='${password}', algorithm='argon2'))")
jupyter lab --ip=0.0.0.0 --NotebookApp.password $notebook_password &

tail -f /dev/null