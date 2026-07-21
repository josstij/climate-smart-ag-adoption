* Project: lsms gender
* Created on: May 2026
* Created by: js
* Edited on: 8 July 2026
* Edited by: jdm
* Stata v.16

* does
	* inputs wave 1 agricultural parcel data
	* cleans up gendered manager and owner variables (mgmt1, defa1, deju1)
	* outputs cleaned parcel data

* assumes
	* access to raw data

* TO DO:
	* complete


************************************************************************
**# 0 - setup
************************************************************************

* define paths
	global			root 	"$data/raw_lsms_data/niger/wave_1/raw"
	global			export 	"$data/lsms_gender_data/01-refined_data/niger/wave_1"
	global			logout 	"$data/lsms_gender_data/01-refined_data/niger/logs"
	
* open log
	cap		log		close
	log				using	"$logout/ecvmaas1_p1_en_w1", append


************************************************************************
**# 1 - clean data
************************************************************************

* load data
	use				"$root/ecvmaas1_p1_en.dta", clear

* rename variables
	rename			as01q16 tenure
	rename			as01q47 mgmt1
	rename			as01q17 defa1
	
* deju1 conditional on having a title document from as01q18 (1-4)
	gen				deju1  = defa1 if inlist(as01q18, 1, 2, 3, 4)
	lab var			deju1 "Id number of person who holds title document"
	
	rename			as01q03 field_id
	rename			as01q05 parcel_id
	
	* replace invalid IDs with missing
	replace			deju1 = . if deju1 == 0
	replace			defa1 = . if defa1 == 0
	replace			mgmt1 = . if mgmt1 == 0 | mgmt1 == 98 | mgmt1 == 99
	
	* keep essential variables
	keep			hid field_id parcel_id tenure deju1 defa1 mgmt1 grappe menage


************************************************************************
**# 2 - end matter
************************************************************************

* save file
	isid			hid parcel_id field_id
	qui:			compress
	save			"$export/ecvmaas1_p1_en_w1", replace

* close the log
	log				close

/* END */	
