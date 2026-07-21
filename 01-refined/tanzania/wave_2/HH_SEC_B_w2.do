* Project: lsms gender
* Created on: may 2026
* Created by: js
* Edited on: 10 july 2026
* Edited by: jdm
* Stata v.18.5

* does

* assumes
		* access to raw data

* TO DO:
		* done


************************************************************************
**# 0 - setup
************************************************************************

* define paths
	global			root 	"$data/raw_lsms_data/tanzania/wave_2/raw"
	global			export 	"$data/lsms_gender_data/01-refined_data/tanzania/wave_2"
	global			logout 	"$data/lsms_gender_data/01-refined_data/tanzania/logs"

* open log
	cap		log		close
	log				using 	"$logout/HH_SEC_B_w2", append


************************************************************************
**# 1 - clean data for HH_SEC_B
************************************************************************

* load data
	use				"$root/HH_SEC_B", clear

* gen variables
	rename			hh_b02 sex
	rename			hh_b04 age
	rename			hh_b05 relate
	rename			hh_b09_1 away
	rename			hh_b19 mrry

	keep			y2_hhid indidy2 sex age relate away mrry

* merge with edu
	merge			1:1 			y2_hhid indidy2 using "$root/HH_SEC_C"

	rename			hh_c07 edu

	keep			y2_hhid indidy2 sex age relate away mrry edu

* merge with work
	merge			1:1 			y2_hhid indidy2 using "$root/HH_SEC_E1"

	* wage work
	gen				wage = (hh_e12 == 1 | hh_e13 == 1) if hh_e12 != . | hh_e13 != .
	
	* non-farm enterprise
	gen				nfe = (hh_e51 == 1 | hh_e52 == 1) if hh_e51 != . | hh_e52 != .
	
	* farm work
	gen				farm = (hh_e77 == 1 | hh_e79 == 1) if hh_e77 != . | hh_e79 != .

	rename			y2_hhid hhid


************************************************************************
**# 2 - end matter
************************************************************************

* keep
	keep			hhid indidy2 sex age relate away mrry edu wage farm nfe

* drop missing
	drop			if 			missing(hhid) | missing(indidy2)

* save file
	qui:			compress
	isid			hhid indidy2
	save			"$export/HH_SEC_B_w2", replace

* close the log
	log				close

/* END */
