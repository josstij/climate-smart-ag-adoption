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
							
							
							
							
							
							
							
							
							
							
							
							
							
							
							
							
							
							
							
							
							
							
							
							
							
							
							
							
							
							
							
							
							
							
							
							
							
							
							
							