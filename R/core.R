#' serve_it_parallel
#'
#' Allows to serve parallel jug instance. A Node.js bases load balancer will spin up \code{n} Jug instances.
#' Requests are proxied using a round robin approach. The Node.js load balancer will also launch a
#' server on another port (called the daemon), this is used to allow \code{kill_servers} to send a kill signal.
#'
#' @param jug the jug instance
#' @param host to host to serve on
#' @param port the port to serve on
#' @param host_daemon the host of the daemon
#' @param port_daemon the port of the daemon
#' @param processes the number of parallel processes to spin up
#' @param node_executable define how to call the Node.js executable
#' @param wait wait for the process to finish?
#' @param verbose verbosity of the jug instances
serve_it_parallel <-
  function(jug,
           host = "127.0.0.1",
           port = 8080,
           host_daemon = "127.0.0.1",
           port_daemon = 8081,
           processes = parallel::detectCores(),
           node_executable = "node",
           wait = TRUE,
           verbose = FALSE) {
    if (Sys.getenv("JUG_PARALLEL") == "") {
      balancer <- system.file("balancer.js", package = "jug.parallel")
      tmp_img <- tempfile()

      .load_pkgs <- function() {
        pkgs <- unlist(strsplit(.PKGS, ","))
        invisible(Map(function(x)
          library(x, character.only = T), pkgs))
      }

      assign(".JUG", jug, envir = globalenv())
      assign(".PKGS", paste0(.packages(), collapse = ","), envir = globalenv())
      assign(".load_pkgs", .load_pkgs, envir = globalenv())
      save.image(tmp_img)

      Sys.setenv("NODE_PATH" = system.file("node_modules", package = "jug.parallel"))
      cmd <-
        paste(node_executable,
              balancer,
              tmp_img,
              processes,
              host,
              port,
              host_daemon,
              port_daemon,
              verbose)

      system(cmd, wait = FALSE)
      if(wait){
        # mimicks in process behaviour with advantage of cleaning up servers when finished
        # i.e. kill_servers doesnt have to be called
        on.exit(kill_servers(host_daemon, port_daemon))
        while(TRUE) Sys.sleep(1)
      }
    } else {
      jug::serve_it(
        jug = jug,
        host = host,
        port = port,
        verbose = verbose
      )
    }
  }


#' Kill all Jug instances launched by \code{serve_it_parallel}
#'
#' @param host the host of the daemon process
#' @param daemon_port the port of the daemon process
kill_servers <- function(host_daemon = "127.0.0.1", port_daemon = 8081) {
  address <- paste0("http://", host_daemon, ":", port_daemon, "/stop")
  curl::curl_fetch_memory(address)
  return(TRUE)
}
