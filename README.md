twitter_aws
===========

Code for capturing Twitter data with python 2.7.3+ and shell script for transferring files from an EC2 to S3.
Referenced on ERI Wiki

## Introduction

Twitter allows virtually anyone to capture tweets containing certain terms from its live stream for free. &nbsp;The catch to getting this data free of charge is that you must have a program that's continuously listening to the stream and storing the data. &nbsp;If you're not constantly listening and want to obtain past Twitter data, you'll have to use data brokers like gnip or Topsy. &nbsp;In order to utitlize the data from these companies in a meaningful way (i.e. transform and display it), you usually have to pay them a hefty fee. &nbsp;Thus, a cheap solution may be to capture the data yourself. &nbsp;The problem is that you have to have a reliable machine always running. &nbsp;This is where Amazon Web Services' EC2 Computing comes in handy. &nbsp;You can spin-up a "free-tier" instance of your choice in Amazon's Cloud and keep it running for one year with no charge. Additionally, you can send the data you capture over to Amazon's S3 storage, which allows you to keep up to 20gb of data free of charge and access it from from anywhere with the correct login credentials.<br> 

<br> 

### Required Logins/Tools (for Windows Computers):

*AWS login credentials (create an account [http://aws.amazon.com/ here]) 
*Twitter API keys (get a Twitter account, go [http://dev.twitter.com here], and follow [https://www.youtube.com/watch?v=TKbHlofCtsE this video demonstration]) 
*Python 2.7.3+ (no 3.x for the code used here) 
*All files referenced below can be found in this [https://github.com/zbeaver4/twitter_aws GitHub Repo] 
*FileZilla (in order to transfer files to your EC2 instance) 
*Putty (to SSH into your EC2 instance)

## Creating a Python Script for Data Capture

To run the Twitter data capture, you'll need to edit the following two files, located in the GitHub Repo: 

"streaming.py:"

*This is the file that does the actual Twitter capture and logging 
*Open the file and edit the 'keywords' list, adding the terms or phrases you want to capture in tweets; this list is not case-sensitive and word order for each element in the list is irrelevant (i.e. "ThIs phraSE" filters the same tweets as "phrase this").

<br> 

"credentials.py:"

*This file contains your Twitter authentication credentials 
*Open the file and insert the appropriate credentials for your Twitter account

<br> 

You're done! 

## Creating an S3 Bucket

S3 is AWS's Simple Storage Service, which will hold all of the tweets you capture. &nbsp;S3 Storage units are referred to as "buckets." Here are the steps for creating your Twitter bucket: 

* Sign into your AWS account and click on the dropdown "Services" box in the upper left hand corner of the screen. 
* Click on S3 
* Click on the blue "Create Bucket" button. 
* Name your bucket, select a Region and click Create. Note: Remember what your bucket was named 
* You're done! We'll come back to this bucket in a little bit to grab some more necessary information.

## Creating and Configuring an EC2 Instance

You've now got a working script and a place to store your captured tweets. It's time to set up a free instance in Amazon's cloud that can continually capture tweets for you. &nbsp;Here are the steps: 

### Creating and Logging into Your Instance 

Rather than re-invent the wheel, [http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/EC2_GetStarted.html here's] Amazon's resource for how to create and connect to an EC2 instance. &nbsp;Follow those procedures but with the following caveats: 

* Make sure that the instance you select is an Ubuntu machine with Python 2.7.3+ installed on it. There may be multiple Ubuntu machines available, either should work fine. 
* Make sure your instance is "free-tier" eligible (to save that $$$)

### Connect using Putty

For the initial connection you will have to convert your .pem private key to a .ppk. You can use puttygen to do this. 

* Download puttygen from the [http://www.chiark.greenend.org.uk/~sgtatham/putty/download.html putty webpage] 
* Pull it onto your desktop and run the .exe 
* Click Load to b<span style="line-height: 1.5em;">rowse to your .pem that you created with Amazon. You may need to change the dialogue to view all files, not just .ppk files.</span> 
* You may or may not get a message saying that you have successfully imported a key. 
* Click Save private key. You will get a warning saying "Are you sure you want to save this key without a passphrase to protect it?" Click yes. 
* Save your new .ppk file. 
* You're done with that step!

Then when your key is converted, use [http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-connect-to-instance-linux.html#using-putty this tutorial] on how to connect to your instance using putty 
When you first log into your EC2 instance through putty, ignore the username AWS tells you- you will use the username "ubuntu"

### Creating New Directories and File Upload Preparation

* In the /home/ubuntu/ directory (assuming your username is "ubuntu," which is the default for EC2 Ubuntu instances), create a directory to hold your python files; we'll call it "tweets" in this demonstration. &nbsp;Here's the code:<br><code>ubuntu@your-ip:~$ mkdir tweets</code><br> 
* Enter the "tweets" folder and create a "log" folder with the following code:<br><code>ubuntu@your-ip:~$ cd tweets</code><br><code>ubuntu@your-ip:~/tweets$ mkdir log</code><br> 
* Open the rotate.sh file (we'll discuss what this does later) from the GitHub Repo with a text editor and make the following edits:<br>- Change 'path/to/log/' to '/home/ubuntu/tweets/log'<br>- Change 'name_of_s3_bucket' to the name you gave to your S3 bucket in the section above (Note: this name occurs twice in rotate.sh)

### Uploading Files to the EC2 Instance with FileZilla

In order to get your files from your computer to your EC2 instance, you need to use Secure File Transfer Protocol (SFTP). &nbsp;You can use FileZilla for this with Windows Computers. &nbsp;All you need to do is upload your "streaming.py," "credentials.py," and newly-edited "rotate.sh" into the "tweets" folder on your instance. &nbsp;Follow [https://www.youtube.com/watch?v=e9BDvg42-JI this video demonstration] on how to connect and upload your files to the tweets directory; the only difference is that you'll want to navigate directly to your ".ppk" file rather than the ".pem" file (you'll have already created this .ppk following the Amazon guide for getting started with EC2 if you've gotten this far). Also, remember to use 'ubuntu' as your user name, and no password. 

* when you have the FileZilla site setup for SFTP, you can select the three files, credentials.py, streaming.py and rotate.sh and right click to upload them to the EC2 instance that you have connected to

We're almost done! 

## Data Transfer using a Shell Script and Linux's Cronjob 

At this point, we've got a working Python script for capturing tweets, a place to store these tweets, and a computer on which to run our script. &nbsp;It's time to tie it all together! 

### Update Your Instance and Download the Correct Python Packages

Let's get our Ubuntu programs up to date just in case they're a little dated. &nbsp;We also want to install two Python packages that are not native to out-of-the-box Python Distributions: Run the following from your /home/ubuntu folder: 

<code>ubuntu@your-ip:~$ sudo apt-get update</code> 

<code>ubuntu@your-ip:~$ sudo pip install tweepy</code> 

<code>ubuntu@your-ip:~$ sudo pip install simplejson </code><br> 

<br> 

* Note that it's possible you will not already have pip, in which case you will need to first run the commands below:

ubuntu@your-ip:~$ sudo apt-get install python-setuptools 

ubuntu@your-ip:~$ sudo easy_install pip<br> 

### Connect your EC2 Instance to your S3 Bucket

To connect your computing instance to your S3 storage, we're going to use a tool called s3cmd. Below is the code for downloading and configuring this tool: 

<br> 

* Download the tool: 

<code>ubuntu@your-ip:~$ sudo apt-get install s3cmd </code> 

<br> 

* Configure the tool to connect to your S3 bucket: 

<code>ubuntu@your-ip:~$ s3cmd --configure</code> 

* Within the configuration, follow the steps under the "Configure s3cmd Environment" [http://tecadmin.net/install-s3cmd-manage-amazon-s3-buckets/ here ]to correctly configure s3cmd (Note: you can hit "Enter" to accept the defaults for many of the config options). 

<br> 

* Your EC2 instance is now ready to transfer files to your Bucket! 

<br> 

### Starting a Screen Session to Run streaming.py

In order to have your instance still running after you terminate your SSH session (and so you can maneuver within your instance while tweets are being captured), you'll want to create a "screen session." This will let streaming.py run in one "screen" while you're free to do other activities in another "screen." 

Intialize a screen session: 

<code>ubuntu@your-ip:~$ screen </code> 

<br> 

You're now in a screen session. &nbsp;Navigate to your "tweets" folder and run "streaming.py" to start capturing tweets: 

<code>ubuntu@your-ip:~$ cd /home/ubuntu/tweets</code> 

<code>ubuntu@your-ip:~/tweets$ python streaming.py </code> 

<br> 

Your instance is now capturing tweets! &nbsp;These tweets are being stored in /home/tweets/log/tweets.log 

Now it's time to leave streaming.py running while we put the finishing touches on this project. &nbsp;Press "Ctrl-a-d" to detach from the screen session. 

<br> 

### Setting up a Cronjob to run rotate.sh

The last step is to set up a recurring job to output the captured tweets to your S3 bucket on a recurring interval. &nbsp;This is where the rotate.sh script comes in; this script compresses the tweets.log file and writes it to your S3 bucket. &nbsp;To make the rotate.sh file an executable, perform the following (you should already be in the "tweets" folder): 

<code>ubuntu@your-ip:~/tweets$ chmod +x rotate.sh</code> 

<code></code> 

Now that it's ready, we need to set up a "cronjob" in order to run this rotate.sh script at a specified time interval (for this demonstration, we'll make this job write out the tweets to S3 every day at midnight): 

Open the "crontab": 

<code>ubuntu@your-ip:~/tweets$ crontab -e</code> 

<br> 

Scroll to the bottom of the crontab, add the following line of text (Note: there are spaces between all the "0s" and "*"s and the beginning of the filepath), and exit and save the file: 

<code>0 0 * * * /home/ubuntu/tweets/rotate.sh</code> 

<br> 

You are officially done! Your S3 bucket will have zipped tweets from the previous day uploaded to it at midnight each day.
