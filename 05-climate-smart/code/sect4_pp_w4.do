* Project: lsms csa
* Created on: july 2026
* Created by: jt
* Edited on: july 2026
* Edited by: jt
* Stata v.19.5

* does
	* inputs wave4 dataset for post planting crop roster csa data
	* cleans up csa variables 
	* outputs file containing improved seed indicator
	
		
* assumes
	* access to raw data 

* TO DO:
	* DONE !!
	

************************************************************************
**# 0 - setup
************************************************************************

* load project setup
	do		"C:/Users/tijer/git/UROC/climate-smart-ag-adoption/05-climate-smart/code/00_setup.do"

* define paths
	global	root		"$raw_data/ethiopia/wave_4/raw"
	global	export		"$clean_data/ethiopia/wave_4"
	global	logout		"$cs_logs"
	
* open log
	cap		log			close
	log		using		"$logout/sect4_pp_w4", append
	

************************************************************************
**# 1 - inspect raw data
************************************************************************

* load raw Section 4 data
	use			"$root/sect4_pp_w4", clear

* inspect identifiers and seed question
	describe	holder_id parcel_id field_id s4q11

* inspect labeled and numeric response categories
	tab			s4q11, missing
	tab			s4q11, missing nolabel

* check whether fields contain multiple crop records
	duplicates	report holder_id parcel_id field_id
	
	
	
	