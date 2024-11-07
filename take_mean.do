************* Take average of deposit_rate & apy *************************
global data_dir "/Volumes/WD Drive +/CreditUnion"
cd "$data_dir/1106"


**************************** For long_term_cd: 2001-2020 *******************
* Loop through years 2001-2020
forvalues year = 2001/2020{
	display _n " Processing year `year'"
	
	* Import data
	use long_term_cd_`year'.dta, clear
	
	* Take average for deposit_rate and apy
	collapse (mean) deposit_rate apy (firstnm) productdescription producttype ///
	product_category, by(accountnumber quarter)

	* Double check
	duplicates list accountnumber quarter
	
	* Save data
	save long_term_cd_`year'_new.dta, replace

}

* Merge all years
use long_term_cd_2001_new.dta, clear
forvalues year = 2002/2020 {
    append using long_term_cd_`year'_new.dta
}
save long_term_cd_2001_2020.dta, replace



**************************** For SAV: 2001-2020 *******************
* Loop through years 2001-2020
forvalues year = 2001/2020{
	display _n " Processing year `year'"
	
	* Import data
	use SAV_`year'.dta, clear
	
	* Take average for deposit_rate and apy
	collapse (mean) deposit_rate apy (firstnm) productdescription producttype ///
	product_category, by(accountnumber quarter)

	* Double check
	duplicates list accountnumber quarter
	
	* Save data
	save SAV_`year'_new.dta, replace

}

* Merge all years
use SAV_2001_new.dta, clear
forvalues year = 2002/2020 {
    append using SAV_`year'_new.dta
}
save SAV_2001_2020.dta, replace


**************************** For INTCK: 2001-2020 *******************
* Loop through years 2001-2020
forvalues year = 2001/2001{
	display _n " Processing year `year'"
	
	* Import data
	use INTCK_`year'.dta, clear
	
	* Take average for deposit_rate and apy
	collapse (mean) deposit_rate apy (firstnm) productdescription producttype ///
	product_category, by(accountnumber quarter)

	* Double check
	duplicates list accountnumber quarter
	
	* Save data
	save INTCK_`year'_new.dta, replace

}

* Merge all years
use INTCK_2001_new.dta, clear
forvalues year = 2002/2020 {
    append using INTCK_`year'_new.dta
}
save INTCK_2001_2020.dta, replace


**************************** For MM: 2001-2020 *******************
* Loop through years 2001-2020
forvalues year = 2001/2001{
	display _n " Processing year `year'"
	
	* Import data
	use MM_`year'.dta, clear
	
	* Take average for deposit_rate and apy
	collapse (mean) deposit_rate apy (firstnm) productdescription producttype ///
	product_category, by(accountnumber quarter)

	* Double check
	duplicates list accountnumber quarter
	
	* Save data
	save MM_`year'_new.dta, replace

}

