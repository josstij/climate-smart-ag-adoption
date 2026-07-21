* Project: lsms-gender
* Created on: Feb 6 
* Created by: sage
* Edited on: 6 Feb 26
* Stata v.19.5


* Does
	* Merges Data
	 
* Needs
	* access to refined data 
	
*To Merge



************************************************************************
**# 0 - setup
************************************************************************

* define paths
	global		root	"$data/lsms_gender_data/01-refined_data/uganda/wave_7"
	global		export	"$data/lsms_gender_data/02-merged_data/uganda/wave_7"
	global		logout	"$data/lsms_gender_data/02-merged_data/uganda/logs"
	
* open log
	cap			log		close
	log			using	"$logout/uganda_merged_w7", append
	
	

************************************************************************
**# 1 - merge individual characteristics
************************************************************************

* load individual roster	
	use			"$root/GSEC2_W7", clear
	
	
* check unique id
	isid		hhid indiv
	
* merge edu	
	merge 1:1 hhid indiv using "$root/GSEC4_W7"
	
* replace edu for 5+
	replace 	edu = 0 if edu == . & age > 4 & _merge == 1
	
	drop		_merge
	
* merge labor
	merge 1:1 hhid indiv using "$root/GSEC8_W7"
	
* replace work for 5+
	replace 	wage = 0 if wage == . & age > 4 & _merge == 1
	replace 	farm = 0 if farm == . & age > 4 & _merge == 1
	replace 	nfe = 0 if nfe == . & age > 4 & _merge == 1
	
	drop		_merge
	
* save file
	qui: 		compress
	isid		hhid indiv
	save 		"$export/indiv_demo", replace
	
	