** 1106 **

********************************************************************************
* Analysis of Response to Fed's Rate Cut: Credit Union vs Bank
* Data: RateWatch deposit rates and Federal Funds Rate (2001-2020)
********************************************************************************


*************** Part 1: Process RateWatch Data ***************
clear all
set more off

* Directory setup
global data_dir "/Volumes/WD Drive +/CreditUnion"
cd "$data_dir/1106"



**************************** Create small dta file based on product category ********************************
* Process data year by year
* First attempt: Year 2001
display "Processing year 2001"
    
* Import and clean data
import delimited using "$data_dir/Data/ratewatch/Original_ratewatch_Data/depositRateData_clean_2001.txt", delimiter("|") clear

* Keep necassary variables
keep accountnumber producttype productdescription termlength rate apy datesurveyed

* Filter products and create categories
keep if inlist(producttype, "CD", "SAV", "MM", "INTCK")

gen product_category = cond(producttype == "CD", ///
    cond(termlength <= 60, "short_term_cd", "long_term_cd"), ///
    producttype)

* Keep necessary productdescription
* CD-10K(3m,6m,12m,24m,36m,48m, long term cd), MM-2.5K, INTCK-2.5K, SAV-2.5K
keep if productdescription == "MM2.5K" | productdescription == "SAV2.5K" | productdescription == "INTCK2.5K" | productdescription == "03MCD10K" | productdescription == "06MCD10K" | productdescription == "12MCD10K" | productdescription == "24MCD10K"| productdescription == "36MCD10K"| productdescription == "48MCD10K"| productdescription == "60MCD10K" | product_category == "long_term_cd"

* Double check
tab productdescription

* Create a temporary cleaned date variable
gen temp_date = datesurveyed

* Remove the time portion and any trailing characters for longer format
replace temp_date = substr(temp_date, 1, 10) if strpos(temp_date, "T") > 0

* Convert string date to Stata date format
gen date_clean = date(temp_date, "YMD")
format date_clean %td

* Generate quarter variable
gen quarter = qofd(date_clean)
format quarter %tq

* Create a string version if needed (e.g., "2001q1")
gen quarter_str = string(year(dofq(quarter))) + "q" + string(quarter(dofq(quarter)))

* Clean up
drop temp_date

* Example of how to label the quarters if needed
label define quarter_lbl 164 "2001q1" 165 "2001q2" 166 "2001q3" 167 "2001q4" ///
                        168 "2002q1" 169 "2002q2" 170 "2002q3" 171 "2002q4" ///
                        172 "2003q1" 173 "2003q2" 174 "2003q3" 175 "2003q4" ///
                        176 "2004q1" 177 "2004q2" 178 "2004q3" 179 "2004q4" ///
                        180 "2005q1" 181 "2005q2" 182 "2005q3" 183 "2005q4" ///
                        184 "2006q1" 185 "2006q2" 186 "2006q3" 187 "2006q4" ///
                        188 "2007q1" 189 "2007q2" 190 "2007q3" 191 "2007q4"
label values quarter quarter_lbl

* Display example records to verify
list datesurveyed quarter quarter_str in 1/5

* Rearrange variables
drop quarter date_clean datesurveyed termlength
rename quarter_str quarter
rename rate deposit_rate

* Save as a dta file
save year_2001.dta, replace


* First, preserve the original dataset
preserve

* Split and save for Money Market accounts (MM)
use accountnumber productdescription producttype deposit_rate apy product_category quarter using year_2001.dta if product_category == "MM", clear
save MM_2001.dta, replace

* Split and save for Savings accounts (SAV)
use accountnumber productdescription producttype deposit_rate apy product_category quarter using year_2001.dta if product_category == "SAV", clear
save SAV_2001.dta, replace

* Split and save for Interest Checking accounts (INTCK)
use accountnumber productdescription producttype deposit_rate apy product_category quarter using year_2001.dta if product_category == "INTCK", clear
save INTCK_2001.dta, replace

* Split and save for Long-term CD accounts
use accountnumber productdescription producttype deposit_rate apy product_category quarter using year_2001.dta if product_category == "long_term_cd", clear
save long_term_cd_2001.dta, replace

