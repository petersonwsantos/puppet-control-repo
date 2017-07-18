#/bin/bash

sed -i s/^SELINUX=.*$/SELINUX=disabled/ /etc/selinux/config
setenforce 0
echo "||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||"
echo "get tags values"
INSTANCE_ID=$(curl -s -w '\n' http://169.254.169.254/latest/meta-data/instance-id/)
EC2_AZ=$(curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone)
EC2_REGION="`echo \"$EC2_AZ\" | sed -e 's:\([0-9][0-9]*\)[a-z]*\$:\\1:'`" 
CODE_COMMIT=$(aws ec2 describe-instances --region $EC2_REGION --instance-ids $INSTANCE_ID --query "Reservations[*].Instances[*].Tags[?Key=='codecommit'].Value" --output text )
REPO_PUPPET=$(aws ec2 describe-instances --region $EC2_REGION --instance-ids $INSTANCE_ID --query "Reservations[*].Instances[*].Tags[?Key=='puppet_repo'].Value" --output text )
PUPPET_ROLE=$(aws ec2 describe-instances --region $EC2_REGION --instance-ids $INSTANCE_ID --query "Reservations[*].Instances[*].Tags[?Key=='puppet_profile'].Value" --output text )

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
