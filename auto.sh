rm -rf ./auto_script_output > /dev/null

OUTPUT=auto_script_output
mkdir $OUTPUT
cd $OUTPUT

### OS Version ###
uname -a >> os_version.txt
cat /etc/os-release >> os_version.txt

### Host Installation time ###
ls -l /etc/ssh/ssh_host_*_key | awk -F" " 'NR==1{print $6"-"$7" "$8}' >> potential_os_installation_date.txt

### Static IP addresses ###
cat /etc/hosts >> static_ip_addresses.txt


### Gettings users with directories lists ###
# users with bash
cat /etc/passwd | grep bash | grep -v root | awk -F":" '{print $1}' > users.txt

# users in /home
ls /home >> users.txt

# cleanup
cat users.txt | sort -u > users1.txt
mv users1.txt users.txt

### Users with SUID=0
cat /etc/passwd | grep :0: >> users_suid_eq_0.txt

### Users who can run sudo
cat /etc/group | grep '^sudo:.*$' | awk -F":" '{print $NF}' >> users_sudo.txt

### Bash history ###
for user in $(cat users.txt)
do
	mkdir $user
	cat /home/$user/.bash_history > $user/bash_history_$user.txt
done

## root user's bash history
mkdir root
cat /root/.bash_history > root/bash_history_root.txt

### log files ###
mkdir logs

# auth.log
cat /var/log/auth.log | grep -a "COMMAND" > logs/auth_commands.log
### /var/log/secure
### /var/log/audit/audit.log

# wtmp, utmp and btmp logs
last -f /var/log/wtmp > logs/wtmp_logs.txt
last -f /var/log/utmp > logs/utmp_logs.txt
last -f /var/log/btmp > logs/btmp_logs.txt


### Get browser information... ###
# Firefox
for user in $(cat users.txt)
do
	mkdir $user/firefox_data
	## places.sqlite -> Firefox history
	find /home/$user/.mozilla/ -name places.sqlite >> $user/firefox_data/places_db_$user.txt
	mkdir $user/firefox_data/browsing_history
	for place in $(cat $user/firefox_data/places_db_$user.txt)
	do
		# copies all places_.sqlite file and renames them according through their profile...
		cp $place $user/firefox_data/browsing_history/$(cat $user/firefox_data/places_db_$user.txt | grep $place | awk -F"/" '{print $6}')_places.sqlite
		# get the contents from the database and dump it to a txt file
		sqlite3 $place "select h.visit_date,p.url from moz_historyvisits as h, moz_places as p where p.id == h.place_id order by h.visit_date" > $user/firefox_data/browsing_history/$(cat $user/firefox_data/places_db_$user.txt | grep $place | awk -F"/" '{print $6}')_browsing_history.txt
	done

	## 
done

# Chromium




### tmp directory ###
find /tmp > tmp_directory_list.txt
#... maybe cat out the data (?)

### currently loggedon users ###
who > users_loggedon.txt
w > users_loggedon_moreinfo.txt

### users login history ###
last > users_login_history.txt

### Opened files ###
lsof > opened_files.txt

### Crontab and scheduled tasks ###
crontab -l -u $user> scheduled_tasks_crontab.txt

### Latest modified/created files init.d/
ls -lt /etc/init.d/ | awk -F" " '{print $6"-"$7" "$8":\t"$9}' | grep -v "\- :" > startup_files_initd_recently_modified.txt

### SSH files (authorized_keys entries)
for user in $(cat users.txt)
do
	mkdir $user/ssh_files
	cat /home/$user/.ssh/authorized_keys > $user/ssh_files/authorized_keys
done