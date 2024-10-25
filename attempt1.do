******* Response to Fed's Rate Cut: Credit Union vs. Bank **********
clear
cls

**** Merge Data
**** 1. RateWatch

* Set working directory to RateWatch folder
cd "/Volumes/WD Drive +/CreditUnion/Data/ratewatch"

*** 首先处理2001-2005年的数据（批量处理） ***
tempfile period1_data

* 从2001年开始
import delimited using "depositRateData_clean_2001.txt", delimiter("|") clear

* 清理数据
gen date_temp = datesurveyed
replace date_temp = substr(date_temp, 1, 10) if strpos(date_temp, "T")>0
gen date = date(date_temp, "YMD")
format date %td
gen quarter = qofd(date)
format quarter %tq
destring rate apy termlength, replace force
keep if inlist(producttype, "CD", "SAV", "MM", "INTCK")
gen product_category = ""
replace product_category = "short_term_cd" if producttype == "CD" & termlength <= 60
replace product_category = "long_term_cd" if producttype == "CD" & termlength > 60
replace product_category = producttype if producttype != "CD"

save `period1_data', replace

* 处理2002-2005
forvalues year = 2002/2005 {
    display "Processing year `year'"
    import delimited using "depositRateData_clean_`year'.txt", delimiter("|") clear
    
    * 清理数据
    gen date_temp = datesurveyed
    replace date_temp = substr(date_temp, 1, 10) if strpos(date_temp, "T")>0
    gen date = date(date_temp, "YMD")
    format date %td
    gen quarter = qofd(date)
    format quarter %tq
    destring rate apy termlength, replace force
    keep if inlist(producttype, "CD", "SAV", "MM", "INTCK")
    gen product_category = ""
    replace product_category = "short_term_cd" if producttype == "CD" & termlength <= 60
    replace product_category = "long_term_cd" if producttype == "CD" & termlength > 60
    replace product_category = producttype if producttype != "CD"
    
    append using `period1_data'
    save `period1_data', replace
}

* 保存2001-2005年的数据到移动硬盘
save "/Volumes/WD Drive +/CreditUnion/Data/ratewatch/processed/ratewatch_2001_2005.dta", replace
clear all

*** 处理2006-2010年的数据（批量处理） ***
tempfile period2_data

* 从2006年开始
import delimited using "depositRateData_clean_2006.txt", delimiter("|") clear

* 清理数据
gen date_temp = datesurveyed
replace date_temp = substr(date_temp, 1, 10) if strpos(date_temp, "T")>0
gen date = date(date_temp, "YMD")
format date %td
gen quarter = qofd(date)
format quarter %tq
destring rate apy termlength, replace force
keep if inlist(producttype, "CD", "SAV", "MM", "INTCK")
gen product_category = ""
replace product_category = "short_term_cd" if producttype == "CD" & termlength <= 60
replace product_category = "long_term_cd" if producttype == "CD" & termlength > 60
replace product_category = producttype if producttype != "CD"
save `period2_data', replace

forvalues year = 2007/2010 {
    display "Processing year `year'"
    import delimited using "depositRateData_clean_`year'.txt", delimiter("|") clear
    
    * 清理数据
    gen date_temp = datesurveyed
    replace date_temp = substr(date_temp, 1, 10) if strpos(date_temp, "T")>0
    gen date = date(date_temp, "YMD")
    format date %td
    gen quarter = qofd(date)
    format quarter %tq
    destring rate apy termlength, replace force
    keep if inlist(producttype, "CD", "SAV", "MM", "INTCK")
    gen product_category = ""
    replace product_category = "short_term_cd" if producttype == "CD" & termlength <= 60
    replace product_category = "long_term_cd" if producttype == "CD" & termlength > 60
    replace product_category = producttype if producttype != "CD"
    
    append using `period2_data'
    save `period2_data', replace
}

* 保存2006-2010年的数据到移动硬盘
save "/Volumes/WD Drive +/CreditUnion/Data/ratewatch/processed/ratewatch_2006_2010.dta", replace
clear all

