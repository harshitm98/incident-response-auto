### OS Version ###
uname -a
cat /etc/os-release

### Gettings users with directories lists ###
ls /home > users.txt
# optional cleanup
cat users.txt | awk -F" " '{print $NF}' > users_cleaned.txt
mv users_cleaned.txt users.txt

### Bash history ###
for user in $(cat users.txt)
do
	cat /home/$user/.bash_history > bash_history_$user.txt
done

## root user's bash history
cat /root/.bash_history > bash_history_root.txt

### log files ###
# https://lazarov.tech/linux-incident-response-part-1/
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
mkdir firefox_data
for user in $(cat users.txt)
mkdir firefox_data/$user
do
	## places.sqlite -> Firefox history
	find /home/$user/.mozilla/ -name places.sqlite >> firefox_data/$user/places_db_$user.txt
	mkdir firefox_data/$user/history
	for place in $(cat firefox_data/$user/places_db_$user.txt)
	do
		# copies all places_.sqlite file and renames them according through their profile...
		cp $place firefox_data/$user/history/$(cat firefox_data/$user/places_db_$user.txt | grep $place | awk -F"/" '{print $6}')_places.sqlite
        #
        #
        #
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