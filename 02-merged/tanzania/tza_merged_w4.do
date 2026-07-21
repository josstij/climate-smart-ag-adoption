* Project: lsms gender
* Created on: may 2026
* Created by: ns
* Edited on: 10 july 2026
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
	global			root 	"$data/lsms_gender_data/01-refined_data/tanzania/wave_4"
	global			export 	"$data/lsms_gender_data/02-merged_data/tanzania/wave_4"
	global			logout 	"$data/lsms_gender_data/02-merged_data/tanzania/logs"

* open log
	cap		log		close
	log				using 	"$logout/tza_merged_w4", append


************************************************************************
**# 1 - merge individual characteristics
************************************************************************

* load individual roster
	use				"$root/HH_SEC_B_w4", clear

* check unique id
	isid			hhid indidy4

* replace edu for 5+
	replace			edu = 0 if edu == . & age > 4

* rename
	rename			indidy4 indiv

* save file
	qui:			compress
	isid			hhid indiv
	save			"$export/indiv_demo", replace


************************************************************************
**# 2 - merge individual characteristics into ag files
************************************************************************

************************************************************************
**### 2.2.1 - merge managers 1-4
************************************************************************

* not using mgmt4 because it is requiring network roster 1 which is strg

* loop for mgmt 1 - 3
	forvalues 	i = 1/3 {

    * load individual demographic file
		use				"$export/indiv_demo", clear

    * create merge ID for manager i
		rename			indiv mgmt`i'

    * merge with the agricultural file
		merge			1:m hhid mgmt`i' using "$root/AG_SEC_3A_w4"

    * rename demographic variables
		local demo relate sex age mrry away edu wage farm nfe

		foreach v of varlist `demo' {
			rename			`v' mg`i'_`v'
		}

	* drop individuals who don't manage plots & plots that only have 1 mananger
		drop			if 	_merge != 3

	* drop non mg`i' vars securely
		rename			mgmt`i' mg`i'
		drop			mgmt* defa* deju* tenure _merge
		lab var			mg`i' "plot manager `i'"

	* check unique id
		isid			hhid plotnum mg`i'

    * save temp file for manager i
		tempfile		mgmt`i'
		save			"`mgmt`i''", replace
	}

* merge manager files
	use				"$root/AG_SEC_3A_w4", clear

* loop over managers 1 to 4 and merge sequentially
	forvalues 	i = 1/3 {

		merge			m:1 hhid plotnum using "`mgmt`i''", nogen
	}

	drop			defa* deju*

* save final merged file
	qui:			compress
	isid			hhid plotnum
	tempfile		mgmt
	save			"`mgmt'", replace


************************************************************************
**### 2.2.2 - merge deju1-2
************************************************************************

* loop for cert 1 & 2
	forvalues	i = 1/2 {

* load individual roster
		use				"$export/indiv_demo", clear

* create cert1 ID
		rename			indiv deju`i'

* merge each file for each manager
		merge			1:m hhid deju`i' using "$root/AG_SEC_3A_w4"

* keep only matched observations
		keep			if _merge == 3
		drop			mgmt* defa* tenure _merge

* rename demographic variables to own0 prefix
		local demo relate sex age mrry away edu wage farm nfe

		foreach v of varlist `demo' {
			rename			`v' dj`i'_`v'
		}


* check unique id
		isid			hhid plotnum deju`i'

* save temp file for manager i
		tempfile		deju`i'
		save			"`deju`i''", replace

	}

* merge manager files
	use				"$root/AG_SEC_3A_w4", clear

* loop over managers 1 to 2 and merge sequentially
	forvalues 	i = 1/2 {

		merge			m:1 hhid plotnum using "`deju`i''", nogen
	}

* drop variables not needed
	drop			defa* mgmt*

* save final merged file
	qui:			compress
	isid			hhid plotnum
	tempfile		deju
	save			"`deju'", replace


************************************************************************
**### 2.3.3 - merge defa 1-2
************************************************************************

* loop for defa 1 - 2
	forvalues 	i = 1/2 {

* load individual demographic file
		use				"$export/indiv_demo", clear

* create merge ID for owners
		rename			indiv defa`i'

* merge with the agricultural file
		merge			1:m hhid defa`i' using "$root/AG_SEC_3A_w4"

* rename demographic variables
		local demo relate sex age mrry away edu wage farm nfe

		foreach v of varlist `demo' {
			rename			`v' df`i'_`v'
		}
* drop individuals who don't own plots
		drop			if 	_merge != 3

* drop non o`i' vars securely
		rename			defa`i' df`i'
		drop			mgmt* defa* deju* tenure _merge
		lab var			df`i' "plot own `i'"

* check unique id
		isid			hhid plotnum df`i'

* save temp file for manager i
		tempfile		defa`i'
		save			"`defa`i''", replace
	}

* merge manager files
	use				"$root/AG_SEC_3A_w4", clear

* loop merge owner files
	forvalues 	i = 1/2 {

		merge			m:1 hhid plotnum using "`defa`i''", nogen
	}

	drop			mgmt*

* save final merged file
	qui:			compress
	isid			hhid plotnum
	tempfile		defa
	save			"`defa'", replace




************************************************************************
**# 3 - merge all
************************************************************************
	use				"`mgmt'", clear

	isid			hhid plotnum

	count

	merge			1:1 hhid plotnum using "`deju'", gen(_deju1)

	merge			1:1 hhid plotnum using "`defa'", gen(_defa)

	count

	drop			_deju1 _defa

	gen			wave = 4


************************************************************************
**# 4 - end matter
************************************************************************

* order variables
	order		wave hhid plotnum tenure ///
				mgmt1 mg1_relate mg1_sex mg1_age mg1_mrry mg1_away mg1_edu mg1_wage mg1_farm mg1_nfe ///
				mgmt2 mg2_relate mg2_sex mg2_age mg2_mrry mg2_away mg2_edu mg2_wage mg2_farm mg2_nfe ///
				mgmt3 mg3_relate mg3_sex mg3_age mg3_mrry mg3_away mg3_edu mg3_wage mg3_farm mg3_nfe ///
				deju1 dj1_relate dj1_sex dj1_age dj1_mrry dj1_away dj1_edu dj1_wage dj1_farm dj1_nfe ///
				deju2 dj2_relate dj2_sex dj2_age dj2_mrry dj2_away dj2_edu dj2_wage dj2_farm dj2_nfe ///
				defa1 df1_relate df1_sex df1_age df1_mrry df1_away df1_edu df1_wage df1_farm df1_nfe ///
				defa2 df2_relate df2_sex df2_age df2_mrry df2_away df2_edu df2_wage df2_farm df2_nfe

	drop			mg1 mg2 mg3

* label variables
	lab var			deju1	"De jure Owner 1"
	lab var			deju2	"De jure Owner 2"
	lab var			wave	"Wave"

* save final merged file
	qui:			compress
	count
	isid			hhid plotnum
	save			"$export/tza_merged_w4", replace

* close the log
	log				close

/* END */


