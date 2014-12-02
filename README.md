# Build images

    docker build -t kevineye/centos centos
    docker build -t kevineye/apache apache
    docker build -t kevineye/apache-sample-hovers apache-sample-hovers
    docker build -t kevineye/apache-sample-slideshow apache-sample-slideshow
    docker build -t kevineye/varnish varnish

# Start dependencies

In these examples, `192.168.59.103` is the docker host machine.

    # start etcd
    docker run --name etcd -d -p 4001:4001 -p 7001:7001 quay.io/coreos/etcd:v0.4.6 -addr 192.168.59.103:4001

    # start registrator
    docker run --name registrator -d --link etcd:etcd -v /var/run/docker.sock:/tmp/docker.sock -h 192.168.59.103 progrium/registrator etcd://etcd:4001/services

# Start varnish container and apps

These could be started in any order. Note, the individual servers (apache containers) do not need a link to etcd, do not need a hostname specification (`-h`), do not need a name (`--name`), and their ports can be allocated dynamically by docker (`-P`).

    # start varnish container
    docker run --name varnish -d --link etcd:etcd -p 80:80 kevineye/varnish
    
    # start sample apps
    docker run -d -P kevineye/apache-sample-hovers
    docker run -d -P kevineye/apache-sample-slideshow

Note, the default varnish configuration will be used until there are both apps running and app configuration metadata (below).

# Add configuration metadata

Without any configuration, the apps will not be accessible through varnish. The configuration can be added before or after varnish or the apps are started. The configuration will not be removed when the apps stop. The configuration will be lost if all clustered etcd containers are destroyed unless a persistent etcd log volume is configured.

The configuration is loaded into etcd using `etcdctl`. This is run in a generic container so that etcdctl does not have to be installed on the host machine.

### Hover app configuration

The following JSON is added to mount the hovers sample app at `/hovers`, and redirect from `/`.

    [
	    {
		    "from": "^https?://[^/]+/hovers\\b"
		},
	    {
		    "from": "^(https?://[^/]+)/(?:$|index\\b).*",
		    "to": "\\1/hovers/"
		}
	]
        
This can be installed with this command:

    docker run --rm -it --link etcd:etcd kevineye/centos sh -c 'etcdctl --peers $ETCD_PORT_4001_TCP_ADDR:$ETCD_PORT_4001_TCP_PORT set /apps/apache-sample-hovers '\''[ { "from": "^https?://[^/]+/hovers\\b" }, { "from": "^(https?://[^/]+)/(?:$|index\\b).*", "to": "\\1/hovers/" } ]'\'

### Slideshow app configuration

The following JSON is added to mount the hovers sample app at `/slideshow`, and demonstrate an internal redirect from `/internal-demo`.

    [
	    {
		    "from": "^https?://[^/]+/slideshow\\b"
		},
	    {
		    "from": "^(https?://[^/]+)/internal-demo\\b",
		    "to": "\\1/slideshow",
		    "internal": true
		}
	]
        
This can be installed with this command:

    docker run --rm -it --link etcd:etcd kevineye/centos sh -c 'etcdctl --peers $ETCD_PORT_4001_TCP_ADDR:$ETCD_PORT_4001_TCP_PORT set /apps/apache-sample-slideshow '\''[ { "from": "^https?://[^/]+/slideshow\\b" }, { "from": "^(https?://[^/]+)/internal-demo\\b", "to": "\\1/slideshow", "internal": true } ]'\'

# Try it out

**Hovers app**
http://192.168.59.103/hovers

**Slideshow app**
http://192.168.59.103/slideshow

**Root redirects to hovers app**
http://192.168.59.103/

**Internal redirect displays slideshow app without redirect**
http://192.168.59.103/internal-demo


# Troubleshooting and extra commands

### Peek at services in etcd

	curl -sL http://192.168.59.103:4001/v2/keys/services?recursive=true | jq .

### List/modify app configuration in etcd

	# dump all app configuration JSON
	curl -sL http://192.168.59.103:4001/v2/keys/apps?recursive=true | jq .

	# just list app configuration keys, using etcdctl
    docker run --rm -it --link etcd:etcd kevineye/centos sh -c 'etcdctl --peers $ETCD_PORT_4001_TCP_ADDR:$ETCD_PORT_4001_TCP_PORT ls /apps'

	# remove an app configuration
    docker run --rm -it --link etcd:etcd kevineye/centos sh -c 'etcdctl --peers $ETCD_PORT_4001_TCP_ADDR:$ETCD_PORT_4001_TCP_PORT rmdir /apps/apache-sample-slideshow'

### Watch registrator add/remove apps

	docker logs -f registrator

### Watch confd update varnish configuration

	docker exec varnish tail -f /log/confd.log

### Peek at current varnish configuration

	docker exec varnish cat /etc/varnish/default.vcl

# Scaling to multiple docker hosts

Not yet tested, but should work.

 1. Start etcd and registrator on each docker host, clustering etcd instances.
 2. For redundancy, start varnish container on each docker host, and use a real load balancer or round-robin DNS to direct traffic to all varnish containers. This is not absolutely necessary. Having only one varnish instance will balance among apps on multiple hosts, but will not have redundancy.
 3. Start any number of apps on any docker hosts. Apps do not need to run on all hosts, or could run multiple times on the same host.
