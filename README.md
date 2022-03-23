# monitauR <img src='images/logo.png' align="right" height="210" />

Easily and remotely monitor the progress of your R scripts.

```R
devtools::install_github("wytamma/monitauR")
```

## Example 

Consider the script `example_scripts/square.R`

```R
#< Setting up the square function
square <- function(x) {
  x*x
}
#< Computing the square
square(5)
```

The `#<` comments are special comments that tell monitauR to log these steps. 

```bash
$ Rscript -e "monitauR::monitor('example_scripts/square.R')"

Job 1: --- Initialised ---
Job 1: https://blog.wytamma.com/monitauR-webapp/jobs?token=02d73eed-bdae-411e-99a6-885121a42c2b
Job 1: Setting up the square function (1/2)
Job 1: Computing the square (2/2)
Job 1: --- Finished ---
```

Alternatively, you can include a call to `monitauR::monitor()` at the top of the script and run the script normally with `$ Rscript example_scripts/square.R` or `> source("example_scripts/square.R")`

```R
monitauR::monitor()
#< Setting up the square function
square <- function(x) {
  x*x
}
#< Computing the square
square(5)
```

```bash
$ Rscript example_scripts/square.R

Job 2: --- Initialised ---
Job 2: https://blog.wytamma.com/monitauR-webapp/jobs?token=4e814983-a675-4d07-9789-6a3b4f187867
Job 2: Setting up the square function (1/2)
Job 2: Computing the square (2/2)
Job 2: --- Finished ---
```

The steps are logged to a web-api and can be viewed using the web-app at [https://blog.wytamma.com/monitauR-webapp/jobs](https://blog.wytamma.com/monitauR-webapp/jobs). 

[![webapp](images/webapp.png)](https://blog.wytamma.com/monitauR-webapp/jobs/)

## Tokens

MonitauR will create a unique random `token` e.g. `4e814983-a675-4d07-9789-6a3b4f187867` this token is required to access the logs. Tokens can be used to group jobs together by specifying them in `monitauR::monitor(token="my-project-token")` all jobs using this token will show up on the same jobs page. You can set the token to anything* however, setting it to something simple may clash with other tokens.

## Comment Syntax

The comment syntax can be changed using the `comment_syntax` option in `monitauR::monitor` e.g. `monitauR::monitor('example_scripts/square.R', comment_syntax="#")` to log normal comments. A name for the script can be specified with the `name` option e.g. `monitauR::monitor('example_scripts/square.R', name="cool script")`. 

## Expression comments

Expressions can be used in monitauR comments by wrapping them in `{}`. For example the last line of the script below will send 'The result is 25' to the server. 

```R
#< Setting up the square function
square <- function(x) {
  x*x
}
#< Computing the square
res <- square(5)
#< { sprintf("The result is %s", res) }
```

## Emails (experimental)

Using the `email` argument you can get the monitauR-api to send you emails when your job finishes/errors.

```bash
monitauR::monitor('example_scripts/square.R', email="wytamma.wirth@me.com")
```

## Explanation 

There is a [plumber api](https://www.rplumber.io/) running on [https://monitaur-api.herokuapp.com/](https://monitaur-api.herokuapp.com/) that receives and logs requests from `monitauR::monitor`. The script infile (`example_scripts/square.R`) has a special comment syntax (`#<`) that tells `monitauR::monitor` when to send a logging request. 

While evaluating the script when the special comment (`#<`) is reached a request is sent to the server telling it to log the step.

### lifecycle of a monitauR script

1. The script is parsed and the expressions are extracted
2. Job ID is generated (status set to initialised)
3. A future is created (using the Job ID) for each special comment step
4. Job status is set to running
5. Script is evaluated and futures are run in sequential order 
6. Any errors are caught and sent to the server (status set to error)
7. When the script completes the Job status is set to finished


## MonitauR-api

Details for the default plumber api can be found [here](https://github.com/Wytamma/monitauR-api). However, the default api is shared and anyone can add to or edit the data on there, and the data might be wiped at any point. If you want your own private server you could deploy your own API and replace the `API_URL` pram in `monitauR::monitor`.

## MonitauR-webapp

Jobs can be monitored via `/jobs` section of webapp found at [https://wytamma.github.io/monitauR-webapp](https://wytamma.github.io/monitauR-webapp). Details for the webapp can be found [here](https://github.com/Wytamma/monitauR-webapp). 

## Docker dev env

```bash
docker run --rm -p 8787:8787  -v $(pwd):/home/rstudio -e ROOT=TRUE -e PASSWORD=yourpasswordhere rocker/rstudio
```

