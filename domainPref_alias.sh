#!/bin/bash

write_domain ()
{
    cd /home/core/mentees/$2
    concatenated_pref=""
    for i in first second third
    do 
        if [[ ${pref[$i]} != '' ]]
        then
            concatenated_pref="$concatenated_pref->${pref[$i]}"
            mkdir ${pref[$i]}
            setfacl -m u:core:rwx /home/core/mentees/$2/${pref[$i]}
            
            if [[ ${pref[$i]} == 'web' ]]
            then
                setfacl -d -m g:web_mentors_grp:r-x /home/core/mentees/$2/${pref[$i]}
            elif [[ ${pref[$i]} == 'app' ]]
            then
                setfacl -m g:app_mentors_grp:r-x /home/core/mentees/$2/${pref[$i]}
                setfacl -d -m g:app_mentors_grp:r-x /home/core/mentees/$2/${pref[$i]}
            elif [[ ${pref[$i]} == 'sysad' ]]
            then
                setfacl -d -m g:sysad_mentors_grp:r-x /home/core/mentees/$2/${pref[$i]}   
            fi
            setfacl -m o::--- /home/core/mentees/$2/${pref[$i]}
        else
            break
        fi
    done
    concatenated_pref=${concatenated_pref#->}
    echo -e "Preference \n$concatenated_pref" > domain_pref.txt
    echo "$1 $2 $concatenated_pref" >> /home/core/mentee_domain.txt

}


read_pref ()
{
    read -p "Enter the $1 preference:  " prf
    if [[ $prf != '' ]]
    then
        if [[ $prf == 1 ]]
        then 
            result=web
        elif [[ $prf == 2 ]]
        then 
            result=app
        elif [[ $prf == 3 ]]
        then 
            result=sysad
        else
            unset prf
            echo "Enter a number in the range 1-3 as preference"
            read_pref $1
        fi
    else
        result=""
    fi
}

ask_pref ()
{
    read_pref first
    pref[first]=$result
    if [[ ${pref[first]} != '' ]]
    then
        read_pref second
        pref[second]=$result
        if [[ ${pref[second]} != '' ]]
        then
            read_pref third
            pref[third]=$result 
        else
            return
        fi
    else
        echo "Atleast one preference needs to be given"
        ask_pref
    fi
}

menu ()
{
    read -p "Enter your Roll Number: " roll_no
    if (( $roll_no > 10000000 && $roll_no < 12000000 ))
    then
        echo "Provide your preference in order"
        echo "Enter 1 for web "
        echo "Enter 2 for app"
        echo "Enter 3 for sysad "
        echo "Press enter if you don't want to provide further preference"

        ask_pref
        if [[ ${pref[second]} != '' ]]
        then
            if [[ ${pref[first]} == ${pref[second]} ]] || [[ ${pref[second]} == ${pref[third]} ]] || [[ ${pref[third]} == ${pref[first]} ]]
            then
                echo "Entered the same domain twice or more"
                echo "Do again"
                menu
            else
                for index in first second third
                do 
                    echo "Your $index preference is ${pref[$index]}"
                done
                write_domain $roll_no $(whoami)
            fi
        else
            for index in first second third
            do 
                echo "Your $index preference is ${pref[$index]}"
            done
            write_domain $roll_no $(whoami)
        fi
    else
        echo "Enter a valid Roll Number"
        menu    
    fi    
}



domainPref_func ()
{
    inmentees=1
    grouplist=$(groups)
    for grp in $grouplist
    do
        if [[ $grp == "mentees_grp" ]]
        then
            inmentees=0
            break
        fi
    done

    if [[ $inmentees -eq 0 ]]
    then
        menu
    else
        echo "The current user is not a mentee. Only a mentee can use this alias" 
    fi
}
declare -A pref
alias domainPref="domainPref_func"
