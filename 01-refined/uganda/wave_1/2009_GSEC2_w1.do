* Project: lsms-gender
* Created on: Jan 30
* Created by: sage
* Edited on: 30 Jan 26
* Stata v.19.5


* Does
	* cleans dataset for individual demographics for first visit 
	
* Needs
	* access to raw data
	
*To do everything 

********************************************************************************
**# 0 - setup
********************************************************************************
	
	* define paths
	global		root	"$data/raw_lsms_data/uganda/wave_1/raw"
	global		export	"$data/lsms_gender_data/01-refined_data/uganda/wave_1"
	global		logout	"$data/lsms_gender_data/01-refined_data/uganda/logs"
	
* open log 
	cap			log		close
	log			using	"$logout/2009_GSEC2_W1", append
	
********************************************************************************
**# 1 - clean data for demographics  
********************************************************************************

* load data 
	use 		"$root/2009_GSEC2"
	
	*rename variables 
	rename		HHID	hhid
	rename 		h2q3	sex
	rename		h2q4	relate
	rename		h2q8	age
	rename		PID		indiv
	rename 		h2q5	away 
	rename 		h2q10	mrry
	
*keep eseential variables 
	keep		sex relate age indiv away mrry hhid
	
*order variables 
	order 		hhid indiv sex relate away age mrry
	
********************************************************************************
**# 2 - clean data for demographics  
********************************************************************************

*save file 
	qui:		compress
	isid		hhid indiv 
	save		"$export/2009_GSEC2_W1",	replace
	