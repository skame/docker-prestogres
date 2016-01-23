FROM ubuntu
ENV PRESTOGRES_VERSION 0.6.7

# explicitly set user/group IDs
RUN groupadd -r postgres --gid=999 && useradd -r -g postgres --uid=999 postgres

RUN sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt/ $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list'
RUN mkdir -p /var/run/postgresql && chown -R postgres /var/run/postgresql
ENV PGDATA /var/lib/postgresql/data

RUN apt-get install -y wget
RUN wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add -
RUN apt-get update
RUN apt-get install -y postgresql-9.3 postgresql-contrib-9.3 postgresql-server-dev-9.3 postgresql-plpython-9.3
RUN apt-get install -y gcc make libssl-dev libpcre3-dev

RUN apt-get install -y python supervisor

ADD https://github.com/treasure-data/prestogres/archive/v${PRESTOGRES_VERSION}.tar.gz prestogres.tar.gz
RUN tar xvfz prestogres.tar.gz && cd prestogres-${PRESTOGRES_VERSION} && ./configure --program-prefix=prestogres- && make && make install
RUN mkdir /var/lib/postgres && chown -R postgres:postgres /var/lib/postgres
RUN su - postgres -c "prestogres-ctl create ${PGDATA}"

#RUN su - postgres -c "postgres -D ${PGDATA} >/tmp/logfile 2>&1 &"
#RUN prestogres-ctl migrate

#CMD su - postgres -c 'prestogres-ctl postgred -D ${PGDATA}/pgdata'

#RUN echo '[supervisord]'  > /etc/supervisord.conf
#RUN echo 'nodaemon=true'  >> /etc/supervisord.conf
#RUN echo '[program:postgres]' >> /etc/supervisord.conf
#RUN echo 'command="su - postgres -c "postgres -D ${PGDATA}"' >> /etc/supervisord.conf
#RUN echo 'autorestart=true' >> /etc/supervisord.conf
#RUN echo '[program:prestogres]'   >> /etc/supervisord.conf
#RUN echo 'command=""'   >> /etc/supervisord.conf

#ENTRYPOINT ["tini", "--"]
#CMD ["/usr/bin/supervisord", "-c", "/etc/supervisord.conf"]
#EXPOSE 8000

COPY start.sh /start.sh
CMD ["/start.sh"]

