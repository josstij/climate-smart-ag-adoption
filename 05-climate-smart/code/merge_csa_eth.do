* Project: lsms csa
* Created on: july 2026
* Created by: jt
* Edited on: july 2026
* Edited by: jt
* Stata v.19.5

* does
	* inspects the existing appended Ethiopia dataset
	* checks whether CSA and Ethiopia data share field-level identifiers
	* prepares for merging five-wave CSA outcomes with manager and land variables
	
* assumes
	* csa_allwaves.dta has been created
	* eth_allrounds.dta exists in the AIDE Lab regression-data folder
	* wave, holder_id, parcel_id, and field_id identify agricultural fields
	
* TO DO:
	* inspect identifiers
	* determine appropriate merge structure
	* merge CSA outcomes with existing Ethiopia data
	* check merge results
	* save final analysis dataset
	
	
************************************************************************
**# 0 - setup
************************************************************************

* load project setup
	do		"C:/Users/tijer/git/UROC/climate-smart-ag-adoption/05-climate-smart/code/00_setup.do"


************************************************************************
**# 1 - inspect existing Ethiopia data
************************************************************************

* load existing appended Ethiopia data
	use			"$eth_allrounds", clear

* inspect identifiers
	describe	wave holder_id parcel_id field_id

* check observations by wave
	tab			wave, missing

* check uniqueness at the field-wave level
	cap		isid		wave holder_id parcel_id field_id

* display uniqueness result
	if _rc == 0 {
		display	as result	"Field-wave identifiers are unique."
	}
	else {
		display	as error	"Field-wave identifiers are not unique."
		duplicates	report wave holder_id parcel_id field_id
	}
	
	
************************************************************************
**# 2 - merge CSA outcomes
************************************************************************

* define paths
	global	root		"$clean_data/ethiopia"
	global	export		"$clean_data/ethiopia"
	global	logout		"$cs_logs"

* open log
	cap		log			close
	log		using		"$logout/merge_csa_eth", append

* merge CSA outcomes into existing Ethiopia data
	merge		1:1 wave holder_id parcel_id field_id ///
				using "$root/csa_allwaves", ///
				keepusing(csa_irr csa_seed csa_soil csa_cons ///
				csa_n_obs csa_count_obs any_csa ///
				csa_complete csa_count any_csa_complete) ///
				generate(merge_csa)

* check overall merge results
	tab			merge_csa

* check merge results within each wave
	tab			wave merge_csa, missing
	
	
************************************************************************
**# 3 - inspect Wave 1 identifier mismatch
************************************************************************

* inspect identifier lengths
	gen			holder_length = strlen(holder_id)

	tab			holder_length merge_csa ///
				if wave == 1, missing

* inspect examples from existing Ethiopia data only
	list		holder_id parcel_id field_id ///
				if wave == 1 & merge_csa == 1 ///
				in 1/20, clean noobs

* inspect examples from CSA data only
	list		holder_id parcel_id field_id ///
				if wave == 1 & merge_csa == 2 ///
				in 1/20, clean noobs

* inspect matched Wave 1 examples
	list		holder_id parcel_id field_id ///
				if wave == 1 & merge_csa == 3 ///
				in 1/20, clean noobs
				
				
************************************************************************
**# 3 - define analysis sample
************************************************************************

* check outcome availability among matched observations
	tabstat		any_csa csa_count_obs csa_complete ///
				if merge_csa == 3, ///
				by(wave) statistics(n mean)

* retain observations with Ethiopia and CSA information
	keep		if merge_csa == 3

* confirm analysis identifiers are unique
	isid		wave holder_id parcel_id field_id

* check final sample by wave
	tab			wave, missing

* check total analysis sample
	count
	

************************************************************************
**# 4 - save analysis data
************************************************************************

* remove CSA merge indicator
	drop		merge_csa

* sort analysis data
	sort		wave holder_id parcel_id field_id

* label dataset
	label		data ///
				"Ethiopia CSA adoption analysis data, waves 1-5"

* save final analysis data
	save		"$export/eth_csa_analysis", replace

* close log
	log			close
	
	