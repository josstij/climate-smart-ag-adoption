* Project: lsms csa
* Created on: july 2026
* Created by: jt
* Edited on: july 2026
* Edited by: jt
* Stata v.19.5

* does
	* loads the final Ethiopia CSA analysis dataset
	* constructs preliminary manager and land-rights variables
	* produces descriptive statistics and figures by survey wave
	* checks the coding of candidate explanatory variables
	
* assumes
	* eth_csa_analysis.dta has been created
	* CSA outcomes have been merged with the existing Ethiopia data
	* primary manager variables use the mg1 prefix
	
* TO DO:
	* finalize explanatory variables
	* produce CSA adoption descriptive results
	* estimate preliminary regression models
	* export preliminary regression results


	clear 	all
	set 	more off
	cap 	log close _all


************************************************************************
**# 0 - setup
************************************************************************

* load project setup
	do		"C:/Users/tijer/git/UROC/climate-smart-ag-adoption/05-climate-smart/code/00_setup.do"

* define paths
	global	root		"$clean_data/ethiopia"
	global	export		"$cs_output"
	global	logout		"$cs_logs"

* open log
	log		using		"$logout/preliminary_results.log", ///
				replace text


************************************************************************
**# 1 - open Ethiopia CSA analysis data
************************************************************************

* load final analysis data
	use		"$root/eth_csa_analysis", clear

* confirm analysis sample
	count
	tab		wave, missing

* confirm field-wave identifiers
	isid	wave holder_id parcel_id field_id

* inspect CSA outcomes
	describe	any_csa csa_count_obs ///
				csa_irr csa_seed csa_soil csa_cons

* check outcome distributions
	tab		any_csa, missing
	tab		csa_count_obs, missing

* summarize outcomes by survey wave
	tabstat	any_csa csa_count_obs, ///
				by(wave) ///
				statistics(n mean sd min max)


************************************************************************
**# 2 - construct preliminary variables
************************************************************************

* female primary manager
* confirm that 1 = male and 2 = female
	tab		mg1_sex, missing

	gen		female_manager = .
	replace	female_manager = 0 if mg1_sex == 1
	replace	female_manager = 1 if mg1_sex == 2

	label	define yesno01 0 "No" 1 "Yes", replace
	label	values female_manager yesno01
	label	variable female_manager ///
				"Female primary manager"

* primary manager age
	clonevar	manager_age = mg1_age

	label	variable manager_age ///
				"Primary manager age"

* lowest or no formal education category
* preserve the original mg1_edu variable
	gen		manager_lowedu = (mg1_edu == 98) ///
				if !missing(mg1_edu)

	label	values manager_lowedu yesno01
	label	variable manager_lowedu ///
				"Manager has little or no formal education"

* land certificate
* account for possible 0/1 and 1/2 coding
	tab		wave title, missing

	gen		has_certificate = .
	replace	has_certificate = 1 if title == 1
	replace	has_certificate = 0 if inlist(title, 0, 2)

	label	values has_certificate yesno01
	label	variable has_certificate ///
				"Household has parcel certificate"

* right to sell or use parcel as collateral
	tab		wave collat, missing

	gen		collateral_right = .
	replace	collateral_right = 1 if collat == 1
	replace	collateral_right = 0 if inlist(collat, 0, 2)

	label	values collateral_right yesno01
	label	variable collateral_right ///
				"Right to sell or use parcel as collateral"


************************************************************************
**# 3 - descriptive statistics by wave
************************************************************************

* display descriptive statistics
	tabstat	female_manager manager_age manager_lowedu ///
				mg1_farm mg1_nfe mg1_wage ///
				has_certificate collateral_right, ///
				by(wave) ///
				statistics(n mean sd) ///
				columns(statistics)

* clear previous collection
	collect	clear

* create preliminary characteristics table
	table	wave, ///
				statistic(frequency) ///
				statistic(mean female_manager) ///
				statistic(mean manager_age) ///
				statistic(mean manager_lowedu) ///
				statistic(mean mg1_farm) ///
				statistic(mean mg1_nfe) ///
				statistic(mean mg1_wage) ///
				statistic(mean has_certificate) ///
				statistic(mean collateral_right) ///
				nformat(%12.0fc frequency) ///
				nformat(%9.3f mean)

* add table title
	collect	title ///
				"Table 1. Preliminary Characteristics of Plot Managers and Land Rights by Survey Wave"

* export table
	collect	export ///
				"$export/table1_preliminary_characteristics.docx", ///
				replace


************************************************************************
**# 4 - female-managed observations by wave
************************************************************************

	preserve

* calculate female-managed share
	collapse	(mean) female_manager, by(wave)

	replace	female_manager = female_manager * 100

