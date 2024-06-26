#!/bin/bash

menteelist=$(awk 'BEGIN{FS=" "; OFS="_"} $0 !~/Rollno Name Domain/{print $2,$1 ;}' "$HOME/mentee_domain.txt")

for mentee in $menteelist
do
    mentee_path="$HOME/mentees/$mentee"
    pref=$(sed -n '2p' "$mentee_path/domain_pref.txt")
    if [[ -z $pref ]]
    then
        rm -rf $mentee_path
        rm -f "$HOME/mentors/*/*/*/$mentee"
        mentee_rollno=${mentee#*_}
        sed -i "/\<${mentee_rollno}\>/d" "$HOME/mentee_domain.txt"
        sed -i "/\<${mentee_rollno}\>/d" "$HOME/.mentee_not_submit.txt"
        sed -i "/\<${mentee_rollno}\>/d" "$HOME/mentors/*/*/Alottedmentees.txt"
        echo "Every trace of $mentee removed"
        continue
    fi
    domain_pref=($( echo "$pref" | awk 'BEGIN{FS="->"} {print $1,$2,$3 ;}' ))
    for domain in $domain_pref;
    do
        if [[ ! -d "$mentee_path/$domain" ]]
        then
            if [[ $domain == 'web' ]]
            then
                mentordir_path="$HOME/mentor/Webdev/"
            elif [[ $domain == 'app' ]]
                mentordir_path="$HOME/mentor/Appdev/"
            else 
                mentordir_path="$HOME/mentor/Sysad/"
            fi
            rm -f "$mentordir_path/*/*/$mentee"
            
        fi
    done

done