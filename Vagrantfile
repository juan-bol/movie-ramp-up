VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

    os = "bento/ubuntu-18.04"
    net_ip = "192.158.1"

    servers = [
        {
            :hostname => "api",
            :ip => ".1",
            :ssh_port => "2201",
            :provision_file => "./api.sh"
        },
        {
            :hostname => "ui",
            :ip => ".2",
            :ssh_port => "2202",
            :provision_file => "./ui.sh"
        }
    ]

    servers.each do |machine|
        config.vm.define machine[:hostname] do |node|
            node.vm.box = "#{os}"
            node.vm.hostname = machine[:hostname]
            node.vm.network "private_network", ip: "#{net_ip}" + machine[:ip]
            node.vm.network "forwarded_port", guest: 22, host: machine[:ssh_port], id: "ssh"
            node.vm.synced_folder "./data", "/home/vagrant/data"
            node.vm.provision "shell", path: machine[:provision_file]

            node.vm.provider :virtualbox do |vb|
                vb.memory = "1204"
                vb.cpus = 1
            end
        end
    end

end