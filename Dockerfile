# alpine needs to build to many wheels, use slim (or set up pip cache in github builders)
FROM python:3.7-slim as builder

RUN apt update \
 && apt install -y gcc \
 && rm -rf /var/lib/apt/lists/*

ADD requirements.txt /
# need to build the wheels first because of qemu
RUN --mount=type=cache,target=/wheels \
    cp /requirements.txt /wheels \
 && pip wheel -r /requirements.txt --wheel-dir=/wheels \
 && rm -fr /root/.cache/pip/

FROM python:3.7-slim

# curl for scripts
RUN apt update \
 && apt install -y curl \
 && rm -rf /var/lib/apt/lists/*

# crazy noop to force buildkit to build previous stage
COPY --from=builder /etc/passwd /etc/passwd

RUN --mount=type=cache,target=/wheels \
    pip install --find-links=/wheels -r /wheels/requirements.txt \
 && rm -fr /root/.cache/pip/

COPY pip.conf /etc/pip.conf

ENV PYTHONPATH="/root/.octoprint/plugin_persist/lib/python2.7/site-packages/:${PYTHONPATH}"

VOLUME [ "/root/.octoprint" ]
EXPOSE 5000

ADD entrypoint.sh /entrypoint.sh

ENTRYPOINT [ "/entrypoint.sh" ]

CMD [ "serve", "--iknowwhatimdoing" ]
