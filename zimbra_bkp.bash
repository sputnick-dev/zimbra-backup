#!/bin/bash

# 2014-03-19 22:25:26.0 +0100 / Gilles Quenot <gilles.quenot@sputnick.fr>

# In // of this script, a FS backup is recommended with rsync by example.

zimbra_backup_path=/home/backup/zimbra
mysql_backup_path=/home/backup/bdd/mysql
mysql_root_pw=$(/opt/zimbra/bin/zmlocalconfig -s | awk '$1 == "mysql_root_password"{print $3}')

cd $zimbra_backup_path
mkdir -p $zimbra_backup_path $mysql_backup_path

# mails+metadatas+calendars+todos
for account in $(su - zimbra -c 'zmprov -l getAllAccounts' | egrep -v '^spam|^ham|^virus-quarantine'); do
    su - zimbra -c "zmmailbox -z -m $account getRestURL '//?fmt=tgz'" > $zimbra_backup_path/mails+cals+todos_${account}_$(date +%Y%m%d-%H%M).tgz
done

# ldap
/opt/zimbra/openldap/sbin/slapcat -F /opt/zimbra/data/ldap/config -b '' -l ./ldap.bak.$(date +%Y%m%d%H%M%S)

# mysql -> http://wiki.zimbra.com/wiki/MySQL_Backup_and_Restore
/opt/zimbra/mysql/bin/mysqldump --user=root --password="$mysql_root_pw" --socket=/opt/zimbra/db/mysql.sock --all-databases --single-transaction --flush-logs --events |
	gzip > $mysql_backup_path/zimbra_dump-$(date +%Y%m%d%H%M).sql.gz

# clean
find $zimbra_backup_path -type f -mtime +15 -delete 2>/dev/null
