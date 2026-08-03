* Project: climate smart ag adoption
* Created on: july 2026
* Created by: jt
* Edited on: 30 july 2026
* Edited by: jt
* Stata v.18.5

	* This file:
		* 1. opens the final Ethiopia CSA regression data
		* 2. defines the regression variables and analysis samples
		* 3. estimates the four CSA outcome specifications
		* 4. stores and exports the final regression results


************************************************************************
**# 0 - setup
************************************************************************

	clear all
	set more off

* load project setup
	do					"C:/Users/tijer/git/UROC/climate-smart-ag-adoption/05-climate-smart/code/00_setup.do"

* define paths
	global	root		"$clean_data/ethiopia"
	global	export		"$cs_output"
	global	logout		"$cs_logs"

* open log
	cap					log close

	log					using ///
							"$logout/final_results.log", ///
							replace text


************************************************************************
**# 1 - open final regression data
************************************************************************

* open final regression data
	use					"$root/eth_csa_regression.dta", clear

* confirm field-wave identifiers are unique
	isid				wave holder_id parcel_id field_id

* confirm final sample size
	assert				_N == 75033

* inspect observations by wave
	tab					wave, missing
	
	
************************************************************************
**# 2 - define regression variables
************************************************************************

* define barrier-domain indices
	local barriers		econ_barrier_index ///
						inst_barrier_index ///
						land_barrier_index

* define manager characteristics
	local manager		female_manager ///
						manager_age ///
						manager_age_sq ///
						manager_lowedu
						
* construct additional manager controls
	gen					manager_not_head = ///
						mg1_relat != 1 ///
						if !missing(mg1_relat)

	gen					manager_married = ///
						inlist(mg1_mrry, 2, 3) ///
						if inrange(mg1_mrry, 1, 6)

	label variable		manager_not_head ///
						"Primary manager is not household head"

	label variable		manager_married ///
						"Primary manager is married"

* define candidate controls for variable selection
	local candidates	manager_not_head ///
						manager_married ///
						mg1_farm ///
						mg1_wage
						
	misstable 			summarize `candidates'

* inspect missingness in outcomes and explanatory variables
	misstable summarize ///
						csa_pca_index ///
						any_csa ///
						csa_count ///
						csa_irr csa_seed csa_soil csa_cons ///
						`barriers' ///
						`manager'
	
* inspect region fixed-effect availability
	misstable summarize	admin_1

	tab					wave admin_1, missing
	
* search for alternative region variables
	lookfor				region

	describe			admin_*
	
* inspect Wave 5 region variable
	tab					wave admin_1, missing

************************************************************************
**# 3 - define common regression sample
************************************************************************

* count missing explanatory variables and region fixed effects
	egen				rhs_missing = rowmiss( ///
						`barriers' ///
						`manager' ///
						admin_1)

* identify observations with complete explanatory variables
	gen					sample_rhs = rhs_missing == 0

	label variable		sample_rhs ///
						"Complete RHS and region-FE sample"

* inspect common regression sample by wave
	tab					wave sample_rhs, missing
	
	
************************************************************************
**# 4 - define outcome-specific samples
************************************************************************

* define outcome-specific regression samples
	gen					sample_pca = ///
						sample_rhs == 1 & ///
						!missing(csa_pca_index)

	gen					sample_any = ///
						sample_rhs == 1 & ///
						!missing(any_csa)

	gen					sample_count = ///
						sample_rhs == 1 & ///
						!missing(csa_count)

	gen					sample_irr = ///
						sample_rhs == 1 & ///
						!missing(csa_irr)

	gen					sample_seed = ///
						sample_rhs == 1 & ///
						!missing(csa_seed)

	gen					sample_soil = ///
						sample_rhs == 1 & ///
						!missing(csa_soil)

	gen					sample_cons = ///
						sample_rhs == 1 & ///
						!missing(csa_cons)
						
* count missing candidate controls
	egen				candidate_missing = rowmiss( ///
						`candidates')

* define variable-selection samples
	gen					sample_select_pca = ///
						sample_pca == 1 & ///
						candidate_missing == 0

	gen					sample_select_any = ///
						sample_any == 1 & ///
						candidate_missing == 0

	gen					sample_select_count = ///
						sample_count == 1 & ///
						candidate_missing == 0

