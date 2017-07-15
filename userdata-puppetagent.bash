#/bin/bash

# puppet_profile  essential_linux   

# 'Y' to AWS code commit and "N" to other public git
CODE_COMMIT="$1"

# Repository Puppet Serverless
REPO_PUPPET="$2" 

#INSTANCE_ID=$(curl -s -w '\n' http://169.254.169.254/latest/meta-data/instance-id/)
#EC2_AZ=`curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone`
#EC2_REGION="`echo \"$EC2_AZ\" | sed -e 's:\([0-9][0-9]*\)[a-z]*\$:\\1:'`"


sed -i s/^SELINUX=.*$/SELINUX=disabled/ /etc/selinux/config
setenforce 0
yum update -y
yum install -y epel-release git-core 
yum install -y  http://yum.puppetlabs.com/puppetlabs-release-pc1-el-7.noarch.rpm
yum install puppet-agent -y 

if [ $CODE_COMMIT = "Y" ]; then
echo "pxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
	rpm -Uvh http://www.city-fan.org/ftp/contrib/yum-repo/rhel6/x86_64/city-fan.org-release-1-13.rhel6.noarch.rpm
	yum update libcurl -y ENABLEREPO=city-fan.org
	#yum install awscli -y
	yum update -y
	aws configure set region $EC2_REGION
	git config --system credential.https://git-codecommit.us-east-2.amazonaws.com.helper '!aws --profile default codecommit credential-helper $@'
	git config --system credential.https://git-codecommit.us-east-2.amazonaws.com.UseHttpPath true
fi 

rm /etc/puppetlabs -rfv
git clone $REPO_PUPPET /etc/puppetlabs
PUPPET_ROLE=$(aws ec2 describe-instances --region $EC2_REGION --instance-ids $INSTANCE_ID --query "Reservations[*].Instances[*].Tags[?Key=='puppet_profile'].Value" --output text )
echo "node default { include roles::$PUPPET_ROLE }" > /etc/puppetlabs/code/environments/production/manifests/site.pp 
/opt/puppetlabs/bin/puppet apply /etc/puppetlabs/code/environments/production/manifests/site.pp
