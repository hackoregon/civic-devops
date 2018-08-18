# Uploading files to AWS S3 less than 5GB in size

Although the AWS CLI can be used for this, the easiest means to upload files to AWS S3 that are less than 5GB in size is to use the S3 console.

To access the S3 console, login to the Hack Oregon account console (https://hacko.signin.aws.amazon.com/console) as a user that has S3 read/write privileges.  Hack Oregon project leads should have this access.

On upper left of console click the services dropdown and select S3 under Storage to bring up the S3 console. The Hack Oregon S3 bucket list will be displayed. Click on the `hacko-data-archive` bucket to display the list of sub-folders.

Click on your projects archive folder (e.g. 2018-transportation-systems ) - you will see a list of files that exist in the folder.  Make sure the name of the file(s) you are going to upload do not conflict with any existing files as you will overwrite the existing file(s).

In the upper left click the Upload button and the Upload wizard will appear. Here you can drag and drop a file or use the Add files button to browse for a file to upload. Make sure the file is named the way you want (and will not overwrite an existing file in the S3 folder) before adding a file to the wizard screen.

Once you have selected you file, the file size will be displayed.  Make sure it is not over or close to 5GB as this method will not work for files over 5 GB. Once you are ready to upload, click the Next buttons to accept the Default settings (do not change these unless instructed to by a DevOps member) until the Upload button is displayed in the lower right corner.

You will be returned to the S3 console and may need to click the Refresh button in the upper right (circular arrows) to view the file. Clicking on the file name will display information about the file.

Do not use the Properties, Permissions tabs to change anything, or click the Make Public button, unless directed to by a DevOps team member. You or those project members who have read permission to S3 can use this page to download a copy to their workstation using the Open, Download, Download as buttons.

The Link at the bottom of the page is only usable by AWS services that have S3 permissions, or for public access (only when file permission has been changed to public access, which should not be done without prior permission from DevOps team).
