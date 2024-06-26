################################################################################
#### Functions for the Chemotherapy Model
################################################################################

## Function to generate the PSA parameters
generate_psa_parameters <- function(n){
  # n: The number of PSA simulations to be drawn

  # Probability of side effects under treatment 1
  p_side_effects_t1 <- rbeta(n, 
                             1 + n_side_effects, 
                             1 + n_patients - n_side_effects)
  
  # Log odds of side effects on treatment 2
  logor_side_effects <- rnorm(n, logor_side_effects_mu, logor_side_effects_sd)
  # Odds of side effects on treatment 1
  odds_side_effects_t1 <- p_side_effects_t1 / (1 - p_side_effects_t1)
  # Odds for side effects on treatment 2
  odds_side_effects_t2 <- odds_side_effects_t1 * exp(logor_side_effects)

  # Probability of side effects under treatment 2
  p_side_effects_t2    <- odds_side_effects_t2 / (1 + odds_side_effects_t2)

  ## Variables to define transition probabilities
  # Probability that a patient is hospitalised over the time horizon
  p_hospitalised_total <- rbeta(n, 
                                1 + n_hospitalised, 
                                1 + n_side_effects - n_hospitalised)
  # Probability that a patient dies over the time horizon given they were 
  # hospitalised
  p_died <- rbeta(n, 1 + n_died, 1 + n_hospitalised - n_died)
  # Lambda_home: Conditional probability that a patient recovers considering 
  # that they are not hospitalised
  betapars <- betaPar(p_recovery_home_mu, p_recovery_home_sd)
  lambda_home <- rbeta(n, betapars$alpha, betapars$beta)
  # Lambda_hosp: Conditional probability that a patient recovers considering 
  # that they do not die
  betapars <- betaPar(p_recovery_hosp_mu, p_recovery_hosp_sd)
  lambda_hosp <- rbeta(n, betapars$alpha, betapars$beta)
  
  ## Health State Costs
  lnpars <- lognPar(c_home_care_mu, c_home_care_sd)
  c_home_care <- rlnorm(n, lnpars$meanlog, lnpars$sdlog)
  
  lnpars <- lognPar(c_hospital_mu, c_hospital_sd)
  c_hospital <- rnorm(n, c_hospital_mu, c_hospital_sd)
  
  lnpars <- lognPar(c_death_mu, c_death_sd)
  c_death <- rlnorm(n, lnpars$meanlog, lnpars$sdlog)
  
  ## Health Utilities
  betapars <- betaPar(u_recovery_mu, u_recovery_sd)
  u_recovery <- rbeta(n, betapars$alpha, betapars$beta)
  betapars <- betaPar(u_home_care_mu, u_home_care_sd)
  u_home_care <- rbeta(n, betapars$alpha, betapars$beta)
  betapars <- betaPar(u_hospital_mu, u_hospital_sd)
  u_hospital <- rbeta(n, betapars$alpha, betapars$beta)
  
  # Long term survival
  gammapars <- gammaPar(rate_longterm_mu, rate_longterm_sd)
  rate_longterm <- rgamma(n, shape = gammapars$alpha, rate = gammapars$beta)
  
  # Specify a matrix containing all the parameters
  params_matrix <- data.frame(
    p_side_effects_t1, 
    p_side_effects_t2,
    c_home_care, c_hospital, c_death,
    u_recovery, u_home_care, u_hospital,
    logor_side_effects,
    p_hospitalised_total, p_died,
    lambda_home, lambda_hosp, rate_longterm)
  
  return(params_matrix)
}

## Function to calculate average time each patient with adverse events spends
## in the health states of the Markov model
calculate_state_occupancy_markov_model <- function(
  p_side_effects_t1, 
  p_side_effects_t2,
  p_home_home, p_home_hospital, p_home_recover,
  p_hospital_hospital, p_hospital_recover, p_hospital_dead,
  p_longterm)
  # All function arguments come from the generate_psa_parameters function except
  # time_horizon which is a model assumption
{ 
  ## Markov transition probability matrix 
  ## States: Home care, Hospital care, Recovery, Death
  MM.mat <- matrix(c(p_home_home, p_home_hospital, p_home_recover, 0,
                     0, p_hospital_hospital, p_hospital_recover, p_hospital_dead,
                     0, 0, 1 - p_longterm, p_longterm,
                     0, 0, 0, 1),
                   nrow = 4, ncol = 4, byrow = TRUE)
  
  ## Number of patients in each state for each time point 
  ## 3 dimensions: number of states, number of time points, 
  ## number of treatment options
  trace <- array(0, dim = c(4, time_horizon + 1, 2)) 
  # Initialise with the predicted number of side effects in the population
  trace[1, 1, ] <- c(p_side_effects_t1, p_side_effects_t2)
  
  # Run the markove model over the time horizon
  for(i in 2:(time_horizon + 1)){   
    trace[, i, 1] <- trace[, i - 1, 1] %*% MM.mat 
    trace[, i, 2] <- trace[, i - 1, 2] %*% MM.mat
  }
  
  return(trace) # 4*16*2 array
}

