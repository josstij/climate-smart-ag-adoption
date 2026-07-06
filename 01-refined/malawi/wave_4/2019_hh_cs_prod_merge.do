* Project: lsms gender dynamics
* Created on: July 2025
* Created by: george hyland
* Edited on: 29 July 2025
* Edited by: george hyland
* Stata v.19.5

* does
		* cleans data for hh food consumption
		* keeps foods hh consumes & produces, excludes purchases
		* merges with ihs_foodconversion_factor_2020 and calorie_conversion to calculate hh caloric production

* assumes

* to do
		* missing calorie info on MAIZE UFA RAW MADEYA (BRAN FLOUR - UNPROCESSED) & whole groundnuts
	/*	
************************************************************************
**# 0 - setup
************************************************************************

* define paths
	global root 	"$data/MWI_2010-2019_IHPS_v06_M_Stata"
	global export 	"$data/refined/wave_4"
	global logout 	"$data/log"

* open log 
	cap log close 
	log using "$logout/mwi_wth_p", append


************************************************************************
**# 1 - clean data
************************************************************************

* load data
		use			"$root/hh_mod_g1_19", clear
	
* rename variables
		rename (hh_g03a hh_g06a hh_g06b hh_g06b_oth) (total_cons prd_qty unit_code Otherunit)
		
* merge with ihs_foodconversion_factor_2020
		merge		m:1 y4_hhid using "$root/hh_mod_a_filt_19"

		drop		_merge
	
/*		
    Result                      Number of obs
    -----------------------------------------
    Not matched                             0
    Matched                           451,276  (_merge==3)
    -----------------------------------------
	
*/
		
* drop foods not consumed/produced by hh
		decode hh_g01, gen(consumed)
		drop if consumed == "NO"
		drop if prd_qty == .
		drop if prd_qty == 0
		drop if unit_code == ""
		
* convert unit_name and subunit into one
		decode hh_g06c, gen(subunit)
		decode hh_g06b_label, gen(unit_name1)
		gen unit_name = unit_name1 + " " + subunit
		*drop if unit_name == "OTHER (SPECIFY) "
		
		decode hh_g02, gen(item_name)
		
* capitalize item_name
		replace item_name = strupper(item_name)
		
* convert region to string for joinby
		tostring region, generate(region1)
		gen region2 = ""
		
		replace region2="North" if region1=="100"
		replace region2="Central" if region1=="200"
		replace region2="South" if region1=="300"
		drop region region1
		rename region2 region
		
* joining hh_cs_prod with ihs_foodconversion_factor_2020
		joinby unit_code item_name item_name Otherunit region using "$data/refined/wave_4/2019_hh_cs_unitcode_merge", unmatched(master)
		
* dropping unmatched pairs (1,467 dropped)
		drop if factor==. & unit_name!="KILOGRAMME "
		drop _merge
		
* make kg unit = 1
		replace factor=1 if factor==.
		
* generate weight in grams for each item
		gen weight_grams = (prd_qty*factor)*1000
		
* changing names for consistency btwn datasets
		replace item_name="NKWANI" if item_name=="NKHWANI"
		replace item_name="PEARL MILLET" if item_name=="PEARL MILLET (MCHEWERE)"
		replace item_name="SORGHUM" if item_name=="SORGHUM (MAPIRA)"
		replace item_name="TANAPOSI RAPE" if item_name=="TANAPOSI/RAPE"
		replace item_name="OTHER CULTIVATED GREEN LEAFY VEGETABLE" if item_name=="OTHER CULTIVATED GREEN LEAFY VEGETABLES"
		replace item_name="SMALL ANIMAL- RABBIT, MICE" if item_name=="SMALL ANIMAL – RABBIT, MICE, ETC"
		replace item_name="MAIZE UFA MADEYA (BRAN FLOUR)" if item_name=="MAIZE UFA PROCESSED MADEYA (BRAN FLOUR - PROCESSED)"
		replace item_name="CHICKEN" if item_name=="CHICKEN - WHOLE"
		replace item_name="FINGER MILLET" if item_name=="FINGER MILLET (MAWERE)"
		replace item_name="CITRUS, NAARTJE, ORANGE, ETC." if item_name=="CITRUS – NAARTJE, ORANGE, ETC"
		replace item_name="BREAKFAST CEREAL" if item_name=="BREAKFAST CEREALS"
		replace item_name="GROUND BEAN" if item_name=="GROUND BEAN (NZAMA)"
		replace item_name="MUSHROOMS" if item_name=="MUSHROOM"
		
* keep relevant variables
		keep y4_hhid item_name prd_qty unit_code region unit_name Otherunit item_code factor weight_grams hhsize	
		
* merge with calorie_conversion
		merge		m:1  item_name using "$data/refined/wave_4/calorie_conversion"
		drop		_merge
		
		*sort y4_hhid
		
/*		Result                      Number of obs
    -----------------------------------------
    Not matched                         1,242
        from master                     1,149  (_merge==1)
        from using                         93  (_merge==2)

    Matched                             5,529  (_merge==3)
    -----------------------------------------
	
*/
		
* calculate calories
		gen calories_hh = ((weight_grams*cal_100g)/100)*(edible_p/100)
		gen calories_pp_day = (calories_hh/hhsize)/7
		
* keep relevant variables
		keep y4_hhid item_name prd_qty calories_hh calories_pp
		
		collapse (sum) calories_hh calories_pp, by(y4_hhid)

		
************************************************************************
**# 2 - end matter
************************************************************************

* save file
	qui: 			compress
	save 			"$export/2019_hh_cs_prod_merge", replace
	
* close the log
	log	close

/* END */