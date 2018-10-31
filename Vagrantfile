# -*- mode: ruby -*-
# vi: set ft=ruby :
require 'json'

appConfig = JSON.parse(File.read('config.json'))
nodes = appConfig['nodes']

Vagrant.configure('2') do |config|

    nodes.each do |node|
        config.vm.define node['name'] do |config|
            envFile = '.env.' + node['name']
            f = File.new(envFile, 'w')
            f.write('OWNER_PRIVATE_KEY=' + node['ownerPrivateKey'] + "\n")
            f.write('COINBASE_PRIVATE_KEY=' + node['coinbasePrivateKey'] + "\n")
            f.write('COINBASE_ADDRESS=' + node['coinbaseAddress'] + "\n")
            f.close    
            config.vm.provider :digital_ocean do |provider, override|
                override.ssh.private_key_path = '~/.ssh/id_rsa'
                override.vm.box = 'digital_ocean'
                override.vm.box_url = "https://github.com/devopsgroup-io/vagrant-digitalocean/raw/master/box/digital_ocean.box"
                override.nfs.functional = false
                provider.ssh_key_name = "thanhson1085"
                provider.token = appConfig['doApiToken']
                provider.image = 'ubuntu-16-04-x64'
                provider.region = node['region']
                provider.size = '8gb'
            end
            config.vm.synced_folder ".", "/vagrant", disabled: true
            config.vm.provision "file", source: "./apply.sh", destination: "/apply.sh"
            config.vm.provision "file", source: envFile, destination: "/.env"
            config.vm.provision "shell", inline: <<-SHELL
                curl -sSL https://get.docker.com/ | sh
                apt-get update && apt-get install -y python3-pip && pip3 install -U tmn
                (crontab -u root -l; echo "*/2 * * * * bash /apply.sh >> /apply.log 2>&1" ) | crontab -u root -
                source /.env
                tmn start --name anonymous --pkey ${COINBASE_PRIVATE_KEY} --net testnet
            SHELL

        end
    end
end