## Function to calculate the costs and effects from our model
calculate_costs_effects <- function(l_params_all)
  # All function arguments come from the generate_psa_parameters function
{ with(as.list(l_params_all),{
  # Calculate p_side_effects_2 from odds ratio
  # Odds of side effects on treatment 1
  odds_side_effects_t1 <- p_side_effects_t1 / (1 - p_side_effects_t1)
  # Odds for side effects on treatment 2
  odds_side_effects_t2 <- odds_side_effects_t1 * exp(logor_side_effects)
  
  # Probability of side effects under treatment 2
  p_side_effects_t2    <- odds_side_effects_t2 / (1 + odds_side_effects_t2)
  
  ## Transition Probabilities
  p_home_hospital <- 1 - (1 - p_hospitalised_total) ^ (1 / time_horizon)
  p_home_home <- (1 - lambda_home) * (1 - p_home_hospital)
  p_home_recover <- lambda_home 
  p_hospital_dead <- 1 - (1 - p_died) ^ (1 / time_horizon)
  p_hospital_hospital <- (1 - lambda_hosp) * (1 - p_hospital_dead)
  p_hospital_recover <- lambda_hosp * (1 - p_hospital_dead)
  p_longterm <- 1 - exp(-rate_longterm)
  
  # Calculate the trace matrix from the markov model function
  m_markov_trace <- calculate_state_occupancy_markov_model(
    p_side_effects_t1,
    p_side_effects_t2,
    p_home_home, p_home_hospital, p_home_recover,
    p_hospital_hospital, p_hospital_recover, p_hospital_dead,
    p_longterm)
  
  ## costs and effectiveness for four states
  c_state_vector <- c(c_home_care, c_hospital, 0, 0)
  u_state_vector <- c(u_home_care, u_hospital, u_recover, 0)
  
  ## Estimate the cost of side effects from the Markov model
  c_side_effects <- array(NA, dim = 2)
  
  ## Average cost for both Soc and novel treatment per person
  ## (The cost includes one-off cost of death for all patients who died)
  c_side_effects[1] <- (sum(c_state_vector %*% m_markov_trace[, , 1]) + 
                          c_death * m_markov_trace[4, time_horizon + 1, 1]) / 52
  c_side_effects[2] <- (sum(c_state_vector %*% m_markov_trace[, , 2]) + 
                c_death * m_markov_trace[4, time_horizon + 1, 2]) / 52
  c_drug <- c(c_treatment_1)
  c_longterm <- (1 - m_markov_trace[4, time_horizon + 1, ]) * 
    (pexp(time_horizon_longterm - 2, rate = rate_longterm)) * c_death
  c_overall <- c(c_drug + c_side_effects + c_longterm)
  
  ## Total QALY of side effects for both Soc and novel treatment
  q_side_effects <- array(NA, dim = 2)
  q_side_effects[1] <- sum(u_state_vector %*% m_markov_trace[,,1]) / 52
  q_side_effects[2] <- sum(u_state_vector %*% m_markov_trace[,,2]) / 12
  q_longterm <- (1 - m_markov_trace[4, time_horizon + 1, ]) *
    integrate(function(x){ (1 - pexp(x, rate = rate_longterm)) * u_home_care}, lower = 2, upper = time_horizon_longterm)$value
  ## QALY of total number of patients who do not experience adverse events for 15 days
  p_no_side_effects <- 1 - 
                          c(p_side_effects_t1,
                            p_side_effects_t2)
  q_no_side_effects <-  p_no_side_effects * u_recover * (time_horizon + 1) / 52
  
  ## Average effect for both Soc and novel treatment per person
  q_overall <- c(q_side_effects + q_no_side_effects + q_longterm)
  
  names(c_overall) <- paste0("cost",seq_along(c_overall))
  names(q_overall) <- paste0("eff",seq_along(q_overall))
  output <- array(NA, dim = c(2, length(q_overall)),
                  dimnames = list(c("Effects", "Costs"),
                                  c("SoC", "Novel")))
  output[1, ] <- q_overall
  output[2, ] <- c_overall
  
  return(output)
}
)
}

calculate_net_benefit <- function(
  costs_effects,
  wtp)
{
    if(!is.null(dim(costs_effects))){
      nb <- wtp * costs_effects[, 1, ] - 
        costs_effects[, 2, ]
    }

  return(nb)
}


