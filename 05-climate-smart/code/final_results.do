* Project: lsms csa
* Created on: july 2026
* Created by: jt
* Edited on: july 2026
* Edited by: jt
* Stata v.19.5

* does
	* loads the final Ethiopia CSA analysis dataset
	* reconstructs theoretically central explanatory variables
	* audits candidate controls for cross-wave comparability
	* prepares candidate controls for LASSO and elastic net
	* estimates post-selection CSA adoption models
	
* assumes
	* eth_csa_analysis.dta has been created
	* CSA outcomes have been harmonized across five Ethiopia survey waves
	* Manager 1 is used consistently as the primary field manager
	* theory variables remain in all relevant specifications
	
* TO DO:
	* inspect coding and missingness
	* define candidate control pool
	* prune noncomparable variables
	* run LASSO and elastic net
	* estimate post-selection regressions
	* export final tables and figures


clear all
set more off
cap log close _all


************************************************************************
**# 0 - setup
************************************************************************

* load project setup
	do		"C:/Users/tijer/git/UROC/climate-smart-ag-adoption/05-climate-smart/code/00_setup.do"

* define paths
	global	root		"$clean_data/ethiopia"
	global	export		"$cs_output"
	global	logout		"$cs_logs"

* open log
	log		using		"$logout/final_results.log", ///
				replace text

* load final analysis data
	use		"$root/eth_csa_analysis", clear

* confirm analysis unit
	isid	wave holder_id parcel_id field_id

* confirm observations
	count
	tab		wave, missing


************************************************************************
**# 1 - reconstruct core explanatory variables
************************************************************************

* female primary manager
	tab		mg1_sex, missing

	gen		female_manager = .
	replace	female_manager = 0 if mg1_sex == 1
	replace	female_manager = 1 if mg1_sex == 2

	label	define yesno01 0 "No" 1 "Yes", replace
	label	values female_manager yesno01
	label	variable female_manager ///
				"Female primary manager"

* primary manager age
	clonevar	manager_age = mg1_age

* exclude implausible primary-manager ages below 15
	replace	manager_age = . ///
				if manager_age < 15 & !missing(manager_age)

	label	variable manager_age ///
				"Primary manager age"

* nonlinear manager-age control
	gen		double manager_age_sq = manager_age^2 ///
				if !missing(manager_age)

	label	variable manager_age_sq ///
				"Primary manager age squared"

* manager education
	gen		manager_lowedu = (mg1_edu == 98) ///
				if !missing(mg1_edu)

	label	values manager_lowedu yesno01
	label	variable manager_lowedu ///
				"Manager has little or no formal education"

* collateral rights
	gen		collateral_right = .
	replace	collateral_right = 1 if collat == 1
	replace	collateral_right = 0 if inlist(collat, 0, 2)

	label	values collateral_right yesno01
	label	variable collateral_right ///
				"Right to sell or use parcel as collateral"


************************************************************************
**# 2 - audit core variables
************************************************************************

* inspect outcomes
	tab		wave any_csa, missing
	tabstat	any_csa csa_count_obs, ///
				by(wave) ///
				statistics(n mean sd min max)

* inspect manager age for questionable values
	summarize	manager_age, detail
	tab		manager_age ///
				if manager_age < 15 | manager_age > 90, ///
				missing

* inspect education coding
	tab		mg1_edu, missing

* inspect missingness in core variables
	misstable	summarize ///
				any_csa csa_count_obs ///
				female_manager manager_age manager_lowedu ///
				collateral_right
				
				
************************************************************************
**# 3 - audit available candidate controls
************************************************************************

* inspect available candidate variables
	describe	mg1_relat mg1_mrry mg1_away ///
				tenure mgmt1 deju1 deju1_sex admin_1

* manager relationship to household head
	tab		wave mg1_relat, missing

* manager marital status
	tab		wave mg1_mrry, missing

* manager time away from household
	tabstat	mg1_away, ///
				by(wave) ///
				statistics(n mean sd min max)

* parcel tenure
	tab		wave tenure, missing

* sex of first reported parcel owner or rights holder
	tab		wave deju1_sex, missing

* compare manager and owner identifiers
	tab		wave mgmt1, missing
	tab		wave deju1, missing

* geographic availability
	tab		wave admin_1, missing

* inspect candidate-variable missingness
	misstable	summarize ///
				mg1_relat mg1_mrry mg1_away ///
				tenure mgmt1 deju1 deju1_sex admin_1
				
				
************************************************************************
**# 4 - construct pruned candidate controls
************************************************************************

* primary manager is the household head
	gen		manager_head = .
	replace	manager_head = 1 if mg1_relat == 1
	replace	manager_head = 0 if inrange(mg1_relat, 2, 15)

	label	values manager_head yesno01
	label	variable manager_head ///
				"Primary manager is household head"

* primary manager is married
* codes 2 and 3 represent married categories
	gen		manager_married = .
	replace	manager_married = 1 if inlist(mg1_mrry, 2, 3)
	replace	manager_married = 0 if inlist(mg1_mrry, 1, 4, 5, 6)

	label	values manager_married yesno01
	label	variable manager_married ///
				"Primary manager is married"

