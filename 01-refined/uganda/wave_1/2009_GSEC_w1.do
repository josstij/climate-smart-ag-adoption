* Project: lsms-gender
* Created on: Jan 30
* Created by: sage
* Edited on: 30 Jan 26
* Stata v.19.5


* Does
	* cleans dataset for individual demographics for first visit, wave 1 
	* labor 
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
	log			using	"$logout/2009_GSEC8_W1", append
	
********************************************************************************
**# 1 - clean data for labor demographics   
********************************************************************************

* load data 
	use			"$root/2009_GSEC8"

*rename variables 
	rename		Hhid		hhid
	rename		Pid			indiv
	rename		H8q03		respond 
	rename 		H8q04		wage
	rename		H8q12		farm
	rename		H8q06		nfe
	
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
	save	"$export/2009_GSEC8_W1",	replace 
