: "${ENVIRONMENT?Need to set ENVIRONMENT, possible values are 'systemsdev' or 'systemstest'}"
: "${PLAYBOOK_PATH?Need to set PLAYBOOK_PATH, this is the path of the ansible playbooks.}"
: "${PLAYBOOK_FILENAME?Need to set PLAYBOOK_FILENAME, this is the filename of the ansible playbook.}"
: "${PLAYBOOK_REQUIREMENTS_TEMPLATE?Need to set PLAYBOOK_REQUIREMENTS_TEMPLATE, this is the filename of the ansible galaxy requirements template .yml file.}"
: "${GITLAB_KEY?Need to set GITLAB_KEY, this is the location of the ssh rsa private key to connect to the ansible galaxy repository.}"
: "${DEPLOY_KEY?Need to set DEPLOY_KEY, this is the location of the ssh rsa private key to connect to the remote machines we want to deploy on.}"
: "${WORKSPACE?Need to set WORKSPACE, this is the workspace of the runner, normally provided by Jenkins.}"

export GitLabDevops360Host="10.36.10.22"

#Overwrite the homedir provided by Jenkins, because writing to that folder is not allowed
HOME=/home/jenkins

echo Starting deploy with the following parameters:
echo "ENVIRONMENT=" $ENVIRONMENT
echo "EXTRA_VARS=" $EXTRA_VARS
echo "------------------------------------------------"

echo "Using ansible version:"
ansible-playbook --version

# Create .ssh folder with limited access rights
mkdir -p $HOME/.ssh
chmod ugo-rwx,u+rwx $HOME/.ssh

# Disable StrictHostKeyChecking
echo "Host *" >> ~/.ssh/config
echo "StrictHostKeyChecking no" >> ~/.ssh/config

#############################################
##### Install roles from Ansible Galaxy #####
#############################################

# Start the ssh-agent
eval "$(ssh-agent)" && ssh-agent -s

# Add the ssh rsa key to connect to the Ansible Galaxy (git) repository
cp $GITLAB_KEY ~/.ssh/id_rsa_gitlab
chmod ugo-rwx,u+r ~/.ssh/id_rsa_gitlab
ssh-add ~/.ssh/id_rsa_gitlab

# Add GitLabDevops360 host to known hosts
ssh-keyscan -t rsa -H $GitLabDevops360Host >> $HOME/.ssh/known_hosts
ssh-keygen -R $GitLabDevops360Host
 
# Use playbook location and inventory from devops360 repository
export PLAYBOOK_PATH=$WORKSPACE/$PLAYBOOK_PATH
export INVENTORY_PATH=$WORKSPACE/devops360repo/environments/$ENVIRONMENT/inventory  

# Set the IP address of ansible-galaxy repository to the temporary requirements file
cp $PLAYBOOK_PATH/$PLAYBOOK_REQUIREMENTS_TEMPLATE $PLAYBOOK_PATH/requirements.tmp.yml
sed -i -- 's/\[\[githost_placeholder\]\]/'$GitLabDevops360Host'/g' $PLAYBOOK_PATH/requirements.tmp.yml

echo "------------------------------------------------"
echo "Getting roles from ansible galaxy"
cd $PLAYBOOK_PATH

ansible-galaxy install -r $PLAYBOOK_PATH/requirements.tmp.yml

# Remove the temporary requirements file
rm $PLAYBOOK_PATH/requirements.tmp.yml

#############################################
##### Install application with Ansible  #####
#############################################

echo "------------------------------------------------"
echo "Deploying with ansible inventory" $INVENTORY_PATH "and playbook path" $PLAYBOOK_PATH $PLAYBOOK_FILENAME

# Add the ssh rsa key to connect to the remote machines
cp $DEPLOY_KEY ~/.ssh/id_rsa_deploy
chmod ugo-rwx,u+r ~/.ssh/id_rsa_deploy
ssh-add ~/.ssh/id_rsa_deploy

ansible-playbook -i $INVENTORY_PATH $PLAYBOOK_PATH/$PLAYBOOK_FILENAME --extra-vars "$EXTRA_VARS"
