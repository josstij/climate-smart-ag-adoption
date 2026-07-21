* Project: lsms gender
* Created on: May 2026
* Created by: js
* Edited on: 8 July 2026
* Edited by: jdm
* Stata v.16

* does
	* inputs wave 1 individual roster
	* cleans up demographic variables (sex, age, edu, etc.)
	* outputs cleaned individual roster

* assumes
	* access to raw data

* TO DO:
	* complete


************************************************************************
**# 0 - setup
************************************************************************

* define paths
	global			root 	"$data/raw_lsms_data/niger/wave_1/raw"
	global			export 	"$data/lsms_gender_data/01-refined_data/niger/wave_1"
	global			logout 	"$data/lsms_gender_data/01-refined_data/niger/logs"
	
* open log
	cap		log		close
	log				using	"$logout/ecvmaind_p1p2_en_w1", append


************************************************************************
**# 1 - clean data
************************************************************************

* load data
	use				"$root/ecvmaind_p1p2_en.dta", clear
		
* rename variables
	rename			ms01q01 sex
	rename			ms01q02 relate
	rename			ms01q06a age
	rename			ms02q23 edu
	rename			ms01q15 mrry
	rename			ms04q01 wage
	rename			ms04q05 nfe
	rename			ms01q21a away
	rename			ms04q03 farm
	rename			ms01q00 indiv
	
* replace edu
	replace			edu = 0 if edu == . & (ms02q01 == 2 | ms02q02 == 2)
	
	
* keep essential variables
	keep			hid indiv relate sex age away mrry edu nfe wage farm menage grappe


************************************************************************
**# 2 - end matter
************************************************************************

* save file
	isid			hid indiv
	qui:			compress
	save			"$export/hecvmaind_p1p2_en_w1", replace
	
* close the log
	log				close

/* END */	
