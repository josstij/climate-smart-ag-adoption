* Project: lsms gender
* Created on: nov 2025
* Created by: ns
* Edited on: 7 apr 2026
* Edited by: jdm
* Stata v.19.5

* does
		* merges data for wave 2
		
* assumes
		* access to refined data 
		
* TO DO
		* done
		

************************************************************************
**# 0 - setup
************************************************************************

* define paths
	global 		root 	"$data/lsms_gender_data/01-refined_data/nigeria/wave_2"
	global 		export 	"$data/lsms_gender_data/02-merged_data/nigeria/wave_2"
	global 		logout 	"$data/lsms_gender_data/02-merged_data/nigeria/logs"

* open log 
	cap 		log 	close
	log 		using 	"$logout/nga_merged_w2", append
	

************************************************************************
**# 1 - merge individual characteristics 
************************************************************************

* load individual roster
	use			"$root/sect1_plantingw2", clear
	
* check unique id
	isid		hhid indiv
	
* merge edu
	merge 1:1 	hhid indiv using "$root/sect2_plantingw2"
	*** 27,165 matched, 3,259 not matched, all from master
	*** all but ** unmatched are younger than 5
	
* replace edu for 5+
	replace 	edu = 0 if edu == . & age > 4 & _merge == 1
	
	drop		_merge
	
* merge work
	merge 1:1 	hhid indiv using "$root/sect3a_plantingw2"
	*** 28,496 matched, 1,928 not matched, all from master
	*** all but ** unmatched are younger than 5
	
* replace work for 5+
	replace 	wage = 0 if wage == . & age > 4 & _merge == 1
	replace 	farm = 0 if farm == . & age > 4 & _merge == 1
	replace 	nfe = 0 if nfe == . & age > 4 & _merge == 1
	
	drop		_merge
	
* save file
	qui: 		compress
	isid		hhid indiv
	save 		"$export/indiv_demo", replace


************************************************************************
**# 2 - merge individual characteristics into ag files
************************************************************************


************************************************************************
**## 2.1 - merge money manager (sect11h_plantingw2)
************************************************************************

* loop through money managers
	forvalues i = 1/4 {

	* load individual roster
		use			"$export/indiv_demo", clear

	* change indiv to monman1
		gen			monman`i' = indiv

	* merge each file for each money manager
		merge 1:m 	hhid monman`i' using "$root/sect11h_plantingw2"
	
	* rename monman1 demo vars	
		local 		demo relate sex age mrry away edu wage farm nfe
	
		foreach v of varlist `demo' {
			rename		`v' mm`i'_`v'
		} 	

	* drop unsold crops			
		drop if 	_merge != 3
	
	* drop not mm`i' vars
		drop 		respond monman* _merge
		gen			monman`i' = indiv
		lab var 	monman`i' "money manager `i'"

	* check unique id
		isid		hhid plotid cropid

	* save as temp 
		tempfile	monman`i'
		save 		"`monman`i''", replace
	}

* merge money manager files
	use			"$root/sect11h_plantingw2", clear

* loop through money manager files
	forvalues i = 1/4 {	
	
	* merge monman files
		merge 1:1 	hhid plotid cropid using "`monman`i''", nogen
	}

* save money manager file
	qui: 		compress
	isid 		hhid plotid cropid
	save 		"$export/monman", replace

	
************************************************************************
**## 2.2 - merge managers and owners (sect11b1_plantingw2)
************************************************************************


************************************************************************
**### 2.2.1 - merge managers 1-6
************************************************************************

* loop for mgmt 1 - 6
	forvalues 	i = 1/6 {

    * load individual demographic file
		use		"$export/indiv_demo", clear

    * create merge ID for manager i
		gen 	mgmt`i' = indiv

    * merge with the agricultural file
		merge 	1:m hhid mgmt`i' using "$root/sect11b1_plantingw2"

    * rename demographic variables
		local 	demo relate sex age mrry away edu wage farm nfe
	
		foreach v of varlist `demo' {
			rename `v' mg`i'_`v'
		}

	* drop individuals who don't manage plots & plots that only have 1 mananger	
		drop if 	_merge != 3
	
	* drop non mg`i' vars
		drop 		respond mgmt* tenure defa* deju* _merge 
		gen			mg`i' = indiv
		lab var 	mg`i' "plot manager `i'"

	* check unique id
		isid		hhid plotid mg`i'
		
    * save temp file for manager i
		tempfile 	mgmt`i'
		save 		"`mgmt`i''", replace
	}

* merge manager files
	use 	"$root/sect11b1_plantingw2", clear

* loop over managers 1 to 4 and merge sequentially
	forvalues 	i = 1/6 {
		
		merge 	m:1 hhid plotid using "`mgmt`i''", nogen
	}

	drop	defa*
	
* save final merged file
	qui: 	compress
	isid 	hhid plot
	save 	"$export/mgmt", replace

	
************************************************************************
**### 2.2.2 - merge deju1 & deju2
************************************************************************

