FROM python:2.7-slim as builder

RUN apt update \
 && apt install -y gcc \
 && rm -rf /var/lib/apt/lists/*

RUN pip wheel regex==2020.1.8 \
              psutil==5.6.7 \
              netifaces==0.10.9 \
 && rm -fr /root/.cache/pip/

FROM python:2.7-slim

COPY --from=builder /*.whl /tmp/

RUN pip install /tmp/*.whl \
                OctoPrint==1.3.12 \
 && rm -fr /root/.cache/pip/

VOLUME [ "/root/.octoprint" ]
EXPOSE 5000

ENTRYPOINT [ "/usr/local/bin/octoprint" ]
CMD [ "serve", "--iknowwhatimdoing" ]
