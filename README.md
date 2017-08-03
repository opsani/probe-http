# probe-http
The http probe calls a REST API over http/https on component instances.  The typical use is to perform an http health check on a component's service network.  The http probe can also be used to verify a REST API exposed by a component on the same network which is used to consume that service.

The http probe supports the following actions:

* `get` - perform a HTTP GET
* `post` - perform a HTTP POST
* `get_ok` - try GET and keep retrying until a success response is received or the action times out (readiness check/wait)
* `service_up` (default) - an alias for `get_ok` which treats any 2x, 3x or 4x HTTP codes as passing.  This action can be used to verify an HTTP service is up without specifying a valid resource for the GET request.

These actions support the following arguments:

* `schema` - URL schema to use: `http` (default) or `https`
* `port` - port number, default is based on schema (`80` for http, `443` for https)
* `path` - URL path relative to host; e.g., `healthz` or `/healthz`; `/` is allowed but not required (default `/`)
* `data` - string containing JSON data to pass on POST (default: no data)
* `ok_codes` - comma-separated list of status codes to be considered ok (e.g., `"200,404"`). If empty, the standard OK codes are assumed.  This option is *ignored* by the `service_up` action.
* `timeout` - operation timeout *per service instance*, in seconds (default `120`):
    * for `get` and `post`: maximum time to connect and get the first response byte
    * for `get_ok` and `service_up`: how long to keep retrying to get any of the ok_codes (success)

## examples

Here are a few examples in the form of quality gates specified in a Skopos TED file (target environment descriptor).  Quality gates associate probe actions to one or more component images.  During application deployment Skopos executes the specified probes to assess components deployed with matching images.

```yaml
quality_gates:
    websrv_test:
        images:
            - opsani/websrv:*
        steps:

            # verify http service using default action service_up
            - probe: opsani/probe-http:v1

            # examples of various health checks
            - probe:
                image: opsani/probe-http:v1
                action: get
                label: "check health over https"
                arguments: { schema: "https", path: "/healthz" }
            - probe:
                image: opsani/probe-http:v1
                action: get
                label: "check health on alternate port"
                arguments: { port: 8080, path: "/healthz" }
            - probe:
                image: opsani/probe-http:v1
                action: service_up
                label: "check for any response with short timeout"
                arguments: { timeout: 5 }
            - probe:
                image: opsani/probe-http:v1
                action: get_ok
                label: "wait until health check OK, retrying with timeout"
                arguments: { port: 8080, path: "/healthz", timeout: 30 }
```
