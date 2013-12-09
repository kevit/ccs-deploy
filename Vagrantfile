# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.box = "wheezy-chef"
  config.vm.host_name = "example.com"
  config.vm.network :private_network, ip: "192.168.33.13"

  config.vm.provision :shell, :inline => "echo 'nameserver 8.8.8.8' > /etc/resolv.conf"
   VAGRANT_JSON = JSON.parse(Pathname(__FILE__).dirname.join('nodes', 'vagrant.json').read)
   config.vm.provision :chef_solo do |chef|
     chef.cookbooks_path = ["site-cookbooks", "cookbooks"]
     chef.roles_path = "roles"
     chef.data_bags_path = "data_bags"
     chef.run_list = VAGRANT_JSON.delete('run_list')
     chef.json = VAGRANT_JSON
     chef.provisioning_path = "/tmp/vagrant-chef"
   end

end
