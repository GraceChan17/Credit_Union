**************** 1018 ************************


********************************************************************************
* Analysis of Response to Fed's Rate Cut: Credit Union vs Bank
* Data: RateWatch deposit rates and Federal Funds Rate (2001-2020)
********************************************************************************


clear all
set more off

* Directory setup
global data_dir "/Volumes/WD Drive +/CreditUnion"
cd "$data_dir/1106"


********************************************************************************
**************** Part 0: Institution Details **********************
********************************************************************************

import delimited "/Volumes/aae/groups/Data/zchen2365/ratewatch/Deposit_InstitutionDetails.txt", clear

* Rearrange variables
rename acct_nbr accountnumber
drop brnch_srv_typ ho_uninumbr web phone hd_offc rtng_nbr address zip city county branches lon lat cnty_fps state_fps msa cbsa tm_zone
keep if inst_typ == "CU" | inst_typ == "BK"

* Save dataset
save processed_institution_details.dta, replace



********************************************************************************
*************** Part 1: Process RateWatch Data ***************
********************************************************************************

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

* Keep necessary productdescription
* CD-10K(3m, 1year, 10year), MM-2.5K, INTCK-2.5K, SAV-2.5K
keep if productdescription == "MM2.5K" | productdescription == "SAV2.5K" | productdescription == "INTCK2.5K" | productdescription == "03MCD10K" | productdescription == "12MCD10K" | termlength == 120

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

*Calculate mean of deposit_rate & apy (quarter + accountnumber + productdescription)
collapse (mean) deposit_rate apy (firstnm) producttype, by(accountnumber quarter productdescription)

* Save as a dta file
save year_2001.dta, replace


* First, preserve the original dataset
preserve

* Split and save for Money Market accounts (MM)
use accountnumber productdescription producttype deposit_rate apy quarter using year_2001.dta if producttype == "MM", clear
save MM2.5K_2001.dta, replace

* Split and save for Savings accounts (SAV)
use accountnumber productdescription producttype deposit_rate apy quarter using year_2001.dta if producttype == "SAV", clear
save SAV2.5K_2001.dta, replace

* Split and save for Interest Checking accounts (INTCK)
use accountnumber productdescription producttype deposit_rate apy quarter using year_2001.dta if producttype == "INTCK", clear
save INTCK2.5K_2001.dta, replace

* Split and save for Long-term CD accounts
use accountnumber productdescription producttype deposit_rate apy quarter using year_2001.dta if productdescription == "120MoCD", clear
save 120MoCD_2001.dta, replace

* Split and save for Short-term CD accounts
use accountnumber productdescription producttype deposit_rate apy quarter using year_2001.dta if productdescription == "03MCD10K", clear
save 03MCD10K_2001.dta, replace

use accountnumber productdescription producttype deposit_rate apy quarter using year_2001.dta if productdescription == "12MCD10K", clear
save 12MCD10K_2001.dta, replace


* Restore the original dataset
restore


* Create a loop to process data for year 2002-2020
* Loop through years 2002-2020
forvalues year = 2002/2020 {
    display _n "Processing year `year'"
    
    * Import and clean data
    import delimited using "$data_dir/Data/ratewatch/Original_ratewatch_Data/depositRateData_clean_`year'.txt", delimiter("|") clear
    
    * Keep necassary variables
    keep accountnumber producttype productdescription termlength rate apy datesurveyed
    
    * Filter products and create categories
    keep if inlist(producttype, "CD", "SAV", "MM", "INTCK")
    
    * Keep necessary productdescription
    * CD-10K(3m, 1year, 10year), MM-2.5K, INTCK-2.5K, SAV-2.5K
    keep if productdescription == "MM2.5K" | productdescription == "SAV2.5K" | productdescription == "INTCK2.5K" | productdescription == "03MCD10K" | productdescription == "12MCD10K" | productdescription == "120MoCD"
    
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
    
    *Calculate mean of deposit_rate & apy (quarter + accountnumber + productdescription)
    collapse (mean) deposit_rate apy (firstnm) producttype, by(accountnumber quarter productdescription)
    
    * Save main yearly file
    save year_`year'.dta, replace
    
    * Split into category-specific files
    preserve
    
    foreach description in "MM2.5K" "SAV2.5K" "INTCK2.5K" "03MCD10K" "12MCD10K" "120MoCD" {
        use accountnumber productdescription producttype deposit_rate apy quarter ///
            using year_`year'.dta if productdescription == "`description'", clear
        save `description'_`year'.dta, replace
    }
    restore
}



