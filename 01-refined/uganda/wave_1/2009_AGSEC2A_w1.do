* Project: lsms-gender
* Created on: Jan 26
* Created by: sage
* Edited on: 23 Jan 26
* Stata v.19.5


* Does
	* cleans uganda wave 1
	
* Needs
	* access to raw data
	
********************************************************************************
**# 0 - setup
********************************************************************************

* define paths
	global		root	"$data/raw_lsms_data/uganda/wave_1/raw"
	global		export	"$data/lsms_gender_data/01-refined_data/uganda/wave_1"
	global		logout	"$data/lsms_gender_data/01-refined_data/uganda/logs"
	
* open log 
	cap			log		close
	log			using	"$logout/2009_AGSEC2A_W1", append
	 

********************************************************************************
**# 1 - clean data for owners 
********************************************************************************

* load data 
	use 		"$root/2009_AGSEC2A"
	
*rename variables 
	rename	A2aq26a		cert1
	rename  A2aq26b 	cert2 
	rename	A2aq27a		mgmt1
	rename  A2aq27b		mgmt2 
	rename  A2aq28a		monman1
	rename	A2aq28b		monman2
	

************ Worked till here 
