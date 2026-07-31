* Project: climate smart ag adoption
* Created on: july 2026
* Created by: jt
* Edited on: 30 july 2026
* Edited by: jt
* Stata v.18.5

	* This file:
		* 1. opens the final Ethiopia CSA regression data
		* 2. defines the regression variables and analysis samples
		* 3. estimates the four CSA outcome specifications
		* 4. stores and exports the final regression results


************************************************************************
**# 0 - setup
************************************************************************

	clear all
	set more off

* load project setup
	do					"C:/Users/tijer/git/UROC/climate-smart-ag-adoption/05-climate-smart/code/00_setup.do"

* define paths
	global	root		"$clean_data/ethiopia"
	global	export		"$cs_output"
	global	logout		"$cs_logs"

* open log
	cap					log close

	log					using ///
							"$logout/selection_models.log", ///
							replace text


************************************************************************
**# 1 - open final regression data
************************************************************************

* open final regression data
	use					"$root/eth_csa_regression.dta", clear

* confirm field-wave identifiers are unique
	isid				wave holder_id parcel_id field_id

* confirm final sample size
	assert				_N == 75033

* inspect observations by wave
	tab					wave, missing
	
	
************************************************************************
**# 2 - define regression variables
************************************************************************

* define barrier-domain indices
	local barriers		econ_barrier_index ///
						inst_barrier_index ///
						land_barrier_index

* define manager characteristics
	local manager		female_manager ///
						manager_age ///
						manager_age_sq ///
						manager_lowedu
						
* construct additional manager controls
	gen					manager_not_head = ///
						mg1_relat != 1 ///
						if !missing(mg1_relat)

	gen					manager_married = ///
						inlist(mg1_mrry, 2, 3) ///
						if inrange(mg1_mrry, 1, 6)

	label variable		manager_not_head ///
						"Primary manager is not household head"

	label variable		manager_married ///
						"Primary manager is married"

* define candidate controls for variable selection
	local candidates	manager_not_head ///
						manager_married ///
						mg1_farm ///
						mg1_wage
						
	misstable 			summarize `candidates'

* inspect missingness in outcomes and explanatory variables
	misstable summarize ///
						csa_pca_index ///
						any_csa ///
						csa_count ///
						csa_irr csa_seed csa_soil csa_cons ///
						`barriers' ///
						`manager'
	
* inspect region fixed-effect availability
	misstable summarize	admin_1

	tab					wave admin_1, missing
	
* search for alternative region variables
	lookfor				region

	describe			admin_*
	
* inspect Wave 5 region variable
	tab					wave admin_1, missing

************************************************************************
**# 3 - define common regression sample
************************************************************************

* count missing explanatory variables and region fixed effects
	egen				rhs_missing = rowmiss( ///
						`barriers' ///
						`manager' ///
						admin_1)

* identify observations with complete explanatory variables
	gen					sample_rhs = rhs_missing == 0

	label variable		sample_rhs ///
						"Complete RHS and region-FE sample"

* create numeric holder identifier for clustered cross-validation
	egen				holder_cluster = group(holder_id)

	label variable		holder_cluster ///
						"Holder-level cluster identifier"
						
* inspect common regression sample by wave
	tab					wave sample_rhs, missing
	
	
************************************************************************
**# 4 - define outcome-specific samples
************************************************************************

* define outcome-specific regression samples
	gen					sample_pca = ///
						sample_rhs == 1 & ///
						!missing(csa_pca_index)

	gen					sample_any = ///
						sample_rhs == 1 & ///
						!missing(any_csa)

	gen					sample_count = ///
						sample_rhs == 1 & ///
						!missing(csa_count)

	gen					sample_irr = ///
						sample_rhs == 1 & ///
						!missing(csa_irr)

	gen					sample_seed = ///
						sample_rhs == 1 & ///
						!missing(csa_seed)

	gen					sample_soil = ///
						sample_rhs == 1 & ///
						!missing(csa_soil)

	gen					sample_cons = ///
						sample_rhs == 1 & ///
						!missing(csa_cons)
						
* count missing candidate controls
	egen				candidate_missing = rowmiss( ///
						`candidates')

* define variable-selection samples
	gen					sample_select_pca = ///
						sample_pca == 1 & ///
						candidate_missing == 0

	gen					sample_select_any = ///
						sample_any == 1 & ///
						candidate_missing == 0

	gen					sample_select_count = ///
						sample_count == 1 & ///
						candidate_missing == 0

* inspect variable-selection sample sizes
	tabstat				sample_select_pca ///
						sample_select_any ///
						sample_select_count, ///
						by(wave) ///
						statistics(sum)

* inspect regression sample sizes by wave
	tabstat				sample_pca ///
						sample_any ///
						sample_count ///
						sample_irr ///
						sample_seed ///
						sample_soil ///
						sample_cons, ///
						by(wave) ///
						statistics(sum)
	
	
************************************************************************
**# 5 - estimate csa-count lasso model
************************************************************************

* select additional controls for CSA practice count
	lasso poisson		csa_count ///
						(`barriers' ///
						`manager' ///
						i.wave i.admin_1) ///
						`candidates' ///
						if sample_select_count == 1, ///
						selection(cv) ///
						cluster(holder_cluster) ///
						rseed(20260730)

* store CSA-count lasso model
	estimates store		count_lasso

* display selected variables and postselection coefficients
	lassocoef,			display(coef, postselection)
	
	
************************************************************************
**# 6 - estimate csa-count elastic-net model
************************************************************************

* select additional controls for CSA practice count
	elasticnet poisson	csa_count ///
						(`barriers' ///
						`manager' ///
						i.wave i.admin_1) ///
						`candidates' ///
						if sample_select_count == 1, ///
						alpha(.25 .5 .75) ///
						selection(cv) ///
						cluster(holder_cluster) ///
						rseed(20260730)

* store CSA-count elastic-net model
	estimates store		count_elastic

* display selected variables and postselection coefficients
	lassocoef,			display(coef, postselection)

* close log
	log close

*