* inspect variable-selection sample sizes
	tabstat				sample_select_pca ///
						sample_select_any ///
						sample_select_count, ///
						by(wave) ///
						statistics(sum)

* inspect regression sample sizes by wave
	tabstat				sample_pca ///
						sample_any ///
						sample_count ///
						sample_irr ///
						sample_seed ///
						sample_soil ///
						sample_cons, ///
						by(wave) ///
						statistics(sum)
	
	
************************************************************************
**# 5 - estimate pca outcome model
************************************************************************

* create numeric holder cluster identifier
	egen				holder_cluster = group(holder_id)

* estimate PCA outcome using barrier domains
	regress				csa_pca_index ///
						`barriers' ///
						`manager' ///
						i.wave i.admin_1 ///
						if sample_pca == 1, ///
						vce(cluster holder_cluster)

* store PCA model
	estimates store		pca_domains
	
	
************************************************************************
**# 6 - estimate any-csa outcome model
************************************************************************

* estimate linear probability model for any CSA adoption
	regress				any_csa ///
						`barriers' ///
						`manager' ///
						i.wave i.admin_1 ///
						if sample_any == 1, ///
						vce(cluster holder_cluster)

* store any-CSA model
	estimates store		any_domains
	
	
************************************************************************
**# 7 - estimate csa-count outcome model
************************************************************************

* estimate OLS model for number of adopted CSA practices
	regress				csa_count ///
						`barriers' ///
						`manager' ///
						i.wave i.admin_1 ///
						if sample_count == 1, ///
						vce(cluster holder_cluster)

* store CSA-count model
	estimates store		count_domains
	
	
************************************************************************
**# 8 - estimate practice-specific models
************************************************************************

* estimate irrigation-adoption model
	quietly regress		csa_irr ///
						`barriers' ///
						`manager' ///
						i.wave i.admin_1 ///
						if sample_irr == 1, ///
						vce(cluster holder_cluster)

	estimates store		irr_domains

* estimate improved-seed adoption model
	quietly regress		csa_seed ///
						`barriers' ///
						`manager' ///
						i.wave i.admin_1 ///
						if sample_seed == 1, ///
						vce(cluster holder_cluster)

	estimates store		seed_domains

* estimate soil-management adoption model
	quietly regress		csa_soil ///
						`barriers' ///
						`manager' ///
						i.wave i.admin_1 ///
						if sample_soil == 1, ///
						vce(cluster holder_cluster)

	estimates store		soil_domains

* estimate conservation-practice adoption model
	quietly regress		csa_cons ///
						`barriers' ///
						`manager' ///
						i.wave i.admin_1 ///
						if sample_cons == 1, ///
						vce(cluster holder_cluster)

	estimates store		cons_domains

