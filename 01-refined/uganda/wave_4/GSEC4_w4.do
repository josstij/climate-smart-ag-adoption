* Project: lsms-gender
* Created on: Feb 26
* Created by: ns
* Edited by: ns
* Edited on: 5 Feb 26
* Stata v.19.5


* Does
	* cleans uganda wave 4
	
* Needs
	* access to raw data
	
	
************************************************************************
**# 0 - setup
************************************************************************

* define paths
	global		root	"$data/raw_lsms_data/uganda/wave_4/raw/hh"
	global		export	"$data/lsms_gender_data/01-refined_data/uganda/wave_4"
	global		logout	"$data/lsms_gender_data/01-refined_data/uganda/logs"
	
* open log 
	cap			log		close
	log			using	"$logout/GSEC4_W4", append
	
	
************************************************************************
**# 1 - clean data
************************************************************************

* load data
	use			"$root/GSEC4", clear
	
* rename variables
	rename 		HHID	hhid
	rename		PID		indiv
	rename		h4q5	attd
	rename		h4q7	edu
	
* keep variables
	keep 		hhid attd indiv edu
	
*order 
	order		hhid indiv attd edu
	

************************************************************************
**# 2 - end matter
************************************************************************	
	
* save file
	qui: 		compress
	isid		hhid indiv
	save 		"$export/GSEC4_w4", replace
	
		