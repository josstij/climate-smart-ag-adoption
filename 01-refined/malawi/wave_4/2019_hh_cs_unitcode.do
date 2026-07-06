* Project: lsms gender dynamics
* Created on: July 2025
* Created by: george hyland
* Edited on: 28 July 2025
* Edited by: george hyland
* Stata v.19.5

* does
		* merges with ihs_foodconversion_factor_2020 add y4_hhid
		* prepares to add factor values from ihs_foodconversion_factor_2020

* assumes

* to do
/*
		
************************************************************************
**# 0 - setup
************************************************************************

* define paths
	global root 	"$data/MWI_2010-2019_IHPS_v06_M_Stata"
	global export 	"$data/refined/wave_4"
	global logout 	"$data/log"

* open log 
	cap log close 
	log using "$logout/mwi_wth_p", append


************************************************************************
**# 1 - clean data
************************************************************************

* load data
		use			"$root/ihs_foodconversion_factor_2020", clear
		
* gen unique variables for collapsing
		gen collapse = _n
		
		bysort unit_code (collapse): gen row = _n
		
* collapse unit_code
		collapse (mean) factor, by(unit_code)
		*collapse (mean) factor, by(region unit_name item_name unit_code)
		
		
************************************************************************
**# 2 - end matter
************************************************************************

* save file
	qui: 			compress
	save 			"$export/2019_hh_cs_unitcode", replace
	
* close the log
	log	close

/* END */