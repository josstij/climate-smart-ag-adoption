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
							land_barrier_index) ///
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
	