* create female-manager figure
	graph	bar female_manager, ///
				over(wave, relabel( ///
					1 "Wave 1" ///
					2 "Wave 2" ///
					3 "Wave 3" ///
					4 "Wave 4" ///
					5 "Wave 5")) ///
				bar(1, color(teal) lcolor(black)) ///
				blabel(bar, format(%4.1f) color(black)) ///
				ytitle("Female-managed observations (%)") ///
				title("Share of Female-Managed Observations by Survey Wave") ///
				subtitle("Wave years: 2011/12, 2013/14, 2015/16, 2018/19, 2021/22") ///
				note("Source: Ethiopia Socioeconomic Survey.") ///
				legend(off)

* export female-manager figure
	graph	export ///
				"$export/figure1_female_manager_bar.png", ///
				width(2000) replace

	restore


************************************************************************
**# 5 - land certification by wave
************************************************************************

	preserve

* retain observations with a valid certificate response
	keep	if !missing(has_certificate)

* calculate certificate share
	collapse	(mean) has_certificate, by(wave)

	replace	has_certificate = has_certificate * 100

* create land-certificate figure
	graph	bar has_certificate, ///
				over(wave, relabel( ///
					1 "Wave 1" ///
					2 "Wave 2" ///
					3 "Wave 3" ///
					4 "Wave 4" ///
					5 "Wave 5")) ///
				bar(1, color(teal) lcolor(black)) ///
				blabel(bar, format(%4.1f) color(black)) ///
				ytitle("Land observations with a certificate (%)") ///
				title("Share of Land Observations with a Certificate") ///
				subtitle("Wave years: 2011/12, 2013/14, 2015/16, 2018/19, 2021/22") ///
				note("Source: Ethiopia Socioeconomic Survey.") ///
				legend(off)

* export land-certificate figure
	graph	export ///
				"$export/figure2_land_certificate.png", ///
				width(2000) replace

	restore


************************************************************************
**# 6 - check coding of preliminary explanatory variables
************************************************************************

* inspect employment variables across waves
	tab		wave mg1_farm, missing
	tab		wave mg1_nfe, missing
	tab		wave mg1_wage, missing

* inspect variable coding
	codebook	mg1_farm mg1_nfe mg1_wage


************************************************************************
**# 7 - preliminary adoption regressions
************************************************************************

* check regression-variable availability
	misstable	summarize any_csa csa_count_obs ///
				female_manager manager_age manager_lowedu ///
				collateral_right

* Model 1: any CSA adoption, all waves
	regress		any_csa female_manager manager_age ///
				manager_lowedu i.wave, ///
				vce(cluster holder_id)

	estimates	store any_all

* Model 2: any CSA adoption with collateral rights, Waves 2-5
	regress		any_csa female_manager manager_age ///
				manager_lowedu collateral_right i.wave ///
				if wave >= 2, ///
				vce(cluster holder_id)

	estimates	store any_land

* Model 3: number of CSA practices, all waves
	regress		csa_count_obs female_manager manager_age ///
				manager_lowedu i.wave, ///
				vce(cluster holder_id)

	estimates	store count_all

* Model 4: number of CSA practices with collateral rights, Waves 2-5
	regress		csa_count_obs female_manager manager_age ///
				manager_lowedu collateral_right i.wave ///
				if wave >= 2, ///
				vce(cluster holder_id)

	estimates	store count_land
	
	
************************************************************************
**# 8 - export preliminary regression results
************************************************************************

* create and export preliminary regression table
	etable,	estimates(any_all any_land count_all count_land) ///
				cstat(_r_b, nformat(%9.3f)) ///
				cstat(_r_se, nformat(%9.3f) sformat("(%s)")) ///
				mstat(N) ///
				mstat(r2) ///
				column(index) ///
				showstars ///
				showstarsnote ///
				title("Table 2. Preliminary Associations with CSA Adoption") ///
				export("$export/table2_preliminary_regressions.docx", ///
					replace)
					
					
************************************************************************
**# 9 - CSA adoption by survey wave
************************************************************************

	preserve

* retain observations with a defined adoption outcome
	keep	if !missing(any_csa)

* calculate adoption share by wave
	collapse	(mean) any_csa, by(wave)

	replace	any_csa = any_csa * 100

* create CSA adoption figure
	graph	bar any_csa, ///
				over(wave, relabel( ///
					1 "Wave 1" ///
					2 "Wave 2" ///
					3 "Wave 3" ///
					4 "Wave 4" ///
					5 "Wave 5")) ///
				bar(1, color(teal) lcolor(black)) ///
				blabel(bar, format(%4.1f) color(black)) ///
				ytitle("Fields adopting any observed CSA practice (%)") ///
				title("Climate-Smart Agriculture Adoption by Survey Wave") ///
				subtitle("Ethiopia Socioeconomic Survey, Waves 1–5") ///
				legend(off)

* export CSA adoption figure
	graph	export ///
				"$export/figure3_csa_adoption_by_wave.png", ///
				width(2000) replace

	restore
	
	
************************************************************************
**# 7 - end matter
************************************************************************

* close log
	log		close