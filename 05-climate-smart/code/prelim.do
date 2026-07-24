* Project: gender
* Created on: July 2026
* Created by: jmt
* Stata v.19.5

* does
	* establishes an identical workspace between users
	* sets globals that define absolute paths
	* serves as the starting point to find any do-file, dataset or output
	* runs all do-files needed for data work. ([!] Eventually)
	* loads any user written packages needed for analysis

* assumes
	* access to all data and code

* TO DO:
	* add all do-files

	


clear all
set more off
capture log close _all

************************************************************************
* 0. Load project setup
************************************************************************

do "C:/Users/tijer/git/UROC/climate-smart-ag-adoption/05-climate-smart/code/00_setup.do"

************************************************************************
* 1. Open the appended Ethiopia dataset
************************************************************************

use "$eth_allrounds", clear

log using "$cs_logs/preliminary_results.log", replace text

count
tab wave
describe


************************************************************************
* 2. Construct preliminary variables
************************************************************************

* Female primary manager
* Confirm that 1 = male and 2 = female
tab mg1_sex, missing

gen female_manager = .
replace female_manager = 0 if mg1_sex == 1
replace female_manager = 1 if mg1_sex == 2

label define yesno01 0 "No" 1 "Yes", replace
label values female_manager yesno01
label variable female_manager "Female primary manager"

* Manager age
clonevar manager_age = mg1_age
label variable manager_age "Primary manager age"

* Lowest/no formal education category
* Preserve the original mg1_edu variable
gen manager_lowedu = (mg1_edu == 98) if !missing(mg1_edu)
label values manager_lowedu yesno01
label variable manager_lowedu "Manager has little or no formal education"

* Land certificate
* Account for possible 0/1 and 1/2 coding
tab wave title, missing

gen has_certificate = .
replace has_certificate = 1 if title == 1
replace has_certificate = 0 if inlist(title, 0, 2)

label values has_certificate yesno01
label variable has_certificate "Household has parcel certificate"

* Right to sell or use parcel as collateral
tab wave collat, missing

gen collateral_right = .
replace collateral_right = 1 if collat == 1
replace collateral_right = 0 if inlist(collat, 0, 2)

label values collateral_right yesno01
label variable collateral_right ///
    "Right to sell or use parcel as collateral"
	
	
************************************************************************
* 3. Descriptive statistics by wave
************************************************************************

tabstat female_manager manager_age manager_lowedu ///
        mg1_farm mg1_nfe mg1_wage ///
        has_certificate collateral_right, ///
        by(wave) statistics(n mean sd) columns(statistics)
		
		
collect clear

table wave, ///
    statistic(frequency) ///
    statistic(mean female_manager) ///
    statistic(mean manager_age) ///
    statistic(mean manager_lowedu) ///
    statistic(mean mg1_farm) ///
    statistic(mean mg1_nfe) ///
    statistic(mean mg1_wage) ///
    statistic(mean has_certificate) ///
    statistic(mean collateral_right) ///
    nformat(%12.0fc frequency) ///
    nformat(%9.3f mean)

collect title ///
    "Table 1. Preliminary Characteristics of Plot Managers and Land Rights by Survey Wave"

collect export ///
    "$csa_output/table1_preliminary_characteristics.docx", ///
    replace
	
	
************************************************************************
* 4. Female-managed observations by wave
************************************************************************
preserve

collapse (mean) female_manager, by(wave)
replace female_manager = female_manager * 100

graph bar female_manager, ///
    over(wave, relabel( ///
        1 "Wave 1" ///
        2 "Wave 2" ///
        3 "Wave 3" ///
        4 "Wave 4" ///
        5 "Wave 5")) ///
    bar(1, color(teal) lcolor(black)) ///
    blabel(bar, format(%4.1f) color(black)) ///
    ytitle("Female-managed observations (%)") ///
    title("Share of Female-Managed Observations by Survey Wave") ///
    subtitle("Wave years: 2011/12, 2013/14, 2015/16, 2018/19, 2021/22") ///
    note("Source: Ethiopia Socioeconomic Survey. Preliminary results.")

graph export ///
    "$cs_output/figure1_female_manager_bar.png", ///
    width(2000) replace

restore

************************************************************************
* 5. Land certification by wave
************************************************************************
************************************************************************
* Figure 2: Land certification by survey wave
************************************************************************

preserve

* Keep observations with a valid certificate response
keep if !missing(has_certificate)

* Calculate the share with a certificate in each wave
collapse (mean) has_certificate, by(wave)
replace has_certificate = has_certificate * 100

graph bar has_certificate, ///
    over(wave, relabel( ///
        1 "Wave 1" ///
        2 "Wave 2" ///
        3 "Wave 3" ///
        4 "Wave 4" ///
        5 "Wave 5")) ///
    bar(1, color(teal) lcolor(black)) ///
    blabel(bar, format(%4.1f) color(black)) ///
    ytitle("Land observations with a certificate (%)") ///
    title("Share of Land Observations with a Certificate") ///
    subtitle("Wave years: 2011/12, 2013/14, 2015/16, 2018/19, 2021/22") ///
    note("Source: Ethiopia Socioeconomic Survey. Preliminary results.") ///
    legend(off)

graph export ///
    "$cs_output/figure2_land_certificate.png", ///
    width(2000) replace

restore


************************************************************************
* / END MATTER /
************************************************************************
log close
	