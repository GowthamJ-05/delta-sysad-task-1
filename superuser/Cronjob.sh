#!/bin/bash
if ![[ -e "$HOME/run_displayStatus.sh" ]]
then
    touch "$HOME/run_displayStatus.sh"
    chmod +x "$HOME/run_displayStatus.sh"
    echo  "#!/bin/bash
    source .bashrc
    displayStatus" > "$HOME/run_displayStatus.sh"
fi

# run display status everyday
cronjob[1]="0 5 * * * $HOME/run_displayStatus.sh"
cronjob[2]="0 5 0,2,4,5 5,6,7 * $HOME/daily_check.sh"
for i in 1 2
do  
    if ! crontab - l | grep -qF ${crontab[$i]}
    then
        (crontab -l 2> /dev/null ;echo "${crontab[$i]}") | crontab -
    else
        echo "Cronjob already added!"
    fi
done

