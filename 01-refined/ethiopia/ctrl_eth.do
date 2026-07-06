* Project: lsms gender
* Created on: dec 2025
* Created by: jt
* Edited on: 8 dec 2025
* Edited by: jt
* Stata v.18.5

* does
		  * Executes all wave specific ethiopia hh .do files
		  * outputs finished houshold data set ready to merge with weather
		
* assumes
		  * subsidiary, wave-specific .do files
		
* TO DO:
		* DONE !!
    
    
* **********************************************************************
* 0 - setup
* **********************************************************************

* local pointing to where dofiles live
    loc dofile = "$code/01-refined\ethiopia"
	

* **********************************************************************
* 1 - run individual HH cleaning .do files
* **********************************************************************

* loops through four waves of nga hh code
* starting with running all individual hh data files

* define local with all sub-folders in it
    loc folderList : dir "`dofile'" dirs "wave_*"
	
* define local with all files in each sub-folder
    foreach folder of loc folderList {
		
		
    * loop through each eth file in the folder local
        loc eth : dir "`dofile'/`folder'" files "sect*.do"
    
    * loop through each file in the above local
        foreach file in `eth' {
        
        * run each individual file
            do "`dofile'/`folder'/`file'"     
    }       
}

/* END */