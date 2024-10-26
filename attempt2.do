******* Response to Fed's Rate Cut: Credit Union vs. Bank **********
clear
cls


******************************** 1. RateWatch ********************************
********** Merge Data *********

* Set working directory to RateWatch folder
cd "/Volumes/WD Drive +/CreditUnion/Data/ratewatch"

*** Start with 2001 ***
display "Processing 2001"
import delimited using "depositRateData_clean_2001.txt", delimiter("|") clear

* Keep necessary variables
keep accountnumber producttype productdescription termlength rate apy cmt datesurveyed

* Clean data format
gen date_temp = datesurveyed
replace date_temp = substr(date_temp, 1, 10) if strpos(date_temp, "T")>0
gen date = date(date_temp, "YMD")
format date %td

* Generate quater
gen quarter = qofd(date)
format quarter %tq

* Keep only relevant products
keep if inlist(producttype, "CD", "SAV", "MM", "INTCK")

* Create product categories
gen product_category = ""
replace product_category = "short_term_cd" if producttype == "CD" & termlength <= 60
replace product_category = "long_term_cd" if producttype == "CD" & termlength > 60
replace product_category = producttype if producttype != "CD"

* Calculate quarterly average rates by institution and product
collapse (mean) rate apy (count) n_obs=rate, ///
    by(accountnumber producttype productdescription product_category cmt quarter)

* Save 2001 data
save "/Volumes/WD Drive +/CreditUnion/Data/ratewatch/processed/ratewatch_2001.dta", replace
clear all

*** Process 2002-2020 ***
foreach year of numlist 2002/2020 {
    clear all
    display "Processing year `year'"
    
    * Import data
    import delimited using "depositRateData_clean_`year'.txt", delimiter("|") clear
    
    * Keep necessary variables
    keep accountnumber producttype productdescription termlength rate apy cmt datesurveyed
    
    * Clean data format
    gen date_temp = datesurveyed
    replace date_temp = substr(date_temp, 1, 10) if strpos(date_temp, "T")>0
    gen date = date(date_temp, "YMD")
    format date %td
    
    * Generate quater
    gen quarter = qofd(date)
    format quarter %tq
    
    * Keep only relevant products
    keep if inlist(producttype, "CD", "SAV", "MM", "INTCK")
    
    * Create product categories
    gen product_category = ""
    replace product_category = "short_term_cd" if producttype == "CD" & termlength <= 60
    replace product_category = "long_term_cd" if producttype == "CD" & termlength > 60
    replace product_category = producttype if producttype != "CD"
    
    * Calculate quarterly average rates by institution and product
    collapse (mean) rate apy (count) n_obs=rate, ///
	by(accountnumber producttype productdescription product_category cmt quarter)

    
    * Save yearly data
    save "/Volumes/WD Drive +/CreditUnion/Data/ratewatch/processed/ratewatch_`year'.dta", replace
    clear all
}


* Merge final dataset
use "/Volumes/WD Drive +/CreditUnion/Data/ratewatch/processed/ratewatch_2001.dta"

foreach year of numlist 2002/2020 {
    append using "/Volumes/WD Drive +/CreditUnion/Data/ratewatch/processed/ratewatch_`year'.dta"
}

* Save final dataset
save "/Volumes/WD Drive +/CreditUnion/Data/ratewatch/processed/ratewatch_final.dta", replace

* Create summary statistics
tabstat rate, by(product_category) stats(n mean sd min p25 p50 p75 max)



********** Initial analeysis *********
****** 1. descritive statistic ********
* 按产品类型统计
tabstat rate apy, by(product_category) stat(n mean sd min p25 p50 p75 max)

* 按年份查看产品分布
tab product_category year, row

* 检查样本机构数量随时间的变化
bysort quarter: distinct accountnumber














