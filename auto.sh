OUTPUT=output
cd $OUTPUT

### OS Version ###
uname -a >> os_version.txt
cat /etc/os-release >> os_version.txt

### Gettings users with directories lists ###
ls /home > users.txt
# optional cleanup
cat users.txt | awk -F" " '{print $NF}' > users_cleaned.txt
mv users_cleaned.txt users.txt

### Bash history ###
for user in $(cat users.txt)
mkdir $user
do
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
mkdir $user/firefox_data
do
	## places.sqlite -> Firefox history
	find /home/$user/.mozilla/ -name places.sqlite >> $user/firefox_data/places_db_$user.txt
	mkdir $user/firefox_data/history
	for place in $(cat $user/firefox_data/places_db_$user.txt)
	do
		# copies all places_.sqlite file and renames them according through their profile...
		cp $place $user/firefox_data/history/$(cat $user/firefox_data/places_db_$user.txt | grep $place | awk -F"/" '{print $6}')_places.sqlite
		for database in $(find $user/firefox_data/history/)
		do
        	sqlite3 $database "select h.visit_date,p.url from moz_historyvisits as h, moz_places as p where p.id == h.place_id order by h.visit_date" >> $user/firefox_data/history/$database_history.txt
		done
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
crontab -l > scheduled_tasks.txt

### Latest modified/created files init.d/
ls -lt /etc/init.d/ | awk -F" " '{print $6"-"$7" "$8":\t"$9}' | grep -v "\- :" > startup_files_initd_recently_modified.txt

### SSH files