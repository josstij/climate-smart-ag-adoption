* Project: lsms gender
* Created on: nov 2025
* Created by: jared sage
* Edited on: 17 mar 2026
* Edited by: ns
* Stata v.18.5

* does
		* merges data for wave 1
		
* assumes
		* access to refined data
		
* TO DO
		* need to merge
		

************************************************************************
**# 0 - setup
************************************************************************

* define paths
	global 		root 	"$data/lsms_gender_data/01-refined_data/malawi/wave_1"
	global 		export 	"$data/lsms_gender_data/02-merged_data/malawi/wave_1"
	global 		logout 	"$data/lsms_gender_data/02-merged_data/malawi/logs"	

* open log 
	cap log close
	log using "$logout/mal_merged_w1", append

************************************************************************
**# 1 - merge individual characteristics
************************************************************************

* load individual roster
	use			"$root/hh_mod_b_10_w1", clear
	
* check unique id
	isid		case_id id_code
	
* merge edu
	merge 1:1 	case_id id_code using "$root/hh_mod_c_10_w1"
	*** 7,682 matched, all matched 
	
* replace edu for 5+
	replace 	edu = 0 if edu == . & age > 4 & _merge == 1
	
	drop		_merge
	
* merge work
	merge 1:1 	case_id id_code using "$root/hh_mod_e_10_w1"
	*** 7,682 matched, all matched 
	
	
* replace work for 5+
	replace 	wage = 0 if wage == . & age > 4 & _merge == 1
	replace 	farm = 0 if farm == . & age > 4 & _merge == 1
	replace 	nfe = 0 if nfe == . & age > 4 & _merge == 1
	
	drop		_merge
	
* save file
	qui: 		compress
	isid		case_id id_code
	save 		"$export/indiv_demo", replace

	
************************************************************************
**# 2 - merge individual characteristics into ag files
************************************************************************

************************************************************************
**## 2.2 - merge managers and owners (sect11b_plantingw1)
************************************************************************

* load individual roster
	use 		"$export/indiv_demo", clear

* create cert1 ID
	*gen 		mgmt1 = real(substr(PID, -2, 2))
	gen			mgmt1 = id_code

* merge each file for each manager
	merge 		1:m case_id mgmt1 using "$root/ag_mod_d_10_w1"
	
	* Result                      Number of obs
    *----------------------------------------
    * Not matched                       6,403
    *   from master                     6,379  (_merge==1)
    *   from using                         24  (_merge==2)

    * Matched                           2,544  (_merge==3)
    *----------------------------------------

* keep only matched observations
	keep if 	_merge == 3
	drop 		_merge
	
* rename demographic variables to own0 prefix
	local 	demo relate sex age mrry edu wage farm nfe
	
	foreach v of varlist `demo' {
		rename `v' mg1_`v'
}

* drop variables not needed
	drop		PID tenure defa*
	
* check unique id
	isid 		case_id plotid

* save file
	qui: 		compress
	isid 		case_id plotid
	save 		"$export/mgmt1", replace

	
************************************************************************
**### 2.3.3 - merge defa 1-2
************************************************************************

* loop for defa 1 - 2
	forvalues 	i = 1/2 {

* load individual demographic file
	use 			"$export/indiv_demo", clear

* create merge ID for owners
	*gen				defa`i' = real(substr(PID, -2, 2))
	gen					defa`i' = id_code
	
* merge with the agricultural file
	merge			1:m case_id defa`i' using "$root/ag_mod_d_10_w1"
	
	
	
	
	
* rename demographic variables
	local 			demo relate sex age mrry edu wage farm nfe
	
	foreach v of varlist `demo' {
		rename `v' df`i'_`v'
		}	
* drop individuals who don't own plots 	
	drop if 		_merge != 3
		
* drop non o`i' vars
	drop 			mgmt* tenure defa* _merge
	gen				df`i' = id_code
	lab var 		df`i' "plot own `i'"

* check unique id
		isid		case_id plotid df`i'
		
* save temp file for manager i
		tempfile 	defa`i'
		save 		"`defa`i''", replace
	}
	
* merge manager files
	use 			"$root/ag_mod_d_10_w1", clear
	
* loop merge owner files
	forvalues 	i = 1/2 {
		
		merge 	m:1 case_id plotid using "`defa`i''", nogen
	}

	drop 			mgmt*
	
* save final merged file
	qui: 			compress
	isid 			case_id plotid
	save 			"$export/defa", replace	
	

************************************************************************
**# 3 - merge all
************************************************************************
	use			"$export/mgmt1", clear
	
	isid 		case_id plotid
	
	count		
	
	merge		1:1 case_id plotid using "$export/defa", gen(_defa)
	
	count		
	
	drop 		_defa 
	
	gen			wave = 1
	
	
************************************************************************
**# 4 - end matter
************************************************************************	
	
* order variables
	* keep only needed variables
	keep        case_id plotid wave ///
				mgmt1 mg1_relate mg1_sex mg1_age mg1_mrry mg1_edu mg1_wage mg1_farm mg1_nfe ///
				defa1 df1_relate df1_sex df1_age df1_mrry df1_edu df1_wage df1_farm df1_nfe ///
				defa2 df2_relate df2_sex df2_age df2_mrry df2_edu df2_wage df2_farm df2_nfe

* order variables neatly
	order       case_id plotid ///
				mgmt1 mg1_relate mg1_sex mg1_age mg1_mrry mg1_edu mg1_wage mg1_farm mg1_nfe ///
				defa1 df1_relate df1_sex df1_age df1_mrry df1_edu df1_wage df1_farm df1_nfe ///
				defa2 df2_relate df2_sex df2_age df2_mrry df2_edu df2_wage df2_farm df2_nfe
				
	rename		case_id		hhid

* label variables
	lab var     mgmt1   "Who in the household manages this [PLOT]?"
	lab var     defa1   "De facto Owner"
	lab var     defa2   "De facto Owner"
	
* save final merged file		
	qui: 		compress
	isid 		plotid hhid
	save 		"$export/demo_w1", replace	
	
* close the log
	log			close

/* END */
