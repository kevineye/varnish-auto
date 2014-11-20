VARNISH_BACKENDS=${VARNISH_BACKENDS:-'["127.0.0.1"]'}

VARNISH_APPS='[
    {
        "name": "apache_sample",
        "path": "^/hovers/",
        "port": "8080"
    },
    {
        "name": "apache_sample_2",
        "path": "^/slideshow/",
        "port": "8081"
    }
]'
