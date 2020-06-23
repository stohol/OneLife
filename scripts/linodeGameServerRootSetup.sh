source ./commonVariables.sh

# For remote game servers

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



apt-get -o Acquire::ForceIPv4=true update
apt-get -y install emacs-nox mercurial git g++ expect gdb make fail2ban ufw


echo ""
echo ""
echo "Whitelisting only main server for ssh"
echo "Opening port 8005 for game server"
echo ""
echo ""

ufw allow from ${MAIN_SERVER_IP} to any port 22
ufw allow 8005
ufw --force enable

echo ""
echo ""
echo "Setting up custom core file name"
echo ""
echo ""

echo "core.%e.%p.%t" > /proc/sys/kernel/core_pattern

echo "" >> /etc/sysctl.conf
echo "" >> /etc/sysctl.conf
echo "# custom core file name" >> /etc/sysctl.conf
echo "kernel.core_pattern=core.%e.%p.%t" >> /etc/sysctl.conf



echo ""
echo ""
echo "Setting up new user account without a password..."
echo ""
echo ""

useradd -m -s /bin/bash ${USERNAME}


dataName="OneLifeData7"


su ${USERNAME}<<EOSU

cd /home/${USERNAME}

echo "ulimit -c unlimited >/dev/null 2>&1" >> ~/.bash_profile

ulimit -c unlimited

mkdir checkout
cd checkout



echo "Using data repository $dataName"

git clone ${CODE_REPO}
git clone ${DATA_REPO}
git clone ${GEMS_REPO}


cd $dataName

lastTaggedDataVersion=\`git for-each-ref --sort=-creatordate --format '%(refname:short)' --count=1 refs/tags/${TAG_BASE}* | sed -e 's/${TAG_BASE}//'\`


echo "" 
echo "Most recent Data git version is:  \$lastTaggedDataVersion"
echo ""

git checkout -q ${TAG_BASE}\$lastTaggedDataVersion



cd ../OneLife/server

echo "http://onehouronelife.com/ticketServer/server.php" > settings/ticketServerURL.ini

ln -s ../../$dataName/objects .
ln -s ../../$dataName/transitions .
ln -s ../../$dataName/categories .
ln -s ../../$dataName/tutorialMaps .
ln -s ../../$dataName/dataVersionNumber.txt .

git for-each-ref --sort=-creatordate --format '%(refname:short)' --count=1 refs/tags/${TAG_BASE}* | sed -e 's/${TAG_BASE}//' > serverCodeVersionNumber.txt


./configure 1

make

bash -l ./runHeadlessServerLinux.sh

echo -n "1" > ~/keepServerRunning.txt

crontab /home/${USERNAME}/checkout/OneLife/scripts/remoteServerCrontabSource


cd /home/${USERNAME}
mkdir .ssh

chmod 744 .ssh

cd .ssh

echo ${PUB_KEY} > authorized_keys

chmod 644 authorized_keys


exit
EOSU

echo ""
echo "Done with remote setup."
echo ""

