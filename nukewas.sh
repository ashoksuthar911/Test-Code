# NukeWAS.sh
# This script is designed to completely remove all WebSphere on a node.  This is the hard remove approach.
# WasUninstall.sh will be coming down the line for a less scortched earth method

# Get running Java PIDs and Kill them
for pids in $(ps -ef | grep java | grep -v grep | awk '{print $2}'); do kill -9 ${pids}; done

# Remove symbolic links
rm -f /opt/websphere/appserver/oracle
rm -f /opt/websphere/appserver/profiles
rm -f /opt/websphere
rm -f /opt/websphere/appserver/systemApps/isclite.ear/security-service-wasadmin-portlet-1.5.war
rm -f /opt/websphere/appserver/systemApps/isclite.ear/system-enterprise-appliance-wasadmin-portlet-2.4.war

#Remove Files and Folders related to WebSphere
rm -rf /opt/was_static
rm -rf /opt/websphere_*
rm -rf /tmp/.com_ibm_tools_attach

# Remove hidden files
rm -f /opt/.ibm

# Unmount mounted shares
umount /media/was85
umount /media/scripts
umount /media/codewarehouse

rmdir /media/codewarehouse
rmdir /media/scripts
rmdir /media/was85

# Remove wasadmin user
if [ -d /home/wasadmin ]; then
        for pids in $(pgrep -u wasadmin); do kill -9 ${pids}; done
        userdel --remove wasadmin
fi

# Backup SSH Keys / remove SSH
#mv /root/.ssh/authorized_keys /root/.ssh/authorized_keys_backup
#mv /root/.ssh/known_hosts /root/.ssh/known_hosts_backup

echo ".................NUKEDNUKEDNUKEDNUKED............."
echo "..........NUKEDNUKEDNUKEDNUKEDNUKEDNUKEDNUKED....."
echo ".....NUKEDNUKEDNUKEDNUKEDNUKEDNUKEDNUKEDNUKEDNUKED"
echo ".....NUKEDNUKEDNUKEDNUKEDNUKEDNUKEDNUKEDNUKEDNUKED"
echo ".....NUKEDNUKEDNUKEDNUKEDNUKEDNUKEDNUKEDNUKEDNUKED"
echo ".....NUKEDNUKEDNUKEDNUKEDNUKEDNUKEDNUKEDNUKEDNUKED"
echo ".....NUKEDNUKEDNUKEDNUKEDNUKEDNUKEDNUKEDNUKEDNUKED"
echo "......NUKEDNUKEDNUKEDNUKEDNUKEDNUKEDNUKEDNUKED...."
echo "..........NUKEDNUKEDNUKEDNUKEDNUKEDNUKEDNUKED....."
echo "......................NUKEDNUKED.................."
echo "......................NUKEDNUKED.................."
echo "......................NUKEDNUKED.................."
echo "......................NUKEDNUKED.................."
echo "......................NUKEDNUKED.................."
echo "......................NUKEDNUKED.................."
echo "......................NUKEDNUKED.................."
echo "......................NUKEDNUKED.................."
echo ".................NUKEDNUKEDNUKEDNUKED............."
echo ".........NUKEDNUKEDNUKEDNUKEDNUKEDNUKEDNUKED......"
echo ".......NUKEDNUKEDNUKEDNUKEDNUKEDNUKEDNUKEDNUKED..."
echo "NUKEDNUKEDNUKEDNUKEDNUKEDNUKEDNUKEDNUKEDNUKEDNUKED"
echo "*******************GROUND ZERO********************"[
