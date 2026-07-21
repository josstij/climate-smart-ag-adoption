* Project: lsms gender
* Created on: dec 2025
* Created by: ns
* Edited on: 7 apr 2026
* Edited by: jdm
* Stata v.19.5

* does
		* merges data for wave 4
		
* assumes
		* access to refined data 
		
* TO DO
		* done
		

************************************************************************
**# 0 - setup
************************************************************************

* define paths
	global 		root 	"$data/lsms_gender_data/01-refined_data/nigeria/wave_4"
	global 		export 	"$data/lsms_gender_data/02-merged_data/nigeria/wave_4"
	global 		logout 	"$data/lsms_gender_data/02-merged_data/nigeria/logs"	 

* open log 
	cap 		log 	close
	log 		using 	"$logout/nga_merged_w4", append
	
	
************************************************************************
**# 1 - merge individual characteristics 
************************************************************************

* load individual roster
	use			"$root/sect1_plantingw4", clear
	
* check unique id
	isid		hhid indiv
	
* merge edu
	merge 1:1 	hhid indiv using "$root/sect2_harvestw4"
	*** 26,557 matched, 4656 not matched, all from master
	
* replace edu for 5+
	replace 	edu = 0 if edu == . & age > 4 & _merge == 1
	
	drop		_merge
	
* merge work
	merge 1:1 	hhid indiv using "$root/sect3_plantingw4"
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
**## 2.2 - merge managers and owners (sect11b_plantingw1)
************************************************************************
	
	
************************************************************************
**### 2.2.1 - merge managers 1-4
************************************************************************

