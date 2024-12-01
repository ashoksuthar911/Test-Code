#!/bin/bash

directry=/root/was_health_checks

#check if any email argument is provided
if [ -z "$1" ]; then
	echo "Please enter email address. Ex ./scriptname someone@oracle.com"
	echo "\"Run this script only in Primary ODR node\""
else
	if [ -d $directry ]; then
	tar -czf $directry-$(date +%d%b%Y).tar.gz $directry --remove-files
	echo "Directory exists, Taking a backup!"
	mkdir $directry
	else
	mkdir $directry
	fi
		/home/wasadmin/menu_config/cell_capacity_check.sh | sed -r "s/\x1B\[([0-9]{1,2}(;[0-9]{1,2})?)?[mGK]//g" | tr -dc '[[:print:]]\n' > $directry/cell_capacity_check_$HOSTNAME.txt
		/home/wasadmin/menu_config/was_cwxpi_audit.sh | sed -r "s/\x1B\[([0-9]{1,2}(;[0-9]{1,2})?)?[mGK]//g" | tr -dc '[[:print:]]\n' > $directry/was_cwxpi_audit_$HOSTNAME.txt
		/home/wasadmin/menu_config/was_status.sh | sed -r "s/\x1B\[([0-9]{1,2}(;[0-9]{1,2})?)?[mGK]//g" | tr -dc '[[:print:]]\n' > $directry/was_status_$HOSTNAME.txt
		ls /opt/websphere/appserver/profiles/appsrv01/config/cells/*/nodes | grep -v dmgr| sed 's/^//' > /root/cells_nodes
	for i in $(cat /root/cells_nodes)
	do
		ssh $i "tail -n 100 /opt/was_static/logs/monthly_reboot.log > monthly_reboot_$i.txt"
		ssh $i "lscpu|head -n 5 > cpu_details_$i.txt; echo -e "\n------------------------" >> cpu_details_$i.txt; iostat -c >> cpu_details_$i.txt"
		ssh $i "free -h > memory_details_$i.txt; echo "-------------------" >> memory_details_$i.txt; vmstat  -sS M >> memory_details_$i.txt"
		ssh $i "tail -n 50 /opt/was_static/logs/graceful_was_shutdown.sh*.log > graceful_was_shutdown_logs_$i.txt"
		scp $i:/root/*$i*.txt $directry
	done
	rm -f cells_nodes
	cd $directry
	zip -9 was_health_checks.zip * 
	echo "Please find the attached logs. Also, You can find all the logs in '/root/was_health_checks' in Primary ODR Node." | mailx -s "WAS Health checks are complete" -a $directry/was_health_checks.zip $1
fi
