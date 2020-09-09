#' @export
init <- function(API_URL, job_name) {
  URL <- sprintf('%s/jobs', API_URL)
  res <- httr::POST(URL, query = list(msg = job_name))
  if (typeof(httr::content(res)) != "list") {
    stop('Malformed response. POST <API_URL>/jobs should return a list.')
  }
  invisible(res)
}

#' @export
start <- function(API_URL, job_id) {
  URL <- sprintf('%s/jobs/%s/start', API_URL, job_id)
  res <- httr::POST(URL)
  invisible(res)
}

#' @export
step <- function(API_URL, job_id, msg) {
  URL <- sprintf('%s/steps', API_URL)
  res <- httr::POST(URL, query = list(msg = msg, job_id = job_id))
  invisible(res)
}

#' @export
end <- function(API_URL, job_id) {
  URL <- sprintf('%s/jobs/%s/end', API_URL, job_id)
  res <- httr::POST(URL)
  invisible(res)
}

#' @export
error <- function(API_URL, job_id, msg) {
  URL <- sprintf('%s/jobs/%s/error', API_URL, job_id)
  res <- httr::POST(URL, query = list(msg = msg))
  invisible(res)
}
