* Project: lsms gender
* Created on: oct 2025
* Created by: jt
* Edited on: 23 oct 2025
* Edited by: jt
* Stata v.19.5

* does
	* inputs wave3 dataset for post planting field mgmt data
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
	global	root 	"$data/raw_lsms_data/ethiopia/wave_3/raw"
	global	export 	"$data/lsms_gender_data/01-refined_data/ethiopia/wave_3"
	global	logout 	"$data/lsms_gender_data/01-refined_data/ethiopia/logs"
	
* open log 
	cap		log		close
	log		using	"$logout/sect3_pp_w3", append
	

************************************************************************
**# 1 - clean data
************************************************************************

* load data
		use			"$root/sect3_pp_w3", clear

* rename variables
	rename		(pp_s3q10a pp_s3q10c_a pp_s3q10c_b ) ///
					(mgmt2 mgmt3 mgmt4 )
	
* keep essential variables
 	keep		holder_id household_id household_id2 ea_id parcel_id field_id ///
				mgmt*
					

		
************************************************************************
**# 2 - end matter
************************************************************************

* save file
	qui: 			compress
	isid			holder_id parcel_id field_id
	save 			"$export/sect3_pp_w3", replace
	
* close the log
	log	close

/* END */