* Split and save for Short-term CD accounts
use accountnumber productdescription producttype deposit_rate apy product_category quarter using year_2001.dta if product_category == "short_term_cd", clear
save short_term_cd_2001.dta, replace

* Restore the original dataset
restore


* Create a loop to process data for year 2002-2020
* Loop through years 2002-2020
forvalues year = 2002/2020 {
    display _n "Processing year `year'"
    
    * Import and clean data
    import delimited using "$data_dir/Data/ratewatch/Original_ratewatch_Data/depositRateData_clean_`year'.txt", delimiter("|") clear
    
    * Keep necessary variables
    keep accountnumber producttype productdescription termlength rate apy datesurveyed
    
    * Filter products and create categories
    keep if inlist(producttype, "CD", "SAV", "MM", "INTCK")
    gen product_category = cond(producttype == "CD", ///
        cond(termlength <= 60, "short_term_cd", "long_term_cd"), ///
        producttype)
    
    * Keep necessary productdescription
    keep if productdescription == "MM2.5K" | ///
           productdescription == "SAV2.5K" | ///
           productdescription == "INTCK2.5K" | ///
           productdescription == "03MCD10K" | ///
           productdescription == "06MCD10K" | ///
           productdescription == "12MCD10K" | ///
           productdescription == "24MCD10K" | ///
           productdescription == "36MCD10K" | ///
           productdescription == "48MCD10K" | ///
           productdescription == "60MCD10K" | ///
           product_category == "long_term_cd"
    
    * Create and clean date variables
    gen temp_date = datesurveyed
    replace temp_date = substr(temp_date, 1, 10) if strpos(temp_date, "T") > 0
    gen date_clean = date(temp_date, "YMD")
    format date_clean %td
    
    * Generate quarter variables
    gen quarter = qofd(date_clean)
    format quarter %tq
    gen quarter_str = string(year(dofq(quarter))) + "q" + string(quarter(dofq(quarter)))
    
    * Clean up
    drop temp_date
    
    * Label quarters (only needs to be done once, but kept for consistency)
    label define quarter_lbl 164 "2001q1" 165 "2001q2" 166 "2001q3" 167 "2001q4" ///
                            168 "2002q1" 169 "2002q2" 170 "2002q3" 171 "2002q4" ///
                            172 "2003q1" 173 "2003q2" 174 "2003q3" 175 "2003q4" ///
                            176 "2004q1" 177 "2004q2" 178 "2004q3" 179 "2004q4" ///
                            180 "2005q1" 181 "2005q2" 182 "2005q3" 183 "2005q4" ///
                            184 "2006q1" 185 "2006q2" 186 "2006q3" 187 "2006q4" ///
                            188 "2007q1" 189 "2007q2" 190 "2007q3" 191 "2007q4", replace
    label values quarter quarter_lbl
    
    * Rearrange and rename variables
    drop quarter date_clean datesurveyed termlength
    rename quarter_str quarter
    rename rate deposit_rate
    
    * Save main yearly file
    save year_`year'.dta, replace
    
    * Split into category-specific files
    preserve
    
    foreach category in "MM" "SAV" "INTCK" "long_term_cd" "short_term_cd" {
        use accountnumber productdescription producttype deposit_rate apy product_category quarter ///
            using year_`year'.dta if product_category == "`category'", clear
        save `category'_`year'.dta, replace
    }
    
    restore
}



