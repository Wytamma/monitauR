#' @export
init <- function(token, API_URL, job_name) {
  URL <- sprintf('%s/jobs', API_URL)
  res <- httr::POST(URL, query = list(msg = job_name, user_token = token))
  if (typeof(httr::content(res)) != "list") {
    stop('Malformed response. POST <API_URL>/jobs should return a list.')
  }
  invisible(httr::content(res)[[1]]$id)
}

#' @export
start <- function(token, API_URL, job_id) {
  URL <- sprintf('%s/jobs/%s/start', API_URL, job_id)
  res <- httr::POST(URL, query = list(user_token = token))
  invisible(res)
}

#' @export
step <- function(token, API_URL, job_id, msg) {
  URL <- sprintf('%s/steps', API_URL)
  res <- httr::POST(URL, query = list(msg = msg, job_id = job_id, user_token = token))
  invisible(res)
}

#' @export
end <- function(token, API_URL, job_id) {
  URL <- sprintf('%s/jobs/%s/end', API_URL, job_id)
  res <- httr::POST(URL, query = list(user_token = token))
  invisible(res)
}

#' @export
error <- function(token, API_URL, job_id, msg) {
  URL <- sprintf('%s/jobs/%s/error', API_URL, job_id)
  res <- httr::POST(URL, query = list(msg = msg, user_token = token))
  invisible(res)
}
