#!/bin/bash

INGRESS_POD=nginx-ingress-controller-3321030678-7l00q

(cd logs && rm *.log)
mkdir -p logs

while true; do
  TIME=`date +'%Y-%m-%d_%H-%M-%S.%N'`
  LOGFILE=logs/$TIME.log
  touch $LOGFILE

  echo "logging for $TIME..."

  echo "current pod states" >> $LOGFILE
  echo "--------------------------------------------------------" >> $LOGFILE
  kubectl get pods -o wide --selector=app=backend >> $LOGFILE

  echo "" >> $LOGFILE
  echo "current nginx configuration" >> $LOGFILE
  echo "--------------------------------------------------------" >> $LOGFILE
  kubectl exec $INGRESS_POD cat /etc/nginx/nginx.conf | head -n 157 | tail -n 15 >> $LOGFILE

  sleep 0.5
done
