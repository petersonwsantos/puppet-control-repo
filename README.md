AWS USERDATA WITH PUPPETLABS AGENT  
====================================

Script Running Commands on Your Linux Instance at Launch
----------------------------------------------------------

When you launch an instance in Amazon EC2, you have the option of passing user data to the instance that can be used to perform common automated configuration tasks and even run scripts after the instance starts. 

You can also pass this data into the launch wizard as plain text, as a file (this is useful for launching instances using the command line tools), or as base64-encoded text (for API calls).


IAM RoLe:
```json
  {
      "Version": "2012-10-17",
      "Statement": [
          {
              "Sid": "Stmt1497632792000",
              "Effect": "Allow",
              "Action": [
                  "ec2:DescribeInstances",
                  "ec2:DescribeTags"
              ],
              "Resource": [
                  "*"
              ]
          },
          {
              "Sid": "Stmt1497632920000",
              "Effect": "Allow",
              "Action": [
                  "codecommit:BatchGetRepositories",
                  "codecommit:Get*",
                  "codecommit:GitPull",
                  "codecommit:List*"
              ],
              "Resource": [
                  "arn:aws:codecommit:us-east-2:210177016610:aws-puppet-masterless-distribuited"
              ]
          }
      ]
  }
```

Userdata: 
```bash
#!/bin/bash 

# 'Y' to AWS code commit and "N" to other public git
CODE_COMMIT="Y"
# Repository Puppet Serverless
REPO_PUPPET="https://git-codecommit.us-east-2.amazonaws.com/v1/repos/aws-puppet-masterless-distribuited" 

curl https://raw.githubusercontent.com/petersonwsantos/puppet-repo-aws/master/userdata-puppetagent.bash | bash -s -- $CODE_COMMIT $REPO_PUPPET
```

