* Project: lsms gender dynamics
* Created on: July 2025
* Created by: george hyland
* Edited on: 29 July 2025
* Edited by: george hyland
* Stata v.19.5

* does
		* merges with hh_cs_prod to add region

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
		
		drop source

* convert region to string for joinby
		tostring region, generate(region1)
		gen region2 = ""
		
		replace region2="North" if region1=="1"
		replace region2="Central" if region1=="2"
		replace region2="South" if region1=="3"
		drop region region1
		rename region2 region
		
* changing names for consistency btwn datasets
		replace item_name="RICE" if item_name=="RICE UNSPECIFIED"
		replace item_name="OKRA / THERERE" if item_name=="OKRA"
		replace unit_name="No 10 PLATE" if unit_name=="NO. 10 PLATE "
		replace unit_name="No 12 PLATE" if unit_name=="NO. 12 PLATE "
		
		
************************************************************************
**# 2 - end matter
************************************************************************

* save file
	qui: 			compress
	save 			"$export/2019_hh_cs_unitcode_merge", replace
	
* close the log
	log	close

/* END */