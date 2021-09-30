#!/bin/bash
  if [ -z "$1" ];then
    echo "Usage:  javadump.sh <service_name|PID>"
    exit
  fi
PID=$(ps -ef|grep "$1"|grep -v grep|grep -v javadump.sh|awk '{print $2}')
  if [ "$PID" = "" ];then
    echo "can't find this java process  :  $1"
    exit
  elif [ 1 -lt $(echo $PID|awk '{print NF}') ];then
    echo "find more then one java process"
    ps -ef|grep "$1"|grep -v grep|grep -v javadump.sh |awk '{for(i=1;i<=7;i++){$i=""}; print NR $0}' 
    exit
  fi
curtime=`date +%Y-%m-%d_%H:%M:%S`
echo "PID: ""$PID" - "service: "$1 "      start dump!!!"
DUMP_DIR=/root/jvm_dump/"$1"_"$curtime"_pd
mkdir -p $DUMP_DIR
jmap -dump:format=b,file=$DUMP_DIR/memory_dump.hprof $PID && echo "save memory_dump.hprof"
jstack $PID > $DUMP_DIR/threads.txt && echo "save threads.txt"
ps -hH "$PID"| wc -l > "$DUMP_DIR"/threadCount.txt && echo "save threadCount.txt"
jmap -heap "$PID" > "$DUMP_DIR"/memory_heap.txt && echo "save memory_heap.txt"

jmap -histo:live "$PID" > "$DUMP_DIR"/jmap.txt && echo "save jmap.txt"

jstat -gcutil "$PID" 1000 10 >> "$DUMP_DIR"/gc.txt && echo "save gc.txt"

top n1 -b -H -p "$PID" > "$DUMP_DIR"/top.txt && echo "save top.txt"
