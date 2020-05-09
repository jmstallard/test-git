#!/bin/bash
# Purpose: Counts the number of lines of code within a date range.
# Author: Jim Stallard/OWCS Team
# Assumptions: all repos are available

REPO_PREFIX="dev"
repoStats() {
echo "In repoStats"
pwd
if [[ -f .git/config ]]; then
		 	url=`grep url .git/config`
		else
			echo "Usage: From git repo root directory:\n"
			echo " $0 <start-date> <end-date>"
			echo " using format yyyy-mm-dd"
			exit 1
	fi
	b=`git log  --since \"$1\" --until \"$2\" |grep commit|tail -1|sed 's/commit //'`
	e=`git log  --since \"$1\" --until \"$2\" |grep commit|head -1|sed 's/commit //'`
	
	echo "starting at ${b}"
	echo "ending at ${e}"
	
	echo "Stats:"
	echo "RUNNING THIS COMMAND >>>>>s=git diff --full-diff --shortstat $b $e <<<<<<<<<<<<<<"
	s=`git diff --full-diff --shortstat $b $e`
	echo $s
	echo  "Statistics for REPO $url from $1 to $2;Number of Insertions; Number of Deletions; Total Changes\n"
	echo  $s|awk -F" " '{printf(";%d;%d;%d\n",$4, $6, $4 + $6)}' >> /tmp/report_$$
	echo  $s|awk -F" " '{printf(";%d;%d;%d\n",$4, $6, $4 + $6)}' 
	#for f in $(git diff --name-status $b $e |sed 's/^A//'); do echo $f; done|xargs wc -l
	#for f in $(git diff --name-status $b $e |sed 's/^A//'); do echo $f; done;
}

#git clone --branch $4 $3 tempRepo

genstat() {
	echo "in genstat"
	echo "3=${3}"
	cd ~/${REPO_PREFIX}/${3}
	pwd
	echo "Iterating over branches"
	for b in $(git branch -r|cut -d'/' -f2);do 
		echo "calling repoStats with branch $b"
		git checkout $b
		git fetch origin $b
		repoStats $1 $2
	done
	cd ~/dev
}

readarray a < ~/bin/repolist
len=${#a[@]}
for (( i=0; i<$len; i++)); do
	echo "calling gen with these parameters: $1 $2 ${a[$i]}"
	genstat $@ ${a[$i]}
done
