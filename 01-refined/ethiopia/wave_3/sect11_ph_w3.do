* Project: lsms gender
* Created on: oct 2025
* Created by: jt
* Edited on: 24 nov 2025
* Edited by: jt
* Stata v.19.5

* does
	* inputs wave3 dataset for post harvest field seller and money mgmt info
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
	global	root 	"$data/raw_lsms_data/ethiopia/wave_3/raw"
	global 	export 	"$data/lsms_gender_data/01-refined_data/ethiopia/wave_3"
	global 	logout	"$data/lsms_gender_data/01-refined_data/ethiopia/logs"
	
* open log 
	cap 	log 	close
	log 	using 	"$logout/sect11_ph_w3", append

	
************************************************************************
**# 1 - clean data
************************************************************************

* load data
		use			"$root/sect11_ph_w3", clear

* rename variables
	rename		(ph_s11q01 ph_s11q05_a ph_s11q05_b) ///
					(sell monman1 monman2)

* drop duplicates
	duplicates drop household_id holder_id crop_code, force
	
	
* keep essential variables
 	keep		holder_id household_id household_id2 ea_id sell ///
					monman1 monman2 crop_code crop_name 


************************************************************************
**# 2 - end matter
************************************************************************

* save file
	qui: 			compress
	isid			household_id holder_id crop_code
	save 			"$export/sect11_ph_w3", replace
	
* close the log
	log	close

/* END */