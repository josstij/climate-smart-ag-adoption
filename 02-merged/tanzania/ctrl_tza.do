* Project: lsms gender
* Created on: june 2026
* Created by: ns
* Edited on: 10 july 2026
* Edited by: jdm
* Stata v.18.5

* does
	* Executes all wave specific Tanzania hh .do files
	* outputs finished houshold data set ready to merge with weather

* assumes
	* wave-specific .do files

* TO DO:
	* done


************************************************************************
**# 0 - setup
************************************************************************

	loc dofile = "$code/01-refined/tanzania"


************************************************************************
**# 1 - run individual HH cleaning .do files
************************************************************************

* loops through waves of tza hh code
* starting with running all individual hh data files

* define local with all sub-folders in it (e.g., wave_1, wave_2, etc.)
	loc folderList : dir "`dofile'" dirs "wave_*"

* define local with all files in each sub-folder
	foreach folder of loc folderList {

	* loop through each TZA file in the folder local
		loc TZA : dir "`dofile'/`folder'" files "*.do"

	* loop through each file in the above local
		foreach file in `TZA' {

		* ADD THIS LINE TO TRACK THE FILES:
			display "====== NOW RUNNING: `folder' / `file' ======"

		* run each individual file
			do "`dofile'/`folder'/`file'"
		}
	}

/* END */

