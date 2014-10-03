#!/bin/sh
cd /path/to/log/
log=tweets.log
tmp=$log-`date +%Y-%m-%d-%H-%M-%S`

if [ -s $log ]
then
	#Renaming the log file will cause Python to start writing a new one with the old name
	mv $log $tmp

	#Compress and upload the old log file
	bzip2 $tmp
	s3cmd put $tmp.bz2 s3://name_of_s3_bucket/ >> upload.log 2>&1

	#Remove local copies for log files with correct md5 sums in s3
	md5sum *.bz2 | grep -o '^[^ ]*' > md5.txt
	s3cmd ls --list-md5 s3://name_of_s3_bucket/ | grep -f md5.txt | grep -o '[^/]*$' | xargs rm
fi