* parcel was rented or borrowed
	gen		rented_borrowed = .
	replace	rented_borrowed = 1 if inlist(tenure, 3, 4)
	replace	rented_borrowed = 0 ///
				if !missing(tenure) & !inlist(tenure, 3, 4)

	label	values rented_borrowed yesno01
	label	variable rented_borrowed ///
				"Parcel was rented or borrowed"

* female first reported owner or rights holder
* available only for a restricted sample
	gen		female_owner = .
	replace	female_owner = 0 if deju1_sex == 1
	replace	female_owner = 1 if deju1_sex == 2

	label	values female_owner yesno01
	label	variable female_owner ///
				"Female first reported owner or rights holder"

* primary manager differs from first reported owner
* defined only when both household-member IDs are observed
	gen		manager_owner_diff = .
	replace	manager_owner_diff = (mgmt1 != deju1) ///
				if !missing(mgmt1, deju1)

	label	values manager_owner_diff yesno01
	label	variable manager_owner_diff ///
				"Primary manager differs from first reported owner"


************************************************************************
**# 5 - check constructed candidate controls
************************************************************************

* check coding across waves
	tab		wave manager_head, missing
	tab		wave manager_married, missing
	tab		wave rented_borrowed, missing
	tab		wave female_owner, missing
	tab		wave manager_owner_diff, missing

* confirm no primary-manager ages below 15 remain
	assert	manager_age >= 15 ///
				if !missing(manager_age)

* inspect managers older than 90 for later sensitivity analysis
	count	if manager_age > 90 & !missing(manager_age)

	tab		manager_age ///
				if manager_age > 90 & !missing(manager_age)
				
				
************************************************************************
**# 6 - define analysis samples
************************************************************************

* all-wave sample for main models
	gen		byte sample_all = ///
				!missing(any_csa, csa_count_obs, ///
				female_manager, manager_age, manager_lowedu, ///
				manager_head, manager_married, rented_borrowed)

	label	variable sample_all ///
				"Complete sample for all-wave models"

* waves 2-5 sample including collateral rights
	gen		byte sample_land = ///
				wave >= 2 & ///
				!missing(any_csa, csa_count_obs, ///
				female_manager, manager_age, manager_lowedu, ///
				collateral_right, manager_head, ///
				manager_married, rented_borrowed)

	label	variable sample_land ///
				"Complete sample for Waves 2-5 land-rights models"

* restricted owner and decision-making sample
	gen		byte sample_owner = ///
				wave >= 2 & ///
				!missing(any_csa, csa_count_obs, ///
				female_manager, manager_age, manager_lowedu, ///
				collateral_right, manager_head, ///
				manager_married, rented_borrowed, ///
				female_owner, manager_owner_diff)

	label	variable sample_owner ///
				"Restricted sample with owner information"

* inspect final sample sizes
	count	if sample_all
	count	if sample_land
	count	if sample_owner

	tab		wave if sample_all
	tab		wave if sample_land
	tab		wave if sample_owner

* confirm restricted samples are nested
	assert	sample_land <= sample_all
	assert	sample_owner <= sample_land
	
	
************************************************************************
**# 7 - all-wave LASSO and elastic-net selection
************************************************************************

* variables in parentheses are theoretically required
* remaining variables are eligible for selection

* LASSO: any observed CSA practice
	lasso	linear any_csa ///
				(female_manager manager_age manager_lowedu i.wave) ///
				manager_age_sq ///
				manager_head ///
				manager_married ///
				rented_borrowed ///
				if sample_all, ///
				selection(cv) ///
				rseed(20260726) ///
				nolog

	estimates	store lasso_any_all

* display selected variables
	lassocoef, ///
				sort(coef, standardized)


* elastic net: any observed CSA practice
	elasticnet linear any_csa ///
				(female_manager manager_age manager_lowedu i.wave) ///
				manager_age_sq ///
				manager_head ///
				manager_married ///
				rented_borrowed ///
				if sample_all, ///
				alpha(.25 .50 .75) ///
				rseed(20260726) ///
				nolog

	estimates	store enet_any_all

* display selected variables
	lassocoef, ///
				sort(coef, standardized)


* LASSO: number of observed CSA practices
	lasso	linear csa_count_obs ///
				(female_manager manager_age manager_lowedu i.wave) ///
				manager_age_sq ///
				manager_head ///
				manager_married ///
				rented_borrowed ///
				if sample_all, ///
				selection(cv) ///
				rseed(20260726) ///
				nolog

	estimates	store lasso_count_all

* display selected variables
	lassocoef, ///
				sort(coef, standardized)


* elastic net: number of observed CSA practices
	elasticnet linear csa_count_obs ///
				(female_manager manager_age manager_lowedu i.wave) ///
				manager_age_sq ///
				manager_head ///
				manager_married ///
				rented_borrowed ///
				if sample_all, ///
				alpha(.25 .50 .75) ///
				rseed(20260726) ///
				nolog

	estimates	store enet_count_all

* display selected variables
	lassocoef, ///
				sort(coef, standardized)


************************************************************************
**# 8 - compare selected all-wave controls
************************************************************************

* compare LASSO and elastic-net selection for any adoption
	lassocoef	lasso_any_all enet_any_all, ///
				sort(coef, standardized)

* compare LASSO and elastic-net selection for adoption count
	lassocoef	lasso_count_all enet_count_all, ///
				sort(coef, standardized)
				
				