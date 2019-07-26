XSOCK=/tmp/.X11-unix
XAUTH=/tmp/.docker.xauth
rm $XAUTH
touch $XAUTH
xauth nlist $DISPLAY | sed -e 's/^..../ffff/' | xauth -f $XAUTH nmerge -

docker run -it \
  --device /dev/video0 \
  --env="DISPLAY" \
  --volume $XSOCK:$XSOCK:rw \
  --volume $XAUTH:$XAUTH \
  --env="XAUTHORITY=${XAUTH}" \
  --ipc host \
  --volume $PWD:/app \
  alpr-unconstrained \
  /bin/bash -c \
  "source activate alprEnv > ~/.bashrc &&
   export PATH=/opt/conda/envs/alprEnv/bin:$PATH && 
   ./run.sh -i /app/jpegs -o /tmp/output -c /tmp/output/results.csv"

#  /bin/bash -c \
#  "source activate alprEnv > ~/.bashrc && export PATH=/opt/conda/envs/alprEnv/bin:$PATH && spyder --workdir=/app"
