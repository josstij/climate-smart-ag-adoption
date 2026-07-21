* Project: lsms gender
* Created on: oct 2025
* Created by: jt
* Edited on: 7 april 2026
* Edited by: jt
* Stata v.19.5

* does
	* inputs wave4 dataset for post planting field mgmt
	* cleans up gendered field mgmt variables 
	* outputs file containing field mgmt
		
* assumes
	* access to raw data 

* TO DO:
	* DONE !!
	

************************************************************************
**# 0 - setup
************************************************************************

* define paths
	global	root 	"$data/raw_lsms_data/ethiopia/wave_4/raw"
	global	export 	"$data/lsms_gender_data/01-refined_data/ethiopia/wave_4"
	global	logout 	"$data/lsms_gender_data/01-refined_data/ethiopia/logs"
	
* open log 
	cap		log		close
	log		using	"$logout/sect3_pp_w4", append
	

************************************************************************
**# 1 - clean data
************************************************************************

* load data
		use			"$root/sect3_pp_w4", clear

* rename variables
	rename		(s3q13 s3q15_1 s3q15_2) ///
					(mgmt2 mgmt3 mgmt4)

* recode yes no
	lab			define yesno 0 "no" 1 "yes"
/*	
* Note to self: the two functions below do the same thing, second one is a loop
	replace		collat	= 0 if	collat == 2
	replace		title	= 0 if	title == 2
	replace		beqth	= 0 if	beqth == 2
	
	lab			value collat yesno
	lab			value title yesno
	lab			value beqth yesno
	
*/
	
/*
	local		ctb collat title beqth
	
	foreach 		v of varlist `ctb' {
		replace			`v' = 0 if `v' == 2
		lab				value `v' yesno 
	}
*/

* keep essential variables
 	keep		holder_id household_id parcel_id field_id mgmt*

		
************************************************************************
**# 2 - end matter
************************************************************************

* save file
	qui: 			compress
	isid			holder_id parcel_id field_id
	save 			"$export/sect3_pp_w4", replace
	
* close the log
	log	close

/* END */