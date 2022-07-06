#!/bin/bash

echo 'Enter path to search executable'

$folder
read folder

files="SUID_SGID_enabled_files"

TMP=$(mktemp)
find $folder -perm -4000 -o -perm -2000 > $TMP

# si j'ai déja une liste alors je compare
if [ -f $files ]; then 
    #TMPDIFF=$(mktemp)
    echo "Comparer $TMP avec l'ancien $files"
    # je boucle sur tout les fichiers differents, les nouveaux, et les manquants
    for i in `diff $files $TMP | cut -f2 -d" "`; do
        if [ -f "${i}" ]; then
            echo "le fichier ${i} a été modifié le $(ls --full-time ${i} | cut -d " " -f6,7)"
            # si c'est un nouveau fichier, alors je dit que c'est un nouveau fichier
        else
            echo "le fichier ${i} a été supprimé"
        fi
    done
else
    echo "Move de $TMP vers $files"
    mv $TMP $files
    chmod 777 $files
fi