AWS(EC2 userdata / CodeCommit ) and Puppet Serverless  
======================================================

EC2 Userdata
---------------
When you launch an instance in Amazon EC2, you have the option of passing user data to the instance that can be used to perform common automated configuration tasks and even run scripts after the instance starts. 

The script **userdata-puppetagent.bash** install puppet-agent and applies the settings according with tag **puppet_profile** of  instance EC2.


**Step 1:** Create an AWS CodeCommit Repository

**Step 2:** Create Role for clone CodeCommit repository and get tag EC2

  **IAM RoLe**   (for clone CodeCommit repository and get tag EC2):
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
                    "codecommit:List*"
                ],
                "Resource": [
                    "arn:aws:codecommit:us-east-2:210177016610:aws-puppet-masterless-distribuited"
                ]
            }
        ]
    }
  ```
**Step 3:**  Launch EC2 Instance (with IAM Role and tag  name=puppet_profile/key=essential_linux ) 

  **Userdata:** 
  ```bash
  #!/bin/bash 

  # 'Y' to AWS code commit and "N" to other public git repo
  CODE_COMMIT="Y"
  # Repository Puppet Serverless
  REPO_PUPPET="https://git-codecommit.us-east-2.amazonaws.com/v1/repos/aws-puppet-serverless-distribuited" 

  curl https://raw.githubusercontent.com/petersonwsantos/puppet-repo-aws/master/userdata-puppetagent.bash | bash -s -- $CODE_COMMIT $REPO_PUPPET
  ```

