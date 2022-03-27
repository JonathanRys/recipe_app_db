    # declare environment
    export ENV=dev

    # ensure apt is up to date
    apt update
    apt -y upgrade

    # declare variables
    ES_VERSION=7.17.1
    VAGRANT_HOME=/home/vagrant

    # install Java and Elasticsearch
    apt install -y openjdk-11-jdk
    export ES_JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64
    # install Elasticsearch
    wget https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-$ES_VERSION-linux-x86_64.tar.gz
    wget https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-$ES_VERSION-linux-x86_64.tar.gz.sha512
    shasum -a 512 -c elasticsearch-$ES_VERSION-linux-x86_64.tar.gz.sha512 
    tar -xzf elasticsearch-$ES_VERSION-linux-x86_64.tar.gz
    
    # install nginx
    apt update
    apt install -y nginx

    # copy/decrypt configs

    # start services
    systemctl start nginx
    $VAGRANT_HOME/elasticsearch-$ES_VERSION/bin/elasticsearch -d -p /tmp/elasticsearch-pid

    # clean up
    rm elasticsearch-$ES_VERSION-linux-x86_64.tar.gz*
