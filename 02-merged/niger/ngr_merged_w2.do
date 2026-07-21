* Project: lsms gender
* Created on: July 2026
* Created by: jdm
* Edited on: 8 July 2026
* Edited by: jdm
* Stata v.19.5

* does
	* merges wave 2 demographic characteristics onto parcel-level agricultural data
	* outputs wave 2 merged file ready for append

* assumes
	* access to raw data

* TO DO:
	* complete


************************************************************************
**# 0 - setup
************************************************************************

* define paths
	global			root 	"$data/lsms_gender_data/01-refined_data/niger/wave_2"
	global			export 	"$data/lsms_gender_data/02-merged_data/niger/wave_2"
	global			logout 	"$data/lsms_gender_data/02-merged_data/niger/logs"
	
* open log
	cap		log		close
	log				using	"$logout/ngr_merged_w2", append


************************************************************************
**# 1 - clean data (Demographics)
************************************************************************

* load base demographic file
	use				"$root/ecvma2_ms01p1_w2.dta", clear
		
* merge education file
	merge			1:1 		indiv grappe menage extension using "$root/ecvma2_ms02p1_w2.dta", nogen

* merge labor file
	merge			1:1 		indiv grappe menage extension using "$root/ecvma2_ms04p1_w2.dta", nogen

* save file
	qui:			compress
	isid			indiv grappe menage extension
	save			"$export/indiv_demo", replace


************************************************************************
**# 2 - merge deju, defa, and mgmt
************************************************************************

* define macro for demographic variables to easily rename them
	local demo relate sex age mrry away edu wage farm nfe

* loop for mgmt1, deju1, deju2
	foreach			role in deju1 deju2 mgmt1 {
		
	* load individual roster
		use				"$export/indiv_demo", clear
		
	* create ID
		gen				`role' = indiv
		
	* merge with plot data
		merge			1:m 	grappe menage extension `role' using "$root/ecvma2_as1p1_w2"
		
	* keep only matched observations
		keep			if 	_merge == 3
		drop			_merge
		
	* determine prefix
		local prefix ""
		if "`role'" == "deju1" local prefix "dj1_"
		if "`role'" == "deju2" local prefix "dj2_"
		if "`role'" == "mgmt1" local prefix "mg1_"
		
	* rename demographic variables
		foreach			v of varlist `demo' {
			rename			`v' `prefix'`v'
		}
		
		isid			grappe menage extension parcel_id field_id
		
	* save tempfile
		tempfile		`role'_temp
		save			"``role'_temp'", replace
	}

* load base plot data
	use				"$root/ecvma2_as1p1_w2", clear

* merge all owners/managers back onto plot data
	foreach			role in deju1 deju2 mgmt1 {
		merge			1:1 	grappe menage extension parcel_id field_id using "``role'_temp'", nogen
	}


************************************************************************
**# 3 - standardize and end matter
************************************************************************

* standardizing ID casing to match wave 1
	
	count			if 	missing(parcel_id) | missing(field_id)

* label variables
	lab var			deju1	"Certificate Holder 1"
	lab var			deju2	"Certificate Holder 2"
	lab var			mgmt1	"Manager 1"
	
	gen				wave = 2
	lab var			wave "Wave"

* order variables
	order			wave hid hid2 grappe menage extension parcel_id field_id tenure ///
					mgmt1 mg1_relate mg1_sex mg1_age mg1_mrry mg1_away mg1_edu mg1_wage mg1_farm mg1_nfe ///
					deju1 dj1_relate dj1_sex dj1_age dj1_mrry dj1_away dj1_edu dj1_wage dj1_farm dj1_nfe ///
					deju2 dj2_relate dj2_sex dj2_age dj2_mrry dj2_away dj2_edu dj2_wage dj2_farm dj2_nfe
					
* save final merged file
	qui:			compress
	count
	isid			grappe menage extension parcel_id field_id
	save			"$export/demo_w2", replace
	
* close the log
	log				close

/* END */