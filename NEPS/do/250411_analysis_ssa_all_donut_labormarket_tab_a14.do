********************************************************************************
*			pooled estimations
********************************************************************************
use "$results\ssa_panel_all_neu.dta", clear
est drop _all
cap erase "$results\SSA_lm_donut_neu_$date.csv"



* define globals
global instr i.after_week
global lin_plain run_week i.after_week#c.run_week 
global lin_full run_week i.after_week#c.run_week i.female i.bula6 i.yob  p_yos_mean p_yos_mean_m p_gerborn_ha_new p_gerborn_ha_new_m m_ageb4_T2 m_ageb4_T2_m ib1.JoinedKita_T2 ib1.OlderSibling_T2  SSY__6 i.RuralNEPSMZ


keep if w_t4_cal != 0
gen n1 = 1 if age == 40 


*donut
drop if inlist(run_week,-1,0,1,2)




*Panel A
	preserve
	keep if inrange(age,25,55)
	keep if inrange(yob,1945,1964)
	
	est drop _all

	
	ivreg2 migflow1_labour $instr $lin_plain  [aw=w_t4_cal] if mig_samp == 1	, cluster(ID_t) partial($lin_plain)	
	eststo lab_flow1_plain		
	qui sum migflow1_labour [aw=w_t4_cal]	 if e(sample)	
	scalar mig_mean = r(mean)
	qui estadd scalar mig_mean
	distinct ID_t if e(sample)
	scalar Indiv = r(ndistinct)
	qui estadd scalar Indiv		
	
	ivreg2 migflow5_labour $instr $lin_plain  [aw=w_t4_cal] 	if mig_samp == 1	, cluster(ID_t) partial($lin_plain)	
	eststo lab_flow5_plain		
	qui sum migflow5_labour [aw=w_t4_cal]	 if e(sample)	
	scalar mig_mean = r(mean)
	qui estadd scalar mig_mean
	distinct ID_t if e(sample)
	scalar Indiv = r(ndistinct)
	qui estadd scalar Indiv	

	ivreg2 migstock_labour $instr $lin_plain  [aw=w_t4_cal] 	if mig_samp == 1	, cluster(ID_t) partial($lin_plain)	
	eststo lab_stock_plain		
	qui sum migstock_labour [aw=w_t4_cal]	 if e(sample)	
	scalar mig_mean = r(mean)
	qui estadd scalar mig_mean
	distinct ID_t if e(sample)
	scalar Indiv = r(ndistinct)
	qui estadd scalar Indiv	
	
	
	ivreg2 migflow1_metropol $instr $lin_plain  [aw=w_t4_cal] if mig_samp == 1	, cluster(ID_t) partial($lin_plain)	
	eststo metro_flow1_plain		
	qui sum migflow1_metropol [aw=w_t4_cal]	 if e(sample)	
	scalar mig_mean = r(mean)
	qui estadd scalar mig_mean
	distinct ID_t if e(sample)
	scalar Indiv = r(ndistinct)
	qui estadd scalar Indiv		
	
	ivreg2 migflow5_metropol $instr $lin_plain  [aw=w_t4_cal] 	if mig_samp == 1	, cluster(ID_t) partial($lin_plain)	
	eststo metro_flow5_plain		
	qui sum migflow5_metropol [aw=w_t4_cal]	 if e(sample)	
	scalar mig_mean = r(mean)
	qui estadd scalar mig_mean
	distinct ID_t if e(sample)
	scalar Indiv = r(ndistinct)
	qui estadd scalar Indiv	

	ivreg2 migstock_metropol $instr $lin_plain  [aw=w_t4_cal] 	if mig_samp == 1	, cluster(ID_t) partial($lin_plain)	
	eststo metro_stock_plain		
	qui sum migstock_metropol [aw=w_t4_cal]	 if e(sample)	
	scalar mig_mean = r(mean)
	qui estadd scalar mig_mean
	distinct ID_t if e(sample)
	scalar Indiv = r(ndistinct)
	qui estadd scalar Indiv	
	
	
	
	esttab lab_* metro_* using "$results\SSA_lm_donut_neu_$date", append scsv keep(1.after_week) cells(b(fmt(3) star) se(par) p) stats(N Indiv mig_mean, fmt(0 0 3)) starlevels(* 0.1 ** 0.05 *** 0.01) stardetach title("Linear trends (no controls)") nodepvars mtitle("Labor market 1 yr" "Labor market 5 yrs" "Labor market lifetime" "Metropol 1 yr" "Metropol 5 yrs" "Metropol lifetime")	// unwbl_* unwkr_*

	restore	

	
	
