# Deploy scripts and helpers

This folder contains :

## provisioning : filled with ansible playbooks and a inventory to test the playbooks locally via vagrant
Folder provisioning\mertical2 is a local copy of the ansible playbooks stored in the devops360 repository.
This folder should ALWAYS be inline with the devops360 repository.

## test-locally : Vagrant configuration to test the ansible playbooks
The Vagrant configuration uses a hyper-v box and can run under windows 10 together with "Docker for Windows"

Prerequisites
- Installed Windows Subsystem for Linux - Ubuntu (https://docs.microsoft.com/en-us/windows/wsl/install-win10)
- Install docker client inside the Ubunto Bash (https://nickjanetakis.com/blog/setting-up-docker-for-windows-and-wsl-to-work-flawlessly)
- Installed Docker for windows (https://docs.docker.com/docker-for-windows/install/#start-docker-for-windows)
  - Expose daemon without TLS
  - Share your drive where the sourcecode of this project is located
- Installed Vagrant

Follow these steps to setup:

### 1. Create a 'internal switch' network for the hyperv box
Preperation when you don't have a internal switch which is connected to the internet:
* open hyper-v manager application in windows 10
* click on Virtual Switch Manager at the right side(Actions)
* create a new internal virtual switch, e.g. InternalWithInternet
* Open Control Panel > Network and Sharing Center > Change Adapter settings (on the right)
* Right click on your network interface that is connected to the internet (Ethernet) and click Properties
* Open tab "Sharing" and allow the network adaptor created above (InternalWithInternet) for sharing internet

If everything is correct, the network adaptor "InternalWithInternet" should have the IP address 192.168.137.1. 
Otherwise the Vagrant scripts and the local inventory will not match.

### 2. Start vagrant
Execute 'up.bat' in the deploy\vagranthyperv folder to create 2 empty virtual machines which can be used to deploy.
When you have more than one network adaptors, vagrant will ask you to select one. If that is the case, select the one created above ("InternalWithInternet")

### 3. Start deploying
Open a Bash on Ubuntu on Windows Shell and start execute-deploy-example.sh
This script will build the Dockerfile.deploy and executes it.

### 4. Start testing your deploying
By default, RabbitMQ will not be installed because it is shared across a lot of other applications.
When you want to test your deploy, install RabbitMQ on the "merchant_deploy_app" machine via:

docker run --hostname my-rabbit -p 5672:5672 -p 15672:15672 -e RABBITMQ_DEFAULT_USER=merticalcommand -e RABBITMQ_DEFAULT_PASS=merticalCommandPW! rabbitmq:3.6.2-management

### TroubleShooting
* 'Error applying virtual Switch properties' => restart pc.
* Don't share the VM with DockerNAT!
* Execute .sh script : Permission denied => git update-index --chmod=+x xyz.sh
