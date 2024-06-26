#!/bin/bash
#This is the start of the program

#======================================================INDUCTION TASK 1=====================================================


setupfunc ()
{
    # Group creation 
    sudo groupadd core_grp
    sudo groupadd mentors_grp
    sudo groupadd mentees_grp

    sudo groupadd web_mentors_grp
    sudo groupadd app_mentors_grp
    sudo groupadd sysad_mentors_grp

    # The core user creation and placing required directories within /home/core
    sudo useradd -m -g core_grp core
    sudo setfacl -m g:sudo:rwx /home/core
    cd /home/core
    mkdir mentees mentors
    cd mentors
    mkdir Webdev Appdev Sysad
    cp ~/$3 /home/core

    # Basic permissions using chmod to restrict access to directories 
    sudo chmod 711 /home/core
    sudo chmod 701 /home/core/mentees
    sudo chmod 700 /home/core/mentors
    sudo chmod 704 /home/core/mentors/Appdev
    sudo chmod 704 /home/core/mentors/Webdev
    sudo chmod 704 /home/core/mentors/Sysad

    # Specific permissions of core to access directories  
    sudo setfacl -m u:core:rwx /home/core/mentees
    sudo setfacl -m u:core:rwx /home/core/mentors
    sudo setfacl -m u:core:rwx /home/core/mentors/Appdev
    sudo setfacl -m u:core:rwx /home/core/mentors/Webdev
    sudo setfacl -m u:core:rwx /home/core/mentors/Sysad

    # Changing the owner of mentee_domain.txt to core
    sudo chown core:core_grp /home/core/$3

    # Permissions to mentee_domain.txt
    sudo chmod 700 /home/core/$3
    sudo setfacl -m g:sudo:rwx /home/core/$3

    # Change core's shell from sh to bash
    sudo usermod -s /bin/bash core

    # Mentee users creation and permission
    mentee_list=$(awk 'BEGIN{OFS="_"} $0 !~/Name RollNo/{print $1,$2}' $2)
    for mentee in $mentee_list
    do 
        # Mentee user creation 
        sudo useradd -m -d /home/core/mentees/$mentee -g mentees_grp $mentee
        sudo setfacl -m g:sudo:rwx /home/core/mentees/$mentee

        # Allow defaults permissions for $mentee
        sudo setfacl -m u:$mentee:rwx /home/core/mentees/$mentee
        sudo setfacl -d -m u:$mentee:rwx /home/core/mentees/$mentee

        # Creation of required files within $mentee's home directory
        cd /home/core/mentees/$mentee
        touch domain_pref.txt task_completed.txt task_submitted.txt

        # Change the ownership of $mentees folder to core
        sudo chown -R core:core_grp /home/core/mentees/$mentee

        # Allow access for core to files created in the future
        sudo setfacl -d -m u:core:rwx /home/core/mentees/$mentee

        # Specific permission for $mentee on task_completed.txt
        sudo setfacl -m u:$mentee:r-- /home/core/mentees/$mentee/task_completed.txt

        # Restrict the mentees_grp access to $mentee
        sudo setfacl -m g::0 /home/core/mentees/$mentee

        # Restrict the others access to $mentee
        sudo setfacl -m o::0 /home/core/mentees/$mentee

        # Allow write access to mentee_domain.txt
        sudo setfacl -m u:$mentee:rw- /home/core/$3

        # Change the mentee's shell from sh to bash
        sudo usermod -s /bin/bash $mentee

        # Deny $mentee the read permissions of / and /home
        sudo setfacl -m u:$mentee:--x /
        sudo setfacl -m u:$mentee:--x /home
    done

    # Mentors users creation and permission

    # Webdev Mentors
    webdev_mentor_list=$(awk 'BEGIN{FS=" ";} $0!~/^Name/{if ($2 ~ /web/) print $1;}' $1)
    for mentor in $webdev_mentor_list
    do
        
        # Mentor user creation 
        sudo useradd -m -d /home/core/mentors/Webdev/$mentor -g mentors_grp $mentor
        sudo usermod -aG  web_mentors_grp $mentor
        sudo setfacl -m g:sudo:rwx /home/core/mentors/Webdev/$mentor

        # Allow defaults permissions for $mentor
        sudo setfacl -m u:$mentor:rwx /home/core/mentors/Webdev/$mentor
        sudo setfacl -d -m u:$mentor:rwx /home/core/mentors/Webdev/$mentor
        
        # Creation of required files and directories within $mentor's home directory
        cd /home/core/mentors/Webdev/$mentor
        touch Alottedmentees.txt
        mkdir submitted_tasks
    
        # Creation of required directories within submitted_tasks
        cd submitted_tasks
        mkdir task1 task2 task3

        # Change the ownership of $mentor folder to core
        sudo chown -R core:core_grp /home/core/mentors/Webdev/$mentor

        # Allow access for core to files created in the future
        sudo setfacl -d -m u:core:rwx /home/core/mentors/Webdev/$mentor

        # Restrict the mentors_grp access to $mentor
        sudo setfacl -m g::0 /home/core/mentors/Webdev/$mentor
        
        # Restrict the others access to $mentor
        sudo setfacl -m o::0 /home/core/mentors//Webdev/$mentor
    
        # Change the mentor's shell from sh to bash
        sudo usermod -s /bin/bash $mentor
    
        # Allow $mentor access to /home/core, /home/core/mentees, /home/core/mentors, /home/core/mentors/Webdev 
        sudo setfacl -m u:$mentor:r-x /home/core 
        sudo setfacl -m u:$mentor:r-x /home/core/mentees
        sudo setfacl -m u:$mentor:r-x /home/core/mentors
        sudo setfacl -m u:$mentor:r-x /home/core/mentors/Webdev 


        # Deny $mentee the read permissions of / and /home
        sudo setfacl -m u:$mentor:--x /
        sudo setfacl -m u:$mentor:--x /home

    done

    #Appdev Mentors    
    appdev_mentor_list=$(awk 'BEGIN{FS=" ";} $0!~/^Name/{if ($2 ~ /app/) print $1;}' $1)
    for mentor in $appdev_mentor_list
    do
        # Mentor user creation and placing required files within $mentor's home directory
        sudo useradd -m -d /home/core/mentors/Appdev/$mentor -g mentors_grp $mentor
        sudo usermod -aG  app_mentors_grp $mentor
        sudo setfacl -m g:sudo:rwx /home/core/mentors/Appdev/$mentor

        # Allow defaults permissions for $mentor
        sudo setfacl -m u:$mentor:rwx /home/core/mentors/Appdev/$mentor
        sudo setfacl -d -m u:$mentor:rwx /home/core/mentors/Appdev/$mentor

        # Creation of required files and directories within $mentor's home directory
        cd /home/core/mentors/Appdev/$mentor
        touch Alottedmentees.txt
        mkdir submitted_tasks

        # Creation of required directories within submitted_tasks
        cd submitted_tasks
        mkdir task1 task2 task3

        # Change the ownership of $mentor folder to core
        sudo chown -R core:core_grp /home/core/mentors/Appdev/$mentor

        # Allow access for core to files created in the future
        sudo setfacl -d -m u:core:rwx /home/core/mentors/Appdev/$mentor

        # Restrict the mentors_grp access to $mentor
        sudo setfacl -m g::0 /home/core/mentors/Appdev/$mentor

        # Restrict the others access to $mentor
        sudo setfacl -m o::0 /home/core/mentors/Appdev/$mentor

        # Change the mentor's shell from sh to bash
        sudo usermod -s /bin/bash $mentor


        # Allow $mentor access to /home/core, /home/core/mentees, /home/core/mentors, /home/core/mentors/Appdev 
        sudo setfacl -m u:$mentor:r-x /home/core 
        sudo setfacl -m u:$mentor:r-x /home/core/mentees
        sudo setfacl -m u:$mentor:r-x /home/core/mentors
        sudo setfacl -m u:$mentor:r-x /home/core/mentors/Appdev 


        # Deny $mentor the read permissions of / and /home
        sudo setfacl -m u:$mentor:--x /
        sudo setfacl -m u:$mentor:--x /home

    done

    # Sysad Mentors
    sysad_mentor_list=$(awk 'BEGIN{FS=" ";} $0!~/^Name/{if ($2 ~ /sysad/) print $1;}' $1)
    for mentor in $sysad_mentor_list
    do
        # Mentor user creation and placing required files within $mentor's home directory
        sudo useradd -m -d /home/core/mentors/Sysad/$mentor -g mentors_grp $mentor
        sudo usermod -aG  sysad_mentors_grp $mentor
        sudo setfacl -m g:sudo:rwx /home/core/mentors/Sysad/$mentor

        # Allow defaults permissions for $mentor
        sudo setfacl -m u:$mentor:rwx /home/core/mentors/Sysad/$mentor
        sudo setfacl -d -m u:$mentor:rwx /home/core/mentors/Sysad/$mentor
   
        # Creation of required files and directories within $mentor's home directory
        cd /home/core/mentors/Sysad/$mentor
        touch Alottedmentees.txt
        mkdir submitted_tasks

        # Creation of required directories within submitted_tasks
        cd submitted_tasks
        mkdir task1 task2 task3

        # Change the ownership of $mentor folder to core
        sudo chown -R core:core_grp /home/core/mentors/Sysad/$mentor

        # Allow access for core to files created in the future
        sudo setfacl -d -m u:core:rwx /home/core/mentors/Sysad/$mentor

        # Restrict the mentors_grp access to $mentor
        sudo setfacl -m g::0 /home/core/mentors/Sysad/$mentor

        # Restrict the others access to $mentor
        sudo setfacl -m o::0 /home/core/mentors/Sysad/$mentor

        # Change the mentor's shell from sh to bash
        sudo usermod -s /bin/bash $mentor

        # Allow $mentor access to /home/core, /home/core/mentees, /home/core/mentors, /home/core/mentors/Sysad 
        sudo setfacl -m u:$mentor:r-x /home/core 
        sudo setfacl -m u:$mentor:r-x /home/core/mentees
        sudo setfacl -m u:$mentor:r-x /home/core/mentors
        sudo setfacl -m u:$mentor:r-x /home/core/mentors/Sysad 


        # Deny $mentor the read permissions of / and /home
        sudo setfacl -m u:$mentor:--x /
        sudo setfacl -m u:$mentor:--x /home

    done

    return 0

}


#usergen
usergen_func ()
{
    if [[ -e /home/core ]]
    then
        echo "Users and permissions have already been setup"
        read -p "Do you want to override them? (Y/n)" opinion
        if [[ $opinion = "Y" || $opinion = "y" ]]
        then 
            thepwd=$(pwd)
            setupfunc $1 $2 $3 2> /dev/null >&2
            echo "Users and permissions have been done successfully"
        fi
        
    else
        thepwd=$(pwd)
        setupfunc $1 $2 $3 2> /dev/null >&2
        echo "Users and permissions have been done successfully"
        cd $thepwd
    fi
}

alias usergen="usergen_func $HOME/mentor_details.txt $HOME/mentee_details.txt mentee_domain.txt"     #Assuming the .txt files are present in sysadm's home directory along with the .bashrc file




