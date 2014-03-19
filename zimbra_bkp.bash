#!/bin/bash

# 2014-03-19 22:25:26.0 +0100 / Gilles Quenot <gilles.quenot@sputnick.fr>

mysql_root_pw=$(/opt/zimbra/bin/zmlocalconfig -s | awk '$1 == "mysql_root_password"{print $3}')

mkdir -p /home/backup/zimbra

# mails+metadatas+calendars+todos
for account in $(su - zimbra -c 'zmprov -l getAllAccounts' | egrep -v '^spam|^ham|^virus-quarantine'); do
    su - zimbra -c "zmmailbox -z -m $account getRestURL '//?fmt=tgz'" > /home/backup/zimbra/mails+cal+todos_${account}_$(date +%Y%m%d-%H%M).tgz
done

# ldap
su - zimbra -c "/opt/zimbra/libexec/zmslapcat /tmp/"
\mv /tmp/ldap.bak.* /home/backup/zimbra

# mysql -> http://wiki.zimbra.com/wiki/MySQL_Backup_and_Restore
/opt/zimbra/mysql/bin/mysqldump --user=root --password=$(/opt/zimbra/bin/zmlocalconfig -s | awk '$1 == "mysql_root_password"{print $3}') --socket=/opt/zimbra/db/mysql.sock --all-databases --single-transaction --flush-logs > /home/backup/bdd/mysql/zimbra_dump-$(date +%Y%m%d%H%M).sql.gz

# clean
find /home/backup/zimbra -type f -mtime +15 -delete 2>/dev/null
