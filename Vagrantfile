VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

    os = "peru/ubuntu-18.04-server-amd64"
    net_ip = "192.168.100"

    servers = [
        # {
        #     :hostname => "api",
        #     :ip => ".11",
        #     :ssh_port => "2201",
        #     :provision_file => "./provision/api.sh"
        # },
        # {
        #     :hostname => "ui",
        #     :ip => ".12",
        #     :ssh_port => "2202",
        #     :provision_file => "./provision/ui.sh"
        # },
        {
            :hostname => "bd",
            :ip => ".13",
            :ssh_port => "2203",
            :provision_file => "./provision/bd.sh"
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
                vb.memory = "512"
                vb.cpus = 1
            end
        end
    end

end