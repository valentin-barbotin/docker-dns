#!/usr/bin/env bash

user_map={}
i=0

# get folder size for each user
for user in $(ls /home); do
    size=$(du -s /home/$user | cut -f1)
    size_formated=$(du -sh /home/$user | cut -f1)
    login=$(grep $user /etc/passwd | cut -d: -f1)

    user_map[$i]=$login:$size:$size_formated
    i=$(($i+1))
done;

# sort the map by size from low to high
for ((i=0; i<${#user_map[@]}; i++)); do
    for ((j=0; j<${#user_map[@]}; j++)); do
        if [[ ${user_map[$i]} < ${user_map[$j]} ]]; then
            tmp=${user_map[$i]}
            user_map[$i]=${user_map[$j]}
            user_map[$j]=$tmp
        fi
    done
done

# print 5 users with biggest folder size and stop if there are less than 5 users
echo "" > /home/.sizes
for ((i=0; i<5; i++)); do
    if [[ ${user_map[$i]} ]]; then
        line="$(echo ${user_map[$i]} | cut -d: -f1) $(echo ${user_map[$i]} | cut -d: -f3)"
        echo $line >> /home/.sizes
    else
        break
    fi
done


for user in $(ls /home); do
    touch /home/$user/.bashrc
    # add lines to .bashrc file if not exist
    if [[ ! $(grep "cat /home/.sizes" /home/$user/.bashrc) ]]; then
        cat << EOF >> /home/$user/.bashrc
if [[ -f /home/.sizes ]]; then
    cat /home/.sizes
fi

# check if user is over 100Mo
size=\$(du -s \$HOME | cut -f1)
if [[ \$size -gt 100000 ]]; then
    echo "WARNING: you home is over 100Mo"
fi
EOF

    fi
done