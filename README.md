# docker-octoprint
docker image for Octoprint


* Runs on port 5000
* `/root/.octoprint` can be mounted to persist configuration
* `PYTHONPATH` and `pip` configured to install plugins in `/root/.octoprint` so they are persisted as well

## Usage

```
docker run -p 5000:5000 \
           -v delme:/root/.octoprint \
           fopina/octoprint:latest
```
