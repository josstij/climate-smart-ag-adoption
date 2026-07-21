* Project: lsms gender
* Created on: june 2026
* Created by: ns
* Edited on: 8 July 2026
* Edited by: jdm
* Stata v.19.5

* does
	* appends wave 1 and wave 2 datasets and merges crop production data
	* outputs final appended data for regression analysis

* assumes
	* access to raw data
		
* TO DO
	* need to merge


************************************************************************
**# 0 - setup
************************************************************************

* define paths
	global			root 	"$data/lsms_gender_data/02-merged_data/niger"
	global			lsms 	"$data/lsms_base/countries/niger"
	global			export 	"$data/lsms_gender_data/03-regression_data"
	global			logout 	"$data/lsms_gender_data/02-merged_data/niger/logs"

* open log
	cap		log		close
	log				using 	"$logout/ngr_appended", append


************************************************************************
**# 1 - append waves
************************************************************************

* append waves 1-2

	use				"$root/wave_1/demo_w1", clear

	append			using	"$root/wave_2/demo_w2", force


************************************************************************
**# 2 - merge in production data
************************************************************************
	
* construct hh_id_merge
	gen				hh_id_merge = ""
	replace			hh_id_merge = string(hid) if wave == 1
	replace			hh_id_merge = string(grappe) + "-" + ///
						string(menage) + "-" + ///
								string(extension) if wave == 2

* construct parcel_id_merge
	gen				parcel_id_merge = ""
	replace			parcel_id_merge = hh_id_merge + "-" + ///
								string(field_id) 

* construct plot_id_merge
	gen				plot_id_merge = ""
	replace			plot_id_merge = parcel_id_merge + "-" + ///
								string(parcel_id)

* merge in production data
	merge			1:m 	wave plot_id_merge using ///
						"$lsms/ngr_allrounds_final_cp", gen(lsms_merge)

* Keep only matched observations and drop the merge variables
	keep			if		lsms_merge == 3
	drop			_merge lsms_merge
	order			field_id, before(parcel_id)
	
* save final merged file
	qui:			compress
	count
	
* Check for unique identifiers
	isid			plot_id_merge wave cropid
	save			"$export/ngr_allrounds", replace
	
* close the log
	log				close

/* END */