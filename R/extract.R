extract_steps_as_futures <-
  function(lines,
           job_id,
           comment_syntax,
           API_URL,
           STOP_ON_ERROR = FALSE) {
    futures <- list()
    steps <- list()
    for (i in 1:length(lines)) {
      line <- lines[i]
      if (!startsWith(line, comment_syntax)) {
        next
      }
      steps[[sprintf("%02d", i)]] <- line
    }
    if (length(steps) == 0) {
      stop(sprintf(
        'Could not find monituaR style comments (%s) in the file.',
        comment_syntax
      ))

    }
    for (i in 1:length(steps)) {
      step <- steps[i]
      msg <-
        trimws(substr(step, nchar(comment_syntax) + 1, nchar(step)))
      # create step future
      f <- future::future({
        tryCatch({
          # do smarter checking for response status
          message(sprintf('Job %s: %s (%s/%s)', job_id, msg, i, length(steps)))
          monitauR:::step(API_URL = API_URL,
                         job_id = job_id,
                         msg = msg)
        },
        error = function(e) {
          if (STOP_ON_ERROR) {
            stop(e)
          }
          warning(e$message)
        })
      }, lazy = TRUE)
      futures[[names(steps)[i]]] <- f
    }
    return(futures)
  }


extract_expressions <- function(lines) {
  exprs <- base::parse(text =  lines, keep.source = TRUE)
  expressions <- list()
  for (i in 1:length(exprs)) {
    e <- exprs[i]
    if (any(startsWith(deparse(e), "expression(monitauR::monitor"))) {
      next
    }
    srcref <- attr(e, "srcref")[[1]][1]
    expressions[sprintf("%02d", srcref)] <- e
  }
  return(expressions)
}
