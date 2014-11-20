VARNISH_REDIRECTS='[
    {
      "from": "^(https?://[^/]+)/(?:index\\b)?",
      "to": "$1/hovers/"
    },
    {
      "from": "^(https?://[^/]+)/demo\\b",
      "to": "$1/slideshow",
      "internal": true
    }
  ]'

VARNISH_APPS='{
    "apache_sample": {
      "path": "^(https?://[^/]+)/hovers/",
      "backends": [
        {
          "host": "192.168.59.103",
          "port": 8080
        }
      ]
    },
    "apache_sample_2": {
      "path": "^(https?://[^/]+)/slideshow/",
      "backends": [
        {
          "host": "192.168.59.103",
          "port": 8080
        }
      ]
    }
  }'
