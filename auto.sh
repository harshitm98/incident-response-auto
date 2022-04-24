rm -rf ./auto_script_output 2>/dev/null

OUTPUT=auto_script_output
MNT_LOCATION=/

while getopts "o:m:" opt; do
  case $opt in
    o) OUTPUT="$OPTARG";;
    m) MNT_LOCATION="$OPTARG";;
    \?) echo "Invalid option -$OPTARG" >&2
    ;;
  esac
done

mkdir $OUTPUT
cd $OUTPUT



### OS Version ###
if [ "$MNT_LOCATION" = "/" ];then
	uname -a >> os_version.txt
fi
cat $MNT_LOCATION/etc/os-release >> os_version.txt

### Host Installation time ###
ls -l $MNT_LOCATION/etc/ssh/ssh_host_*_key | awk -F" " 'NR==1{print $6"-"$7" "$8}' >> potential_os_installation_date.txt

### Static IP addresses ###
cat $MNT_LOCATION/etc/hosts >> static_ip_addresses.txt

### Get live data
if [ "$MNT_LOCATION" = "/" ];then
	ps -auwx >> running_processes.txt
	# echo "==== Netstat ====\n" >> active_connections.txt;
	netstat -antp >> active_connections_netstat.txt
	echo "\n\n==== SS ====\n" >> active_connections_ss.txt; 
	ss -tulpn >> active_connections_ss.txt
fi

### Gettings users with directories lists ###
# users with bash
cat $MNT_LOCATION/etc/passwd | grep bash | grep -v root | awk -F":" '{print $1}' > users.txt

# users in /home
ls $MNT_LOCATION/home >> users.txt

# cleanup
cat users.txt | sort -u > users1.txt
mv users1.txt users.txt

### Users with SUID=0
cat $MNT_LOCATION/etc/passwd | grep :0: >> users_suid_eq_0.txt

### Users who can run sudo
cat $MNT_LOCATION/etc/group | grep '^sudo:.$MNT_LOCATION*$' | awk -F":" '{print $NF}' >> users_sudo.txt

### Bash history ###
for user in $(cat users.txt)
do
	mkdir $user
	cat $MNT_LOCATION/home/$user/.bash_history > $user/bash_history_$user.txt
done

## root user's bash history
mkdir root
cat $MNT_LOCATION/root/.bash_history > root/bash_history_root.txt

### log files ###
mkdir logs

# auth.log
cat $MNT_LOCATION/var/log/auth.log | grep -a "COMMAND" > logs/auth_commands.log
### /var/log/secure
### /var/log/audit/audit.log

# wtmp, utmp and btmp logs
last -f $MNT_LOCATION/var/log/wtmp > logs/wtmp_logs.txt
last -f $MNT_LOCATION/var/log/utmp > logs/utmp_logs.txt
last -f $MNT_LOCATION/var/log/btmp > logs/btmp_logs.txt


### Get browser information... ###
# Firefox
for user in $(cat users.txt)
do
	mkdir $user/firefox_data
	## places.sqlite -> Firefox history
	find $MNT_LOCATION/home/$user/.mozilla/ -name places.sqlite >> $user/firefox_data/places_db_$user.txt
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
find $MNT_LOCATION/tmp > tmp_directory_list.txt
#... maybe cat out the data (?)

### currently loggedon users ###
if [ "$MNT_LOCATION" = "/" ];then
	who > users_loggedon.txt
	w > users_loggedon_moreinfo.txt
fi

### users login history ###
if [ "$MNT_LOCATION" = "/" ];then
	last > users_login_history.txt
fi

### Opened files ###
if [ "$MNT_LOCATION" = "/" ];then
	lsof > opened_files.txt
fi

### Crontab and scheduled tasks ###
if [ "$MNT_LOCATION" = "/" ];then
	crontab -l -u $user> list_scheduled_tasks_crontab.txt
fi

## crontab
cat $MNT_LOCATION/etc/crontab >> list_cronjobs.txt

## users cronjobs 
find $MNT_LOCATION/var/spool/cron/crontabs/ -type f -print -exec cat {} \; >> listed_user_cronjobs.txt

## all other cronjobs
find $MNT_LOCATION/etc/cron.d -type f -print -exec cat {} \; >> listed_cron.d.txt
find $MNT_LOCATION/etc/cron.daily -type f -print -exec cat {} \; >> listed_cron.daily.txt
find $MNT_LOCATION/etc/cron.hourly -type f -print -exec cat {} \; >> listed_cron.hourly.txt
find $MNT_LOCATION/etc/cron.weekly -type f -print -exec cat {} \; >> listed_cron.weekly.txt


### Latest modified/created files init.d/
ls -lt $MNT_LOCATION/etc/init.d/ | awk -F" " '{print $6"-"$7" "$8":\t"$9}' | grep -v "\- :" > startup_files_initd_recently_modified.txt

### SSH files (authorized_keys entries)
for user in $(cat users.txt)
do
	mkdir $user/ssh_files
	cat $MNT_LOCATION/home/$user/.ssh/authorized_keys > $user/ssh_files/authorized_keys
done

# root SSH
cat $MNT_LOCATION/root/.ssh/authorized_keys > root/ssh_files/authorized_keys

### Dump "interesting" files

# Files owned by user root
find $MNT_LOCATION/ -perm -4000 -user root -type f >> files_owned_by_root.txt

# Checks for SGID files
find $MNT_LOCATION/ -perm /6000 -type f >> files_sgid.txt

# Checks for files updated within last 7 days
find $MNT_LOCATION/ -mtime -7 -o -ctime -7 >> files_updated_recently.txt

### Dump hashes of all the files
find $MNT_LOCATION/ -type f -exec md5sum {} \; >> hashes_of_all_files.txt