********************** Create complied dataset ***********************
******* 1. MM2.5K ************
use MM2.5K_2001.dta, clear
forvalues year = 2002/2020 {
    append using MM2.5K_`year'.dta
}
save MM2.5K_2001_2020.dta, replace

* Merge with Fed data
merge m:1 accountnumber using "/Volumes/aae/users/zchen2365/1018/processed_institution_details.dta"
keep if _merge == 3
drop _merge

preserve
drop accountnumber
*Calculate mean of deposit_rate & apy (quarter + accountnumber + productdescription)
collapse (mean) deposit_rate apy asset_sz institutiondeposits branchdeposits (firstnm) productdescription producttype inst_nm inst_typ uninumbr rssd_id est_dt state, by(quarter cert_nbr)

* Merge with Fed data
merge m:1 quarter using "/Volumes/aae/users/zchen2365/1106/dataset/fed_funds_quarterly.dta"
keep if _merge == 3
drop _merge

save "/Volumes/aae/users/zchen2365/1018/MM2.5K_fed_instdetails.dta", replace
restore


******* 2. SAV2.5K ************
use SAV2.5K_2001.dta, clear
forvalues year = 2002/2020 {
    append using SAV2.5K_`year'.dta
}
save SAV2.5K_2001_2020.dta, replace


* Merge with Fed data
merge m:1 accountnumber using "/Volumes/aae/users/zchen2365/1018/processed_institution_details.dta"
keep if _merge == 3
drop _merge

preserve
drop accountnumber
*Calculate mean of deposit_rate & apy (quarter + accountnumber + productdescription)
collapse (mean) deposit_rate apy asset_sz institutiondeposits branchdeposits (firstnm) productdescription producttype inst_nm inst_typ uninumbr rssd_id est_dt state, by(quarter cert_nbr)

* Merge with Fed data
merge m:1 quarter using "/Volumes/aae/users/zchen2365/1106/dataset/fed_funds_quarterly.dta"
keep if _merge == 3
drop _merge

save "/Volumes/aae/users/zchen2365/1018/SAV2.5K_fed_instdetails.dta", replace
restore


******* 3. INTCK2.5K ************
use INTCK2.5K_2001.dta, clear
forvalues year = 2002/2020 {
    append using INTCK2.5K_`year'.dta
}
save INTCK2.5K_2001_2020.dta, replace


* Merge with Fed data
merge m:1 accountnumber using "/Volumes/aae/users/zchen2365/1018/processed_institution_details.dta"
keep if _merge == 3
drop _merge

preserve
drop accountnumber
*Calculate mean of deposit_rate & apy (quarter + accountnumber + productdescription)
collapse (mean) deposit_rate apy asset_sz institutiondeposits branchdeposits (firstnm) productdescription producttype inst_nm inst_typ uninumbr rssd_id est_dt state, by(quarter cert_nbr)

* Merge with Fed data
merge m:1 quarter using "/Volumes/aae/users/zchen2365/1106/dataset/fed_funds_quarterly.dta"
keep if _merge == 3
drop _merge

save "/Volumes/aae/users/zchen2365/1018/INTCK2.5K_fed_instdetails.dta", replace
restore


******* 4. 03MCD10K ************
use 03MCD10K_2001.dta, clear
forvalues year = 2002/2020 {
    append using 03MCD10K_`year'.dta
}
save 03MCD10K_2001_2020.dta, replace


* Merge with Fed data
merge m:1 accountnumber using "/Volumes/aae/users/zchen2365/1018/processed_institution_details.dta"
keep if _merge == 3
drop _merge

preserve
drop accountnumber
*Calculate mean of deposit_rate & apy (quarter + accountnumber + productdescription)
collapse (mean) deposit_rate apy asset_sz institutiondeposits branchdeposits (firstnm) productdescription producttype inst_nm inst_typ uninumbr rssd_id est_dt state, by(quarter cert_nbr)

