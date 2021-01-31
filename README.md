# docker-octoprint
docker image for Octoprint


* Runs on port 5000
* `/root/.octoprint` can be mounted to persist configuration
* `PYTHONPATH` and `pip` configured to install plugins in `/root/.octoprint` so they are persisted as well
* Use `MKNOD` env var to specify an initial `mknod` command, in case you want the image to start even if the device does not exist (ie: printer turned off):
  * need to use `--privileged` or `--device-cgroup-rules` instead of `--device`
  * eg: `-e MKNOD="/dev/ttyACM0 c 166 0"`

## Usage

```
docker run -p 5000:5000 \
           -v delme:/root/.octoprint \
           --device /dev/YOURTTY:/dev/YOURTTY \
           fopina/octoprint:latest
```
