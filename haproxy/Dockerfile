FROM haproxy:1.6

RUN mkdir /etc/haproxy
RUN ln -s /etc/haproxy/haproxy.cfg /usr/local/etc/haproxy/haproxy.cfg

VOLUME /tmp/haproxy.status.sock
VOLUME /var/run/haproxy.pid
VOLUME /etc/haproxy/haproxy.cfg
