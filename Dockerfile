FROM centos:centos6
MAINTAINER Kevin Eye <kevineye@gmail.com>

RUN rpm -Uvh http://download.fedoraproject.org/pub/epel/6/i386/epel-release-6-8.noarch.rpm \
 && rpm --nosignature -i https://repo.varnish-cache.org/redhat/varnish-4.0.el6.rpm \
 && yum -y update \
 && yum -y install tar varnish python-setuptools \
 && yum clean all

COPY . /app

RUN curl -L https://github.com/coreos/etcd/releases/download/v0.4.6/etcd-v0.4.6-linux-amd64.tar.gz | tar xzf - \
 && cp -pr etcd-v0.4.6-linux-amd64/etcd* /usr/local/bin \
 && rm -rf etcd-v0.4.6-linux-amd64 \
 && curl -L -o /usr/local/bin/confd https://github.com/kelseyhightower/confd/releases/download/v0.7.0-beta1/confd-0.7.0-linux-amd64 \
 && chmod 755 /usr/local/bin/confd \
 && mkdir -p /etc/confd/conf.d \
 && mkdir -p /etc/confd/templates \
 && curl -L -o /usr/local/bin/jq http://stedolan.github.io/jq/download/linux64/jq && chmod 555 /usr/local/bin/jq \
 && easy_install supervisor \
 && ln -s /app/conf/varnish.confd /etc/confd/conf.d/varnish.toml \
 && ln -s /app/conf/varnish.vcl.tmpl /etc/confd/templates/varnish.vcl.tmpl \
 && mkdir /log \
 && rm -rf /var/log/varnish \
 && ln -s /log /var/log/varnish \
 && cp /app/conf/default.vcl /etc/varnish/default.vcl

EXPOSE 80
VOLUME ["/app", "/log"]
CMD ["/usr/bin/supervisord", "-c", "/app/conf/supervisord.conf"]
