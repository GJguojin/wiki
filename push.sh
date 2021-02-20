#!/bin/bash

# 判断参数1是否包含参数2
contains_str(){
    # echo " >>> $1 <<< "
    # echo " <<< $2"
    
    contains_result=$(echo $1 | grep "${2}")
    if [[ -n $contains_result  ]] ; then
          return 1
      else
          return 0     
    fi
    
}
time=$(date "+%Y%m%d%H%M%S")
echo "time $time"

echo ""
echo "**************************"
echo "git add ."
git add .

echo ""
echo "**************************"
echo "git commit"
commit_msg="modify${time}"
git commit -m $commit_msg


echo ""
echo "**************************"
echo "git pull"
git pull


echo ""
echo "**************************"
echo "git push"

pushResult=$(git push)
echo "pushResult:${pushResult}"
no_push="Everything up-to-date"
if [ $pushResult = $no_push ]; then
    echo "=== ${Everything up-to-dat} ==="
else
	echo ""
	echo "**************************"
	echo "remote git pull"
	ssh root@120.48.26.59  /opt/wiki/command.sh
fi


