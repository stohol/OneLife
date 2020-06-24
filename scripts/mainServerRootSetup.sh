#!/bin/bash

source ./commonVariables.sh

# For main management server

# Run as root to perform initial setup and user account creation



echo ""
echo ""
echo "Future root ssh logins will be key-based only, with password forbidden"
echo ""
echo ""


mkdir .ssh

chmod 744 .ssh

cd .ssh

echo ${PUB_KEY} > authorized_keys

chmod 644 authorized_keys

sed -i 's/PermitRootLogin yes/PermitRootLogin without-password/' /etc/ssh/sshd_config

service ssh restart


echo ""
echo ""
echo "Installing packages..."
echo ""
echo ""



add-apt-repository ppa:ondrej/php
apt-get -o Acquire::ForceIPv4=true update
add-apt-repository ppa:ondrej/php
apt-get -y install emacs-nox nginx fail2ban ufw git mysql-server php5.6-fpm php5.6-mysql php5.6 php5.6-curl php-pear php5.6-xml php-elisp



echo ""
echo ""
echo "Opening port 22 for ssh"
echo "Opening port 80 and 443 for web"
echo ""
echo ""

ufw allow 22
ufw allow 80
ufw allow 443
ufw --force enable



echo ""
echo ""
echo "Setting up new user account without a password..."
echo ""
echo ""

useradd -m -s /bin/bash ${USERNAME}


su ${USERNAME}<<EOSU

cd /home/${USERNAME}

mkdir .ssh

chmod 744 .ssh

cd .ssh

echo ${PUB_KEY} > authorized_keys

chmod 644 authorized_keys


cd /home/${USERNAME}

mkdir checkout
cd checkout
git clone ${CODE_REPO}

cd /home/${USERNAME}
mkdir public_html

exit
EOSU


echo ""
echo "Done with main server setup."
echo ""