* Project: lsms gender dynamics
* Created on: 9 july 2025
* Created by: alj
* Edited on: 9 july 2025
* Edited by: alj
* Stata v.18

* does
	* creates 2013 fcs 
	*** follows: https://inddex.nutrition.tufts.edu/data4diets/indicator/food-consumption-score-fcs
	
* assumes
	* access to all raw data

* TO DO:
	* done! 
	
* **********************************************************************
**#0 - setup
* **********************************************************************

* define paths
	global root 	"$data/raw_lsms_data/malawi/harmonized/wave_2"
	global export 	"$data/lsms_gender_data/01-refined_data/malawi/wave_2"
	global logout 	"$data/lsms_gender_data/01-refined_data/malawi/logs"
	
* open log 
	cap log close
	log using "$logout/hh_mod_g2_13", append
	
* ***********************************************************************
**# 1 - prepare malawi 2013 - food consumption score 
* ***********************************************************************

* load data
	use 		"$root/hh_mod_g2_13.dta", clear
	
	drop 		occ qx_type interview_status
	
* reshape long to wide
	reshape 	wide hh_g08c, i(y2_hhid) j(hh_g08a)

* rename food variables 
	rename		hh_g08c1 staples
	rename 		hh_g08c2 roots
	rename 		hh_g08c3 pulses
	rename 		hh_g08c4 vegetables
	rename 		hh_g08c5 meat
	rename 		hh_g08c6 fruits
	rename 		hh_g08c7 dairy
	rename 		hh_g08c8 oil
	rename 		hh_g08c9 sugar
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
	isid			y2_hhid
	describe
	summarize 
	save 			"$export/hh_g2_13", replace

* close the log
	log	close

/* END */
