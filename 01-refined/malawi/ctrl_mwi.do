* Project: lsms gender
* Created on: April 1 2026
* Created by: ns
* Edited on: 20 April 2026
* Edited by: ns,js
* Stata v.18.5

* does
		* runs every file
		
* assumes
		* access to refined data

		
************************************************************************
**# 0 - setup
************************************************************************

    loc dofile = "$code/01-refined/malawi"
	
************************************************************************
**# 1 - run individual HH & AG cleaning .do files
************************************************************************

* loops through waves of malawi code
* starting with running all individual data files

* define local with all sub-folders in it
    loc folderList : dir "`dofile'" dirs "wave_*"
	
* define local with all files in each sub-folder
    foreach folder of loc folderList {
		
    * loop through each MWI file in the folder local
        loc MWI : dir "`dofile'/`folder'" files "*_w*.do"
    
    * loop through each file in the above local
        foreach file in `MWI' {
        
        * run each individual file
            do "`dofile'/`folder'/`file'"     
    }       
}


/* END */