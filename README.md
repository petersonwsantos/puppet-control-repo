AWS USERDATA WITH PUPPETLABS AGENT  
====================================

Script Running Commands on Your Linux Instance at Launch
----------------------------------------------------------

When you launch an instance in Amazon EC2, you have the option of passing user data to the instance that can be used to perform common automated configuration tasks and even run scripts after the instance starts. 

You can also pass this data into the launch wizard as plain text, as a file (this is useful for launching instances using the command line tools), or as base64-encoded text (for API calls).



**Usage:**

curl https://raw.githubusercontent.com/petersonwsantos/puppet-repo-aws/master/user-data.sh | sh 
