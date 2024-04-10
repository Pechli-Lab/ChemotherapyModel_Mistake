# Validating Health Economics Models in R Exercise



## Reference Papers

The Chemotherapy Model for "Value of Information for Health Economic Evalulations", Heath, Kunst and Jackson (2021).

This model is structured based on "A Need for Change! A Coding Framework for Improving Transparency in Decision Modeling" by Alarid-Escudero, F., Krijkamp, E., Pechlivanoglou, P., Jalal, H., Kao, S., Yang, A. and Enns, E.

This model has been adapted from a model presented in "Calculating the Expected Value of Sample Information Using Efficient Nested Monte Carlo: A Tutorial" by Heath, A. and Baio G. This will be used as the running example throughout the book.



## Instructions and Code File Structure

For R users, after downloading the entire folder, double-click the Rproj file named `Chemotherapy_Model_book_mistakes.Rproj`. This will set up your working environment automatically via the Rproj file.

The folder structure is as follows:

- `01_data_raw`: Contains raw CSV data files.
- `02_data`: Contains model inputs derived from raw data and distribution parameter assumptions.
- `03_R`: Contains scripts for miscellaneous functions and model functions.
- `04_analysis`: Here, we run the chemotherapy model, conduct analyses, and create plots using `01_model_run.R`.

Output directories:
- `05_output`: Stores output files.
- `06_figs`: Stores figures.
- `07_tables`: Stores tables.

**Model Inputs Tables:** `R_HTA_Tables.pdf`



## Errors

There are **8 errors** in the model located within the scripts:

* `02_data/02_Assumption_Inputs.R`
* `03_R/01_misc_functions.R`
* `03_R/02_model_functions.R`. 

Please note that there's no error or warning messages will appear if you run the model using the script `04_analysis/01_model_run.R`.



## Hints

**Hints and code** are located in `04_analysis/02_hints_to_detect_errors.R`. 

* **General Hints**: 

  ```R
  # Command to check generated PSA parameters:
  apply(m_params, 2, mean)
  round(apply(m_params, 2, sd), 3)
  
  # Command to check the result dataframe:
  apply(df_e, 2, mean)
  apply(df_c, 2, mean)
  ```

* **Hint 1**: Compare definitions in `02_data/02_Assumption_inputs.R` with `R_HTA_Tables.pdf`.

  

* **Hint 2**: Beta distribution's parameters, alpha and beta, should both be greater than 0.

  

* **Hint 3**: Set `u_recovery` to 1 and rerun the model.

  ```R
  m_params$u_recovery <- 1
  ```



* **Hint 4**: Please check results' reproducibility by repeating `01_model_run.R`.

  

* **Hint 5**: Check the transition probability matrix in `03_R/02_model_functions.R`.

  Two functions you might consider (from the ***darthtools*** package):

  ```R
  # Checks if each row of the transition matrices sums to one.
  check_sum_of_transition_array(MM.mat)
  # Checks if transition probabilities are within [0, 1].
  check_transition_probability(MM.mat)
  ```



* **Hint 6**: If there are potential problems with the transition probability matrix, try to check each probability element of the transition matrix.

  

* **Hint 7a**: Check the PSA scatter plot output plot.

  ```R
  plot_psa(l_psa, txtsize = 13)
  ```

  

* **Hint 7b**: Also, try setting `c_treatment_2` to another value and check the model's output.

  ```R
  l_params_all$c_treatment_2 <- 350000
  ```

  



