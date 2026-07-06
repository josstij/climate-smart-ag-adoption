/* BEGIN */

* Project: lsms gender dynamics
* Created on: July 2025
* Created by: george hyland
* Edited on: 29 july 2025
* Edited by: alj
* Stata v.19.5

* does
		* graphs graphs graphs

* assumes

* to do
	* this file is a bit of a mess 

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
**# 1 - graphs
************************************************************************

* load data
		use			"$export/2019_final_merge", clear


* this one is okay but not great 		
twoway (scatter Calories_PerPerson_Day Portion_Female_Managed) ///
       (lfit Calories_PerPerson_Day Portion_Female_Managed), ///
       title("Calories vs % Female-Managed Plots") ///
       xtitle("% Female-Managed Plots") ///
       ytitle("Calories Consumed")	

* i think this is an improvement 				
twoway (scatter Calories_PerPerson_Day Portion_Female_Managed) ///
       (lowess Calories_PerPerson_Day Portion_Female_Managed), ///
       title("Calories vs % Female-Managed Plots")	
*** used in poster 
	  
* tried this but its not that great 	  
xtile fem = Portion_Female_Managed, nq(4)
graph box Calories_PerPerson_Day, over(fem, label(angle(0))) ///
    title("Calories per Person by Quartile of Female-Managed Plots")
	
* also tried some logging stuff and it was meh to bad to unintepretable 
	
* tried this but it doesn't really work 	   
graph box Portion_Female_Managed, over(fcs_category, label(angle(0))) ///
    title("Share of Female-Managed Plots by Food Consumption Score") ///
    ytitle("Share of Female-Managed Plots") 
		
* but mostly because this is so much better
vioplot Portion_Female_Managed, over(fcs_category) ///
    vertical ///
    title("Distribution of Female-Managed Plot Share by Food Score") ///
    ytitle("Share of Female-Managed Plots")	
*** used in poster 
	   
************************************************************************
**# 2 - end matter
************************************************************************
	
* close the log
	log	close

/* END */