* Merge with Fed data
merge m:1 quarter using "/Volumes/aae/users/zchen2365/1106/dataset/fed_funds_quarterly.dta"
keep if _merge == 3
drop _merge

save "/Volumes/aae/users/zchen2365/1018/03MCD10K_fed_instdetails.dta", replace
restore



******* 5. 12MCD10K ************
use 12MCD10K_2001.dta, clear
forvalues year = 2002/2020 {
    append using 12MCD10K_`year'.dta
}
save 12MCD10K_2001_2020.dta, replace


* Merge with Fed data
merge m:1 accountnumber using "/Volumes/aae/users/zchen2365/1018/processed_institution_details.dta"
keep if _merge == 3
drop _merge

preserve
drop accountnumber
*Calculate mean of deposit_rate & apy (quarter + accountnumber + productdescription)
collapse (mean) deposit_rate apy asset_sz institutiondeposits branchdeposits (firstnm) productdescription producttype inst_nm inst_typ uninumbr rssd_id est_dt state, by(quarter cert_nbr)

* Merge with Fed data
merge m:1 quarter using "/Volumes/aae/users/zchen2365/1106/dataset/fed_funds_quarterly.dta"
keep if _merge == 3
drop _merge

save "/Volumes/aae/users/zchen2365/1018/12MCD10K_fed_instdetails.dta", replace
restore



******* 6. 120MoCD ************
use 120MoCD_2001.dta, clear
forvalues year = 2002/2020 {
    append using 120MoCD_`year'.dta
}
save 120MoCD_2001_2020.dta, replace

* Merge with Fed data
merge m:1 accountnumber using "/Volumes/aae/users/zchen2365/1018/processed_institution_details.dta"
keep if _merge == 3
drop _merge

preserve
drop accountnumber
*Calculate mean of deposit_rate & apy (quarter + accountnumber + productdescription)
collapse (mean) deposit_rate apy asset_sz institutiondeposits branchdeposits (firstnm) productdescription producttype inst_nm inst_typ uninumbr rssd_id est_dt state, by(quarter cert_nbr)

* Merge with Fed data
merge m:1 quarter using "/Volumes/aae/users/zchen2365/1106/dataset/fed_funds_quarterly.dta"
keep if _merge == 3
drop _merge

save "/Volumes/aae/users/zchen2365/1018/120MoCD_fed_instdetails.dta", replace
restore






********************************************************************************
*************** Part 2: Combined Data ***************
********************************************************************************
clear
use "/Volumes/WD Drive +/CreditUnion/Data/Combined Data.dta", clear

* Convert string date to Stata date format
gen date_clean = date(period, "YM")
format date_clean %td

* Generate quarter variable
gen quarter = qofd(date_clean)
format quarter %tq

* Create a string version if needed (e.g., "2001q1")
gen quarter_str = string(year(dofq(quarter))) + "q" + string(quarter(dofq(quarter)))

* Focus research on 2001q1-2020q2
keep if year >= 2001 & year <= 2020
drop if quarter_str == "2020q3" | quarter_str == "2020q4"

* Keep necessary variables
keep quarter quarter_str id instme CU_dummy period cu_number total_assets amt_total_loans members marketShare ///
net_worth coreDeposits fee_income delqRatio netChargeOffRatio assetGrowth loanGrowth /// 
depositGrowth roa mortgages firstMortgages secondMortgages delqMortgages ///
branches total_liabilities total_capital member_growth capital_adequacy

rename id cert_nbr
rename quarter quarter1
rename quarter_str quarter

* Save data first
save "/Volumes/aae/users/zchen2365/1018/combined_processed_1st.dta", replace



********************************************************************************
*************** Part 3: Base  Pandel Regression Model ***************
********************************************************************************
******* 1. MM2.5K ************beginning
use "/Volumes/WD Drive +/CreditUnion/1018/MM2.5K_fed_instdetails.dta", clear

* Generate CU_dummy (1 for Credit Unions, 0 for Banks)
gen CU_dummy = (inst_typ == "CU")

* Create a new numeric quarter variable
rename quarter quarter_str
gen quarter = quarterly(quarter_str, "YQ")
format quarter %tq

