FROM kevineye/centos
MAINTAINER Kevin Eye <kevineye@gmail.com>

RUN rpm -Uvh http://download.fedoraproject.org/pub/epel/6/i386/epel-release-6-8.noarch.rpm \
 && rpm --nosignature -i https://repo.varnish-cache.org/redhat/varnish-4.0.el6.rpm \
 && yum -y install varnish python-setuptools \
 && yum clean all

COPY . /app

RUN easy_install supervisor \
 && curl -L -o /usr/local/bin/confd https://github.com/kelseyhightower/confd/releases/download/v0.7.0-beta1/confd-0.7.0-linux-amd64 \
 && chmod 755 /usr/local/bin/confd \
 && mkdir -p /etc/confd/conf.d \
 && mkdir -p /etc/confd/templates \
 && ln -s /app/conf/varnish.confd /etc/confd/conf.d/varnish.toml \
 && ln -s /app/conf/varnish.vcl.tmpl /etc/confd/templates/varnish.vcl.tmpl \
 && rm -rf /var/log/varnish \
 && ln -s /log /var/log/varnish \
 && cp /app/conf/default.vcl /etc/varnish/default.vcl

EXPOSE 80

CMD ["/usr/bin/supervisord", "-c", "/app/conf/supervisord.conf"]
