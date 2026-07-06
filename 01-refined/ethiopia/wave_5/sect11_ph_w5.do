* Project: lsms gender
* Created on: oct 2025
* Created by: jt
* Edited on: 25 oct 2025
* Edited by: jt
* Stata v.19.5

* does
	* inputs wave5 dataset for post harvest field seller mrkt earn
	* cleans up gendered field seller mrkt earn variables 
	* outputs file containing field seller mrkt earn
		
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
	log		using	"$logout/sect11_ph_w5", append
	

************************************************************************
**# 1 - clean data
************************************************************************

* load data
		use			"$root/sect11_ph_w5", clear

* rename variables
	rename		(s11q07 s11q13_1 s11q13_2 s11q01b s11q00a) ///
					(sell monman1 monman2 crop_code crop_name)

* drop duplicates
	duplicates drop household_id holder_id crop_code, force
	
	
* keep essential variables
 	keep		holder_id household_id ea_id sell ///
					monman1 monman2 crop_code crop_name 
	
************************************************************************
**# 2 - end matter
************************************************************************

* save file
	qui: 			compress
	isid			household_id holder_id crop_code
	save 			"$export/sect11_ph_w5", replace
	
* close the log
*	log	close

/* END */
