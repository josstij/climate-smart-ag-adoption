* Project: lsms gender
* Created on: 3 nov 2025
* Created by: jt
* Edited on: 27 july 2026
* Edited by: jt
* Stata v.19.5

* does
	* inputs wave 5 household asset data
	* constructs household fixed-telephone or radio ownership
	* outputs one observation per household
		
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

	tab			asset_cd s11q00 ///
					if inlist(asset_cd, 7, 8), missing
	tab			any_fixed_radio if hh_tag, missing

* retain one household-level asset record
	keep		if inlist(asset_cd, 7, 8)

	bysort		household_id: ///
		keep	if _n == 1

* label household asset indicator
	lab var		any_fixed_radio ///
					"household owns fixed telephone or radio"

* keep essential variables
	keep		household_id ea_id any_fixed_radio


************************************************************************
**# 2 - end matter
************************************************************************

* save file
	qui:		compress
	isid		household_id
	save		"$export/sect11_hh_w5", replace

* close the log
	log		close

/* END */