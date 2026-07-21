* Project: lsms gender
* Created on: may 2026
* Created by: ns
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
	global			root 	"$data/raw_lsms_data/tanzania/wave_6/raw"
	global			export 	"$data/lsms_gender_data/01-refined_data/tanzania/wave_6"
	global			logout 	"$data/lsms_gender_data/01-refined_data/tanzania/logs"

* open log
	cap		log		close
	log				using 	"$logout/HH_SEC_B_w6", append


************************************************************************
**# 1 - clean data for AG_SEC_3A
************************************************************************

* load data
	use				"$root/HH_SEC_B", clear

* gen variables
	rename			hh_b02 sex
	rename			hh_b04 age
	rename			hh_b05 relate
	rename			hh_b10 away
	rename			hh_b19 mrry

	keep			sdd_hhid sdd_indid sex age relate away mrry

* merge with edu
	merge			1:1 			sdd_hhid sdd_indid using "$root/HH_SEC_C"
	rename			hh_c07 edu


	keep			sdd_hhid sdd_indid sex age relate away mrry edu

* merge with work
	merge			1:1 			sdd_hhid sdd_indid using "$root/HH_SEC_E1"

	rename			hh_e03 wage
	rename			hh_e05 nfe
	rename			hh_e07 farm

	rename			sdd_hhid hhid



************************************************************************
**# 2 - end matter
************************************************************************

* keep
	keep			hhid sdd_indid sex age relate away mrry edu wage farm nfe

* drop missing
	drop			if 			missing(hhid) | missing(sdd_indid)

* save file
	qui:			compress
	isid			hhid sdd_indid
	save			"$export/HH_SEC_B_w6", replace

* close the log
	log				close

/* END */

