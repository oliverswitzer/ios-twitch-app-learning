#!/bin/sh

WIREMOCK_DIR=`dirname $0`
MAPPINGS_DIR="$WIREMOCK_DIR"
PORT=8082
START=true
STOP=false
RECORD=false
API_URL="http://twitch.cfapps.io/"
MATCH_HEADERS="Accept,Content-Type,Authorization"

function usage
{
    echo "Usage:"
    echo "\twiremock.sh -k|r [-h] [-m <mappings_dir>]"
    echo
    echo "\t-k --kill - stop server"
    echo "\t-m --mappings <mappings_dir> - start server with mocks from <mappings_dir>"
    echo "\t-r --record - start wiremock in recording mode"
    echo "\t-h --help - this screen"
}

while [ -n "$1" ]
do
    case $1 in
        -m | --mappings )
            shift
            MAPPINGS_DIR="$1"
            ;;
        -k | --kill )
            START=false
            STOP=true
            RECORD=false
            ;;
        -r | --record )
            START=false
            STOP=false
            RECORD=true
            ;;
        -h | --help )
            usage
            exit
            ;;
        * )
            usage
            exit 1
    esac
    shift
done

mkdir -p $WIREMOCK_DIR/logs

if [ "$START" == true ]
then
    exec > $WIREMOCK_DIR/logs/play.log
    echo "Starting Wiremock in play mode on port $PORT with mappings from $MAPPINGS_DIR"
    java -jar $WIREMOCK_DIR/wiremock.jar --verbose --port $PORT --root-dir $MAPPINGS_DIR &
elif [ "$STOP" == true ]
then
    exec > $WIREMOCK_DIR/logs/stop.log
    echo "Stopping Wiremock on localhost:$PORT & $AUTH_PORT"
    curl -X POST --data '' "http://localhost:$PORT/__admin/shutdown"
elif [ "$RECORD" == true ]
then
    exec > $WIREMOCK_DIR/logs/record.log
    echo "Starting Wiremock in record mode on port $PORT"
    echo "Storing mappings to $MAPPINGS_DIR"
    java -jar $WIREMOCK_DIR/wiremock.jar --proxy-all "$API_URL" --record-mappings --match-headers "$MATCH_HEADERS" --verbose --port $PORT --root-dir $MAPPINGS_DIR &
fi
