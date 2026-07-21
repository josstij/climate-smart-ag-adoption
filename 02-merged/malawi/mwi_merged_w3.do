* Project: lsms gender
* Created on: April 1 2026
* Created by: jared sage
* Edited on: 3 April 2026
* Edited by: ns,js
* Stata v.18.5

* does
		* merges data for wave 3
		
* assumes
		* access to refined data
		
* TO DO
		* need to merge
		

************************************************************************
**# 0 - setup
************************************************************************

* define paths
	global 		root 	"$data/lsms_gender_data/01-refined_data/malawi/wave_3"
	global 		export 	"$data/lsms_gender_data/02-merged_data/malawi/wave_3"
	global 		logout 	"$data/lsms_gender_data/02-merged_data/malawi/logs"	

* open log 
	cap log close
	log using "$logout/mal_merged_w3", append
	

	
************************************************************************
**# 1 - merge individual characteristics
************************************************************************

* load individual roster
	use 		"$root/hh_mod_b_16_w3", clear

* check unique ids
	isid 		y3_hhid indiv

* save file
	qui compress
	save 		"$export/indiv_demo", replace

	
************************************************************************
**### 2.3.3 - merge defa 1-4
************************************************************************

* loop for defa 1 - 4
	forvalues 	i = 1/4 {

* load individual demographic file
	use 			"$export/indiv_demo", clear

* create merge ID for owners
	gen				defa`i' = indiv
	
* merge with the agricultural file
	merge			1:m y3_hhid defa`i' using "$root/ag_mod_b2_16_w3"
	
* rename demographic variables
	local 			demo relate sex age mrry edu wage farm nfe
	
	foreach v of varlist `demo' {
		rename `v' df`i'_`v'
		}	
* drop individuals who don't own plots 	
	drop if 		_merge != 3
		
* drop non o`i' vars
	drop 			defa* _merge
	gen				df`i' = indiv
	lab var 		df`i' "plot own `i'"

* check unique id
	isid            y3_hhid gardenid
		
* save temp file for manager i
		tempfile 	defa`i'
		save 		"`defa`i''", replace
	}
	
* merge manager files
	use 			"$root/ag_mod_b2_16_w3", clear
	
* loop merge owner files
	forvalues 	i = 1/4 {
		
		merge 	1:1 y3_hhid gardenid using "`defa`i''", nogen
	}
	
* save final merged file
	qui: 			compress
	isid 			y3_hhid gardenid
	save 			"$export/defa", replace	
	
	
************************************************************************
**### 2.3.4 - merge deju 1-4
************************************************************************

* loop for deju 1 - 4
	forvalues 	i = 1/4 {

* load individual demographic file
	use 			"$export/indiv_demo", clear

* create merge ID for de jure owners
	gen				deju`i' = indiv
	
* merge with the agricultural file
	merge			1:m y3_hhid deju`i' using "$root/ag_mod_b2_16_w3"
	
* rename demographic variables
	local 			demo relate sex age mrry edu wage farm nfe
	
	foreach v of varlist `demo' {
		rename `v' dj`i'_`v'
		}	

* drop individuals who don't own plots 	
	drop if 		_merge != 3
		
* drop non owner vars
	drop 			deju* _merge
	gen				dj`i' = indiv
	lab var 		dj`i' "de jure owner `i'"

* check unique id
	isid			y3_hhid gardenid
		
* save temp file for owner i
		tempfile 	deju`i'
		save 		"`deju`i''", replace
	}
	
* merge owner files
	use 			"$root/ag_mod_b2_16_w3", clear
	
* loop merge owner files
	forvalues 	i = 1/4 {
		
		merge 	1:1 y3_hhid gardenid using "`deju`i''", nogen
	}
	
* save final merged file
	qui: 			compress
	isid 			y3_hhid gardenid
	save 			"$export/deju", replace

************************************************************************
**### 2.3.5 - merge mgmt 1-3
************************************************************************

* loop for managers 1 - 3
	forvalues 	i = 1/3 {

* load individual demographic file
	use 			"$export/indiv_demo", clear

* create merge ID for managers
	gen				mgmt`i' = indiv
	
* merge with the agricultural plot file
	merge			1:m y3_hhid mgmt`i' using "$root/ag_mod_d_16_w3"
	
* rename demographic variables
	local 			demo relate sex age mrry edu wage farm nfe
	
	foreach v of varlist `demo' {
		rename `v' mg`i'_`v'
		}	

* drop individuals who don't manage plots 	
	drop if 		_merge != 3
		
* drop non manager vars
	drop 			mgmt* _merge
	gen				mg`i' = indiv
	lab var 		mg`i' "plot manager `i'"

* check unique id at the PLOT level
	isid			y3_hhid gardenid plotid
		
* save temp file for manager i
		tempfile 	mgmt`i'
		save 		"`mgmt`i''", replace
	}
	
* merge manager files
	use 			"$root/ag_mod_d_16_w3", clear
	
* loop merge manager files
	forvalues 	i = 1/3 {
		
		* Merge back at the PLOT level
		merge 	1:1 y3_hhid gardenid plotid using "`mgmt`i''", nogen
	}
	
* save final merged mgmt file
	qui: 			compress
	isid 			y3_hhid gardenid plotid
	save 			"$export/mgmt", replace	


************************************************************************
**# 3 - merge all
************************************************************************
	
* Load the most granular file first (Plot Level)
	use			"$export/mgmt", clear
	
	isid 		y3_hhid gardenid plotid
	
* Merge the Garden-Level defa data (many plots to 1 garden)
	merge		m:1 y3_hhid gardenid using "$export/defa", gen(_defa)
	
* Merge the Garden-Level deju data (many plots to 1 garden)
	merge		m:1 y3_hhid gardenid using "$export/deju", gen(_deju)
	
* drop merge variables 
	drop 		_defa _deju
	
	gen			wave = 3
	
	
************************************************************************
**# 4 - end matter
************************************************************************ 
	drop if missing(plotid)

* 2. Keep only needed variables using wildcards for efficiency
	keep        y3_hhid gardenid plotid wave ///
	            mgmt1 mg1_* mgmt2 mg2_* mgmt3 mg3_* ///
	            defa1 df1_* defa2 df2_* defa3 df3_* defa4 df4_* ///
	            deju1 dj1_* deju2 dj2_* deju3 dj3_* deju4 dj4_*
                
* 3. Order variables neatly
	order       y3_hhid gardenid plotid ///
	            mgmt1 mg1_* mgmt2 mg2_* mgmt3 mg3_* ///
	            defa1 df1_* defa2 df2_* defa3 df3_* defa4 df4_* ///
	            deju1 dj1_* deju2 dj2_* deju3 dj3_* deju4 dj4_*

* 4. Label the primary ID variables
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
    
	rename		y3_hhid	hhid
* 5. Save final merged file       
	qui:        compress
	isid        hhid gardenid plotid
	save        "$export/demo_w3", replace  
    
* close the log
	log         close

/* END */
