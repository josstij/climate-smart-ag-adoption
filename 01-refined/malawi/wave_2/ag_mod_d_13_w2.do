* Project: lsms gender dynamics
* Created on: march 2026
* Created by: jared sage
* Edited on: 3 March 2026
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
	global root 	"$data/raw_lsms_data/malawi/harmonized/wave_2"
	global export 	"$data/lsms_gender_data/01-refined_data/malawi/wave_2"
	global logout 	"$data/lsms_gender_data/01-refined_data/malawi/logs"
	
* open log 
	cap log close
	log using "$logout/ag_mod_d_13_w2", append

************************************************************************
**# 1 - clean data
************************************************************************

* load data
		use			"$root/ag_mod_d_13", clear

* rename variables
		rename			ag_d01 		mgmt1
		rename			ag_d01_2a	mgmt2
		rename			ag_d01_2b	mgmt3
		rename			ag_d03_2a	deju1
		rename			ag_d03_2b	deju2
		rename			ag_d04a		defa1
		rename			ag_d04b		defa2
		rename			ag_d04_2a	defa3
		rename			ag_d04_2b	defa4
		rename			ag_d00		plotid 
		
* keep essential variables
 		keep		y2_hhid plotid mgmt1 mgmt2 mgmt3 deju1 deju2 defa1 defa2 defa3 defa4
		
************************************************************************
**## 2 - fill in missing defa 1-4 (Waterfall logic) & deju 
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
	
* shift deju2 left
	replace		deju1 = deju2 if deju1 == .
	replace		deju2 = . if deju1 == deju2


************************************************************************
**# 3 - end matter
************************************************************************

* drop missing values 

	drop if 		missing(y2_hhid) | missing(plotid)
	isid 			y2_hhid plotid



* save file
	isid			y2_hhid plotid
	qui: 			compress
	save 			"$export/ag_mod_d_13_w2", replace
	
* close the log
	log	close

/* END */
 