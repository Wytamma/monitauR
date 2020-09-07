# monitaur-api.R
library('dplyr')

jobs <-
  tibble(
    name = character(),
    status = character(),
    error = character(),
    id = integer(),
    created = character(),
    updated = character()
  )
steps <-
  tibble(
    msg = character(),
    job_id = integer(),
    id = integer(),
    created = character(),
    updated = character()
  )

#* Create a new job
#* @param msg Name of job to be created
#* @post /jobs
function(msg = "") {
  job <-
    list(
      name = msg,
      status = 'initialised',
      id = nrow(jobs) + 1,
      created = as.character(Sys.time()),
      updated = as.character(Sys.time())
    )
  jobs <<-
    jobs %>% add_row(
      name = job$name,
      status = job$status,
      error = '',
      id = job$id,
      created = job$created,
      updated = job$updated
    )
  get_job_by_id(job$id)
}


get_job_by_id <- function(job_id) {
  jobs %>% filter(id == job_id)
}

set_status_of_job <- function(job_id, status) {
  jobs[jobs$id == job_id, 'status'] <<- status
  jobs[jobs$id == job_id, 'updated'] <<- as.character(Sys.time())
}



#* Set job status to running
#* @post /jobs/<id:int>/start
function(id) {
  set_status_of_job(id, 'running')
  get_job_by_id(id)
}

#* Set job status to finished
#* @post /jobs/<id:int>/end
function(id) {
  set_status_of_job(id, 'finished')
  get_job_by_id(id)
}

#* Set job status to error
#* @param msg Job error msg
#* @post /jobs/<id:int>/error
function(id, msg = '') {
  set_status_of_job(id, 'error')
  jobs[jobs$id == id, 'error'] <<- msg
  get_job_by_id(id)
}

#* List all jobs
#* @get /jobs
function() {
  jobs
}


#* Get job by id
#* @param id Job ID
#* @get /jobs/<id:int>
function(id) {
  get_job_by_id(id)
}

get_step_by_id <- function(step_id) {
  steps %>% filter(id == step_id)
}

get_steps_by_job_id <- function(filter_id) {
  steps %>% filter(job_id == filter_id)
}

#* List all steps
#* @param job_id Job id to use as filter
#* @get /steps
function(job_id = NA) {
  steps
  if (is.na(job_id)) {
    return(steps)
  } else {
    return(get_steps_by_job_id(as.integer(job_id)))
  }
}

#* Get step by id
#* @param id Step ID
#* @get /steps/<id:int>
function(id) {
  get_step_by_id(id)
}

create_new_step <- function(job_id, msg) {
  step <-
    list(
      msg = msg,
      job_id = as.integer(job_id),
      id = nrow(steps) + 1,
      created = as.character(Sys.time()),
      updated = as.character(Sys.time())
    )
  steps <<-
    steps %>% add_row(
      msg = step$msg,
      job_id = step$job_id,
      id = step$id,
      created = step$created,
      updated = step$updated
    )
  get_step_by_id(step$id)
}

#* Create a new job step
#* @param job_id ID of job to create step on
#* @param msg Message for step to be created
#* @post /steps
function(job_id, msg = "") {
  create_new_step(job_id, msg)
}

#* @filter cors
cors <- function(res) {
  res$setHeader("Access-Control-Allow-Origin", "*")
  plumber::forward()
}