* loop for mgmt 1 - 4
	forvalues 	i = 1/4 {

    * load individual demographic file
		use		"$export/indiv_demo", clear

    * create merge ID for manager i
		gen 	mgmt`i' = indiv

    * merge with the agricultural file
		merge 	1:m hhid mgmt`i' using "$root/sect11b1_plantingw4"

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
	use 	"$root/sect11b1_plantingw4", clear

* loop over managers 1 to 4 and merge sequentially
	forvalues 	i = 1/4 {
		
		merge 	m:1 hhid plotid using "`mgmt`i''", nogen
	}

	drop	defa*
	
* save final merged file
	qui: 	compress
		isid 	hhid plotid
	save 	"$export/mgmt", replace	
	
	
************************************************************************
**### 2.2.2 - merge deju1 - 4
************************************************************************

* loop for cert 1 - 4
	forvalues	i = 1/4 {

* load individual roster
	use 	"$export/indiv_demo", clear

* create cert1 ID
	gen 	deju`i' = indiv

* merge each file for each manager
	merge 	1:m hhid deju`i' using "$root/sect11b1_plantingw4"

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
	use 	"$root/sect11b1_plantingw4", clear

* loop over managers 1 to 4 and merge sequentially
	forvalues 	i = 1/4 {
		
		merge 	m:1 hhid plotid using "`deju`i''", nogen
	}
	
* drop variables not needed
	drop 	defa* mgmt*

* save final merged file
	qui: 	compress
		isid 	hhid plotid
	save 	"$export/deju", replace
		
	
************************************************************************
**### 2.3.3 - merge defa 1-10
************************************************************************

* loop for own 1 - 10
	forvalues 	i = 1/10 {

* load individual demographic file
		use 	"$export/indiv_demo", clear

* create merge ID for owners
		gen		defa`i' = indiv
	
* merge with the agricultural file
		merge	1:m hhid defa`i' using "$root/sect11b1_plantingw4"
	
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
	use 	"$root/sect11b1_plantingw4", clear

* loop over managers 1 to 10 and merge sequentially
	forvalues 	i = 1/10 {
		
		merge 	m:1 hhid plotid using "`defa`i''", nogen
	}
	
* drop variables not needed
	drop 	deju* mgmt*

* save final merged file
	qui: 	compress
		isid 	hhid plotid
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
	
	gen			wave = 4
	
	
************************************************************************
**# 4 - end matter
************************************************************************		
	
* order variables
	order		wave zone state lga sector ea hhid plotid tenure ///
				mgmt1 mg1_relate mg1_sex mg1_age mg1_mrry mg1_away mg1_edu mg1_wage mg1_farm mg1_nfe ///
				mgmt2 mg2_relate mg2_sex mg2_age mg2_mrry mg2_away mg2_edu mg2_wage mg2_farm mg2_nfe ///
				mgmt3 mg3_relate mg3_sex mg3_age mg3_mrry mg3_away mg3_edu mg3_wage mg3_farm mg3_nfe ///
				mgmt4 mg4_relate mg4_sex mg4_age mg4_mrry mg4_away mg4_edu mg4_wage mg4_farm mg4_nfe ///
				deju1 dj1_relate dj1_sex dj1_age dj1_mrry dj1_away dj1_edu dj1_wage dj1_farm dj1_nfe ///
				deju2 dj2_relate dj2_sex dj2_age dj2_mrry dj2_away dj2_edu dj2_wage dj2_farm dj2_nfe ///
				deju3 dj3_relate dj3_sex dj3_age dj3_mrry dj3_away dj3_edu dj3_wage dj3_farm dj3_nfe ///
				deju4 dj4_relate dj4_sex dj4_age dj4_mrry dj4_away dj4_edu dj4_wage dj4_farm dj4_nfe ///
				defa1 df1_relate df1_sex df1_age df1_mrry df1_away df1_edu df1_wage df1_farm df1_nfe ///
				defa2 df2_relate df2_sex df2_age df2_mrry df2_away df2_edu df2_wage df2_farm df2_nfe ///
				defa3 df3_relate df3_sex df3_age df3_mrry df3_away df3_edu df3_wage df3_farm df3_nfe ///
				defa4 df4_relate df4_sex df4_age df4_mrry df4_away df4_edu df4_wage df4_farm df4_nfe ///
				defa5 df5_relate df5_sex df5_age df5_mrry df5_away df5_edu df5_wage df5_farm df5_nfe ///
				defa6 df6_relate df6_sex df6_age df6_mrry df6_away df6_edu df6_wage df6_farm df6_nfe ///
				defa7 df7_relate df7_sex df7_age df7_mrry df7_away df7_edu df7_wage df7_farm df7_nfe ///
				defa8 df8_relate df8_sex df8_age df8_mrry df8_away df8_edu df8_wage df8_farm df8_nfe ///
				defa9 df9_relate df9_sex df9_age df9_mrry df9_away df9_edu df9_wage df9_farm df9_nfe ///
				defa10 df10_relate df10_sex df10_age df10_mrry df10_away df10_edu df10_wage df10_farm df10_nfe 
	
	drop		mg1 mg2 mg3 mg4 df1 df2 df3 df4 df5 df6 df7 df8 df9 df10 indiv 
	
* label variables
	lab var		tenure	"How was [PLOT] acquired?"
	lab var 	mgmt1	"Who in the household manages this [PLOT]?"
	lab var 	mgmt2	"Who in the household manages this [PLOT]?"
	lab var 	mgmt3	"Who in the household manages this [PLOT]?"
	lab var 	mgmt4	"Who in the household manages this [PLOT]?"
	lab var		deju1	"De jure Owner"
	lab var		deju2	"De jure Owner"
	lab var		deju3	"De jure Owner"
	lab var		deju4	"De jure Owner"
	lab var 	defa1	"De facto Owner"
	lab var 	defa2	"De facto Owner"
	lab var 	defa3	"De facto Owner"
	lab var 	defa4	"De facto Owner"
	lab var 	defa5	"De facto Owner"
	lab var 	defa6	"De facto Owner"
	lab var 	defa7	"De facto Owner"
	lab var 	defa8	"De facto Owner"
	lab var 	defa9	"De facto Owner"
	lab var 	defa10	"De facto Owner"
	lab var 	wave	"Wave"
	
* save final merged file
	qui: 	compress
	count
	isid 	hhid plotid
	save 	"$export/demo_w4", replace	
	
* close the log
	log	close

/* END */	
	