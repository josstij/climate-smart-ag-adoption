* Project: lsms gender
* Created on: 7 april 2026
* Created by: jt
* Edited on: 7 april 2026
* Edited by: jt
* Stata v.18.5

* does
		* merges data for wave 3
		
		
* assumes
		* access to refined data 
		
* TO DO
		* DONE !!
		

************************************************************************
**# 0 - setup
************************************************************************

* define paths
	global 		root 	"$data/lsms_gender_data/01-refined_data/ethiopia/wave_4"
	global 		export 	"$data/lsms_gender_data/02-merged_data/ethiopia/wave_4"
	global 		logout 	"$data/lsms_gender_data/02-merged_data/ethiopia/logs"	

* open log 
	cap 		log 	close
	log 		using 	"$logout/eth_merged_w4", append
	

************************************************************************
**# 1 - merge individual characteristics 
************************************************************************

* load individual roster
	use			"$root/sect1_hh_w4", clear
	
* check unique id 
	isid		household_id individual_id
	
* merge edu
	merge 1:1 	household_id individual_id using "$root/sect2_hh_w4"
	*** 23,385 matched, 4,594 not matched from master
	
	drop		_merge
	
* merge work
	merge 1:1 	household_id individual_id using "$root/sect4_hh_w4"
	*** 23,393 matched, 4,597 not matched from master
	
	drop		_merge
	
* save file
	qui: 		compress
	isid		household_id individual_id
	save 		"$root/indiv_demo", replace

	
************************************************************************
**# 2 - merge mgmt + deju into ag files
************************************************************************

************************************************************************
**## 2.1 - merge mgmt and dejure (sect2_pp_w4) - parcel 
************************************************************************

************************************************************************
**### 2.1.1 - merge manager 1 - parcel
************************************************************************

* load individual roster
	use			"$root/indiv_demo", clear

* change indiv to mgmt1
	gen			mgmt1 = individual_id

* merge each file for each mgmt1
	merge 1:m 	household_id mgmt1 using "$root/sect2_pp_w4"
	*** only match 13765, not matched 22461 from master and 48 from using
	*** this is fine because we are JUST matching for manager 1, in s2_pp_w4
	*** there are 13765 + 48 managers
	
* rename mgmt1 demo vars	
	local 		demo relat sex age mrry away edu wage farm nfe
	
	foreach v of varlist `demo' {
		rename		`v' mg1_`v'
		} 	

* drop unsold crops			
	drop if 	_merge != 3
	*** 22,509 observations deleted
	
* drop not mg1 vars
	drop 		deju* _merge

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
	gen			deju`i' = individual_id
	
*merge each file for each deju
	merge 1:m 	household_id deju`i' using "$root/sect2_pp_w4"
	*** matched 2,512
	
* keep only matched observations
	keep if 	_merge == 3
	drop		_merge
	
* rename demographic variables to deju prefix
	local		demo relat sex age mrry away edu wage farm nfe
	
	foreach		v of varlist `demo' {
		rename	`v' deju`i'_`v'
		} 

	isid		parcel_id holder_id
	
* save temp file for deju`i'
	tempfile	deju`i'
	save		"`deju`i''", replace
	}


************************************************************************
**## 2.2 - merge mgmt (sect3_pp_w4) - field
************************************************************************

************************************************************************
**### 2.2.1 - merge manager 2 - 4 - field
************************************************************************

* loop for mgmt2-4
	forvalues	i = 2/4 {
		
* load individual roster
	use			"$root/indiv_demo", clear

*create mgmt ID
	gen			mgmt`i' = individual_id
	
*merge each file for each deju
	merge 1:m 	household_id mgmt`i' using "$root/sect3_pp_w4"
	*** matched 2,780
	
* keep only matched observations
	keep if 	_merge == 3
	drop		_merge
	
* rename demographic variables to deju prefix
	local		demo relat sex age mrry away edu wage farm nfe
	
	foreach		v of varlist `demo' {
		rename	`v' mgmt`i'_`v'
		} 

	isid		field_id parcel_id holder_id
	
* save temp file for deju`i'
	tempfile	mgmt`i'
	save		"`mgmt`i''", replace
	}


************************************************************************
**## 2.3 - merge monman (section 9 ph) - crop
************************************************************************
/*
* loop for monman 1-2
	forvalues	i = 1/2 {
		
* load individual roster
	use			"$root/indiv_demo", clear

*create monman ID
	gen			monman`i' = individual_id
	
*merge each file for each monman
	merge 1:m 	household_id monman`i' using "$export1/sect9_ph_w4"
	
* keep only matched observations
	keep if 	_merge == 3
	drop		_merge
	
* rename demographic variables to monman prefix
	local		demo relat sex age mrry away edu wage farm nfe
	
	foreach		v of varlist `demo' {
		rename	`v' monman`i'_`v'
		} 
		
	isid        holder_id household_id parcel_id field_id crop_code

* save temp file for monman`i'
	tempfile	monman`i'
	save		"`monman`i''", replace
	}	
	
*/

************************************************************************
**# 3 - merge mgmt, deju, defa, monman together
************************************************************************

************************************************************************
**## 3.1 - merge mgmt2-4 together
************************************************************************
	
* load mgmt2
* need to run from top to get all pathways 
	use			"`mgmt2'", clear
	
	isid		holder_id parcel_id field_id
	
* merge mgmt3 to mgmt2
	merge 1:1 	holder_id parcel_id field_id using "`mgmt3'"
	***

* keep matched and master observations
	drop if		_merge == 2

	drop 		_merge
	
* merge mgmt4 to mgmt3
	merge 1:1 	holder_id parcel_id field_id using "`mgmt4'"
	
* keep matched and master observations
	drop if		_merge == 2

	drop 		_merge
		
* compress and save for the final merged file 
	qui:		compress
	isid		parcel_id holder_id field_id
	
	tempfile	field 
	save 		"`field'", replace

	
************************************************************************
**## 3.2 - merge mgmt1, deju1, deju2 together
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
	
* compress for final merged file 
	qui:		compress
	isid		parcel_id holder_id 
	

************************************************************************
**## 3.3 - merge field and parcel together
************************************************************************
	
* merge parcel into field 	
	merge 1:m	 holder_id parcel_id using "`field'"
	***matched: 22,835, not matched: 4,073 from master, and 35 from using
	drop if 	_merge == 2
	
* for parcels missing fields give it an id of 1
	replace		field_id = 1 if field_id == .
	
* compress and save final merged file 
	qui:		compress
	isid		holder_id parcel_id field_id
	save		"$export/demo_w4", replace

************************************************************************
**## 3.4 - merge monman1 and monman2 together
************************************************************************
/*
* need to run from top to get all pathways 

	use			"`monman1'", clear
	
	isid 		household_id individual_id parcel_id holder_id
	
* merge cert1 to mgmt1
	merge 1:1 	household_id individual_id holder_id using "`monman2'"
	
* keep only matched observations
*	keep if		_merge == 3
	*** let's keep it all 
	drop 		_merge

* compress and save final merged file 
	qui:		compress
	isid		household_id individual_id parcel_id holder_id 
	save		"$export/mm_demo_w4", replace
*/
************************************************************************
**# 4 - end matter
************************************************************************

* close the log
	log	close

/* END */
	