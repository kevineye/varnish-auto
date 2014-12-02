vcl 4.0;

backend default { # default backend is never actually used -- see vcl_recv
    .host = "localhost";
    .port = "8080";
}

sub vcl_recv {
   return (synth(404, "Not found"));
}

sub vcl_synth {
    if (resp.status == 301) {
        set resp.http.Location = resp.reason;
        set resp.reason = "Moved Permanently";
    }

    set resp.http.Content-Type = "text/html; charset=utf-8";
    set resp.http.Retry-After = "5";
    synthetic( {"<!DOCTYPE HTML>
<html><head><meta charset="utf-8"><title>"} + resp.status + " " + resp.reason + {"</title><style>
    @import url(http://fonts.googleapis.com/css?family=Bree+Serif|Source+Sans+Pro:300,400);
    body{ background: #E6E6E6; color: #666; text-align: center }
    h1 { font: bold 25vh/1 'Bree Serif', sans-serif; margin: 25vh 0 0 }
    p { font: 5vh 'Source Sans Pro', sans-serif; margin: 10px }
</style></head><body>
    <h1>"} + resp.status + {"</h1>
    <p>"} + resp.reason + {".</p>
</body></html>"} );
    return (deliver);
}
