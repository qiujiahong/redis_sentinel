FROM redis:4.0.11
COPY ./conf/* /etc/redis/

RUN echo "==> start redis..." && \
    mkdir -p /etc/redis && \
    mkdir -p /opt/soft/redis/data  && \
    mkdir -p /var/log/redis &&\
    chmod +x /etc/redis/redis_start.sh && \
    mv /etc/redis/redis_start.sh /usr/bin/ 

ENTRYPOINT ["/usr/bin/redis_start.sh"]