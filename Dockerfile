FROM python:3.7-slim as builder

RUN apt update \
 && apt install -y gcc \
 && rm -rf /var/lib/apt/lists/*

RUN pip wheel netifaces==0.10.9 \
              psutil==5.8.0 \
              regex==2020.11.13 \
 && rm -fr /root/.cache/pip/

FROM python:3.7-slim

COPY --from=builder /*.whl /tmp/

RUN pip install /tmp/*.whl \
                'OctoPrint==1.5.3' \
 && rm -fr /root/.cache/pip/

COPY pip.conf /etc/pip.conf
ENV PYTHONPATH="/root/.octoprint/plugin_persist/lib/python2.7/site-packages/:${PYTHONPATH}"

VOLUME [ "/root/.octoprint" ]
EXPOSE 5000

ENTRYPOINT [ "/usr/local/bin/octoprint" ]
CMD [ "serve", "--iknowwhatimdoing" ]
