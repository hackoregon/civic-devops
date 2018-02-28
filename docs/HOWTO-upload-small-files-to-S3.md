# Upload files to S3 less than 5GB in size

Although the AWS CLI can be used for this, the easiest means to upload to S3, files that are less than 5GB in size is to use the S3 console.

To access the S3 console, login to the Hack Oregon accountconsole as a user that has S3 read/write privileges <https://hacko.signin.aws.amazon.com/console> project leads should have this access.

On upper left of console click the services dropdown andselect S3 under Storage to bring up the S3 console. The Hack Oregon S3 bucketlist will be displayed. Click on the hacko-archive bucket to display the listof sub-folders. 

Click on your projects archive folder ( I.e. 2018-transportation-systems ), you will see a list of files that exist in the folder (make sure the name of the file(s) you are going to upload do not conflict with any existing files as you will overwrite the existing file(s)). 

In the upper left click the Upload button and the Uploadwizard will appear. Here you can drag and drop a file or use the Add filesbutton to browse for a file to upload. Make sure the file is named the way youwant and will not overwrite an existing file in the S3 folder before adding afile to the wizard screen.

Once you have selected you file, the file size will bedisplayed, make sure it is not over or close to 5GB as this method should notbe used for files over or near that size. Once you are ready to upload, clickthe Next buttons to accept the Default settings (do not change these unlessinstructed to by a DevOps member) until the Upload button is displayed in thelower right corner.

You will be returned to the S3 console and may need to clickthe Refresh button in the upper right (circular arrows) to view the file.Clicking on the file name will display information about the file.

Do not use the Properties, Permissions tabs to changeanything ore click the Make Public button unless directed to by a DevOps team member.You or project members who have read permission to S3 can use this page todownload a copy to their workstation using the Open, Download, Download asbuttons.

The Link at the bottom of the page is only usable by AWS services that have S3 permissions or for public access (only when file permission has been changed to public access, which should not be done without prior permission from DevOps team)