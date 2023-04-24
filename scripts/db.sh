# declare environment
export ENV=dev

# Set server timezone
timedatectl set-timezone America/New_York
# Set the server locale
localectl set-locale LANG=en_US.UTF-8

# ensure apt is up to date
apt update
apt -y upgrade

# declare variables
ES_VERSION=7.17.1
VAGRANT_HOME=/vagrant
ES_HOME=/etc/elasticsearch

# install Java and ElasticSearch
echo '##### Install Java 11'
apt install -y openjdk-11-jdk
export ES_JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64

# install ElasticSearch
echo '##### Install ElasticSearch'
cd /etc
mkdir elasticsearch
cd elasticsearch
mkdir jvm.options.d
echo 'fetching...'
# supress the output because it prints too many lines
wget https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-$ES_VERSION-linux-x86_64.tar.gz &> /dev/null
wget https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-$ES_VERSION-linux-x86_64.tar.gz.sha512
shasum -a 512 -c elasticsearch-$ES_VERSION-linux-x86_64.tar.gz.sha512 
# unpack
tar -xzf elasticsearch-$ES_VERSION-linux-x86_64.tar.gz
# create log and data folders
mkdir /var/lib/elasticsearch
mkdir /var/log/elasticsearch
# set up groups and permissions
groupadd elasticsearch
useradd elasticsearch -g elasticsearch -p elasticsearch
cd /opt
chown elasticsearch:elasticsearch /var/log/elasticsearch
chown elasticsearch:elasticsearch /var/lib/elasticsearch
chown -R elasticsearch:elasticsearch $ES_HOME
chmod o+x $ES_HOME/
chgrp elasticsearch $ES_HOME/

# @todo
# build Kibana box
# build LogStash box

# install nginx
echo '##### Install nginx'
apt update
apt install -y nginx

# copy scripts / decrypt configs
echo '##### Copy configs'
mkdir /root/scripts
mkdir /etc/systemd/system/elasticsearch.service.d
scripts=("env_$ENV.sh" "decrypt.sh" "copy_configs.sh")
for file in "${scripts[@]}"; do
    cp $VAGRANT_HOME/scripts/$file /root/scripts/
    chmod -R 700 /root/scripts/$file    
done
# copy configs
/root/scripts/copy_configs.sh

# clean up
echo '##### Clean up'
rm $ES_HOME/elasticsearch-$ES_VERSION-linux-x86_64.tar.gz*

# set up the firewall
ufw allow ssh
ufw allow 9200 # ElasticSearch
ufw --force enable

# start services
systemctl enable elasticsearch
systemctl daemon-reload
echo '##### Start services'
systemctl start nginx
systemctl start elasticsearch

echo "Server build complete: $(date)"
# reboot to apply updates and test failure recovery
reboot
