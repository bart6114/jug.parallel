library(jug)

jug() %>%
  get("/", function(req, res, err){
    "Hello World!"
  }) %>%
  simple_error_handler_json() %>%
  serve_it_parallel(wait=T)