* Merge all years
use MM_2001_new.dta, clear
forvalues year = 2002/2020 {
    append using MM_`year'_new.dta
}
save MM_2001_2020.dta, replace


**************************** For short_term_cd: 2001-2020 ******************
* Loop through years 2001-2020
forvalues year = 2001/2020{
	display _n " Processing year `year'"
	
	* Import data
	use short_term_cd_`year'.dta, clear
	
	* Take average for deposit_rate and apy
	collapse (mean) deposit_rate apy (firstnm) producttype product_category, ///
	by(accountnumber productdescription quarter)
	
	
	* Save processed data
	save short_term_cd_`year'.dta, replace
	
	preserve
	
	* Split and save for 03MCD10K
	use accountnumber productdescription quarter deposit_rate apy producttype ///
	product_category using short_term_cd_`year'.dta if productdescription == "03MCD10K", clear
	save CD_03MCD10K_`year'.dta, replace
	
    * Split and save for 06MCD10K
	use accountnumber productdescription quarter deposit_rate apy producttype ///
	product_category using short_term_cd_`year'.dta if productdescription == "06MCD10K", clear
	save CD_06MCD10K_`year'.dta, replace
	
	* Split and save for 12MCD10K
	use accountnumber productdescription quarter deposit_rate apy producttype ///
	product_category using short_term_cd_`year'.dta if productdescription == "12MCD10K", clear
	save CD_12MCD10K_`year'.dta, replace
	
	* Split and save for 24MCD10K
	use accountnumber productdescription quarter deposit_rate apy producttype ///
	product_category using short_term_cd_`year'.dta if productdescription == "24MCD10K", clear
	save CD_24MCD10K_`year'.dta, replace
	
	* Split and save for 36MCD10K
	use accountnumber productdescription quarter deposit_rate apy producttype ///
	product_category using short_term_cd_`year'.dta if productdescription == "36MCD10K", clear
	save CD_36MCD10K_`year'.dta, replace
	
	* Split and save for 48MCD10K
	use accountnumber productdescription quarter deposit_rate apy producttype ///
	product_category using short_term_cd_`year'.dta if productdescription == "48MCD10K", clear
	save CD_48MCD10K_`year'.dta, replace
	
	* Split and save for 60MCD10K
	use accountnumber productdescription quarter deposit_rate apy producttype ///
	product_category using short_term_cd_`year'.dta if productdescription == "60MCD10K", clear
	save CD_60MCD10K_`year'.dta, replace
	

}



* Merge all years: 03MCD10K
use CD_03MCD10K_2001.dta, clear
forvalues year = 2002/2020 {
    append using CD_03MCD10K_`year'.dta
}
save CD_03MCD10K_2001_2020.dta, replace


* Merge all years: 06MCD10K
use CD_06MCD10K_2001.dta, clear
forvalues year = 2002/2020 {
    append using CD_06MCD10K_`year'.dta
}
save CD_06MCD10K_2001_2020.dta, replace

* Merge all years: 12MCD10K
use CD_12MCD10K_2001.dta, clear
forvalues year = 2002/2020 {
    append using CD_12MCD10K_`year'.dta
}
save CD_12MCD10K_2001_2020.dta, replace

* Merge all years: 24MCD10K
use CD_24MCD10K_2001.dta, clear
forvalues year = 2002/2020 {
    append using CD_24MCD10K_`year'.dta
}
save CD_24MCD10K_2001_2020.dta, replace

* Merge all years: 36MCD10K
use CD_36MCD10K_2001.dta, clear
forvalues year = 2002/2020 {
    append using CD_36MCD10K_`year'.dta
}
save CD_36MCD10K_2001_2020.dta, replace

* Merge all years: 48MCD10K
use CD_48MCD10K_2001.dta, clear
forvalues year = 2002/2020 {
    append using CD_48MCD10K_`year'.dta
}
save CD_48MCD10K_2001_2020.dta, replace

* Merge all years: 60MCD10K
use CD_60MCD10K_2001.dta, clear
forvalues year = 2002/2020 {
    append using CD_60MCD10K_`year'.dta
}
save CD_60MCD10K_2001_2020.dta, replace




*************** Part 2: Process Federal Funds Rate Data ***************
clear all
import delimited using Federal_Funds_Effective_Rate_2001_2020.csv, clear

* Create a temporary cleaned date variable
gen date_temp = date

* Convert string date to Stata date format
gen date_clean = date(date_temp, "YMD")
format date_clean %td

*Generate quarter variable
gen quarter = qofd(date_clean)
format quarter %tq

* Create a string version if needed(e.g., "2001q1")
gen quarter_str = string(year(dofq(quarter))) + "q" + string(quarter(dofq(quarter)))

* Clean up
drop date date_temp date_clean quarter
rename quarter_str quarter
rename fedfunds fed_rate

* Generate rate change indicators
sort quarter
gen fed_rate_decrease = (fed_rate < fed_rate[_n-1]) // 1 for decreased or 0 for increased
gen fed_rate_change = fed_rate - fed_rate[_n-1]

save fed_funds_quarterly.dta, replace


*************** Part 3: Merge and Analyze Data ***************





















