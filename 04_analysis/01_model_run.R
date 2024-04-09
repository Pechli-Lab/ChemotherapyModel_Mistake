################################################################################
#### Chemotherapy Model Run Example
################################################################################

#1. Setup and Preliminaries
# Set seed for reproducibility
set.seed(123)

# Install and load required packages
if (!require('pacman')) install.packages('pacman')
library(pacman)
p_load("dplyr", "tidyr", "reshape2", "devtools", "scales", "ellipse", "ggplot2", "lazyeval", "igraph", "truncnorm", "ggraph", "knitr", "stringr", "diagram", "dampack", install = FALSE)
p_load_gh("DARTH-git/darthtools") # Uncomment if needed

# Load external inputs and functions
source("02_data/01_data_inputs.R")
source("02_data/02_assumption_inputs.R")
source("03_R/01_misc_functions.R")
source("03_R/02_model_functions.R")

#2. Generate PSA Parameters
# Define the number of simulations and strategies
n_psa_size  <- 5000
n_str       <- 2
v_names_str <- c("SoC", "Novel")

# Generate PSA parameters
m_params <- generate_psa_parameters(n_psa_size)

# Define basic PSA parameters
l_params_all <- list(
  time_horizon = time_horizon,
  time_horizon_longterm = time_horizon_longterm,
  c_treatment_1 = c_treatment_1,
  c_treatment_2 = c_treatment_2
)

#3. Initialize Output Data Frames
# Initialize data frames for storing costs and effectiveness
df_c <- as.data.frame(matrix(0, nrow = n_psa_size, ncol = n_str))
colnames(df_c) <- v_names_str

df_e <- as.data.frame(matrix(0, nrow = n_psa_size, ncol = n_str))
colnames(df_e) <- v_names_str

#4. Run the Model
# Run the model for each parameter set
for (i in 1:n_psa_size) {
  l_psa_input <- update_param_list(l_params_all, m_params[i,])
  l_out_ce_temp <- calculate_costs_effects(l_psa_input)
  df_c[i, ] <- l_out_ce_temp["Costs",]
  df_e[i, ] <- l_out_ce_temp["Effects",]
  
  if (i/(n_psa_size/100) == round(i/(n_psa_size/100), 0)) {
    cat('\r', paste(i/n_psa_size * 100, "% done", sep = " "))
  }
}

# Save intermediate results to CSV files
write.csv(df_c, "07_tables/costs.csv")
write.csv(df_e, "07_tables/effects.csv")

#5. Create and Analyze PSA Object
# Create PSA object with dampack
l_psa <- make_psa_obj(cost = df_c, effectiveness = df_e, parameters = m_params, strategies = v_names_str)

# Vector with willingness-to-pay (WTP) thresholds
v_wtp <- seq(0, 50000, by = 1000)

# Generate and display visualizations of the PSA results, then save to PDF

# Probabilistic Sensitivity Analysis (PSA) Scatter Plot
plot_psa(l_psa, txtsize = 13)
dev.copy2pdf(file = "06_figs/psa_scatter_plot.pdf", width = 7, height = 5)
dev.off()  # Close the PDF device

# Incremental Cost-Effectiveness Ratio (ICER) Plot
df_cea_psa <- calculate_icers(cost = summary(l_psa)$meanCost, effect = summary(l_psa)$meanEffect, strategies = summary(l_psa)$Strategy)
plot_icers(df_cea_psa, label = "all", txtsize = 13)
dev.copy2pdf(file = "06_figs/icer_plot.pdf", width = 7, height = 5)
dev.off()  # Close the PDF device

# Cost-Effectiveness Acceptability Curve (CEAC) Plot
ceac_obj <- ceac(wtp = v_wtp, psa = l_psa)
plot_ceac(ceac_obj, txtsize = 13, xlim = c(0, NA), n_x_ticks = 14)
dev.copy2pdf(file = "06_figs/ceac_plot.pdf", width = 7, height = 5)
dev.off()  # Close the PDF device

# Expected Loss Curve (ELC) Plot
elc_obj <- calc_exp_loss(wtp = v_wtp, psa = l_psa)
plot_exp_loss(elc_obj, log_y = FALSE, txtsize = 13, xlim = c(0, NA), n_x_ticks = 14)
dev.copy2pdf(file = "06_figs/elc_plot.pdf", width = 7, height = 5)
dev.off()  # Close the PDF device

# Expected Value of Perfect Information (EVPI) Plot
evpi_obj <- calc_evpi(wtp = v_wtp, psa = l_psa)
plot_evpi(evpi_obj, effect_units = "QALY", txtsize = 13, xlim = c(0, NA), n_x_ticks = 14)
dev.copy2pdf(file = "06_figs/evpi_plot.pdf", width = 7, height = 5)
dev.off()  # Close the PDF device
