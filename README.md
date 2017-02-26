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

One call also call `serve_it_parallel` with `wait=FALSE`. This way the terminal will not be blocked and the `jug` instances will be served in the background. Remember that you will have to clean up the servers manually.

Stop and clean-up all servers:
```r
kill_servers()
```
```
[1] TRUE
Stopping servers...success
```
