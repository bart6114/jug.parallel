# jug.parallel

**under development**

`jug.parallel` allows processing `jug` requests in parallel. Under the hood it launches a node.js based load balancer which in turn spins up `n` different instances of your `jug` instance. A round-robin approach is used to distribute the requests.

## Requirements

- node.js installation

## Installation

```r
devtools::install_github("Bart6114/jug.parallel")
```

## Example

Start up 8 jug instances in parallel:

```r
library(jug)

jug() %>%
  get("/", function(req, res, err){
    "Hello World!"
  }) %>%
  simple_error_handler_json() %>%
  serve_it_parallel(processes=8)
```

```sh
curl 127.0.0.1:8080
```
```
Hello World!
```

One can also call `serve_it_parallel` with `wait=FALSE`. This way the terminal will not be blocked and the `jug` instances will be served in the background. Remember that you will have to clean up the servers manually.

Stop and clean-up all servers:
```r
kill_servers()
```
```
[1] TRUE
Stopping servers...success
```

## Benchmarks

Below (non-exhaustive) load tests have been done using [loadtest](https://www.npmjs.com/package/loadtest) on a MacBook Pro with a 2,5 GHz Intel Core i7 CPU. The requests for second (rps) was set to 1000.

| type         | concurrency | requests | duration (secs) | errors |
|--------------|-------------|----------|-----------------|--------|
| jug          | 6           | 1e2      | 0.48            | 0      |
| jug.parallel | 6           | 1e2      | 0.62            | 0      |
| jug          | 6           | 1e3      | 1.95            | 1      |
| jug.parallel | 6           | 1e3      | 1.37            | 0      |
| jug          | 6           | 1e4      | 15.08           | 458    |
| jug.parallel | 6           | 1e4      | 12.30           | 0      |

The most important take away here is that `jug.parallel` only becomes interesting in cases where you are expecting a (very) high load or where the request processing duration is significant.
