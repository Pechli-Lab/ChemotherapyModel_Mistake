################################################################################
#### Model Inputs from Assumptions for the Chemotherapy Model
################################################################################

## Time Horizon
time_horizon <- 52
time_horizon_longterm <- 40

## Parameters for the PSA distribution of the risk reduction of side effects
logor_side_effects_mu <- log(0.54)
logor_side_effects_sd <- 0.3

## Parameters for the PSA distribution of the recovery time for patients who are
## not hospitalised
p_recovery_home_mu <- 0.21
p_recovery_home_sd <- 0.03

## Parameters for the PSA distribution of the recovery time for patients who are
## hospitalised
p_recovery_hosp_mu <- 0.03
p_recovery_hosp_sd <- 0.0065

## Parameters for the PSA distribution of the costs of treating patients at home
c_home_care_mu <- 830
c_home_care_sd <- sqrt(150)

## Parameters for the PSA distribution of the costs of treating patients in
## hospital
c_hospital_mu <- 2400
c_hospital_sd <- 1880

## Parameters for the PSA distribution of the one-off cost of death
c_death_mu <- 1710
c_death_sd <- sqrt(760)


## Parameters for the PSA distribution of the utility for recovered patients
u_recover     <-  0.98
u_recovery_mu <- u_recover
u_recovery_sd <- sqrt(0.0008)


## Parameters for the PSA distribution of the utility of patients who are treated
## at home. 
u_home_care_mu <- 0.7
u_home_care_sd <- 0.5

## Parameters for the PSA distribution of the utility of treating patients in 
## hospital
u_hospital_mu <- 0.3
u_hospital_sd <- sqrt(0.03)

## Parameters for the PSA distribution of the long-term 
rate_longterm_mu <- 0.95 / 20 # 95% of individuals to die by 20 years
rate_longterm_sd <- sqrt(0.001)

## Drug costs
c_treatment_1 <- 120
c_treatment_2 <- 1975
