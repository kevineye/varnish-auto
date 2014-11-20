FROM kevineye/centos

RUN rpm -Uvh http://download.fedoraproject.org/pub/epel/6/i386/epel-release-6-8.noarch.rpm \
 && yum -y install varnish npm \
 && yum clean all

RUN npm install -g handlebars-cmd

COPY . /app

RUN rm -rf /var/log/varnish \
 && ln -s /log /var/log/varnish

ENV VARNISH_BACKENDS ["localhost"]

EXPOSE 80

CMD ["/app/start.sh"]