*Panel B
preserve
	keep if inrange(age,25,55)
	keep if inrange(yob,1945,1964)
	est drop _all

	
	ivreg2 migflow1_labour $instr $lin_full  [aw=w_t4_cal] if mig_samp == 1	, cluster(ID_t) partial($lin_full)	
	eststo lab_flow1_plain		
	qui sum migflow1_labour [aw=w_t4_cal]	 if e(sample)	
	scalar mig_mean = r(mean)
	qui estadd scalar mig_mean
	distinct ID_t if e(sample)
	scalar Indiv = r(ndistinct)
	qui estadd scalar Indiv		
	
	ivreg2 migflow5_labour $instr $lin_full  [aw=w_t4_cal] 	if mig_samp == 1	, cluster(ID_t) partial($lin_full)	
	eststo lab_flow5_plain		
	qui sum migflow5_labour [aw=w_t4_cal]	 if e(sample)	
	scalar mig_mean = r(mean)
	qui estadd scalar mig_mean
	distinct ID_t if e(sample)
	scalar Indiv = r(ndistinct)
	qui estadd scalar Indiv	

	ivreg2 migstock_labour $instr $lin_full  [aw=w_t4_cal] 	if mig_samp == 1	, cluster(ID_t) partial($lin_full)	
	eststo lab_stock_plain		
	qui sum migstock_labour [aw=w_t4_cal]	 if e(sample)	
	scalar mig_mean = r(mean)
	qui estadd scalar mig_mean
	distinct ID_t if e(sample)
	scalar Indiv = r(ndistinct)
	qui estadd scalar Indiv	
	
	
	ivreg2 migflow1_metropol $instr $lin_full  [aw=w_t4_cal] if mig_samp == 1	, cluster(ID_t) partial($lin_full)	
	eststo metro_flow1_plain		
	qui sum migflow1_metropol [aw=w_t4_cal]	 if e(sample)	
	scalar mig_mean = r(mean)
	qui estadd scalar mig_mean
	distinct ID_t if e(sample)
	scalar Indiv = r(ndistinct)
	qui estadd scalar Indiv		
	
	ivreg2 migflow5_metropol $instr $lin_full  [aw=w_t4_cal] 	if mig_samp == 1	, cluster(ID_t) partial($lin_full)	
	eststo metro_flow5_plain		
	qui sum migflow5_metropol [aw=w_t4_cal]	 if e(sample)	
	scalar mig_mean = r(mean)
	qui estadd scalar mig_mean
	distinct ID_t if e(sample)
	scalar Indiv = r(ndistinct)
	qui estadd scalar Indiv	

	ivreg2 migstock_metropol $instr $lin_full  [aw=w_t4_cal] 	if mig_samp == 1	, cluster(ID_t) partial($lin_full)	
	eststo metro_stock_plain		
	qui sum migstock_metropol [aw=w_t4_cal]	 if e(sample)	
	scalar mig_mean = r(mean)
	qui estadd scalar mig_mean
	distinct ID_t if e(sample)
	scalar Indiv = r(ndistinct)
	qui estadd scalar Indiv		
	
	esttab lab_* metro_* using "$results\SSA_lm_donut_neu_$date", append scsv keep(1.after_week) cells(b(fmt(3) star) se(par) p) stats(N Indiv mig_mean, fmt(0 0 3)) starlevels(* 0.1 ** 0.05 *** 0.01) stardetach title("Linear trends (full controls)") nodepvars mtitle("Labor market 1 yr" "Labor market 5 yrs" "Labor market lifetime" "Metropol 1 yr" "Metropol 5 yrs" "Metropol lifetime")	// unwbl_* unwkr_*	

	restore	