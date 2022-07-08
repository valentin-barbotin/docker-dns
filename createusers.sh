#!/usr/bin/env bash

function checkGroups () {
    if [ -z "$1" ]; then
        echo "No user specified"
        exit 1
    fi

    if [ -z "$2" ]; then
        echo "No groups specified"
        exit 1
    fi

    local user=$1
    local groups=$2
    grps=($(echo -e "$groups" | awk -F: '{$NF=$1=$2=$3=""; sub(/^[ \t]+/, ""); print $0}'))
    for grp in "${grps[@]}"; do
        if [ -z "$(grep -e ^${grp}: /etc/group)" ]; then
            groupadd ${grp} && echo "Group ${grp} created" || echo "Failed to create group ${grp}"
        fi

        usermod -aG ${grp} ${LOGIN} && echo "User ${LOGIN} added to group ${grp}" || echo "User ${LOGIN} not added to group ${grp}"

    done

}


if [ -z "$(grep -e ^groupe1: /etc/group)" ]; then
    groupadd groupe1
fi

cat users.txt | while read line; do
  LOGIN=$(echo $line | awk -F: '{print $1}')
  PRENOM=$(echo $line | awk -F: '{print $2}')
  NOM=$(echo $line | awk -F: '{print $3}')
  PASSWORD=$(echo $line | awk -F: '{print $NF}')

  if [ -z "$(grep -e ^$LOGIN: /etc/passwd)" ]; then
    echo "User $LOGIN does not exist"
    echo "Creating user $LOGIN"

    # Create the user
    useradd $LOGIN -s /bin/bash --create-home --groups groupe1 && echo "User $LOGIN created" || echo "Failed to create user $LOGIN"
    echo "$LOGIN:$PASSWORD" | chpasswd
    chage --lastday 0 $LOGIN
    nb=$((5 + RANDOM % $((10-5))))
    echo "User $LOGIN created with password $PASSWORD"
    for ((i=0;i<nb;i++)); do
      size=$((5 + RANDOM % $((50-5))))
      filename="ratio$i"
      path="/home/$LOGIN/$filename"
      fallocate -l $size\MiB $path
      echo "File $filename created"
      chown $LOGIN:groupe1 $path
    done

  fi

  sed -i '/^#User: '$LOGIN':/d' /etc/passwd
  echo "#User: '$LOGIN' prenom: '$PRENOM' nom: '$NOM'" >> /etc/passwd

  checkGroups $LOGIN $line
done

echo "Done"