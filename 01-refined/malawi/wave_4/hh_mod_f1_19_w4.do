* Project: lsms gender dynamics
* Created on: march 2026
* Created by: jared sage, ns
* Edited on: 20 april 2026
* Edited by: jared
* Stata v.19.5

* does
		* cleans dataset for 2010 ag panel
		* cleans up gendered plot variables 
		
* assumes
	* access to raw data 

* TO DO:
	* done!

************************************************************************
**# 0 - setup
************************************************************************

* define paths
	global root 	"$data/raw_lsms_data/malawi/harmonized/wave_4"
	global export 	"$data/lsms_gender_data/01-refined_data/malawi/wave_4"
	global logout 	"$data/lsms_gender_data/01-refined_data/malawi/logs"
	
* open log 
	cap log close
	log using 		"$logout/hh_mod_f1_19_w4", append

************************************************************************
**# 1 - clean data
************************************************************************

* load data
		use			"$root/hh_mod_f1_19", clear

* rename variables
		gen			tenure = hh_f103
		
		gen 		deju1 = hh_f108_id1_doc_1 if tenure == 4
		gen 		deju2 = hh_f108_id2_doc_1 if tenure == 4
		gen 		deju3 = hh_f108_id3_doc_1 if tenure == 4
		gen 		deju4 = hh_f108_id4_doc_1 if tenure == 4
		gen 		defa1 = hh_f106_1
		gen 		defa2 = hh_f106_2
		gen 		defa3 = hh_f106_3
		gen 		defa4 = hh_f106_4
		
* label values
	lab var			tenure	"How was this plot aquired"
	lab var			deju1	"de jure owner 1"	
	lab var			deju2	"de jure owner 2"	
	lab var			deju3	"de jure owner 3"	
	lab var			deju4	"de jure owner 4"	
	
	forvalues i = 1/4 {
		lab var		defa`i' "Who in hh has the right to sell this [PLOT] or use it as collateral?"
	}		
		
* Clean IDs and force numeric type
	forvalues i = 1/4 {
		* replace ID 0 with missing since no indiv = 0
		replace 	deju`i' = . if deju`i' == 0
		replace 	defa`i' = . if defa`i' == 0
		
		* force numeric type to prevent string/numeric merge crashes
		*cap destring deju`i', replace
		cap destring defa`i', replace
	}
	
	
************************************************************************
**## 2.1 - fill in missing deju 1-4 (Waterfall logic)
************************************************************************

* shift deju2 left
	replace		deju1 = deju2 if deju1 == .
	replace		deju2 = . if deju1 == deju2

* shift deju3 left
	replace		deju1 = deju3 if deju1 == .
	replace		deju3 = . if deju1 == deju3
	replace		deju2 = deju3 if deju2 == .
	replace		deju3 = . if deju2 == deju3

* shift deju4 left
	replace		deju1 = deju4 if deju1 == .
	replace		deju4 = . if deju1 == deju4
	replace		deju2 = deju4 if deju2 == .
	replace		deju4 = . if deju2 == deju4
	replace		deju3 = deju4 if deju3 == .
	replace		deju4 = . if deju3 == deju4

	
************************************************************************
**## 2.2 - fill in missing defa 1-4 (Waterfall logic)
************************************************************************

* shift defa2 left
	replace		defa1 = defa2 if defa1 == .
	replace		defa2 = . if defa1 == defa2

* shift defa3 left
	replace		defa1 = defa3 if defa1 == .
	replace		defa3 = . if defa1 == defa3
	replace		defa2 = defa3 if defa2 == .
	replace		defa3 = . if defa2 == defa3

* shift defa4 left
	replace		defa1 = defa4 if defa1 == .
	replace		defa4 = . if defa1 == defa4
	replace		defa2 = defa4 if defa2 == .
	replace		defa4 = . if defa2 == defa4
	replace		defa3 = defa4 if defa3 == .
	replace		defa4 = . if defa3 == defa4		
	
* Drop plots that have literally no manager listed at all
	drop if 	missing(defa1) & missing(defa2) & missing(defa3) & missing(defa4)
		
* keep essential variables
	keep		y4_hhid gardenid tenure deju1 deju2 deju3 deju4 defa1 defa2 defa3 defa4

	
************************************************************************
**# 2 - end matter
************************************************************************

* drop missing variables
	drop if 		missing(y4_hhid) | missing(gardenid)
	
* save file
	isid			y4_hhid gardenid
	qui: 			compress
	save 			"$export/hh_mod_f1_19_w4", replace
	
* close the log
	log	close

/* END */
