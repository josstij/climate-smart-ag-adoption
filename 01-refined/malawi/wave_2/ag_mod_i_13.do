* Project: lsms gender dynamics
* Created on: July 2025
* Created by: george hyland
* Edited on: 19 July 2025
* Edited by: george hyland
* Stata v.19.5

* does
		* cleans data for 2013 crop sales
		
* assumes

* to do
		* convert qty unit codes into strings
		* drop unsold crops??

		
************************************************************************
**# 0 - setup
************************************************************************

* define paths
	global root 	"$data/raw_lsms_data/malawi/harmonized/wave_2"
	global export 	"$data/lsms_gender_data/01-refined_data/malawi/wave_2"
	global logout 	"$data/lsms_gender_data/01-refined_data/malawi/logs"

* open log 
	cap log close 
	log using "$logout/ag_mod_i_13", append
	
	
************************************************************************
**# 1 - clean data
************************************************************************

* load data
		use			"$root/ag_mod_i_13", clear
		
* rename variables
		rename (ag_i0b ag_i01 ag_i01_1 ag_i02a ag_i02b ag_i03 ag_i12a ag_i12b ag_i12_1a ag_i12_1b ag_i13 ag_i14a ag_i14b ag_i19 ag_i21a ag_i21b ag_i21_1a ag_i21_1b ag_i22 ag_i23a ag_i23b ag_i38 ag_i40a ag_i40b ag_i42a ag_i42b) (crop_code sold id_resp qty_sld unit_sld rev_tot qty_1st unit_1st decmake1 decmake2 rev_1st revkeep1 revkeep2 sec_buy qty_2nd unit_2nd decmake3 decmake4 rev_2nd revkeep3 revkeep4 strg strg_qty strg_unit strg_rsn1 strg_rsn2)
		
		* convert unit codes to strings
		label define change 1 "Head" 2 "Spouse" 3 "Child" 4 "Grandchild" 5 "Niece/Nephew" 6 "Parent" 7 "Sibling" 8 "S/D In-Law" 9 "B/S In-Law" 10 "Grandparent" 11 "F/M In-Law" 12 "OtherRel" 13 "Serv_Rel" 14 "Lod_Rel" 15 "OtherNR" 16 "Other"
		label values (id_resp decmake1 decmake2 revkeep1 revkeep2 decmake3 decmake4 revkeep3 revkeep4) change
		
* keep essential variables (dropped. 16' & 19' don't have decision maker for sales)
		*keep y2_hhid crop_code sold id_resp qty_sld unit_sld rev_tot qty_1st unit_1st decmake1 decmake2 rev_1st revkeep1 revkeep2 sec_buy qty_2nd unit_2nd decmake3 decmake4 rev_2nd revkeep3 revkeep4 strg strg_qty strg_unit strg_rsn1 strg_rsn2
		
		keep y2_hhid crop_code sold id_resp qty_sld unit_sld rev_tot qty_1st unit_1st rev_1st revkeep1 revkeep2 sec_buy qty_2nd unit_2nd rev_2nd revkeep3 revkeep4 strg strg_qty strg_unit strg_rsn1 strg_rsn2
		
/*	drop if no crops sold (unsure if needed)
		decode sold, gen(sold2)
		drop if sold2 == "NO"
		drop if sold2 == ""
*/

	
************************************************************************
**# 2 - end matter
************************************************************************

* save file
	qui: 			compress
	save 			"$export/ag_i_13", replace
	
* close the log
	log	close

/* END */