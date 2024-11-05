* Import the existing dataset with deposit institution details
import delimited using "Deposit_InstitutionDetail.txt", delimiter("|") clear
tempfile deposit_data
save `deposit_data'

* Import the credit union and bank dataset
use "/Volumes/aae/groups/Data/zchen2365/Combined Data.dta", clear

* Keep relevant variables for analysis
keep id CU_dummy period year instme total_assets amt_total_loans members ///
    potential_members marketShare ///
    net_worth capAd pctComm pctRes pctCons mortgages firstMortgages ///
    delqRatio netChargeOffRatio logAsset assetGrowth loanGrowth ///
    depositGrowth roa loansForSale mortgageBackedSecurities ///
    fedFundsAndRevRepurchase coreDeposits fee_income state ///
    total_capital loan_share_ratio

* Generate additional useful ratios and metrics
gen capital_ratio = total_capital/total_assets
gen loan_to_deposit = amt_total_loans/coreDeposits
gen fee_income_ratio = fee_income/total_assets
gen mortgage_concentration = mortgages/amt_total_loans

* Create categorical variables for size based on total assets
egen asset_size_cat = cut(total_assets), group(5)
label define size_cat 0 "Very Small" 1 "Small" 2 "Medium" 3 "Large" 4 "Very Large"
label values asset_size_cat size_cat

* Convert state codes to match deposit institution data format if needed
* (You may need to modify this based on your actual state code format)
replace state = upper(state)

* Save temporary file
tempfile analysis_data
save `analysis_data'

* Merge with deposit institution data
use `deposit_data', clear
merge 1:1 state zip_code using `analysis_data'

* Clean up merge results
* Keep only matched observations or modify based on your needs
keep if _merge == 3
drop _merge

* Generate additional variables that combine information from both datasets
gen deposits_per_branch = INSTITUTIONDEPOSITS/BRANCHES
gen assets_per_branch = total_assets/BRANCHES

* Label variables
label variable capital_ratio "Capital to Assets Ratio"
label variable loan_to_deposit "Loan to Deposit Ratio"
label variable fee_income_ratio "Fee Income to Assets Ratio"
label variable mortgage_concentration "Mortgage Concentration"
label variable deposits_per_branch "Deposits per Branch"
label variable assets_per_branch "Assets per Branch"

* Format numeric variables
format total_assets amt_total_loans coreDeposits %15.2fc
format capital_ratio loan_to_deposit fee_income_ratio %9.4f
format deposits_per_branch assets_per_branch %15.2fc

* Save final dataset
save "merged_analysis_data.dta", replace

* Generate summary statistics
tabstat capital_ratio loan_to_deposit fee_income_ratio mortgage_concentration ///
    deposits_per_branch assets_per_branch, by(CU_dummy) ///
    statistics(mean sd min p25 p50 p75 max) columns(statistics)
