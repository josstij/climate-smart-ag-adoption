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

	label	variable manager_age ///
				"Primary manager age"

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