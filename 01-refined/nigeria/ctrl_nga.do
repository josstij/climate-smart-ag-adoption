* Project: lsms gender
* Created on: nov 2025
* Created by: ns
* Edited on: 7 april
* Edited by: jdm
* Stata v.18.5

* does
	* Executes all wave specific Nigeria hh .do files
	* outputs finished houshold data set ready to merge with weather
		
* assumes
	* wave-specific .do files
		
* TO DO:
	* done
    
    
************************************************************************
**# 0 - setup
************************************************************************

    loc dofile = "$code/01-refined/nigeria"
	
	
************************************************************************
**# 1 - run individual HH cleaning .do files
************************************************************************

* loops through four waves of nga hh code
* starting with running all individual hh data files

* define local with all sub-folders in it
    loc folderList : dir "`dofile'" dirs "wave_*"
	
* define local with all files in each sub-folder
    foreach folder of loc folderList {
		
		
    * loop through each NGA file in the folder local
        loc NGA : dir "`dofile'/`folder'" files "sect*.do"
    
    * loop through each file in the above local
        foreach file in `NGA' {
        
        * run each individual file
            do "`dofile'/`folder'/`file'"     
    }       
}

	
/* END */