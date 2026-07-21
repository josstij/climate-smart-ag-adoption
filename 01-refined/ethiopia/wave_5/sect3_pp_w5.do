* Project: lsms gender
* Created on: oct 2025
* Created by: jt
* Edited on: 25 oct 2025
* Edited by: jt
* Stata v.19.5

* does
	* inputs wave5 dataset for post planting field mgmt data
	* cleans up gendered field mgmt data variables 
	* outputs file containing field mgmt data
		
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
	log		using	"$logout/sect3_pp_w5", append
	

************************************************************************
**# 1 - clean data
************************************************************************

* load data
		use			"$root/sect3_pp_w5", clear

* rename variables
	rename		(s3q13 s3q15_1 s3q15_2) ///
					(mgmt2 mgmt3 mgmt4)

/*
* recode yes no
	replace		collat = 0 if collat == 2
	lab			define yesno 0 "no" 1 "yes"
	lab			value collat yesno
*/	

* keep essential variables
 	keep		holder_id household_id parcel_id field_id ea_id ///
				mgmt*

		
************************************************************************
**# 2 - end matter
************************************************************************

* save file
	qui: 			compress
	isid			holder_id household_id parcel_id field_id
	save 			"$export/sect3_pp_w5", replace
	
* close the log
	log	close

/* END */