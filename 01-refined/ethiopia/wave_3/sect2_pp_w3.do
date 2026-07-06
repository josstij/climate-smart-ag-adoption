* Project: lsms gender
* Created on: oct 2025
* Created by: jt
* Edited on: 25 oct 2025
* Edited by: jt
* Stata v.19.5

* does
	* inputs wave3 dataset for post planting parcel ownership data
	* cleans up gendered plot owner variables 
	* outputs file containing defacto owners, dejure owners, tenure
	* no beqth
		
* assumes
	* access to raw data 

* TO DO:
	* DONE !!
	

************************************************************************
**# 0 - setup
************************************************************************

* define paths
	global	root 	"$data/raw_lsms_data/ethiopia/wave_3/raw"
	global	export 	"$data/lsms_gender_data/01-refined_data/ethiopia/wave_3"
	global	logout 	"$data/lsms_gender_data/01-refined_data/ethiopia/logs"
	
* open log 
	cap		log		close
	log		using	"$logout/sect2_pp_w3", append
	

************************************************************************
**# 1 - clean data
************************************************************************

* load data
		use			"$root/sect2_pp_w3", clear

* rename variables
	rename		(pp_saq07 pp_s2q03 pp_s2q03b pp_s2q03c_a pp_s2q03c_b ///
					pp_s2q04 pp_s2q06_a pp_s2q06_b ) ///
					(mgmt1 tenure collat defa1 defa2 title deju1 deju2)

* recode yes no for collat
	replace		collat = 0 if collat == 2
	lab			define yesno 0 "no" 1 "yes"
	lab			value collat yesno
	
* recode yes no for title
	replace 	title = 0 if title ==2
	lab			value title yesno
	
* keep essential variables
 	keep		holder_id household_id ea_id parcel_id mgmt1 tenure ///
					collat defa1 defa2 title deju1 deju2

	duplicates drop household_id parcel_id, force	

	
************************************************************************
**# 2 - end matter
************************************************************************

* save file
	qui: 			compress
	isid			holder_id parcel_id
	save 			"$export/sect2_pp_w3", replace
	
* close the log
	log				close

/* END */