#!/usr/bin/env bash

sudo apt-get update
sudo apt-get upgrade
sudo apt-get install -y software-properties-common
#sudo add-apt-repository ppa:webupd8team/java
#sudo apt-get -y update
#sudo apt-get install -y oracle-java8-installer
sudo apt-get install -y wget unzip tar
sudo apt-get install -y openssh-server
sudo apt-get install -y openssh-client
sudo apt-get install -y openssl bash procps
sudo apt-get install -y ssh rsync
sudo apt-get -y autoremove


cat >> ~/.bashrc <<"END"

NORMAL="\[\e[0m\]"
BOLD="\[\e[1m\]"
DARKGRAY="\[\e[90m\]"
BLUE="\[\e[34m\]"
PS1="$DARKGRAY\u@$BOLD$BLUE\h$DARKGRAY:\w\$ $NORMAL"

END

# Disable IPv6 on all nodes
sudo /bin/su -c "echo 'net.ipv6.conf.all.disable_ipv6 = 1' >> /etc/sysctl.conf"
sudo /bin/su -c "echo 'net.ipv6.conf.default.disable_ipv6 = 1' >> /etc/sysctl.conf"
sudo /bin/su -c "echo 'net.ipv6.conf.lo.disable_ipv6 = 1' >> /etc/sysctl.conf"
sudo sysctl -p
#cat /proc/sys/net/ipv6/conf/all/disable_ipv6

# Disable Firewall
sudo ufw disable
#sudo ufw status

# Remove SE-Linuxl
if false
then

apparmor_status
sudo /etc/init.d/apparmor stop
sudo update-rc.d -f apparmor remove

fi

JAVA_VERSION=8u171

# sudo apt-get remove -y oracle-java8-installer
# wget -O jdk8.tar.gz http://download.oracle.com/otn-pub/java/jdk/${JAVA_VERSION}-b11/512cd62ec5174c3487ac17c61aaa89e8/jdk-${JAVA_VERSION}-linux-x64.tar.gz
sudo cp /vagrant/downloads/jdk-${JAVA_VERSION}-linux-x64.tar.gz .
tar -zxf jdk-${JAVA_VERSION}-linux-x64.tar.gz
sudo chmod +x jdk1.8.0_171
sudo mkdir -p /usr/lib/jvm
sudo mv jdk1.8.0_171 /usr/lib/jvm/jdk1.8.0_171
rm -f jdk-${JAVA_VERSION}-linux-x64.tar.gz

cat >> ~/.bashrc <<"END"

# Set JAVA
export JAVA_HOME=/usr/lib/jvm/jdk1.8.0_171
export PATH=$PATH:$JAVA_HOME/bin

END

HADOOP_VERSION=2.7.3

# wget -O hadoop.tar.gz https://archive.apache.org/dist/hadoop/common/hadoop-${HADOOP_VERSION}/hadoop-${HADOOP_VERSION}.tar.gz
sudo cp /vagrant/downloads/hadoop-${HADOOP_VERSION}.tar.gz .
tar -zxf hadoop-${HADOOP_VERSION}.tar.gz
sudo chmod +x hadoop-${HADOOP_VERSION}
sudo mv hadoop-${HADOOP_VERSION} /usr/local/hadoop
rm -f hadoop-${HADOOP_VERSION}.tar.gz
mkdir -p /tmp/hadoop
mkdir -p /home/vagrant/HA/data/namenode
chmod 755 /home/vagrant/HA/data/namenode
mkdir -p /home/vagrant/HA/data/datanode
chmod 755 /home/vagrant/HA/data/datanode

cat >> ~/.bashrc <<"END"

# Set Hadoop-related environment variables
export HADOOP_HOME=/usr/local/hadoop
export HADOOP_MAPRED_HOME=$HADOOP_HOME
export HADOOP_COMMON_HOME=$HADOOP_HOME
export HADOOP_HDFS_HOME=$HADOOP_HOME
export HADOOP_PREFIX=$HADOOP_HOME
export YARN_HOME=$HADOOP_HOME

export HADOOP_CONF_DIR=$HADOOP_HOME/etc/hadoop
export YARN_CONF_DIR=$HADOOP_HOME/etc/hadoop

# Add Hadoop bin / sbin directories to PATH
export PATH=$PATH:$HADOOP_HOME/sbin:$HADOOP_HOME/bin

END

ZOOKEEPER_VERSION=3.4.11

# wget -O zookeeper.tar.gz http://archive.apache.org/dist/zookeeper/zookeeper-${ZOOKEEPER_VERSION}/zookeeper-${ZOOKEEPER_VERSION}.tar.gz
sudo cp /vagrant/downloads/zookeeper-${ZOOKEEPER_VERSION}.tar.gz .
tar -zxf zookeeper-${ZOOKEEPER_VERSION}.tar.gz
sudo chmod +x zookeeper-${ZOOKEEPER_VERSION}
sudo mv zookeeper-${ZOOKEEPER_VERSION} /usr/local/zookeeper
rm -f zookeeper-${ZOOKEEPER_VERSION}.tar.gz
mkdir -p /home/vagrant/HA/data/zookeeper
chmod 755 /home/vagrant/HA/data/zookeeper
mkdir -p /home/vagrant/HA/data/jn
chmod 755 /home/vagrant/HA/data/jn

cat >> ~/.bashrc <<"END"

# Set Zookeeper-related environment variables
export ZOOKEEPER_HOME=/usr/local/zookeeper

# Add Zookeeper directory to PATH
export PATH=$PATH:$ZOOKEEPER_HOME/bin

END

# cp /vagrant/home/vagrant/.bashrc ~/.bashrc
source ~/.bashrc

# Generate the SSH key in all the nodes
# ssh-keygen -t rsa
echo | ssh-keygen -t rsa -P ''
sudo chmod 700 .ssh/
cd .ssh/
chmod 600 *
cd ..

# On Namenode
cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys
'
ssh-copy-id -i .ssh/id_rsa.pub vagrant@hadoop-nn1
ssh-copy-id -i .ssh/id_rsa.pub vagrant@hadoop-nn2
ssh-copy-id -i .ssh/id_rsa.pub vagrant@hadoop-dn1
ssh-copy-id -i .ssh/id_rsa.pub vagrant@hadoop-dn2
'

# Restart the ssh service in all the nodes
sudo service ssh restart

sudo cp /vagrant/etc/hosts /etc/hosts  # HOSTS FILE NEED REPLACEMENT
# sudo -- sh -c "cat /vagrant/etc/hosts >> /etc/hosts"

# Copy Hadoop and Zookeeper Configurations
cp /vagrant/usr/local/hadoop/etc/hadoop/* /usr/local/hadoop/etc/hadoop/
cp /vagrant/usr/local/zookeeper/conf/* /usr/local/zookeeper/conf/

# In hadoop-nn1
# cp /vagrant/home/vagrant/myid-nn1 /home/vagrant/HA/data/zookeeper/myid

# In hadoop-nn2
# cp /vagrant/home/vagrant/myid-nn2 /home/vagrant/HA/data/zookeeper/myid

# In hadoop-dn1
# cp /vagrant/home/vagrant/myid-dn1 /home/vagrant/HA/data/zookeeper/myid

# In hadoop-dn2
# cp /vagrant/home/vagrant/myid-dn2 /home/vagrant/HA/data/zookeeper/myid

# All Nodes
# hadoop-daemon.sh start journalnode
# zkServer.sh start
# mr-jobhistory-daemon.sh start historyserver
