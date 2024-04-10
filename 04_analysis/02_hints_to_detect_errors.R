################################################################################
#### Hint Commands for Error Detection
################################################################################

# General hints:

# Command to check generated PSA parameters:
apply(m_params, 2, mean)
round(apply(m_params, 2, sd), 3)

# Command to check the result dataframe:
apply(df_e, 2, mean)
apply(df_c, 2, mean)

# Hint 1: Compare definitions in 02_data/02_Assumption_inputs.R with R_HTA_Tables.pdf.

# Hint 2: Beta distribution's parameters, alpha and beta, should both be greater than 0.

# Hint 3: Set u_recovery to 1 and rerun the model:
m_params$u_recovery <- 1

# Hint 4: Please check results' reproducibility by repeating 01_model_run.R.

# Hint 5: Check the transition probability matrix in 03_R/02_model_functions.R.

# Two functions you might consider (from the darthtools package):
# Checks if each row of the transition matrices sums to one.
check_sum_of_transition_array(MM.mat)
# Checks if transition probabilities are within [0, 1].
check_transition_probability(MM.mat)

# Hint 6: If there are potential problems with the transition probability matrix,
# try to check each probability element of the transition matrix.

# Hint 7a: Check the PSA scatter output plot.
plot_psa(l_psa, txtsize = 13)

# Hint 7b: Also, try setting c_treatment_2 to another value and check the model's output.
l_params_all$c_treatment_2 <- 350
