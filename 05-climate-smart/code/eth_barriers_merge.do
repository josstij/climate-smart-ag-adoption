* Project: climate smart ag adoption
* Created on: 28 july 2026
* Created by: jt
* Edited on: 28 july 2026
* Edited by: jt
* Stata v.18.5


************************************************************************
**# 0 - setup
************************************************************************

	clear all
	set more off

************************************************************************
**# 1 - open appended csa data
************************************************************************

	use				"$clean_data/ethiopia/eth_csa_analysis.dta", clear

	isid				wave holder_id parcel_id field_id

	tab					wave
	
*	describe			female_manager manager_age manager_age_sq ///
*						manager_lowedu collateral_right

	lookfor				manager
	lookfor				female sex gender
	
	tab					mg1_sex, missing nolabel
	
	gen byte			female_manager = (mg1_sex == 2) ///
							if !missing(mg1_sex)

	label define		female_manager_lbl 0 "Male" 1 "Female", replace
	label values		female_manager female_manager_lbl
	label variable		female_manager "First plot manager is female"

	tab					wave female_manager, missing
	
	lookfor 			age
	
	tabstat				mg1_age, by(wave) ///
							statistics(n mean min max) 
							
	tab					wave if mg1_age < 15, missing
	
	tab					mg1_age wave if mg1_age < 15, missing
	
	gen					manager_age = mg1_age

	replace				manager_age = . if manager_age < 15

	label variable		manager_age "Age of first plot manager"

	tabstat				manager_age, by(wave) ///
							statistics(n mean min max)
	
	lookfor				education school grade
	
	tab					mg1_edu, missing
	
	tab 				mg1_edu, missing nolabel
	
	gen byte			manager_lowedu = (mg1_edu == 98) ///
							if !missing(mg1_edu)

	label values		manager_lowedu yesno01
	label variable		manager_lowedu ///
							"Manager cannot read or write"

	tab					wave manager_lowedu, missing
	
	gen					manager_age_sq = manager_age^2

	label variable		manager_age_sq ///
							"Age of first plot manager squared"
	lookfor				collateral tenure title certificate sell rent transfer
	
	tab 				wave collat, missing
	
	tab 				collat, missing nolabel
	
	gen byte			no_collateral_right = (collat == 0) ///
							if !missing(collat)

	label values		no_collateral_right yesno01
	label variable		no_collateral_right ///
							"Household lacks right to sell or collateralize parcel"

	tab					wave no_collateral_right, missing
	
	tab					wave title, missing
	
	label list			yesno
	
	notes				title
	
	
	
	
	
	
	
