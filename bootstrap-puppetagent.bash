#/bin/bash

# puppet_profile  essential_linux   
sed -i s/^SELINUX=.*$/SELINUX=disabled/ /etc/selinux/config
setenforce 0


mkdir /scripts
cat > /scripts/aws_get_tags.bash <<EOF
INSTANCE_ID=$(curl -s -w '\n' http://169.254.169.254/latest/meta-data/instance-id/)
EC2_AZ=`curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone`
EC2_REGION="`echo \"$EC2_AZ\" | sed -e 's:\([0-9][0-9]*\)[a-z]*\$:\\1:'`" 
CODE_COMMIT=$(aws ec2 describe-instances --region $EC2_REGION --instance-ids $INSTANCE_ID --query "Reservations[*].Instances[*].Tags[?Key=='codecommit'].Value" --output text )
REPO_PUPPET=$(aws ec2 describe-instances --region $EC2_REGION --instance-ids $INSTANCE_ID --query "Reservations[*].Instances[*].Tags[?Key=='puppet_repo'].Value" --output text )
PUPPET_ROLE=$(aws ec2 describe-instances --region $EC2_REGION --instance-ids $INSTANCE_ID --query "Reservations[*].Instances[*].Tags[?Key=='puppet_profile'].Value" --output text )
EOF
bash /scripts/aws_get_tags.bash

yum install -y  http://yum.puppetlabs.com/puppetlabs-release-pc1-el-7.noarch.rpm
yum install puppet-agent -y 

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

yum update -y
rpm -Uvh http://www.city-fan.org/ftp/contrib/yum-repo/rhel6/x86_64/city-fan.org-release-1-13.rhel6.noarch.rpm
yum update libcurl -y ENABLEREPO=city-fan.org
	
if [ $CODE_COMMIT = "Y" ]; then
	aws configure set region $EC2_REGION
	git config --system credential.https://git-codecommit.us-east-2.amazonaws.com.helper '!aws --profile default codecommit credential-helper $@'
	git config --system credential.https://git-codecommit.us-east-2.amazonaws.com.UseHttpPath true
fi 

rm -rfv  /etc/puppetlabs/code/environments/production
git clone $REPO_PUPPET /etc/puppetlabs/code/environments/production
echo "node default { include roles::$PUPPET_ROLE }" > /etc/puppetlabs/code/environments/production/manifests/site.pp 
/opt/puppetlabs/bin/puppet apply /etc/puppetlabs/code/environments/production/manifests/site.pp