* Check for outliers
* Look for extreme values in deposit rates
sum deposit_rate, detail

* Consider winsorizing if there are extreme outliers
winsor2 deposit_rate, cuts(1 99) replace

* Generate pre and post financial crisis dummy
gen post_crisis = (quarter >= "2008q3")
xi: xtreg deposit_rate ///
    fed_rate CU_dummy c.fed_rate#c.CU_dummy ///
    c.fed_rate#c.CU_dummy#post_crisis ///
    logassets institutiondeposits branchdeposits ///
    i.quarter, ///
    fe cluster(cert_nbr)
	
********************** Data cleaning and descriptive statistics **********************
* Summary statistics
summarize deposit_rate fed_rate asset_sz institutiondeposits branchdeposits

* Summary by institution type
tabstat deposit_rate, by(CU_dummy) stats(mean sd min max n)

* Check for missing values
misstable summarize deposit_rate fed_rate asset_sz institutiondeposits branchdeposits

* Create a time series plot of average rates by institution type
preserve
collapse (mean) deposit_rate, by(quarter CU_dummy)
twoway (line deposit_rate quarter if CU_dummy==1) ///
       (line deposit_rate quarter if CU_dummy==0), ///
       title("MM2.5K Average Rates Over Time") ///
       legend(label(1 "Credit Unions") label(2 "Banks")) ///
       ytitle("Deposit Rate") xtitle("Quarter")
graph export "/Volumes/WD Drive +/CreditUnion/1018/mm25k_rates_over_time.png", replace
restore


********************** Regression Result **********************
* Generate log of asset size
gen logassets = log(asset_sz)

* Set up panel data structure
xtset cert_nbr quarter

* Run the base panel regression
xtreg deposit_rate ///
    fed_rate CU_dummy c.fed_rate#c.CU_dummy ///
    logassets institutiondeposits branchdeposits ///
    i.quarter, ///
    fe cluster(cert_nbr)
*** beta_3 == .0548631, F(82, 4289)= 1615.30, Prob > F = 0.0000

* without contral variables
xtreg deposit_rate ///
    fed_rate CU_dummy c.fed_rate#c.CU_dummy ///
    i.quarter, ///
    fe cluster(cert_nbr)	
	
* Store results
estimates store mm25k_model

* Test interaction term
test c.fed_rate#c.CU_dummy ///F(  1,  4289) =   26.04

* Calculate marginal effects
margins, dydx(fed_rate) at(CU_dummy=(0 1))

* Create output table
outreg2 using "/Volumes/WD Drive +/CreditUnion/1018/mm25k_results.doc", replace ctitle(MM2.5K)


****** Consider adding time interactions ****
* Generate interaction between quarter dummies and CU_dummy
xi: xtreg deposit_rate ///
    fed_rate CU_dummy c.fed_rate#c.CU_dummy ///
    logassets institutiondeposits branchdeposits ///
    i.quarter*CU_dummy, ///
    fe cluster(cert_nbr)


************ Q1 *****************************
xtreg deposit_rate fed_rate CU_dummy c.fed_rate#c.CU_dummy logassets institutiondeposits branchdeposits i.quarter_num, fe cluster(cert_nbr)

************ Q2 *****************************


************ Q3 *****************************



******* 2. SAV2.5K ************


use "/Volumes/WD Drive +/CreditUnion/1018/MM2.5K_fed_instdetails.dta", clear

* Generate CU_dummy (1 for Credit Unions, 0 for Banks)
gen CU_dummy = (inst_typ == "CU")

* Create a new numeric quarter variable
rename quarter quarter_str
gen quarter = quarterly(quarter_str, "YQ")
format quarter %tq

* Check for outliers
* Look for extreme values in deposit rates
sum deposit_rate, detail

* Consider winsorizing if there are extreme outliers
winsor2 deposit_rate, cuts(1 99) replace

* Generate pre and post financial crisis dummy
gen post_crisis = (quarter >= "2008q3")
xi: xtreg deposit_rate ///
    fed_rate CU_dummy c.fed_rate#c.CU_dummy ///
    c.fed_rate#c.CU_dummy#post_crisis ///
    logassets institutiondeposits branchdeposits ///
    i.quarter, ///
    fe cluster(cert_nbr)
	
