* Project: lsms csa
* Created on: july 2026
* Created by: jt
* Edited on: july 2026
* Edited by: jt
* Stata v.19.5

* does
	* loads the final Ethiopia CSA analysis dataset
	* confirms the field-wave structure of the analysis data
	* inventories available manager, household, land, and institutional variables
	* identifies candidate controls for final regression models
	
* assumes
	* eth_csa_analysis.dta has been created
	* CSA outcomes have been merged with the existing Ethiopia variables
	* wave, holder_id, parcel_id, and field_id uniquely identify observations
	
* TO DO:
	* inspect candidate-variable coding
	* identify variables comparable across survey waves
	* document variables retained for pruning
	* document variables excluded from final models


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
	global	logout		"$cs_logs"

* open log
	log		using		"$logout/01_variable_inventory.log", ///
				replace text


************************************************************************
**# 1 - open Ethiopia CSA analysis data
************************************************************************

* load final merged analysis data
	use		"$root/eth_csa_analysis", clear

* confirm dataset size
	count

* inspect observations by wave
	tab		wave, missing

* confirm field-wave identifiers
	isid	wave holder_id parcel_id field_id

* inspect dataset structure
	describe


************************************************************************
**# 2 - inspect CSA outcomes and core variables
************************************************************************

* inspect CSA outcomes
	describe	any_csa csa_count_obs ///
				csa_irr csa_seed csa_soil csa_cons

	tab		wave any_csa, missing

	tabstat	any_csa csa_count_obs, ///
				by(wave) ///
				statistics(n mean sd min max)

* inspect primary manager variables
	describe	mg1_sex mg1_age mg1_edu ///
				mg1_farm mg1_nfe mg1_wage

	tab		wave mg1_sex, missing
	tab		wave mg1_edu, missing

* inspect land-rights variables
	describe	title collat

	tab		wave title, missing
	tab		wave collat, missing


************************************************************************
**# 3 - identify candidate explanatory variables
************************************************************************

* gender and household management
	lookfor		female
	lookfor		gender
	lookfor		household head
	lookfor		manager
	lookfor		owner

* household characteristics
	lookfor		household size
	lookfor		working age
	lookfor		dependency
	lookfor		education
	lookfor		literacy

* land and field characteristics
	lookfor		area
	lookfor		size
	lookfor		tenure
	lookfor		title
	lookfor		certificate
	lookfor		collateral
	lookfor		slope
	lookfor		soil

* labor and economic characteristics
	lookfor		hired labor
	lookfor		family labor
	lookfor		credit
	lookfor		asset
	lookfor		subsidy
	lookfor		program
	lookfor		enterprise
	lookfor		wage

* institutional access
	lookfor		extension
	lookfor		advice
	lookfor		training
	lookfor		weather
	lookfor		information
	lookfor		communication
	lookfor		phone
	lookfor		radio

* climate and agricultural shocks
	lookfor		shock
	lookfor		drought
	lookfor		flood
	lookfor		rainfall
	lookfor		pest
	lookfor		disease

* geographic controls
	lookfor		region
	lookfor		zone
	lookfor		woreda
	lookfor		rural
	lookfor		distance
	lookfor		market


************************************************************************
**# 4 - document known cross-wave problems
************************************************************************

* employment variables are not comparable across all five waves
	tab		wave mg1_farm, missing
	tab		wave mg1_nfe, missing
	tab		wave mg1_wage, missing

* land certification requires additional harmonization
	tab		wave title, missing

* collateral rights are unavailable in Wave 1
	tab		wave collat, missing


************************************************************************
**# 5 - end matter
************************************************************************

* close log
	log		close