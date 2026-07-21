* Project: lsms-gender
* Created on: 4 Feb 30
* Created by: sage
* Edited on: 4 Feb 26
* Stata v.19.5


* Does
	* cleans dataset for individual demographics for first visit 
	* labor 
* Needs
	* access to raw data
	
*To do everything 

********************************************************************************
**# 0 - setup
********************************************************************************
	
	* define paths
	global		root	"$data/raw_lsms_data/uganda/wave_8/raw/hh"
	global		export	"$data/lsms_gender_data/01-refined_data/uganda/wave_8"
	global		logout	"$data/lsms_gender_data/01-refined_data/uganda/logs"
	
* open log 
	cap			log		close
	log			using	"$logout/gsec_W8", append
	
********************************************************************************
**# 1 - clean data for labor demographics   
********************************************************************************

* load data 
	use			"$root/gsec8", 	clear

*rename variables 
	rename		pid			indiv
	rename		s8q03		respond 
	rename 		s8q04		wage
	rename		s8q12		farm
	rename		s8q06		nfe
	
*keep variables 
	keep 		hhid indiv respond wage farm nfe 
	
*reorder variables 
	order		hhid indiv respond wage farm nfe 
	
********************************************************************************
**# 2 - clean data for labor demographics   
********************************************************************************

*save file 
	qui:	compress
	isid	hhid indiv
	save	"$export/gsec8_W8",	replace 
