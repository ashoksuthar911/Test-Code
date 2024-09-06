#!/bin/bash


echo "Gluster checks are in-progress, Please wait!"

# Generate a filename for the log
glusterchecks="gluster_checks_$(date +%d%b%Y).log"

if [[ -f "$glusterchecks" ]]; then
	tar -czf $glusterchecks.tar.gz $glusterchecks --remove-files
	rm -f "$glusterchecks"
fi
echo -e "Gluster Checks performed on host on $(date +%d-%b-%Y_%H:%M) on $nodes_arg" >> $glusterchecks
echo "------------------------------------------------------------------------------------------" >> $glusterchecks

# Function to display usage
usage() {
    echo "Usage: $0 -e someone@oracle.com -n node1,node2,node3" >&2
    exit 1
}

# Function to perform commands on gluster nodes
glstrnode() {
    echo "Enabling Repos on $node" >> $glusterchecks
    echo "------------------------------------------------------------------------------------------" >> $glusterchecks
    ssh $node "yum-config-manager --disable \*gluster\*" 2&> /dev/null
    ssh $node "yum-config-manager --enable \*gluster8\*" 2&> /dev/null
    ssh $node "yum repoinfo enabled | grep -i gluster" >> $glusterchecks
    echo -e "\n**********************************************************************************************\n\n" >> $glusterchecks

    echo "Printing OpVersion of connected Gluster Clients" >> $glusterchecks
    echo "------------------------------------------------------------------------------------------" >> $glusterchecks
    for vol in $(gluster volume list); do
        gluster volume status $vol clients
    done >> $glusterchecks
    echo -e "\n**********************************************************************************************\n\n" >> $glusterchecks

    echo "Printing attached nodes" >> $glusterchecks
    echo "------------------------------------------------------------------------------------------" >> $glusterchecks
    for vol in $(gluster volume list); do
        gluster volume status $vol clients
    done | cut -f 1 -d : | grep -vE "\-|[a-z]" | sort -u | nslookup >> $glusterchecks
    echo -e "\n**********************************************************************************************\n\n" >> $glusterchecks

    echo "Glusterd service status on $node" >> $glusterchecks
    echo "------------------------------------------------------------------------------------------" >> $glusterchecks
    ssh $node "systemctl status glusterd" >> $glusterchecks
    echo -e "\n**********************************************************************************************\n\n" >> $glusterchecks

    echo "SMB service status on $node" >> $glusterchecks
    echo "------------------------------------------------------------------------------------------" >> $glusterchecks
	ssh $node "systemctl status smb" >> $glusterchecks
    echo -e "\n**********************************************************************************************\n\n" >> $glusterchecks

    echo "CTDB service status on $node" >> $glusterchecks
    echo "------------------------------------------------------------------------------------------" >> $glusterchecks
    ssh $node "ctdb status" >> $glusterchecks
    echo -e "\n**********************************************************************************************\n\n" >> $glusterchecks

    echo "Checking FSTAB on $node" >> $glusterchecks
    echo "------------------------------------------------------------------------------------------" >> $glusterchecks
    ssh $node "grep -i gluster /etc/fstab" >> $glusterchecks
    echo -e "\n**********************************************************************************************\n\n" >> $glusterchecks

    echo "Gluster's Volume status on $node" >> $glusterchecks
    ssh $node "gluster volume status" >> $glusterchecks
    echo -e "\n**********************************************************************************************\n\n" >> $glusterchecks

    echo "Running the heal commands on $node" >> $glusterchecks
    echo "------------------------------------------------------------------------------------------" >> $glusterchecks
    ssh $node 'bash -c "for i in \$(gluster volume list); do gluster volume heal \$i; done"' >> $glusterchecks
    echo -e "\n**********************************************************************************************\n\n" >> $glusterchecks
    ssh $node 'bash -c "for i in \$(gluster volume list); do gluster volume heal \$i info; done"' >> $glusterchecks
    echo -e "\n**********************************************************************************************\n\n" >> $glusterchecks
    echo "Please perform the SNAPSHOT for $node, before proceeding for the upgrade!" | tee -a $glusterchecks
}

# Parse command-line arguments
while getopts "e:n:" opt; do
    case $opt in
        e)
            email_arg=$OPTARG
            ;;
        n)
            nodes_arg=$OPTARG
            ;;
        *)
            usage
            ;;
    esac
done

# Check if the -e or -n option was not provided
if [[ -z "$email_arg" || -z "$nodes_arg" ]]; then
    usage
fi

# Convert the comma-separated list into an array
IFS=',' read -r -a node_list <<< "$nodes_arg"

# Process each node
for node in "${node_list[@]}"; do
    if [[ "$node" == *glstr* || "$node" == *nfs* ]]; then
        if [[ -z "$(ssh $node "rpm -qa | grep -i gluster")" ]]; then
            echo "This node does not have Gluster installed, Script will exit now!"| tee -a $glusterchecks
			exit 1
        else
			if ssh "$node" "gluster volume get all cluster.max-op-version | grep -q '80000'"; then
				echo "Gluster version on $node is already on V8. No upgrade required." | tee -a $glusterchecks
      				echo -e "\n**********************************************************************************************\n" | tee -a $glusterchecks
			else
				echo "Gluster upgrade is needed on $node." | tee -a $glusterchecks
      				echo -e "\n**********************************************************************************************\n" | tee -a $glusterchecks
    				glstrnode
			fi
		fi
	fi
	if ssh "$node" "grep -iq '7..' /etc/oracle-release"; then
		echo "Gluster packages are compatiable for $node with OL 7.X." | tee -a $glusterchecks
  		echo -e "\n**********************************************************************************************\n" | tee -a $glusterchecks
		echo "Current OL version on $node" >> $glusterchecks
		ssh $node "cat /etc/oracle-release" >> $glusterchecks
		echo -e "\n**********************************************************************************************\n" >> $glusterchecks
	else
		echo "Current OL version on $node" >> $glusterchecks
		ssh $node "cat /etc/oracle-release" >> $glusterchecks
		echo -e "\n**********************************************************************************************\n" >> $glusterchecks
		echo "Cannot proceed with upgrade on $node as Gluster packages are only available for OL 7.X" | tee -a $glusterchecks
	fi
	echo "Checking and installing required packages on $node" >> $glusterchecks
	echo "------------------------------------------------------------------------------------------" >> $glusterchecks
	ssh $node "yum -y install yum-utils" >> $glusterchecks 2>&1
	echo -e "\n**********************************************************************************************\n" >> $glusterchecks
	ssh $node "rpm -qa | grep -i gluster" >> $glusterchecks 2>&1
	echo -e "\n**********************************************************************************************\n" >> $glusterchecks
	
	echo "Checking Enabled Repos on $node" >> $glusterchecks
	echo "------------------------------------------------------------------------------------------" >> $glusterchecks
	ssh $node "yum repoinfo enabled | grep -i gluster" >> $glusterchecks 2>&1
	echo -e "\n**********************************************************************************************\n" >> $glusterchecks
done

# Send the log file via email
echo "Test done, Please check the attached file." | mailx -s "Gluster Health checks are complete" -a $glusterchecks $email_arg
