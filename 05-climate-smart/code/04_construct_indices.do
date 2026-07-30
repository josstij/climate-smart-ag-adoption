* Project: climate smart ag adoption
* Created on: 30 july 2026
* Created by: jt
* Edited on: 30 july 2026
* Edited by: jt
* Stata v.18.5

	* This file:
		* 1. opens the Ethiopia CSA barriers data
		* 2. constructs economic barrier indices
		* 3. constructs institutional barrier indices
		* 4. constructs land and tenure barrier indices
		* 5. constructs the data-driven CSA index
		* 6. saves the final regression data


************************************************************************
**# 0 - setup
************************************************************************

	clear all
	set more off


************************************************************************
**# 1 - open barriers data
************************************************************************

	use				"$clean_data/ethiopia/eth_csa_barriers.dta", clear

	isid				wave holder_id parcel_id field_id
	
************************************************************************
**# 2 - construct economic barrier index
************************************************************************

* construct economic-barrier count
	egen				econ_barrier_count = ///
							rowtotal(no_credit no_nfe), missing

* count observed economic-barrier components
	egen				econ_barrier_n = ///
							rownonmiss(no_credit no_nfe)

* construct share of observed economic barriers present
	gen					econ_barrier_index = ///
							econ_barrier_count / econ_barrier_n ///
							if econ_barrier_n > 0

* label economic-barrier measures
	label variable		econ_barrier_count ///
							"Number of observed economic barriers"

	label variable		econ_barrier_n ///
							"Number of observed economic-barrier components"

	label variable		econ_barrier_index ///
							"Share of observed economic barriers present"

* inspect economic-barrier measures by wave
	tabstat				econ_barrier_count ///
							econ_barrier_index ///
							econ_barrier_n, ///
							by(wave) ///
							statistics(n mean min max)
							

************************************************************************
**# 3 - construct institutional barrier index
************************************************************************

* construct institutional-barrier count
	egen				inst_barrier_count = ///
							rowtotal(no_extension no_advisory ///
							no_communication), missing

* count observed institutional-barrier components
	egen				inst_barrier_n = ///
							rownonmiss(no_extension no_advisory ///
							no_communication)

* construct share of observed institutional barriers present
	gen					inst_barrier_index = ///
							inst_barrier_count / inst_barrier_n ///
							if inst_barrier_n > 0

* label institutional-barrier measures
	label variable		inst_barrier_count ///
							"Number of observed institutional barriers"

	label variable		inst_barrier_n ///
							"Number of observed institutional-barrier components"

	label variable		inst_barrier_index ///
							"Share of observed institutional barriers present"

* inspect institutional-barrier measures by wave
	tabstat				inst_barrier_count ///
							inst_barrier_index ///
							inst_barrier_n, ///
							by(wave) ///
							statistics(n mean min max)
							
							
************************************************************************
**# 4 - construct land and tenure barrier index
************************************************************************

* construct land-and-tenure barrier count
	egen				land_barrier_count = ///
							rowtotal(no_collateral_right ///
							no_land_certificate ///
							insecure_tenure), missing

* count observed land-and-tenure barrier components
	egen				land_barrier_n = ///
							rownonmiss(no_collateral_right ///
							no_land_certificate ///
							insecure_tenure)

* construct share of observed land-and-tenure barriers present
	gen					land_barrier_index = ///
							land_barrier_count / land_barrier_n ///
							if land_barrier_n > 0

* label land-and-tenure barrier measures
	label variable		land_barrier_count ///
							"Number of observed land and tenure barriers"

	label variable		land_barrier_n ///
							"Number of observed land and tenure components"

	label variable		land_barrier_index ///
							"Share of observed land and tenure barriers present"

* inspect land-and-tenure barrier measures by wave
	tabstat				land_barrier_count ///
							land_barrier_index ///
							land_barrier_n, ///
							by(wave) ///
							statistics(n mean min max)
							
							
************************************************************************
**# 5 - construct overall barrier index
************************************************************************

* count observed barrier domains
	egen				overall_barrier_n = ///
							rownonmiss(econ_barrier_index ///
							inst_barrier_index ///
							land_barrier_index)

* construct average barrier index across observed domains
	egen				overall_barrier_index = ///
							rowmean(econ_barrier_index ///
							inst_barrier_index ///
							land_barrier_index)

* label overall barrier measures
	label variable		overall_barrier_n ///
							"Number of observed barrier domains"

	label variable		overall_barrier_index ///
							"Average barrier share across observed domains"

* inspect overall barrier index by wave
	tabstat				overall_barrier_index ///
							overall_barrier_n, ///
							by(wave) ///
							statistics(n mean min max)
							
						
************************************************************************
**# 6 - inspect csa index availability
************************************************************************

* inspect complete CSA observations by wave
	tab					wave csa_complete, missing				
							
* inspect CSA indicator availability by wave
	tabstat				csa_irr csa_seed ///
							csa_soil csa_cons, ///
							by(wave) ///
							statistics(n mean min max)				
							
* count observations with three comparable CSA indicators
	egen				csa_pca3_n = ///
							rownonmiss(csa_irr csa_seed csa_soil)

	tab					wave csa_pca3_n, missing
							
					
************************************************************************
**# 7 - estimate data-driven csa index
************************************************************************

* estimate first principal component using complete CSA observations
	pca				csa_irr csa_seed ///
							csa_soil csa_cons ///
							if csa_complete == 1, ///
							components(1)
							
* inspect correlations among complete CSA indicators
	pwcorr				csa_irr csa_seed ///
							csa_soil csa_cons ///
							if csa_complete == 1, ///
							sig obs		
							
* re-estimate first principal component
	pca				csa_irr csa_seed ///
							csa_soil csa_cons ///
							if csa_complete == 1, ///
							components(1)

* generate data-driven CSA score
	predict				csa_pca_index ///
							if e(sample), score

	label variable		csa_pca_index ///
							"Data-driven CSA practice-pattern index"

* inspect PCA score by number of adopted practices
	tabstat				csa_pca_index, ///
							by(csa_count) ///
							statistics(n mean min max)				
							

************************************************************************
**# 8 - save final regression data
************************************************************************

* remove temporary diagnostic variable
	drop				csa_pca3_n

* confirm final field-level sample
	assert				_N == 75033

	isid				wave holder_id parcel_id field_id

* sort final regression data
	sort				wave holder_id parcel_id field_id

* save final regression data
	qui:				compress

	save				"$clean_data/ethiopia/eth_csa_regression", replace
							
							