********************** Data cleaning and descriptive statistics **********************
* Summary statistics
summarize deposit_rate fed_rate asset_sz institutiondeposits branchdeposits

* Summary by institution type
tabstat deposit_rate, by(CU_dummy) stats(mean sd min max n)

* Check for missing values
misstable summarize deposit_rate fed_rate asset_sz institutiondeposits branchdeposits

* Create a time series plot of average rates by institution type
preserve
collapse (mean) deposit_rate, by(quarter CU_dummy)
twoway (line deposit_rate quarter if CU_dummy==1) ///
       (line deposit_rate quarter if CU_dummy==0), ///
       title("MM2.5K Average Rates Over Time") ///
       legend(label(1 "Credit Unions") label(2 "Banks")) ///
       ytitle("Deposit Rate") xtitle("Quarter")
graph export "/Volumes/WD Drive +/CreditUnion/1018/mm25k_rates_over_time.png", replace
restore


********************** Regression Result **********************
* Generate log of asset size
gen logassets = log(asset_sz)

* Set up panel data structure
xtset cert_nbr quarter

* Run the base panel regression
xtreg deposit_rate ///
    fed_rate CU_dummy c.fed_rate#c.CU_dummy ///
    logassets institutiondeposits branchdeposits ///
    i.quarter, ///
    fe cluster(cert_nbr)
	
* Store results
estimates store mm25k_model

* Test interaction term
test c.fed_rate#c.CU_dummy ///F(  1,  4289) =   26.04

* Calculate marginal effects
margins, dydx(fed_rate) at(CU_dummy=(0 1))

* Create output table
outreg2 using "/Volumes/WD Drive +/CreditUnion/1018/mm25k_results.doc", replace ctitle(MM2.5K)


****** Consider adding time interactions ****
* Generate interaction between quarter dummies and CU_dummy
xi: xtreg deposit_rate ///
    fed_rate CU_dummy c.fed_rate#c.CU_dummy ///
    logassets institutiondeposits branchdeposits ///
    i.quarter*CU_dummy, ///
    fe cluster(cert_nbr)





******* 3. INTCK2.5K ************


use "/Volumes/WD Drive +/CreditUnion/1018/MM2.5K_fed_instdetails.dta", clear

* Generate CU_dummy (1 for Credit Unions, 0 for Banks)
gen CU_dummy = (inst_typ == "CU")

* Create a new numeric quarter variable
rename quarter quarter_str
gen quarter = quarterly(quarter_str, "YQ")
format quarter %tq

* Check for outliers
* Look for extreme values in deposit rates
sum deposit_rate, detail

* Consider winsorizing if there are extreme outliers
winsor2 deposit_rate, cuts(1 99) replace

* Generate pre and post financial crisis dummy
gen post_crisis = (quarter >= "2008q3")
xi: xtreg deposit_rate ///
    fed_rate CU_dummy c.fed_rate#c.CU_dummy ///
    c.fed_rate#c.CU_dummy#post_crisis ///
    logassets institutiondeposits branchdeposits ///
    i.quarter, ///
    fe cluster(cert_nbr)
	
********************** Data cleaning and descriptive statistics **********************
* Summary statistics
summarize deposit_rate fed_rate asset_sz institutiondeposits branchdeposits

* Summary by institution type
tabstat deposit_rate, by(CU_dummy) stats(mean sd min max n)

* Check for missing values
misstable summarize deposit_rate fed_rate asset_sz institutiondeposits branchdeposits

* Create a time series plot of average rates by institution type
preserve
collapse (mean) deposit_rate, by(quarter CU_dummy)
twoway (line deposit_rate quarter if CU_dummy==1) ///
       (line deposit_rate quarter if CU_dummy==0), ///
       title("MM2.5K Average Rates Over Time") ///
       legend(label(1 "Credit Unions") label(2 "Banks")) ///
       ytitle("Deposit Rate") xtitle("Quarter")
graph export "/Volumes/WD Drive +/CreditUnion/1018/mm25k_rates_over_time.png", replace
restore


********************** Regression Result **********************
* Generate log of asset size
gen logassets = log(asset_sz)

