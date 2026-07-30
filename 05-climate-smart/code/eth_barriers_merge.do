* Project: climate smart ag adoption
* Created on: 28 july 2026
* Created by: jt
* Edited on: 29 july 2026
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
	
* remove holders outside the CSA analysis sample
	drop				if merge_sect7 == 2

* confirm original analysis sample is preserved
	count

	isid				wave holder_id parcel_id field_id

* remove merge indicator
	drop				merge_sect7
	
* inspect credit-access barrier by wave
	tab					wave no_credit, missing
	
* inspect extension-program barrier by wave
	tab					wave no_extension, missing
	
* inspect advisory-services barrier by wave
	tab					wave no_advisory, missing
	

************************************************************************
**# 5 - merge household economic barriers
************************************************************************

* construct household merge identifier in analysis data
	gen str18			hh_merge_id = household_id

	replace				hh_merge_id = household_id2 ///
							if wave == 2

* confirm household merge identifier is available
	assert				!missing(hh_merge_id)


* append household nonfarm-enterprise barriers across waves
	preserve

	tempfile			sect4_all

	forvalues w = 1/5 {

		use				"$aide_data/lsms_gender_data/01-refined_data/ethiopia/wave_`w'/sect4_hh_w`w'.dta", clear

		gen				wave = `w'

* construct wave-specific household merge identifier
		if `w' == 2 {

			gen str18		hh_merge_id = household_id2

		}

		else {

			gen str18		hh_merge_id = household_id

		}

	* confirm barrier is constant within household
		bysort			hh_merge_id: ///
							assert no_nfe == no_nfe[1]

	* retain one observation per household
		bysort			hh_merge_id: ///
							keep if _n == 1

		keep			wave hh_merge_id no_nfe

		isid			wave hh_merge_id

		if `w' == 1 {

			save			`sect4_all', replace

		}

		else {

			append			using `sect4_all'

			save			`sect4_all', replace

		}

	}

	restore


* merge household economic barrier into field-level data
	merge m:1			wave hh_merge_id ///
							using `sect4_all', ///
							keepusing(no_nfe) ///
							generate(merge_sect4)

* inspect merge results
	tab					wave merge_sect4, missing

* remove households outside the CSA analysis sample
	drop				if merge_sect4 == 2

* confirm original field-level sample is preserved
	assert				_N == 75033

	isid				wave holder_id parcel_id field_id

* inspect nonfarm-enterprise barrier by wave
	tab					wave no_nfe, missing
	
* remove merge indicator
	drop				merge_sect4
	

************************************************************************
**# 6 - prepare communication barrier
************************************************************************

* construct communication merge identifier
	gen str18			comm_merge_id = household_id

	replace				comm_merge_id = household_id2 ///
							if inlist(wave, 2, 3)
							
* append household communication barriers across available waves
	preserve

	tempfile			communication_all

	forvalues w = 1/3 {

		use				"$aide_data/lsms_gender_data/01-refined_data/ethiopia/wave_`w'/sect10_hh_w`w'.dta", clear

		gen				wave = `w'

		gen str18		comm_merge_id = household_id

		keep			wave comm_merge_id no_communication

		isid			wave comm_merge_id

		if `w' == 1 {

			save			`communication_all', replace

		}

		else {

			append			using `communication_all'

			save			`communication_all', replace

		}

	}

* add Wave 4 communication barrier
	use				"$aide_data/lsms_gender_data/01-refined_data/ethiopia/wave_4/sect11_hh_w4.dta", clear

	gen				wave = 4

	gen str18		comm_merge_id = household_id

	keep				wave comm_merge_id no_communication

	isid				wave comm_merge_id

	append				using `communication_all'

	save				`communication_all', replace

	restore
	
* merge household communication barrier into field-level data
	merge m:1			wave comm_merge_id ///
							using `communication_all', ///
							keepusing(no_communication) ///
							generate(merge_communication)

* inspect communication-barrier merge results
	tab					wave merge_communication, missing
	
* inspect Wave 3 household identifiers from analysis data
	preserve

	keep				if wave == 3 & merge_communication == 1

	list				comm_merge_id household_id ///
							in 1/10, clean noobs

	restore


* inspect Wave 3 household identifiers from communication data
	preserve

	keep				if wave == 3 & merge_communication == 2

	list				comm_merge_id ///
							in 1/10, clean noobs

	restore
	
* inspect extra characters in Wave 3 communication identifiers
	preserve

	keep				if wave == 3 & ///
							merge_communication == 2

	gen str4			id_extra = ///
							substr(hh_merge_id, 7, 4)

	tab					id_extra, missing

	restore
	
* inspect Wave 3 communication-file identifiers
	preserve

	use				"$aide_data/lsms_gender_data/01-refined_data/ethiopia/wave_3/sect10_hh_w3.dta", clear

	describe			*id*

	restore
	
* inspect communication-barrier merge results
	tab					wave merge_communication, missing

* remove households outside the CSA analysis sample
	drop				if merge_communication == 2

* confirm original field-level sample is preserved
	assert				_N == 75033

	isid				wave holder_id parcel_id field_id

* inspect communication-access barrier by wave
	tab					wave no_communication, missing

* remove merge indicator and temporary merge identifiers
	drop				merge_communication ///
						hh_merge_id comm_merge_id
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	