evaluate_expressions  <- function(expressions, token, job_id, name, API_URL) {
  n <- length(expressions)
  for (i in seq_len(n)) {
    tryCatch({
      if (typeof(expressions[[i]]) == "environment") {
        if (expressions[[i]]$globals$MONITAUR_EXPRESSION) {
          # load current environment
          expressions[[i]]$globals <- append(expressions[[i]]$globals, as.list(environment()))
        }
        res <- future::value(expressions[[i]])
      } else {
        eval(expressions[[i]])
      }}, error = function(e) {
        # log error
        message(sprintf('%s: --- ERROR ---', name))
        monitauR:::error(token, API_URL, job_id, e$message)
        stop(e)
      }, interrupt = function(e) {
        message(sprintf('%s: --- CANCELED ---', name))
        monitauR:::error(token, API_URL, job_id, 'CANCELED')
        rlang::interrupt()
      })
  }
  invisible()
}
