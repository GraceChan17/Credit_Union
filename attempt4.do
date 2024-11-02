
********************************************************************************
* Analysis of Response to Fed's Rate Cut: Credit Union vs Bank
* Data: RateWatch deposit rates and Federal Funds Rate (2001-2020)
********************************************************************************

*************** Part 1: Process RateWatch Data ***************
clear all
set more off

* Directory setup
global data_dir "/Volumes/WD Drive +/CreditUnion/Data"
cd "$data_dir/ratewatch"

* Process data year by year
forvalues year = 2001/2020 {
    display "Processing year `year'"
    
    * Import and clean data
    import delimited using "depositRateData_clean_`year'.txt", delimiter("|") clear
    
    keep accountnumber producttype productdescription termlength rate apy cmt datesurveyed
    
    * Date formatting
    gen date = date(substr(datesurveyed, 1, 10), "YMD") if strpos(datesurveyed, "T") > 0
    format date %td
    
    * Generate quarter
    gen quarter = qofd(date)
    format quarter %tq
    
    * Filter products and create categories
    keep if inlist(producttype, "CD", "SAV", "MM", "INTCK")
    
    gen product_category = cond(producttype == "CD", ///
        cond(termlength <= 60, "short_term_cd", "long_term_cd"), ///
        producttype)
    
    * Aggregate quarterly data
    collapse (mean) rate apy (count) n_obs=rate, ///
        by(accountnumber producttype productdescription product_category cmt quarter)
    
    * Save processed data
    save "processed/ratewatch_`year'.dta", replace
	clear all
}

* Merge all years
use "processed/ratewatch_2001.dta", clear
forvalues year = 2002/2020 {
    append using "processed/ratewatch_`year'.dta"
}
save "processed/ratewatch_final.dta", replace

*************** Part 2: Process Federal Funds Rate Data ***************
clear all
import delimited using "$data_dir/Fed/Federal_Funds_Effective_Rate_2001_2020.csv", clear

* Generate quarterly data
gen date_temp = date(date, "YMD")
gen quarter = qofd(date_temp)
format quarter %tq

* Clean and aggregate Fed rate data
rename fedfunds fed_rate
destring fed_rate, replace
collapse (mean) fed_rate, by(quarter)

* Generate rate change indicators
sort quarter
gen fed_rate_decrease = (fed_rate < fed_rate[_n-1]) //decreased == 1 or increased == 0
gen fed_rate_change = fed_rate - fed_rate[_n-1]

save "$data_dir/Fed/fed_funds_quarterly.dta", replace

*************** Part 3: Merge and Analyze Data ***************
use "$data_dir/ratewatch/processed/ratewatch_final.dta", clear

* Check exact duplicates
duplicates report quarter accountnumber product_category productdescription cmt

* List examples of duplicates if found
duplicates example quarter accountnumber product_category productdescription cmt

* Calculate mean for rate and apy when duplicates exist
collapse (mean) rate apy (count) n_obs=rate, ///
    by(quarter accountnumber product_category productdescription cmt)

* Verify no duplicates remain
duplicates report quarter accountnumber product_category productdescription cmt

* Tag duplicate observations
duplicates tag quarter accountnumber product_category productdescription cmt, gen(dup)

* Double check: See which observations are duplicates
browse if dup > 0

* Remove duplicates
collapse (mean) rate apy (count) n_obs=rate, ///
    by(quarter accountnumber product_category productdescription cmt)
****************************************************************************
****************************************************************************

* Merge with Fed data
merge m:1 quarter using "$data_dir/Fed/fed_funds_quarterly.dta"
keep if _merge == 3
drop _merge

* Generate changes in deposit rates and federal funds rate
sort accountnumber product_category quarter
by accountnumber product_category: gen deposit_rate_change = rate - rate[_n-1]

* Save combined data: deposit rate + federal funds effective rate
save "$data_dir/Fed/fed_deposit.dta", replace


*************** Part 4: Analysis ***************
* First generate descriptive statistics for deposit rate by product category
tabstat rate, by(product_category) ///
    stat(n mean sd min p25 p50 p75 max) columns(statistics) // results stored in "descriptive statistics for deposit rate group by product category.csv"

* Create frame for storing results
frame create results str32 product_type quarter avg_deposit_rate avg_deposit_change fed_rate_change pass_through n_obs

* First create a frame to store results
frame create results
frame change results
clear
set obs 0
gen product_type = ""
gen quarter = .
gen avg_deposit_rate = .
gen avg_deposit_change = .
gen fed_rate_change = .
gen pass_through = .
gen n_obs = .
frame change default

* Analysis by product type
local product_types INTCK MM SAV short_term_cd long_term_cd

