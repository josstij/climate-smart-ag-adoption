* Project: lsms gender
* Created on: 9 july 2025
* Created by: alj
* Edited on: 9 july 2025
* Edited by: george hyland
* Stata v.19.5

* does
	* creates 2019 fcs 
	*** follows: https://inddex.nutrition.tufts.edu/data4diets/indicator/food-consumption-score-fcs
	
* assumes
	* access to all raw data

* TO DO:
	* all 
/*
* **********************************************************************
**#0 - setup
* **********************************************************************

* define paths
	global root 	"$data/MWI_2010-2019_IHPS_v06_M_Stata"
	global export 	"$data/refined/wave_4"
	global logout 	"$data/log"

* open log 
	cap log close 
	log using "$logout/2019_fcs", append
	
* ***********************************************************************
**# 1 - prepare malawi 2019 - food consumption score 
* ***********************************************************************

* load data
	use 		"$root/hh_mod_g2_19.dta", clear
	
	drop 		qx_type interview_status hh_g08j
	
* reshape long to wide
* not required for 19'
	*reshape 	wide hh_g08c, i(y3_hhid) j(hh_g08a)

* rename food variables 
	rename		hh_g08a staples
	rename 		hh_g08b roots
	rename 		hh_g08c pulses
	rename 		hh_g08d vegetables
	rename 		hh_g08e meat
	rename 		hh_g08f fruits
	rename 		hh_g08g dairy
	rename 		hh_g08h oil
	rename 		hh_g08i sugar
* we ignore spices and condiments - not included in FCS

* cap values at 7 (root is base of a week)
	foreach 	var in staples roots pulses vegetables meat fruits dairy oil sugar {
					replace `var' = 7 if `var' > 7
					}

* apply weights 
	gen 		w_staples    = staples * 2
	gen 		w_roots      = roots * 2
	*** combine with staples 
	gen 		w_pulses     = pulses * 3
	gen 		w_vegetables = vegetables * 1
	gen 		w_fruits     = fruits * 1
	gen		 	w_meat       = meat * 4
	gen 		w_dairy      = dairy * 4
	gen 		w_sugar      = sugar * 0.5
	gen 		w_oil        = oil * 0.5

* sum for total FCS
	egen 		fcs = rsum (w_staples w_roots w_pulses w_vegetables w_fruits w_meat w_dairy w_sugar w_oil)

* categorize
	gen 		fcs_category = .
	replace 	fcs_category = 1 if fcs <= 21
	replace 	fcs_category = 2 if fcs > 21 & fcs <= 35
	replace 	fcs_category = 3 if fcs > 35

	label 		define fcs_cat 1 "Poor" 2 "Borderline" 3 "Acceptable"
	label 		values fcs_category fcs_cat

* prepare for export
	isid			y4_hhid
	describe
	summarize 
	save 			"$export/2019_fcs.dta", replace

* close the log
	log	close

/* END */