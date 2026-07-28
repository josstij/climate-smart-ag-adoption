* Project: lsms gender
* Created on: 3 nov 2025
* Created by: jt
* Edited on: 27 july 2026
* Edited by: jt
* Stata v.19.5

* does
	* inputs wave4 dataset for hh indv communication data
	* cleans up indv lvl variables 
	* outputs file containing communication
		
* assumes
	* access to raw data 

* TO DO:
	* DONE !!
	

************************************************************************
**# 0 - setup
************************************************************************

* define paths
	global	root 	"$data/raw_lsms_data/ethiopia/wave_5/raw"
	global	export 	"$data/lsms_gender_data/01-refined_data/ethiopia/wave_5"
	global	logout 	"$data/lsms_gender_data/01-refined_data/ethiopia/logs"
	
* open log 
	cap		log		close
	log		using	"$logout/sect11_hh_w5", append
	

************************************************************************
**# 1 - clean data
************************************************************************

* load wave 5 household-assets data
	use			"$root/sect11_hh_w5", clear

* inspect identifiers and asset variables
	describe	household_id ea_id asset_cd

* locate ownership variable
	lookfor		how many
	lookfor		household own
	lookfor		telephone mobile radio
	
* inspect wave 5 asset codes and ownership responses
	codebook	asset_cd s11q00 s11q01

	tab			asset_cd, missing
	
* inspect wave 5 mobile-phone module
	use			"$root/sect11b1_hh_w5", clear

	describe	household_id individual_id
	lookfor		mobile
	lookfor		phone
	
* inspect mobile-phone ownership responses
	isid		household_id individual_id

	codebook	s11b_ind_01
	tab			s11b_ind_01, missing
	
* create individual mobile-phone ownership indicator
	gen			mobile_owner = .
	replace		mobile_owner = 1 if s11b_ind_01 == 1
	replace		mobile_owner = 0 if s11b_ind_01 == 2

* identify whether anyone in household owns a mobile phone
	bysort		household_id: ///
		egen	any_mobile = max(mobile_owner)

* verify construction once per household
	egen		hh_tag = tag(household_id)

	tab			s11b_ind_01 mobile_owner, missing
	tab			any_mobile if hh_tag, missing

* retain one household-level record
	bysort		household_id: ///
		keep	if _n == 1

* keep essential variables
	keep		household_id any_mobile

* confirm household-level uniqueness
	isid		household_id

* save household mobile indicator
	qui:		compress
	save		"$export/sect11b1_hh_w5", replace
	
* reload main household-assets file
	use			"$root/sect11_hh_w5", clear

* inspect fixed telephone and radio ownership
	tab			asset_cd s11q00 ///
					if inlist(asset_cd, 7, 8), missing
					
* identify fixed-phone or radio ownership
	gen			fixed_radio = .
	replace		fixed_radio = 1 if s11q00 == 1 & ///
					inlist(asset_cd, 7, 8)
	replace		fixed_radio = 0 if s11q00 == 2 & ///
					inlist(asset_cd, 7, 8)

* identify whether household owns either asset
	bysort		household_id: ///
		egen	any_fixed_radio = max(fixed_radio)

* verify once per household
	egen		hh_tag = tag(household_id)

	tab			any_fixed_radio if hh_tag, missing
	
* retain one household-level asset record
	keep		if inlist(asset_cd, 7, 8)

	bysort		household_id: ///
		keep	if _n == 1

	keep		household_id ea_id any_fixed_radio

* merge household mobile-phone ownership
	merge		1:1 household_id ///
					using "$export/sect11b1_hh_w5"

* inspect merge results
	tab			_merge, missing
	tab			any_mobile, missing
	
* create combined communication-access indicator
	gen			any_communication = .
	replace		any_communication = 1 if ///
					any_fixed_radio == 1 | any_mobile == 1
	replace		any_communication = 0 if ///
					any_fixed_radio == 0 & any_mobile == 0

* create communication-access barrier
	gen			no_communication = .
	replace		no_communication = 0 if any_communication == 1
	replace		no_communication = 1 if any_communication == 0

* label variables
	lab var		any_communication ///
					"household owns fixed telephone, radio, or mobile phone"
	lab var		no_communication ///
					"household owns no fixed telephone, radio, or mobile phone"

	lab define	barrier01 ///
					0 "no barrier" ///
					1 "barrier", replace

	lab values	no_communication barrier01

* verify combined measure
	tab			any_communication, missing
	tab			no_communication, missing
	
* remove merge indicator
	drop		_merge

* keep essential variables
	keep		household_id ea_id ///
				any_fixed_radio any_mobile ///
				any_communication no_communication


************************************************************************
**# 2 - end matter
************************************************************************

* save file
	qui:		compress
	isid		household_id
	save		"$export/sect11_hh_w5", replace
	
	