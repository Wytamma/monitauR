#' Monitor the progress of a script
#'
#' This function is used to monitor the progress of a script. A script file
#' passed to the function will be evaluated and any comments with the
#' `comment_syntax` #> (default) will be sent to a remote sever (`API_URL`) for
#' logging. Before the script is evaluated the job will be initialised with the
#' remote server and a Job ID is generated. That Job ID is used to link each
#' step with the script. Once the script is finished the Job satus will be set to
#' complete. If the script errors the error will also be logged with the server.
#'
#' @param infile Path to the input file
#' @param job_name Name of job (defaults to infile)
#' @param comment_syntax Special comment syntax (defaults to #>)
#' @param API_URL Base url of the remote server
#' @return The result of the script.
#' @export
monitor <-
  function(infile,
           job_name = NA,
           API_URL,
           comment_syntax = "#>"
           ) {
    if (is.na(job_name)) {
      job_name <- infile
    }
    lines <- readLines(infile)
    job_id <- NA
    res <- monitauR::init(API_URL, job_name)
    job_id <- httr::content(res)[[1]]$id
    if (is.na(job_id)) {
      stop('job_id is not defined')
    }
    message(sprintf('Job %s: --- Initialising ---', job_id))
    # extract
    futures <- extract_steps_as_futures(lines, job_id, comment_syntax, API_URL)
    expressions <-extract_expressions(lines)
    # combine
    expressions <- c(expressions, futures)
    # sort
    expressions <- expressions[order(names(expressions))]
    # eval
    monitauR::start(API_URL, job_id)
    evaluate_expressions(expressions)
    monitauR::end(API_URL, job_id)
    message(sprintf('Job %s: --- Completed ---', job_id))
    invisible()
  }
