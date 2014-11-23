FROM kevineye/centos

RUN rpm -Uvh http://download.fedoraproject.org/pub/epel/6/i386/epel-release-6-8.noarch.rpm \
 && rpm --nosignature -i https://repo.varnish-cache.org/redhat/varnish-4.0.el6.rpm \
 && yum -y install varnish npm tar perl-devel python-setuptools \
 && yum clean all

RUN npm install -g handlebars-cmd

RUN curl -L https://github.com/coreos/etcd/releases/download/v0.4.6/etcd-v0.4.6-linux-amd64.tar.gz | tar xzf - \
 && cp -pr etcd-v0.4.6-linux-amd64/etcd* /usr/local/bin \
 && rm -rf etcd-v0.4.6-linux-amd64

RUN easy_install supervisor

RUN curl -L http://cpanmin.us | perl - -n Digest::SHA Time::HiRes Compress::Raw::Zlib Mojolicious \
 && rm -rf /root/.cpanm

RUN curl -L -o /usr/local/bin/jq http://stedolan.github.io/jq/download/linux64/jq && chmod 555 /usr/local/bin/jq

COPY . /app

RUN ln -s /app/etcd-varnish /usr/local/bin

RUN rm -rf /var/log/varnish \
 && ln -s /log /var/log/varnish \
 && touch /log/varnish-reload.log

EXPOSE 80

CMD ["/usr/bin/supervisord", "-c", "/app/conf/supervisord.conf"]
