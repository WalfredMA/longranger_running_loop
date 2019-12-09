#!/bin/bash

ids="$1"
time0=300
logfile='checkinglog.txt'

checklogpath='/mnt/speed/maw/log'

running=()
pids=()
user="maw"
echo "start checking $ids of $user"


IFS=';' read -ra eachid <<< "$ids"

running+=${eachid[@]}

while [[ ${#running[@]} -ne 0 ]] ; do

i=-1
newpids=()
newrunning=()
for id in ${running[@]}
do

i=$i+1
pid=${pids[$i]}
echo "checking $id"
echo "checking $id" >> $logfile

alljobs="$(qstat | grep $user | grep "\ $id")"

newpid=$(echo "$alljobs" | grep -o "^\w*\b")
newpid="${newpid//$'\n\n'/$'\n'}"
newpid="${newpid//$'\n'/\|}"
echo $alljobs >> $logfile
echo $'\n' >> $logfile

IFS=$'\n' read -ra alljobs <<< "$alljobs"

if [ ${#alljobs[@]} = 0 ]
then
	IFS=' ' read -ra pid <<<$pid 
	IFS=$'\n' read -ra alllogfiles <<< "$(ls "$checklogpath" -t | grep "$id" | grep "$pid" | head -1)"
	echo "checking $alllogfiles"
	echo "checking $alllogfiles" >> $logfile
	if [ ${#alllogfiles[@]} = 0 ]
	then 
		qsub -N $id -l hostname='(ihg-node-2|ihg-node-3|ihg-node-4|ihg-node-5)' ~/longranger_run_ihg.sh $id
		echo "resub $id $(date)" >> $logfile
		newrunning+=($id)
		newpids+=($pid)
	else
		tail  "$checklogpath/$alllogfiles"  >> $logfile
		IFS=$'\n' read -ra check <<< "$(tail -20 "$checklogpath/$alllogfiles" | grep 'Pipestance completed successfully!')"
		echo ${check[@]}
		if [ ${#check[@]} = 0 ]
		then 
			qsub -N $id -l hostname='(ihg-node-2|ihg-node-3|ihg-node-4|ihg-node-5)' ~/longranger_run_ihg.sh $id
			echo "resub $id $(date)" >> $logfile
			newrunning+=($id)
			newpids+=($pid)
		fi
	fi
else
	newrunning+=($id)
	newpids+=($newpid)
fi
done

unset running
running=()
running+=("${newrunning[@]}")
unset pids
pids=()
pids+=("${newpids[@]}")

if [ ${#running[@]} -ne 0 ]
then 
	sleep $time0
fi

done 
