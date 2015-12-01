Vagrant.configure(2) do |config|
  config.vm.box = "ubuntu/precise64"
  config.vm.provision :shell, :path => "vagrant/bootstrap.sh"
  config.vm.network "private_network", ip: "10.11.12.13"
  #config.vm.network :forwarded_port, host: 8080, guest: 80
  #config.vm.network :forwarded_port, host: 9200, guest: 9200
  config.vm.provider "virtualbox" do |v|
    v.memory = 1024
    v.gui = false
  end
end
