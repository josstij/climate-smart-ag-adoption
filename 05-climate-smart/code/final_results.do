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
							"$logout/final_results.log", ///
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

* inspect missingness in outcomes and explanatory variables
	misstable summarize ///
						csa_pca_index ///
						any_csa ///
						csa_count_obs ///
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
						!missing(csa_count_obs)

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
**# 5 - estimate pca outcome model
************************************************************************

* create numeric holder cluster identifier
	egen				holder_cluster = group(holder_id)

* estimate PCA outcome using barrier domains
	regress				csa_pca_index ///
						`barriers' ///
						`manager' ///
						i.wave i.admin_1 ///
						if sample_pca == 1, ///
						vce(cluster holder_cluster)

* store PCA model
	estimates store		pca_domains
	
	
************************************************************************
**# 6 - estimate any-csa outcome model
************************************************************************

* estimate linear probability model for any CSA adoption
	regress				any_csa ///
						`barriers' ///
						`manager' ///
						i.wave i.admin_1 ///
						if sample_any == 1, ///
						vce(cluster holder_cluster)

* store any-CSA model
	estimates store		any_domains
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	