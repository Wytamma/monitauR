# monitauR

A package to easily monitor the progress of your R scripts. Progress is registered with a remote API using a special comment syntax.

## example 

```R
> monitauR::monitor('example_scripts/square.R', API_URL='http://localhost:8000/')
Job 1: --- Initialising ---
Job 1: Setting up the square function
Job 1: Computing the square
Job 1: --- Completed ---

> httr::content(httr::GET('http://localhost:8000/jobs'))
[[1]]
[[1]]$name
[1] "example_scripts/square.R"

[[1]]$status
[1] "finished"

[[1]]$id
[1] 1

[[1]]$created
[1] "2020-09-07 06:22:48"

[[1]]$updated
[1] "2020-09-07 06:22:48"

> httr::content(httr::GET('http://localhost:8000/steps'))
[[1]]
[[1]]$msg
[1] "Setting up the square function"

[[1]]$job_id
[1] 1

[[1]]$id
[1] 1

[[1]]$created
[1] "2020-09-07 06:22:49"

[[1]]$updated
[1] "2020-09-07 06:22:49"


[[2]]
[[2]]$msg
[1] "Computing the square"

[[2]]$job_id
[1] 1

[[2]]$id
[1] 2

[[2]]$created
[1] "2020-09-07 06:22:49"

[[2]]$updated
[1] "2020-09-07 06:22:49"
```

## explanation 

There is a plumber api running on PORT 8000 that receives and logs requests from `monitauR::monitor`. The script file has a special comment syntax (#>) that tells `monitauR::monitor` when to send a logging request. 

`example_scripts/square.R'`

```R
#> Setting up the square function
square <- function(x) {
  x*x
}
#> Computing the square
square(5)
```

While evaluating the script when the special comment (#>) is reached a request is sent to the server telling it to log the step.

### lifecycle of a monitauR script

1. The script is parsed and the expressions are extracted
2. Job ID is generated (status set to Initialising)
3. A future is created (using the Job ID) for each special comment step
4. Job status is set to running
5. Script is evaluated and futures are run in sequential order 
6. Any errors are caught and set to the server (status set to error)
6. When script completes the Job status is set to finished

## monitauR-api

Details for the api can be found [here](https://github.com/Wytamma/monitauR/tree/master/monitauR-api). However, anyone could make there own API and replace the `API_URL` pram with their own.

## docker dev env

```bash
docker run --rm -p 8787:8787  -v $(pwd):/home/rstudio -e ROOT=TRUE -e PASSWORD=yourpasswordhere rocker/rstudio
```

