#!/bin/bash
set -e
set -x

# Ensure apt is in non-interactive to avoid prompts
export DEBIAN_FRONTEND=noninteractive

apt-get update
apt-get -y upgrade --no-install-recommends

package_list="apt-transport-https \
apt-utils \
bzip2 \
ca-certificates \
curl \
dialog \
dirmngr \
fonts-liberation \
g++ \
gcc \
git \
gnupg2 \
htop \
init-system-helpers \
iproute2 \
jq \
less \
libc6 \
libgcc1 \
libglib2.0-0 \
libgssapi-krb5-2 \
libicu[0-9][0-9] \
libkrb5-3 \
liblttng-ust[0-9] \
libsm6 \
libstdc++6 \
libxext6 \
libxrender1 \
locales \
lsb-release \
lsof \
man-db \
manpages \
manpages-dev \
nano \
ncdu \
net-tools \
openssh-client \
openssh-server \
pandoc \
procps \
psmisc \
rsync \
run-one \
strace \
sudo \
tini \
unzip \
vim-tiny \
wget \
zip \
zlib1g \
zsh"

echo "Packages to verify are installed: ${package_list}"
apt-get -y install --no-install-recommends ${package_list} 2> >( grep -v 'debconf: delaying package configuration, since apt-utils is not installed' >&2 )

echo "en_US.UTF-8 UTF-8" > /etc/locale.gen
locale-gen

# Create or update a non-root user to match UID/GID.
echo "auth requisite pam_deny.so" >> /etc/pam.d/su
sed -i.bak -e 's/^%admin/#%admin/' /etc/sudoers
sed -i.bak -e 's/^%sudo/#%sudo/' /etc/sudoers
useradd -l -m -s $(which zsh) -N -u "${USER_UID}" "${USERNAME}"
echo "${USERNAME} ALL=NOPASSWD: ALL" >> /etc/sudoers

user_rc_path="/home/${USERNAME}"

# Install Oh-My-Zsh
oh_my_install_dir="${user_rc_path}/.oh-my-zsh"
template_path="${oh_my_install_dir}/templates/zshrc.zsh-template"
user_rc_file="${user_rc_path}/.zshrc"
umask g-w,o-w
mkdir -p ${oh_my_install_dir}
git clone --depth=1 \
        -c core.eol=lf \
        -c core.autocrlf=false \
        -c fsck.zeroPaddedFilemode=ignore \
        -c fetch.fsck.zeroPaddedFilemode=ignore \
        -c receive.fsck.zeroPaddedFilemode=ignore \
        "https://github.com/ohmyzsh/ohmyzsh" "${oh_my_install_dir}" 2>&1
echo -e "$(cat "${template_path}")\nDISABLE_AUTO_UPDATE=true\nDISABLE_UPDATE_PROMPT=true" > ${user_rc_file}
cd "${oh_my_install_dir}"
git repack -a -d -f --depth=1 --window=1
cp -rf "${user_rc_file}" "${oh_my_install_dir}" /root
chown -R ${USERNAME}:${group_name} "${user_rc_path}"

echo "Done!"