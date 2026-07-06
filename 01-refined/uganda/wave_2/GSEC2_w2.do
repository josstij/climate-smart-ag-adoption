* Project: lsms-gender
* Created on: Feb 26
* Created by: ns
* Edited by: ns
* Edited on: 3 Feb 26
* Stata v.19.5


* Does
	* cleans uganda wave 2
	
* Needs
	* access to raw data
	
	
************************************************************************
**# 0 - setup
************************************************************************

* define paths
	global		root	"$data/raw_lsms_data/uganda/wave_2/raw"
	global		export	"$data/lsms_gender_data/01-refined_data/uganda/wave_2"
	global		logout	"$data/lsms_gender_data/01-refined_data/uganda/logs"
	
* open log 
	cap			log		close
	log			using	"$logout/GSEC2_W2", append
	

************************************************************************
**# 1 - clean data
************************************************************************

* load data
	use			"$root/GSEC2", clear
	
* rename variables
	rename		HHID	hhid
	rename		PID		indiv
	rename		h2q3	sex
	rename 		h2q4	relate
	rename		h2q5	away
	rename		h2q8	age
	rename		h2q10	mrry 
	
* keep essential variables
	keep 		hhid indiv sex relate away age mrry
	
* order variables
	order		hhid indiv sex relate away age mrry
	
	
************************************************************************
**# 2 - end matter
************************************************************************	
	
* save file
	qui: 		compress
	isid		hhid indiv
	save 		"$export/GSEC2_w2", replace