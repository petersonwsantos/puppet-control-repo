#/bin/bash

CODE_COMMIT="N"
PUPPET_ROLE="linux_essential"

sed -i s/^SELINUX=.*$/SELINUX=disabled/ /etc/selinux/config
setenforce 0

echo "||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||"
echo "Installing puppet agent"
yum install -y  http://yum.puppetlabs.com/puppetlabs-release-pc1-el-7.noarch.rpm
yum install  puppet-agent-1.9.0-1.el7 -y 

cat > /etc/puppetlabs/code/hiera.yaml <<EOF
---
version: 5
hierarchy:
  - name: "OS values"
    path: "%{facts.os.family}.yaml"
  - name: "Common values"
    path: "common.yaml"
defaults:
  data_hash: yaml_data
  datadir: hieradata
EOF

echo "||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||"
echo "Installing curl for CodeCommit"
rpm -Uvh http://www.city-fan.org/ftp/contrib/yum-repo/rhel7/x86_64/city-fan.org-release-1-13.rhel7.noarch.rpm
yum update libcurl -y ENABLEREPO=city-fan.org

echo "||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||"
echo "Config CodeCommit"	
if [ $CODE_COMMIT = "Y" ]; then
	aws configure set region $EC2_REGION
	git config --system credential.https://git-codecommit.us-east-2.amazonaws.com.helper '!aws --profile default codecommit credential-helper $@'
	git config --system credential.https://git-codecommit.us-east-2.amazonaws.com.UseHttpPath true
fi 

echo "||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||"
echo "Clone Puppet repository "
rm -rfv  /etc/puppetlabs/code/environments/production
mkdir    /etc/puppetlabs/code/environments/production
git clone $REPO_PUPPET /etc/puppetlabs/code/environments/production

echo "||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||"
echo "Puppet - Apply config Role "
echo "node default { include role::$PUPPET_ROLE }" > /etc/puppetlabs/code/environments/production/manifests/site.pp 
/opt/puppetlabs/bin/puppet apply /etc/puppetlabs/code/environments/production/manifests/site.pp
