#!/bin/bash

mentor_func ()
{
    for grp in $grouplist
    do
        if [[ $grp == "web_mentors_grp" ]]
        then
            domain=web
            break
        fi
        if [[ $grp == "app_mentors_grp" ]]
        then
            domain=app
            break
        fi
        if [[ $grp == "sysad_mentors_grp" ]]
        then
            domain=sysad
            break
        fi
    done
    
    mentee_list=$(awk 'BEGIN{ ORS=" " } $0 !~/Rollno Name/{ print $2;} END{}' "~/AlottedMentees.txt") 
    for mentee in $mentee_list
    do
        dir_location="~/../../../mentees/$mentee/$domain"
        declare -a task_completed_arr
        for i in {1..3}
        do
            task_location="$dir_location/Task$i"
            if [[ -d "$task_location" ]]
            then
                cd ~/submitted_tasks/task$i  
                ln -s ~/../../../mentees/$mentee/$domain/Task$i $mentee
                if [[ -z "$task_location/*" ]]
                then
                    task_completed_arr[$i]='n'
                else
                    task_completed_arr[$i]='y'
                fi
            else
                task_completed_arr[$i]='n'
            fi
        done
        declare -i column
        column=$(awk -v domain="$domain" 'BEGIN{column=1; FS=","; OFS=","} $0 ~/^Tasks_domain/{for (i = 1; i <= NF; i++) {if ($i != domain){column++} else {print column ;break}}}' $dir_location/../task_completed.txt)
        modified_data=$(awk -v col=$column -v val1=${task_completed_arr[1]} -v val2=${task_completed_arr[2]} -v val3=${task_completed_arr[3]}'BEGIN{task[2]=val1;task[3]=val2;task[4]=val3; FS=","; OFS=","} $0 !~/^Tasks_domain/{$col=task[NR];} {print $1,$2,$3,$4 } END{}' $dir_location/../task_completed.txt)
        echo -e "$modified_data" > $dir_location/../task_completed.txt
    done
}


mentee_func ()
{
    mentee_preference=$(awk 'BEGIN{FS="->"} {if (NR == 2) {for (i=1;i<=NF:i++) print $i}}'"/home/core/mentees/$(whoami)/domain_pref.txt")
    for i in $mentee_preference
    do
        if [[ $1 == $i]]
        then
            condition=0
        fi 
    done
    if [[ $condition -eq 0 ]]
    then
        echo "$1:" > /home/core/mentees/$(whoami)/task_submitted.txt
        declare -a taskarr
        for i in {1..3}
        do
            read -p "Have you submitted the task$i (Y/n) " fetch
            taskarr[$i]=$fetch
            echo -e "\tTask$i: ${taskarr[$i]}" >> /home/core/mentees/$(whoami)/task_submitted.txt
            if [[ ${taskarr[$i]} == 'y' ]] || [[ ${taskarr[$i]} == 'Y' ]]
            then
                cd /home/core/mentees/$(whoami)/$1
                mkdir Task$i
            fi
        done
        echo "Task folders have been created"
    else
        echo "The domain $1 isn't in your domain preference"
    fi
}

check_mentee_func ()
{
    for i in $1 $2 $3
    do 
        match=1
        declare -l tolower
        tolower=$i
        for j in web app sysad
        do
            if [[ $tolower == $j ]]
            then
                match=0
                break
            fi
        done

        if [[ $match -eq 0 ]]
        then
            echo mentee_func $j
        else 
            echo "Invalid parameters given. Provide valid Parameters only"
            return 1
        fi
    done
    return 0
}




submitTask_func ()
{
    inmentees=1
    inmentor=1
    grouplist=$(groups)
    for grp in $grouplist
    do
        if [[ $grp == "mentees_grp" ]]
        then
            inmentees=0
            break
        fi
    done
    for grp in $grouplist
    do
        if [[ $grp == "mentors_grp" ]]
        then
            inmentor=0
            break
        fi
    done
    if [[ $inmentees -eq 0 && $inmentor -eq 1 ]]
    then
        check_mentee_func $1 $2 $3
    elif [[ $inmentees -eq 1 && $inmentor -eq 0 ]]
    then 
        mentor_func
    else
        echo "The current user is not a mentee or a mentor. Need to be a mentee or a mentor in order to use this alias " 
    fi
}


alias submitTask="submitTask_func"
