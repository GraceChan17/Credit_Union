clear
cls

cd "/Users/chenzhiying/Downloads/results"

* Import the Deposit Institution Detail data
import delimited using "/Volumes/aae/groups/Data/zchen2365/ratewatch/Deposit_InstitutionDetails.txt", delimiter("|") clear

* Keep CU & BK
keep if inst_typ == "BK" | inst_typ == "CU"

* Clean institution names in Deposit Detail data
* Convert to uppercase and remove common suffixes and special characters
gen inst_name_clean = upper(inst_nm)
replace inst_name_clean = subinstr(inst_name_clean, ".", "", .)
replace inst_name_clean = subinstr(inst_name_clean, ",", "", .)
replace inst_name_clean = subinstr(inst_name_clean, "INC", "", .)
replace inst_name_clean = subinstr(inst_name_clean, "INCORPORATED", "", .)
replace inst_name_clean = subinstr(inst_name_clean, "CORP", "", .)
replace inst_name_clean = subinstr(inst_name_clean, "CORPORATION", "", .)
replace inst_name_clean = subinstr(inst_name_clean, "LLC", "", .)
replace inst_name_clean = subinstr(inst_name_clean, "LTD", "", .)
replace inst_name_clean = subinstr(inst_name_clean, "  ", " ", .)
replace inst_name_clean = trim(inst_name_clean)

* Rename acct_nbr to accountnumber
rename acct_nbr accountnumber

* Keep necessary variables
keep accountnumber inst_name_clean inst_nm inst_typ cert_nbr asset_sz institutiondeposits branches est_dt lon lat state zip county msa cbsa

save "/Users/chenzhiying/Downloads/results/deposit_data.dta", replace

* Save as temporary file
tempfile deposit_data
save `deposit_data', replace

* Return to Combined Data and clean institution names
use "/Volumes/aae/groups/Data/zchen2365/Combined Data.dta", clear

* Keep relevant variables for analysis
keep id CU_dummy period year instme total_assets amt_total_loans members ///
    potential_members marketShare ///
    net_worth capAd pctComm pctRes pctCons mortgages firstMortgages ///
    delqRatio netChargeOffRatio logAsset assetGrowth loanGrowth ///
    depositGrowth roa loansForSale mortgageBackedSecurities ///
    fedFundsAndRevRepurchase coreDeposits fee_income state ///
    total_capital loan_share_ratio
	
* Clean institution names in Combined Data
gen inst_name_clean = upper(instme)
replace inst_name_clean = subinstr(inst_name_clean, ".", "", .)
replace inst_name_clean = subinstr(inst_name_clean, ",", "", .)
replace inst_name_clean = subinstr(inst_name_clean, "INC", "", .)
replace inst_name_clean = subinstr(inst_name_clean, "INCORPORATED", "", .)
replace inst_name_clean = subinstr(inst_name_clean, "CORP", "", .)
replace inst_name_clean = subinstr(inst_name_clean, "CORPORATION", "", .)
replace inst_name_clean = subinstr(inst_name_clean, "LLC", "", .)
replace inst_name_clean = subinstr(inst_name_clean, "LTD", "", .)
replace inst_name_clean = subinstr(inst_name_clean, "  ", " ", .)
replace inst_name_clean = trim(inst_name_clean)

* Generate additional useful ratios and metrics
gen capital_ratio = total_capital/total_assets
gen loan_to_deposit = amt_total_loans/coreDeposits
gen fee_income_ratio = fee_income/total_assets
gen mortgage_concentration = mortgages/amt_total_loans

* Create categorical variables for size based on total assets
egen asset_size_cat = cut(total_assets), group(5)
label define size_cat 0 "Very Small" 1 "Small" 2 "Medium" 3 "Large" 4 "Very Large"
label values asset_size_cat size_cat












* Save cleaned Combined Data
tempfile combined_clean
save `combined_clean'

* Perform fuzzy matching using reclink2
reclink2 inst_name_clean using "deposit_data.dta", idmaster(id) idusing(inst_nm) gen(matchscore) minscore(0.6) required(inst_name_clean)

* Examine match quality
gsort - matchscore
list inst_name_clean inst_name_clean_using matchscore in 1/10, clean

* Keep good matches (adjust threshold as needed)
keep if matchscore >= 0.8

* Drop unnecessary matching variables
drop *_using matchscore

* Save the merged dataset
save "Final_Merged_Data.dta", replace

* Generate match quality report
preserve
gen match_quality = "Excellent" if matchscore >= 0.95
replace match_quality = "Good" if matchscore >= 0.85 & matchscore < 0.95
replace match_quality = "Fair" if matchscore >= 0.80 & matchscore < 0.85
tab match_quality if !missing(match_quality)
restore
