#!/bin/bash

TESTURL="localhost:8080/samplewar"

log()
{
  echo -e "[`date '+%Y-%m-%d %T'`]:" $1
}


launch_container()
{
  log "INFO: Begin Docker container creation"
  IMG=$1
  BUILDDIR=$(pwd)
  mkdir sanity

  CID=$(/usr/bin/docker run -itd --name testc -p 8080:8080 -v ${BUILDDIR}/sanity:/opt/jboss/wildfly/standalone/log ${IMG})

  if [ $? -ne "0" ]; then
     log "ERROR: Couldnt create Docker Container"
     exit 1
  else
     sleep 15
     log "INFO: Container Launch Initiated ${CID}"
  fi
  
  log "INFO: Completed  Docker container creation"
}

test_container()
{
 log "INFO: Begin Docker Sanity check"

 TESTCASES=("HttpCheck", "LogCheck")
 TURL=$1
 RETVAR=0

 for TC in "${TESTCASES[@]}"
 do
   log "INFO: Running TestCase: $TC"
   
   if [ ${TC} == "HttpCheck" ]; then

     curl -is --max-redirs 10 http://$TURL -L | grep -w "200 OK"
     if [ $? -ne "0" ]; then
        log "ERROR: TESTCASE: $TC FAILED"
        RETVAR=$((RETVAR + 1))
     else
        log "INFO: TESTCASE: $TC PASSED"
     fi
    
   else
  
     CWD=$(pwd)
     if [ -f ${CWD}/sanity ]; then
        log "ERROR: TESTCASE: $TC FAILED"
        RETVAR=$((RETVAR + 1))
     else
        log "INFO: TESTCASE: $TC PASSED"
     fi
        
   fi
 done

 log "INFO: Completed Docker Sanity check"
 return ${RETVAR}
}

cleanup()
{
 log "INFO: Cleaning up Docker Container"
 CNAME=$1
 /usr/bin/docker rm $CNAME --force
 if [ $? -ne "0" ]; then
    log "ERROR: Couldnt delete Docker Container"
    exit 1
  fi
  rm -rf sanity/
 log "INFO: Deleted Docker Container"
}

#MAIN#
launch_container $1
test_container ${TESTURL}
TRET=$?
cleanup testc
if [ ${TRET} -ne "0" ]; then
  exit 1
fi

