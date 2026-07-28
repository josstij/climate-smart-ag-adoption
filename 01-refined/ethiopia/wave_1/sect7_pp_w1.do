* Project: lsms gender
* Created on: july 2026
* Created by: jt
* Edited on: 2y juy 2026
* Edited by: jt
* Stata v.19.5

* does
	* inputs wave1 dataset for post planting parcel ownership data
	* cleans up gendered parcel owner variables 
	* outputs file containing defacto owners, dejure owners, tenure
	* no collat, own1, own2, beqth
		
* assumes
	* access to raw data 

* TO DO:
	* DONE !!
	

************************************************************************
**# 0 - setup
************************************************************************

* define paths
	global	root 	"$data/raw_lsms_data/ethiopia/wave_1/raw"
	global	export 	"$data/lsms_gender_data/01-refined_data/ethiopia/wave_1"
	global	logout 	"$data/lsms_gender_data/01-refined_data/ethiopia/logs"
	
* open log 
	cap		log		close
	log		using	"$logout/sect7_pp_w1", append
	

************************************************************************
**# 1 - inspect data
************************************************************************

* load data
	use			"$root/sect7_pp_w1", clear

* confirm observation level
	isid			holder_id

* inspect selected questions
	codebook		pp_s7q04 pp_s7q05 ///
					pp_s7q06 pp_s7q07 ///
					pp_s7q08 pp_s7q09

* inspect response distributions
	tab				pp_s7q04, missing
	tab				pp_s7q06, missing
	tab				pp_s7q08, missing

* create credit-access barrier
	gen			no_credit = .
	replace		no_credit = 0 if pp_s7q06 == 1
	replace		no_credit = 1 if pp_s7q06 == 2

* label variable
	lab var		no_credit "does not receive credit services"

* label values
	lab define	barrier01 ///
					0 "no barrier" ///
					1 "barrier", replace

	lab values	no_credit barrier01
	
* create extension-program barrier
	gen			no_extension = .
	replace		no_extension = 0 if pp_s7q04 == 1
	replace		no_extension = 1 if pp_s7q04 == 2

* label variable
	lab var		no_extension "does not participate in extension program"

* apply barrier value label
	lab values	no_extension barrier01
	
* create advisory-services barrier
	gen			no_advisory = .
	replace		no_advisory = 0 if pp_s7q08 == 1
	replace		no_advisory = 1 if pp_s7q08 == 2

* label variable
	lab var		no_advisory "does not receive advisory services"

* apply barrier value label
	lab values	no_advisory barrier01
	
* keep essential variables
	keep			holder_id household_id ea_id ///
					no_credit no_extension no_advisory
					
					
************************************************************************
**# 2 - end matter
************************************************************************

* save file
	qui: 			compress
	isid			holder_id
	save 			"$export/sect7_pp_w1", replace
	
* close the log
	log	close

/* END */