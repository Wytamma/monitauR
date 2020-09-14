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
#' @param comment_syntax Special comment syntax (defaults to #<)
#' @param API_URL Base url of the remote server
#' @return The result of the script.
#' @export
monitor <-
  function(infile,
           name = NA,
           API_URL = "https://monitaur-api.herokuapp.com",
           comment_syntax = "#<") {
    if (is.na(name)) {
      name <- infile
    }
    if (endsWith(API_URL, '/')) {
      API_URL <- substr(API_URL, 0, nchar(API_URL) - 1)
    }

    # read script
    lines <- readLines(infile)

    # extract expressions
    expressions <- extract_expressions(lines)

    # generate Job ID
    job_id <- NA
    res <- monitauR::init(API_URL, name)
    job_id <- httr::content(res)[[1]]$id
    if (is.na(job_id)) {
      stop('job_id is not defined')
    }
    message(sprintf('Job %s: --- Initialised ---', job_id))

    # extract futures
    tryCatch({
      futures <-
        extract_steps_as_futures(lines, job_id, comment_syntax, API_URL)
    },
    error = function(e) {
      # log error
      message(sprintf('Job %s: --- ERROR ---', job_id))
      monitauR::error(API_URL, job_id, e$message)
      stop(e)
    })

    # combine
    expressions <- c(expressions, futures)

    # sort
    expressions <- expressions[order(names(expressions))]

    # eval
    monitauR::start(API_URL, job_id)
    evaluate_expressions(expressions, job_id, API_URL)
    monitauR::end(API_URL, job_id)
    message(sprintf('Job %s: --- Finished ---', job_id))
    invisible()
  }
