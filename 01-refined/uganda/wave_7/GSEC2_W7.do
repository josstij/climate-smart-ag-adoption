* Project: lsms-gender
* Created on: 4 Feb 26  
* Created by: sage
* Edited on: 4 Feb 26
* Stata v.19.5


* Does
	* cleans dataset for individual demographics for first visit, wave 7
	*labor
* Needs
	* access to raw data
	
*To do everything 

********************************************************************************
**# 0 - setup
********************************************************************************
	
* define paths
	global		root	"$data/raw_lsms_data/uganda/wave_7/raw/hh"
	global		export	"$data/lsms_gender_data/01-refined_data/uganda/wave_7"
	global		logout	"$data/lsms_gender_data/01-refined_data/uganda/logs"
	
* open log 
	cap			log		close
	log			using	"$logout/GSEC2_W7", append
	
********************************************************************************
**# Bookmark #2
********************************************************************************

* load data 
	use			"$root/GSEC2", clear
	
* rename variables
	rename		PID		indiv	
	rename 		h2q3	sex
	rename		h2q4	relate
	rename		h2q8	age
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
	qui:	compress
	isid	hhid indiv
	save	"$export/GSEC2_W7",	replace 
