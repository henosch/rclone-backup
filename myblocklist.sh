#!/bin/sh
# Download AdBlock Lists (EasyList, EasyPrivacy, / Social Blocking)
curl -s -L https://easylist.to/easylist/easylist.txt https://easylist.to/easylist/easyprivacy.txt \
 https://easylist.to/easylist/fanboy-social.txt > adblock.unsorted
 
# Look for: ||domain.tld^
sort -u adblock.unsorted | grep ^\|\|.*\^$ | grep -v \/ > adblock.sorted
 
# Remove extra chars and put list under lighttpd web root
sed 's/[\|^]//g' < adblock.sorted > /var/www/html/adblock.hosts
 
# Remove files we no longer need
rm adblock.unsorted adblock.sorted
sudo chown pihole:pihole -R /etc/pihole/
