#!/bin/bash
echo "git add ."
git add .

echo ""
echo "**************************"
echo "git commit"
git commit -m "modify"


echo ""
echo "**************************"
echo "git pull"
git pull


echo ""
echo "**************************"
echo "git push"
git push

echo ""
echo "**************************"
echo "remote git pull"
ssh root@120.48.26.59  /opt/wiki/command.sh
