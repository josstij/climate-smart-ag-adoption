* Project: lsms gender
* Created on: may 2026
* Created by: ns
* Edited on: 10 july 2026
* Edited by: jdm
* Stata v.19.5

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
	global			root 	"$data/lsms_gender_data/02-merged_data/tanzania"
	global			lsms 	"$data/lsms_base/countries/tanzania"
	global			export 	"$data/lsms_gender_data/03-regression_data"
	global			logout 	"$data/lsms_gender_data/02-merged_data/tanzania/logs"

* open log
	cap		log		close
	log				using 	"$logout/tza_appended", append


************************************************************************
**# 1 - append waves
************************************************************************

* append waves 1-7
	use				"$root/wave_1/tza_merged_w1", clear

	append			using 	"$root/wave_2/tza_merged_w2" ///
						"$root/wave_3/tza_merged_w3" ///
						"$root/wave_4/tza_merged_w4" ///
						"$root/wave_5/tza_merged_w5" ///
						"$root/wave_6/tza_merged_w6" ///
						"$root/wave_7/tza_merged_w7"


************************************************************************
**# 2 - merge in production data
************************************************************************

* Construct the plot_id_merge variable to match the crop dataset
* This concatenates "1781-001" + "-" + "M1" -> "1781-001-M1"
	gen				plot_id_merge = hhid + "-" + plotnum



* merge in production data
	merge			1:m 	wave plot_id_merge using ///
						"$lsms/tza_allrounds_final_cp", gen(lsms_merge)

	keep			if		lsms_merge == 3
	drop			_merge lsms_merge

* save final merged file
	qui:			compress
	count
	isid			hhid plotnum wave cropid
	save			"$export/tza_allrounds", replace

* close the log
	log				close

/* END */


