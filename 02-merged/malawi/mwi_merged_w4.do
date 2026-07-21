* Project: lsms gender
* Created on: April 1 2026
* Created by: ns
* Edited on: 20 April 2026
* Edited by: ns,js
* Stata v.18.5

* does
		* merges data for wave 4
		
* assumes
		* access to refined data
		
* TO DO
		* need to merge
		

************************************************************************
**# 0 - setup
************************************************************************

* define paths
	global 		root 	"$data/lsms_gender_data/01-refined_data/malawi/wave_4"
	global 		export 	"$data/lsms_gender_data/02-merged_data/malawi/wave_4"
	global 		logout 	"$data/lsms_gender_data/02-merged_data/malawi/logs"	

* open log
	cap log close
	log using "$logout/mal_merged_w4", append
	
************************************************************************
**# 1 - merge individual characteristics
************************************************************************

* load individual roster
	use 		"$root/hh_mod_b_19_w4", clear

* check unique ids
	isid 		y4_hhid indiv

* save file
	qui compress
	save 		"$export/indiv_demo", replace

	
************************************************************************
**### 2.1 - merge defa 1-4 (Garden Level)
************************************************************************

* loop for defa 1 - 4
forvalues i = 1/4 {

	* load individual demographic file
	use 			"$export/indiv_demo", clear

	* ARMOR: ensure no missing/duplicate IDs crash the merge
	drop if missing(indiv)
	duplicates drop y4_hhid indiv, force

	* create merge ID for owners
	gen				defa`i' = indiv
	
	* merge with the garden-level agricultural file
	merge			1:m y4_hhid defa`i' using "$root/hh_mod_f1_19_w4"
	
	* rename demographic variables
	local 			demo relate sex age mrry edu wage farm nfe
	foreach v of varlist `demo' {
		rename `v' df`i'_`v'
	}	

	* drop individuals who don't own plots 	
	keep if 		_merge == 3
		
	* drop non owner vars
	drop 			defa* _merge
	gen				df`i' = indiv
	lab var 		df`i' "de facto owner `i'"

	* check unique id at the GARDEN level
	isid			y4_hhid gardenid
		
	* save temp file for owner i
	tempfile 		defa`i'
	save 			"`defa`i''", replace
}
	
* merge owner files back to base
	use 			"$root/hh_mod_f1_19_w4", clear
	
* loop merge owner files
forvalues i = 1/4 {
	merge 			1:1 y4_hhid gardenid using "`defa`i''", nogen
}
	
* save final merged defa file
	qui: 			compress
	isid 			y4_hhid gardenid
	save 			"$export/defa", replace	
	
	
************************************************************************
**### 2.2 - merge deju 1-4 (Garden Level)
************************************************************************

* loop for deju 1 - 4
forvalues i = 1/4 {

	* load individual demographic file
	use 			"$export/indiv_demo", clear

	* ARMOR: ensure no missing/duplicate IDs crash the merge
	drop if missing(indiv)
	duplicates drop y4_hhid indiv, force

	* create merge ID for de jure owners
	gen				deju`i' = indiv
	
	* merge with the garden-level agricultural file
	merge			1:m y4_hhid deju`i' using "$root/hh_mod_f1_19_w4"
	
	* rename demographic variables
	local 			demo relate sex age mrry edu wage farm nfe
	foreach v of varlist `demo' {
		rename `v' dj`i'_`v'
	}	

	* drop individuals who don't own plots 	
	keep if 		_merge == 3
		
	* drop non owner vars
	drop 			deju* _merge
	gen				dj`i' = indiv
	lab var 		dj`i' "de jure owner `i'"

	* check unique id at the GARDEN level
	isid			y4_hhid gardenid
		
	* save temp file for owner i
	tempfile 		deju`i'
	save 			"`deju`i''", replace
}
	
* merge owner files back to base
	use 			"$root/hh_mod_f1_19_w4", clear
	
* loop merge owner files
forvalues i = 1/4 {
	merge 			1:1 y4_hhid gardenid using "`deju`i''", nogen
}
	
* save final merged deju file
	qui: 			compress
	isid 			y4_hhid gardenid
	save 			"$export/deju", replace


************************************************************************
**### 2.3 - merge mgmt 1-3 (Plot Level)
************************************************************************

* loop for managers 1 - 3
forvalues i = 1/3 {

	* load individual demographic file
	use 			"$export/indiv_demo", clear

	* ARMOR: ensure no missing/duplicate IDs crash the merge
	drop if missing(indiv)
	duplicates drop y4_hhid indiv, force

	* create merge ID for managers
	gen				mgmt`i' = indiv
	
	* merge with the plot-level agricultural file
	merge			1:m y4_hhid mgmt`i' using "$root/ag_mod_d_19_w4"
	
	* rename demographic variables
	local 			demo relate sex age mrry edu wage farm nfe
	foreach v of varlist `demo' {
		rename `v' mg`i'_`v'
	}	

	* drop individuals who don't manage plots 	
	keep if 		_merge == 3
		
	* drop non manager vars
	drop 			mgmt* _merge
	gen				mg`i' = indiv
	lab var 		mg`i' "plot manager `i'"

	* check unique id at the PLOT level
	isid			y4_hhid gardenid plotid
		
	* save temp file for manager i
	tempfile 		mgmt`i'
	save 			"`mgmt`i''", replace
}
	
* merge manager files back to base
	use 			"$root/ag_mod_d_19_w4", clear
	
* loop merge manager files
forvalues i = 1/3 {
	merge 			1:1 y4_hhid gardenid plotid using "`mgmt`i''", nogen
}
	
* save final merged mgmt file
	qui: 			compress
	isid 			y4_hhid gardenid plotid
	save 			"$export/mgmt", replace	


************************************************************************
**# 3 - merge all
************************************************************************
	
* Load the most granular file first (Plot Level)
	use				"$export/mgmt", clear
	isid 			y4_hhid gardenid plotid
	
* Merge the Garden-Level defa data (many plots to 1 garden)
	merge			m:1 y4_hhid gardenid using "$export/defa", gen(_defa)
	
* Merge the Garden-Level deju data (many plots to 1 garden)
	merge			m:1 y4_hhid gardenid using "$export/deju", gen(_deju)
	
* drop merge variables 
	drop 			_defa _deju
	
	gen				wave = 4
	
	
************************************************************************
**# 4 - end matter
************************************************************************	
	
* Fix the ghost gardens (drop gardens with no plots)
	drop if missing(plotid)

* keep only needed variables
	keep        y4_hhid gardenid plotid wave ///
	            mgmt1 mg1_* mgmt2 mg2_* mgmt3 mg3_* ///
	            defa1 df1_* defa2 df2_* defa3 df3_* defa4 df4_* ///
	            deju1 dj1_* deju2 dj2_* deju3 dj3_* deju4 dj4_*
				
* order variables neatly
	order       y4_hhid gardenid plotid ///
	            mgmt1 mg1_* mgmt2 mg2_* mgmt3 mg3_* ///
	            defa1 df1_* defa2 df2_* defa3 df3_* defa4 df4_* ///
	            deju1 dj1_* deju2 dj2_* deju3 dj3_* deju4 dj4_*

* label the primary ID variables
	lab var     mgmt1   "Plot Manager 1"
	lab var     mgmt2   "Plot Manager 2"
	lab var     mgmt3   "Plot Manager 3"
	
	lab var     defa1   "De facto Owner 1"
	lab var     defa2   "De facto Owner 2"
	lab var     defa3   "De facto Owner 3"
	lab var     defa4   "De facto Owner 4"
	
	lab var     deju1   "De jure Owner 1"
	lab var     deju2   "De jure Owner 2"
	lab var     deju3   "De jure Owner 3"
	lab var     deju4   "De jure Owner 4"
	
	rename		y4_hhid	hhid
* save final merged file (Updated to w4!)		
	qui: 		compress
	isid 		hhid gardenid plotid
	save 		"$export/demo_w4", replace	
	
* close the log
	log			close

/* END */