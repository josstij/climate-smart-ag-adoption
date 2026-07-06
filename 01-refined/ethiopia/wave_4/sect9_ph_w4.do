* Project: lsms gender
* Created on: oct 2025
* Created by: jt
* Edited on: 10 nov 2025
* Edited by: jt
* Stata v.19.5

* does
	* inputs wave4 data set from post harvest survey
	* cleans up gendered field user
	* outputs file containing field user
		
* assumes
	* access to raw data 

* TO DO:
	* DONE !!

	
************************************************************************
**# 0 - setup
************************************************************************

* define paths
	global	root 	"$data/raw_lsms_data/ethiopia/wave_4/raw"
	global 	export 	"$data/lsms_gender_data/01-refined_data/ethiopia/wave_4"
	global 	logout	"$data/lsms_gender_data/01-refined_data/ethiopia/logs"
	
* open log 
	cap 	log 	close
	log 	using 	"$logout/sect9_ph_w4", append

	
************************************************************************
**# 1 - clean data
************************************************************************

* load data
		use			"$root/sect9_ph_w4", clear

* rename variables
	rename		(s9q09_1 s9q09_2 crop_id s9q00b) ///
					( use1 use2 crop_code crop_name)


* keep essential variables
	keep		holder_id household_id ea_id ///
					parcel_id field_id crop_code use1 use2 crop_name

		
************************************************************************
**# 2 - end matter
************************************************************************

* save file
	duplicates 		drop
	qui: 			compress
	isid			holder_id parcel_id field_id crop_code
	save 			"$export/sect9_ph_w3", replace
	
* close the log
	log	close

/* END */