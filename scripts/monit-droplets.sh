#!/bin/bash
{ hostname ; date ; free -h ; docker ps -a ; last | head ; ps -eo pid,comm,%cpu,%mem --sort=-%cpu | head -n 8 ;} > /home/injera/logs/docker-host1.txt
cd /home/injera/logs 
/usr/bin/git add --all . 
/usr/bin/git commit -m "daily crontab logs `date`"
/usr/bin/git push origin master
