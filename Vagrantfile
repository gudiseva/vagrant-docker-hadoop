# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  #config.vm.box = "wesmcclure/ubuntu1404-docker"
  config.vm.box = "geerlingguy/ubuntu1604"  
  config.vm.provision "docker"
  config.vm.box_check_update = true
  #config.vm.network "private_network", type: "dhcp"
  config.vm.provision "shell", path: "install.hadoop.sh", privileged: false
  config.vm.synced_folder "src/", "/srv/website", disabled: false

  config.vm.provider :virtualbox do |vb|
    vb.customize ["modifyvm", :id, "--cpus", "1", "--memory", "1536"]
  end

  config.vm.define "hadoop-nn1" do |master|
      master.vm.hostname = "hadoop-nn1"
      master.vm.network "private_network", ip: "172.20.20.61"
  end

  config.vm.define "hadoop-nn2" do |standby|
    standby.vm.hostname = "hadoop-nn2"
    standby.vm.network "private_network", ip: "172.20.20.62"
  end

  (1..2).each do |i|
    config.vm.define "hadoop-dn#{i}" do |slave|
      slave.vm.hostname = "hadoop-dn#{i}"
      slave.vm.network "private_network", ip: "172.20.20.4#{i}"
    end
  end

end
