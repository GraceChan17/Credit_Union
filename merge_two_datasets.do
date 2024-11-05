********************* 20241105 ***************************

* First, ensure the bank names are standardized between datasets
* Convert bank names to lowercase in both datasets to avoid case mismatches
use combined_data_necessary_variables.dta, clear
gen instme_temp = lower(instme)

* Create a temporary version of the second dataset with standardized names
use fed_deposit_with_controls_update.dta, clear
replace inst_nm = lower(inst_nm)
save fed_deposit_temp.dta, replace

* Perform the merge
use combined_data_necessary_variables.dta, clear
merge m:m quarter instme using fed_deposit_temp.dta

* Check merge results
tab _merge

* Clean up
erase fed_deposit_temp.dta