* display coefficients of primary interest
	estimates table		irr_domains ///
						seed_domains ///
						soil_domains ///
						cons_domains, ///
						keep(`barriers' `manager') ///
						b(%9.3f) ///
						se(%9.3f) ///
						stats(N r2)
	
	
************************************************************************
**# 9 - estimate overall-barrier models
************************************************************************

* define overall barrier specification
	local overall_rhs	overall_barrier_index ///
						`manager'

* estimate PCA model using overall barrier index
	quietly regress		csa_pca_index ///
						`overall_rhs' ///
						i.wave i.admin_1 ///
						if sample_pca == 1, ///
						vce(cluster holder_cluster)

	estimates store		pca_overall

* estimate any-CSA model using overall barrier index
	quietly regress		any_csa ///
						`overall_rhs' ///
						i.wave i.admin_1 ///
						if sample_any == 1, ///
						vce(cluster holder_cluster)

	estimates store		any_overall

* estimate CSA-count model using overall barrier index
	quietly regress		csa_count ///
						`overall_rhs' ///
						i.wave i.admin_1 ///
						if sample_count == 1, ///
						vce(cluster holder_cluster)

	estimates store		count_overall

* display overall-barrier results
	estimates table		pca_overall ///
						any_overall ///
						count_overall, ///
						keep(`overall_rhs') ///
						b(%9.3f) ///
						se(%9.3f) ///
						stats(N r2)
	
	
************************************************************************
**# 10 - estimate overall-barrier practice models
************************************************************************

* estimate irrigation model using overall barrier index
	quietly regress		csa_irr ///
						`overall_rhs' ///
						i.wave i.admin_1 ///
						if sample_irr == 1, ///
						vce(cluster holder_cluster)

	estimates store		irr_overall

* estimate improved-seed model using overall barrier index
	quietly regress		csa_seed ///
						`overall_rhs' ///
						i.wave i.admin_1 ///
						if sample_seed == 1, ///
						vce(cluster holder_cluster)

	estimates store		seed_overall

* estimate soil-management model using overall barrier index
	quietly regress		csa_soil ///
						`overall_rhs' ///
						i.wave i.admin_1 ///
						if sample_soil == 1, ///
						vce(cluster holder_cluster)

	estimates store		soil_overall

* estimate conservation model using overall barrier index
	quietly regress		csa_cons ///
						`overall_rhs' ///
						i.wave i.admin_1 ///
						if sample_cons == 1, ///
						vce(cluster holder_cluster)

	estimates store		cons_overall

* display overall-barrier practice results
	estimates table		irr_overall ///
						seed_overall ///
						soil_overall ///
						cons_overall, ///
						keep(`overall_rhs') ///
						b(%9.3f) ///
						se(%9.3f) ///
						stats(N r2)
	
	
************************************************************************
**# 11 - export main regression table
************************************************************************

* create domain-index table for aggregate CSA outcomes
	etable,				estimates( ///
							pca_domains ///
							any_domains ///
							count_domains) ///
						keep( ///
							econ_barrier_index ///
							inst_barrier_index ///
							land_barrier_index ///
							female_manager ///
							manager_age ///
							manager_age_sq ///
							manager_lowedu) ///
						mstat(N) ///
						mstat(r2) ///
						showstars ///
						showstarsnote ///
						column(index) ///
						title("Barrier domains and CSA adoption outcomes") ///
						note("All models include wave and region fixed effects. Standard errors are clustered by holder.")

* assign clear model-column labels
	collect label levels	cmdset ///
							1 "PCA index" ///
							2 "Any CSA" ///
							3 "CSA count", ///
							modify

* shorten explanatory-variable labels
	collect label levels	colname ///
							econ_barrier_index ///
								"Economic barriers" ///
							inst_barrier_index ///
								"Institutional barriers" ///
							land_barrier_index ///
								"Land and tenure barriers" ///
							female_manager ///
								"Female manager" ///
							manager_age ///
								"Manager age" ///
							manager_age_sq ///
								"Manager age squared" ///
							manager_lowedu ///
								"Manager cannot read or write", ///
							modify

* align identical coefficients across models
	collect layout		(colname#result[_r_b _r_se] ///
						 result[N r2]) ///
						(cmdset#stars)

* format table cells and headers
	collect style header	result[_r_b _r_se], ///
							level(hide)

	collect style header	cmdset, ///
							level(label)

	collect style cell	result[_r_b _r_se], ///
							nformat(%9.3f)

	collect style cell	result[_r_se], ///
							sformat("(%s)")

	collect style column,	extraspace(1)

	collect style putdocx, ///
							width(100%) ///
							halign(center)

* export corrected table
	collect export		"$export/table_domain_models.docx", ///
							replace
	
	
************************************************************************
**# 12 - estimate any-csa robustness model
************************************************************************

* estimate logit model for any CSA adoption
	logit				any_csa ///
						`barriers' ///
						`manager' ///
						i.wave i.admin_1 ///
						if sample_any == 1, ///
						vce(cluster holder_cluster)

* store logit robustness model
	estimates store		any_logit
	
	
************************************************************************
**# 13 - estimate csa-count robustness model
************************************************************************

* estimate Poisson model for number of adopted CSA practices
	poisson				csa_count ///
						`barriers' ///
						`manager' ///
						i.wave i.admin_1 ///
						if sample_count == 1, ///
						vce(cluster holder_cluster) irr

* store Poisson robustness model
	estimates store		count_poisson
	
	
************************************************************************
**# 14 - estimate practice-specific robustness models
************************************************************************

* estimate irrigation-adoption logit model
	quietly logit		csa_irr ///
						`barriers' ///
						`manager' ///
						i.wave i.admin_1 ///
						if sample_irr == 1, ///
						vce(cluster holder_cluster)

	estimates store		irr_logit

* estimate improved-seed adoption logit model
	quietly logit		csa_seed ///
						`barriers' ///
						`manager' ///
						i.wave i.admin_1 ///
						if sample_seed == 1, ///
						vce(cluster holder_cluster)

	estimates store		seed_logit

* estimate soil-management adoption logit model
	quietly logit		csa_soil ///
						`barriers' ///
						`manager' ///
						i.wave i.admin_1 ///
						if sample_soil == 1, ///
						vce(cluster holder_cluster)

	estimates store		soil_logit

* estimate conservation-adoption logit model
	quietly logit		csa_cons ///
						`barriers' ///
						`manager' ///
						i.wave i.admin_1 ///
						if sample_cons == 1, ///
						vce(cluster holder_cluster)

	estimates store		cons_logit

* display barrier-domain odds ratios separately
	foreach model in	irr_logit ///
						seed_logit ///
						soil_logit ///
						cons_logit {

		estimates table	`model', ///
							keep(`barriers') ///
							eform ///
							b(%9.3f) ///
							se(%9.3f) ///
							stats(N)
	}
	

************************************************************************
**# 15 - create adjusted-prediction figure
************************************************************************

* restore primary any-CSA model
	estimates restore	any_domains

* estimate adjusted probability across institutional-barrier values
	margins,			at( ///
							inst_barrier_index = ///
							(0(.10)1))

* plot adjusted probability of any CSA adoption
	marginsplot,		///
						title( ///
							"Institutional barriers and CSA adoption") ///
						xtitle( ///
							"Share of institutional barriers present") ///
						ytitle( ///
							"Adjusted probability of adoption") ///
						xlabel(0(.20)1) ///
						ylabel( ///
							.62 "62%" ///
							.64 "64%" ///
							.66 "66%" ///
							.68 "68%" ///
							.70 "70%" ///
							.72 "72%", ///
							angle(horizontal)) ///
						legend(off) ///
						name(inst_any_figure, replace)

* export poster figure
	graph export		"$export/figure_inst_barrier_any_csa.png", ///
						replace ///
						width(2400)

	graph export		"$export/figure_inst_barrier_any_csa.pdf", ///
						replace
						
						
************************************************************************
**# 16 - export compact latex table
************************************************************************

* clear previous table collection
	collect clear

* shorten barrier labels
	label variable		econ_barrier_index ///
						"Economic barriers"

	label variable		inst_barrier_index ///
						"Institutional barriers"

	label variable		land_barrier_index ///
						"Land and tenure barriers"

* create compact table of aggregate outcomes
	etable,				estimates( ///
							pca_domains ///
							any_domains ///
							count_domains) ///
						keep( ///
							econ_barrier_index ///
							inst_barrier_index ///
							land_barrier_index ///
							female_manager) ///
						column(index) ///
						mstat(N) ///
						mstat(r2) ///
						showstars ///
						showstarsnote ///
						title( ///
							"Barrier domains and CSA adoption outcomes") ///
						note( ///
							"Manager characteristics, wave fixed effects, and region fixed effects are included but not displayed. Standard errors are clustered by holder.")

* label model columns
	collect label levels	cmdset ///
							1 "PCA index" ///
							2 "Any CSA" ///
							3 "CSA count", ///
							modify

* export table-only LaTeX code
	collect export		"$export/table_domain_models.tex", ///
							tableonly replace
							
							
************************************************************************
**# 17 - create practice-specific coefficient figure
************************************************************************

* create temporary file for practice-specific coefficients
	tempname			coefpost
	tempfile			practice_coefs

	postfile			`coefpost' ///
						str20 outcome ///
						byte outcome_order ///
						str30 barrier ///
						byte barrier_order ///
						double b se ///
						using `practice_coefs', replace

* collect irrigation coefficients
	estimates restore	irr_domains

	post				`coefpost' ///
						("Irrigation") (1) ///
						("Economic barriers") (1) ///
						(_b[econ_barrier_index]) ///
						(_se[econ_barrier_index])

	post				`coefpost' ///
						("Irrigation") (1) ///
						("Institutional barriers") (2) ///
						(_b[inst_barrier_index]) ///
						(_se[inst_barrier_index])

	post				`coefpost' ///
						("Irrigation") (1) ///
						("Land and tenure barriers") (3) ///
						(_b[land_barrier_index]) ///
						(_se[land_barrier_index])

* collect improved-seed coefficients
	estimates restore	seed_domains

	post				`coefpost' ///
						("Improved seed") (2) ///
						("Economic barriers") (1) ///
						(_b[econ_barrier_index]) ///
						(_se[econ_barrier_index])

	post				`coefpost' ///
						("Improved seed") (2) ///
						("Institutional barriers") (2) ///
						(_b[inst_barrier_index]) ///
						(_se[inst_barrier_index])

	post				`coefpost' ///
						("Improved seed") (2) ///
						("Land and tenure barriers") (3) ///
						(_b[land_barrier_index]) ///
						(_se[land_barrier_index])

* collect soil-management coefficients
	estimates restore	soil_domains

	post				`coefpost' ///
						("Soil management") (3) ///
						("Economic barriers") (1) ///
						(_b[econ_barrier_index]) ///
						(_se[econ_barrier_index])

	post				`coefpost' ///
						("Soil management") (3) ///
						("Institutional barriers") (2) ///
						(_b[inst_barrier_index]) ///
						(_se[inst_barrier_index])

	post				`coefpost' ///
						("Soil management") (3) ///
						("Land and tenure barriers") (3) ///
						(_b[land_barrier_index]) ///
						(_se[land_barrier_index])

* collect conservation coefficients
	estimates restore	cons_domains

	post				`coefpost' ///
						("Conservation") (4) ///
						("Economic barriers") (1) ///
						(_b[econ_barrier_index]) ///
						(_se[econ_barrier_index])

	post				`coefpost' ///
						("Conservation") (4) ///
						("Institutional barriers") (2) ///
						(_b[inst_barrier_index]) ///
						(_se[inst_barrier_index])

	post				`coefpost' ///
						("Conservation") (4) ///
						("Land and tenure barriers") (3) ///
						(_b[land_barrier_index]) ///
						(_se[land_barrier_index])

	postclose			`coefpost'

* construct confidence intervals and plotting positions
	preserve

		use				`practice_coefs', clear

		gen					ci_low = b - 1.96 * se
		gen					ci_high = b + 1.96 * se

		gen					y_position = outcome_order
		replace				y_position = y_position - .18 ///
								if barrier_order == 1
		replace				y_position = y_position + .18 ///
								if barrier_order == 3

* plot practice-specific barrier coefficients
		twoway				///
			(rcap ci_low ci_high y_position ///
				if barrier_order == 1, ///
				horizontal ///
				lcolor(navy) ///
				lwidth(medthin)) ///
			(scatter y_position b ///
				if barrier_order == 1, ///
				msymbol(O) ///
				mcolor(navy) ///
				msize(medsmall)) ///
			(rcap ci_low ci_high y_position ///
				if barrier_order == 2, ///
				horizontal ///
				lcolor(cranberry) ///
				lwidth(medthin)) ///
			(scatter y_position b ///
				if barrier_order == 2, ///
				msymbol(D) ///
				mcolor(cranberry) ///
				msize(medsmall)) ///
			(rcap ci_low ci_high y_position ///
				if barrier_order == 3, ///
				horizontal ///
				lcolor(forest_green) ///
				lwidth(medthin)) ///
			(scatter y_position b ///
				if barrier_order == 3, ///
				msymbol(T) ///
				mcolor(forest_green) ///
				msize(medsmall)), ///
			xline(0, ///
				lpattern(dash) ///
				lcolor(gs8)) ///
			xlabel(-.30(.10).20, ///
				format(%4.1f) ///
				labsize(small)) ///
			ylabel( ///
				1 "Irrigation" ///
				2 "Improved seed" ///
				3 "Soil management" ///
				4 "Conservation", ///
				angle(horizontal) ///
				labsize(small) ///
				noticks) ///
			yscale(reverse) ///
			xtitle( ///
				"Change in adoption probability", ///
				size(medsmall)) ///
			ytitle("") ///
			title( ///
				"Barrier domains and CSA practice adoption", ///
				size(medium)) ///
			subtitle( ///
				"Linear probability estimates with 95% confidence intervals", ///
				size(small)) ///
			legend( ///
				order( ///
					2 "Economic" ///
					4 "Institutional" ///
					6 "Land/tenure") ///
				cols(3) ///
				position(6) ///
				ring(1) ///
				size(small) ///
				region(lcolor(none))) ///
			graphregion(color(white)) ///
			plotregion(color(white)) ///
			xsize(8.5) ///
			ysize(5.5) ///
			scheme(stcolor_alt) ///
			name(practice_coef_figure, replace)

* export practice-specific coefficient figure
		graph export		"$export/figure_practice_barrier_coefficients.png", ///
								replace ///
								width(3000)

		graph export		"$export/figure_practice_barrier_coefficients.pdf", ///
								replace

	restore
	
	
************************************************************************
**# 18 - export overall-barrier latex table
************************************************************************

* clear previous collection
	collect clear

* create compact overall-barrier table
	etable,				estimates( ///
							pca_overall ///
							any_overall ///
							count_overall) ///
						keep( ///
							overall_barrier_index) ///
						column(index) ///
						mstat(N) ///
						mstat(r2) ///
						showstars ///
						showstarsnote ///
						title( ///
							"Overall barriers and CSA adoption outcomes") ///
						note( ///
							"Manager characteristics, wave fixed effects, and region fixed effects are included but not displayed. Standard errors are clustered by holder.")

* label model columns
	collect label levels	cmdset ///
							1 "PCA index" ///
							2 "Any CSA" ///
							3 "CSA count", ///
							modify

* label displayed coefficient
	collect label levels	colname ///
							overall_barrier_index ///
							"Overall barrier index", ///
							modify

* export table-only LaTeX code
	collect export		"$export/table_overall_models.tex", ///
							tableonly replace
							
							
************************************************************************
**# 19 - identify dominant barrier by region
************************************************************************

* calculate average barrier-domain indices by region
	preserve

		keep				if !missing(admin_1)

		collapse			(mean) ///
								econ_barrier_index ///
								inst_barrier_index ///
								land_barrier_index, ///
								by(admin_1)

* identify the largest average barrier domain
		egen				max_barrier = rowmax( ///
								econ_barrier_index ///
								inst_barrier_index ///
								land_barrier_index)

		gen					dominant_barrier = 1 ///
								if econ_barrier_index == max_barrier

		replace				dominant_barrier = 2 ///
								if inst_barrier_index == max_barrier

		replace				dominant_barrier = 3 ///
								if land_barrier_index == max_barrier

* label dominant barrier domains
		label define		dominant_barrier_lbl ///
								1 "Economic barriers" ///
								2 "Institutional barriers" ///
								3 "Land and tenure barriers"

		label values		dominant_barrier ///
								dominant_barrier_lbl

* inspect regional results
		sort				admin_1

		list				admin_1 ///
								econ_barrier_index ///
								inst_barrier_index ///
								land_barrier_index ///
								dominant_barrier, ///
								noobs abbreviate(24)

* save regional data for mapping
		save				"$export/region_dominant_barrier.dta", ///
								replace

	restore
	
	
************************************************************************
**# 20 - estimate pca lasso model
************************************************************************

* select additional controls for PCA outcome
	lasso linear		csa_pca_index ///
						(`barriers' ///
						`manager' ///
						i.wave i.admin_1) ///
						`candidates' ///
						if sample_select_pca == 1, ///
						selection(cv) ///
						cluster(holder_cluster) ///
						rseed(20260730)

* store PCA lasso model
	estimates store		pca_lasso

* display selected variables and postselection coefficients
	lassocoef,			display(coef, postselection)
	
	
************************************************************************
**# 21 - estimate pca elastic-net model
************************************************************************

* select additional controls for PCA outcome
	elasticnet linear	csa_pca_index ///
						(`barriers' ///
						`manager' ///
						i.wave i.admin_1) ///
						`candidates' ///
						if sample_select_pca == 1, ///
						alpha(.25 .5 .75) ///
						selection(cv) ///
						cluster(holder_cluster) ///
						rseed(20260730)

* store PCA elastic-net model
	estimates store		pca_elastic

* display selected variables and postselection coefficients
	lassocoef,			display(coef, postselection)
	
	
************************************************************************
**# 22 - estimate any-csa lasso model
************************************************************************

* select additional controls for any CSA adoption
	lasso logit		any_csa ///
						(`barriers' ///
						`manager' ///
						i.wave i.admin_1) ///
						`candidates' ///
						if sample_select_any == 1, ///
						selection(cv) ///
						cluster(holder_cluster) ///
						rseed(20260730)

* store any-CSA lasso model
	estimates store		any_lasso

* display selected variables and postselection coefficients
	lassocoef,			display(coef, postselection)
	
	
************************************************************************
**# 23 - estimate any-csa elastic-net model
************************************************************************

* select additional controls for any CSA adoption
	elasticnet logit	any_csa ///
						(`barriers' ///
						`manager' ///
						i.wave i.admin_1) ///
						`candidates' ///
						if sample_select_any == 1, ///
						alpha(.25 .5 .75) ///
						selection(cv) ///
						cluster(holder_cluster) ///
						rseed(20260730)

* store any-CSA elastic-net model
	estimates store		any_elastic

* display selected variables and postselection coefficients
	lassocoef,			display(coef, postselection)
	
	
************************************************************************
**# 24 - create and inspect regional barrier means
************************************************************************

* load project setup
	do					"C:/Users/tijer/git/UROC/climate-smart-ag-adoption/05-climate-smart/code/00_setup.do"

* define paths needed for this section
	global root			"$clean_data/ethiopia"
	global export		"$cs_output"

* open final regression data
	use					"$root/eth_csa_regression.dta", clear

* calculate regional barrier-domain means
	keep				if !missing(admin_1)

	collapse			(mean) ///
						econ_barrier_index ///
						inst_barrier_index ///
						land_barrier_index, ///
						by(admin_1)

* save regional dataset
	save				"$export/region_dominant_barrier.dta", ///
						replace

* display regional barrier-domain means
	list				admin_1 ///
						econ_barrier_index ///
						inst_barrier_index ///
						land_barrier_index, ///
						noobs clean
					
	
************************************************************************
**# 25 - create regional barrier comparison figure
************************************************************************

* create region-name variable for graph labels
	capture drop		region_name

	decode				admin_1, ///
						gen(region_name)

* allow room for corrected region names
	recast str30		region_name

* correct region names for display
	replace				region_name = "Somali" ///
						if region_name == "Somalie"

	replace				region_name = "Gambela" ///
						if region_name == "Gambelia"

	replace				region_name = "Dire Dawa" ///
						if region_name == "Diredwa"

	replace				region_name = "Benishangul-Gumuz" ///
						if region_name == "Benshagul Gumuz"
						
* plot average barrier indices by region
	graph hbar			(mean) ///
						econ_barrier_index ///
						inst_barrier_index ///
						land_barrier_index, ///
						over(region_name, ///
							sort(1) ///
							descending ///
							label(labsize(small))) ///
						asyvars ///
						bar(1, color(navy)) ///
						bar(2, color(cranberry)) ///
						bar(3, color(forest_green)) ///
						ylabel(0(.20)1, ///
							format(%3.1f) ///
							angle(horizontal)) ///
						ytitle( ///
							"Mean barrier index (0–1)", ///
							size(medsmall)) ///
						title( ///
							"Regional barrier profiles in Ethiopia", ///
							size(medium)) ///
						subtitle( ///
							"Pooled means across five ESS waves", ///
							size(small)) ///
						legend( ///
							order( ///
								1 "Economic" ///
								2 "Institutional" ///
								3 "Land/tenure") ///
							rows(1) ///
							position(6) ///
							ring(1) ///
							size(small) ///
							region(lcolor(none))) ///
						graphregion(color(white)) ///
						plotregion(color(white)) ///
						xsize(8.5) ///
						ysize(6.5) ///
						name(region_barrier_figure, replace)

* export regional comparison figure
	graph export		"$export/figure_regional_barrier_profiles.png", ///
						replace ///
						width(3000)

	graph export		"$export/figure_regional_barrier_profiles.pdf", ///
						replace
						
						
						
						
	log			close
	
	
	
	
	
	
	
	
	
	