foreach type in `product_types' {
    display _n _n "Analysis for `type'"
    display "------------------------"
    
    * 1. Basic statistics during Fed rate decreases
    display "Basic statistics during Fed rate decreases:"
    tabstat rate deposit_rate_change if product_category == "`type'" & fed_rate_decrease == 1, ///
        stats(n mean sd min max) columns(statistics)
    
    * 2. Calculate pass-through effect
    preserve
        keep if product_category == "`type'" & fed_rate_decrease == 1
        
        collapse (mean) avg_deposit_rate=rate ///
            (mean) avg_deposit_change=deposit_rate_change ///
            (mean) fed_rate_change=fed_rate_change ///
            (count) n_obs=rate, ///
            by(quarter)
        
        gen pass_through = avg_deposit_change/fed_rate_change
        gen product_type = "`type'"
        
        * Display detailed pass-through statistics
        display "Pass-through effect statistics:"
        summarize pass_through, detail
        
        * Save to results frame
        tempfile temp_results
        save `temp_results'
        frame change results
        append using `temp_results'
        frame change default
    restore
} /// results stores in "detail table of pass-through effect for each product type.xlsx"

* Switch to results frame for analysis
frame change results

* Create summary table of pass-through effects
tabstat pass_through, by(product_type) ///
    stat(n mean sd min p25 p50 p75 max) ///
    columns(statistics) /// results stores in "summary table of pass-through effects group by product type.csv"

* Create visualization
graph box pass_through, over(product_type) ///
    title("Pass-through Effects by Product Type") ///
    subtitle("During Fed Rate Decrease Periods") ///
    note("Pass-through = Change in Deposit Rate / Change in Fed Rate") ///
    ylabel(,angle(horizontal))
graph export "pass_through_box.png", replace

* Calculate cross-sectional statistics
tabstat pass_through, by(product_type) ///
    statistics(mean sd count) ///
    columns(statistics) ///
    format(%9.3f) /// results stores in "cross-sectional statistics.csv"

* Switch back to main data
frame change default


*************** Part 5: Extract characteristics data ***************
* Import and process institution details
clear
cd "$data_dir/combined_dataset"

* Import the institution details data with delimiter
import delimited using "$data_dir/ratewatch/Original_ratewatch_Data/Deposit_InstitutionDetails.txt", delimiter("|") clear

* Rename acct_nbr to match fed_deposit.dta
rename acct_nbr accountnumber

* Keep relevant variables for control
keep accountnumber inst_nm inst_typ cert_nbr asset_sz branches ///
    institutiondeposits est_dt state

* Clean and format variables
* Convert asset size to billions for easier interpretation
gen assets_billions = asset_sz/1000000000
label variable assets_billions "Total Assets (Billions)"

* Generate institution type dummy (1 for CU, 0 for banks)
gen credit_union = (inst_typ == "CU")
label variable credit_union "Credit Union Indicator"

* Calculate log of assets
gen ln_assets = ln(assets_billions)
label variable ln_assets "Log of Total Assets"

* Generate age of institution
gen est_date = date(est_dt, "YMD")
format est_date %td
gen age = (date("2020-12-31", "YMD") - est_date)/365.25
label variable age "Institution Age (Years)"

* Clean branch information
replace branches = 0 if branches == .
label variable branches "Number of Branches"

* Save processed institution details
save "inst_details_processed.dta", replace

* Merge with fed_deposit data
use "fed_deposit.dta", clear
merge m:1 accountnumber using "inst_details_processed.dta"

* Check merge results
tab _merge
tab inst_typ if _merge == 3

* Keep only matched observations
keep if _merge == 3
drop _merge

* Generate additional control variables
gen ln_branches = ln(branches + 1)
label variable ln_branches "Log of Branches (Plus 1)"

* Save final merged dataset
save "fed_deposit_with_controls.dta", replace




use "fed_deposit_with_controls.dta", clear
* Basic analysis of institutional characteristics
tabstat assets_billions branches age, by(credit_union) ///
    statistics(n mean sd min p25 p50 p75 max) columns(statistics)

* Examine rate setting by institution type
tabstat rate if fed_rate_decrease == 1, by(credit_union) ///
    statistics(n mean sd min p25 p50 p75 max) columns(statistics)

* Create visualizations
* Box plot of rates by institution type
graph box rate, over(credit_union) ///
    title("Deposit Rates by Institution Type") ///
    subtitle("During Fed Rate Decrease Periods") ///
    note("0 = Banks, 1 = Credit Unions") ///
    ylabel(,angle(horizontal))
graph export "rates_by_inst_type.png", replace

* Scatter plot of rates vs size
twoway (scatter rate assets_billions if credit_union == 0, mcolor(blue) msymbol(circle_hollow)) ///
       (scatter rate assets_billions if credit_union == 1 mcolor(red) msymbol(circle_hollow)), ///
    title("Deposit Rates vs Institution Size") ///
    subtitle("By Institution Type") ///
    xtitle("Assets (Billions)") ytitle("Deposit Rate") ///
    legend(order(1 "Banks" 2 "Credit Unions"))
graph export "rates_vs_size.png", replace







