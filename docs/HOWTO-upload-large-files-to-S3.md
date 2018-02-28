# Upload of files 5GB or greater to S3

To upload files of this size, it is required to use multi-part upload by AWS. This cannot be done through the S3 console, logged in as a user. The easiest way is to use the AWS CLI (Command Line Interface) which requires installing on a windows or Linux system.

You will need your Hack Oregon AWS user Access Key and Secret Key to configure and use the CLI.

For Windows there are two flavors AWS CLI and Power Shell CLI. Both are similar and found in the same download location. This will describe the process for the AWS CLI.

Go to the AWS CLI documentation page:

<https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-welcome.html>

On the left expand the Install link and click on Windows. You can install via the MSI installer or install Python, PIP and AWS CLI. The MSI is easiest so Download the version for your system (32 or 64 bit) and follow the instructions.

After installation is complete the CLI needs to be configured in order to access the Hack Oregon account on your behalf.  On the AWS CLI documentation page, on the left click on Configuration and use the Quick Configuration process by running the aws configure command on your PC in a command prompt window:

**(replace with your Access Key and Secret Key and keep the rest the same**)

 

$ **aws configure     **

AWS Access Key ID [None]: **AKIAIOSFODNN7EXAMPLE**

AWS Secret Access Key[None]: **wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY**

Default region name [None]:**us-west-2**

Default output format [None]: **json**

You do not need to do any additional setup if you choose. You can test the CLI install and setup by running this command in a command prompt window:

$ `**aws s3 help**`

You should get a list of available S3 commands.

To upload a file from your PC, in a command prompt window, CD to the directory/folder where the file is, make sure the file has the name you want it to have on S3. 

Example: 
To upload the file pgdump.zip to the hacko-archive Bucket and the project folder for your	 2018 transportation systems project:

Note: do not forget the ending ‘ / ‘ on the Bucket/Folder path.

$ aws s3 cp pgdump.zip  s3://hacko-archive/2018-transportation-systems/

