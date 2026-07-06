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
	use			"$root/GSEC8_1", clear
	
*rename 
	rename		HHID	hhid
	rename		PID		indiv
	rename		h8q2	respond
	rename		h8q4	wage
	rename		h8q6	nfe
	rename		h8q12	farm

* keep variables
	keep		hhid indiv respond wage nfe farm
	
* order variables
	order		hhid indiv respond wage nfe farm
	
	
************************************************************************
**# 2 - end matter
************************************************************************	
	
* save file
	qui: 		compress
	isid		hhid indiv
	save 		"$export/GSEC8_w4", replace