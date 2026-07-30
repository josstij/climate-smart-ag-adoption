* Project: climate smart ag adoption
* Created on: 28 july 2026
* Created by: jt
* Edited on: 28 july 2026
* Edited by: jt
* Stata v.18.5

	* This file:
		* 1. opens the appended Ethiopia CSA analysis data
		* 2. constructs manager-level explanatory variables
		* 3. harmonizes and constructs barriers to CSA adoption
		* 4. creates barrier indices across available survey waves
		* 5. saves the final Ethiopia barriers analysis data


************************************************************************
**# 0 - setup
************************************************************************

	clear all
	set more off

************************************************************************
**# 1 - open appended csa data
************************************************************************

* open appended CSA analysis data
	use				"$clean_data/ethiopia/eth_csa_analysis.dta", clear

* confirm field-wave identifiers are unique
	isid				wave holder_id parcel_id field_id

* inspect observations by wave
	tab					wave


************************************************************************
**# 2 - construct manager characteristics
************************************************************************

* inspect manager sex variables
	lookfor				manager
	lookfor				female sex gender

* confirm coding of primary manager sex
	tab					mg1_sex, missing nolabel

* construct female-manager indicator
	gen byte			female_manager = (mg1_sex == 2) ///
							if !missing(mg1_sex)

	label define		female_manager_lbl ///
							0 "Male" ///
							1 "Female", replace

	label values		female_manager female_manager_lbl
	label variable		female_manager ///
							"First plot manager is female"

* inspect female-manager indicator by wave
	tab					wave female_manager, missing


* inspect primary manager age
	lookfor				age

	tabstat				mg1_age, by(wave) ///
							statistics(n mean min max)

* inspect implausible manager ages
	tab					wave if mg1_age < 15, missing

	tab					mg1_age wave if mg1_age < 15, ///
							missing

* construct cleaned manager age
	gen					manager_age = mg1_age

	replace				manager_age = . ///
							if manager_age < 15

	label variable		manager_age ///
							"Age of first plot manager"

* inspect cleaned manager age by wave
	tabstat				manager_age, by(wave) ///
							statistics(n mean min max)

* construct squared manager age
	gen					manager_age_sq = manager_age^2

	label variable		manager_age_sq ///
							"Age of first plot manager squared"


* inspect primary manager education
	lookfor				education school grade

	tab					mg1_edu, missing

* confirm coding of primary manager education
	tab					mg1_edu, missing nolabel

* construct manager literacy barrier
	gen byte			manager_lowedu = (mg1_edu == 98) ///
							if !missing(mg1_edu)

	label values		manager_lowedu yesno01
	label variable		manager_lowedu ///
							"Manager cannot read or write"

* inspect manager literacy barrier by wave
	tab					wave manager_lowedu, missing


************************************************************************
**# 3 - construct land and tenure barriers
************************************************************************

* inspect available land-rights variables
	lookfor				collateral tenure title certificate ///
							sell rent transfer


* inspect collateral-rights variable
	tab					wave collat, missing

* confirm coding of collateral-rights variable
	tab					collat, missing nolabel

* construct lack of collateral-rights barrier
	gen byte			no_collateral_right = (collat == 0) ///
							if !missing(collat)

	label values		no_collateral_right yesno01
	label variable		no_collateral_right ///
							"Household lacks right to sell or collateralize parcel"

* inspect collateral-rights barrier by wave
	tab					wave no_collateral_right, missing


* inspect land-certificate variable
	tab					wave title, missing

* inspect attached value label
	label list			yesno

* inspect variable notes
	notes				title

* harmonize Wave 5 no response with Waves 1-4
	replace				title = 0 ///
							if wave == 5 & title == 2

* confirm harmonized certificate variable
	tab					wave title, missing
	
* construct lack of land-certificate barrier
	gen byte			no_land_certificate = (title == 0) ///
							if !missing(title)

	label values		no_land_certificate yesno01
	label variable		no_land_certificate ///
							"Household lacks parcel certificate"

* inspect land-certificate barrier by wave
	tab					wave no_land_certificate, missing
	
* inspect parcel-tenure categories by wave
	tab					wave tenure, missing
	
* confirm coding of parcel-tenure categories by wave
	tab					wave tenure, missing nolabel
	
* inspect parcel-tenure value labels
	label list			pp_s2q03
	
* construct potentially insecure tenure barrier
	gen byte			insecure_tenure = .

	replace				insecure_tenure = 0 ///
							if inlist(tenure, 1, 2)

	replace				insecure_tenure = 0 ///
							if inlist(wave, 3, 4, 5) & tenure == 7

	replace				insecure_tenure = 1 ///
							if inlist(tenure, 3, 4, 5)

	replace				insecure_tenure = 1 ///
							if wave == 1 & tenure == 10

	replace				insecure_tenure = 1 ///
							if inlist(wave, 3, 4, 5) & tenure == 6

	label values		insecure_tenure yesno01
	label variable		insecure_tenure ///
							"Parcel has potentially insecure tenure arrangement"

* inspect tenure barrier by wave
	tab					wave insecure_tenure, missing
	
* confirm cleaned institutional barrier files exist
	forvalues w = 1/5 {

		confirm file		"$aide_data/lsms_gender_data/01-refined_data/ethiopia/wave_`w'/sect7_pp_w`w'.dta"

	}
	
	
************************************************************************
**# 4 - prepare economic and institutional barriers
************************************************************************

* append holder-level barrier files across waves
	preserve

	tempfile			sect7_all

	forvalues w = 1/5 {

		use				"$aide_data/lsms_gender_data/01-refined_data/ethiopia/wave_`w'/sect7_pp_w`w'.dta", clear

		gen				wave = `w'

		keep			wave holder_id ///
							no_credit no_extension no_advisory

		isid			wave holder_id

		if `w' == 1 {

			save			`sect7_all', replace

		}

		else {

			append			using `sect7_all'

			save			`sect7_all', replace

		}

	}

	restore
	
* merge holder-level barriers into field-level data
	merge m:1			wave holder_id ///
							using `sect7_all', ///
							keepusing(no_credit no_extension no_advisory) ///
							generate(merge_sect7)

* inspect merge results by wave
	tab					wave merge_sect7, missing
	

	
	
	
	
	