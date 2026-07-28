* Project: lsms gender
* Created on: oct 2025
* Created by: jt
* Edited on: july 27 2026
* Edited by: jt
* Stata v.19.5

* does
	* inputs wave1 dataset for post harvest field seller and money mgmt info
	* cleans up gendered field seller and money mgmt variables 
	* outputs file containing seller and money mgmt data
		
		
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
	log		using	"$logout/sect11_ph_w1", append
	

************************************************************************
**# 1 - clean data
************************************************************************

* load data
		use			"$root/sect11_ph_w1", clear

* rename variables
	rename		(ph_s11q01 ph_s11q05_a ph_s11q05_b) ///
					(sell monman1 monman2)

* recode yes no
	replace		sell = 0 if sell == 2
	lab			define yesno 0 "no" 1 "yes"
	lab			value sell yesno
	
	replace		sell = 1 if monman1 != .
	*** replaced 6 if reports monman they sell crop
	
* replace missing monman1
	replace 	monman1 = monman2 if monman1 == . & monman2 != .
	*** replaced 35
	
* replace duplicate monman2
	replace		monman2 = . if monman1 == monman2
	*** replaced 61
	
* keep essential variables
	keep		holder_id household_id monman1 monman2 ///
				crop_name crop_code 

* drop missing values 
	keep if		monman1 != .
	*** 1,734 remain
	
		
************************************************************************
**# 2 - end matter
************************************************************************

* save file
	qui: 			compress
	isid			holder_id crop_code
	save 			"$export/sect11_ph_w1", replace
	
* close the log
	log	close

/* END */