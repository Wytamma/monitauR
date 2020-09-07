extract_steps_as_futures <- function(lines, job_id, comment_syntax, API_URL, STOP_ON_ERROR = FALSE) {
  futures <- list()
  for (i in 1:length(lines)) {
    line <- lines[i]
    if (!startsWith(line, comment_syntax)) {
      next
    }
    msg <-
      trimws(substr(line, nchar(comment_syntax) + 1, nchar(line)))
    # create step future
    f <- future::future({
      tryCatch({
        # do smarter checking for response status
        message(sprintf('Job %s: %s', job_id, msg))
        monitauR::step(API_URL = API_URL, job_id = job_id, msg = msg)},
        error = function(e) {
          if (STOP_ON_ERROR) {
            stop(e)
          }
          warning(e$message)
        }
      )
    }, lazy = TRUE)
    futures[[as.character(i)]] <- f
  }
  return(futures)
}


extract_expressions <- function(lines) {
  exprs <- base::parse(text = paste(lines))
  expressions <- list()
  for (i in 1:length(exprs)) {
    e <- exprs[i]
    srcref <- attr(e, "srcref")[[1]][1]
    expressions[as.character(srcref)] <- e
  }
  return(expressions)
}
