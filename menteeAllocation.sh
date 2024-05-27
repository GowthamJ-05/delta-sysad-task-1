#!/bin/bash
web_Mentor_Allocation_func ()
{

    declare -a Mentor_array_web
    declare -a Mentee_capacity_array_web
    
    webdevlist=$(curl -s https://inductions.delta.nitt.edu/sysad-task1-mentorDetails.txt | cat | awk 'BEGIN{FS=" "; OFS=","} $0 !~/^Name/{if ($2 ~ /web/) print $3,$1 ;}' \
 | sort -k1,1nr)
    declare -i j
    j=0
    for i in $webdevlist
    do
        Mentor_array_web[$j]=${i#*,}
        declare -i Mentee_capacity_array_web[$j]
        Mentee_capacity_array_web[$j]=${i%,*}
        j=$j+1
    done


    declare -a rollnolist_web
    menteelist_web=$(awk 'BEGIN{FS=" "} $0 !~/Rollno Name Domain/{if ($3 ~/.*web.*/) print $2 ;}' $1)
    rollnolist_web=($(awk 'BEGIN{FS=" "} $0 !~/Rollno Name Domain/{if ($3 ~/.*web.*/) print $1 ;}' $1))
    declare -i j
    j=0
    n=${#Mentor_array_web[@]}
    for mentee in $menteelist_web
    do 
        if [[ ${Mentee_capacity_array_web[$j]} -ne 0 ]]
        then
            echo "${rollnolist_web[$j]} $mentee" >> ~/mentors/Webdev/${Mentor_array_web[$j]}/Alottedmentees.txt
            Mentee_capacity_array_web[$j]=${Mentee_capacity_array_web[$j]}-1
            j=$(( (j+1) % n ))
        else
            j=$(( (j+1) % n ))
        fi
    done
}

app_Mentor_Allocation_func ()
{

    declare -a Mentor_array_app
    declare -a Mentee_capacity_array_app
    
    appdevlist=$(curl -s https://inductions.delta.nitt.edu/sysad-task1-mentorDetails.txt | cat | awk 'BEGIN{FS=" "; OFS=","} $0 !~/^Name/{if ($2 ~ /app/) print $3,$1 ;}' \
 | sort -k1,1nr)
    declare -i j
    j=0
    for i in $appdevlist
    do
        Mentor_array_app[$j]=${i#*,}
        declare -i Mentee_capacity_array_app[$j]
        Mentee_capacity_array_app[$j]=${i%,*}
        j=$j+1
    done


    declare -a rollnolist_app
    menteelist_app=$(awk 'BEGIN{FS=" "} $0 !~/Rollno Name Domain/{if ($3 ~/.*app.*/) print $2 ;}' $1)
    rollnolist_app=($(awk 'BEGIN{FS=" "} $0 !~/Rollno Name Domain/{if ($3 ~/.*app.*/) print $1 ;}' $1))
    declare -i j
    j=0
    n=${#Mentor_array_app[@]}
    for mentee in $menteelist_app
    do 
        if [[ ${Mentee_capacity_array_app[$j]} -ne 0 ]]
        then
            echo "${rollnolist_app[$j]} $mentee" >> ~/mentors/Appdev/${Mentor_array_app[$j]}/Alottedmentees.txt
            Mentee_capacity_array_app[$j]=${Mentee_capacity_array_app[$j]}-1
            j=$(( (j+1) % n ))
        else
            j=$(( (j+1) % n ))
        fi
    done
}

sysad_Mentor_Allocation_func ()
{
    

    declare -a Mentor_array_sysad
    declare -a Mentee_capacity_array_sysad

    sysadlist=$(curl -s https://inductions.delta.nitt.edu/sysad-task1-mentorDetails.txt | cat | awk 'BEGIN{FS=" "; OFS=","} $0 !~/^Name/{if ($2 ~ /sysad/) print $3,$1 ;}' \
 | sort -k1,1nr)
    declare -i j
    j=0
    for i in $sysadlist
    do
        Mentor_array_sysad[$j]=${i#*,}
        declare -i Mentee_capacity_array_sysad[$j]
        Mentee_capacity_array_sysad[$j]=${i%,*}
        j=$j+1
    done


    declare -a rollnolist_sysad
    menteelist_sysad=$(awk 'BEGIN{FS=" "} $0 !~/Rollno Name Domain/{if ($3 ~/.*sysad.*/) print $2 ;}' $1)
    rollnolist_sysad=($(awk 'BEGIN{FS=" "} $0 !~/Rollno Name Domain/{if ($3 ~/.*sysad.*/) print $1 ;}' $1))
    declare -i j
    j=0
    n=${#Mentor_array_sysad[@]}
    for mentee in $menteelist_sysad
    do 
        if [[ ${Mentee_capacity_array_sysad[$j]} -ne 0 ]]
        then
            echo "${rollnolist_sysad[$j]} $mentee" >> ~/mentors/Sysad/${Mentor_array_sysad[$j]}/Alottedmentees.txt
            Mentee_capacity_array_sysad[$j]=${Mentee_capacity_array_sysad[$j]}-1
            j=$(( (j+1) % n ))
        else
            j=$(( (j+1) % n ))
        fi
    done
}


mentorAlloc ()
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
        web_Mentor_Allocation_func $1
        app_Mentor_Allocation_func $1
        sysad_Mentor_Allocation_func $1

        echo "Mentor Allocation done sucessfully" 
    else
        echo "The current user is not core. Only a core can use this alias" 
    fi
    
}


alias mentorAllocation="mentorAlloc ~/mentee_domain.txt"
