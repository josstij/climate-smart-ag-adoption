* Project: lsms gender
* Created on: mar 2025
* Created by: ns
* Edited on: 24 mar 2025
* Edited by: ns
* Stata v.18.5

* does
		* merges all waves 
		
* assumes
		* access to merged data 
		
* TO DO
		* need to merge
		

************************************************************************
**# 0 - setup
************************************************************************

* define paths
	global 		root 	"$data/lsms_gender_data/02-merged_data/nigeria"
	global 		lsms 	"$data/lsms_base/countries/nigeria"
	global 		export 	"$data/lsms_gender_data/03-regression_data"
	global 		logout 	"$data/lsms_gender_data/02-merged_data/nigeria/logs"	 

* open log 
	cap 		log 	close
	log 		using 	"$logout/nga_appended", append
	
	
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
	
* Convert all three key variables to string
    tostring	hhid, gen(hh_id_merge)
    tostring 	plotid, gen(plot_id_merge)
    
* Reconstruct the Plot ID to match master format (HHID-PLOT)
    replace 	plot_id_merge = hh_id_merge + "-" + plot_id_merge

* merge in production data
	merge 1:m 	wave plot_id_merge using ///
					"$lsms/nga_allrounds_final_cp", gen(lsms_merge)
	*** 50,926 matched, 743 unmatched from master, 1,284 unmatched from using
	
	keep if		lsms_merge == 3
	drop		_merge lsms_merge
	
* save final merged file
	qui: 		compress
	count
	isid 		hhid plotid wave cropid
	save 		"$export/nga_allrounds", replace	
	
* close the log
	log			close

/* END */	
	