FROM kevineye/centos

RUN rpm -Uvh http://download.fedoraproject.org/pub/epel/6/i386/epel-release-6-8.noarch.rpm \
 && rpm --nosignature -i https://repo.varnish-cache.org/redhat/varnish-4.0.el6.rpm \
 && yum -y install varnish npm \
 && yum clean all

RUN npm install -g handlebars-cmd

COPY . /app

RUN rm -rf /var/log/varnish \
 && ln -s /log /var/log/varnish

ENV VARNISH_BACKENDS ["127.0.0.1"]

EXPOSE 80

CMD ["/app/start.sh"]
