* Project: lsms gender
* Created on: feb 2026
* Created by: ns
* Edited on: 6 feb 2026
* Edited by: ns
* Stata v.18.5

* does
		* merges data for wave 4
		
* assumes
		* access to refined data 
		
* TO DO
		* need to merge
		
		
************************************************************************
**# 0 - setup
************************************************************************

* define paths
	global		root	"$data/lsms_gender_data/01-refined_data/uganda/wave_4"
	global		export	"$data/lsms_gender_data/02-merged_data/uganda/wave_4"
	global		logout	"$data/lsms_gender_data/02-merged_data/uganda/logs"
	
* open log 
	cap			log		close
	log			using	"$logout/uganda_merged_w4", append
	
	

************************************************************************
**# 1 - merge individual characteristics 
************************************************************************

* load individual roster	
	use			"$root/GSEC2_w4", clear
	
	
* check unique id
	isid		hhid indiv
	
* merge edu	
	merge 1:1 hhid indiv using "$root/GSEC4_w4"
	
* replace edu for 5+
	replace 	edu = 0 if edu == . & age > 4 & _merge == 1
	
	drop		_merge
	
* merge labor
	merge 1:1 hhid indiv using "$root/GSEC8_w4"
	
* replace work for 5+
	replace 	wage = 0 if wage == . & age > 4 & _merge == 1
	replace 	farm = 0 if farm == . & age > 4 & _merge == 1
	replace 	nfe = 0 if nfe == . & age > 4 & _merge == 1
	
	drop		_merge
	
* save file
	qui: 		compress
	isid		hhid indiv
	save 		"$export/indiv_demo", replace
