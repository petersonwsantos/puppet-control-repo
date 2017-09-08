#/bin/bash

CODE_COMMIT="N"
PUPPET_ROLE="linux_essential"

sed -i s/^SELINUX=.*$/SELINUX=disabled/ /etc/selinux/config
setenforce 0
yum install -y git

echo "||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||"
echo "Installing puppet agent"
yum install -y  http://yum.puppetlabs.com/puppetlabs-release-pc1-el-7.noarch.rpm
yum install -y puppet-agent-1.9.0-1.el7  

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
echo "Clone Puppet repository "
rm -rfv  /etc/puppetlabs/code/environments/production
mkdir    /etc/puppetlabs/code/environments/production
git clone $REPO_PUPPET /etc/puppetlabs/code/environments/production

echo "||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||"
echo "Puppet - Apply config Role "
echo "node default { include role::$PUPPET_ROLE }" > /etc/puppetlabs/code/environments/production/manifests/site.pp 
/opt/puppetlabs/bin/puppet apply /etc/puppetlabs/code/environments/production/manifests/site.pp
