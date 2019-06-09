#!/bin/bash
set -eo pipefail
__dirname=$(cd $(dirname "$0"); pwd -P)
cd "${__dirname}"
# Load default values
source .env
DEFAULT_PORT="$WO_PORT"
DEFAULT_HOST="$WO_HOST"
DEFAULT_DIR="$WO_DIR"

# Parse args for overrides
POSITIONAL=()
while [[ $# -gt 0 ]]
do
key="$1"

case $key in
    --port)
    export WO_PORT="$2"
    shift # past argument
    shift # past value
    ;;    
    --hostname)
    export WO_HOST="$2"
    shift # past argument
    shift # past value
    ;;
	--dir)
    export WO_DIR=$(realpath "$2")
    shift # past argument
    shift # past value
    ;;
    *)    # unknown option
    POSITIONAL+=("$1") # save it in an array for later
    shift # past argument
    ;;
esac
done
set -- "${POSITIONAL[@]}" # restore positional parameter

usage(){
  echo "Usage: $0 <command>"
  echo
  echo "This program helps to manage the setup/teardown of the docker containers for running Piwigo. We recommend that you read the full documentation of docker at https://docs.docker.com if you want to customize your setup."
  echo 
  echo "Command list:"
  echo "	start [options]		Start Piwigo"
  echo "	stop			Stop Piwigo"
  echo "	down			Stop and remove Piwigo's docker containers"
  echo "	rebuild			Rebuild all docker containers and perform cleanups"
  echo ""
  echo "Options:"
  echo "	--port	<port>	Set the port that WebODM should bind to (default: $DEFAULT_PORT)"
  echo "	--hostname	<hostname>	Set the hostname that Piwigo will be accessible from (default: $DEFAULT_HOST)"
  echo "	---dir	<path>	Path where data will be persisted (default: $DEFAULTA_DIR (docker named volume))"
  exit
}

run(){
	echo $1
	eval $1
}

start(){
	echo ""
	echo "Using the following environment:"
	echo "================================"
	echo "Host: $WO_HOST"
	echo "Port: $WO_PORT"
	echo "Directory: $WO_DIR"
	echo "================================"
	echo "Make sure to issue a $0 down if you decide to change the environment."
	echo ""

	command="docker-compose -f docker-compose.yml"
	run "$command start || $command up -d"
}

down(){
	run "docker-compose -f docker-compose.yml down --remove-orphans"
}

rebuild(){
	run "docker-compose down --remove-orphans"
	run "docker-compose -f docker-compose.yml build --no-cache"
	echo -e "\033[1mDone!\033[0m You can now start Piwigo by running $0 start"
}

if [[ $1 = "start" ]]; then
	start
elif [[ $1 = "stop" ]]; then
	echo "Stopping Piwigo..."
	run "docker-compose -f docker-compose.yml stop"
elif [[ $1 = "down" ]]; then
	echo "Tearing down Piwigo..."
	down
elif [[ $1 = "rebuild" ]]; then
	echo  "Rebuilding Piwigo..."
	rebuild
else
	usage
fi
