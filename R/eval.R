evaluate_expressions  <- function(expressions, job_id, API_URL) {
  n <- length(expressions)
  for (i in seq_len(n)) {
    if (typeof(expressions[[i]]) == "environment") {
      res <- future::value(expressions[[i]])
    } else {
      tryCatch({
        eval(expressions[[i]])
      }, error = function(e) {
        # log error
        message(sprintf('Job %s: --- ERROR ---', job_id))
        monitauR::error(API_URL, job_id, e$message)
        stop(e)
      })
    }
  }
  invisible()
}
