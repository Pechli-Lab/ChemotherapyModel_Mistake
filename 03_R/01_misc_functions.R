################################################################################
#### Misc Functions for the Chemotherapy Model
################################################################################

## Function to transform values for mean and standard deviation into parameters 
## for a Beta distribution

betaPar <- function(m, s) {
  # m:  Mean of the Beta distribution
  # s: Standard deviation of the Beta distribution
  
  var <- s ^ 2
  alpha <- ((1 - m) / var - 1 / m) * m ^ 2
  beta <- alpha * (1 / m - 1)
  
  if(alpha < 0){
    alpha = abs(alpha)
  }
  if(beta < 0){
    beta = abs(beta)
  }
  
  return(
    list(alpha = alpha, beta = beta)
  )
}

## Function to transform values for mean and standard deviation into parameters 
## for a Log-Normal distribution

lognPar <- function(m,s) {
  # m: Mean of Log-Normal distribution
  # s: Standard deiviation of Log-Normal distribution
  
  var <- s^2
  meanlog <- log(m) - 0.5 * log(1 + var/m^2)
  varlog <- log(1 + (var/m^2))
  sdlog <- sqrt(varlog)
  
  return(
    list(meanlog = meanlog, sdlog = sdlog)
  )
}

## Function to transform values for mean and standard deviation into parameters 
## for a Gamma distribution

gammaPar <- function(m,s) {
  # m: Mean of Log-Normal distribution
  # s: Standard deiviation of Log-Normal distribution
  
  var <- s^2
  beta <- m / var
  alpha <- m * beta
  
  return(
    list(alpha = alpha, beta = beta)
  )
}
