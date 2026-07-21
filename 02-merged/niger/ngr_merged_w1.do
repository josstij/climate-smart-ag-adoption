* Project: lsms gender
* Created on: june 2026
* Created by: js
* Edited on: 8 July 2026
* Edited by: jdm
* Stata v.19.5

* does
	* merges wave 1 demographic characteristics onto parcel-level agricultural data
	* outputs wave 1 merged file ready for append

* assumes
	* access to raw data

* TO DO:
	* complete


************************************************************************
**# 0 - setup
************************************************************************

* define paths
	global			root 	"$data/lsms_gender_data/01-refined_data/niger/wave_1"
	global			export 	"$data/lsms_gender_data/02-merged_data/niger/wave_1"
	global			logout 	"$data/lsms_gender_data/02-merged_data/niger/logs"
	
* open log
	cap		log		close
	log				using	"$logout/ngr_merged_w1", append


************************************************************************
**# 1 - clean data
************************************************************************

* load data
	use				"$root/hecvmaind_p1p2_en_w1", clear

* save file
	qui:			compress
	isid			hid indiv
	save			"$export/indiv_demo", replace


************************************************************************
**# 2 - merge deju, defa, and mgmt
************************************************************************

* define macro for demographic variables to easily rename them
	local demo relate sex age mrry away edu wage farm nfe

* loop for mgmt1, defa1, deju1
	foreach			role in deju1 defa1 mgmt1 {
		
	* load individual roster
		use				"$export/indiv_demo", clear
		
	* create ID
		gen				`role' = indiv
		
	* merge with plot data
		merge			1:m 	hid grappe menage `role' using "$root/ecvmaas1_p1_en_w1"
		
	* keep only matched observations
		keep			if 	_merge == 3
		drop			_merge
		
	* determine prefix
		local prefix ""
		if "`role'" == "deju1" local prefix "dj1_"
		if "`role'" == "defa1" local prefix "df1_"
		if "`role'" == "mgmt1" local prefix "mg1_"
		
	* rename demographic variables
		foreach			v of varlist `demo' {
			rename			`v' `prefix'`v'
		}
		
		isid			hid grappe menage parcel_id field_id
		
	* save tempfile
		tempfile		`role'_temp
		save			"``role'_temp'", replace
	}

	* load base plot data
		use				"$root/ecvmaas1_p1_en_w1", clear
	
		count			if 	missing(parcel_id) | missing(field_id)

* merge all owners/managers back onto plot data
	foreach			role in deju1 defa1 mgmt1 {
		merge			1:1 	hid grappe menage parcel_id field_id using "``role'_temp'", nogen
	}


* label variables
	lab var			deju1	"De jure Owner"

	gen				wave = 1
	lab var			wave "Wave"


************************************************************************
**# 3 - end matter
************************************************************************

* order variables
	order			wave hid grappe menage parcel_id field_id tenure ///
					mgmt1 mg1_relate mg1_sex mg1_age mg1_mrry mg1_away mg1_edu mg1_wage mg1_farm mg1_nfe ///
					deju1 dj1_relate dj1_sex dj1_age dj1_mrry dj1_away dj1_edu dj1_wage dj1_farm dj1_nfe ///
					defa1 df1_relate df1_sex df1_age df1_mrry df1_away df1_edu df1_wage df1_farm df1_nfe
					
* save final merged file
	qui:			compress
	count
	isid			hid grappe menage parcel_id field_id
	save			"$export/demo_w1", replace
	
* close the log
	log				close

/* END */
