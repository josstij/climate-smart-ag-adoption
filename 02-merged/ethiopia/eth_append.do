* Project: lsms gender
* Created on: july 2026
* Created by: jdm
* Edited on: 7 july 2026
* Edited by: jdm
* Stata v.19.5

* does
		* appends all waves 

* assumes
		* access to merged data 
		
* TO DO
		* done


************************************************************************
**# 0 - setup
************************************************************************

* define paths
	global 		root 	"$data/lsms_gender_data/02-merged_data/ethiopia"
	global 		export 	"$data/lsms_gender_data/03-regression_data"
	global 		logout 	"$data/lsms_gender_data/02-merged_data/ethiopia/logs"	 

* open log 
	cap 		log 	close
	log 		using 	"$logout/eth_append", append
	
	
************************************************************************
**# 1 - append waves
************************************************************************

* append waves 1-5

	use			"$root/wave_1/demo_w1", clear


	append		using 	"$root/wave_2/demo_w2" ///
						"$root/wave_3/demo_w3" ///
						"$root/wave_4/demo_w4" ///
						"$root/wave_5/demo_w5", force


************************************************************************
**# 2 - end matter
************************************************************************

* fill missing field_id for wave 1 (parcel-level, no fields)
	replace		field_id = 1 if field_id == .

* save final appended file
	qui: 		compress
	count
	isid 		holder_id parcel_id field_id wave
	save 		"$export/eth_allrounds", replace	
	
* close the log
	log			close

/* END */	
