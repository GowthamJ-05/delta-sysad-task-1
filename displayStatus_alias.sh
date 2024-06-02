#!/bin/bash 
displayStatus_func ()
{
    if [[ -e "~/.mentee_not_submit.txt" ]]
    then
        touch "~/.mentee_not_submit.txt"
        chmod 700 "~/.mentee_not_submit.txt"
    fi
    touch "~/.mentee_new_submit.txt"
    declare -a mentee_domain_list
    mentee_list=$(awk 'BEGIN {FS=' '} $0 !~/Rollno Name Domain/{print $2}' "$HOME/mentee_domain.txt")
    mentee_domain_list=($(awk 'BEGIN {FS=' '} $0 !~/Rollno Name Domain/{print $3}' "$HOME/mentee_domain.txt"))
    declare -i mentee_number mentee_number_web mentee_number_app mentee_number_sysad

    mentee_number=0
    mentee_number_web=0
    mentee_number_app=0
    mentee_number_sysad=0

    declare -a task_web task_app task_sysad
    declare -i task_web task_app task_sysad
    task_web=(0 0 0)
    task_app=(0 0 0)
    task_sysad=(0 0 0)

    for mentee in $mentee_list
    do
        mentee_domain=$(echo ${mentee_domain_list[$mentee_number]} | awk 'BEGIN{FS="->"; OFS=" "} {print $1,$2,$3}')
        if [[ -s "~/mentees/$mentee/task_submitted.txt" ]]
        then
            for domain in $mentee_domain
            do 

                if [[ $domain == "web" ]]
                then
                    declare -a task_submit_web 
                    task_submit_web=($(awk 'BEGIN{i=1;} $0 ~/^web:/{i=0} {if(i==0){print $2; }}$0 ~/^sysad:/{i=1} $0 ~/^app:/{i=1}' "$HOME/mentees/$mentee/task_submitted.txt" ))
                    for i in {0..2}
                    do
                        row="$mentee,$domain,$i"
                        if [[ ${task_submit_web[$i]} == 'y' ]]
                        then
                            task_web[$i]=${task_web[$i]}+1
                            if [[ $(awk -v row=$row 'BEGIN{FS=",";} $0 ~row {print 0; exit}' "$HOME/.mentee_not_submit.txt") ]]
                            then
                                new_data=$(awk -v row=$row 'BEGIN{FS=","; Match=1;} $0 ~row {Match = 0;} {if (Match!=0){print $1,$2,$3} else {Match=1}} END{}' "$HOME/.mentee_not_submit.txt")
                                echo $new_data > "~/.mentee_not_submit.txt"
                                echo $row >> "~/.mentee_new_submit.txt"
                            fi
                        elif [[ ${task_submit_web[$i]} == 'n' ]]
                        then
                            echo "$row" >> "~/.mentee_not_submit.txt"
                        fi
                    done
                mentee_number_web=$mentee_number_web+1  
                fi
                
                
                if [[ $domain == "app" ]]
                then
                    declare -a task_submit_app
                    task_submit_app=($(awk 'BEGIN{i=1;} $0 ~/^app:/{i=0} {if(i==0){print $2; }}$0 ~/^web:/{i=1} $0 ~/^sysad:/{i=1}' "$HOME/mentees/$mentee/task_submitted.txt" ))
                    for i in {0..2}
                    do
                        row="$mentee,$domain,$i"
                        if [[ ${task_submit_app[$i]} == 'y' ]]
                        then
                            task_app[$i]=${task_app[$i]}+1
                            if [[ $(awk -v row=$row 'BEGIN{FS=",";} $0 ~row {print 0; exit}' "$HOME/.mentee_not_submit.txt") ]]
                            then
                                new_data=$(awk -v row=$row 'BEGIN{FS=","; Match=1;} $0 ~row {Match = 0;} {if (Match!=0){print $1,$2,$3} else {Match=1}}' "$HOME/.mentee_not_submit.txt")
                                echo $new_data > "~/.mentee_not_submit.txt"
                                echo $row >> "~/.mentee_new_submit.txt"
                            fi
                        elif [[ ${task_submit_app[$i]} == 'n' ]]
                        then
                            echo "$row" >> "~/.mentee_not_submit.txt"
                        fi
                    done 
                mentee_number_app=$mentee_number_app+1 
                fi



                if [[ $domain == "sysad" ]]
                then
                    declare -a task_submit_sysad
                    task_submit_sysad=($(awk 'BEGIN{i=1;} $0 ~/^sysad:/{i=0} {if(i==0){print $2; }}$0 ~/^web:/{i=1} $0 ~/^app:/{i=1}' "$HOME/mentees/$mentee/task_submitted.txt" ))
                    for i in {0..2}
                    do
                        row="$mentee,$domain,$i"
                        if [[ ${task_submit_sysad[$i]} == 'y' ]]
                        then
                            task_sysad[$i]=${task_sysad[$i]}+1
                            if [[ $(awk -v row=$row 'BEGIN{FS=",";} $0 ~row {print 0; exit} END{exit 1}' "$HOME/.mentee_not_submit.txt") ]]
                            then
                                new_data=$(awk -v row=$row 'BEGIN{FS=","; match=1;} $0 ~row {Match = 0;} {if (Match!=0){print $1,$2,$3} else {Match=1}}' "$HOME/.mentee_not_submit.txt")
                                echo $new_data > "~/.mentee_not_submit.txt"
                                echo $row >> "~/.mentee_new_submit.txt"
                            fi
                        elif [[ ${task_submit_sysad[$i]} == 'n' ]]
                        then
                            echo "$row" >> "~/.mentee_not_submit.txt"
                        fi
                    done 
                mentee_number_sysad=$mentee_number_sysad+1 
                fi
 
 
            done 
        fi
        mentee_number=$mentee_number+1
    done


    if [[ $1 == '' ]]
    then 
        for i in {0..2}
        do  
            total=$(( ${task_web[$i]}+ ${task_app[$i]}+${task_sysad[$i]} ))
            cal=$(echo $total $mentee_number | awk '{result = $1 / $2; print 100*result}')
            echo "The percentage of mentees who have submitted task $i is $cal"
        done
        echo "The mentees who have newly submitted their tasks are : "
        echo "web"
        awk 'BEGIN {FS=","; OFS=" "} $2 ~/web/{print $1,"task",$3+1} ' "$HOME/.mentee_new_submit.txt"

        echo "app"
        awk 'BEGIN {FS=","; OFS=" "} $2 ~/app/{print $1,"task",$3+1} '  "$HOME/.mentee_new_submit.txt"

        echo "sysad"
        awk 'BEGIN {FS=","; OFS=" "} $2 ~/sysad/{print $1,"task",$3+1}' "$HOME/.mentee_new_submit.txt"

        rm -f "~/.mentee_new_submit.txt"

    elif [[ $1 == 'web' ]]
    then
        for i in {0..2}
        do 
            cal=$( echo ${task_web[$i]} $mentee_number_web | awk '{result = $1 / $2; print 100*result}' )
            echo "The percentage of mentees who have submitted task $i is $cal"
        done
        echo "The mentees who have newly submitted their tasks are : "
        awk 'BEGIN {FS=","; OFS=" "} $2 ~/web/{print $1,"task",$3+1}' "$HOME/.mentee_new_submit.txt"

        rm -f "~/.mentee_new_submit.txt"

    elif [[ $1 == 'app' ]]
    then
        for i in {0..2}
        do 
            cal=$( echo ${task_app[$i]} $mentee_number_app | awk '{result = $1 / $2; print 100*result}' )
            echo "The percentage of mentees who have submitted task $i is $cal"
        done
        echo "The mentees who have newly submitted their tasks are : "
        awk 'BEGIN {FS=","; OFS=" "} $2 ~/app/{print $1,"task",$3+1}' "$HOME/.mentee_new_submit.txt"

        rm -f "~/.mentee_new_submit.txt"

    elif [[ $1 == 'sysad' ]]
    then
        for i in {0..2}
        do 
            cal=$( echo ${task_sysad[$i]} $mentee_number_sysad | awk '{result = $1 / $2; print 100*result}' )
            echo "The percentage of mentees who have submitted task $i is $cal"
        done
        echo "The mentees who have newly submitted their tasks are : "
        awk 'BEGIN {FS=","; OFS=" "} $2 ~/sysad/{print $1,"task",$3+1}' "$HOME/.mentee_new_submit.txt"

        rm -f "~/.mentee_new_submit.txt"

    fi

}

displayStatusCheck_func ()
{

    declare -l domain_asked
    domain_asked=$1
    if [[ $domain_asked == '' ]] || [[ $domain_asked == 'web' ]] || [[ $domain_asked == 'app' ]] || [[ $domain_asked == 'sysad' ]]
    then
        displayStatus_func $domain_asked
    else
        echo "Provide a valid domain"
    fi
}



checkforcore_func ()
{
    incore=1
    grouplist=$(groups)
    for grp in $grouplist
    do
        if [[ $grp == "core_grp" ]]
        then
            incore=0
            break
        fi
    done

    if [[ $incore -eq 0 ]]
    then
        displayStatusCheck_func $1
    else
        echo "The current user is not core. Only core can use this alias" 
    fi
}
alias displayStatus="check_func"
