#!/bin/bash
set -eo pipefail
__dirname=$(cd $(dirname "$0"); pwd -P)
cd "${__dirname}"
# Load default values
source .env
DEFAULT_HOST="$WO_HOST"
DEFAULT_DIR="$WO_DIR"

# Parse args for overrides
POSITIONAL=()
while [[ $# -gt 0 ]]
do
key="$1"

case $key in
    --hostname)
    export WO_HOST="$2"
    shift # past argument
    shift # past value
    ;;
	--dir)
    export WO_DIR=$(realpath "$2")
    export WO_DIR_GALLERIES="$WO_DIR/data/galleries"
    export WO_DIR_LOCAL="$WO_DIR/data/local"
    export WO_DIR_PLUGINS="$WO_DIR/data/plugins"
    export WO_DIR_THEMES="$WO_DIR/data/themes"
    export WO_DIR_CACHE="$WO_DIR/cache"
    export WO_DIR_UPLOAD="$WO_DIR/upload"
    export WO_DIR_MYSQL="$WO_DIR/mysql"
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
  echo "	--hostname	<hostname>	Set the hostname that Piwigo will be accessible from (default: $DEFAULT_HOST)"
  echo "	---dir	<path>	Path where data will be persisted (default: $DEFAULT_DIR (docker named volume))"
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
