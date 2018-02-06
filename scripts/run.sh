docker run \
  -p 80:8080 \
  -v /home/amotov/Temp:/usr/share/fm/files/writable \
  -v /home/amotov/Work:/usr/share/fm/files/readonly \
  -e FM_HEAP_SIZE=1024m \
  --name file-manager \
  -d kcell/file-manager:latest