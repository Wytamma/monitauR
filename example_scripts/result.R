monitauR::monitor(name="Result script", token="monitauR")
#< Setting up the square function
square <- function(x) {
  x*x
}
#< Computing the square
res <- square(5)
#< { sprintf("The result is %s", res) }