* loop for cert 1 & 2
	forvalues	i = 1/2 {

* load individual roster
	use 	"$export/indiv_demo", clear

* create cert1 ID
	gen 	deju`i' = indiv

* merge each file for each manager
	merge 	1:m hhid deju`i' using "$root/sect11b1_plantingw2"

* keep only matched observations
	keep if _merge == 3
	drop 	_merge
	
* rename demographic variables to own0 prefix
	local 	demo relate sex age mrry away edu wage farm nfe
	
	foreach v of varlist `demo' {
		rename `v' dj`i'_`v'
	}		
    

* check unique id
	isid 	hhid plotid deju`i'
	
* save temp file for manager i
	tempfile 	deju`i'
	save 		"`deju`i''", replace
	
	}
	
* merge manager files
	use 	"$root/sect11b1_plantingw2", clear

* loop over managers 1 to 4 and merge sequentially
	forvalues 	i = 1/2 {
		
		merge 	m:1 hhid plotid using "`deju`i''", nogen
	}
	
* drop variables not needed
	drop 	defa* mgmt*

* save final merged file
	qui: 	compress
	isid 	hhid plot
	save 	"$export/deju", replace
	
	
************************************************************************
**### 2.3.3 - merge owners 1-4
************************************************************************

* loop for own 1 - 4
	forvalues 	i = 1/4 {

* load individual demographic file
		use 	"$export/indiv_demo", clear

* create merge ID for owners
		gen		defa`i' = indiv
	
* merge with the agricultural file
		merge	1:m hhid defa`i' using "$root/sect11b1_plantingw2"
	
* rename demographic variables
		local 	demo relate sex age mrry away edu wage farm nfe
	
		foreach v of varlist `demo' {
			rename `v' df`i'_`v'
			}	
* drop individuals who don't own plots 	
		drop if 	_merge != 3
		
* drop non ow`i' vars
		drop 	respond mgmt* tenure deju* _merge
		gen			df`i' = indiv
		lab var 	df`i' "plot defa `i'"

* check unique id
		isid		hhid plotid df`i'
		
* save temp file for manager i
		tempfile 	defa`i'
		save 		"`defa`i''", replace
	}
	
* merge manager files
	use 	"$root/sect11b1_plantingw2", clear

* loop over managers 1 to 4 and merge sequentially
	forvalues 	i = 1/4 {
		
		merge 	m:1 hhid plotid using "`defa`i''", nogen
	}
	
* drop variables not needed
	drop 	deju* mgmt*

* save final merged file
	qui: 	compress
	isid 	hhid plot
	save 	"$export/defa", replace
	
	
************************************************************************
**# 3 - merge all
************************************************************************
	use			"$export/mgmt", clear
	
	isid 		hhid plotid
	
	count		
	
	merge		1:1 hhid plotid using "$export/deju", gen(_deju)
	
	merge		1:1 hhid plotid using "$export/defa", gen(_defa)
	
	count		
	
	drop 		_defa _deju
	
	gen			wave = 2
	
************************************************************************
**# 4 - end matter
************************************************************************	
	
* order variables
	order		wave zone state lga sector ea hhid plotid tenure ///
				mgmt1 mg1_relate mg1_sex mg1_age mg1_mrry mg1_away mg1_edu mg1_wage mg1_farm mg1_nfe ///
				mgmt2 mg2_relate mg2_sex mg2_age mg2_mrry mg2_away mg2_edu mg2_wage mg2_farm mg2_nfe ///
				mgmt3 mg3_relate mg3_sex mg3_age mg3_mrry mg3_away mg3_edu mg3_wage mg3_farm mg3_nfe ///
				mgmt4 mg4_relate mg4_sex mg4_age mg4_mrry mg4_away mg4_edu mg4_wage mg4_farm mg4_nfe ///
				mgmt5 mg5_relate mg5_sex mg5_age mg5_mrry mg5_away mg5_edu mg5_wage mg5_farm mg5_nfe ///
				deju1 dj1_relate dj1_sex dj1_age dj1_mrry dj1_away dj1_edu dj1_wage dj1_farm dj1_nfe ///
				deju2 dj2_relate dj2_sex dj2_age dj2_mrry dj2_away dj2_edu dj2_wage dj2_farm dj2_nfe ///
				defa1 df1_relate df1_sex df1_age df1_mrry df1_away df1_edu df1_wage df1_farm df1_nfe ///
				defa2 df2_relate df2_sex df2_age df2_mrry df2_away df2_edu df2_wage df2_farm df2_nfe ///
				defa3 df3_relate df3_sex df3_age df3_mrry df3_away df3_edu df3_wage df3_farm df3_nfe ///
				defa4 df4_relate df4_sex df4_age df4_mrry df4_away df4_edu df4_wage df4_farm df4_nfe 
	
	drop		mg1 mg2 mg3 mg4 mg5 df1 df2 df3 df4 indiv
	
* label variables
	lab var		tenure	"How was [PLOT] acquired?"
	lab var 	mgmt2	"Who in the household manages this [PLOT]?"
	lab var 	mgmt3	"Who in the household manages this [PLOT]?"
	lab var 	mgmt4	"Who in the household manages this [PLOT]?"
	lab var 	mgmt5	"Who in the household manages this [PLOT]?"
	lab var		deju1	"De jure Owner"
	lab var		deju2	"De jure Owner"
	lab var 	defa1	"De facto Owner"
	lab var 	defa2	"De facto Owner"
	lab var 	defa3	"De facto Owner"
	lab var 	defa4	"De facto Owner"
	lab var 	wave	"Wave"
	
* save final merged file
	qui: 	compress
	count
	isid 	hhid plotid 
	save 	"$export/demo_w2", replace	
	
* close the log
	log	close

/* END */	