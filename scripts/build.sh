DIRECTORY=`dirname $0`

docker build -t kcell/file-manager:latest -f $DIRECTORY/../Dockerfile .