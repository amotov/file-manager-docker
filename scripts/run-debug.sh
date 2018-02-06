docker run -it \
  -p 80:8080 \
  -v /home/amotov/Temp:/usr/share/fm/files/writable \
  -v /home/amotov/Work:/usr/share/fm/files/readonly \
  --name file-manager \
  kcell/file-manager:latest
  /bin/bash