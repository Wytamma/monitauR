evaluate_expressions  <- function(expressions, token, job_id, name, API_URL) {
  n <- length(expressions)
  for (i in seq_len(n)) {
    if (typeof(expressions[[i]]) == "environment") {
      res <- future::value(expressions[[i]])
    } else {
      tryCatch({
        eval(expressions[[i]])
      }, error = function(e) {
        # log error
        message(sprintf('%s: --- ERROR ---', name))
        monitauR:::error(token, API_URL, job_id, e$message)
        stop(e)
      })
    }
  }
  invisible()
}
