* Project: lsms gender
* Created on: April 1 2026
* Created by: jared sage
* Edited on: 3 April 2026
* Edited by: ns,js
* Stata v.18.5

* does
		* merges data for wave 2
		
* assumes
		* access to refined data
		
* TO DO
		* need to merge
		

************************************************************************
**# 0 - setup
************************************************************************

* define paths
	global 		root 	"$data/lsms_gender_data/01-refined_data/malawi/wave_2"
	global 		export 	"$data/lsms_gender_data/02-merged_data/malawi/wave_2"
	global 		logout 	"$data/lsms_gender_data/02-merged_data/malawi/logs"	

* open log 
	cap log 	close
	log using 	"$logout/mal_merged_w2", append
	

	
************************************************************************
**# 1 - merge individual characteristics
************************************************************************

* load individual roster
	use 		"$root/hh_mod_b_13_w2", clear

* check unique ids
	isid 		y2_hhid indiv

* save file
	qui compress
	save 		"$export/indiv_demo", replace


************************************************************************
**### 2.2.1 - merge managers 1-3
************************************************************************

forvalues i = 1/3 {

    * load individual demographic file
    use "$export/indiv_demo", clear

    * create merge ID for manager i
    gen mgmt`i' = indiv

    * merge with agricultural file
    merge 1:m y2_hhid mgmt`i' using "$root/ag_mod_d_13_w2"

    * keep only matched observations
    keep if _merge == 3
    drop _merge

    * store actual PID for manager i
    gen mg`i' = indiv
    label var mg`i' "plot manager `i' ID"

    * rename demographic variables
    local demo relate sex age mrry edu wage farm nfe
    foreach v of local demo {
        rename `v' mg`i'_`v'
    }

    * drop variables not needed
    drop indiv defa* deju* 

    * check unique id
    isid y2_hhid plotid

    * save temp file for manager i
    tempfile mgmt`i'
    save "`mgmt`i''", replace
}

* merge temp files

	use "$root/ag_mod_d_13_w2", clear

forvalues i = 1/3 {
					merge 1:1 y2_hhid plotid using "`mgmt`i''", nogen
					
}

	drop 			defa*

* save final merged file
	isid 			y2_hhid plotid
	qui compress
	save "$export/mgmt", replace	
	

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
	merge			1:m y2_hhid defa`i' using "$root/ag_mod_d_13_w2"
	
* rename demographic variables
	local 			demo relate sex age mrry edu wage farm nfe
	
	foreach v of varlist `demo' {
		rename `v' df`i'_`v'
		}	
* drop individuals who don't own plots 	
	drop if 		_merge != 3
		
* drop non o`i' vars
	drop 			mgmt* defa* _merge
	gen				df`i' = indiv
	lab var 		df`i' "plot own `i'"

* check unique id
		isid		y2_hhid plotid df`i'
		
* save temp file for manager i
		tempfile 	defa`i'
		save 		"`defa`i''", replace
	}
	
* merge manager files
	use 			"$root/ag_mod_d_13_w2", clear
	
* loop merge owner files
	forvalues 	i = 1/4 {
		
		merge 	m:1 y2_hhid plotid using "`defa`i''", nogen
	}

	drop 			mgmt*
	
* save final merged file
	qui: 			compress
	isid 			y2_hhid plotid
	save 			"$export/defa", replace	
	
	
************************************************************************	
**### 2.2.2 - merge deju 1-2
************************************************************************
	
forvalues i = 1/2 {
	
* load individual roster
	use 	"$export/indiv_demo", clear

* create cert1 ID
	gen 	deju`i' = indiv

* merge each file for each manager
	merge 	1:m y2_hhid deju`i' using "$root/ag_mod_d_13_w2"

* keep only matched observations
	keep if _merge == 3
	drop 	_merge
	
* rename demographic variables to own0 prefix
	local 	demo relate sex age mrry edu wage farm nfe
	
	foreach v of varlist `demo' {
		rename `v' dj`i'_`v'
}



* check unique id
	isid 		y2_hhid plotid
	
* save temp file for manager i
	tempfile 	deju`i'
	save 		"`deju`i''", replace
	
	}
	
* merge manager files
	use 	"$root/ag_mod_d_13_w2", clear

* loop over managers 1 to 2 and merge sequentially
	forvalues 	i = 1/2 {
		
		merge 	m:1 y2_hhid plotid using "`deju`i''", nogen
	}

* check unique id
	isid 	y2_hhid plotid 
	
*drop unecessary variables
	drop	mgmt* defa* indiv 

* save file
	qui: 	compress
	isid 	y2_hhid plotid
	save 	"$export/deju", replace
	
	
************************************************************************
**# 3 - merge all
************************************************************************
	use			"$export/mgmt", clear
	
	isid 		y2_hhid plotid
	
	count		
	
	merge		1:1 y2_hhid plotid using "$export/defa", gen(_defa)
	
	count		
	
	drop		_defa
	
	merge		1:1 y2_hhid plotid using "$export/deju", gen(_deju)
	
	count		
	
	drop 		_deju
	
	gen			wave = 2
	
	
************************************************************************
**# 4 - end matter
************************************************************************	
	
* order variables
	* keep only needed variables
	keep		y2_hhid plotid wave ///
				mgmt1 mg1_relate mg1_sex mg1_age mg1_mrry mg1_edu mg1_wage mg1_farm mg1_nfe ///
				mgmt2 mg2_relate mg2_sex mg2_age mg2_mrry mg2_edu mg2_wage mg2_farm mg2_nfe ///
				mgmt3 mg3_relate mg3_sex mg3_age mg3_mrry mg3_edu mg3_wage mg3_farm mg3_nfe ///
				defa1 df1_relate df1_sex df1_age df1_mrry df1_edu df1_wage df1_farm df1_nfe ///
				defa2 df2_relate df2_sex df2_age df2_mrry df2_edu df2_wage df2_farm df2_nfe ///
				defa3 df3_relate df3_sex df3_age df3_mrry df3_edu df3_wage df3_farm df3_nfe ///
				defa4 df4_relate df4_sex df4_age df4_mrry df4_edu df4_wage df4_farm df4_nfe ///
				deju1 dj1_relate dj1_sex dj1_age dj1_mrry dj1_edu dj1_wage dj1_farm dj1_nfe ///
				deju2 dj2_relate dj2_sex dj2_age dj2_mrry dj2_edu dj2_wage dj2_farm dj2_nfe
				
* Label manager variables
	lab var 	mgmt1 "Manager 1 of the plot"
	lab var 	mgmt2 "Manager 2 of the plot"
	lab var 	mgmt3 "Manager 3 of the plot"

* Label owner (defa) variables
	lab var 	defa1 "De facto Owner 1"
	lab var 	defa2 "De facto Owner 2"
	lab var 	defa3 "De facto Owner 3"
	lab var 	defa4 "De facto Owner 4"

* Label deju variables
	lab var 	deju1 "De jure Owner 1"
	lab var 	deju2 "De jure Owner 2"
	
*rename hhid
	rename		y2_hhid		hhid
	
* save final merged file		
	qui: 		compress
	isid 		hhid plotid
	save 		"$export/demo_w2", replace	
	
* close the log
	log			close

/* END */
