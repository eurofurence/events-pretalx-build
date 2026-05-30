FROM python:3.14-trixie

RUN apt-get update && \
    apt-get install -y git gettext libmariadb-dev libpq-dev locales libmemcached-dev build-essential \
            supervisor \
            locales \
            --no-install-recommends && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    dpkg-reconfigure locales && \
    locale-gen C.UTF-8 && \
    /usr/sbin/update-locale LANG=C.UTF-8 && \
    mkdir /etc/pretalx && \
    mkdir /data && \
    mkdir /public && \
    groupadd -g 999 pretalxuser && \
    useradd -r -u 999 -g pretalxuser -d /pretalx -ms /bin/bash pretalxuser

ENV LC_ALL=C.UTF-8

COPY --chown=pretalxuser:pretalxuser pretalx/pyproject.toml /pretalx
COPY --chown=pretalxuser:pretalxuser pretalx/src /pretalx/src
COPY --chown=root:root deployment/docker/pretalx.bash /usr/local/bin/pretalx
COPY --chown=root:root deployment/docker/supervisord.conf /etc/supervisord.conf

RUN pip3 install -U pip setuptools wheel typing && \
    pip3 install -e /pretalx/[mysql,postgres,redis] && \
    pip3 install pylibmc && \
    pip3 install gunicorn && \
    pip3 install git+https://github.com/tjarbo/pretalx-social-auth.git@v1.0.0-alpha.3

RUN apt-get update && \
    apt-get install -y nodejs npm && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN chmod +x /usr/local/bin/pretalx

RUN python3 -m pretalx makemigrations && \
    python3 -m pretalx migrate && \
    python3 -m pretalx rebuild && \
    rm -f /pretalx/src/pretalx.cfg && \
    rm -f /pretalx/src/data/.secret && \
    chown -R pretalxuser:pretalxuser /pretalx /data /public /etc/pretalx

USER pretalxuser

VOLUME ["/etc/pretalx", "/data", "/public"]
EXPOSE 80
ENTRYPOINT ["pretalx"]
CMD ["all"]
