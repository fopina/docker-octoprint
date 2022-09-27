ARG BASE=python:3.9-slim

##### BASE

FROM ${BASE} as base-armv7
ADD pip.armv7.conf /etc/pip.conf

FROM ${BASE} as base-amd64

FROM base-armv7 as base-arm64

# ==== CLEAN BASE ====
FROM base-${TARGETARCH}${TARGETVARIANT} as base

##### MAIN

FROM base as builder

RUN apt update \
 && apt install -y gcc \
 && rm -rf /var/lib/apt/lists/*

ADD requirements.txt /
# need to build the wheels first because of qemu
RUN --mount=type=cache,target=/wheels \
    cp /requirements.txt /wheels \
 && pip wheel -r /requirements.txt --wheel-dir=/wheels \
 && rm -fr /root/.cache/pip/

FROM base

# curl for scripts
RUN apt update \
 && apt install -y curl \
 && rm -rf /var/lib/apt/lists/*

# crazy noop to force buildkit to build previous stage
COPY --from=builder /etc/passwd /etc/passwd

RUN --mount=type=cache,target=/wheels \
    pip install --find-links=/wheels -r /wheels/requirements.txt \
 && rm -fr /root/.cache/pip/

ENV PYTHONPATH="/root/.octoprint/plugin_persist/lib/python2.7/site-packages/:${PYTHONPATH}"

ADD pip.conf /etc/pip.conf

VOLUME [ "/root/.octoprint" ]
EXPOSE 5000

ADD entrypoint.sh /entrypoint.sh

ENTRYPOINT [ "/entrypoint.sh" ]

CMD [ "serve", "--iknowwhatimdoing" ]