**************************** For long_term_cd: 2001-2020 *******************
* Loop through years 2001-2020
clear
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
clear
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
clear
forvalues year = 2001/2020{
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
clear
forvalues year = 2001/2020{
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

* Merge all years: short_term_cd
use short_term_cd_2001.dta, clear
forvalues year = 2002/2020 {
    append using short_term_cd_`year'.dta
}
save short_term_cd_2001_2020.dta, replace


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


* Merge 5 product categories into 1 dataset
use short_term_cd_2001_2020.dta, clear
append using long_term_cd_2001_2020.dta
append using SAV_2001_2020.dta
append using INTCK_2001_2020.dta
append using MM_2001_2020.dta

save cd_SAV_INTCK_MM_2001_2020.dta, replace



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


*************************** Part 3: Merge and Analyze Data *************************
******************* All product description: deposit_rate + fed_rate **************************
clear
cd "/Volumes/WD Drive +/CreditUnion/1106/initially_processed_dataset"
use deposit_rate/cd_SAV_INTCK_MM_2001_2020.dta, clear

* Check duplicates
duplicates list quarter accountnumber productdescription

* Browse duplicate sample
br accountnumber productdescription quarter deposit_rate apy producttype product_category if accountnumber == "WV00100026" & productdescription == "60MCD10K" & quarter == "2020q1"

* Take average for deposit_rate and apy
collapse (mean) deposit_rate apy (firstnm) producttype product_category, by(accountnumber quarter productdescription)

* Double checkduplicates list quarter accountnumber productdescription
duplicates list quarter accountnumber productdescription /// should show 0 observations are duplicates


save deposit_rate/cd_SAV_INTCK_MM_2001_2020.dta, replace

* Process product_category == long_term_cd
preserve
keep if product_category == "long_term_cd"

* Take average
collapse (mean) deposit_rate apy, by(accountnumber quarter)

* Double checkduplicates list quarter accountnumber productdescription
duplicates list quarter accountnumber product_category if product_category == "long_term_cd" /// should show 0 observations are duplicates

gen product_category = "long_term_cd"
gen productdescription = "long_term_cd"
gen producttype = "long_term_cd"

tempfile long_term_means

save long_term_means.dta, replace


restore


drop if product_category == "long_term_cd"
append using long_term_means.dta

sort accountnumber quarter product_category


* Double check
duplicates list quarter accountnumber productdescription /// should show 0 observations are duplicates
duplicates list quarter accountnumber product_category if product_category == "long_term_cd"

****************************************************************************
****************************************************************************

* Merge with Fed data
merge m:1 quarter using fed_rate/fed_funds_quarterly.dta
keep if _merge == 3
drop _merge

replace producttype = "short_term_cd" if producttype == "CD"

* Process very time length of short_term_cd
sort accountnumber productdescription quarter
by accountnumber productdescription: gen deposit_rate_change = deposit_rate - deposit_rate[_n-1]

* Save combined data: deposit rate + federal funds effective rate
save fed_deposit.dta, replace



******************* INTCK: deposit_rate + fed_rate **************************
clear
cd "/Volumes/WD Drive +/CreditUnion/1106/initially_processed_dataset"
use deposit_rate/INTCK_2001_2020.dta, clear

* Check duplicates
duplicates list quarter accountnumber

* Take average for deposit_rate and apy
collapse (mean) deposit_rate apy (firstnm) productdescription producttype product_category, by(accountnumber quarter)

* Double check duplicates(should show 0 observations are duplicates)
duplicates list quarter accountnumber

* Merge with Fed data
merge m:1 quarter using fed_rate/fed_funds_quarterly.dta
keep if _merge == 3
drop _merge

* Process very time length of short_term_cd
sort accountnumber quarter
by accountnumber: gen deposit_rate_change = deposit_rate - deposit_rate[_n-1]

* Save data: deposit rate + federal funds effective rate
save fed_deposit_INTCK.dta, replace



******************* SAV: deposit_rate + fed_rate **************************
clear
cd "/Volumes/WD Drive +/CreditUnion/1106/initially_processed_dataset"
use deposit_rate/SAV_2001_2020.dta, clear

* Check duplicates
duplicates list quarter accountnumber

* Take average for deposit_rate and apy
collapse (mean) deposit_rate apy (firstnm) productdescription producttype product_category, by(accountnumber quarter)

* Double check duplicates(should show 0 observations are duplicates)
duplicates list quarter accountnumber

* Merge with Fed data
merge m:1 quarter using fed_rate/fed_funds_quarterly.dta
keep if _merge == 3
drop _merge

* Process very time length of short_term_cd
sort accountnumber quarter
by accountnumber: gen deposit_rate_change = deposit_rate - deposit_rate[_n-1]

* Save data: deposit rate + federal funds effective rate
save fed_deposit_SAV.dta, replace




******************* MM: deposit_rate + fed_rate **************************
clear
cd "/Volumes/WD Drive +/CreditUnion/1106/initially_processed_dataset"
use deposit_rate/MM_2001_2020.dta, clear

* Check duplicates
duplicates list quarter accountnumber

* Take average for deposit_rate and apy
collapse (mean) deposit_rate apy (firstnm) productdescription producttype product_category, by(accountnumber quarter)

* Double check duplicates(should show 0 observations are duplicates)
duplicates list quarter accountnumber

* Merge with Fed data
merge m:1 quarter using fed_rate/fed_funds_quarterly.dta
keep if _merge == 3
drop _merge

* Process very time length of short_term_cd
sort accountnumber quarter
by accountnumber: gen deposit_rate_change = deposit_rate - deposit_rate[_n-1]

* Save data: deposit rate + federal funds effective rate
save fed_deposit_MM.dta, replace


******************* long_term_cd: deposit_rate + fed_rate **************************
clear
cd "/Volumes/WD Drive +/CreditUnion/1106/initially_processed_dataset"
use deposit_rate/long_term_cd_2001_2020.dta, clear

* Check duplicates
duplicates list quarter accountnumber 

* Take average for deposit_rate and apy
collapse (mean) deposit_rate apy (firstnm) productdescription producttype product_category, by(accountnumber quarter)

* Double check duplicates(should show 0 observations are duplicates)
duplicates list quarter accountnumber

* Merge with Fed data
merge m:1 quarter using fed_rate/fed_funds_quarterly.dta
keep if _merge == 3
drop _merge

* Process very time length of short_term_cd
sort accountnumber quarter
by accountnumber: gen deposit_rate_change = deposit_rate - deposit_rate[_n-1]

* Save data: deposit rate + federal funds effective rate
save fed_deposit_long_term_cd.dta, replace


******************* short_term_cd: deposit_rate + fed_rate **************************
clear
cd "/Volumes/WD Drive +/CreditUnion/1106/initially_processed_dataset"
use deposit_rate/short_term_cd_2001_2020.dta, clear

* Check duplicates
duplicates list quarter accountnumber productdescription

* Take average for deposit_rate and apy
collapse (mean) deposit_rate apy (firstnm) producttype product_category, by(accountnumber quarter productdescription)

* Double check duplicates(should show 0 observations are duplicates)
duplicates list quarter accountnumber productdescription

* Merge with Fed data
merge m:1 quarter using fed_rate/fed_funds_quarterly.dta
keep if _merge == 3
drop _merge

* Process very time length of short_term_cd
sort accountnumber productdescription quarter
by accountnumber productdescription: gen deposit_rate_change = deposit_rate - deposit_rate[_n-1]

* Save data: deposit rate + federal funds effective rate
save fed_deposit_short_term_cd.dta, replace





*************************** Part 4: Institution charateristics ******************************
* Import data
clear
import delimited "/Volumes/WD Drive +/CreditUnion/Data/ratewatch/Original_ratewatch_Data/Deposit_InstitutionDetails.txt", clear

* Arrange variables
rename acct_nbr accountnumber
keep if inst_typ == "BK"| inst_typ == "CU"
drop web phone
keep accountnumber inst_nm inst_typ est_dt state

* Generate dummy variable: CU_dummy (1 for CU, 0 for BK)
gen CU_dummy = .
replace CU_dummy = 1 if inst_typ == "CU"
replace CU_dummy = 0 if inst_typ == "BK"

drop inst_typ

* Standardize institution names
* Process inst_nm
gen inst_nm_clean = lower(trim(inst_nm))
replace inst_nm_clean = subinstr(inst_nm_clean, ".", "", .)
replace inst_nm_clean = subinstr(inst_nm_clean, ",", "", .)
replace inst_nm_clean = subinstr(inst_nm_clean, "inc", "", .)
replace inst_nm_clean = subinstr(inst_nm_clean, "corp", "", .)


save institution_details.dta, replace








































