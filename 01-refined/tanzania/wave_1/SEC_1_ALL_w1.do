* Project: lsms gender
* Created on: may 2026
* Created by: ns
* Edited on: 10 july 2026
* Edited by: jdm
* Stata v.18.5

* does
	* finds some of the demographic variables


* assumes
		* access to raw data

* TO DO:
		* done


************************************************************************
**# 0 - setup
************************************************************************

* define paths
	global			root 	"$data/raw_lsms_data/tanzania/wave_1/raw"
	global			export 	"$data/lsms_gender_data/01-refined_data/tanzania/wave_1"
	global			logout 	"$data/lsms_gender_data/01-refined_data/tanzania/logs"

* open log
	cap		log		close
	log				using 	"$logout/SEC_1_ALL_w1", append


************************************************************************
**# 1 - clean data for SEC_1A_ALL
************************************************************************

* load data
	use				"$root/SEC_1_ALL", clear

* gen variables
	rename			s1q2 age
	rename			s1q3 sex
	rename			s1q4 respond



************************************************************************
**# 2 - end matter
************************************************************************

* keep
	keep			hhid rosterid age sex

* drop missing
	drop			if 			missing(hhid) | missing(rosterid)

* save file
	qui:			compress
	isid			hhid rosterid
	save			"$export/SEC_1_ALL_w1", replace

* close the log
	log				close

/* END */


