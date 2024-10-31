



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
gen fed_rate_decrease = (fed_rate < fed_rate[_n-1]) //decresed == 1 or increased == 0
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

*************** Part 4: Analysis ***************
* Summary statistics by product type

* Define product types
local product_types INTCK MM SAV short_term_cd long_term_cd

foreach type in `product_types' {
    display _n "Analysis for `type'"
    display "------------------------"
    
    * Basic statistics during Fed rate decreases
    tabstat rate deposit_rate_change if product_category == "`type'" & fed_rate_decrease == 1, ///
        stats(n mean sd min max) columns(statistics)
    
    * Calculate pass-through effect
    preserve
        keep if product_category == "`type'" & fed_rate_decrease == 1
        collapse (mean) avg_deposit_rate=rate ///
            (mean) avg_deposit_change=deposit_rate_change ///
            (mean) fed_rate_change=fed_rate_change, ///
            by(quarter)
        gen pass_through = avg_deposit_change/fed_rate_change
        summarize pass_through
    restore
}

* Create summary statistics table
preserve
    collapse (mean) mean_deposit_rate=rate ///
            (mean) mean_deposit_change=deposit_rate_change ///
            (count) n_obs=rate ///
            (sd) sd_deposit_change=deposit_rate_change ///
        if fed_rate_decrease == 1, by(product_category)
    
    * Save results    
    export delimited using "rate_adjustment_summary.csv", replace
restore

* Visualize deposit rate adjustments
graph box deposit_rate_change if fed_rate_decrease == 1, over(product_category) ///
    title("Deposit Rate Adjustments During Fed Funds Rate Decreases") ///
    subtitle("By Product Type") ///
    note("Period: 2001-2020")
graph export "rate_adjustments_box.png", replace

* Time series comparison
preserve
    collapse (mean) avg_deposit_rate=rate fed_rate=fed_rate, by(quarter product_category)

    foreach type of local product_types {
        twoway (line avg_deposit_rate quarter if product_category == "`type'") ///
               (line fed_rate quarter), ///
            title("`type' Deposit Rates vs Fed Funds Rate") ///
            legend(label(1 "`type' Deposit Rate") label(2 "Fed Funds Rate"))
        graph export "rate_series_`type'.png", replace
    }
restore



















































