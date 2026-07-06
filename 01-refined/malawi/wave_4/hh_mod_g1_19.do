* Project: lsms gender dynamics
* Created on: July 2025
* Created by: george hyland
* Edited on: 22 July 2025
* Edited by: george hyland
* Stata v.19.5

* does
		* cleans data for hh food consumption
		* keeps foods hh consumes & produces, excludes purchases

* assumes

* to do
		* convert unit codes into strings
		* merge with ihs_foodconversion_factor_2020
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
		use			"$root/hh_mod_g1_19", clear
	
* rename variables
		rename (hh_g02 hh_g06a hh_g06b) (item_code prd_qty unit_code)
		
* merge data
		merge		m:1 y4_hhid using "$root/hh_mod_a_filt_19"

		drop		_merge
		
/*		
    Result                      Number of obs
    -----------------------------------------
    Not matched                             0
    Matched                           451,276  (_merge==3)
    -----------------------------------------
	
*/

		*merge		1:m unit_code using "$root/ihs_foodconversion_factor_2020"
		
		*drop		_merge
		
* drop foods not consumed/produced by hh
		decode hh_g01, gen(consumed)
		drop if consumed == "NO"
		drop if prd_qty == .
		drop if prd_qty == 0
		
* keep relevant variables
		keep y4_hhid item_code prd_qty unit_code region
		
		
************************************************************************
**# 2 - end matter
************************************************************************

* save file
	qui: 			compress
	save 			"$export/2019_hh_cs_prod", replace
	
* close the log
	log	close

/* END */