* Set up panel data structure
xtset cert_nbr quarter

* Run the base panel regression
xtreg deposit_rate ///
    fed_rate CU_dummy c.fed_rate#c.CU_dummy ///
    logassets institutiondeposits branchdeposits ///
    i.quarter, ///
    fe cluster(cert_nbr)
	
* Store results
estimates store mm25k_model

* Test interaction term
test c.fed_rate#c.CU_dummy ///F(  1,  4289) =   26.04

* Calculate marginal effects
margins, dydx(fed_rate) at(CU_dummy=(0 1))

* Create output table
outreg2 using "/Volumes/WD Drive +/CreditUnion/1018/mm25k_results.doc", replace ctitle(MM2.5K)


****** Consider adding time interactions ****
* Generate interaction between quarter dummies and CU_dummy
xi: xtreg deposit_rate ///
    fed_rate CU_dummy c.fed_rate#c.CU_dummy ///
    logassets institutiondeposits branchdeposits ///
    i.quarter*CU_dummy, ///
    fe cluster(cert_nbr)




******* 4. 03MCD10K ************


use "/Volumes/WD Drive +/CreditUnion/1018/MM2.5K_fed_instdetails.dta", clear

* Generate CU_dummy (1 for Credit Unions, 0 for Banks)
gen CU_dummy = (inst_typ == "CU")

* Create a new numeric quarter variable
rename quarter quarter_str
gen quarter = quarterly(quarter_str, "YQ")
format quarter %tq

* Check for outliers
* Look for extreme values in deposit rates
sum deposit_rate, detail

* Consider winsorizing if there are extreme outliers
winsor2 deposit_rate, cuts(1 99) replace

* Generate pre and post financial crisis dummy
gen post_crisis = (quarter >= "2008q3")
xi: xtreg deposit_rate ///
    fed_rate CU_dummy c.fed_rate#c.CU_dummy ///
    c.fed_rate#c.CU_dummy#post_crisis ///
    logassets institutiondeposits branchdeposits ///
    i.quarter, ///
    fe cluster(cert_nbr)
	
********************** Data cleaning and descriptive statistics **********************
* Summary statistics
summarize deposit_rate fed_rate asset_sz institutiondeposits branchdeposits

* Summary by institution type
tabstat deposit_rate, by(CU_dummy) stats(mean sd min max n)

* Check for missing values
misstable summarize deposit_rate fed_rate asset_sz institutiondeposits branchdeposits

* Create a time series plot of average rates by institution type
preserve
collapse (mean) deposit_rate, by(quarter CU_dummy)
twoway (line deposit_rate quarter if CU_dummy==1) ///
       (line deposit_rate quarter if CU_dummy==0), ///
       title("MM2.5K Average Rates Over Time") ///
       legend(label(1 "Credit Unions") label(2 "Banks")) ///
       ytitle("Deposit Rate") xtitle("Quarter")
graph export "/Volumes/WD Drive +/CreditUnion/1018/mm25k_rates_over_time.png", replace
restore


********************** Regression Result **********************
* Generate log of asset size
gen logassets = log(asset_sz)

* Set up panel data structure
xtset cert_nbr quarter

* Run the base panel regression
xtreg deposit_rate ///
    fed_rate CU_dummy c.fed_rate#c.CU_dummy ///
    logassets institutiondeposits branchdeposits ///
    i.quarter, ///
    fe cluster(cert_nbr)
	
* Store results
estimates store mm25k_model

* Test interaction term
test c.fed_rate#c.CU_dummy ///F(  1,  4289) =   26.04

* Calculate marginal effects
margins, dydx(fed_rate) at(CU_dummy=(0 1))

* Create output table
outreg2 using "/Volumes/WD Drive +/CreditUnion/1018/mm25k_results.doc", replace ctitle(MM2.5K)


****** Consider adding time interactions ****
* Generate interaction between quarter dummies and CU_dummy
xi: xtreg deposit_rate ///
    fed_rate CU_dummy c.fed_rate#c.CU_dummy ///
    logassets institutiondeposits branchdeposits ///
    i.quarter*CU_dummy, ///
    fe cluster(cert_nbr)








