#' Monitor the progress of a script
#'
#' This function is used to monitor the progress of a script. A script file
#' passed to the function will be evaluated and any comments with the
#' `comment_syntax` #< (default) will be sent to a remote sever (`API_URL`) for
#' logging. Before the script is evaluated the job will be initialised with the
#' remote server and a Job ID is generated. That Job ID is used to link each
#' step with the script. Once the script is finished the Job satus will be set to
#' complete. If the script errors the error will also be logged with the server.
#'
#' @param infile Path to the input file
#' @param name Name of job (defaults to infile)
#' @param token Token for grouping jobs (defaults to uuid)
#' @param email Email to send notifications
#' @param comment_syntax Special comment syntax (defaults to #<)
#' @param API_URL Base url of the remote server
#' @return The result of the script.
#' @export
monitor <-
  function(infile = NA,
           name = NA,
           token = NA,
           email = NA,
           API_URL = "https://monitaur-api.herokuapp.com",
           comment_syntax = "#<") {

    internal <- FALSE
    if (is.na(infile)) {
      infile <- this.path::this.path()
      internal <- TRUE
    }
    if (is.na(name)) {
      name <- basename(infile)
    }
    if (endsWith(API_URL, '/')) {
      API_URL <- substr(API_URL, 0, nchar(API_URL) - 1)
    }

    if (is.na(token)) {
      token <- create_token()
    }

    # read script
    lines <- readLines(infile)

    # check for comment syntax
    found <- FALSE
    for (i in 1:length(lines)) {
      line <- lines[i]
      if (startsWith(line, comment_syntax)) {
        found <- TRUE
        break
      }
    }
    if (!found) {
      stop(sprintf(
        'Could not find monituaR style comments (%s) in the file.',
        comment_syntax
      ))
    }
    # extract expressions
    expressions <- extract_expressions(lines)

    # generate Job ID
    job_id <- NA
    job_id <- monitauR:::init(token, API_URL, name, email)
    if (is.na(job_id)) {
      stop('job_id is not defined')
    }
    message(sprintf('%s: --- Initialised ---', name))
    if (!is.na(email)) {
      message(sprintf('%s: Sending email updates to: %s', name, email))
    }
    message(sprintf('%s: https://blog.wytamma.com/monitauR-webapp/jobs?token=%s', name, token))
    # extract futures
    tryCatch({
      futures <-
        monitauR:::extract_steps_as_futures(lines, token, job_id, name, comment_syntax, API_URL)
    },
    error = function(e) {
      # log error
      message(sprintf('%s: --- ERROR ---', name))
      monitauR:::error(token, API_URL, job_id, e$message)
      stop(e)
    })

    # combine
    expressions <- c(expressions, futures)

    # sort
    expressions <- expressions[sprintf( "%02d", sort(as.numeric(names(expressions))))]

    # eval
    monitauR:::start(token, API_URL, job_id)
    monitauR:::evaluate_expressions(expressions, token, job_id, name, API_URL)
    monitauR:::end(token, API_URL, job_id)
    message(sprintf('%s: --- Finished ---', name))
    if (internal) {
      exit()
    }
    invisible()
  }


create_token <- function() {
  uuid::UUIDgenerate()
}

exit <- function() {
  .Internal(.invokeRestart(list(NULL, NULL), NULL))
}
