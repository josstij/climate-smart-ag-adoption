* Project: lsms gender
* Created on: oct 2025
* Created by: jt
* Edited on: 25 oct 2025
* Edited by: jt
* Stata v.19.5

* does
	* inputs wave5 dataset for post planting parcel ownership data
	* cleans up gendered plot owner variables 
	* outputs file containing defacto owners, dejure owners, tenure
		
* assumes
	* access to raw data 

* TO DO:
	* DONE !!
	

************************************************************************
**# 0 - setup
************************************************************************

* define paths
	global	root 	"$data/raw_lsms_data/ethiopia/wave_5/raw"
	global	export 	"$data/lsms_gender_data/01-refined_data/ethiopia/wave_5"
	global	logout 	"$data/lsms_gender_data/01-refined_data/ethiopia/logs"
	
* open log 
	cap		log		close
	log		using	"$logout/sect2_pp_w5", append
	

************************************************************************
**# 1 - clean data
************************************************************************

* load data
		use			"$root/sect2_pp_w5", clear

* rename variables
	rename		(s2q01a s2q05 s2q06 s2q07_1 s2q07_2 s2q03 s2q04b_1 s2q04b_2 ///
					s2q04b_3 s2q04b_4) ///
					(mgmt1 tenure collat defa1 defa2 title deju1 deju2 deju3 ///
					deju4)

* recode yes no
	replace		collat = 0 if collat == 2
	lab			define yesno 0 "no" 1 "yes"
	lab			value collat yesno
	
* keep essential variables
 	keep		holder_id household_id parcel_id mgmt1 tenure ea_id ///
					collat defa1 defa2 title deju1 deju2 deju3 deju4

		
************************************************************************
**# 2 - end matter
************************************************************************

* save file
	qui: 			compress
	isid			holder_id parcel_id
	save 			"$export/sect2_pp_w5", replace
	
* close the log
	log	close

/* END */