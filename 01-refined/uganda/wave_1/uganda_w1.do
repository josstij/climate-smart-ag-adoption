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
	use			log		close
	*log			using	"$logout"
*********************worked till here 
