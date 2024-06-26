#!/bin/bash
deRegister_func()
{
    mentee_path="/home/core/mentees/$(whoami)"
    
    if [[ -d $mentee_path ]]
    then
        for domain in $1 $2 $3
        do
            if [[ -d "$mentee_path/$domain" ]]
            then
                rm -rf "$mentee_path/$domain"
            else
                echo "Couldn't find the $domain directory in $mentee's directory"
            fi 
            if grep -q "$domain" "$mentee_path/domain_pref.txt" 
            then
                new_domain_pref=$(awk '{if (NR > 1) print $1}' "$mentee_path/domain_pref.txt" | awk -v domain=$domain 'BEGIN{FS="->";OFS="->"}{for (i=1;i<=NF;i++) if ($i != domain) printf $i"->"}')
                echo -e "Preference \n${new_domain_pref%->}" > "$mentee_path/domain_pref.txt"
            else 
                echo "Could not find $domain in domain_pref.txt of $mentee"
        done
    else
        echo "Couldn't find $(whoami)'s home directory"
    fi
}

check_parameter_func()
{
    if [[ $# -eq 0]]
    then
        echo "USAGE: deRegister [domain].."
        exit 1
    elif [[ $# -lt 4 ]]
    then
        for i in $1 $2 $3
        do 
            declare -l tolower
            tolower=$i
            if echo "web app sysad" | grep -q "\b$tolower\b";then
            else 
                echo "Invalid parameters given. Provide valid Parameters only"
                exit 1
            fi
        done
        deRegister_func $1 $2 $3
        return 0
    else 
        echo "Warning: number of arguments more than 3"
    fi
}

group_check_func ()
{
    
    if $(groups $(whoami) | grep -q '\bmentee_grp\b')
    then
        check_parameter_func $@
    else 
        echo "Warning: Only a mentee can use this alias"
    fi

}

alias deRegister="group_check_func"
