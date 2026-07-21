* Project: lsms gender
* Created on: April 1 2026
* Created by: ns
* Edited on: 20 April 2026
* Edited by: ns,js
* Stata v.18.5


************************************************************************
**# 0 - setup
************************************************************************

* define paths
	global 		root 	"$data/lsms_gender_data/02-merged_data/malawi"
	global 		lsms 	"$data/lsms_base/countries/malawi"
	global 		export 	"$data/lsms_gender_data/03-regression_data"
	global 		logout 	"$data/lsms_gender_data/02-merged_data/malawi/logs"	 

* open log 
	cap 		log 	close
	log 		using 	"$logout/mwi_append", append
	
	
************************************************************************
**# 1 - append waves
************************************************************************

* append waves 1-4

	use			"$root/wave_1/demo_w1", clear


	append		using 	"$root/wave_2/demo_w2" ///
						"$root/wave_3/demo_w3" ///
						"$root/wave_4/demo_w4"


************************************************************************
**# 2 - merge in production data
************************************************************************

* fill missing gardenid for waves 1-2 (plot-level, no gardens)
	replace		gardenid = "RG01" if gardenid == ""

* end matter
	order		wave hhid gardenid plotid 

* save final merged file
	qui: 		compress
	count
	isid 		hhid plotid gardenid wave
	save 		"$export/mal_allrounds", replace
	
* close the log
	log			close

/* END */