#!/bin/bash
git add .
git commit -m "modify"
git push

sleep 2s

ssh root@120.48.26.59  /opt/wiki/command.sh