******* 5. 12MCD10K ************




use "/Volumes/WD Drive +/CreditUnion/1018/MM2.5K_fed_instdetails.dta", clear

* Generate CU_dummy (1 for Credit Unions, 0 for Banks)
gen CU_dummy = (inst_typ == "CU")

* Create a new numeric quarter variable
rename quarter quarter_str
gen quarter = quarterly(quarter_str, "YQ")
format quarter %tq

* Check for outliers
* Look for extreme values in deposit rates
sum deposit_rate, detail

* Consider winsorizing if there are extreme outliers
winsor2 deposit_rate, cuts(1 99) replace

* Generate pre and post financial crisis dummy
gen post_crisis = (quarter >= "2008q3")
xi: xtreg deposit_rate ///
    fed_rate CU_dummy c.fed_rate#c.CU_dummy ///
    c.fed_rate#c.CU_dummy#post_crisis ///
    logassets institutiondeposits branchdeposits ///
    i.quarter, ///
    fe cluster(cert_nbr)
	
********************** Data cleaning and descriptive statistics **********************
* Summary statistics
summarize deposit_rate fed_rate asset_sz institutiondeposits branchdeposits

* Summary by institution type
tabstat deposit_rate, by(CU_dummy) stats(mean sd min max n)

* Check for missing values
misstable summarize deposit_rate fed_rate asset_sz institutiondeposits branchdeposits

* Create a time series plot of average rates by institution type
preserve
collapse (mean) deposit_rate, by(quarter CU_dummy)
twoway (line deposit_rate quarter if CU_dummy==1) ///
       (line deposit_rate quarter if CU_dummy==0), ///
       title("MM2.5K Average Rates Over Time") ///
       legend(label(1 "Credit Unions") label(2 "Banks")) ///
       ytitle("Deposit Rate") xtitle("Quarter")
graph export "/Volumes/WD Drive +/CreditUnion/1018/mm25k_rates_over_time.png", replace
restore


********************** Regression Result **********************
* Generate log of asset size
gen logassets = log(asset_sz)

* Set up panel data structure
xtset cert_nbr quarter

* Run the base panel regression
xtreg deposit_rate ///
    fed_rate CU_dummy c.fed_rate#c.CU_dummy ///
    logassets institutiondeposits branchdeposits ///
    i.quarter, ///
    fe cluster(cert_nbr)
	
* Store results
estimates store mm25k_model

* Test interaction term
test c.fed_rate#c.CU_dummy ///F(  1,  4289) =   26.04

* Calculate marginal effects
margins, dydx(fed_rate) at(CU_dummy=(0 1))

* Create output table
outreg2 using "/Volumes/WD Drive +/CreditUnion/1018/mm25k_results.doc", replace ctitle(MM2.5K)


****** Consider adding time interactions ****
* Generate interaction between quarter dummies and CU_dummy
xi: xtreg deposit_rate ///
    fed_rate CU_dummy c.fed_rate#c.CU_dummy ///
    logassets institutiondeposits branchdeposits ///
    i.quarter*CU_dummy, ///
    fe cluster(cert_nbr)









******* 6. 120MoCD ************
preserve
rename id cert_nbr
rename quarter quarter1
rename quarter_str quarter

merge m:1 cert_nbr quarter using "/Volumes/aae/users/zchen2365/1018/120MoCD_fed_instdetails.dta"

br cert_nbr CU_dummy period cu_number instme total_assets amt_total_loans members marketShare net_worth coreDeposits fee_income delqRatio netChargeOffRatio assetGrowth loanGrowth depositGrowth roa mortgages firstMortgages secondMortgages delqMortgages branches total_liabilities total_capital member_growth capital_adequacy quarter1 quarter deposit_rate apy asset_sz institutiondeposits branchdeposits productdescription producttype inst_nm inst_typ uninumbr rssd_id est_dt state fed_rate fed_rate_decrease fed_rate_change _merge if _merge == 3

keep if _merge == 3
drop _merge

restore

******* 1. MM2.5K ************





































********************************************************************************
*************** Part 1: Process RateWatch Data ***************
********************************************************************************














































********************************************************************************
*************** Part 1: Process RateWatch Data ***************
********************************************************************************

















































