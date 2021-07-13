FROM python:3.7-slim as builder

ARG VERSION=1.6.1

RUN apt update \
 && apt install -y gcc \
 && rm -rf /var/lib/apt/lists/*

# need to build the wheels first because of qemu
RUN --mount=type=cache,target=/wheels \
    pip wheel "OctoPrint==${VERSION}" --wheel-dir=/wheels \
 && rm -fr /root/.cache/pip/

FROM python:3.7-slim

ARG VERSION=1.6.1

# crazy noop to force buildkit to build previous stage
COPY --from=builder /etc/passwd /etc/passwd

RUN --mount=type=cache,target=/wheels \
    pip install --find-links=/wheels "OctoPrint==${VERSION}" \
 && rm -fr /root/.cache/pip/

COPY pip.conf /etc/pip.conf

ENV PYTHONPATH="/root/.octoprint/plugin_persist/lib/python2.7/site-packages/:${PYTHONPATH}"

VOLUME [ "/root/.octoprint" ]
EXPOSE 5000

ADD entrypoint.sh /entrypoint.sh

ENTRYPOINT [ "/entrypoint.sh" ]

CMD [ "serve", "--iknowwhatimdoing" ]
