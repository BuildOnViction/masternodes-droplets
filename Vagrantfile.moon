# -*- mode: ruby -*-
# vi: set ft=ruby :
require 'json'

appConfig = JSON.parse(File.read('config.json'))

Vagrant.configure('2') do |config|

    config.vm.define 'moon' do |config|
        envFile = '.env.moon'
        f = File.new(envFile, 'w')
        f.write('PRIVATE_KEY_MOON=' + appConfig['coinbasePrivateKeyMoon'] + "\n")
        f.write('MAIN_IP=' + appConfig['mainPublicIp'] + "\n")
        f.write('NETWORK_ID=' + appConfig['networkId'].to_s + "\n")
        f.write('VERBOSITY=' + appConfig['verbosity'].to_s + "\n")
        f.close    

        config.vm.provider :digital_ocean do |provider, override|
            override.ssh.private_key_path = '~/.ssh/id_rsa'
            override.vm.box = 'digital_ocean'
            override.vm.box_url = "https://github.com/devopsgroup-io/vagrant-digitalocean/raw/master/box/digital_ocean.box"
            override.nfs.functional = false
            provider.ssh_key_name = "thanhson1085"
            provider.token = appConfig['doApiToken']
            provider.image = 'ubuntu-16-04-x64'
            provider.region = 'sgp1'
            provider.size = '8gb'
        end

        config.vm.synced_folder ".", "/vagrant", type: "rsync",
            rsync__exclude: ".git/"

        config.vm.provision "file", source: envFile, destination: "/vagrant/.env"

        config.vm.provision "shell", inline: <<-SHELL
            apt-get update && apt-get install -y build-essential git wget
            wget https://dl.google.com/go/go1.10.4.linux-amd64.tar.gz && tar -xvf go1.10.4.linux-amd64.tar.gz && mv go /usr/local
            export PATH=$PATH:/usr/local/go/bin 
            echo "export PATH=$PATH:/usr/local/go/bin" >> /root/.bashrc
            mkdir -p ${HOME}/go/src/github.com/ethereum/
            cd ${HOME}/go/src/github.com/ethereum/ && git clone https://github.com/tomochain/tomochain.git go-ethereum
            cd ${HOME}/go/src/github.com/ethereum/go-ethereum && make all
            cd /vagrant
            nohup bash ./moon.sh<&- &>/vagrant/moon.log &
        SHELL
    end

end
