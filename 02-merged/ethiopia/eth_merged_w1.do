* Project: lsms gender
* Created on: dec 2025
* Created by: jt
* Edited on: 1 april 2026
* Edited by: jt
* Stata v.18.5

* does
		* merges data for wave 1
		* monman is at crop level, stored in a seperate file
		
* assumes
		* access to refined data 
		
* TO DO
		* DONE !!
		

************************************************************************
**# 0 - setup
************************************************************************

* define paths
	global 		root 	"$data/lsms_gender_data/01-refined_data/ethiopia/wave_1"
	global 		export 	"$data/lsms_gender_data/02-merged_data/ethiopia/wave_1"
	global 		export1 "$data/lsms_gender_data/01-refined_data/ethiopia/wave_1"
	global 		logout 	"$data/lsms_gender_data/02-merged_data/ethiopia/logs"	
***	loc 		weight	= 	"$data/household_data/ethiopia/wave_3/raw"  


* open log 
	cap 		log 	close
	log 		using 	"$logout/eth_merged_w1", append
	

************************************************************************
**# 1 - merge individual characteristics 
************************************************************************

* load individual roster
	use			"$root/sect1_hh_w1", clear
	
* check unique id
	isid		household_id individual_id
	
* merge edu
	merge 1:1 	household_id individual_id using "$root/sect2_hh_w1"
	*** 18,865 matched, 1 not matched, all from using
	
	drop		_merge
	
* merge work
	merge 1:1 	household_id individual_id using "$root/sect4_hh_w1"
	*** 18,864 matched, 2 not matched, all from master
	
	drop		_merge
	
* save file
	qui: 		compress
	isid		household_id individual_id 
	save 		"$root/indiv_demo", replace

	
************************************************************************
**# 2 - merge individual characteristics into ag files
************************************************************************


************************************************************************
**## 2.1 - merge manager and dejure (sect2_pp_w1)
************************************************************************

************************************************************************
**### 2.1.1 - merge manager 1 with demo - parcel
************************************************************************

* load individual roster
	use			"$root/indiv_demo", clear

* change indiv to mgmt1
	gen			mgmt1 = indiv_num

* merge each file for each money manager
	merge 1:m 	household_id mgmt1 using "$root/sect2_pp_w1"
	
* rename mgmt1 demo vars
	local 		demo relat sex age mrry away edu wage farm nfe
	
	foreach v of varlist `demo' {
		rename		`v' mg1_`v'
		} 	

* drop unsold crops			
	drop if 	_merge != 3
	
* drop not mg1 vars
	drop 		 title deju* _merge

	isid		parcel_id holder_id
	
* save as temp 
	tempfile	mgmt1
	save 		"`mgmt1'", replace
	
	
************************************************************************
**### 2.1.2 - merge deju 1 and 2 with demo - parcel
************************************************************************

* loop for deju 1-2
	forvalues	i = 1/2 {
		
* load individual roster
	use			"$root/indiv_demo", clear

*create deju1 ID
	gen			deju`i' = indiv_num
	
*merge each file for each deju
	merge 1:m 	household_id deju`i' using "$root/sect2_pp_w1"
	
* keep only matched observations
	keep if 	_merge == 3
	drop		_merge
	
* rename demographic variables to deju prefix
	local		demo relat sex age mrry away edu wage farm nfe
	
	foreach		v of varlist `demo' {
		rename	`v' dj`i'_`v'
		} 

* save temp file for deju`i'
	tempfile	deju`i'
	save		"`deju`i''", replace
	}

************************************************************************
**## 2.2 - merge monman (sect11_ph_w1)
************************************************************************

************************************************************************
**### 2.2.1 - merge monman1 and monman2 (section 11 ph)
************************************************************************

* loop for monman 1-2
	forvalues	i = 1/2 {
		
* load individual roster
	use			"$root/indiv_demo", clear

*create monman ID
	gen			monman`i' = indiv_num
	
*merge each file for each monman
	merge 1:m 	household_id monman`i' using "$export1/sect11_ph_w1"
	
* keep only matched observations
	keep if 	_merge == 3
	drop		_merge
	
* rename demographic variables to monman prefix
	local		demo relat sex age mrry away edu wage farm nfe
	
	foreach		v of varlist `demo' {
		rename	`v' mm`i'_`v'
		} 

	isid 		holder_id crop_code
		
* save temp file for monman`i'
	tempfile	monman`i'
	save		"`monman`i''", replace
	}	
	
************************************************************************
**# 3 - merge mgmt, deju, defa, monman together
************************************************************************
	
************************************************************************
**## 3.1 - merge mgmt1, deju1, deju2 together
************************************************************************

* load mgmt1
* need to run from top to get all pathways 
	use			"`mgmt1'", clear
	
	isid 		parcel_id holder_id
	
* merge deju1 to mgmt1
	merge 1:1 	parcel_id holder_id using "`deju1'"
	
* keep only matched observations
*	keep if		_merge == 3
	*** let's keep it all 
	drop 		_merge

* merge deju2 to merged dataset
	merge 1:1	parcel_id holder_id using "`deju2'"
	
* keep only matched obsevrations
*	keep if		_merge == 3
	drop		_merge
	
* check duplicates
	duplicates report parcel_id holder_id
	
* compress and save final merged file 
	qui:		compress
	isid		parcel_id holder_id
	save		"$export/demo_w1", replace

	
************************************************************************
**## 3.2 - merge monman1 to monman2
************************************************************************
/*
* load monman1
* need to run from top to get all pathways 
	use			"`monman1'", clear
	
	isid 		holder_id crop_code
	
* merge deju1 to mgmt1
	merge 1:1 	holder_id crop_code using "`monman2'"
	*** 21 using only obs should have only 1,638 
	
* keep only matched observations
*	keep if		_merge == 3
	*** let's keep it all 
	drop 		_merge
	
* file at crop level
* compress and save final merged file
	qui: 		compress	
	isid		holder_id crop_code
	save		"$export/mm_demo_w1", replace
*/
		
	
************************************************************************
**# 4 - end matter
************************************************************************

* close the log
	log	close

/* END */
	
	