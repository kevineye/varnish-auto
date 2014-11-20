TEST=123

VARNISH_BACKENDS=${VARNISH_BACKENDS:-'["localhost"]'}

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
