* Project: lsms-gender
* Created on: Feb 4
* Created by: sage
* Edited on: 4 Feb 26
* Stata v.19.5


* Does
	* cleans dataset for individual demographics for first visit 
	* edu
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
	log			using	"$logout/GSEC4_W7", append
	
********************************************************************************
**# 1 - clean data for demographics  
********************************************************************************

* load data 
	use			"$root/GSEC4"
	
*rename variables 
	rename		PID		indiv
	rename 		s4q07	edu
	rename		s4q05	attd		
*keep variables
	keep		hhid indiv edu attd 
	
*order variables
	order 		hhid indiv edu attd 
	
********************************************************************************
**# 2 - clean data for demographics  
********************************************************************************

*save file 
	qui:	compress
	isid	hhid indiv
	save	"$export/GSEC4_W7",	replace 