*** 处理2011-2016年的数据（逐年处理） ***
foreach year of numlist 2011/2016 {
    clear all
    display "Processing year `year'"
    
    * 导入数据
    import delimited using "depositRateData_clean_`year'.txt", delimiter("|") clear
    
    * 清理数据
    gen date_temp = datesurveyed
    replace date_temp = substr(date_temp, 1, 10) if strpos(date_temp, "T")>0
    gen date = date(date_temp, "YMD")
    format date %td
    gen quarter = qofd(date)
    format quarter %tq
    destring rate apy termlength, replace force
    keep if inlist(producttype, "CD", "SAV", "MM", "INTCK")
    gen product_category = ""
    replace product_category = "short_term_cd" if producttype == "CD" & termlength <= 60
    replace product_category = "long_term_cd" if producttype == "CD" & termlength > 60
    replace product_category = producttype if producttype != "CD"
    
    * 计算季度平均值
    collapse (mean) rate apy (count) n_obs=rate, ///
        by(accountnumber product_category quarter)
    
    * 保存到移动硬盘
    save "/Volumes/WD Drive +/CreditUnion/Data/ratewatch/processed/ratewatch_`year'.dta", replace
    clear all
}

*** 处理2017-2020年的数据（批量处理） ***
clear all
tempfile period4_data

* 从2017年开始
display "Processing year 2017"
import delimited using "depositRateData_clean_2017.txt", delimiter("|") clear

* 清理数据
gen date_temp = datesurveyed
replace date_temp = substr(date_temp, 1, 10) if strpos(date_temp, "T")>0
gen date = date(date_temp, "YMD")
format date %td
gen quarter = qofd(date)
format quarter %tq
destring rate apy termlength, replace force
keep if inlist(producttype, "CD", "SAV", "MM", "INTCK")
gen product_category = ""
replace product_category = "short_term_cd" if producttype == "CD" & termlength <= 60
replace product_category = "long_term_cd" if producttype == "CD" & termlength > 60
replace product_category = producttype if producttype != "CD"

* 保存2017年数据作为起始点
save `period4_data', replace

* 处理2018-2020年的数据
forvalues year = 2018/2020 {
    display "Processing year `year'"
    clear
    import delimited using "depositRateData_clean_`year'.txt", delimiter("|") clear
    
    * 清理数据
    gen date_temp = datesurveyed
    replace date_temp = substr(date_temp, 1, 10) if strpos(date_temp, "T")>0
    gen date = date(date_temp, "YMD")
    format date %td
    gen quarter = qofd(date)
    format quarter %tq
    destring rate apy termlength, replace force
    keep if inlist(producttype, "CD", "SAV", "MM", "INTCK")
    gen product_category = ""
    replace product_category = "short_term_cd" if producttype == "CD" & termlength <= 60
    replace product_category = "long_term_cd" if producttype == "CD" & termlength > 60
    replace product_category = producttype if producttype != "CD"
    
    * 追加数据
    append using `period4_data'
    save `period4_data', replace
}

* 保存2017-2020年的数据到移动硬盘
save "/Volumes/WD Drive +/CreditUnion/Data/ratewatch/processed/ratewatch_2017_2020.dta", replace

*** 最后合并所有数据 ***
clear all
use "/Volumes/WD Drive +/CreditUnion/Data/ratewatch/processed/ratewatch_2001_2005.dta"
append using "/Volumes/WD Drive +/CreditUnion/Data/ratewatch/processed/ratewatch_2006_2010.dta"

foreach year of numlist 2011/2016 {
    append using "/Volumes/WD Drive +/CreditUnion/Data/ratewatch/processed/ratewatch_`year'.dta"
}

append using "/Volumes/WD Drive +/CreditUnion/Data/ratewatch/processed/ratewatch_2017_2020.dta"

* 保存最终合并的数据集
save "/Volumes/WD Drive +/CreditUnion/Data/ratewatch/processed/ratewatch_final.dta", replace

* 创建基础统计数据
tabstat rate, by(product_category) stats(n mean sd min p25 p50 p75 max)
