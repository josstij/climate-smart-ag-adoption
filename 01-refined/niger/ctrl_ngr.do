* Project: lsms gender
* Created on: june 2025
* Created by: ns
* Edited on: 8 July 2026
* Edited by: jdm
* Stata v.19.5

* does
	* Executes all wave specific Niger hh .do files
	* outputs finished houshold data set ready to merge with weather
		
* assumes
	* wave-specific .do files
		
* TO DO:
	* done
    
    
************************************************************************
**# 0 - setup
************************************************************************

    loc dofile = "$code/01-refined/niger"
	
************************************************************************
**# 1 - run individual HH cleaning .do files
************************************************************************

* loops through waves of ngr hh code
* starting with running all individual hh data files

* define local with all sub-folders in it
    loc folderList : dir "`dofile'" dirs "wave_*"
	
* define local with all files in each sub-folder
    foreach folder of loc folderList {
		
    * loop through each NGR file in the folder local
    * NOTE: Changed from "sect*.do" to "*.do" to catch all Niger ECVMA prefixes
        loc NGR : dir "`dofile'/`folder'" files "*.do"
    
    * loop through each file in the above local
        foreach file in `NGR' {
        
        * run each individual file
            do "`dofile'/`folder'/`file'"     
        }       
    }

	
/* END */